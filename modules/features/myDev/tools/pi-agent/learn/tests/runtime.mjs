// Smoke-test through the real locked Pi extension loader, without a model call.
// Usage: node tests/runtime.mjs /nix/store/...-pi-coding-agent-0.99.2 [resource-dir]
import assert from "node:assert/strict";
import { promises as fs } from "node:fs";
import path from "node:path";
import os from "node:os";
import { fileURLToPath, pathToFileURL } from "node:url";

const packageRoot = process.argv[2];
if (!packageRoot) throw new Error("Supply the installed Pi package path.");
const agentRoot = path.join(packageRoot, "lib/node_modules/@earendil-works/pi-coding-agent");
const { loadExtensions } = await import(pathToFileURL(path.join(agentRoot, "core/extensions/loader.js")).href);
const resources = process.argv[3] ?? path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
process.env.PI_LEARN_AGENTS_DIR = path.join(resources, "agents");
process.env.PI_LEARN_PI_BIN = path.join(packageRoot, "bin/pi");
const project = await fs.mkdtemp(path.join(os.tmpdir(), "pi-learn-runtime-"));
const branch = [];
const notifications = [], messages = [];
const ctx = {
  cwd: project, hasUI: false, model: { provider: "test", id: "fake", input: ["text"] },
  isIdle: () => true,
  ui: { notify: (text, level) => notifications.push({ text, level }), setStatus: () => {}, setWidget: () => {}, theme: { fg: (_style, text) => text } },
  sessionManager: { getSessionId: () => "smoke-session", getSessionFile: () => path.join(project, "session.jsonl"), getSessionDir: () => project,
    getBranch: () => branch, getEntries: () => branch },
};
let loaded;
try {
  loaded = await loadExtensions([
    "interactive-subagents/index.ts", "ask-user-question.ts", "quiz.ts", "md-log.ts",
    "research/index.ts", "visual-tools/index.ts", "learning/index.ts",
  ].map((file) => path.join(resources, "extensions", file)), project);
  assert.deepEqual(loaded.errors, []);
  Object.assign(loaded.runtime, {
    appendEntry: (customType, data) => branch.push({ type: "custom", customType, data }),
    sendMessage: (message) => messages.push(message), sendUserMessage: (message) => messages.push(message),
    getAllTools: () => [], getThinkingLevel: () => "off",
  });
  const tools = new Map(loaded.extensions.flatMap((e) => [...e.tools].map(([name, tool]) => [name, tool.definition])));
  const commands = new Map(loaded.extensions.flatMap((e) => [...e.commands]));
  async function emit(type, event = {}) {
    for (const extension of loaded.extensions) for (const handler of extension.handlers.get(type) ?? []) await handler({ type, ...event }, ctx);
  }
  await emit("session_start");
  for (const command of ["learn", "review", "practice", "explain", "progress"]) assert.ok(commands.has(command));
  for (const tool of ["quiz", "ask_user_question", "web_search", "web_fetch", "learning_start", "learning_progress", "subagent"]) assert.ok(tools.has(tool));
  const agents = await tools.get("subagents_list").execute("list", {}, undefined, undefined, ctx);
  const listing = JSON.stringify(agents);
  for (const name of ["researcher", "exercise-designer", "examiner", "mermaid-maker", "svg-maker"]) assert.ok(listing.includes(name), name);
  const cancel = new AbortController(); cancel.abort();
  for (const name of ["ask_user_question", "quiz"]) {
    const params = name === "quiz" ? { question: "Which?", options: [{ label: "A", value: "a" }, { label: "B", value: "b" }], correctAnswer: "a", explanation: "A is correct." } : { question: "Which goal?" };
    const result = await tools.get(name).execute("canceled", params, cancel.signal, undefined, ctx);
    assert.equal(result.details.status, "cancelled");
  }
  let activePopups = 0, maxPopups = 0;
  const uiCtx = { ...ctx, hasUI: true, ui: { ...ctx.ui,
    custom: async (factory) => new Promise((resolve) => {
      activePopups++; maxPopups = Math.max(maxPopups, activePopups);
      const component = factory({ requestRender: () => {} }, ctx.ui.theme, {}, (value) => { activePopups--; resolve(value); });
      setTimeout(() => { component.handleInput("\r"); component.handleInput("\r"); }, 15);
    }),
  } };
  const [quizResult, questionResult] = await Promise.all([
    tools.get("quiz").execute("quiz-ui", { question: "Choose A", options: [{ label: "A", value: "a" }, { label: "B", value: "b" }], correctAnswer: "a", explanation: "A is correct.", shuffle: false }, undefined, undefined, uiCtx),
    tools.get("ask_user_question").execute("question-ui", { question: "Choose a goal", options: [{ label: "Theory", value: "theory" }, { label: "Practice", value: "practice" }] }, undefined, undefined, uiCtx),
  ]);
  assert.equal(maxPopups, 1, "shared popup lock serializes both extensions");
  assert.equal(quizResult.details.correct, true);
  assert.equal(questionResult.details.status, "answered");
  await tools.get("learning_start").execute("start", { goal: "Understand and apply Bayes' rule" }, undefined, undefined, ctx);
  branch.push({ type: "message", id: "real", timestamp: new Date().toISOString(), message: { role: "user", content: [{ type: "text", text: "Posterior odds equal prior odds times the likelihood ratio." }] } });
  const progress = tools.get("learning_progress");
  await progress.execute("concept", { action: "concept", id: "bayes", title: "Bayes' rule" }, undefined, undefined, ctx);
  const read = JSON.parse((await progress.execute("read", { action: "read" }, undefined, undefined, ctx)).content[0].text);
  const evidenceRef = Object.keys(read.evidence)[0];
  await progress.execute("record", { action: "record", concept: "bayes", evidenceRef, kind: "explanation", result: "correct", hints: 0,
    rubric: "Relate prior, likelihood, and posterior odds.", rationale: "The actual learner stated the odds relation correctly." }, undefined, undefined, ctx);
  await commands.get("progress").handler("", ctx);
  assert.ok(messages.some((m) => typeof m === "object" && m.customType === "learning-progress"));
  assert.equal((await fs.readdir(path.join(project, ".learn/lessons"))).length, 1);
  assert.ok(!notifications.some((n) => n.level === "error"), JSON.stringify(notifications));
  await emit("session_start");
  const resumed = JSON.parse((await progress.execute("read", { action: "read" }, undefined, undefined, ctx)).content[0].text);
  assert.equal(resumed.attempts.length, 1);
  console.log("Locked Pi loader: seven extensions, five commands, specialist discovery, canceled UI, evidence capture, assessment, logging, and resume passed.");
} finally {
  if (loaded) for (const e of loaded.extensions) for (const handler of e.handlers.get("session_shutdown") ?? []) await handler({ type: "session_shutdown" }, ctx);
  await fs.rm(project, { recursive: true, force: true });
}
