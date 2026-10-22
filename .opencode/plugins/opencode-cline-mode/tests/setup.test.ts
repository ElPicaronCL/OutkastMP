/**
 * Basic smoke test to verify the V2 mock test infrastructure.
 */
import { describe, it, expect } from "vitest";
import {
  createMockPluginContext,
  getMockHandles,
} from "./mocks/context.js";

describe("Test Infrastructure", () => {
  it("creates a mock V2 plugin context", () => {
    const context = createMockPluginContext();

    expect(context).toBeDefined();
    expect(context.location).toBeDefined();
    expect(
      (context.location as { project: { canonical: string } }).project.canonical,
    ).toBe("test-project");
  });

  it("allows location overrides", () => {
    const context = createMockPluginContext({
      location: {
        directory: "/custom/path",
        project: { canonical: "custom-project" },
      },
    });

    const location = context.location as {
      directory: string;
      project: { canonical: string };
    };
    expect(location.project.canonical).toBe("custom-project");
    expect(location.directory).toBe("/custom/path");
  });

  it("captures agent transform updates", async () => {
    const context = createMockPluginContext();
    const editor = context.agent as {
      transform: (fn: (e: unknown) => void) => Promise<void>;
    };

    await editor.transform((e) => {
      const ed = e as {
        update: (id: string, fn: (a: Record<string, unknown>) => void) => void;
        default: (id: string) => void;
      };
      ed.update("demo", (agent) => {
        agent.name = "Demo";
      });
      ed.default("demo");
    });

    const handles = getMockHandles(context);
    expect(handles.agents.get("demo")).toBeDefined();
    expect(handles.defaultAgent).toBe("demo");
  });

  it("captures session hooks", async () => {
    const context = createMockPluginContext();
    const session = context.session as {
      hook: (name: string, fn: () => void) => Promise<unknown>;
    };

    await session.hook("prompt", () => {});

    const handles = getMockHandles(context);
    expect(typeof handles.sessionHooks.get("prompt")).toBe("function");
  });
});
