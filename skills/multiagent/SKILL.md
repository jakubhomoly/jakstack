---
name: multiagent
description: Use when the user says "multiagent", "orchestrate", "fan out", or asks to run work in parallel across several agents or models.
---

# multiagent

Get work done faster by using both subscriptions at once. Split the task,
run the parts in parallel on Claude and Codex agents, then check and merge
the results.

## 1. Split

Break the request into parts that can run at the same time: per service, per
package, per question, per review angle. Each part needs a clear "done when".

- Parts that edit the same files are one part. Merge them, or run them in
  order.
- If there is only one real part, skip this skill and do the work.
- Up to 5 agents by default. More only when the user asks.

## 2. Pick models

Model choice is yours. In T3, call `orchestrator_capabilities` once and pick
from what it lists. Read model IDs from it each run; do not hardcode them.

Preferred models, used at your discretion:

- [specify models]

Spread the work across both providers so neither subscription sits idle.
Match the model to the part:

- Mechanical edits: a small, fast model at low effort.
- Research and code search: a mid-tier model.
- Implementation and debugging: a strong model at high effort.
- Design and review: the strongest model. Review on the other provider from
  the one that wrote the code.

If the user named a model that is not available, say so. Do not substitute.

## 3. Start

Start every agent in one message so they run in parallel. In T3, call
`delegate_task` for each, with `mode: "async"`, a `title`, a `role`, and the
`target` from step 2. Use `isolation: "worktree"` for agents that edit files.
Save each `taskId`.

Each brief must stand alone:

```
Goal: <what this part delivers>
Repo: <abs path> Base: <ref>
Context: <files, conventions, constraints>
Scope: <what to touch> Out of scope: <what not to touch>
Done when: <command, test, or output that proves it>
Do not commit, push, or open PRs unless this brief says so.
Reply: what you changed or found, the proof you ran, open risks.
```

## 4. Wait

Wait for the completion notices. Do not poll. Read each result with
`task_status` once it arrives. If an agent fails or goes off track,
`task_cancel` it and start a new one with a better brief.

## 5. Check and merge

An agent's report is a claim, not proof.

- Read the diffs and findings yourself.
- Run each "done when" check and the repo's checks on the merged result.
- When agents disagree, check the evidence and decide.
- Fix small gaps yourself.

## 6. Report

A table of part, model, outcome, and proof. Then the checks you ran with
their output, your decisions, and open risks.
