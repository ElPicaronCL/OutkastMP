// OpenCode entrypoint for the vendored opencode-cline-mode plugin.
//
// The upstream package ships TypeScript sources (`src/`) and is built into
// `dist/` with `npm run build`. OpenCode's local plugin loader looks for
// `index.js` (or `index.ts`) directly in the plugin directory, so this thin
// re-export bridges that expectation to the compiled output.
//
// Rebuild after changing `src/`:
//   cd .opencode/plugins/opencode-cline-mode && npm run build
export { default } from "./dist/index.js"
