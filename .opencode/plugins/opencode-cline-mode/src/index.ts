import { Plugin } from "@opencode/plugin";
import type { Context } from "@opencode/plugin/promise/plugin";

import { Logger } from "./logger.js";
import { loadPluginConfig } from "./config-loader.js";
import { buildClineAgents, toClineAgentInfo } from "./agent-builder.js";
import { PromptFetcher } from "./prompt-fetcher.js";
import type { FetchedPrompt } from "./prompt-fetcher.js";
import { GitHubAPIError } from "./utils/github-api.js";
import { PromptAdapter } from "./prompt-adapter.js";
import { getClineTools } from "./tools/index.js";
import { StateManager } from "./state-manager.js";

/**
 * Resolve the current default model as a V1-style `"provider/model"` string.
 *
 * V1 read `config.model`. V2 has no global config object; the closest source is
 * `ctx.model.default()`. Its output shape has varied across 2.x builds
 * (`ModelInfo` directly or `{ data: ModelInfo | null }`), so both are handled,
 * and an unknown model falls back to `"inherit"` exactly like V1 did.
 */
async function resolveDefaultModel(ctx: Context): Promise<string> {
  try {
    const result = (await ctx.model.default()) as unknown;
    const info =
      result && typeof result === "object" && "data" in result
        ? (result as { data?: unknown }).data
        : result;

    if (info && typeof info === "object") {
      const providerID = (info as { providerID?: unknown }).providerID;
      const id = (info as { id?: unknown }).id;
      if (typeof providerID === "string" && typeof id === "string") {
        return `${providerID}/${id}`;
      }
    }
  } catch {
    // Fall through to the V1 fallback value.
  }
  return "inherit";
}

/** Extract the provider segment from a `"provider/model"` string. */
function providerOf(model: string): string | undefined {
  const slash = model.indexOf("/");
  return slash > 0 ? model.slice(0, slash) : undefined;
}

export default Plugin.define({
  id: "cline-mode",
  async setup(ctx) {
    // V2 has no `ctx.directory`; plugin location supplies the directory and
    // project metadata. `project.name` does not exist in V2, so the canonical
    // project directory is used for the equivalent log field.
    const directory = ctx.location.directory;
    const projectLabel = ctx.location.project.canonical;

    // Logger is console-backed in V2 (see src/logger.ts).
    const logger = new Logger();

    try {
      const pluginConfig = loadPluginConfig(directory);
      await logger.info("Plugin config loaded", { config: pluginConfig });

      await logger.info("Fetching Cline prompts from GitHub...", {
        directory,
        project: projectLabel,
      });

      const fetcher = new PromptFetcher();
      const adapter = new PromptAdapter({
        yoloModeEnabled: pluginConfig.yolo_mode,
        cwd: directory,
      });

      let prompts = new Map<string, FetchedPrompt>();
      try {
        prompts = await fetcher.fetchAll();
        await logger.info("Successfully fetched Cline prompts", {
          fileCount: prompts.size,
          files: Array.from(prompts.keys()),
        });
      } catch (error: unknown) {
        // Fetching the upstream prompts is best-effort. Cline's repository
        // layout changes over time and the network may be unavailable, so a
        // failure must NOT prevent the plugin from loading. The plugin's own
        // integration notes (see PromptAdapter#getModeNote) still fully
        // describe plan/act behavior; upstream fragments only add flavor.
        const message = error instanceof Error ? error.message : String(error);
        await logger.warn("Failed to fetch Cline prompts from GitHub", {
          error: message,
          status: error instanceof GitHubAPIError ? error.status : undefined,
          rateLimitReset:
            error instanceof GitHubAPIError
              ? error.rateLimitReset?.toISOString()
              : undefined,
        });
        console.error(
          "[opencode-cline-mode] Could not fetch upstream Cline prompts; " +
            "continuing with built-in prompt notes. Errors are non-fatal.",
        );
      }

      const planPrompt = adapter.adapt(prompts, "plan");
      const actPrompt = adapter.adapt(prompts, "act");

      await logger.info("Cline prompts adapted successfully", {
        planPromptLength: planPrompt.systemPrompt.length,
        actPromptLength: actPrompt.systemPrompt.length,
        yoloModeEnabled: pluginConfig.yolo_mode,
      });

      const defaultModel = await resolveDefaultModel(ctx);
      const fallbackProvider = providerOf(defaultModel);

      const clineAgents = buildClineAgents({
        config: pluginConfig,
        defaultModel,
        planPrompt,
        actPrompt,
      });

      // Convert the V1 `AgentConfig` records into the V2 `Agent.Info` subset.
      const clineAgentInfos = Object.entries(clineAgents).map(([id, agent]) =>
        toClineAgentInfo(id, agent, fallbackProvider),
      );

      // ---------------------------------------------------------------------
      // Agent transform (V1 `config` hook)
      //
      // Behavioral differences from V1, unavoidable in V2:
      // - V1 could replace the whole agent map (`config.agent = {...}`). V2's
      //   AgentEditor exposes no `removeAll`/`add`, only `update`/`remove`
      //   per id, so built-in agents are intentionally NOT removed. The cline
      //   agents are registered/updated by id instead.
      // - `replace_default_agents: true` is preserved by selecting the default
      //   agent via `editor.default(...)`.
      // - V2 `Agent.Info` has no `temperature` or per-tool booleans, so those
      //   V1 fields are enforced at request time in the `context` hook below.
      // ---------------------------------------------------------------------
      await ctx.agent.transform((editor) => {
        for (const info of clineAgentInfos) {
          editor.update(info.id, (agent) => {
            // V2 `Agent.Info` fields use Effect-branded string types. The
            // plugin builds plain strings, so assign through `unknown`.
            agent.name = info.name as unknown as typeof agent.name;
            if (info.model) {
              agent.model = info.model as unknown as typeof agent.model;
            }
            if (info.system !== undefined) {
              agent.system = info.system;
            }
            if (info.description !== undefined) {
              agent.description = info.description;
            }
            agent.mode = info.mode;
            if (info.hidden !== undefined) {
              agent.hidden = info.hidden;
            }
          });
        }

        if (pluginConfig.replace_default_agents) {
          const requestedDefault = pluginConfig.default_agent || "cline-plan";
          const known = clineAgentInfos.some((a) => a.id === requestedDefault);
          editor.default(known ? requestedDefault : "cline-plan");
        }
      });

      if (pluginConfig.replace_default_agents) {
        await logger.info("Cline Mode: Default agents replaced", {
          visibleAgents: clineAgentInfos.map((a) => a.id),
          defaultAgent: pluginConfig.default_agent || "cline-plan",
          promptsFetchedFrom: "GitHub - cline/cline (main branch)",
          yoloMode: pluginConfig.yolo_mode,
        });
      } else {
        await logger.info("Cline Mode: Cline agents added alongside defaults", {
          clineAgents: clineAgentInfos.map((a) => a.id),
          promptsFetchedFrom: "GitHub - cline/cline (main branch)",
          yoloMode: pluginConfig.yolo_mode,
        });
      }

      // ---------------------------------------------------------------------
      // Tool registration (V1 `tool` map -> ctx.tool.transform)
      // ---------------------------------------------------------------------
      await ctx.tool.transform((editor) => {
        for (const tool of getClineTools()) {
          editor.add({
            name: tool.name,
            description: tool.description,
            input: tool.input,
            execute: tool.execute,
          });
        }
      });

      // ---------------------------------------------------------------------
      // Mode switching (V1 `chat.message` -> session hooks)
      //
      // V1 fired on the user message with `{ agent, sessionID }`. In V2 the
      // `prompt` hook runs BEFORE agent/model resolution and has NO agent
      // field, so it cannot drive the mode switch. The `context` hook fires
      // immediately before every agent model request and DOES expose
      // `event.agent`, so the mode switch, YOLO flag, per-agent temperature,
      // and per-agent tool restrictions all live there.
      //
      // The `prompt` hook is still registered (matching the documented V1->V2
      // mapping for `chat.message`) to eagerly create the per-session
      // StateManager and record admission. It intentionally does not switch
      // modes because the agent is unknown at that point.
      // ---------------------------------------------------------------------
      await ctx.session.hook("prompt", (event) => {
        // Ensure state exists for the session as soon as a prompt is admitted.
        StateManager.getInstance(event.sessionID);
      });

      await ctx.session.hook("context", async (event) => {
        const agent = event.agent;

        if (agent !== "cline-plan" && agent !== "cline-act") {
          return;
        }

        const stateManager = StateManager.getInstance(event.sessionID);
        stateManager.setYoloMode(pluginConfig.yolo_mode);
        stateManager.switchMode(agent === "cline-plan" ? "plan" : "act");

        // V1 stored per-agent temperature on the agent config. V2 applies it
        // as a generation option on the outgoing model request.
        const temperature =
          agent === "cline-plan"
            ? (pluginConfig.plan_temperature ?? 0.1)
            : (pluginConfig.act_temperature ?? 0.3);
        event.options.temperature = temperature;

        // V1 disabled write/edit/patch/bash for the plan agent via
        // `tools: { ...: false }`. V2 removes those tools from the request's
        // tool set for the same effect.
        if (agent === "cline-plan") {
          for (const disabled of ["write", "edit", "patch", "bash"]) {
            delete event.tools[disabled];
          }
        }

        await logger.info(`${agent} agent activated`, {
          sessionID: event.sessionID,
          agent,
          promptsSource: "Official Cline repository (GitHub)",
          yoloMode: pluginConfig.yolo_mode,
        });
      });

      // No long-lived resources were opened; hooks/transforms are disposed by
      // OpenCode when the plugin unloads.
      return;
    } catch (error: unknown) {
      await logger.error("Failed to initialize Cline Mode Plugin", {
        error: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : undefined,
      });
      throw error;
    }
  },
});

export { GitHubAPIError } from "./utils/github-api.js";
export { PromptAdapter } from "./prompt-adapter.js";
export { PromptFetcher } from "./prompt-fetcher.js";
export { ToolMapper } from "./tool-mapper.js";
