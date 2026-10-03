import test from "node:test";
import assert from "node:assert/strict";
import { promises as fs } from "node:fs";
import os from "node:os";
import path from "node:path";
import { emptyState, upsertConcept, recordAttempt, readState, updateState, DAY } from "../extensions/learning/state.mjs";

function fixture() {
  const s = emptyState(); s.goal = "Derive and apply a principle";
  upsertConcept(s, { id: "principle", title: "Principle" });
  return s;
}
function evidence(s, id, at, session = "one", kind = "user", correct = true) {
  s.evidence[id] = { text: "A real learner explanation", at: new Date(at).toISOString(), session, kind, correct };
}
const assessment = (ref, kind = "explanation", result = "correct", hints = 0) =>
  ({ concept: "principle", evidenceRef: ref, kind, result, hints, rubric: "Derive from the stated premises", rationale: "The supplied response explicitly derived the step." });

test("recognition never establishes understanding or retention", () => {
  const s = fixture(); evidence(s, "q", 0, "one", "quiz");
  recordAttempt(s, assessment("q", "diagnostic"), new Date(0));
  assert.equal(s.concepts.principle.dimensions.understanding, false);
  assert.throws(() => recordAttempt(s, assessment("q")), /diagnostics only/);
});
test("invented, repeated, and misgraded evidence is rejected", () => {
  const s = fixture();
  assert.throws(() => recordAttempt(s, assessment("invented")), /observed/);
  evidence(s, "q", 0, "one", "quiz", false);
  assert.throws(() => recordAttempt(s, assessment("q", "diagnostic")), /not correct/);
  evidence(s, "a", 0);
  recordAttempt(s, assessment("a"), new Date(0));
  assert.throws(() => recordAttempt(s, assessment("a")), /already assessed/);
});
test("hinted answers cannot be recorded as independent success", () => {
  const s = fixture(); evidence(s, "a", 0);
  assert.throws(() => recordAttempt(s, assessment("a", "explanation", "correct", 1)), /must be recorded as hinted/);
  recordAttempt(s, assessment("a", "explanation", "hinted", 1), new Date(0));
  assert.equal(s.concepts.principle.dimensions.understanding, false);
});
test("retention requires a new session and a real delay", () => {
  const s = fixture(); evidence(s, "first", 0);
  recordAttempt(s, assessment("first"), new Date(0));
  evidence(s, "same", 2 * DAY);
  assert.throws(() => recordAttempt(s, assessment("same", "recall"), new Date(2 * DAY)), /new session/);
  evidence(s, "early", DAY - 1, "two");
  assert.throws(() => recordAttempt(s, assessment("early", "recall"), new Date(DAY - 1)), /24 hours/);
  evidence(s, "later", DAY, "two");
  recordAttempt(s, assessment("later", "recall"), new Date(DAY));
  assert.equal(s.concepts.principle.dimensions.retention, true);
  assert.equal(s.concepts.principle.due, new Date(4 * DAY).toISOString());
  assert.equal(s.concepts.principle.dimensions.transfer, false);
  evidence(s, "too-soon", 2 * DAY, "three");
  assert.throws(() => recordAttempt(s, assessment("too-soon", "recall"), new Date(2 * DAY)), /not due yet/);
  evidence(s, "same-review-session", 4 * DAY, "two");
  assert.throws(() => recordAttempt(s, assessment("same-review-session", "recall"), new Date(4 * DAY)), /new session/);
});
test("hinted retrieval shortens intervals and failure resets them", () => {
  const s = fixture(); evidence(s, "first", 0);
  recordAttempt(s, assessment("first"), new Date(0));
  for (let i = 1; i <= 2; i++) {
    evidence(s, "later" + i, [0, 1, 4][i] * DAY, "session" + i);
    recordAttempt(s, assessment("later" + i, "recall"), new Date([0, 1, 4][i] * DAY));
  }
  assert.equal(s.concepts.principle.reviewStage, 2);
  evidence(s, "hint", 11 * DAY, "four");
  recordAttempt(s, assessment("hint", "recall", "hinted", 1), new Date(11 * DAY));
  assert.equal(s.concepts.principle.reviewStage, 1);
  evidence(s, "fail", 14 * DAY, "five");
  recordAttempt(s, assessment("fail", "recall", "incorrect"), new Date(14 * DAY));
  assert.equal(s.concepts.principle.reviewStage, 0);
  assert.equal(s.concepts.principle.dimensions.retention, false);
});
test("concept dependencies reject missing nodes and cycles", () => {
  const s = fixture();
  assert.throws(() => upsertConcept(s, { id: "other", title: "Other", prerequisites: ["missing"] }), /prerequisite/);
  upsertConcept(s, { id: "other", title: "Other", prerequisites: ["principle"] });
  assert.throws(() => upsertConcept(s, { id: "principle", title: "Principle", prerequisites: ["other"] }), /acyclic/);
});
test("concurrent writes preserve attempts and resume readable records", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "pi-learn-state-"));
  try {
    await updateState(root, (s) => { s.goal = "Test"; upsertConcept(s, { id: "principle", title: "Principle" }); });
    await Promise.all(Array.from({ length: 8 }, (_, i) => updateState(root, (s) => {
      evidence(s, "real" + i, i);
      recordAttempt(s, assessment("real" + i, "application"), new Date(i));
    })));
    assert.equal((await readState(root)).attempts.length, 8);
    assert.match(await fs.readFile(path.join(root, ".learn/PROGRESS.md"), "utf8"), /transfer/);
  } finally { await fs.rm(root, { recursive: true, force: true }); }
});
test("malformed state is preserved, not silently reset", async () => {
  const root = await fs.mkdtemp(path.join(os.tmpdir(), "pi-learn-bad-"));
  try {
    await fs.mkdir(path.join(root, ".learn"));
    const target = path.join(root, ".learn/state.json");
    await fs.writeFile(target, '{"version":99}');
    await assert.rejects(() => updateState(root, (s) => { s.goal = "overwrite"; }), /Invalid/);
    assert.equal(await fs.readFile(target, "utf8"), '{"version":99}');
    await assert.rejects(() => fs.stat(path.join(root, ".learn/.state.lock")), /ENOENT/);
  } finally { await fs.rm(root, { recursive: true, force: true }); }
});
