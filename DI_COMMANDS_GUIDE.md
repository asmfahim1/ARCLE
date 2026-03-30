# Dependency Injection Commands Guide

## Overview

The ARCLE CLI provides two separate commands for Dependency Injection (DI) generation: **`gen-di`** and **`auto-gen-di`**. Both perform similar core functions but differ in the complete workflow they execute.

---

## Command Comparison

### `gen-di` - Manual Control (Quick DI Generation)

**Purpose:** Generate or regenerate Dependency Injection files only.

**What it does:**
- Generates/updates DI infrastructure files
- That's it — you control everything else

**When to use:**
- ✅ You only need to create/update DI infrastructure
- ✅ You want manual control over `pub get` and `build_runner`
- ✅ Using GetX or Riverpod (which don't need build_runner)
- ✅ Quick iterations on DI structure
- ✅ You want to verify DI changes before building

**Workflow:**
```
gen-di → DI files generated
         (manual: pub get, build_runner, etc.)
```

**Aliases:**
- `arcle gen-di`
- `arcle di`

**Example:**
```bash
arcle gen-di --state bloc
arcle di --force
```

---

### `auto-gen-di` - Full Automation (Complete Setup)

**Purpose:** Auto-generate DI and complete the entire setup in one command.

**What it does:**
1. Generates/updates DI files
2. Updates project dependencies
3. Runs `pub get`
4. Runs `build_runner` (for BLoC state management)

**When to use:**
- ✅ You want everything done automatically in one step
- ✅ After modifying service dependencies
- ✅ Setting up a fresh project with DI scaffolding
- ✅ Using BLoC state management (needs build_runner)
- ✅ You want maximum convenience without manual steps

**Workflow:**
```
auto-gen-di → DI files → Dependencies → pub get → build_runner
              (complete automated setup)
```

**Aliases:**
- `arcle auto-gen-di`
- `arcle autodi`

**Example:**
```bash
arcle auto-gen-di --state bloc
arcle autodi --force
```

---

## Why Two Separate Commands?

### Flexibility
- **`gen-di`** gives developers fine-grained control over each step
- **`auto-gen-di`** provides convenience for users who want everything at once

### State Management Differences
- **BLoC** requires `build_runner` to generate code
- **GetX** and **Riverpod** don't need `build_runner`

With two commands:
- Use `gen-di` for GetX/Riverpod projects (skip unnecessary steps)
- Use `auto-gen-di` for BLoC projects (complete setup in one shot)

### Workflow Control
Different scenarios require different approaches:

| Scenario | Command | Why |
|----------|---------|-----|
| Want to verify DI changes before building | `gen-di` | Gives you control |
| First-time project setup | `auto-gen-di` | One-shot complete setup |
| Added new service dependencies | `auto-gen-di` | Auto-handles pub get |
| Using GetX/Riverpod | `gen-di` | Skip unnecessary build_runner |
| Quick DI structure iterations | `gen-di` | Don't rebuild every time |
| CI/CD pipeline | `auto-gen-di` | Automated, no manual steps |

---

## Quick Reference

```bash
# Quick DI update (you handle build steps)
arcle gen-di

# Complete setup (everything automated)
arcle auto-gen-di

# Force overwrite
arcle gen-di --force
arcle auto-gen-di --force

# Explicit state management
arcle gen-di --state bloc
arcle auto-gen-di --state getx

# Interactive prompt
arcle gen-di --interactive
arcle auto-gen-di --interactive

# Specify project path
arcle gen-di --path ./my_project
arcle auto-gen-di --path ./my_project
```

---

## Summary

| Aspect | `gen-di` | `auto-gen-di` |
|--------|----------|--------------|
| **DI Generation** | ✅ Yes | ✅ Yes |
| **Pub Get** | ❌ Manual | ✅ Auto |
| **Build Runner** | ❌ Manual | ✅ Auto (BLoC) |
| **Dependency Update** | ❌ Manual | ✅ Auto |
| **Use Case** | Control & Flexibility | Speed & Automation |
| **Best For** | GetX, Riverpod, Iterations | BLoC, CI/CD, Setup |

Choose the command that fits your workflow! Both are valuable depending on your use case.
