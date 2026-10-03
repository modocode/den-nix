import { promises as fs } from "node:fs";
import path from "node:path";
import os from "node:os";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const piPackage = process.argv[2];
if (!piPackage) throw new Error("Usage: node tests/typecheck.mjs <installed-pi-package>");
const dependencies = path.join(piPackage, "lib/node_modules");
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const dir = await fs.mkdtemp(path.join(os.tmpdir(), "pi-learning-types-"));
try {
  const config = { compilerOptions: { target: "ES2022", module: "NodeNext", moduleResolution: "NodeNext",
    strict: true, noEmit: true, allowImportingTsExtensions: true, allowJs: true, checkJs: false, skipLibCheck: true,
    paths: {
      "@earendil-works/pi-coding-agent": [dependencies + "/@earendil-works/pi-coding-agent/index.d.ts"],
      "@earendil-works/pi-tui": [dependencies + "/@earendil-works/pi-tui/index.d.ts"],
      typebox: [dependencies + "/typebox/build/index.d.mts"],
    }, typeRoots: [dependencies + "/@types"] }, include: [root + "/extensions/**/*.ts"] };
  const file = path.join(dir, "tsconfig.json");
  await fs.writeFile(file, JSON.stringify(config));
  execFileSync(process.execPath, [dependencies + "/typescript/bin/tsc", "-p", file], { stdio: "inherit" });
  console.log("All learning extensions passed strict TypeScript checking against the locked Pi API.");
} finally { await fs.rm(dir, { recursive: true, force: true }); }
