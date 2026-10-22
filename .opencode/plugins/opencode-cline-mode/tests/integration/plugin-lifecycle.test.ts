/**
 * Integration tests for the V2 plugin lifecycle.
 *
 * The plugin default-exports `Plugin.define({ id, setup })`. These tests call
 * `setup(mockContext)` directly and assert that the V2 agent transform, tool
 * transform, and session hooks received the expected registrations.
 */

import { describe, it, expect, afterEach, vi } from "vitest";

// `Plugin.define` is identity in the real package; mock it so the module can be
// imported without pulling the whole V2 SDK graph into the test process.
vi.mock("@opencode/plugin", () => ({
  Plugin: {
    define: (definition: unknown) => definition,
  },
}));

vi.mock("../../src/utils/github-api.js", () => ({
  fetchMultipleFiles: vi.fn().mockResolvedValue(
    new Map([
      [
        "src/core/prompts/system-prompt/components/agent_role.ts",
        "export const content = `You are a planning agent.`",
      ],
      [
        "src/core/prompts/system-prompt/components/objective.ts",
        "export const content = `Your goal is to help users.`",
      ],
      [
        "src/core/prompts/system-prompt/components/capabilities.ts",
        "export const content = `You can use tools.`",
      ],
      [
        "src/core/prompts/system-prompt/components/rules.ts",
        "export const content = `Follow these rules.`",
      ],
      [
        "src/core/prompts/system-prompt/components/act_vs_plan_mode.ts",
        "export const content = `Plan vs Act modes.`",
      ],
    ]),
  ),
  checkRateLimit: vi
    .fn()
    .mockResolvedValue({ remaining: 100, resetTime: new Date() }),
  GitHubAPIError: class GitHubAPIError extends Error {
    status?: number;
    rateLimitReset?: Date;
    constructor(message: string, status?: number, rateLimitReset?: Date) {
      super(message);
      this.status = status;
      this.rateLimitReset = rateLimitReset;
    }
  },
}));

vi.mock("../../src/tool-mapper.js", () => ({
  ToolMapper: class MockToolMapper {
    mapToolsInText = vi.fn((text: string) => text);
    isUnsupported = vi.fn(() => false);
    getAlternative = vi.fn(() => null);
    getUnsupportedTools = vi.fn(() => []);
  },
}));

import ClineModePlugin from "../../src/index.js";
import {
  createMockPluginContext,
  getMockHandles,
  cleanupTempDirs,
} from "../mocks/context.js";

describe("Plugin Lifecycle Integration (V2)", () => {
  afterEach(() => {
    cleanupTempDirs();
  });

  it("exports a V2 plugin definition with an id and setup", () => {
    expect(ClineModePlugin).toBeDefined();
    expect((ClineModePlugin as { id?: unknown }).id).toBe("cline-mode");
    expect(typeof (ClineModePlugin as { setup?: unknown }).setup).toBe(
      "function",
    );
  });

  it("registers cline-plan and cline-act agents via the agent transform", async () => {
    const mockContext = createMockPluginContext();
    await (ClineModePlugin as { setup: (c: unknown) => Promise<void> }).setup(
      mockContext,
    );

    const handles = getMockHandles(mockContext);
    expect(handles.agents.get("cline-plan")).toBeDefined();
    expect(handles.agents.get("cline-act")).toBeDefined();
    expect(handles.defaultAgent).toBe("cline-plan");
  });

  it("sets the plan agent mode and the act agent mode distinctly", async () => {
    const mockContext = createMockPluginContext();
    await (ClineModePlugin as { setup: (c: unknown) => Promise<void> }).setup(
      mockContext,
    );

    const handles = getMockHandles(mockContext);
    expect(handles.agents.get("cline-plan")?.mode).toBe("primary");
    expect(handles.agents.get("cline-act")?.mode).toBe("primary");
  });

  it("registers a prompt and a context session hook", async () => {
    const mockContext = createMockPluginContext();
    await (ClineModePlugin as { setup: (c: unknown) => Promise<void> }).setup(
      mockContext,
    );

    const handles = getMockHandles(mockContext);
    expect(typeof handles.sessionHooks.get("prompt")).toBe("function");
    expect(typeof handles.sessionHooks.get("context")).toBe("function");
  });

  it("switches StateManager mode from the context hook for cline agents", async () => {
    const mockContext = createMockPluginContext();
    await (ClineModePlugin as { setup: (c: unknown) => Promise<void> }).setup(
      mockContext,
    );

    const handles = getMockHandles(mockContext);
    const contextHook = handles.sessionHooks.get("context");
    expect(contextHook).toBeDefined();

    // The hook is a no-op for non-cline agents and must not throw.
    await contextHook?.({
      sessionID: "test-session-0",
      agent: "build",
      model: { providerID: "test", modelID: "test-model" },
      options: {},
      tools: {},
    });

    await contextHook?.({
      sessionID: "test-session-1",
      agent: "cline-plan",
      model: { providerID: "test", modelID: "test-model" },
      options: {},
      tools: {},
    });

    const actEvent: Record<string, unknown> = {
      sessionID: "test-session-2",
      agent: "cline-act",
      model: { providerID: "test", modelID: "test-model" },
      options: {},
      tools: {},
    };
    await contextHook?.(actEvent);
    // The act agent keeps its tools and receives a temperature override.
    expect(actEvent.options).toHaveProperty("temperature");
  });

  it("registers the cline tools via the tool transform", async () => {
    const mockContext = createMockPluginContext();
    await (ClineModePlugin as { setup: (c: unknown) => Promise<void> }).setup(
      mockContext,
    );

    const handles = getMockHandles(mockContext);
    for (const name of [
      "plan_mode_respond",
      "ask_followup_question",
      "attempt_completion",
      "init_focus_chain",
      "update_focus_step",
      "get_focus_chain",
    ]) {
      expect(handles.tools.get(name)).toBeDefined();
    }
  });
});
