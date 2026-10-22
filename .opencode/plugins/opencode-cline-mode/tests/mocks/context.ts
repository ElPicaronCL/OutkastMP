/**
 * Mock utilities for testing the V2 plugin context.
 *
 * The plugin is a V2 `Plugin.define({ id, setup })` definition, so `setup`
 * receives a V2 context. This module builds a minimal-but-faithful mock of the
 * parts of that context the plugin actually touches:
 *   - `location.directory` / `location.project.canonical`
 *   - `model.default()`
 *   - `agent.transform(editor)`
 *   - `tool.transform(editor)`
 *   - `session.hook(name, handler)` with captured `prompt` / `context` handlers
 */

import type { Agent } from "@opencode/schema/agent";
import * as fs from "fs";
import * as path from "path";
import * as os from "os";

let tempDirs: string[] = [];

/** Minimal mutable agent record used by the mock AgentEditor. */
export interface MockAgentInfo {
  id: string;
  name?: string;
  mode?: string;
  model?: unknown;
  system?: unknown;
  description?: string;
  hidden?: boolean;
}

/** Minimal tool record used by the mock ToolEditor. */
export interface MockToolInfo {
  name: string;
  description: string;
  input: unknown;
  execute: (...args: unknown[]) => unknown;
}

type SessionHookHandler = (event: Record<string, unknown>) => unknown;

/**
 * Captured handles from the mock context, for assertions.
 */
export interface MockContextHandles {
  agents: Map<string, MockAgentInfo>;
  defaultAgent: string | undefined;
  tools: Map<string, MockToolInfo>;
  sessionHooks: Map<string, SessionHookHandler>;
}

const handlesRegistry = new WeakMap<object, MockContextHandles>();

/**
 * Create a mock V2 plugin context for testing.
 */
export function createMockPluginContext(
  overrides?: Record<string, unknown>,
): Record<string, unknown> {
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), "cline-plugin-test-"));
  tempDirs.push(tempDir);

  const agents = new Map<string, MockAgentInfo>();
  const tools = new Map<string, MockToolInfo>();
  const sessionHooks = new Map<string, SessionHookHandler>();
  const handles: MockContextHandles = {
    agents,
    defaultAgent: undefined,
    tools,
    sessionHooks,
  };

  const ctx: Record<string, unknown> = {
    location: {
      directory: tempDir,
      project: { canonical: "test-project" },
    },
    model: {
      default: async () => ({ providerID: "test", id: "test-model" }),
    },
    agent: {
      transform: async (fn: (editor: unknown) => void) => {
        const editor = {
          list: () => Array.from(agents.values()),
          get: (id: string) => agents.get(id),
          default: (id: string | undefined) => {
            handles.defaultAgent = id;
          },
          update: (id: string, update: (agent: MockAgentInfo) => void) => {
            const existing: MockAgentInfo = agents.get(id) ?? { id };
            update(existing);
            agents.set(id, existing);
          },
          remove: (id: string) => {
            agents.delete(id);
          },
        };
        fn(editor);
      },
    },
    tool: {
      transform: async (fn: (editor: unknown) => void) => {
        const editor = {
          list: () => Array.from(tools.values()),
          get: (id: string) => tools.get(id),
          add: (info: MockToolInfo) => {
            tools.set(info.name, info);
          },
          update: (id: string, update: (tool: MockToolInfo) => void) => {
            const existing = tools.get(id);
            if (existing) update(existing);
          },
          remove: (id: string) => {
            tools.delete(id);
          },
        };
        fn(editor);
      },
    },
    session: {
      hook: async (name: string, handler: SessionHookHandler) => {
        sessionHooks.set(name, handler);
        return { dispose: async () => {} };
      },
    },
    ...overrides,
  };

  handlesRegistry.set(ctx, handles);
  return ctx;
}

/** Retrieve captured handles for a mock context created above. */
export function getMockHandles(context: object): MockContextHandles {
  const handles = handlesRegistry.get(context);
  if (!handles) {
    throw new Error("Context was not created by createMockPluginContext");
  }
  return handles;
}

/** Type-only import hook so `Agent` stays referenced for consumers. */
export type MockAgent = Agent.Info;

/**
 * Cleanup all temp directories (call in afterEach)
 */
export function cleanupTempDirs(): void {
  for (const dir of tempDirs) {
    try {
      fs.rmSync(dir, { recursive: true, force: true });
    } catch {
      // ignore cleanup errors
    }
  }
  tempDirs = [];
}
