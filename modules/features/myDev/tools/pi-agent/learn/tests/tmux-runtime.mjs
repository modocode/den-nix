// End-to-end helpers in an isolated tmux server and a local fake model.
// No external model calls or personal credentials. Supply Pi package and tmux bin.
import assert from "node:assert/strict";
import { promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";
import http from "node:http";
import { execFileSync } from "node:child_process";
import { fileURLToPath, pathToFileURL } from "node:url";
const script = fileURLToPath(import.meta.url);
const [piPackage, tmuxBin, workerDir] = process.argv.slice(2);
const shell = (s) => "'" + s.replaceAll("'", "'\\''") + "'";
if (!piPackage || !tmuxBin) throw new Error("Usage: node tmux-runtime.mjs <pi-package> <tmux-bin>");
if (!workerDir) {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), "pi-learning-tmux-"));
  const socket = "pi-learning-" + process.pid;
  try {
    execFileSync(tmuxBin, ["-L", socket, "-f", "/dev/null", "new-session", "-d", "-x", "180", "-y", "50", "-s", "test", "-c", dir,
      [process.execPath, script, piPackage, tmuxBin, dir].map(shell).join(" ")], { env: { ...process.env, SHELL: "/run/current-system/sw/bin/bash" } });
    const until = Date.now() + 60000;
    let result;
    while (Date.now() < until) {
      try { result = JSON.parse(await fs.readFile(path.join(dir, "result.json"), "utf8")); break; }
      catch (error) { if (error.code !== "ENOENT") throw error; }
      await new Promise((r) => setTimeout(r, 250));
    }
    assert.ok(result, "tmux smoke test timed out");
    assert.equal(result.ok, true, result.error);
    console.log(result.message);
  } finally {
    try { execFileSync(tmuxBin, ["-L", socket, "kill-server"], { stdio: "ignore" }); } catch {}
    await fs.rm(dir, { recursive: true, force: true });
  }
} else {
  process.env.PATH = path.dirname(tmuxBin) + ":" + process.env.PATH;
  process.env.PI_LEARN_AGENTS_DIR = path.resolve(path.dirname(script), "../agents");
  process.env.PI_LEARN_PI_BIN = path.join(piPackage, "bin/pi");
  process.env.PI_CODING_AGENT_DIR = path.join(workerDir, "agent");
  process.env.LEARN_SMOKE_API_KEY = "local-test";
  const requests = [], delivered = [], authorization = [];
  let loaded;
  const server = http.createServer(async (request, response) => {
    const chunks = [];
    for await (const chunk of request) chunks.push(chunk);
    requests.push(JSON.parse(Buffer.concat(chunks).toString()));
    authorization.push(request.headers.authorization);
    await new Promise((r) => setTimeout(r, 4000));
    response.writeHead(200, { "content-type": "text/event-stream" });
    const base = { id: "chatcmpl-smoke", object: "chat.completion.chunk", created: Math.floor(Date.now()/1000), model: "smoke" };
    response.write("data: " + JSON.stringify({ ...base, choices: [{ index: 0, delta: { role: "assistant", content: "SMOKE_HELPER_RESULT: verified local execution." }, finish_reason: null }] }) + "\n\n");
    response.write("data: " + JSON.stringify({ ...base, choices: [{ index: 0, delta: {}, finish_reason: "stop" }], usage: { prompt_tokens: 100, completion_tokens: 10, total_tokens: 110 } }) + "\n\n");
    response.end("data: [DONE]\n\n");
  });
  const ctx = {
    cwd: workerDir, model: { provider: "learn-smoke", id: "smoke", input: ["text"] },
    ui: { setWidget: () => {}, notify: () => {} },
    sessionManager: { getSessionFile: () => path.join(workerDir, "parent.jsonl"), getSessionId: () => "parent", getSessionDir: () => workerDir },
  };
  try {
    await new Promise((r) => server.listen(0, "127.0.0.1", r));
    await fs.mkdir(process.env.PI_CODING_AGENT_DIR);
    await fs.writeFile(path.join(workerDir, "parent.jsonl"), JSON.stringify({ type: "session", id: "parent", version: 3, cwd: workerDir, timestamp: new Date().toISOString() }) + "\n");
    await fs.writeFile(path.join(process.env.PI_CODING_AGENT_DIR, "models.json"), JSON.stringify({
      providers: { "learn-smoke": { api: "openai-completions", baseUrl: "http://127.0.0.1:" + server.address().port + "/v1", apiKey: "$LEARN_SMOKE_API_KEY",
        models: [{ id: "smoke", name: "Local smoke model", reasoning: false, input: ["text"],
          cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 }, contextWindow: 32768, maxTokens: 1024 }] } },
    }));
    const sdkRoot = path.join(piPackage, "lib/node_modules/@earendil-works/pi-coding-agent");
    const { loadExtensions } = await import(pathToFileURL(path.join(sdkRoot, "core/extensions/loader.js")).href);
    loaded = await loadExtensions([path.resolve(path.dirname(script), "../extensions/interactive-subagents/index.ts")], workerDir);
    assert.deepEqual(loaded.errors, []);
    loaded.runtime.sendMessage = (message) => { if (message.customType === "subagent_result") delivered.push(message); };
    const extension = loaded.extensions[0];
    const spawn = extension.tools.get("subagent").definition;
    await assert.rejects(() => spawn.execute("no-model", { agent: "examiner", task: "Check evidence" }, undefined, undefined, { ...ctx, model: undefined }), /Select an authenticated/);
    await assert.rejects(() => spawn.execute("no-vision", { agent: "svg-maker", task: "Draw a line" }, undefined, undefined, ctx), /cannot inspect images/);
    const first = await spawn.execute("one", { agent: "exercise-designer", task: "Reply with the smoke marker. Do not call tools." }, undefined, undefined, ctx);
    const second = await spawn.execute("two", { agent: "examiner", task: "Reply with the smoke marker. Do not call tools." }, undefined, undefined, ctx);
    await assert.rejects(() => spawn.execute("three", { agent: "researcher", task: "Third task" }, undefined, undefined, ctx), /Two learning helpers/);
    const until = Date.now() + 40000;
    while (delivered.length < 2 && Date.now() < until) await new Promise((r) => setTimeout(r, 250));
    assert.equal(delivered.length, 2, JSON.stringify(delivered));
    for (const message of delivered) {
      assert.equal(message.details.exitCode, 0, message.content);
      assert.match(message.content, /SMOKE_HELPER_RESULT/);
      assert.equal(message.display, false, "private solutions must not be displayed in the teaching transcript");
      const snapshot = JSON.parse(await fs.readFile(message.details.sessionFile + ".loadout.json", "utf8"));
      assert.equal(snapshot.model, "learn-smoke/smoke");
      assert.equal(snapshot.toolAllowlist, "read,ask_question");
      assert.equal(snapshot.spawnable, null);
    }
    assert.equal(requests.length, 2);
    assert.ok(authorization.every((value) => value === "Bearer local-test"), "runtime credentials must reach child panes");
    assert.ok(requests.every((r) => r.model === "smoke"));
    assert.ok(first.details && second.details);
    await assert.rejects(() => fs.stat(path.join(workerDir, ".learn/state.json")), /ENOENT/);
    await fs.writeFile(path.join(workerDir, "result.json"), JSON.stringify({ ok: true,
      message: "Real tmux helpers: active model inheritance, two-helper cap, read-only loadouts, local model execution, automatic completion and result delivery passed." }));
  } catch (error) {
    await fs.writeFile(path.join(workerDir, "result.json"), JSON.stringify({ ok: false, error: error.stack }));
  } finally {
    if (loaded) for (const e of loaded.extensions) for (const handler of e.handlers.get("session_shutdown") ?? []) await handler({}, ctx);
    await new Promise((r) => server.close(r));
  }
}
