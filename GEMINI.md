# ARCLE Development Workflow Rules — Gemini

## Mission

Develop ARCLE as a reliable, maintainable developer tool. Prioritize correctness, maintainability, efficient context usage, traceability, and minimal process overhead. These rules apply to all future ARCLE development, regardless of version.

## 1. Start Every Task by Establishing Context

Before modifying anything:

1. Read this file, other applicable repository instructions, and any relevant agent-specific configuration.
2. Inspect `git status --short --branch` and the current diff. Preserve all pre-existing user changes.
3. Identify the task size: **Small**, **Normal**, **Complex**, or **Cross-repo**.
4. Read the latest relevant entries in the existing history file. Search older entries only when they contain decisions, constraints, or evidence relevant to the current task.
5. Inspect relevant source files, tests, CLI commands, templates, and documentation. Expand the investigation only when necessary.
6. Verify previous findings against the current repository when they could be outdated.
7. Identify missing expected files or documentation rather than assuming they exist.

Do not repeat investigations that are already resolved and adequately documented. Do not rely on history as a substitute for checking relevant current code.

## 2. Engineering Quality Standard

Approach every task with the rigor expected of an experienced software engineer.

- Find root causes instead of treating symptoms.
- Consider maintainability, architecture, failure modes, compatibility, and security.
- Prefer simple, focused solutions over unnecessary abstractions.
- Consider material trade-offs before choosing an implementation.
- Avoid speculative improvements unrelated to the requested outcome.
- Never claim experience, execution, or verification that did not occur.

## 3. Plan Before Implementation

Before editing, present or record a plan appropriate to the task.

Include:
- Goal and expected outcome
- Scope and exclusions
- Relevant context and verified findings
- Implementation steps and affected files
- Acceptance criteria
- Verification steps
- Material risks and dependencies
- Whether user approval is needed and why

Scale planning to complexity:

- **Small:** a few concise bullets.
- **Normal:** implementation steps, affected files, acceptance criteria, and checks.
- **Complex:** alternatives, trade-offs, dependencies, compatibility, staged implementation, and recovery considerations.

Proceed with routine, reversible changes without unnecessary approval. Ask for approval when the user requires it, a consequential ambiguity exists, the scope would materially expand, or an action is destructive, sensitive, or external.

If implementation reveals a significant new risk or scope change, update the plan before proceeding when approval is necessary.

## 4. Scope Control and Repository Safety

- Make the smallest complete change that satisfies the acceptance criteria.
- Avoid unrelated refactors, dependency additions, renames, generated-file churn, and broad documentation rewrites.
- Preserve existing public behavior unless a change is requested or necessary and explained.
- When modifying a feature or CLI command, inspect its related argument parsing, help text, output, tests, examples, and documentation.
- Never overwrite unrelated user changes.
- Never execute destructive Git or filesystem commands without explicit permission.
- Keep credentials, API keys, passwords, and other secrets out of source code, logs, history, and examples.
- Inspect the final diff for accidental changes.

## 5. Task Timing

Record actual task start and end timestamps when a reliable clock is available.

- **Start:** immediately before the first task-specific investigation or implementation.
- **End:** after implementation, required verification, and task records are complete.
- Use ISO 8601 timestamps with timezone, such as `2026-10-14T09:00:00+06:00`.
- Calculate elapsed time as end minus start.
- Report wall-clock duration by default, including pauses.
- If active working time is recorded, report it separately.
- Never invent timestamps or durations.
- If the start time was not captured, record `Not measured`.
- If work is blocked or incomplete, record its status instead of reporting a completed-task duration.

## 6. Token Usage

Report token usage only when a trustworthy metric is available.

- Distinguish input, output, and total tokens when possible.
- Identify the source of the metric.
- If unavailable, record `Not available`.
- Never estimate or invent token counts.

Token efficiency must not compromise correctness, security, or necessary verification.

## 7. History Management

Use the repository's existing history file and format, such as `docs/HISTORY.md`, if present. Do not create a competing history system without a clear need.

Keep history entries newest first when consistent with the existing convention.

For completed tasks, record:

- Task title and category
- Agent identifier, if known
- Actual start and end timestamps with timezone
- Calculated elapsed wall-clock duration
- Outcome and reason for the change
- Reusable findings or decisions that prevent future investigation
- Evidence references, such as source paths, symbols, tests, or commands
- Verification results
- Token usage, if trustworthy

Adapt this example to the existing history format:

    ## YYYY-MM-DD HH:mm ±HH:mm — [Category] Task title
    - Agent: gemini
    - Start: YYYY-MM-DDTHH:mm:ss±HH:mm
    - End: YYYY-MM-DDTHH:mm:ss±HH:mm
    - Elapsed: 42 minutes (wall-clock)
    - Result: ...
    - Reusable finding: ... (evidence: path/symbol/command)
    - Verification: PASS ...; FAIL ...; SKIPPED ...; NOT RUN ...
    - Token usage: input ...; output ...; total ... (source: ...)

If no trustworthy token metric exists, use:

    - Token usage: Not available

History should capture outcomes, decisions, verified facts, and important pitfalls—not chain-of-thought, lengthy transcripts, or a diary of every action.

Prefer evidence references over copied explanations. Do not mark proposed work as completed. Record interrupted work only when it will help continuation.

Do not introduce elaborate task IDs unless the repository already has an established convention.

## 8. Mandatory Pre-release Documentation Gate

Before declaring any release ready to publish, review the README, CHANGELOG, and every document affected by the release.

1. Identify the actual changes included in the release.
2. Review README installation instructions, usage, CLI examples, options, features, screenshots, and claims affected by those changes.
3. Review CHANGELOG entries for changes, fixes, breaking changes, migrations, and compatibility notes.
4. Review other affected documentation, including guides, CLI references, configuration examples, templates, API references, contribution instructions, and release notes.
5. Compare documentation claims against the current implementation and relevant tests.
6. Report each documentation item as one of:
    - **Updated and verified**
    - **Already accurate; no change needed**
    - **Missing or requires correction**
    - **Not checked**, with the reason
7. Make documentation changes within the authorized scope. If approval is required, identify the exact files and changes needing approval.
8. Do not declare the release ready to publish while required documentation corrections remain unresolved.
9. Recheck the documentation and explicitly report when the gate passes.
10. Avoid gratuitous edits when existing documentation is accurate.

For ordinary non-release tasks, update the documentation directly affected by the change without performing an unnecessary full documentation audit.

## 9. Plan and History Lifecycle

Keep the active plan focused on current work, upcoming steps, decisions, and acceptance criteria.

Update the plan as scope or status changes. Record completed work in history. Mark unfinished work as blocked or deferred rather than complete.

Respect existing repository conventions. Avoid duplicate plans, duplicate histories, and unnecessary process files.

If the repository has a history-management command, inspect its existing help or documentation before using it. Do not invent commands or flags.

## 10. Switching Agents and Continuing Work

Agents may be switched when a token budget is exhausted, a session ends, or the user chooses another agent. Simultaneous multi-agent collaboration is not required.

When continuing the same task:

1. Read the active plan and latest relevant history entry.
2. Inspect current Git status and diff.
3. Identify what is completed, incomplete, blocked, and unverified.
4. Reuse verified findings and decisions.
5. Inspect only the missing context needed to continue safely.
6. Continue from the recorded state rather than restarting the entire investigation.
7. Keep one consolidated history entry for the task where practical. Do not create duplicate completed entries merely because the agent changed.

Never assume another agent completed a step unless the current repository or reliable task record confirms it.

## 11. Verification and Task Closure

Select verification steps based on risk, scope, and acceptance criteria.

Where applicable, check:
- Formatting
- Static analysis
- Unit and integration tests
- CLI behavior and help output
- Generated output
- Documentation examples
- Compatibility
- Final Git diff

Report checks as **PASS**, **FAIL**, **SKIPPED**, or **NOT RUN**.

Explain material failures and why important checks were skipped or not run. Never claim that a test or command passed if it was not executed successfully.

Do not fix unrelated failures unless requested or necessary for safe completion.

A task is complete when:
- Acceptance criteria are met, or remaining criteria are explicitly blocked or deferred.
- Appropriate verification is performed and reported.
- The plan and history are updated as applicable.
- Relevant documentation is addressed.
- The final diff is reviewed.

## 12. Completion Report

At task completion, report concisely:

1. What changed
2. Important decisions and reusable findings
3. Verification results
4. Plan, history, and documentation files updated
5. Risks, failures, or blockers
6. Start and end timestamps, calculated duration, and token usage when available

Do not claim a release was published unless publication was actually completed and verified.

## Guiding Principle

**Optimize for durable progress—not the appearance of activity.**