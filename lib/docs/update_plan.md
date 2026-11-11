# ARCLE — Standardize Workflow Instructions for Claude, Codex, and Gemini

## Role

Act as a senior Dart/Flutter CLI engineer and AI-agent workflow architect with 10+ years of equivalent software engineering experience.

Inspect ARCLE's actual source code and standardize the mandatory workflow instructions generated for Claude, Codex, and Gemini.

The goal is to maintain one consistent set of mandatory workflow rules across all three agents while preserving each agent's native instruction-file conventions.

## 1. Preserve the Existing Folder Structure

Keep the existing `.ai/` folder, agent-specific folders, settings files, permissions, and other generated project files.

Make only this requested output-path change:

**Before:**

```text
.codex/
├── instructions.md
└── settings.json
```

**After:**

```text
.codex/
├── CODEX.md
└── settings.json
```

Do not rename, delete, or migrate any other folders or files as part of this task.

Inspect the actual generator implementation and update the relevant path constants, templates, file writers, tests, and documentation. Ensure no code still expects the old Codex instruction filename.

Before implementing the filename change, verify whether `CODEX.md` is automatically discovered by the intended Codex environment. If not, identify the compatibility implications and the smallest supported solution. Do not claim automatic loading without evidence.

## 2. Establish One Shared Workflow Contract

Audit the existing workflow rules and agent-specific instruction files.

Maintain a consistent mandatory workflow contract across:

- Claude: the existing Claude instruction entry point.
- Codex: `.codex/CODEX.md`.
- Gemini: the existing Gemini instruction entry point.

Use `.ai/` as the shared source of workflow rules wherever that matches the existing implementation.

Each agent's entry-point file must explicitly identify the shared rule files it must read and require them to be loaded before task-specific investigation or implementation.

Do not assume that creating a file automatically makes an agent load it.

Avoid maintaining three conflicting copies of shared rules. Agent-specific files may contain native integration details, but mandatory shared requirements must remain consistent.

## 3. Mandatory Workflow

Ensure the shared rules explicitly cover the following.

### Project discovery

- Inspect Git status and relevant diffs before making changes.
- Preserve existing user modifications.
- Read relevant source code, configuration, plans, and history.
- Identify the actual architecture, state management, networking, dependency injection, and project conventions.
- Verify files, APIs, commands, and packages before relying on them.
- Report missing or inaccessible required instructions honestly.

### Task planning

- Identify the task objective, scope, acceptance criteria, dependencies, and risks.
- Record a supplied Jira/task ID when available.
- Never invent task IDs or claim unperformed Jira actions.
- Plan before implementation, with planning depth appropriate to the task.
- Update the plan when the scope or implementation changes.
- Resume from verified state when continuing work across sessions or agents.

### UI and design system

- Use the project's `Dimensions` utility for supported UI dimensions, padding, margin, spacing, width, and height.
- Use `AppColors` and the existing theme system for colors and styling.
- Reuse existing common widgets where appropriate.
- Avoid scattered hardcoded UI values and duplicate design tokens.
- Inspect the actual project classes before using them.

For Figma, design MCP, screenshots, or supplied visual references, inspect available resources, match layout, dimensions, typography, spacing, colors, assets, and component states, compare the result against the reference, and disclose unresolved differences. Never claim pixel-perfect accuracy without an actual comparison.

### Clean Architecture

- Follow the architecture that exists in the project.
- Respect presentation, domain, data, and core responsibilities.
- Separate screen-level controllers, BLoCs, providers, or bindings when independent responsibilities and lifecycles justify it.
- Use focused use cases for distinct business operations.
- Keep API models separate from domain entities when their contracts or meanings differ.
- Reuse genuinely shared domain concepts rather than duplicating entities unnecessarily.
- Follow existing dependency injection, routing, repository, mapping, and error-handling conventions.
- Ask the user when a consequential architectural decision cannot be determined from requirements and source code.

### Coding and security

- Follow existing formatting, naming, null-safety, and analyzer conventions.
- Use existing logging utilities instead of debug `print()` calls.
- Avoid unnecessary dependencies and abstractions.
- Never hardcode secrets or expose sensitive information in logs.
- Validate input and handle expected failures.
- Keep changes minimal and preserve unrelated behavior.

### Verification

Run applicable formatting, analysis, tests, and other checks.

Report each check as `PASS`, `FAIL`, `SKIPPED`, or `NOT RUN`. Do not claim success unless supported by actual results.

Review the final Git diff before declaring completion.

### Plan and history management

Preserve ARCLE's actual plan/history locations and supported CLI commands.

Update the project plan and history, and feature-level records where applicable, according to repository conventions.

Verify the available history-command arguments before using them. Never invent unsupported flags, timestamps, duration, or token metrics.

Record reliable timestamps and token usage only when available.

### Documentation and release readiness

Update documentation affected by the change.

Before declaring a release ready, inspect README, CHANGELOG, templates, CLI examples, configuration documentation, and other affected guides. Confirm that documentation matches the implementation.

### Agent switching

Sequential switching between Claude, Codex, and Gemini is supported. Simultaneous multi-agent collaboration is not required.

A continuation agent must inspect the plan, recent history, Git status, current diff, and remaining acceptance criteria before continuing.

### Completion report

Every completed task must report the outcome, changed files, verification results, plan/history updates, remaining risks, and blockers.

Never claim that a task is complete when mandatory acceptance criteria remain unverified.

## 4. Agent-Specific Entry Files

Inspect the existing generated templates for all three agents.

Each entry-point file must:

1. Identify itself as the mandatory project workflow entry point.
2. Explicitly require reading the applicable `.ai/` rules before task-specific work.
3. Require project discovery, planning, implementation, verification, and history updates.
4. Explain what to do if required files are missing.
5. Avoid contradictory instructions and stale paths.
6. Preserve supported native agent configuration.

Use the verified existing filename conventions, with `.codex/CODEX.md` as the requested Codex filename.

Do not assume the filename is automatically recognized by Codex. Verify native discovery and address any incompatibility honestly.

## 5. Implementation and Tests

Trace the actual generation pipeline and update the real source code, not just example output.

Add or update tests to verify:

- Correct instruction filename for each agent.
- Codex generates `CODEX.md` rather than `instructions.md`.
- Existing settings and folder structure remain intact.
- Shared mandatory workflow requirements appear consistently across agents.
- Agent entry files reference valid shared rule paths.
- No stale Codex filename references remain in relevant generator code or documentation.
- Existing generation behavior remains correct.

Run relevant tests, formatting, and static analysis. Report any checks that could not be run.

## 6. Required Final Report

Provide:

1. Files and templates inspected.
2. Exact source files changed.
3. Confirmation of the Codex filename change.
4. Verification of Codex instruction discovery and any limitations.
5. Summary of workflow consistency across all three agents.
6. Test results.
7. Documentation changes.
8. Remaining blockers.

Do not modify unrelated features, delete configuration directories, or change the package version without authorization.