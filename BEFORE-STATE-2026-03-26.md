# Before State Reconstruction - 2026-03-26

## Purpose

This file reconstructs the most defensible "before modification" state from:

- handoff files in the workspace
- the sample project on disk
- the original source reviewed before this tuning pass

It is not a historical Git snapshot. It is a forensic record created after the fact.

## What Was Claimed Before Review

From the handoff documents, the following claims were presented:

1. the workflow was already at v7 quality
2. dual-model review gates were mandatory and preserved
3. TG username auto-detection was implemented
4. the sample project had successfully completed two iterations
5. the structure and references were broadly consistent

## What Was Actually Verified Before Review

Before this tuning pass, the following facts were verified in source:

1. skill installation path guidance was inconsistent across documents
2. gate specs allowed review skipping when Codex CLI was unavailable
3. Chinese requirement slug handling was unsafe
4. TG username auto-write to `.env` was not implemented in `init-project.sh`
5. the test-pipeline template contained unsafe shell logic
6. a requirements-ingestion command template referenced a nonexistent MCP call

## Sample Project State Before Review

Verified in `/Volumes/HS-SSD-1TB/work-test-piple-1`:

1. both `src/` and `web/` existed
2. iteration directories for `calculator-feature` and `h5-dark-theme-feature` existed
3. `tests/e2e/h5-calculator.e2e.ts` existed
4. `tests/unit/calculator.test.ts` existed
5. `tests/reports/h5-calculator-coverage.md` claimed a unit test file that did not exist
6. `package.json` defined a `lint` script but did not include `eslint` in dependencies

## Confidence Notes

High confidence:

- filesystem existence/non-existence
- contents of source files and handoff files

Lower confidence:

- whether the claimed successful workflow runs were executed exactly as described
- whether the sample project was manually repaired between steps and then summarized loosely

## Why No True Pre-Change Commit Exists

At the time this review started:

- `sdlc-workflow/` was untracked in Git
- the handoff files were also untracked

That means there was no repository baseline from which to create a genuine "before" commit after the fact.

## Current Intent

This reconstruction exists so future readers can distinguish:

- **what the system claimed**
- **what was actually verified**
- **what was changed during the 2026-03-26 review pass**
