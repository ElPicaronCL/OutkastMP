import type {
  AgentConfig,
  ClineAgentInfo,
  ModelRef,
  PluginConfig,
} from "./types.js";
import type { AdaptedPrompt } from "./prompt-adapter.js";

interface BuildAgentsParams {
  config: Required<PluginConfig>;
  defaultModel: string;
  planPrompt: AdaptedPrompt;
  actPrompt: AdaptedPrompt;
}

/**
 * Parse a V1 model string into a V2 `{ id, providerID }` reference.
 *
 * V1 accepted an OpenCode model string such as `"anthropic/claude-sonnet-4"`.
 * V2 stores provider and model as separate fields. When the string has no
 * provider segment we fall back to `fallbackProvider` (typically the current
 * default model's provider). Returns `undefined` when no usable reference can
 * be produced, so the agent inherits the session model instead of guessing.
 */
export function parseModelRef(
  model: string | undefined,
  fallbackProvider?: string,
): ModelRef | undefined {
  if (!model || model === "inherit") {
    return undefined;
  }

  const slash = model.indexOf("/");
  if (slash > 0) {
    return {
      providerID: model.slice(0, slash),
      id: model.slice(slash + 1),
    };
  }

  if (fallbackProvider) {
    return { providerID: fallbackProvider, id: model };
  }

  return undefined;
}

/**
 * Convert a V1 `AgentConfig` into the V2 `Agent.Info` subset this plugin edits.
 *
 * Field mapping:
 * - `mode`        -> `mode` (V1 only used "primary"/"subagent").
 * - `model`       -> `model` (parsed into `{ id, providerID }`).
 * - `description` -> `description`.
 * - `system[]`    -> `system` (V2 uses one string; joined with a blank line).
 * - `hidden`      -> `hidden`.
 * - `temperature` -> NOT representable on `Agent.Info`; applied at request
 *                    time by the session `context` hook (see index.ts).
 * - `tools`       -> NOT representable on `Agent.Info`; enforced by removing
 *                    disabled tools from `event.tools` in the `context` hook.
 */
export function toClineAgentInfo(
  id: string,
  agent: AgentConfig,
  fallbackProvider?: string,
): ClineAgentInfo {
  return {
    id,
    name: id,
    model: parseModelRef(agent.model, fallbackProvider),
    system: agent.system?.join("\n\n"),
    description: agent.description,
    mode: agent.mode,
    hidden: agent.hidden,
  };
}

/**
 * Build cline-plan and cline-act agent configurations using adapted prompts
 */
export function buildClineAgents(
  params: BuildAgentsParams,
): Record<string, AgentConfig> {
  const { config, defaultModel, planPrompt, actPrompt } = params;

  const planModel = config.plan_model || defaultModel;
  const actModel = config.act_model || defaultModel;
  const planTemperature = config.plan_temperature ?? 0.1;
  const actTemperature = config.act_temperature ?? 0.3;

  return {
    "cline-plan": {
      mode: "primary",
      model: planModel,
      temperature: planTemperature,
      description:
        "Cline Plan Mode - Analysis and planning without code changes (prompts from official Cline repository)",
      tools: { write: false, edit: false, patch: false, bash: false },
      system: [planPrompt.systemPrompt],
    },
    "cline-act": {
      mode: "primary",
      model: actModel,
      temperature: actTemperature,
      description:
        "Cline Act Mode - Execute plans with full tool access (prompts from official Cline repository)",
      tools: { write: true, edit: true, patch: true, bash: true },
      system: [actPrompt.systemPrompt],
    },
  };
}
