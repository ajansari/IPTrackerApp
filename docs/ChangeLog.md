# ChangeLog — IP Tracking

Ground truth for what was built and why. Every deviation from FRD/TDD logged before the next batch.

---

## Assumptions made under time constraint (agent decisions — confirm or correct)

### A-1 — Extension identity
**Decision:** Publisher `DSW`, Extension Name `IP Tracking`, prefix `ipt`, namespace `DSW.IPTracking`, Deployment Target `SaaS PTE`, Localization `W1`.
**Reason:** User delegated the naming decision ("do what you think's right"). `DSW` from the user's email domain.
**Reverse cost:** Low if changed before Batch 1 (edit intake sheet + `app.json` + regenerate).

### A-2 — ID range widened
**Decision:** 80300–80339 (was 80300–80319).
**Reason:** UI + API + 2 permission sets = 21 objects; 20-ID range was 1 short. User confirmed 80300–80339 is free.

### A-3 — Price duplication resolved
**Decision:** `ipt IP App Edition."Unit Price"` is the reference/list price; `ipt IP App Price` is the authoritative price matrix keyed by App + Edition + Billing Period + Currency. Pricing basis (per user / per company / …) is implied by `ipt IP App."License Type"`, not a separate field.
**Reason:** User's spec put a price on both the Editions table and a separate Pricing table at the same grain — a contradiction. This keeps both without redundancy.

### A-4 — No Setup table / no number series (v1)
**Decision:** `ipt IP Entitlement."Entry No."` is `AutoIncrement`. `Code` fields are entered manually. No module Setup table.
**Reason:** Avoids a Setup object + number-series dependency in the first cut. Deferred, not rejected.

### A-5 — IP App "Edition" field
**Decision:** Modelled as `"Default Edition Code"` — an optional pointer to one edition of the app (TableRelation filtered by the app's own Code).
**Reason:** An IP App has many editions; a single field on the header only makes sense as a default.

### A-6 — IP Entitlement key & cardinality
**Decision:** PK `Entry No.`; the same Customer + IP App + Edition may appear on multiple entries (renewals, multiple environments). Secondary key on Customer No. + IP App Code + Edition Code.
**Reason:** Register/document semantics, like Service Item.

### A-7 — Expiration instead of an "Expired" status
**Decision:** Status enum stays {Gratis, Active, Demo}. `"Expiration Date"` (auto-suggested = Date of Purchase + 1M/1Y/3Y by Billing Period, user-editable) represents lapse. `Status` default = `Active`.
**Reason:** User's status list had no terminal value; a date is more precise than a status for lapse.

### A-8 — API pages editable
**Decision:** All four API pages use `DelayedInsert = true` (read/write).
**Reason:** User asked for "both" UI and API; no read-only constraint stated. Read-only consumers are served by the `IPT - IP Tracking Read` permission set.

### A-9 — Card ListParts added
**Decision:** IP App Card hosts an Editions ListPart (80320) and a Prices ListPart (80321), using two of the spare IDs.
**Reason:** Materially better UX; range has ample headroom.

### A-10 — `app.json` updated now
**Decision:** `name`, `publisher`, `idRanges`, `application` (→ 28.0.0.0) updated in `app.json` during DESIGN rather than at Step 05.
**Reason:** Keeps the parameter source of truth consistent; prevents drift. Scaffold folder structure still deferred to Step 05.

---

## Step 04 — Sanity Check findings and resolutions

Signed off 2026-09-04. Full evidence: `docs/SanityCheck.md`. All four blocking defects were
found by compiling a disposable probe project (outside the repo) against the project's own
symbols with CodeCop + UICop + PerTenantExtensionCop — not by inspection. Corrected model
compiles **0 errors / 0 warnings**.

## Issue 04-01 — Permission set names exceed the AL identifier limit
**Problem:** `"IPT - IP Tracking Read"` / `"IPT - IP Tracking Edit"` (22 chars) are rejected: `error AL0305: The length of the application object identifier ... cannot exceed 20 characters`.
**Root cause:** The runbook §2.4 checklist states a 30-character rule for entity and field names. `permissionset` identifiers are capped at **20**, and the project's pre-flight rule inherited the 30 figure, so the design passed its own check.
**Resolution:** Renamed to `"IPT - IP Track Read"` / `"IPT - IP Track Edit"` (19 each), keeping the `IPT - ` prefix from Parameter 1.3. Captions unchanged — `'IP Tracking - Read'` / `'IP Tracking - Edit'` — so the UI is unaffected. The pre-flight rule now carries a separate 20-char limit for permission sets.
**Files affected:** `TDD.md` §1.3, §9; `ObjectRegister.md`; `FRD.md` §7.6.
**Updated:** TDD and FRD — yes.

## Issue 04-02 — Batch plan could not compile batch-by-batch
**Problem:** TDD §3 contained 5 forward references: 80303 and 80304 (batch 2) referenced 80305 (batch 3) and 80306 (batch 4) through their `OnDelete` guards, and 80308 (batch 2) referenced ListPart 80321 (batch 3). Batches 2 and 3 would each fail to compile, breaking the Step 06 exit gate.
**Root cause:** The batch plan was built on the "smallest module first" heuristic without modelling the reference graph. Tables 80303–80306 are mutually referential, and each table's `LookupPageId`/`DrillDownPageId` → List page → `CardPageId` → Card page → ListParts forms one indivisible dependency cluster. No entity-by-entity split of that cluster compiles.
**Resolution:** Re-layered into 3 batches — B1 enums (3), B2 tables + List/Card + ListParts + permission sets (16), B3 API pages (4). Verified 0 forward references. Generation order inside B2 recorded in TDD §3. Alternative (5 entity batches with three files revisited) was considered and rejected: it trades a clean per-batch gate for rework churn.
**Files affected:** `TDD.md` §3; `ObjectRegister.md` (Batch column).
**Updated:** TDD — yes.

## Issue 04-03 — API publisher and group fail CodeCop, changing the API URL
**Problem:** `APIPublisher = 'DSW'` and `APIGroup = 'ipt_ipManagement'` both raise `warning AA0101: For pages of the type API the value of properties APIPublisher, APIGroup, EntityName, and EntitySetName should be camel-cased`. FRD §8 treats warnings as errors, so this blocks BUILD. `EntityName`/`EntitySetName` pass.
**Root cause:** Parameter 1.3 was populated from the publisher's brand casing (`DSW`) and a snake_case group name, neither of which matches the AL API naming rule.
**Resolution:** `APIPublisher = 'dsw'`, `APIGroup = 'iptIpManagement'`. Verified to clear AA0101 with no other diagnostic. The API base URL changes from `/api/DSW/ipt_ipManagement/v1.0/…` to `/api/dsw/iptIpManagement/v1.0/…`. Accepted deliberately: no consumer exists yet, so the change is free now and would be breaking after publish. This is the highest-value catch of Step 04.
**Files affected:** `TDD.md` §1.3, §5.3, §8.2; `FRD.md` §7.5.
**Updated:** TDD and FRD — yes.

## Issue 04-04 — Tables without a permission set are a compile error under PerTenantExtensionCop
**Problem:** `error PTE0004: Table 80303 'ipt IP App' is missing a matching permission set` — and the same for 80304, 80305, 80306.
**Root cause:** Permission sets were scheduled last (batch 5) on the assumption that they merely depend on the tables. Under PerTenantExtensionCop the dependency runs the other way as well: a table without a covering permission set is an error, so every batch before the permission sets would fail.
**Resolution:** Permission sets 80338/80339 are generated in the same batch as the tables (batch 2 of the re-layered plan). PerTenantExtensionCop is confirmed enabled for this PTE. Verified: PTE0004 clears for all four tables once both sets are present.
**Files affected:** `TDD.md` §3; `ObjectRegister.md` (Batch column).
**Updated:** TDD — yes.

## Issue 04-05 — Advisory findings applied
**Problem:** Eleven non-blocking findings (SanityCheck SC-05…SC-15).
**Root cause:** Mixed — template details not yet validated against the linter, and stale values carried from the scaffold.
**Resolution:**
- SC-05 `using` order reversed in the TDD template (`Microsoft.Finance.Currency` before `Microsoft.Sales.Customer`) — clears `info AA0477`.
- SC-06 file-naming convention pinned in new TDD §4.1 as `<ObjectNameWithoutSpaces>.<Type>.al` — clears 13 × `warning AA0215`.
- SC-07 `info AW0006` on Card pages accepted as-is; adding `UsageCategory` would place four card pages in Tell-Me. Info-level, does not breach the 0-warning gate.
- SC-08 AL runtime 16.0 → **17.0**, matching the symbols' `Runtime="17.0"` and the installed AL toolchain. Compiled clean at both; 17.0 chosen so the app is not locked out of runtime-17 features.
- SC-09 `app.json "platform"` 1.0.0.0 → 28.0.0.0.
- SC-10 Object Register total corrected from 21 to **23** — the two ListParts added by A-9 were never added to the footer.
- SC-11 `launch.json` `environmentName` `sandbox` → `v29Sandbox`, the tenant's only environment. Whether that environment is BC v29 must be confirmed before Step 09.
- SC-12 FRD §8 NFR reworded: bounded per-row FlowFields on list pages are permitted; unbounded aggregation is not.
- SC-13 field-number growth buffers noted for tables 80304 and 80305. Table 80306 left contiguous — renumbering its FlowFields buys nothing before BUILD.
- SC-14 `Deployment.md` added to the Step 12 deliverables.
- SC-15 `ipt IP App Price` deliberately has no `OnDelete` guard (rate-table semantics, per A-6); the effect on the Entitlement `Unit Price` FlowField is documented rather than changed.
**Files affected:** `TDD.md` §1.4, §4, §4.1, §5.3, §7.2, §7.3, §11; `FRD.md` §4, §8; `ObjectRegister.md`; `app.json`; `.vscode/launch.json`.
**Updated:** TDD and FRD — yes.

---

## Step 05 — Plan the Code

Completed 2026-09-04. Deliverable: `docs/BuildPlan.md`. **No deviation from FRD or TDD** — Step 05
adds the scaffold, the per-object generation order and the validation tooling; it changes no
design decision. Recorded here because the ChangeLog is the ground truth for what was built.

**Scaffold:** `src/{Enums,Tables,Pages,PermissionSets,API}`, `scripts/`, `.gitignore`,
`.vscode/settings.json` (CodeCop + UICop + PerTenantExtensionCop enabled, 4-space indent, no
tabs). Verified: the empty scaffold compiles to 0 errors / 0 warnings and produces `out/app.app`.

**Batch order:** TDD §3's three batches expanded to a per-object generation order (BuildPlan §2)
so that every object's dependencies exist on disk before it is written. Note for Batch 2: the
four tables are mutually referential, so the batch compiles at its **end**, not file by file.

**Pre-flight:** `scripts/preflight.py`, 26 rules, parameters read from a single `PARAM` block
derived from TDD §1. Beyond the six checks the runbook names (identifier length, entity-name
length, reserved keywords, localization range, `ObsoleteState`, required properties) it also
encodes the four Step 04 defects as permanent rules — NAME-01 carries the 20-char permission-set
limit (SC-01), API-01 the camelCase rule (SC-03), NS-02 the `using` sort order (SC-05), FILE-01
the file-naming convention (SC-06) — so that class of error cannot recur in a later batch
(runbook Step 07 action 3: "what rule should have caught it?").

**Validator tested before being relied on:** clean against the 17 compile-clean Step 04 probe
files; caught all 12 injected defects with no false positives. Three bugs *in the validator*
surfaced during that test and were fixed — a line-anchored property matcher that skipped
single-line field blocks, a page-level property search that mistook a field-level
`Editable = false` for a page property, and an end-anchored page-field pattern that skipped
one-line `field(...) { ... }`. Had these shipped untested, pre-flight would have passed files
with missing Captions and ToolTips.

**Build:** `scripts/build.sh` runs pre-flight then `alc` with all three analyzers and fails on
any warning as well as any error (Operating Rule 5).

---

## Batch 1 — Enums (2026-09-04)

**Objects:** 80300 `ipt IP License Type`, 80301 `ipt IP Billing Period`, 80302 `ipt IP Entitlement Status`.
**Deviation from TDD §6:** none — generated verbatim from spec.
**Verification:** `scripts/preflight.py src/Enums` → 0 failures. `scripts/build.sh` → 0 errors, 0 warnings, `out/app.app` produced.
**Files:** `src/Enums/iptIPLicenseType.Enum.al`, `src/Enums/iptIPBillingPeriod.Enum.al`, `src/Enums/iptIPEntitlementStatus.Enum.al`.
**ObjectRegister:** 80300–80302 marked Built.

---

## Batch 2 — Tables, UI pages, permission sets (2026-09-04)

**Objects (16):** tables 80303–80306; pages 80307–80314; ListParts 80320–80321; permission sets 80338–80339.
**Deviation from TDD §7/§8.1/§9:** none — generated verbatim from spec, in the dependency order from BuildPlan §2 (ListParts → Cards → Lists, tables before their referencing pages, permission sets last).
**Verification:** `scripts/preflight.py src/Tables src/Pages src/PermissionSets` → 0 failures. `scripts/build.sh` (full project, 19 files) → 0 errors, 0 warnings, 4 info.
**Info accepted, not a defect:** `AW0006` on all four Card pages (80308, 80310, 80312, 80314) — Cards are reached via their List page; adding `UsageCategory` would place four cards in Tell-Me. Pre-accepted at Step 04, SanityCheck SC-07.
**Files:** `src/Tables/*.al` (4), `src/Pages/*.al` (10), `src/PermissionSets/*.al` (2).
**ObjectRegister:** 16 objects marked Built.

---

## Batch 3 — API pages (2026-09-04)

**Objects (4):** 80315 IP App API, 80316 IP App Edition API, 80317 IP App Price API, 80318 IP Entitlement API.
**Deviation from TDD §8.2:** none — generated verbatim from the field identifier map.
**Verification:** `scripts/preflight.py src/API` → 0 failures. `scripts/build.sh` (full project, 23 files) → 0 errors, 0 warnings, 4 info (same accepted `AW0006` as Batch 2 — API pages themselves raised none).
**Files:** `src/API/*.al` (4).
**ObjectRegister:** all 23 objects now marked Built. **BUILD phase complete.**

---

## Step 08 — Gap-Fit Test, Fidelity Validation

Completed 2026-09-04. Deliverable: `docs/GapAnalysis.md`. Three-way comparison of FRD ⇄ TDD ⇄
as-built, evidence pulled from the compiled source on disk (not recalled from memory of
generating it): all 23 objects, every field count, every OnDelete guard, the R-1 rule wiring,
all 5 FlowFields' `Editable = false`, every List/Card/Part column set, every API field identifier
map, and both permission sets' grants were extracted with `grep` and checked line-for-line
against TDD §7–§9. Full project recompiled at the end to rule out drift: 0 errors, 0 warnings,
4 info (unchanged from Batch 3).

**Result: 1 gap, classified Intentional.**

## Issue 08-01 — Consumer permission documentation (FRD §7.6) not yet published
**Problem:** FRD §7.6 states documentation should list the base `D365 BASIC` + Customer read
permissions API/BI consumers need beyond the app's own permission sets. No such document exists.
**Root cause:** Deliberately deferred, not missed — flagged at Step 04 sign-off (SanityCheck
SC-14) as a Step 12 deliverable (`Deployment.md`), because Step 12 is where all consumer-facing
documentation is produced together.
**Resolution:** No action at Step 08. TDD §9 already carries the substance of the guidance;
`Deployment.md` at Step 12 will publish it as its own document.
**Files affected:** none yet — tracked for `docs/Deployment.md`.
**Updated:** neither TDD nor FRD — this is a documentation deliverable, not a design change.

**No other gap found.** Every FRD entity, TDD rule and property traced cleanly to the as-built
code; no scope creep, no undisclosed deviation.

---

## Step 09 (partial) — Package the app

Completed 2026-09-04. Deliverable: `docs/Packaging.md`. Scope: the "build the .app package"
action of Step 09 only — publish, green-team and red-team tests need a live BC tenant and are
still open.

`app.json` identity/runtime/dependencies re-confirmed against TDD §1 Parameter block — exact
match on every field. `./scripts/build.sh` → 0 errors, 0 warnings, 4 info (unchanged, pre-accepted
AW0006). Opened `out/app.app` and read its **compiled** `SymbolReference.json` and
`NavxManifest.xml` directly — 23 objects (4 tables, 14 pages, 3 enums, 2 permission sets) and
identity fields both match, confirming what ships is what was built, not just what's on disk.

**Observation (not a defect):** embedded source inside the package sits under a doubled
`src/src/...` path — the project's own top-level folder is named `src`, and
`includeSourceInSymbolFile` prefixes embedded source with `src/` again. Cosmetic only. Flagged
because `includeSourceInSymbolFile`/`allowDebugging`/`allowDownloadingSource = true` (inherited
from the Step 05 scaffold, never revisited) should be a deliberate choice before shipping to
production, not a carried-over default — appropriate for an internal PTE, but worth confirming.

**Files affected:** none (no code change; verification only).
**Updated:** neither TDD nor FRD.

---

## Batch deviations
*(none yet — BUILD not started)*
