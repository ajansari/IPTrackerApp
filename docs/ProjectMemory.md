# Project Memory — IP Tracking

*Required by `BC_App_Build_Routine_Agent.md` ("Project Memory" — ALL ALONG). An anchor, not a
narrative: where things are and what's still open. The story of *why* lives in `ChangeLog.md`.
Update at the close of every step or batch. Committed to git like every other doc here.*

---

## Current state (2026-09-05)

**Phase:** PROVE — **Steps 10, 11 and 12 complete; only Step 09's live verification outstanding.**
BUILD complete; Step 08 (Gap-Fit) closed; **Step 09: published by AJ to `v29Sandbox`, but its
green/red-team tests were skipped by instruction — exit gate NOT met**; Step 10 Code Review done
(2 findings fixed); Step 11 as-built docs done; Step 12 documentation set done. The app is
feature-complete and documented, but **has never been functionally verified on a live tenant**.

**Identity:** Publisher `OnlyCopilotFans`, prefix `ocpf`, namespace `OnlyCopilotFans.IPTracking`,
runtime 17.0, ID range 80300–80339 (32 used, 8 free). Dependency on Business Foundation
(28.4.53241.53312) for No. Series. **Version: `1.2.0.1`** (Minor `1.0.0.0`→`1.1.0.0` after the
first 09F batch, Minor `1.1.0.0`→`1.2.0.0` after 09F-13/09F-14, Revision `1.2.0.0`→`1.2.0.1`
after 09F-13's corrective fix — see ChangeLog). Packages in `out/` (never deleted):
`IP_Tracking_1.0.0.0.app`, `IP_Tracking_1.1.0.0.app`, `IP_Tracking_1.2.0.0.app`,
`IP_Tracking_1.2.0.1.app`.

**Object count:** 32 (3 enums, 5 tables, 10 UI pages, 2 catalog pages, 2 ListParts, 4 API pages,
1 tableextension, 4 pageextensions, 2 permission sets). Full list: `ObjectRegister.md`.

**Build status:** `./scripts/build.sh` → 0 errors, 0 warnings, 6 pre-accepted info (`AW0006` on
4 Card pages, SC-07, + 2 catalog pages with no `UsageCategory`, 09F-13). Verify this is still
true before trusting anything below — it may have drifted since this file was last updated.

## Live documents — read these, not this file, for anything substantive

| Document | What it's the source of truth for |
|---|---|
| `TDD.md` | Every object's exact spec — the one a developer regenerates code from |
| `FRD.md` | Business requirements, in business language |
| `ObjectRegister.md` | Every object, its ID, and its Built/Planned status |
| `ChangeLog.md` | Every decision, its reasoning, and every defect found + fixed |
| `TestingFeedback.md` | Raw human testing input, verbatim, before triage |
| `Roadmap.md` | Deferred/future work — not scheduled, just not lost |
| `PostDevTDD.md` | **As-built** object truth — what actually exists. Beats `TDD.md` where they disagree |
| `Documentation.md` | Consumer/integration API reference + Mermaid schema (generated from code) |
| `HumanUnitTestScript.md` | 40-step manual test pass — **specification, not yet executed** |
| `Deployment.md` | Admin install/permissions/upgrade/uninstall guide |
| `CodeReview.md` | Step 10 findings — point-in-time record |
| `SanityCheck.md`, `GapAnalysis.md`, `Packaging.md`, `BuildPlan.md` | Historical Step 04/05/08/09 records — point-in-time, not living specs. Each now carries a banner pointing back here |

## Open decisions awaiting sign-off

*Each row names who the decision is waiting on — distinct from "who last edited this file"
(that's `git blame`'s job). Right now that's always AJ; add names here once a second person
raises or owns a decision.*

- **Roadmap R-3** — rename the "IP App" entity (candidates ranked, "Licensed Product"
  recommended). Deliberately deferred — do not action without asking. *(awaiting: AJ)*
- **Roadmap R-1** — Sales Invoice/Order → IP Entitlement creation. Idea only; open question on
  which Edition was sold, not designed. *(awaiting: AJ)*
- **Roadmap R-2** — a "Manual Nos." override for IP Entitlement `No.`. Idea only. *(awaiting: AJ)*
- ~~**GA-01 / Issue 08-01** — consumer permission documentation~~ **CLOSED at Step 12** —
  published as `Deployment.md` §4 with a role-mapping table.
- **Step 09 exit gate unmet** — AJ published `1.2.0.1` to `v29Sandbox`, but the green-team /
  red-team / live permission verification were skipped by AJ's instruction. Never established
  either way: whether the 4 custom API pages are actually discoverable/installed there (neither
  keyword nor semantic `bc_actions_search` found them before the step was cut short), and
  whether `v29Sandbox` is really BC v29, which would make the 28.4 symbols downlevel (SC-11).
  *(awaiting: AJ)*
- **preflight rule gap (10-02)** — `preflight.py` has no rule requiring `DataClassification` on
  `tableextension` fields; TAB-01 only checks table-level. Adding one would stop that class of
  gap recurring. Not done — deliberately not scope-crept into the review. *(awaiting: AJ)*
- **09F-14 table placement** — "License Key" (Text80) was placed on `ocpf IP Entitlement`
  because the request didn't name a table; reasoned as the per-customer register, not the
  catalog tables. Confirm this is right, or move it. *(awaiting: AJ)*

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
- 2026-09-05 — Second testing round (09F-13/09F-14): fixed a real defect (new Entitlement from
  either cross-reference action fell outside its own filter — `RunPageLink` doesn't default new
  records, only filters; fixed via `OnNewRecord`, rule R-5); added `"License Key"` (Text80) to
  `ocpf IP Entitlement`; added Roadmap R-4 (License Key Generator, idea only).
- 2026-09-05 — Version `1.1.0.0` → `1.2.0.0` (Minor). Self-corrected from an earlier Build/
  Revision suggestion — a new field is Minor per our own policy, a bundled bugfix doesn't
  downgrade that. Confirmed by AJ. `out/IP_Tracking_1.2.0.0.app`; all three packages present.
- 2026-09-05 — AJ asked why `Packaging.md` still showed `DSW` (created 2026-09-04, before the
  09F-05 rename, never updated — confirmed via git history, not a bug). Added a "superseded,
  see this file" banner to all four point-in-time records rather than editing their history.
- 2026-09-05 — 09F-13's first fix didn't work in real testing. Checked Base App's actual
  "Item Vendor Catalog" symbols rather than guess again: the missing piece was no `CardPageId`
  + a hidden linking field on a *dedicated* target page, not a trigger on the shared list. Added
  pages 80328/80329, retargeted all four cross-reference actions. 32 objects now.
- 2026-09-05 — Version `1.2.0.0` → `1.2.0.1` (Revision — corrective fix to an already-shipped
  feature, no new capability). Confirmed by AJ. `out/IP_Tracking_1.2.0.1.app`; all four packages
  present.
- 2026-09-05 — Step 09 remainder skipped by AJ's instruction after live API discovery came up
  empty; exit gate left unmet, logged as a deviation rather than quietly closed.
- 2026-09-05 — Step 10 Code Review complete (`CodeReview.md`): 12 dimensions scanned, 10 clean,
  2 scan hits dismissed as false positives, 2 real findings fixed — 10-01 (catalog pages missing
  the `"No."` column, late-batch drift) and 10-02 (Item extension field had no
  `DataClassification`, the app's only unclassified field).
- 2026-09-05 — Step 11: `PostDevTDD.md` written (as-built, generated via new
  `scripts/extract_asbuilt.py`); `FRD.md` re-baselined — caught 2 genuinely stale statements
  (the Unit Price FlowField NFR, and Setup/number-series still listed as out of scope).
- 2026-09-05 — Step 12: `Documentation.md` (API reference + Mermaid erDiagram, generated from
  code), `HumanUnitTestScript.md` (40 steps, not yet run), `Deployment.md` (closes GA-01).

## Next

**The runbook is complete through Step 12 except Step 09's live verification.** What remains:

1. **Run `HumanUnitTestScript.md` against `v29Sandbox`** — the outstanding Step 09 work, now with
   a written 40-step script to follow. Until this passes, "working" is asserted, not demonstrated.
2. **Optional:** `/code-review ultra` for an independent multi-agent review (user-triggered/billed).
3. **Decide the open items** listed above — the IP App rename (R-3), License Key table placement,
   the `resourceExposurePolicy` source-shipping question, and the preflight `tableextension` rule gap.
4. Roadmap R-1/R-2/R-4 remain unscheduled ideas.
