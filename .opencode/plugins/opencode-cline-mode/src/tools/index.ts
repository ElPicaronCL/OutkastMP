/**
 * V2 tool definitions for Cline mode.
 *
 * V1 exported plain string returns and used `tool({ args: <zod-ish>, ... })`
 * from `@opencode-ai/plugin`. V2 registers tools through
 * `ctx.tool.transform((editor) => editor.add({...}))`, schemas are JSON Schema,
 * and executors return `Tool.Result` (`{ content: string }`).
 *
 * The tool names, descriptions, StateManager usage, and returned strings are
 * preserved from the V1 implementation. Only the registration shape changed.
 */

import type { ToolContext } from "@opencode/plugin/promise/tool";
import { StateManager } from "../state-manager.js";

/**
 * Minimal JSON Schema shape understood by V2 tool inputs.
 *
 * The index signature keeps this assignable to the V2 `JsonSchema.JsonSchema`
 * type (`Record<string, unknown>`).
 */
export interface JsonSchemaObject {
  type: "object";
  properties: Record<string, unknown>;
  required?: string[];
  additionalProperties?: boolean;
  [key: string]: unknown;
}

/**
 * A V2 tool definition. Kept structural (not importing `Tool.Info`) so the
 * tools module stays free of deep schema imports; it is assignable to the
 * `editor.add(...)` argument.
 */
export interface ClineToolDefinition {
  name: string;
  description: string;
  input: JsonSchemaObject;
  execute: (
    input: unknown,
    context: ToolContext,
  ) => Promise<
    | { content: string }
    | { content: string; metadata?: Record<string, unknown> }
  >;
}

interface PlanModeRespondInput {
  response: string;
  options?: string[];
  needs_more_exploration?: boolean;
}

interface AskFollowupQuestionInput {
  question: string;
  options?: string[];
}

interface AttemptCompletionInput {
  result: string;
  command?: string;
}

interface InitFocusChainInput {
  steps: string[];
}

interface UpdateFocusStepInput {
  step_index: number;
  status: "in_progress" | "completed" | "failed";
  notes?: string;
}

interface ApprovePlanInput {
  plan_summary?: string;
}

/** Access to the session state manager for the current tool call. */
function stateFor(context: ToolContext): StateManager | null {
  return context.sessionID ? StateManager.getInstance(context.sessionID) : null;
}

/**
 * V1 `context.metadata({ title, metadata })` recorded tool-call metadata.
 * V2 exposes `context.progress(metadata)` for the same purpose. The outer
 * `title` wrapper had no V2 equivalent, so the inner metadata is forwarded.
 */
async function reportMetadata(
  context: ToolContext,
  metadata: Record<string, unknown>,
): Promise<void> {
  try {
    await context.progress(metadata);
  } catch {
    // Progress reporting is best-effort; never fail the tool because of it.
  }
}

export const planModeRespondTool: ClineToolDefinition = {
  name: "plan_mode_respond",
  description:
    "Respond to the user in PLAN MODE. Use this to share thoughts, analysis, or present plans directly without using thinking tags. This is the primary way to communicate in PLAN MODE.",
  input: {
    type: "object",
    properties: {
      response: {
        type: "string",
        description: "The response to share with user",
      },
      options: {
        type: "array",
        items: { type: "string" },
        description:
          "Optional list of suggested answers for the user to choose from",
      },
      needs_more_exploration: {
        type: "boolean",
        description:
          "Set to true if you need to gather more information before finalizing the plan",
      },
    },
    required: ["response"],
    additionalProperties: false,
  },
  execute: async (rawInput, context) => {
    const args = rawInput as PlanModeRespondInput;
    const { response, options, needs_more_exploration } = args;

    // Validate response parameter
    if (!response || typeof response !== "string") {
      return {
        content:
          "❌ Error: Invalid response parameter. Response must be a non-empty string.",
      };
    }

    await reportMetadata(context, {
      title: "📋 Plan Created",
      mode: "plan",
      type: "plan_response",
      hasOptions: !!options,
      needsMoreExploration: needs_more_exploration,
    });

    // Create visual box for plan response
    const boxWidth = 65;
    const topBorder = "╔" + "═".repeat(boxWidth - 2) + "╗";
    const bottomBorder = "╚" + "═".repeat(boxWidth - 2) + "╝";
    const separator = "╠" + "═".repeat(boxWidth - 2) + "╣";

    const createLine = (text: string) => {
      const padding = boxWidth - 4 - text.length;
      return "║ " + text + " ".repeat(Math.max(0, padding)) + " ║";
    };

    if (needs_more_exploration) {
      return {
        content: `${topBorder}
${createLine("🔍 继续探索")}
${separator}

${response}

**注意**: 需要更多信息来完善计划。继续使用只读工具收集信息。

${bottomBorder}`,
      };
    }

    let formattedResponse = `${topBorder}
${createLine("📋 实施计划")}
${separator}

${response}`;

    if (options && options.length > 0) {
      formattedResponse += "\n\n**选项**:";
      options.forEach((opt, i) => {
        formattedResponse += `\n${i + 1}. ${opt}`;
      });
    }

    formattedResponse += `\n\n${bottomBorder}`;

    return { content: formattedResponse };
  },
};

export const askFollowupQuestionTool: ClineToolDefinition = {
  name: "ask_followup_question",
  description:
    "Ask the user a clarifying question to better understand their requirements. Use this in PLAN MODE when you need more information.",
  input: {
    type: "object",
    properties: {
      question: { type: "string", description: "The question to ask the user" },
      options: {
        type: "array",
        items: { type: "string" },
        description: "Optional list of suggested answers",
      },
    },
    required: ["question"],
    additionalProperties: false,
  },
  execute: async (rawInput, context) => {
    const args = rawInput as AskFollowupQuestionInput;

    await reportMetadata(context, {
      title: "Question",
      question: args.question,
      options: args.options,
    });

    let response = `❓ **Question**: ${args.question}`;

    if (args.options && args.options.length > 0) {
      response += "\n\n**Options**:";
      args.options.forEach((opt, i) => {
        response += `\n${i + 1}. ${opt}`;
      });
    }

    return { content: response };
  },
};

export const attemptCompletionTool: ClineToolDefinition = {
  name: "attempt_completion",
  description:
    "Present the completed task result to the user. Use this in ACT MODE when the task is finished.",
  input: {
    type: "object",
    properties: {
      result: {
        type: "string",
        description: "The result or summary of the task",
      },
      command: {
        type: "string",
        description: "Optional command to run to demonstrate the result",
      },
    },
    required: ["result"],
    additionalProperties: false,
  },
  execute: async (rawInput, context) => {
    const args = rawInput as AttemptCompletionInput;
    const stateManager = stateFor(context);

    // Mark all remaining steps as completed
    if (stateManager) {
      const focusChain = stateManager.getFocusChain();
      if (focusChain) {
        focusChain.steps.forEach((step, index) => {
          if (step.status === "pending" || step.status === "in_progress") {
            stateManager.completeStep(index);
          }
        });
      }
    }

    await reportMetadata(context, {
      title: "Task Complete",
      hasCommand: !!args.command,
      progress: stateManager?.formatProgress(),
    });

    let response = `✅ **Task Completed**\n\n${args.result}`;

    if (stateManager) {
      const progress = stateManager.getProgress();
      if (progress.total > 0) {
        response += `\n\n${stateManager.formatProgress()}`;
      }
    }

    if (args.command) {
      response += `\n\n**Suggested command**: \`${args.command}\``;
    }

    return { content: response };
  },
};

// Focus Chain tools
export const initFocusChainTool: ClineToolDefinition = {
  name: "init_focus_chain",
  description:
    "Initialize a focus chain (task progress tracker) with a list of steps. Use this at the beginning of ACT MODE to track plan execution.",
  input: {
    type: "object",
    properties: {
      steps: {
        type: "array",
        items: { type: "string" },
        description: "List of steps to execute in the plan",
      },
    },
    required: ["steps"],
    additionalProperties: false,
  },
  execute: async (rawInput, context) => {
    const args = rawInput as InitFocusChainInput;
    const stateManager = stateFor(context);

    if (!stateManager) {
      return {
        content:
          "⚠️ Warning: Session state not available. Progress tracking disabled.",
      };
    }

    stateManager.initializeFocusChain(args.steps);

    const progress = stateManager.getProgress();

    await reportMetadata(context, {
      title: "Focus Chain Initialized",
      totalSteps: progress.total,
      steps: args.steps,
    });

    return {
      content: `📋 **Focus Chain Initialized**

${args.steps.map((step, i) => `${i + 1}. ⏳ ${step}`).join("\n")}

**Total**: ${progress.total} steps
**Status**: Ready to execute

Use \`update_focus_step\` to mark steps as in_progress, completed, or failed.`,
    };
  },
};

export const updateFocusStepTool: ClineToolDefinition = {
  name: "update_focus_step",
  description:
    "Update the status of a step in the focus chain. Use this in ACT MODE to track progress as you execute the plan.",
  input: {
    type: "object",
    properties: {
      step_index: {
        type: "number",
        description: "Index of the step (0-based)",
      },
      status: {
        type: "string",
        enum: ["in_progress", "completed", "failed"],
        description: "New status for the step",
      },
      notes: {
        type: "string",
        description: "Optional notes about this step",
      },
    },
    required: ["step_index", "status"],
    additionalProperties: false,
  },
  execute: async (rawInput, context) => {
    const args = rawInput as UpdateFocusStepInput;
    const stateManager = stateFor(context);

    if (!stateManager) {
      return {
        content: "⚠️ Warning: Session state not available. Cannot update step.",
      };
    }

    const focusChain = stateManager.getFocusChain();
    if (!focusChain) {
      return {
        content:
          "⚠️ Warning: No focus chain initialized. Use `init_focus_chain` first.",
      };
    }

    if (args.step_index < 0 || args.step_index >= focusChain.steps.length) {
      return {
        content: `❌ Error: Invalid step index ${args.step_index}. Valid range: 0-${focusChain.steps.length - 1}`,
      };
    }

    const step = focusChain.steps[args.step_index];

    switch (args.status) {
      case "in_progress":
        stateManager.startStep(args.step_index);
        break;
      case "completed":
        stateManager.completeStep(args.step_index, args.notes);
        break;
      case "failed":
        stateManager.failStep(args.step_index, args.notes);
        break;
    }

    const progress = stateManager.getProgress();
    const statusEmoji = {
      in_progress: "🔄",
      completed: "✅",
      failed: "❌",
    };

    await reportMetadata(context, {
      title: "Step Updated",
      stepIndex: args.step_index,
      stepDescription: step.description,
      status: args.status,
      progress: progress,
    });

    let response = `${statusEmoji[args.status]} **Step ${args.step_index + 1}: ${args.status.toUpperCase()}**

${step.description}`;

    if (args.notes) {
      response += `\n\n**Notes**: ${args.notes}`;
    }

    response += `\n\n${stateManager.formatProgress()}`;

    // Check if all steps completed
    if (progress.completed === progress.total && progress.total > 0) {
      response +=
        "\n\n🎉 **All steps completed!** Consider using `attempt_completion` to present the final result.";
    }

    return { content: response };
  },
};

export const getFocusChainTool: ClineToolDefinition = {
  name: "get_focus_chain",
  description:
    "Get the current focus chain status. Use this to check progress in ACT MODE.",
  input: {
    type: "object",
    properties: {},
    additionalProperties: false,
  },
  execute: async (_rawInput, context) => {
    const stateManager = stateFor(context);

    if (!stateManager) {
      return { content: "⚠️ Warning: Session state not available." };
    }

    const focusChain = stateManager.getFocusChain();
    if (!focusChain) {
      return {
        content:
          "📋 No focus chain initialized. Use `init_focus_chain` to create one.",
      };
    }

    const progress = stateManager.getProgress();
    const statusEmoji = {
      pending: "⏳",
      in_progress: "🔄",
      completed: "✅",
      failed: "❌",
    };

    let response = `📋 **Focus Chain Status**\n\n`;

    response += focusChain.steps
      .map(
        (step, i) =>
          `${i + 1}. ${statusEmoji[step.status]} ${step.description}${step.notes ? ` (${step.notes})` : ""}`,
      )
      .join("\n");

    response += `\n\n${stateManager.formatProgress()}`;
    response += `\n\n**Details**:
- Total: ${progress.total}
- Completed: ${progress.completed}
- Failed: ${progress.failed}
- Pending: ${progress.total - progress.completed - progress.failed}`;

    return { content: response };
  },
};

/** Optional permission gate used by the (unregistered) plan-approval tool. */
export type PermissionAssert = (input: {
  sessionID: string;
  agent: string;
  action: string;
  resources: string[];
  metadata?: Record<string, unknown>;
}) => Promise<void>;

/**
 * Build the plan-approval tool.
 *
 * V1 called `context.ask({ permission, patterns, ... })`. V2 exposes the
 * equivalent authorization path as `ctx.permission.assert(...)`, which lives on
 * the plugin context rather than the tool context, so the caller passes it in.
 * This tool is exported for parity but is NOT registered by `getClineTools()`,
 * matching V1 (the V1 map never exposed it either).
 */
export function createApprovePlanTool(
  assert: PermissionAssert,
): ClineToolDefinition {
  return {
    name: "approve_plan",
    description:
      "Request user approval for the current plan. After approval, asks if user wants to switch to Act Mode or stay in Plan Mode.",
    input: {
      type: "object",
      properties: {
        plan_summary: {
          type: "string",
          description: "Optional summary of the plan being approved",
        },
      },
      additionalProperties: false,
    },
    execute: async (rawInput, context) => {
      const args = rawInput as ApprovePlanInput;
      const stateManager = stateFor(context);

      if (stateManager) {
        stateManager.setAwaitingPlanResponse(true);
        if (args.plan_summary) {
          stateManager.setLastPlan(args.plan_summary);
        }
      }

      await assert({
        sessionID: context.sessionID,
        agent: context.agent,
        action: "plan_approval",
        resources: ["cline-plan:approve"],
        metadata: {
          agent: context.agent,
          sessionID: context.sessionID,
          planSummary: args.plan_summary,
        },
      });

      if (stateManager) {
        stateManager.setAwaitingPlanResponse(false);
        stateManager.setModeSwitched(true);
      }

      await reportMetadata(context, {
        title: "Plan Approved - What's Next?",
        status: "approved",
        agent: context.agent,
        yoloMode: stateManager?.isYoloMode() || false,
        options: ["Switch to Act Mode", "Stay in Plan Mode"],
      });

      // YOLO 模式：直接提示切换
      if (stateManager?.isYoloMode()) {
        return {
          content: `[PLAN APPROVED]

The plan has been approved!

**YOLO Mode**: Automatically switching to ACT MODE.

**Switching to ACT MODE**:
- Press \`Tab\` and select \`cline-act\`
- Or run: \`opencode --agent cline-act\`

The approved plan will be executed step by step in ACT MODE.`,
        };
      }

      // 标准模式：提供两个选项
      return {
        content: `[PLAN APPROVED]

The plan has been approved!

**What would you like to do next?**

**Option 1: Switch to Act Mode** ✅
Execute the plan now by switching to the \`cline-act\` agent:
- Press \`Tab\` and select \`cline-act\`
- Or run: \`opencode --agent cline-act\`

**Option 2: Stay in Plan Mode** 📋
Continue in \`cline-plan\` to:
- Review the plan in more detail
- Make modifications before execution
- Discuss alternative approaches

**Your choice**: Reply with "switch" or "act" to execute now, or continue the conversation to stay in plan mode.`,
      };
    },
  };
}

export const startActTool: ClineToolDefinition = {
  name: "start_act",
  description:
    "Switch from PLAN MODE to ACT MODE to execute the approved plan. Use this when you have presented a complete plan and the user is ready to execute it.",
  input: {
    type: "object",
    properties: {},
    additionalProperties: false,
  },
  execute: async (_rawInput, context) => {
    const stateManager = stateFor(context);

    if (stateManager) {
      stateManager.setModeSwitched(true);
    }

    await reportMetadata(context, {
      title: "Switching to ACT MODE",
      fromAgent: context.agent,
      targetAgent: "cline-act",
      sessionID: context.sessionID,
      yoloMode: stateManager?.isYoloMode() || false,
    });

    const yoloNote = stateManager?.isYoloMode()
      ? "\n\n**YOLO Mode**: Auto-approval enabled. Plan will be executed automatically."
      : "";

    return {
      content: `🔄 **Switching to ACT MODE**

You are about to switch from PLAN MODE to ACT MODE to execute the approved plan.

**How to switch**:
1. Press \`Tab\` to open agent selector
2. Select \`cline-act\` from the list
3. The approved plan will be executed step by step

**Alternative methods**:
- Run: \`opencode --agent cline-act\`
- Or restart OpenCode with: \`opencode\` and select cline-act agent

**What happens in ACT MODE**:
- ✅ File modifications (write, edit, patch)
- ✅ Command execution (bash)
- ✅ Plan execution with progress tracking
- ✅ Verification of changes${yoloNote}

**Ready to execute!** Switch to \`cline-act\` agent now to begin implementation.`,
    };
  },
};

/**
 * The tool set registered on `ctx.tool.transform`. Same six tools (and same
 * order) as V1 `getClineTools()`.
 */
export function getClineTools(): ClineToolDefinition[] {
  return [
    planModeRespondTool,
    askFollowupQuestionTool,
    attemptCompletionTool,
    initFocusChainTool,
    updateFocusStepTool,
    getFocusChainTool,
  ];
}
