import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema } from "@modelcontextprotocol/sdk/types.js";
import * as fs from "fs";
import * as path from "path";

const server = new Server(
  { name: "mta-neon-tools", version: "1.0.0" },
  { capabilities: { tools: {} } }
);

// Define tools your AI can call
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "read_mta_logs",
      description: "Reads recent server logs from the MTA-Neon gamemode directory.",
      inputSchema: {
        type: "object",
        properties: {
          lines: { type: "number", description: "Number of lines to read from the end of the log" }
        },
        required: ["lines"]
      }
    }
  ]
}));

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "read_mta_logs") {
    const linesCount = (request.params.arguments?.lines as number) || 50;
    // Adjust path to your MTA server logs folder
    const logPath = path.join(process.env.HOME || "", "Documents/OutkastMP/deathmatch/logs/server.log");

    try {
      const data = fs.readFileSync(logPath, "utf-8");
      const lines = data.split("\n");
      const tail = lines.slice(-linesCount).join("\n");
      return { content: [{ type: "text", text: tail }] };
    } catch (error: any) {
      return { content: [{ type: "text", text: `Error reading logs: ${error.message}` }], isError: true };
    }
  }
  throw new Error(`Unknown tool: ${request.params.name}`);
});

// Start server over stdio
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}
main().catch((error) => {
  console.error("Server error:", error);
  process.exit(1);
});