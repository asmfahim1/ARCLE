# ARCLE — Diagnose and Fix AI Workflow Non-Compliance

## Role

Act as a senior Dart/Flutter CLI engineer and AI-agent integration specialist with 10+ years of equivalent software engineering experience.

ARCLE generates shared workflow rules and agent-specific instructions for Claude, Codex, and Gemini. However, after configuring an agent through ARCLE and assigning it a task, the agent does not consistently follow the mandatory workflow.

Your job is to identify the actual root cause, implement a targeted fix, and verify the correction.

**Do not assume this is merely a prompt-quality problem. Inspect the real implementation and investigate instruction discovery, generated paths, configuration, runtime behavior, and workflow validation.**

## 1. Preserve Existing Configuration

Keep the existing directory structure.

- Keep `.ai/` and its current rule and configuration files.
- Keep each agent-specific configuration directory.
- Keep existing settings and permission files.
- Use `.codex/CODEX.md` as the requested Codex instruction filename, replacing `.codex/instructions.md` in the generator where applicable.
- Do not delete other generated files or directories.
- Preserve all unrelated user changes.

Inspect the actual repository before assuming any of these paths or filenames exist.

## 2. Audit Before Fixing

Before editing source code:

1. Read the applicable repository and agent instructions.
2. Inspect Git status, branch, and existing diffs.
3. Identify the actual ARCLE version.
4. Read the relevant README, CHANGELOG, tests, and implementation.
5. Trace the complete `arcle configure-ai` execution path.
6. Locate templates, output-path logic, shared-rule generation, settings writers, and permission handling.
7. Inspect the actual generated files.
8. Verify how Claude, Codex, and Gemini discover and load their instruction files.
9. Create or update a task plan.
10. Record the start timestamp if reliable timing is available.

Do not modify code during the initial investigation phase.

## 3. Find the Actual Root Cause

Investigate the following possibilities individually. These are hypotheses, not conclusions.

### A. Instruction files are not discovered

Verify the exact native instruction filenames, supported locations, working-directory behavior, and loading rules for each agent.

Determine whether ARCLE writes its instructions to paths that the selected agent actually reads.

Pay particular attention to `.codex/CODEX.md`: confirm whether the intended Codex environment recognizes that file and whether a different supported entry point is required.

If the requested filename is not automatically recognized, document the conflict and recommend the smallest compatible solution. Do not claim automatic loading without evidence.

### B. Shared rules are not loaded

Inspect `.ai/architecture_rules.md`, `.ai/coding_rules.md`, `.ai/project_context.md`, and other rule files present in the actual repository.

Verify that each agent's primary instruction file explicitly requires reading the correct shared rules before task-specific investigation and implementation.

Search for:

- Incorrect paths.
- Stale filenames.
- Missing rule references.
- References to files that are never generated.
- Instructions that are present only in an unrelated file.
- Inconsistent shared rules across agents.

### C. Instructions are too vague

Determine whether the generated instructions define concrete actions or only broad principles.

For example, compare:

- Vague: “Follow ARCLE workflow.”
- Actionable: “Before task-specific work, read the shared rules, inspect Git status and the relevant history, identify acceptance criteria, and prepare the task plan.”

Ensure the workflow describes required actions, expected outputs, and completion checks.

Do not make the instructions unnecessarily long. Prefer precise, testable requirements.

### D. Settings or permissions interfere

Inspect `settings.json`, `settings.yaml`, and `permissions.yaml`.

Verify their actual schemas, readers, supported fields, and effects.

Determine whether configuration is invalid, ignored, stored at the wrong path, or preventing required workflow commands.

Distinguish between written instructions and technically enforced permissions. Do not weaken security controls to force compliance.

### E. The generator produces inconsistent output

Compare the source templates and generated output for Claude, Codex, and Gemini.

Verify whether shared requirements are missing, duplicated inconsistently, overwritten, or conditionally omitted.

Identify whether re-running `configure-ai` changes or removes required instructions unexpectedly.

### F. No enforcement or validation exists

Determine whether ARCLE has any mechanism to validate the generated workflow configuration.

Check whether it can detect:

- Missing instruction files.
- Missing mandatory rule references.
- Invalid paths.
- Missing workflow sections.
- Unsupported commands or configuration fields.
- Stale references to old instruction filenames.

Where appropriate, add static validation so detectable configuration defects fail visibly instead of remaining unnoticed.

Do not claim that static validation proves the external AI agent followed the instructions at runtime.

## 4. Reproduce the Problem When Possible

Use a controlled test project and the actual ARCLE generation process where practical.

Verify:

1. What files ARCLE generates.
2. Whether the selected agent recognizes the intended entry-point file.
3. Whether shared rule files are accessible.
4. Whether required commands can be run.
5. Whether a representative task follows the required lifecycle.
6. Whether the agent can skip required verification or history updates without any warning.

If actual agent execution is unavailable, state that explicitly and distinguish static source findings from unverified runtime behavior.

Do not fabricate a reproduction or claim that an external agent was tested when it was not.

## 5. Implement a Targeted Fix

After identifying the cause, implement the smallest complete fix.

Depending on the evidence, this may include:

- Correcting instruction filenames or output paths.
- Correcting shared-rule references.
- Strengthening agent-specific entry instructions.
- Aligning the three agents on the same mandatory workflow contract.
- Correcting settings generation.
- Adding validation for required files, paths, and instruction sections.
- Updating regression tests.
- Correcting outdated documentation.

Do not make unrelated architecture changes.

Preserve the existing directory structure and settings unless the verified root cause requires a narrowly scoped correction.

## 6. Required Workflow Contract

Ensure the generated instructions consistently require the following lifecycle.

1. **Load instructions:** read all applicable shared rules and report missing files.
2. **Inspect:** check Git status, relevant source, project configuration, plan, and history.
3. **Plan:** identify scope, acceptance criteria, risks, and implementation steps.
4. **Implement:** follow existing architecture, design-system, and security conventions.
5. **Verify:** run appropriate tests, analysis, formatting, and visual checks.
6. **Document:** update affected plans, histories, and documentation.
7. **Review:** inspect the final diff and report remaining risks.
8. **Report:** provide actual outcomes and verification evidence.

The workflow must include the project's actual requirements for `Dimensions`, `AppColors`, theme usage, Clean Architecture, screen-level state boundaries, focused use cases, model/entity separation, Figma/design-reference fidelity, and truthful test reporting.

Use the existing project rule files as the source of truth. Do not silently omit requirements that already exist in the project's workflow.

## 7. Regression Tests

Add or update tests for:

- Correct output paths for every supported agent.
- The requested Codex filename.
- Presence of mandatory workflow sections.
- Correct references to shared `.ai/` rule files.
- Detection of missing required files and stale paths.
- Configuration validation.
- Safe regeneration and preservation of settings.
- Existing CLI behavior unrelated to this fix.

Run focused tests first, then broader relevant tests where practical.

Run formatting and static analysis where appropriate.

Inspect the generated output and final Git diff.

Report `PASS`, `FAIL`, `SKIPPED`, or `NOT RUN` for each relevant verification check.

## 8. Documentation and History

Update the README, CHANGELOG, and affected documentation only where the actual behavior changes.

Verify all documented commands and arguments against the implementation. Do not invent unsupported CLI flags.

Update the project plan and history using the repository's established conventions. Record timestamps and token usage only when reliable measurements are available.

## 9. Acceptance Criteria

- [ ] The root cause is supported by actual source evidence or a reproducible test.
- [ ] Instruction discovery has been investigated separately for each supported agent.
- [ ] The correct shared rules are referenced and loaded through the supported mechanism.
- [ ] The Codex filename change is handled correctly.
- [ ] The fix addresses the identified cause rather than merely rewriting the prompt.
- [ ] Detectable configuration defects are validated where feasible.
- [ ] Regression tests cover the correction.
- [ ] Existing folders, settings, permissions, and unrelated user changes are preserved.
- [ ] Relevant tests pass, or failures and skipped checks are disclosed.
- [ ] Documentation matches the actual implementation.
- [ ] Runtime limitations are stated honestly.

## 10. Final Report

Provide:

1. **Actual root cause(s).**
2. **Evidence:** exact source files, functions, generated files, or test results.
3. **Why the existing configuration failed.**
4. **Changes implemented:** exact file paths and behavioral changes.
5. **Per-agent results:** Claude, Codex, and Gemini.
6. **Validation and regression-test results.**
7. **Documentation and history updates.**
8. **Remaining limitations or unverified runtime behavior.**

Do not stop after presenting possible causes. Complete the scoped fix once the evidence establishes what needs to change.

Do not claim that workflow compliance is guaranteed by Markdown alone. The objective is to make instruction discovery correct, requirements actionable, configuration defects detectable, and compliance verifiable to the extent supported by the agent environment.