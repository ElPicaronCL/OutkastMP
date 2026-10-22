// OpenCode V2 entrypoint for harness-memory (npm package harness-memory@0.5.1).
//
// Background: harness-memory@0.5.1 ships a V1 OpenCode plugin factory
// (`harness-memory/plugin`). OpenCode V2.1.x refuses V1 plugins because the
// default export is a bare function instead of an object definition:
//   "Plugin must export a default definition with an id and an effect or setup
//    function. (cause: SchemaError(Expected object at ["default"]))"
//
// This file is a thin V2 adapter. It keeps the entire bundled V1 logic intact
// and only rebuilds the entrypoint/hook-registration layer:
//
//   1. Build a V1-compatible context shim (the V1 factory only reads
//      `ctx.directory`, verified by grepping dist/plugin/index.js).
//   2. Call the unmodified V1 factory to obtain its hooks object.
//   3. Re-register each V1 hook on the matching V2 hook domain.
//   4. Convert the V1 `session.idle` / `session.compacted` hooks (which are
//      server EVENTS in V2) into an event subscription.
//
// The `harness-memory` CLI and the `.opencode/commands/harness-memory-*.md`
// slash commands are untouched by this file.

import { Plugin } from "@opencode/plugin";
import { HarnessMemoryPlugin } from "harness-memory/plugin";

/** Build a minimal V1-style context the bundled factory can consume. */
function makeV1Context(ctx) {
  const directory = ctx?.location?.directory ?? process.cwd();
  return {
    directory,
    // The V1 factory only uses `ctx.directory`; the remaining fields are kept
    // for forward compatibility and in case future bundle revisions read them.
    project: ctx?.location?.project,
    worktree: ctx?.location?.directory,
    client: {
      app: {
        log: async ({ body } = {}) => {
          // V1 plugins used ctx.client.app.log({ service, level, message }).
          const level = body?.level ?? "info";
          const message = body?.message ?? "";
          const service = body?.service ?? "harness-memory";
          const line = `[${service}] ${message}`;
          if (level === "error") console.error(line);
          else if (level === "warn") console.warn(line);
          else console.log(line);
        },
      },
    },
  };
}

/**
 * Normalise a V1 system-prompt fragment (a string) into a V2 SystemPart.
 * V2 `SystemPart` is `{ type: "text", text: string }`, not a bare string.
 */
function toSystemPart(value) {
  if (value !== null && typeof value === "object" && typeof value.text === "string") {
    return value;
  }
  return { type: "text", text: String(value ?? "") };
}

/**
 * Best-effort extraction of a session id from a V2 event envelope.
 * V2 event envelopes carry the payload under `data` (see
 * @opencode/schema event-manifest), but we probe a few shapes defensively.
 */
function readEventSessionID(event, onMissing) {
  const id =
    event?.data?.sessionID ??
    event?.properties?.sessionID ??
    event?.sessionID;
  if (typeof id === "string" && id.length > 0) {
    return id;
  }
  if (typeof onMissing === "function") {
    onMissing(event);
  }
  return undefined;
}

export default Plugin.define({
  id: "harness-memory",
  async setup(ctx) {
    const v1 = await HarnessMemoryPlugin(makeV1Context(ctx));

    // -- chat.message -> session.hook("prompt") --------------------------
    // V1 read: input.sessionID/messageID/agent/model/variant and
    // extractMessageText(output.message, output.parts). We synthesise an
    // equivalent message+parts pair from the V2 prompt (text is the payload).
    await ctx.session.hook("prompt", async (event) => {
      const text = event?.prompt?.text;
      const parts = typeof text === "string" ? [{ type: "text", text }] : undefined;
      await v1["chat.message"](
        {
          sessionID: event.sessionID,
          messageID: event.messageID,
          agent: undefined,
          model: undefined,
          variant: undefined,
        },
        { message: { role: "user" }, parts },
      );
    });

    // -- chat.params -> session.hook("context") --------------------------
    // V1 extractModelRef reads providerID/modelID. V2 Model.Ref exposes
    // `id`/`providerID`, so pass both `id` and `modelID`.
    await ctx.session.hook("context", async (event) => {
      if (typeof v1["chat.params"] !== "function") return;
      await v1["chat.params"]({
        sessionID: event.sessionID,
        model: {
          providerID: event?.model?.providerID,
          modelID: event?.model?.id ?? event?.model?.modelID,
          id: event?.model?.id,
        },
      });
    });

    // -- experimental.chat.system.transform -> session.hook("context") ---
    // V1 pushed strings into output.system. V2 event.system is SystemPart[],
    // so wrap each pushed string as { type: "text", text }.
    await ctx.session.hook("context", async (event) => {
      if (typeof v1["experimental.chat.system.transform"] !== "function") return;
      const out = { system: [] };
      await v1["experimental.chat.system.transform"]({ sessionID: event.sessionID }, out);
      if (Array.isArray(out.system) && out.system.length > 0) {
        if (!Array.isArray(event.system)) event.system = [];
        event.system.push(...out.system.map(toSystemPart));
      }
    });

    // -- tool.execute.before -> tool.hook("execute.before") --------------
    // V1 read output.args and input.callID; V2 uses event.input/event.id.
    await ctx.tool.hook("execute.before", async (event) => {
      await v1["tool.execute.before"](
        { tool: event.tool, callID: String(event.id), sessionID: event.sessionID },
        { args: event.input },
      );
    });

    // -- tool.execute.after -> tool.hook("execute.after") ---------------
    // V1 read output.title/output.output/output.metadata. V2 carries the
    // result on event.result (completed) or event.error (error). We keep the
    // mapping faithful so isHarnessMemoryCliCall() detection still works:
    // it matches tool === "bash" and `${title} ${output}` containing
    // "harness-memory"/"memory:add"/etc.
    await ctx.tool.hook("execute.after", async (event) => {
      const out = { title: "", output: "", metadata: {} };
      if (event.status === "completed" && event.result) {
        const content = event.result.content;
        out.output =
          typeof content === "string"
            ? content
            : content !== undefined
              ? JSON.stringify(content)
              : "";
        out.metadata = event.result.metadata ?? {};
        out.title = (event.result.metadata && event.result.metadata.title) || event.tool;
      } else if (event.status === "error") {
        out.output = String(event.error?.message ?? event.error ?? "");
      }
      await v1["tool.execute.after"](
        { tool: event.tool, callID: String(event.id), sessionID: event.sessionID },
        out,
      );
    });

    // -- session.idle / session.compacted -> event subscription ----------
    // These are server EVENTS in V2, not hooks. `session.idle` still exists;
    // the V1 `session.compacted` hook maps to the V2 `session.compaction.ended`
    // event (there is no `session.compacted` event in V2).
    const controller = new AbortController();
    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
          if (event?.type === "session.idle") {
            const sessionID = readEventSessionID(event, () =>
              console.warn("[harness-memory] session.idle event missing sessionID"),
            );
            await v1["session.idle"]({ sessionID });
          } else if (
            event?.type === "session.compaction.ended" ||
            event?.type === "session.compacted"
          ) {
            const sessionID = readEventSessionID(event, () =>
              console.warn(
                "[harness-memory] session compaction event missing sessionID",
              ),
            );
            await v1["session.compacted"]({ sessionID });
          }
        }
      } catch (error) {
        if (!controller.signal.aborted) {
          console.warn("[harness-memory] event subscription error:", error);
        }
      }
    })();

    return () => controller.abort();
  },
});
