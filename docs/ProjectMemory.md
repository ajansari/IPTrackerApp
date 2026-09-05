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
(28.4.53241.53312) for No. Series. **Version: `1.1.0.0`** (bumped from `1.0.0.0`, Minor, after
the 09F feedback batch — see ChangeLog). Packages in `out/` (never deleted — see the
"Packaging & Versioning" rule and the incident logged in ChangeLog): `IP_Tracking_1.0.0.0.app`,
`IP_Tracking_1.1.0.0.app`.

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

## Open decisions awaiting sign-off

*Each row names who the decision is waiting on — distinct from "who last edited this file"
(that's `git blame`'s job). Right now that's always AJ; add names here once a second person
raises or owns a decision.*

- **Roadmap R-3** — rename the "IP App" entity (candidates ranked, "Licensed Product"
  recommended). Deliberately deferred — do not action without asking. *(awaiting: AJ)*
- **Roadmap R-1** — Sales Invoice/Order → IP Entitlement creation. Idea only; open question on
  which Edition was sold, not designed. *(awaiting: AJ)*
- **Roadmap R-2** — a "Manual Nos." override for IP Entitlement `No.`. Idea only. *(awaiting: AJ)*
- **GA-01 / Issue 08-01** — consumer permission documentation (`D365 BASIC` + Customer read)
  not yet published as `Deployment.md`. Scheduled for Step 12, not forgotten. *(awaiting: AJ)*
- **Step 09 remainder** — publish to `v29Sandbox` and run green-team/red-team tests. Needs a
  live tenant; not done standalone. Also unresolved: whether `v29Sandbox` is actually BC v29,
  which would make the 28.4 symbols downlevel for it (SC-11). *(awaiting: AJ)*

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
- 2026-09-05 — Named attribution ("AJ", not "the human"/"User") applied throughout ChangeLog/TDD;
  "awaiting: `<name>`" added to every Open Decisions row above; runbook gained a BaseApp-docs
  symbol-file fallback and a Step 01 "ask 5 questions before inferring" kickoff rule.
- 2026-09-05 — Runbook Step 01 also now collects Object ID ranges as an ask-confirm-loop
  (start ID, end ID, show range, confirm, "additional ranges? Y/N", repeat); §1.2's table
  restructured to hold any number of ranges, not just Primary + one optional Additional.
- 2026-09-05 — Package naming fixed: `scripts/build.sh` now outputs
  `<AppName>_<version>.app` (derived from `app.json`, e.g. `IP_Tracking_1.0.0.0.app`) instead of
  a hardcoded `app.app`. New runbook policy for when to offer repackaging, how to size a version
  bump, and pushing back on a premature ask for either.
- 2026-09-05 — First repackage under the new policy: version `1.0.0.0` → `1.1.0.0` (Minor,
  proposed with reasoning, confirmed by AJ). `out/IP_Tracking_1.1.0.0.app`, 0 errors/0 warnings.
- 2026-09-05 — Incident: a manual `rm -f out/*.app` before both builds above deleted the
  1.0.0.0 package (not a `build.sh` defect — confirmed the script never deletes anything).
  Recovered by rebuilding from the exact prior source state, not a true undelete (`out/` isn't
  git-tracked; `rm` doesn't use Trash). Runbook gained an explicit "never delete a previous
  package" rule citing this incident.

## Next

Step 09 remainder (publish + test on `v29Sandbox`), then Step 10 (Code Review — `/code-review
ultra` is user-triggered/billed, offer it), Step 11 (update design docs if PROVE surfaces
anything), Step 12 (Document the Code: API reference, **Mermaid `erDiagram`** covering owned +
touched standard tables, `Deployment.md` closing GA-01, integration examples).
