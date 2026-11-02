---
name: multiagent
description: Use when the user says "multiagent", "orchestrate", "fan out", or asks to run work in parallel across several agents or models.
---

# multiagent

Split the task into independent units, run them in parallel on child agents,
and merge the results. You plan, dispatch, check, and report. The children do
the work.

## 1. Split

Break the request into units that can run at the same time: per service, per
package, per question, per review angle. Each unit needs its own definition of
done.

- Units that write the same files are not independent. Merge them into one
  unit, or run them in sequence.
- If the task has only one real unit, do not orchestrate. Do it, or hand it to
  one child.
- Default cap: 5 children. Go higher only when the user asks or the units are
  small and mechanical.

## 2. Pick models

Model choice is yours. In T3, call `orchestrator_capabilities` once per thread
and pick from what it lists. Use `search` to find a model that is not in the
short list. Skip providers with `canRunChildTask: false` or a constraint. Do
not hardcode model IDs in briefs or notes. Read them from the catalog each run.

Preferred models, used at your discretion:

- [specify models]

Match the model to the unit:

- Bulk mechanical edits, renames, codemods: a small, fast model at low effort.
- Scoped research and code search: a mid-tier model.
- Multi-step implementation and debugging: a strong model at high effort.
- Judgment, design, and review: the strongest model available. For review,
  prefer a different provider than the one that wrote the code.

Set reasoning effort through `target.options` with the option IDs the catalog
gives for that model. Use the highest efforts only for hard units. If the user
named a model or provider and it is not available, say so. Do not substitute.

## 3. Dispatch

Start every child in one message so they run at the same time. In T3, use
`delegate_task` for each:

- `mode: "async"`, a short `title`, and a fresh `clientRequestId`.
- `role`: `implementation`, `research`, `review`, `design`, `test`, or
  `general`.
- `isolation: "worktree"` for any child that edits files or runs mutating git.
  Read-only children use the shared checkout.
- `target.providerInstanceId`, `target.model`, and `target.options` from step 2.
- Save each `taskId`.

Children get no history. Each brief carries everything:

```
Goal: <what this unit delivers>
Repo: <abs path> Branch/base: <ref>
Context: <files, conventions, constraints the child needs>
Scope: <what to touch> Out of scope: <what not to touch>
Done when: <the check that proves it: command, test, output>
Do not commit, push, open PRs, or start subagents unless this brief says so.
Reply: what you changed or found, the proof you ran, open risks.
```

Outside T3, use the harness's native subagents (`Agent` in Claude Code,
`spawn_agent` in Codex), one per unit, all in one message. Use a worktree for
write-capable children. If the harness cannot run the model you picked, use
one it can run and say so in the report.

Do not use `Workflow`, `create_threads`, or `t3_thread_launch` unless the user
asks for them.

## 4. Wait

Wait for the completion notices. Do not poll with `task_status`, `sleep`, or
watchers while a child is running. Read each result with `task_status` after
its notice arrives.

If a child fails, times out, or goes off track, `task_cancel` it and start a
fresh one with a corrected brief. A timeout is not a result. Cancel any child
you no longer need.

## 5. Check and merge

Treat each child's report as a claim, not proof.

- Read the diff or findings yourself.
- Run the checks from each brief's "Done when" on the merged result, plus the
  repo's typecheck, lint, and tests.
- Resolve conflicts between children. When two children disagree, check the
  evidence and decide. Do not average the answers.
- Fix small gaps yourself. Send a fresh child only for a real unit of
  remaining work.

## 6. Report

One table: unit, model and effort, outcome, proof. Then the merged result,
the checks you ran with their output, the decisions you made, and the open
risks. Say which children failed or were cancelled, and why.
