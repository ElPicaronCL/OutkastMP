/**
 * Tool mapper for converting Cline tool names to OpenCode equivalents
 */

import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

export interface ToolMapping {
  tools: Record<string, string>;
  unsupported: string[];
  alternatives: Record<string, string>;
}

export class ToolMapper {
  private mapping: ToolMapping;

  constructor() {
    this.mapping = this.loadMapping();
  }

  private escapeRegExp(str: string): string {
    return str.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  }

  private loadMapping(): ToolMapping {
    const __filename = fileURLToPath(import.meta.url);
    const __dirname = path.dirname(__filename);

    // The mapping lives at `<plugin root>/config/tool-mapping.json`, but this
    // module runs from `<plugin root>/dist/` after `tsc`. Resolve against the
    // plugin root explicitly and keep a couple of legacy fallbacks so the
    // lookup works whether the code runs from `src/`, `dist/`, or a vendored
    // copy. (The original single `../../config` path pointed one level too
    // high when running from `dist/`, so setup threw before registering.)
    const candidates = [
      path.join(__dirname, "..", "config", "tool-mapping.json"),
      path.join(__dirname, "..", "..", "config", "tool-mapping.json"),
    ];

    let lastError: unknown;
    for (const configPath of candidates) {
      try {
        const content = fs.readFileSync(configPath, "utf-8");
        return JSON.parse(content) as ToolMapping;
      } catch (error) {
        lastError = error;
      }
    }

    throw new Error(
      `Failed to load tool mapping configuration: ${lastError instanceof Error ? lastError.message : String(lastError)}`,
    );
  }

  /**
   * Map a Cline tool name to OpenCode equivalent
   */
  mapTool(clineTool: string): string | null {
    if (this.isUnsupported(clineTool)) {
      return null;
    }

    return this.mapping.tools[clineTool] || clineTool;
  }

  /**
   * Check if a tool is unsupported
   */
  isUnsupported(tool: string): boolean {
    return this.mapping.unsupported.includes(tool);
  }

  /**
   * Get alternative for an unsupported tool
   */
  getAlternative(tool: string): string | null {
    return this.mapping.alternatives[tool] || null;
  }

  /**
   * Map all tool references in a text
   */
  mapToolsInText(text: string): string {
    let result = text;

    for (const [clineTool, openCodeTool] of Object.entries(
      this.mapping.tools,
    )) {
      const escapedTool = this.escapeRegExp(clineTool);
      const patterns = [
        new RegExp(`\\b${escapedTool}\\b`, "g"),
        new RegExp(`\`${escapedTool}\``, "g"),
        new RegExp(`\\*\\*${escapedTool}\\*\\*`, "g"),
      ];

      for (const pattern of patterns) {
        result = result.replace(pattern, (match) => {
          if (match.includes("`")) {
            return `\`${openCodeTool}\``;
          }
          if (match.includes("**")) {
            return `**${openCodeTool}**`;
          }
          return openCodeTool;
        });
      }
    }

    for (const unsupportedTool of this.mapping.unsupported) {
      const alternative = this.getAlternative(unsupportedTool);
      if (alternative) {
        const escapedTool = this.escapeRegExp(unsupportedTool);
        const patterns = [
          new RegExp(`\\b${escapedTool}\\b`, "g"),
          new RegExp(`\`${escapedTool}\``, "g"),
          new RegExp(`\\*\\*${escapedTool}\\*\\*`, "g"),
        ];

        for (const pattern of patterns) {
          result = result.replace(pattern, (match) => {
            if (match.includes("`")) {
              return `\`${alternative}\``;
            }
            if (match.includes("**")) {
              return `**${alternative}**`;
            }
            return alternative;
          });
        }
      }
    }

    return result;
  }

  /**
   * Get all supported tools
   */
  getSupportedTools(): string[] {
    return Object.keys(this.mapping.tools);
  }

  /**
   * Get all unsupported tools
   */
  getUnsupportedTools(): string[] {
    return this.mapping.unsupported;
  }
}
