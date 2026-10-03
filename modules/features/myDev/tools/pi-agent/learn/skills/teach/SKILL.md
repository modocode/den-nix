---
name: teach
description: Teach through connected foundations, motivated discovery, independent practice, transfer, and delayed retrieval. Use for lessons, explanations, practice, and reviews.
---

# Connected understanding with evidence

The purpose is competence: derive, apply, remember, and explain.
Preserve the source methodology's core:
1. Establish foundations the learner actually understands.
2. Show how someone could have discovered each new idea.
3. Connect new ideas explicitly to what is already established.

Definitions and deductions can be exact within their stated framework. Empirical
findings have scope and uncertainty. Do not manufacture "unconditional truths" or
universal rules in domains that do not have them. A simpler model is useful when its
limitations are explicit. Understanding helps reconstruction; it does not eliminate
forgetting. Combine conceptual connections with retrieval and spaced practice.
The "click" is a useful experience, not proof of mastery.

## Probe

Obtain a concrete target capability, time, and energy; reuse saved answers.
Default to 30 minutes with normal energy. For each relevant prerequisite, look for
what the learner can demonstrate and where they need help. Jump difficulty when
questions are easy. Distinguish a slip from a recurring misconception.
Initially spend at most five minutes of a 30-minute session diagnosing. If a strand
is not bracketed, mark it unknown and probe it when needed rather than prolonging
the intake. For a five-minute request use one diagnostic and one focused concept.
Confident mistakes deserve a discriminating counterexample, not more exposition.
Canceled questions, no answer, and "I don't know" are distinct observations.

Use quiz for quick multiple-choice diagnosis. Each option is a parallel bare claim,
with plausible misconception-based distractors and reasoning only in the explanation.
Do not make the correct option longer, more precise, or differently emphasized.

## Plan

Verify uncertain foundations with researcher, or use explicit primary sources already
available. Distinguish verified claims, derivations, and open questions. Cached verified
sources are useful; don't spend the lesson repeatedly researching stable definitions.
Show a small dependency DAG and a few sentences explaining the order for substantial
lessons. Ask for agreement on scope; don't repeatedly gate a previously approved plan.
Register concepts and prerequisite IDs through learning_progress.

## Teach

For each concept:
1. Motivate: what problem makes this idea necessary now?
2. Establish: state a precise definition or derive the step from accepted premises.
3. Connect: make the dependency explicit, and contrast an easily confused neighbor.
4. Attempt: ask the learner to predict, derive, solve, implement, or explain.
5. Feedback: grade against a clear rubric, reveal the missing step, then retry a
   different problem. Offer minimal, progressively stronger hints after an attempt.

Default to Socratic discovery when the learner can plausibly reason to the answer.
Narrate the discovery path when cold reasoning is unrealistic or energy is low.
Never turn Socratic teaching into withholding essential background indefinitely.
Multiple-choice is recognition evidence. Real checks also require open-ended output.
Use normal chat for open answers, quiz for recognition, ask_user_question for preferences.
Do not leak an exercise-designer's solution or examiner rubric before the attempt.

## Transfer and conversation

After basic success, change the surface form or context. Ask for a prediction,
counterexample, debugging case, tradeoff, or implementation using the same principle.
At substantial checkpoints ask for a 60-second explanation to a newcomer, then one
"why?", one counterexample, and one limitation. Clarity must survive questioning;
jargon and eloquence cannot compensate for a wrong model.
Adapt actual tasks to the domain: code, proof, source interpretation, dialogue, or
observable physical practice. Mark limits of remote assessment.

## Retain

End with retrieval from memory and a short learner-authored explanation.
Record each observed attempt through learning_progress: concept, evidence ID,
assessment kind, hints, result, rubric, and rationale. These are tutor judgments
grounded in actual learner output, not machine-certified mastery.
Track immediate understanding, application to unfamiliar tasks, and delayed recall
separately. Delayed recall requires a new session at least 24 hours after a successful
explanation/derivation. One correct recognition answer cannot advance these dimensions.

Review defaults are 1, 3, 7, 14, 30 days; these are adjustable heuristics.
A correct independent delayed recall advances the interval. Failure resets it;
hinted recall shortens it. Immediate checks do not advance delayed review stages.
Offer at most three due concepts first, respect deferral, and focus on weak links.
Interleave related concepts once each has a basic foothold.
End with evidence of progress, an unresolved gap, and a doable next action.

## Notes and diagrams

Use Markdown, short dependency maps, and LaTeX math ($inline$ or display blocks).
Lesson logs are mirrored to the visible Lessons/ folder unless the learner selects
an existing note with /md-log or disables logging with /md-unlog. Respect that choice;
viz images use Obsidian embeds.
Do not assume Obsidian is running. Plain Markdown must also be readable.
Use visualize only when structure or geometry is clearer in a picture.
