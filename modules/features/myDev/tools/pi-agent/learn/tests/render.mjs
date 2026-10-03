// Invoke the actual managed renderer tools and retain previews for inspection.
// Usage: node render.mjs <pi-package> <mmdc> <chromium> <rsvg-convert> <output-dir>
import assert from "node:assert/strict";
import { promises as fs } from "node:fs";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const [piPackage, mmdc, chromium, rsvg, output] = process.argv.slice(2);
if (!output) throw new Error("Supply Pi package, renderer executables, and a temporary output directory.");
Object.assign(process.env, { PI_LEARN_MMDC: mmdc, PI_LEARN_CHROMIUM: chromium, PI_LEARN_RSVG: rsvg });
const { loadExtensions } = await import(pathToFileURL(path.join(piPackage, "lib/node_modules/@earendil-works/pi-coding-agent/core/extensions/loader.js")).href);
const extensions = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../extensions/visual-tools/tools");
const loaded = await loadExtensions(["mermaid_tools.ts", "svg_tools.ts"].map((name) => path.join(extensions, name)), output);
assert.deepEqual(loaded.errors, []);
const tools = new Map(loaded.extensions.flatMap((e) => [...e.tools].map(([name, t]) => [name, t.definition])));
await fs.mkdir(output, { recursive: true });
await tools.get("write_mermaid").execute("m-write", { source: 'graph TD\n  A["Prior odds"] --> C["Posterior odds"]\n  B["Likelihood ratio"] --> C' });
await tools.get("write_svg").execute("s-write", { source: '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="200" viewBox="0 0 600 200"><rect width="600" height="200" fill="white"/><line x1="60" y1="100" x2="540" y2="100" stroke="#333" stroke-width="3"/><g font-family="sans-serif" font-size="22" text-anchor="middle"><path d="M60 90v20 M300 90v20 M540 90v20" stroke="#333" stroke-width="3"/><text x="60" y="145">0</text><text x="300" y="145">1/2</text><text x="540" y="145">1</text></g><circle cx="300" cy="100" r="7" fill="#3182ce"/></svg>' });
for (const [tool, file] of [["render_mermaid", "mermaid.png"], ["render_svg", "svg.png"]]) {
  const result = await tools.get(tool).execute("render", {});
  assert.equal(result.details.ok, true, JSON.stringify(result.content));
  assert.ok(result.content.some((item) => item.type === "image"));
  await fs.copyFile(result.details.path, path.join(output, file));
}
console.log(output);
