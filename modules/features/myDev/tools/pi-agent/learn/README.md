# Pi learning harness

This adapts the original [learn methodology](https://github.com/amosblomqvist/learn):
connected foundations, motivated discovery, diagnostic quizzes, and verified visuals.
It adds bounded diagnostics, independent exercises, unfamiliar applications,
conversational examination, project records, and spaced retrieval.

## Start

The `pi` NixOS module installs ordinary `pi` and the dedicated `pi-learn` command.
The same file exports `packages.<system>.pi-learn` for standalone builds.
Authenticate/select a model using your normal Pi setup; no credentials or fixed model
are embedded in Nix. Helpers inherit the active tutor model at launch.

From a folder for one subject:

```sh
pi-learn
```

The launcher uses your current tmux session or opens a new one. Headless/help/version
invocations run directly. Pi arguments such as `--model`, `--continue`, and `--resume`
are forwarded. The executable extensions loaded by this command are explicit; your
ordinary Pi executable and personal settings are not overwritten.

Inside Pi:

- `/learn derive Bayes' rule and use it to interpret evidence` — start/update a goal.
- `/learn` — resume the saved project goal.
- `/review [focus]` — retrieve up to three due concepts before seeing answers.
- `/practice [focus]` — attempt an unfamiliar application.
- `/explain [focus]` — explain to a newcomer and defend your reasoning.
- `/progress` — show recorded evidence and due dates without a model call.
- `/md-log <existing-note.md>` / `/md-unlog` — manually change/stop lesson mirroring.

Tell the tutor your time/energy budget when needed. Defaults: 30 minutes, normal
energy, at most five minutes of initial diagnosis. Changes use
`learning_progress(action="preferences", minutes=..., energy="low|normal|high")`.
Review intervals can be changed through `intervals=[1,3,7,14,30]` (five positive,
strictly increasing day counts). New schedules use these values.

## What counts as progress

The tutor collects actual user messages and completed quiz responses as evidence.
It records a concept ID, evidence ID, assessment kind, hint count, result, rubric,
and rationale. Semantic grading is an AI judgment that you can challenge.
Missing/canceled answers are not graded. Multiple-choice evidence is diagnostic
only. Understanding, unfamiliar application, conversation, and delayed recall are
recorded separately; no aggregate "mastery score" masks missing evidence.

Delayed recall needs a new session at least 24 hours after an independent correct
explanation/derivation. Immediate success schedules the first one-day review.
Successful delayed retrieval advances through 3, 7, 14, 30 days. Hinted retrieval
shortens the stage; failure resets it. These intervals are adjustable defaults, not
a claim of a universally optimal schedule. Reviews are offered on return; there is
no background scheduler or notification service.

## Project files

- `.learn/state.json` — authoritative structured record; includes learner responses.
- `.learn/PROGRESS.md` — readable summary generated from the record.
- `.learn/lessons/<date>-<session>.md` — mirrored conversation and quiz feedback.
- `viz/` — published diagrams, compatible with Obsidian embeds.

Keep a separate project folder per subject; continuing a subject reuses its state.
A changed goal keeps prior evidence. Records are never stored in the Nix store.
Do not commit personal learning records unless you want to share their contents.
Obsidian is optional. Lessons use Markdown and LaTeX; diagrams use Obsidian embeds.

Writes serialize across processes with `.learn/.state.lock` and use atomic file
replacement. A malformed state raises an error and is preserved. Back up state.json
before manually editing or restoring it. If a process crashes during a write, verify
no Pi process is writing that project, then remove the empty lock directory with
`rmdir .learn/.state.lock`. The next successful update regenerates PROGRESS.md;
state.json remains authoritative if the mirror was interrupted.

## Specialists and tools

Researcher verifies sources; exercise-designer supplies private rubrics and transfer
tasks; examiner checks submitted evidence independently. Mermaid/SVG makers render,
inspect, and iterate. Helpers cannot spawn helpers or edit learning records. At most
two run concurrently. Rubric/examination helpers run in background tmux windows and their results are hidden from the teaching transcript until the tutor gives feedback. They remain accessible through deliberate tmux window switching; this is instructional separation, not access control. Delegation is selective so your session time goes into practice.

DuckDuckGo search is free and can be blocked. The research tools report that failure
explicitly; provide known URLs/local documents when needed. Direct fetching supports
public HTML/text, 20-second timeouts, 1 MiB input and 20,000 output characters.
It does not extract PDFs; provide locally extracted text for those.
Retrieved content is untrusted evidence, not executable instructions.

Nix supplies tmux, Node, Mermaid CLI, Chromium, and librsvg. No runtime npm install or
browser download is needed. Rendering uses declared executable paths. A maker must
look at the rendered image before publishing. With a text-only model, the tutor uses
a labeled textual diagram instead; it cannot claim visual inspection.

## Provenance and maintenance

`extensions/interactive-subagents/` vendors
[pi-interactive-subagents](https://github.com/amosblomqvist/pi-interactive-subagents)
at commit `c3e8b53c0754ae5ccc19fdab5a7481ec039bc2f7`, with its MIT license.
Local changes adapt the Pi namespace, discover only packaged learning agents, inherit
the active model, carry runtime credentials/renderer paths into panes, use the absolute raw Pi executable, disable child resource
discovery, cap concurrent helpers, and close child panes on parent shutdown.
The supplied quiz/question/log extensions are adapted to the locked
`@earendil-works/pi-coding-agent` API. The original learning directory's README
linked [How I Use AI to Learn Things](https://www.youtube.com/watch?v=kzcI5F4tGiU).

The learning additions use retrieval practice and spaced practice, informed by
[Dunlosky et al. (2013)](https://doi.org/10.1177/1529100612453266) and
[Karpicke & Blunt (2011)](https://doi.org/10.1126/science.1199327).
Concept maps help explain connections; they do not replace practicing retrieval.

Delayed review progression also requires that the review is due and that each review occurs in a fresh session. Use a fresh pi-learn session or /new when returning for review.

After updating Pi, run `node --test learn/tests/*.test.mjs` from this module,
build `nix build .#pi-learn` from the flake root, and smoke-test popups, helper
completion, and both visual renderers. The tests use temporary learning projects.
The tests/typecheck.mjs, tests/runtime.mjs, tests/tmux-runtime.mjs, and tests/render.mjs scripts document their arguments at the top; tmux testing uses a local fake model without paid API calls.
New Nix and harness files must be Git-tracked before a Git-backed flake sees them.
