import type { LogBody } from "./types.js";

/**
 * Logger utility for OpenCode plugins.
 *
 * V1 logged through `client.app.log(...)`. The V2 plugin context has no such
 * endpoint: `ctx.app` only exposes `{ name, version, channel }`. The minimal
 * faithful port therefore writes to `console` while keeping the exact same
 * service tag, levels, and message payloads so existing log messages survive.
 */
export class Logger {
  private service: string = "opencode-cline-mode";

  async info(message: string, extra?: Record<string, unknown>): Promise<void> {
    await this.log("info", message, extra);
  }

  async warn(message: string, extra?: Record<string, unknown>): Promise<void> {
    await this.log("warn", message, extra);
  }

  async error(message: string, extra?: Record<string, unknown>): Promise<void> {
    await this.log("error", message, extra);
  }

  async debug(message: string, extra?: Record<string, unknown>): Promise<void> {
    await this.log("debug", message, extra);
  }

  private async log(
    level: LogBody["level"],
    message: string,
    extra?: Record<string, unknown>,
  ): Promise<void> {
    try {
      const line = `[${this.service}] ${message}`;
      if (extra !== undefined) {
        console.error(line, extra);
      } else {
        console.error(line);
      }
    } catch (error) {
      console.error(`[${this.service}] Failed to log:`, error);
    }
  }
}
