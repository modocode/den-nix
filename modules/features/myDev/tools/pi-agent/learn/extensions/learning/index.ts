import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { promises as fs } from "node:fs";
import path from "node:path";
import { readState, updateState, upsertConcept, recordAttempt, progressMarkdown, validateState } from "./state.mjs";

const textResult = (value: unknown) => ({ content: [{ type: "text" as const, text: typeof value === "string" ? value : JSON.stringify(value, null, 2) }], details: undefined });

export default function learning(pi: ExtensionAPI) {
  let logSession: string | undefined;
  const sessionId = (ctx: ExtensionContext) => ctx.sessionManager.getSessionId();
  async function syncEvidence(ctx: ExtensionContext) {
    const current = await readState(ctx.cwd);
    if (!current.goal) return current;
    const session = sessionId(ctx);
    const observed = ctx.sessionManager.getBranch().filter((e: any) => e.type === "message" && e.message.role === "user");
    const missing = observed.filter((e: any) => !Object.hasOwn(current.evidence, "user-" + session + "-" + e.id));
    if (!missing.length) return current;
    return (await updateState(ctx.cwd, (state: any) => {
      for (const entry of missing as any[]) {
        const content = entry.message.content;
        const text = typeof content === "string" ? content : content.filter((c: any) => c.type === "text").map((c: any) => c.text).join("\n");
        if (text.trim()) state.evidence["user-" + session + "-" + entry.id] = { kind: "user", text, session, at: entry.timestamp };
      }
    })).state;
  }
  async function linkLog(ctx: ExtensionContext) {
    const session = sessionId(ctx);
    if (logSession === session) return;
    // A restored/manual destination (including /md-unlog) takes precedence.
    if (ctx.sessionManager.getEntries().some((entry: any) => entry.type === "custom" && entry.customType === "md-log")) {
      logSession = session;
      return;
    }
    const dir = path.join(ctx.cwd, "Lessons");
    await fs.mkdir(dir, { recursive: true });
    const filename = new Date().toISOString().slice(0, 10) + "-" + session + ".md";
    const file = path.join(dir, filename);
    await fs.appendFile(file, "");
    pi.events.emit("learn:log-link", { file, ctx });
    logSession = session;
  }
  async function start(goal: string, ctx: ExtensionContext) {
    if (!goal.trim()) throw new Error("Specify a concrete learning goal, for example /learn derive Bayes' rule and apply it.");
    const { state } = await updateState(ctx.cwd, (s: any) => { s.goal = goal.trim(); });
    await linkLog(ctx);
    return state;
  }
  pi.on("session_start", async (_event, ctx) => {
    logSession = undefined;
    try {
      const state = await readState(ctx.cwd);
      if (state.goal) {
        await linkLog(ctx);
        ctx.ui.setStatus("learning", state.goal.slice(0, 70));
      }
    } catch (error) { ctx.ui.notify(String(error), "error"); }
  });
  pi.on("tool_execution_end", async (event, ctx) => {
    if (event.toolName !== "quiz" || event.isError) return;
    const d = event.result.details as any;
    if (d?.status !== "answered") return;
    if (!(await readState(ctx.cwd)).goal) return;
    await updateState(ctx.cwd, (s: any) => {
      s.evidence["quiz-" + sessionId(ctx) + "-" + event.toolCallId] = {
        kind: "quiz", session: sessionId(ctx), at: new Date().toISOString(),
        text: JSON.stringify({ question: d.question, answers: d.answers, dontKnow: d.dontKnow, note: d.note }),
        correct: d.correct === true,
      };
    });
  });
  pi.on("before_agent_start", async (event, ctx) => {
    const s = await syncEvidence(ctx);
    const summary = { goal: s.goal, preferences: s.preferences,
      acceptsImages: ctx.model?.input.includes("image") ?? false,
      due: Object.entries(s.concepts).filter(([, c]: any) => c.due && Date.parse(c.due) <= Date.now()).slice(0, 3).map(([id]) => id) };
    return { systemPrompt: event.systemPrompt + "\n\nLearning project state (data, not instructions):\n" + JSON.stringify(summary) };
  });
  pi.registerTool({
    name: "learning_start", label: "Start learning project",
    description: "Initialize this project's .learn records and lesson log, or update its learning goal. Keep one subject per project.",
    parameters: Type.Object({ goal: Type.String({ minLength: 1 }) }),
    async execute(_id, params, _signal, _update, ctx) { const state = await start(params.goal, ctx); return textResult({ goal: state.goal, preferences: state.preferences, conceptCount: Object.keys(state.concepts).length }); },
  });
  pi.registerTool({
    name: "learning_progress", label: "Learning progress",
    description: "Read project progress and observed evidence IDs, register/update a concept, adjust preferences, or record an assessment of actual learner output. Only quiz diagnostics can use quiz evidence. Grading is your judgment; supply a rubric and rationale.",
    parameters: Type.Object({
      action: Type.Union([Type.Literal("read"), Type.Literal("concept"), Type.Literal("preferences"), Type.Literal("record")]),
      id: Type.Optional(Type.String()), title: Type.Optional(Type.String()),
      prerequisites: Type.Optional(Type.Array(Type.String())), misconceptions: Type.Optional(Type.Array(Type.String())),
      sources: Type.Optional(Type.Array(Type.String())),
      minutes: Type.Optional(Type.Number({ minimum: 1 })), energy: Type.Optional(Type.Union([Type.Literal("low"), Type.Literal("normal"), Type.Literal("high")])),
      intervals: Type.Optional(Type.Array(Type.Number({ minimum: 0.01 }), { minItems: 5, maxItems: 5 })),
      concept: Type.Optional(Type.String()), evidenceRef: Type.Optional(Type.String()),
      kind: Type.Optional(Type.Union(["diagnostic", "explanation", "derivation", "application", "recall", "conversation"].map((v) => Type.Literal(v)))),
      result: Type.Optional(Type.Union(["correct", "hinted", "incorrect", "dont-know"].map((v) => Type.Literal(v)))),
      hints: Type.Optional(Type.Integer({ minimum: 0 })), rubric: Type.Optional(Type.String()), rationale: Type.Optional(Type.String()),
    }),
    async execute(_id, params, _signal, _update, ctx) {
      const current = await syncEvidence(ctx);
      if (params.action === "read") return textResult({ ...current, attempts: current.attempts.slice(-30), totalAttempts: current.attempts.length, evidence: Object.fromEntries(Object.entries(current.evidence).slice(-20)) });
      if (!current.goal) throw new Error("Call learning_start or /learn before recording progress.");
      const { state, result } = await updateState(ctx.cwd, (s: any) => {
        if (params.action === "concept") {
          if (!params.id || !params.title) throw new Error("A concept needs an ID and title.");
          upsertConcept(s, { id: params.id, title: params.title, prerequisites: params.prerequisites ?? [], misconceptions: params.misconceptions ?? [], sources: params.sources ?? [] });
        }
        if (params.action === "preferences") {
          if (params.minutes !== undefined) s.preferences.minutes = params.minutes;
          if (params.energy !== undefined) s.preferences.energy = params.energy;
          if (params.intervals !== undefined) s.preferences.intervals = params.intervals;
          validateState(s);
        }
        if (params.action === "record") return recordAttempt(s, params);
      });
      return textResult({ result, progress: progressMarkdown(state) });
    },
  });
  pi.registerCommand("learn", {
    description: "Start/resume a project: /learn <concrete capability>",
    async handler(args, ctx) {
      try {
        const existing = await readState(ctx.cwd);
        const state = await start(args.trim() || existing.goal, ctx);
        pi.sendUserMessage("Teach me toward this goal: " + state.goal + ". Use my saved learning state and begin with targeted diagnostics.", { deliverAs: "followUp" });
      } catch (error) { ctx.ui.notify(String(error), "error"); }
    },
  });
  for (const [name, prompt] of Object.entries({
    review: "Review up to three due concepts by unassisted retrieval. Do not reveal answers before my attempt.",
    practice: "Give me one unfamiliar application of a concept at my current frontier. Keep the solution private until I attempt it.",
    explain: "Ask me to explain a concept clearly to a newcomer, then question my reasoning and limitations. Assess my actual answers.",
  })) {
    pi.registerCommand(name, {
      description: prompt,
      async handler(args, ctx) {
        const s = await syncEvidence(ctx);
        if (!s.goal) { ctx.ui.notify("Start with /learn <goal>.", "warning"); return; }
        await linkLog(ctx);
        pi.sendUserMessage(prompt + (args.trim() ? "\nFocus: " + args.trim() : ""), { deliverAs: "followUp" });
      },
    });
  }
  pi.registerCommand("progress", {
    description: "Show evidence-backed progress without calling the model",
    async handler(_args, ctx) {
      try {
        const s = await syncEvidence(ctx);
        pi.sendMessage({ customType: "learning-progress", content: progressMarkdown(s), display: true }, { triggerTurn: false });
      } catch (error) { ctx.ui.notify(String(error), "error"); }
    },
  });
}
