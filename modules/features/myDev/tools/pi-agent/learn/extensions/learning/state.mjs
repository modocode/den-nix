import { promises as fs } from "node:fs";
import path from "node:path";
import { randomUUID } from "node:crypto";

export const DAY = 86400000;
export const DEFAULT_INTERVALS = [1, 3, 7, 14, 30];
const results = ["correct", "hinted", "incorrect", "dont-know"];
const kinds = ["diagnostic", "explanation", "derivation", "application", "recall", "conversation"];

export function emptyState() {
  return { version: 1, goal: "", preferences: { minutes: 30, energy: "normal", intervals: [...DEFAULT_INTERVALS] }, concepts: {}, evidence: {}, attempts: [] };
}
export function validateState(state) {
  if (!state || state.version !== 1 || typeof state.goal !== "string" ||
      !state.preferences || !Number.isFinite(state.preferences.minutes) || state.preferences.minutes < 1 ||
      !["low", "normal", "high"].includes(state.preferences.energy) ||
      !Array.isArray(state.preferences.intervals) || state.preferences.intervals.length !== 5 ||
      !state.preferences.intervals.every((n, i, a) => Number.isFinite(n) && n > 0 && (i === 0 || n > a[i - 1])) ||
      !state.concepts || Array.isArray(state.concepts) || typeof state.concepts !== "object" ||
      !state.evidence || Array.isArray(state.evidence) || typeof state.evidence !== "object" ||
      !Array.isArray(state.attempts)) {
    throw new Error("Invalid .learn/state.json. Preserve the file and restore a valid version; it was not overwritten.");
  }
  for (const c of Object.values(state.concepts)) {
    if (!c || typeof c.title !== "string" || !Array.isArray(c.prerequisites) ||
        !Array.isArray(c.misconceptions) || !Array.isArray(c.sources) ||
        !Number.isInteger(c.reviewStage) || c.reviewStage < 0 || c.reviewStage > 4 ||
        !(c.due === null || Number.isFinite(Date.parse(c.due))) ||
        !c.dimensions || !["understanding", "transfer", "retention", "conversation"].every((key) => typeof c.dimensions[key] === "boolean")) {
      throw new Error("Invalid concept in .learn/state.json; the file was not overwritten.");
    }
  }
  for (const e of Object.values(state.evidence)) {
    if (!e || !["user", "quiz"].includes(e.kind) || typeof e.text !== "string" ||
        typeof e.session !== "string" || !Number.isFinite(Date.parse(e.at))) throw new Error("Invalid learner evidence in state.json.");
  }
  for (const a of state.attempts) {
    if (!a || !Object.hasOwn(state.concepts, a.concept) || !Object.hasOwn(state.evidence, a.evidenceRef) ||
        !kinds.includes(a.kind) || !results.includes(a.result) || !Number.isFinite(Date.parse(a.at))) throw new Error("Invalid assessment in state.json.");
  }
  return state;
}
export async function readState(root) {
  try { return validateState(JSON.parse(await fs.readFile(path.join(root, ".learn/state.json"), "utf8"))); }
  catch (error) { if (error.code === "ENOENT") return emptyState(); throw error; }
}
/** @param {any} state @param {{id: string, title: string, prerequisites?: string[], misconceptions?: string[], sources?: string[]}} params */
export function upsertConcept(state, { id, title, prerequisites = [], misconceptions = [], sources = [] }) {
  if (!/^[a-z0-9][a-z0-9-]{0,79}$/.test(id)) throw new Error("Use a short lowercase kebab-case concept ID.");
  if (!title?.trim()) throw new Error("A concept needs a title.");
  if (prerequisites.some((p) => !Object.hasOwn(state.concepts, p) || p === id)) throw new Error("Register prerequisite concepts first; self-dependencies are invalid.");
  const old = Object.hasOwn(state.concepts, id) ? state.concepts[id] : undefined;
  state.concepts[id] = { title: title.trim(), prerequisites, misconceptions, sources,
    dimensions: old?.dimensions ?? { understanding: false, transfer: false, retention: false, conversation: false },
    reviewStage: old?.reviewStage ?? 0, due: old?.due ?? null };
  const visiting = new Set(), visited = new Set();
  const visit = (key) => {
    if (visiting.has(key)) throw new Error("Concept prerequisites must form an acyclic graph.");
    if (visited.has(key)) return;
    visiting.add(key);
    for (const dependency of state.concepts[key].prerequisites) visit(dependency);
    visiting.delete(key); visited.add(key);
  };
  for (const key of Object.keys(state.concepts)) visit(key);
}
export function recordAttempt(state, params, now = new Date()) {
  const { concept, evidenceRef, kind, result, hints, rubric, rationale } = params;
  const c = Object.hasOwn(state.concepts, concept) ? state.concepts[concept] : undefined;
  const evidence = Object.hasOwn(state.evidence, evidenceRef) ? state.evidence[evidenceRef] : undefined;
  if (!c) throw new Error("Register the concept first.");
  if (!evidence || !evidence.text?.trim()) throw new Error("Use an observed learner evidence ID returned by learning_progress.");
  if (!kinds.includes(kind) || !results.includes(result) || !Number.isInteger(hints) || hints < 0 ||
      !rubric?.trim() || !rationale?.trim()) throw new Error("Provide assessment kind, result, hint count, rubric, and rationale.");
  if (evidence.kind === "quiz" && kind !== "diagnostic") throw new Error("Multiple-choice evidence supports diagnostics only.");
  if (evidence.kind === "quiz" && result === "correct" && evidence.correct !== true) throw new Error("The observed quiz answer was not correct.");
  if (result === "correct" && hints > 0) throw new Error("An answer with hints must be recorded as hinted.");
  if (result === "hinted" && hints === 0) throw new Error("A hinted result needs a nonzero hint count.");
  if (state.attempts.some((a) => a.concept === concept && a.evidenceRef === evidenceRef && a.kind === kind)) throw new Error("This evidence was already assessed for this concept and kind.");
  const established = state.attempts.findLast((a) => a.concept === concept && ["explanation", "derivation"].includes(a.kind) && a.result === "correct");
  const lastReview = state.attempts.findLast((a) => a.concept === concept && a.kind === "recall");
  const delayed = kind === "recall" && established && evidence.session !== (lastReview?.session ?? established.session) &&
    Date.parse(evidence.at) - Date.parse(established.at) >= DAY;
  if (kind === "recall" && !delayed) throw new Error("Delayed recall needs a new session at least 24 hours after a successful explanation/derivation; record an immediate check as explanation instead.");
  if (kind === "recall" && c.due && Date.parse(evidence.at) < Date.parse(c.due)) throw new Error("This review is not due yet; use an immediate explanation check instead of advancing the review stage.");
  const attempt = { id: randomUUID(), at: now.toISOString(), session: evidence.session,
    concept, evidenceRef, kind, result, hints, rubric, rationale };
  state.attempts.push(attempt);
  const independent = result === "correct";
  if (["explanation", "derivation"].includes(kind)) {
    c.dimensions.understanding = independent;
    if (!independent) c.dimensions.retention = false;
  }
  if (kind === "application") c.dimensions.transfer = independent;
  if (kind === "conversation") c.dimensions.conversation = independent;
  if (delayed) {
    c.dimensions.retention = independent;
    c.reviewStage = independent ? Math.min(4, c.reviewStage + 1) : result === "hinted" ? Math.max(0, c.reviewStage - 1) : 0;
    c.due = new Date(now.getTime() + state.preferences.intervals[c.reviewStage] * DAY).toISOString();
  } else if (["explanation", "derivation"].includes(kind) && (c.due === null || !independent)) {
    c.reviewStage = 0;
    c.due = new Date(now.getTime() + state.preferences.intervals[0] * DAY).toISOString();
  }
  return attempt;
}
export function progressMarkdown(state, now = new Date()) {
  const clean = (s) => String(s).replace(/\|/g, "\\|").replace(/\n/g, " ");
  const rows = Object.entries(state.concepts).map(([id, c]) => {
    const dims = Object.entries(c.dimensions).filter(([, value]) => value).map(([key]) => key).join(", ") || "not demonstrated";
    return "| " + [clean(c.title), clean(id), clean(dims), c.due?.slice(0, 10) ?? "unscheduled"].join(" | ") + " |";
  });
  return [
    "# Learning progress", "", "Goal: " + state.goal, "",
    "Budget: " + state.preferences.minutes + " minutes; energy: " + state.preferences.energy + ".", "",
    "Generated from state.json at " + now.toISOString() + ". Assessments are tutor judgments backed by observed learner output.", "",
    "| Concept | ID | Demonstrated dimensions | Next review |", "| --- | --- | --- | --- |", ...rows, "",
    "## Recent assessments", "",
    ...state.attempts.slice(-10).map((a) => "- " + a.at.slice(0, 10) + " · " + a.concept + " · " + a.kind + ": " + a.result + " (" + a.hints + " hints), evidence " + a.evidenceRef + ". " + a.rationale), "",
  ].join("\n");
}
export async function updateState(root, mutate) {
  const dir = path.join(root, ".learn"), lock = path.join(dir, ".state.lock");
  await fs.mkdir(dir, { recursive: true });
  let acquired = false;
  for (let i = 0; i < 100; i++) {
    try { await fs.mkdir(lock); acquired = true; break; }
    catch (error) { if (error.code !== "EEXIST") throw error; await new Promise((r) => setTimeout(r, 50)); }
  }
  if (!acquired) throw new Error("Learning state is locked by another session. If its process crashed, remove .learn/.state.lock after confirming no writer remains.");
  const temp = path.join(dir, ".state-" + randomUUID() + ".tmp");
  const mirror = path.join(dir, ".progress-" + randomUUID() + ".tmp");
  try {
    const state = await readState(root);
    const result = await mutate(state);
    validateState(state);
    await fs.writeFile(temp, JSON.stringify(state, null, 2) + "\n", { mode: 0o600 });
    await fs.rename(temp, path.join(dir, "state.json"));
    await fs.writeFile(mirror, progressMarkdown(state));
    await fs.rename(mirror, path.join(dir, "PROGRESS.md"));
    return { state, result };
  } finally {
    await fs.unlink(temp).catch(() => {});
    await fs.unlink(mirror).catch(() => {});
    await fs.rmdir(lock);
  }
}
