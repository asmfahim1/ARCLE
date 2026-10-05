/// Templates for the lightweight `docs/PLAN.md` and `docs/HISTORY.md`
/// files seeded at the project root and inside each feature module.
///
/// Not to be confused with `DocsTemplates` in `docs_templates.dart`,
/// which renders the full `arcle gen-doc` architecture document.
class ProjectDocsTemplates {
  /// Root project plan, seeded at `docs/PLAN.md` on `arcle create`/`init`.
  static String rootPlan(String projectName) => '''
# $projectName — Project Plan

## Overview

Describe the product goal, target users, and high-level scope here.

## Milestones

- [ ] Define core features and architecture
- [ ] Build MVP feature set
- [ ] Polish, test, and prepare for release

## Features

Each feature under `lib/features/<feature>/docs/` keeps its own `PLAN.md` and
`HISTORY.md`. This file tracks the project as a whole.
''';

  /// Root project history, seeded at `docs/HISTORY.md` on `arcle create`/`init`.
  /// Agents and `arcle history add` append entries here as work happens.
  static String rootHistory(String projectName) => '''
# $projectName — Project History

Chronological log of work done on this project by developers and AI agents.
Newest entries go at the top.

| Date | Agent | Feature | Summary |
| --- | --- | --- | --- |
''';

  /// Per-feature plan, seeded at `lib/features/<feature>/docs/PLAN.md`.
  static String featurePlan(String name) => '''
# $name Feature Plan

## Purpose

Describe the feature, its responsibilities, and the user flows it supports.

## Implementation plan

- [ ] Define the domain entities and repository contract.
- [ ] Implement the data sources, models, and repository.
- [ ] Build the presentation flow and connect routing/DI.
- [ ] Add tests and localization coverage.

See the root `docs/PLAN.md` for overall project context.
''';

  /// Per-feature history, seeded at `lib/features/<feature>/docs/HISTORY.md`.
  static String featureHistory(String name) => '''
# $name Feature History

Track meaningful changes to this feature here. Newest entries go at the top.

| Date | Agent | Summary |
| --- | --- | --- |
| ${_today()} | arcle | Feature scaffold created. |
''';

  static String _today() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
