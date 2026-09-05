# Project Memory — IP Tracking

*Required by `BC_App_Build_Routine_Agent.md` ("Project Memory" — ALL ALONG). An anchor, not a
narrative: where things are and what's still open. The story of *why* lives in `ChangeLog.md`.
Update at the close of every step or batch. Committed to git like every other doc here.*

---

## Current state (2026-09-05)

**Phase:** PROVE. BUILD is complete; Step 08 (Gap-Fit) closed; Step 09 partial (packaged, not
yet published to a live tenant). Two testing-feedback rounds applied on top of BUILD.

**Identity:** Publisher `OnlyCopilotFans`, prefix `ocpf`, namespace `OnlyCopilotFans.IPTracking`,
runtime 17.0, ID range 80300–80339 (28 used, 12 free). Dependency on Business Foundation
(28.4.53241.53312) for No. Series.

**Object count:** 30 (3 enums, 5 tables, 9 UI pages, 2 ListParts, 4 API pages, 1 tableextension,
4 pageextensions, 2 permission sets). Full list: `ObjectRegister.md`.

**Build status:** `./scripts/build.sh` → 0 errors, 0 warnings, 4 pre-accepted info (`AW0006` on
Card pages, SC-07). Verify this is still true before trusting anything below — it may have
drifted since this file was last updated.

## Live documents — read these, not this file, for anything substantive

| Document | What it's the source of truth for |
|---|---|
| `TDD.md` | Every object's exact spec — the one a developer regenerates code from |
| `FRD.md` | Business requirements, in business language |
| `ObjectRegister.md` | Every object, its ID, and its Built/Planned status |
| `ChangeLog.md` | Every decision, its reasoning, and every defect found + fixed |
| `TestingFeedback.md` | Raw human testing input, verbatim, before triage |
| `Roadmap.md` | Deferred/future work — not scheduled, just not lost |
| `SanityCheck.md`, `GapAnalysis.md`, `Packaging.md`, `BuildPlan.md` | Historical Step 04/05/08/09 records — point-in-time, not living specs |

## Open decisions awaiting human sign-off

- **Roadmap R-3** — rename the "IP App" entity (candidates ranked, "Licensed Product"
  recommended). Deliberately deferred — do not action without asking.
- **Roadmap R-1** — Sales Invoice/Order → IP Entitlement creation. Idea only; open question on
  which Edition was sold, not designed.
- **Roadmap R-2** — a "Manual Nos." override for IP Entitlement `No.`. Idea only.
- **GA-01 / Issue 08-01** — consumer permission documentation (`D365 BASIC` + Customer read)
  not yet published as `Deployment.md`. Scheduled for Step 12, not forgotten.
- **Step 09 remainder** — publish to `v29Sandbox` and run green-team/red-team tests. Needs a
  live tenant; not done standalone. Also unresolved: whether `v29Sandbox` is actually BC v29,
  which would make the 28.4 symbols downlevel for it (SC-11).

## Milestone log (one line each — full detail in `ChangeLog.md`)

- 2026-09-04 — Steps 01–05 (DEFINE/DESIGN/scaffold) → `SanityCheck.md`, `BuildPlan.md`.
- 2026-09-04 — BUILD: 23 objects, 3 batches, 0/0 every batch.
- 2026-09-04 — Step 08 Gap-Fit: 1 gap (GA-01), classified Intentional.
- 2026-09-04 — Step 09 partial: package built and verified; publish still open.
- 2026-09-05 — Framework extended: Testing Feedback Log, Session Memory (later made prescriptive
  and in-repo — see below), `Roadmap.md` created.
- 2026-09-05 — Feedback batch 09F-01…09F-10: rename to `ocpf`/`OnlyCopilotFans`, enum blank
  defaults + new values, "Other" conditional visibility, Reference Unit Price removed, Item⇄IP
  App tie, Entitlement `No.` + No. Series + IP App Setup table, IP App⇄Customer lookups.
- 2026-09-05 — 09F-11/09F-12: Unit Price converted FlowField→stored+suggested+editable (R-4);
  two deletion-control gaps closed (Item check on IP App delete; Setup singleton guard).
- 2026-09-05 — This file created; "Session Memory" made prescriptive (`docs/ProjectMemory.md`
  required, in-repo) rather than conditional on the agent's own memory feature.

## Next

Step 09 remainder (publish + test on `v29Sandbox`), then Step 10 (Code Review — `/code-review
ultra` is user-triggered/billed, offer it), Step 11 (update design docs if PROVE surfaces
anything), Step 12 (Document the Code: API reference, **Mermaid `erDiagram`** covering owned +
touched standard tables, `Deployment.md` closing GA-01, integration examples).
