# ChangeLog — IP Tracking

Ground truth for what was built and why. Every deviation from FRD/TDD logged before the next batch.

---

## Assumptions made under time constraint (agent decisions — confirm or correct)

### A-1 — Extension identity
**Decision:** Publisher `DSW`, Extension Name `IP Tracking`, prefix `ipt`, namespace `DSW.IPTracking`, Deployment Target `SaaS PTE`, Localization `W1`.
**Reason:** AJ delegated the naming decision ("do what you think's right"). `DSW` from AJ's email domain.
**Reverse cost:** Low if changed before Batch 1 (edit intake sheet + `app.json` + regenerate).

### A-2 — ID range widened
**Decision:** 80300–80339 (was 80300–80319).
**Reason:** UI + API + 2 permission sets = 21 objects; 20-ID range was 1 short. AJ confirmed 80300–80339 is free.

### A-3 — Price duplication resolved
**Decision:** `ipt IP App Edition."Unit Price"` is the reference/list price; `ipt IP App Price` is the authoritative price matrix keyed by App + Edition + Billing Period + Currency. Pricing basis (per user / per company / …) is implied by `ipt IP App."License Type"`, not a separate field.
**Reason:** AJ's spec put a price on both the Editions table and a separate Pricing table at the same grain — a contradiction. This keeps both without redundancy.

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
**Reason:** AJ's status list had no terminal value; a date is more precise than a status for lapse.

### A-8 — API pages editable
**Decision:** All four API pages use `DelayedInsert = true` (read/write).
**Reason:** AJ asked for "both" UI and API; no read-only constraint stated. Read-only consumers are served by the `IPT - IP Tracking Read` permission set.

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

## Testing feedback batch (2026-09-05) — 09F-01…09F-10

Source: `TestingFeedback.md`, session 2026-09-05. Ten issues: eight from triaged feedback,
two real defects found by compiling the batch (not by inspection — same discipline as Step 04).
Generated and compiled as one unit (30 files, not sub-batched) because the rename in 09F-05
touches every existing file and the new objects in 09F-06/07/08 depend on the renamed ones.

## Issue 09F-01 — License Type enum needed a blank default plus two new values
**Problem:** `ocpf IP License Type` had no blank/unspecified option and no way to express "Free" or "Free Open Source" licensing.
**Root cause:** Original enum (TDD §6.1) was scoped from the DEFINE-phase domain vocabulary, which didn't anticipate these needs; only surfaced once a real user tried to enter data.
**Resolution:** Added `value(0; " ") { Caption = ''; }` as the new default, renumbering Perpetual…PerOther from 0–6 to 1–7, then appended `Free` (8) and `FreeOpenSource` (9). Renumbering existing ordinals is normally forbidden for a published `Extensible` enum (BC convention: only ever append) — safe here only because BUILD had not reached Step 09 publish, so no live data exists against the old ordinals. Verified `value(0; " ")` compiles (an enum value's internal name can't be truly empty, but a single-space quoted identifier with an empty `Caption` does).
**Files affected:** `src/Enums/ocpfIPLicenseType.Enum.al` (renamed from `iptIPLicenseType.Enum.al`).
**Updated:** TDD (§6.1) and FRD (§7.1) — yes.

## Issue 09F-02 — "Other" field should only show for License Type = Per Other
**Problem:** `"Other"` on the IP App Card was always visible, even though it's only meaningful when License Type is Per Other.
**Root cause:** Not considered at DESIGN time — the field existed and had a tooltip, but no visibility rule was specified.
**Resolution:** Rule R-2: a page-scoped `Boolean` (`OtherVisible`), recomputed on `OnAfterGetCurrRecord` and on License Type's `OnValidate`, bound via `Visible = OtherVisible`. Table field and API are unaffected — UI-only.
**Files affected:** `src/Pages/ocpfIPAppCard.Page.al`.
**Updated:** TDD (§7.1 R-2) and FRD (§7.1) — yes.

## Issue 09F-03 — Default Billing Period needed a blank default
**Problem:** `"Default Billing Period"` on IP App had no way to leave it unspecified.
**Root cause:** Same as 09F-01 — surfaced only in testing.
**Resolution:** Added blank at ordinal 0 to the shared `ocpf IP Billing Period` enum, same renumbering approach and same one-time-exception justification as 09F-01.
**Ripple (explicit decision by AJ):** the enum is shared by three fields. Offered a choice — keep `IP App Price."Billing Period"` and `IP Entitlement."Billing Period"` defaulting to Monthly via explicit `InitValue`, or let all three default blank. **Decision: let all three default blank.** No `InitValue` added to either field; a new Price row or Entitlement now starts with no Billing Period until the user picks one, which also delays rule R-1 and the Unit Price FlowField lookup.
**Files affected:** `src/Enums/ocpfIPBillingPeriod.Enum.al`.
**Updated:** TDD (§6.2, §7.3, §7.4) and FRD (§7.1, §7.3, §7.4) — yes.

## Issue 09F-04 — Remove "Reference Unit Price" from IP App Edition
**Problem:** `IP App Edition."Unit Price"` (caption "Reference Unit Price") duplicated the pricing matrix (`IP App Price`) without being tied to it — nothing validated the two stayed consistent, recreating the exact ambiguity A-3 tried to resolve by relabeling rather than removing.
**Root cause:** A-3 (DEFINE-phase) kept both fields to preserve two different requirements found in the original spec at the same grain; in practice only the Prices matrix is ever calculated from, so the Edition-level field was pure UI clutter with a stale-data risk.
**Resolution:** Removed the field entirely — from the table, its List/Card/ListPart, and the Edition API's `unitPrice`. `IP App Price` is now the sole source of anything price-shaped.
**Files affected:** `src/Tables/ocpfIPAppEdition.Table.al`, `src/Pages/ocpfIPAppEditions.Page.al`, `src/Pages/ocpfIPAppEditionCard.Page.al`, `src/Pages/ocpfIPAppEditionsPart.Page.al`, `src/API/ocpfIPAppEditionAPI.Page.al`.
**Updated:** TDD (§7.2, §8.1, §8.2) and FRD (§7.2) — yes.

## Issue 09F-05 — Rename prefix/publisher/namespace: `ipt`/`DSW` → `ocpf`/`OnlyCopilotFans`
**Problem:** Prefix and publisher no longer matched the actual organization.
**Root cause:** A-1 set `DSW`/`ipt` from AJ's email domain under DEFINE-phase time pressure; corrected once the actual publisher was confirmed.
**Resolution:** `app.json` publisher → `OnlyCopilotFans`; AL object prefix `ipt`→`ocpf`; permission-set prefix `IPT - `→`OCPF - ` (both new names are exactly 20 chars, the AL0305 boundary — verified by compiling, not measured by eye); `APIPublisher` `'dsw'`→`'ocpf'`, `APIGroup` `'ipt_ipManagement'`/`'iptIpManagement'`→`'ocpfIpManagement'`. **Namespace `DSW.IPTracking`→`OnlyCopilotFans.IPTracking`** — not explicitly requested but caught by the "any other DSW references" audit: leaving the old publisher baked into every object's namespace while the publisher itself changed would have been an inconsistent, incomplete rename. All 23 existing files renamed accordingly (filenames included, per the `<ObjectNameWithoutSpaces>.<Type>.al` convention).
**Audit result:** zero `DSWi` references found anywhere. All `DSW` references were either the four items just listed (now fixed) or historical mentions inside `ChangeLog.md`/`SanityCheck.md`/`BuildPlan.md`/`GapAnalysis.md` recording past decisions — left untouched, as rewriting dated history would falsify the record.
**Files affected:** all 23 pre-existing `.al` files (renamed), `app.json`, `scripts/preflight.py` (`PARAM` block).
**Updated:** TDD (§1.1–§1.4, throughout) and FRD (§7.5, §7.6) — yes.

## Issue 09F-06 — Item ⇄ IP App tie
**Problem:** No way to associate a sellable Item with an IP App.
**Root cause:** New requirement, not previously scoped.
**Resolution:** `tableextension "ocpf Item"` (80323) adds `"IP App"` (Code[10], `TableRelation = "ocpf IP App".Code`, optional — blank is valid, not every item has an IP association) to table 27 Item. `pageextension`s on Item Card (80324, `addlast(Item)`) and Item List (80325, `addlast(Control1)`) surface it. Anchor group/control names (`Item`, `Control1`) confirmed against the Base App symbols before writing the extension — not guessed.
**Files affected:** `src/TableExtensions/ocpfItem.TableExt.al`, `src/PageExtensions/ocpfItemCard.PageExt.al`, `src/PageExtensions/ocpfItemList.PageExt.al`.
**Updated:** TDD (§8.3) and FRD (§7.7) — yes.

## Issue 09F-07 — IP Entitlement `Entry No.` → `No.` (Code20, No. Series) + new IP App Setup table/page
**Problem:** `"Entry No."` (autoincrement Integer) wasn't the preferred key design; needed to become a No. Series-driven `"No."` (Code20), which in turn requires a Setup table to hold the series code.
**Root cause:** A-4 (DEFINE-phase) deliberately deferred a Setup table/number series for the *whole app* to avoid that dependency in the first cut. This request scopes it down to just the one field that needs it, rather than reopening A-4 wholesale.
**Resolution:**
- Verified the **current, non-deprecated** No. Series implementation against the Business Foundation symbols (not assumed): `codeunit "No. Series"` (310) + `table "No. Series"` (308), namespace `Microsoft.Foundation.NoSeries` — replacing the older `NoSeriesManagement`. Exact signature confirmed: `GetNextNo(NoSeriesCode: Code[20]): Code[20]`.
- Added `app.json` dependency on Business Foundation (Microsoft, `f3552374-a1f2-4356-848e-196002525837`, `28.4.53241.53312`) — referencing a codeunit/table from a module not previously depended on requires a declared dependency, not just resolvable symbols.
- New `table 80319 "ocpf IP App Setup"` — singleton, PK `"Primary Key"` (Code[10]), matching the convention confirmed against `Sales & Receivables Setup`/`Marketing Setup` (not assumed); one field, `"IP Entitlement Nos."` (Code20, `TableRelation = "No. Series".Code`).
- New `page 80322 "ocpf IP App Setup"` — Card, `UsageCategory = Administration`, `InsertAllowed/DeleteAllowed = false`, `OnOpenPage` inserts the singleton record if missing (standard Setup-page pattern).
- `ocpf IP Entitlement`: field 1 renamed `"Entry No."` (Integer, AutoIncrement) → `"No."` (Code[20]); `OnInsert` trigger assigns it via `NoSeries.GetNextNo(IPAppSetup."IP Entitlement Nos.")` when blank; PK key renamed to match. Minimal-viable pattern — mandatory series, no "Manual Nos." override (candidate for `Roadmap.md`, not built).
- Both permission sets extended to cover the new Setup table (`PerTenantExtensionCop`'s `PTE0004` requires it — confirmed by compiling, not assumed).
- Renamed throughout: pages 80313/80314 (column/field `No.`, `Editable = false`), API 80318 (`entryNo`→`no`).
**Files affected:** `src/Tables/ocpfIPAppSetup.Table.al` (new), `src/Pages/ocpfIPAppSetup.Page.al` (new), `src/Tables/ocpfIPEntitlement.Table.al`, `src/Pages/ocpfIPEntitlements.Page.al`, `src/Pages/ocpfIPEntitlementCard.Page.al`, `src/API/ocpfIPEntitlementAPI.Page.al`, `src/PermissionSets/OCPFIPTrackRead.PermissionSet.al`, `src/PermissionSets/OCPFIPTrackEdit.PermissionSet.al`, `app.json`.
**Updated:** TDD (§1.4, §2, §7.4 R-3, §8.1, §8.2, §9) and FRD (§1 "out of scope", §7.4, §7.6) — yes.

## Issue 09F-08 — Entitlement lookup from IP App and Customer pages
**Problem:** No way to see, from an IP App or a Customer, which of the other side it's associated with — analogous to BC's Item↔Vendor "Item Vendor Catalog" pattern, per direct request.
**Root cause:** New requirement, not previously scoped.
**Resolution:** IP App List (80307) and Card (80308) — own pages, edited directly — each gain an `action(Entitlements)` under `area(Navigation)`, `RunObject = page "ocpf IP Entitlements"`, `RunPageLink = "IP App Code" = field(Code)`. Customer Card (80326) and List (80327) — base-app pages, via `pageextension` — each gain an `action("IP Entitlements")` the same way, `RunPageLink = "Customer No." = field("No.")`. `addlast(Navigation)` targets the page's `area(Navigation)` directly rather than naming one of the base page's existing action groups — a more stable anchor across BC versions.
**Files affected:** `src/Pages/ocpfIPApps.Page.al`, `src/Pages/ocpfIPAppCard.Page.al`, `src/PageExtensions/ocpfCustomerCard.PageExt.al` (new), `src/PageExtensions/ocpfCustomerList.PageExt.al` (new).
**Updated:** TDD (§8.1, §8.3, §10) and FRD (§7.8) — yes.

## Issue 09F-09 — Page extensions failed to resolve their base page (found by compiling)
**Problem:** All four new page extensions (Item Card/List, Customer Card/List) failed with `AL0247: The target Page '<Name>' for the extension object is not found`, cascading into `AL0118`/`AL0186` on `Rec`.
**Root cause:** The base pages (Item Card, Item List, Customer Card, Customer List) carry no namespace prefix themselves, which is easy to mistake for "no `using` needed." In fact the extension still needs `using Microsoft.Inventory.Item;` / `using Microsoft.Sales.Customer;` to resolve the target — an easy trap, not caught by pre-flight (which doesn't model extension-target resolution) and only found by the actual compile.
**Resolution:** Added the missing `using` directive to all four files. Written into TDD §4 as an explicit warning for future extension objects.
**Files affected:** `src/PageExtensions/ocpfItemCard.PageExt.al`, `src/PageExtensions/ocpfItemList.PageExt.al`, `src/PageExtensions/ocpfCustomerCard.PageExt.al`, `src/PageExtensions/ocpfCustomerList.PageExt.al`.
**Updated:** TDD (§4, §12) — yes.

## Issue 09F-10 — `Image = Entity` is not a valid action image (found by compiling)
**Problem:** `warning AL0482: The image Entity is not valid in this context` on all four new navigation actions.
**Root cause:** Assumed `Entity` was a valid `PageActionImage` value without checking; it either doesn't exist or isn't valid for this control type in this AL version.
**Resolution:** Changed to `Image = List` (a well-established, always-valid choice for a "view related records" action) on all four. Written into the TDD §5.4 extension template so future actions default to a known-good image.
**Files affected:** `src/Pages/ocpfIPApps.Page.al`, `src/Pages/ocpfIPAppCard.Page.al`, `src/PageExtensions/ocpfCustomerCard.PageExt.al`, `src/PageExtensions/ocpfCustomerList.PageExt.al`.
**Updated:** TDD (§5.4) — yes.

**Final verification:** `scripts/preflight.py` (26 rules, extended to recognize `tableextension`/
`pageextension` as distinct kinds — see Note below) → 0 failures across 30 files.
`scripts/build.sh` → **0 errors / 0 warnings**, 4 pre-accepted info (unchanged `AW0006`).

**Note — pre-flight tooling gap found and fixed:** `scripts/preflight.py`'s object-declaration
regex and `OBJ_KINDS` map didn't distinguish `tableextension`/`pageextension` from `table`/`page`,
which would have made rule FILE-01 expect the wrong filename suffix (`.Table.al` instead of
`.TableExt.al`). Fixed before running pre-flight on this batch, not after a false failure.

---

## Issue 09F-11 — IP Entitlement Unit Price should auto-populate but stay editable

**Problem:** `"Unit Price"` on IP Entitlement was a `FlowField` — always read-only, always live-recalculated. AJ wanted it to auto-populate *and* remain user-editable, which a `FlowField` cannot do by definition.
**Root cause:** DESIGN (TDD §7.4, 2026-09-04) reached for `FlowField` because the value genuinely is derived from other fields — but didn't separately ask "should this be overridable?", conflating "computed" with "read-only." R-1's Expiration Date already used the correct pattern for exactly this kind of field; Unit Price didn't follow it.
**Resolution:** Converted field 13 from a `FlowField` to a real stored `Decimal` (`MinValue = 0`), suggested by new rule R-4 — an `OnValidate`-triggered lookup against `ocpf IP App Price` (App + Edition + Billing Period + blank Currency), called from IP App Code's, Edition Code's and Billing Period's `OnValidate`, mirroring R-1's structure. Removed `Editable = false` from the table field, the Entitlement List/Card ToolTips (updated to describe "suggested, editable"), and the API page's `unitPrice` field.
**Known limitation (documented, not fixed):** `0` is used as the "not yet suggested" sentinel. A deliberately-entered `0` (e.g. a Gratis entitlement) is indistinguishable from "unset" and may be silently re-suggested if App, Edition or Billing Period changes again afterward. Accepted rather than adding a separate "user has touched this" flag for one field.
**Generalized into the runbook** (not just this app): Step 03's "Per-field spec" now requires deciding explicitly, per field, between a read-only `FlowField` and a stored-and-suggested field — see `BC_App_Build_Routine_Agent.md`.
**Files affected:** `src/Tables/ocpfIPEntitlement.Table.al`, `src/Pages/ocpfIPEntitlements.Page.al`, `src/Pages/ocpfIPEntitlementCard.Page.al`, `src/API/ocpfIPEntitlementAPI.Page.al`.
**Updated:** TDD (§7.4, new rule R-4) and FRD (§7.4) — yes.

**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, same 4 pre-accepted info.

## Issue 09F-12 — Deletion controls for the objects added in 09F-06/09F-07

**Problem:** "What deletion controls should we have?" — raised as a question, not a decision. Checked against the two objects 09F-06/09F-07 added: `ocpf IP App Setup` (no table-level guard, only page-level `DeleteAllowed = false`) and the Item↔IP App tie (`ocpf IP App`'s `OnDelete` guard didn't check for referencing Items).
**Root cause:** Both are gaps left by 09F-06/09F-07, not fresh judgment calls — FRD design rule 7 ("deleting a parent that has children is blocked with a clean error") already sets the app's policy; the new objects just weren't checked against it when added. This is exactly the class of gap the new Step 04 checklist item (below) exists to catch going forward.
**Resolution (closed without a separate decision — both are consistency fixes, not new tradeoffs):**
- `ocpf IP App"`'s `OnDelete` guard now also blocks when any `Item` references it via the new `"IP App"` field (`using Microsoft.Inventory.Item;` added).
- `ocpf IP App Setup` (a singleton) now has an unconditional `OnDelete` error — `DeleteAllowed = false` on the page only stops UI deletion, not a direct `Delete()` call from code or a future API page.
**Alternative considered and rejected:** cascading the delete (null out `Item."IP App"` instead of blocking) — rejected as inconsistent with how every other reference in this app behaves (block, not cascade). Reversible if AJ prefers cascade-clear instead.
**Files affected:** `src/Tables/ocpfIPApp.Table.al`, `src/Tables/ocpfIPAppSetup.Table.al`.
**Updated:** TDD (§7.1, §10) — yes.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, same 4 pre-accepted info.

## Framework additions (2026-09-05, not app-specific) — see `BC_App_Build_Routine_Agent.md`

Three gaps in the runbook itself, surfaced by this session's questions, fixed at the source
rather than only in this project's docs:

1. **Computed-field pattern (Step 03, per-field spec):** distinguish a `FlowField` (always
   read-only, live-recalculated) from a stored field seeded by a trigger that suggests a value
   but lets the user override it — decided explicitly per field, not defaulted. Directly
   motivated by 09F-11.
2. **Deletion-controls checklist item (Step 04):** every entity's deletion behavior must be
   explicitly decided and stated, *including* re-checking fields on other tables (own or
   extended standard tables) that reference it by `TableRelation` whenever one is added. Not
   previously required; the new IP App Setup table and the Item `"IP App"` tie (09F-06/09F-07)
   are exactly the kind of addition this would have caught sooner.
3. **Mermaid schema diagram (Step 12):** `Documentation.md` must include a Mermaid `erDiagram`
   covering every table this app owns *and* every standard/base table it touches via
   `TableRelation`, `tableextension`, or a `pageextension`'s `RunPageLink` — generated from the
   actual objects, not from memory.

No ChangeLog issue number — these aren't a deviation from this app's FRD/TDD, they're a process
improvement to the framework all future apps built with it will inherit.

## Framework addition (2026-09-05, second pass) — Project Memory made prescriptive and in-repo

Verified (grepped, not recalled) that the previous session's "Session Memory" section did *not*
actually require a file named `Memory.md`, or any specific in-repo file — it only said "if the
agent has a persistent memory capability, use it," which meant a future project's continuity
depended on whichever agent happened to run it, and lived outside the repo entirely (Claude
Code's own memory store, keyed to one machine's file path — invisible to git, a teammate, or any
other tool that opens the repo).

**Resolution:** rewrote the section as **"Project Memory — `docs/ProjectMemory.md` (required,
in-repo)"** — a committed, version-controlled artifact, not conditional on the executing agent's
own memory feature. Deliberately scoped as a short *anchor* (current phase, live-document
pointers, open decisions, one line per milestone), not a narrative — the "why" stays in
`ChangeLog.md`; duplicating it in a second document would create drift between two sources of
truth. An agent's own external memory (if any) may point at this file but must not duplicate it.
Also added `TestingFeedback`, `Roadmap` and `ProjectMemory` to the Operating Rules' canonical
required-documents list, which had never been updated when those two were created.

**Files affected:** `docs/ProjectMemory.md` (new, this project's own copy — see the file for
current state); Claude Code's own external memory note trimmed to a pointer, per the new rule.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, unchanged (doc-only change).

## Framework additions (2026-09-05, third pass) — named attribution, awaiting-name, BaseApp docs fallback, Step 01 kickoff questions

Four items, all originating from AJ's own review of the runbook (checking, not assuming, what
it actually says — the same discipline this framework has been built with throughout):

1. **Named attribution, not a role noun.** "Track Changes — the ChangeLog" now requires naming
   the actual person ("AJ decided X"), never "the human"/"the user" — a role-noun silently
   assumes exactly one contributor exists. Applied retroactively in this project: every
   ChangeLog and TDD occurrence of "the human"/"User"/"the user's" that attributed a decision to
   AJ specifically was renamed to "AJ" (occurrences referring to a future *end-user of the built
   app* — e.g. "until the user picks one," "remain user-editable" — were correctly left alone;
   those aren't AJ).
2. **"Awaiting: `<name>`" on every Open Decisions row.** Added to the "Project Memory" section —
   distinct from `git blame` (who last edited the line) because it's forward-looking (who the
   project is waiting on), not historical. Applied to all five rows in `docs/ProjectMemory.md`.
3. **BaseApp documentation as a symbol-file fallback.** Operating Rule 2 now names
   <https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/module/base-application>
   as where to look when a standard table/field/datatype isn't answerable from the downloaded
   `.alpackages` symbols (a module not included, or when browsing/discovering rather than
   already knowing what to grep for). The symbol file remains authoritative if the two disagree.
4. **Step 01 kickoff — ask, don't infer.** If Extension Name, Publisher, Use Namespace (y/n),
   Namespace, Localization or AL Object Prefix still carry placeholders, the agent must ask the
   human these five questions directly before writing anything — explicitly citing this
   project's own A-1 (publisher/prefix inferred from an email domain under time pressure, later
   walked back in 09F-05) as the cautionary example. This also **added a new parameter**, "Use
   Namespace (y/n)," to §1.1/§1.3 — AL namespaces are optional, and the intake sheet never had a
   way to say so; `Namespace` is N/A when the answer is `No`.

No ChangeLog issue number — process improvements to the framework, not a deviation from this
app's FRD/TDD. **Verification:** `scripts/build.sh` → 0 errors, 0 warnings, unchanged.

## Framework addition (2026-09-05, fourth pass) — Object ID range collected as a loop

**Problem:** AJ had two more kickoff-question additions in mind and forgot to include them
earlier: (1) Object ID ranges (Parameter 1.2) should be asked the same way as the five identity
questions — directly, not inferred — but as a *loop* rather than a single question, since a
project can have more than one range. (2) — folded into (1); AJ's message described one flow.
**Resolution:** Added to Step 01: for each range, ask the starting Object ID, ask the ending
Object ID, show the resulting range and its size, ask the human to confirm it, then ask "are
there additional ranges?" — repeating for every "yes" until "no." §1.2's table was restructured
to match: it previously had a fixed shape (one Primary row + at most one optional Additional
row), which couldn't represent more than two ranges. Now: Primary (first confirmed range) +
Additional allocation 1..N (one row per further "yes"), no fixed limit.
**Files affected:** `BC_App_Build_Routine_Agent.md` §01 Actions, §1.2 table + worked example.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, unchanged (doc-only change).

## Framework addition (2026-09-05, fifth pass) — package naming, packaging/versioning judgment

**Problem:** `out/app.app` was a hardcoded, uninformative package filename. Nothing in the
framework said when to *offer* rebuilding the package as work progresses, how to decide a
version bump, or to push back on a premature ask for either.
**Resolution:** New ALL ALONG section, "Packaging & Versioning":
- **Naming, fixed:** `<ExtensionName, spaces → underscores>_<version>.app`, read from `app.json`
  at build time — e.g. `IP_Tracking_1.0.0.0.app`. `scripts/build.sh` now derives `APP_NAME`/
  `APP_VERSION` from `app.json` via `python3 -c "import json; ..."` rather than a fixed string.
- **When to offer repackaging:** the same granularity that already warrants a ChangeLog entry
  and its own commit — a batch, feedback round, or fix that compiles 0/0 and is a meaningful,
  testable unit. Not every trivial edit.
- **Version-bump policy** (Major/breaking, Minor/new features, Build/repackage-no-new-function,
  Revision/hotfix) — always proposed with reasoning and confirmed before `app.json` changes,
  never bumped silently.
- **Pushback rule:** a premature packaging ask (known errors, unfinished batch) or a
  disproportionate bump request must be named plainly, not silently complied with.
**Files affected:** `BC_App_Build_Routine_Agent.md` (Step 09 Actions + new ALL ALONG section);
`scripts/build.sh`.
**Verification:** `scripts/build.sh` → produces `out/IP_Tracking_1.0.0.0.app`; 0 errors, 0
warnings, unchanged diagnostics.

## Version 1.0.0.0 → 1.1.0.0 (Minor) — first repackage under the new policy

**Proposed:** Minor bump. Reasoning: everything since the original BUILD-complete package
(itself never versioned past `1.0.0.0`) has been backward-compatible additions — the entire 09F
feedback batch (12 issues: enum values, conditional visibility, a removed field, the full
publisher/prefix/namespace rename, the Item and Customer ties, the No. Series-driven Entitlement
`No.` + new Setup table, the Unit Price FlowField→stored conversion, two deletion-control fixes)
— no breaking change, no mere repackage-with-no-function, no single hotfix. That's squarely
"new features, backward-compatible" — Minor, not Major/Build/Revision.
**Confirmed by AJ.**
**Resolution:** `app.json` `version`: `1.0.0.0` → `1.1.0.0`. Repackaged.
**Files affected:** `app.json`.
**Verification:** `scripts/build.sh` → `out/IP_Tracking_1.1.0.0.app`, 0 errors, 0 warnings, same
4 pre-accepted info.

## Incident — previous package deleted; recovered by rebuild, not undelete

**Problem:** Before both the 1.0.0.0 and 1.1.0.0 builds above, `rm -f out/*.app` was run
manually as a pre-build habit — out of an instinct to "make sure we see the new file cleanly,"
not because `scripts/build.sh` itself deletes anything (confirmed: it doesn't). This deleted
`out/IP_Tracking_1.0.0.0.app`. AJ caught it and asked for the file back.
**Root cause:** An agent habit, not a script defect. `out/` is git-ignored (a build artifact
directory), so nothing lost there is recoverable from git history, and `rm` on macOS does not
use the Trash — the original bytes are genuinely gone, permanently.
**Resolution:** Recovered functionally, not literally: `app.json`'s version was temporarily set
back to `1.0.0.0` (the only thing that had changed since that package was built), rebuilt to
regenerate `out/IP_Tracking_1.0.0.0.app`, then restored to `1.1.0.0` and rebuilt again. `git
diff` confirmed the working tree matched the committed `1.1.0.0` state exactly before and after.
Both packages now sit in `out/`.
**Generalized into the runbook (not just this project):** "Packaging & Versioning" now states
**never delete a previous package** — not by the build script, not by the agent running it, not
as a "tidying" habit before a build — citing this exact incident as the cautionary example, the
same way Step 01's "ask, don't infer" rule cites the DSW/`ipt`→OnlyCopilotFans/`ocpf` rename.
**Files affected:** none (no code change — `app.json` ended exactly where it started).
**Updated:** `BC_App_Build_Routine_Agent.md` ("Packaging & Versioning") — yes.
**Verification:** `scripts/build.sh` → both `out/IP_Tracking_1.0.0.0.app` and
`out/IP_Tracking_1.1.0.0.app` present; 0 errors, 0 warnings.

## Issue 09F-13 — New Entitlement from a cross-reference action fell outside its own filter

**Problem:** Creating a new IP Entitlement from the "Entitlements" action on IP App List/Card
(80307/80308) or the "IP Entitlements" action on Customer Card/List (pageextensions 80326/80327)
failed — AJ's words: "what I was creating went outside the filtered view." The new record didn't
inherit the field the target list was filtered on (IP App Code or Customer No.), so it fell
outside that very filter and appeared to vanish.
**Root cause:** `RunPageLink` filters the target page; it does not, by itself, default a new
record's field to the filtered value. That default has to be set explicitly.
**Resolution:** Rule R-5 (TDD §7.4) — `OnNewRecord` on page 80313 "ocpf IP Entitlements" reads
`Rec.GetFilter` on both "IP App Code" and "Customer No." and applies whichever is active to the
new record via `Validate`. One trigger on the shared target page fixes both entry points, since
both cross-reference actions funnel through this same List page.
**Files affected:** `src/Pages/ocpfIPEntitlements.Page.al`.
**Updated:** TDD (§7.4, new rule R-5) and FRD (§7.4) — yes.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, same 4 pre-accepted info.

## Issue 09F-14 — New field: License Key (Text80)

**Problem:** No field to record a license key against an entitlement.
**Root cause:** New requirement; not previously scoped. Table wasn't specified in the request.
**Resolution:** Added field 14 `"License Key"` (Text[80], plain, no validation/default) to
`ocpf IP Entitlement` — reasoned to be the per-customer register, not the catalog tables
(`IP App`/`IP App Edition`), matching how a license key is issued per purchase, not per product
definition; also the natural attachment point for the License Key Generator idea (Roadmap R-4).
Shown on the Card and the API; **deliberately not shown on the List** — a license key isn't
grid-appropriate. Flagged for confirmation since the table wasn't specified in the request.
**Files affected:** `src/Tables/ocpfIPEntitlement.Table.al`, `src/Pages/ocpfIPEntitlementCard.Page.al`, `src/API/ocpfIPEntitlementAPI.Page.al`.
**Updated:** TDD (§7.4) and FRD (§7.4) — yes.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, same 4 pre-accepted info.

## Version 1.1.0.0 → 1.2.0.0 (Minor) — self-correction on the bump level

**Proposed (then corrected):** Initially suggested Build or Revision for this batch (09F-13
bugfix + 09F-14 new field), reasoning it was "mostly a bugfix." That was a misapplication of our
own policy — "Packaging & Versioning" states plainly: "**Minor** — new features, **fields**, or
objects added in a backward-compatible way." 09F-14 added a field; a bundled bugfix doesn't
downgrade that. Self-corrected before acting on it, not after.
**Confirmed by AJ** ("yes.") — to the corrected Minor bump.
**Resolution:** `app.json` `version`: `1.1.0.0` → `1.2.0.0`. Repackaged.
**Files affected:** `app.json`.
**Verification:** `scripts/build.sh` → `out/IP_Tracking_1.2.0.0.app`; 0 errors, 0 warnings, same
4 pre-accepted info. All three packages (`1.0.0.0`, `1.1.0.0`, `1.2.0.0`) confirmed present in
`out/` — none deleted.

## Superseded banner added to the four point-in-time records

**Problem:** AJ opened `docs/Packaging.md` and asked why it still showed `DSW` as publisher —
checked git history: created once (`08fac06`, 2026-09-04 23:32), never touched since, and the
`DSW`→`OnlyCopilotFans` rename (09F-05) landed the *next day* (`ad228aa`, 2026-09-05 11:36). Not
a bug — the "point-in-time record, not a living spec" policy for `SanityCheck.md`/
`GapAnalysis.md`/`BuildPlan.md`/`Packaging.md` was established earlier this session — but the
policy had a real gap: unlike `ChangeLog.md` (obviously a dated log), these four read as
✔-checklists of current fact, not snapshots, so the historical framing is easy to miss.
`Packaging.md`'s §5 "remaining work" list was also a second, now-stale copy of what
`docs/ProjectMemory.md`'s "Open Decisions"/"Next" sections already track live — `ProjectMemory.md`
didn't exist yet when Packaging.md was written.
**Resolution:** Added a short blockquote banner at the top of all four documents pointing to
`docs/ProjectMemory.md` for current status — content of the documents themselves left untouched
(rewriting old records to match current state would falsify the history, same reasoning as
leaving `ChangeLog.md`'s own historical `DSW` mentions alone).
**Files affected:** `docs/SanityCheck.md`, `docs/GapAnalysis.md`, `docs/BuildPlan.md`,
`docs/Packaging.md`.
**Updated:** none of TDD/FRD — this is a documentation-hygiene fix, not a design change.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, unchanged (doc-only change).

## Issue 09F-13 (revised) — first fix insufficient; corrected by mirroring Base App exactly

**Problem:** AJ reported the 09F-13 fix from the previous session "still broken in v1.2.0.0,"
from both the IP App side and the Customer side, and asked for it to be implemented like Base
App's real "Item Vendor Catalog." The original fix — an `OnNewRecord` trigger on the shared
general list (page 80313) reading `Rec.GetFilter` — did not resolve the defect in practice.
**Root cause (found by checking the actual symbols, not guessing further):** `Microsoft_Base
Application`'s real Item Card action is:
```
Ven&dors { RunObject = 'Item Vendor Catalog'; RunPageLink = '"Item No." = field("No.")';
           RunPageView = 'sorting("Item No.")'; }
```
— the same `RunObject`/`RunPageLink` mechanism this project already used; that part was never
wrong. The actual difference: the target page ("Item Vendor Catalog") has **no `CardPageId`** —
new records are created and edited **inline**, never navigating to a separate Card page — and
the linking field (`"Item No."`) is simply **hidden** (`Visible = false`). Our shared target
page (80313) kept its `CardPageId`, routing "New" through a *separate* Card page object, which
broke the filter-to-default behavior the first fix relied on.
**Resolution:** Two new dedicated catalog pages, mirroring the verified pattern exactly:
- `page 80328 "ocpf IP App Entitlements"` — List, no `CardPageId`, `"IP App Code"` hidden. New
  target of the "Entitlements" action on 80307/80308.
- `page 80329 "ocpf Customer Entitlements"` — List, no `CardPageId`, `"Customer No."` hidden.
  New target of the "IP Entitlements" action on 80326/80327.
Both retain an `OnNewRecord`/`GetFilter` trigger for their one relevant field as
defense-in-depth — cheap and harmless — but the structural fix (no Card, field hidden) is what
actually matches the proven pattern. All four actions gained `RunPageView = sorting(...)`,
matching Base App. The general list (80313) is unchanged for its own direct/Tell-Me entry point;
its now-unnecessary `OnNewRecord` was removed since it's no longer a `RunPageLink` target.
**Files affected:** `src/Pages/ocpfIPAppEntitlements.Page.al` (new), `src/Pages/ocpfCustomerEntitlements.Page.al` (new), `src/Pages/ocpfIPEntitlements.Page.al` (trigger removed), `src/Pages/ocpfIPApps.Page.al`, `src/Pages/ocpfIPAppCard.Page.al`, `src/PageExtensions/ocpfCustomerCard.PageExt.al`, `src/PageExtensions/ocpfCustomerList.PageExt.al` (all four retargeted).
**Updated:** TDD (§2, §7.4 rule R-5 rewritten, §8.1, §8.3) and FRD (§7.4, §7.8) — yes.
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, 6 pre-accepted info (2 new `AW0006`
on the catalog pages — expected, they have no `UsageCategory`, matching Base App's own pages).

## Version 1.2.0.0 → 1.2.0.1 (Revision) — corrective fix, no new capability

**Proposed:** Revision, not Minor. Reasoning: the cross-reference navigation feature itself
already shipped (counted in the 1.2.0.0 Minor bump); this corrects a defect in it discovered
during AJ's own testing of that package. The two new page objects are implementation vehicles
for the fix, not new user-facing capability — matches our policy's Revision definition exactly:
"a small correction or hotfix discovered while testing a specific package, with no new features."
**Confirmed by AJ.**
**Resolution:** `app.json` `version`: `1.2.0.0` → `1.2.0.1`. Repackaged.
**Files affected:** `app.json`.
**Verification:** `scripts/build.sh` → `out/IP_Tracking_1.2.0.1.app`; 0 errors, 0 warnings, same
6 pre-accepted info. All four packages (`1.0.0.0`, `1.1.0.0`, `1.2.0.0`, `1.2.0.1`) confirmed
present in `out/` — none deleted.

## Step 09 — remainder skipped by instruction (deviation, logged per Operating Rule 7)

**What happened:** AJ published `1.2.0.1` to `v29Sandbox` and asked to proceed with Step 09's
remaining to-dos. Live testing was started via the BC MCP tools: `list_companies` returned
`CRONUS USA, Inc.` (default) and `My Company`; `bc_actions_search` was then run in both keyword
and semantic modes for the app's custom API entities. **Neither mode surfaced any of the four
custom API pages (80315–80318)** — only unrelated standard Base App actions matched. Before
concluding anything about the API surface, the next step was to check installation state via
the standard Extension Management list (`List_Extensions_PAG30002`) — at which point AJ
interrupted and instructed: skip the remainder of Step 09, move to Step 10.
**Status: Step 09 is NOT complete.** Not done: green-team tests (`$metadata`, collection read,
read by `SystemId`, create, update), red-team tests (invalid field, invalid key, delete a parent
with dependents, missing-permission call), and live permission-set verification. The unresolved
question of whether the custom APIs are actually discoverable/installed in that environment is
also still open — it was never established either way.
**Decision by:** AJ, explicitly. **Not an agent judgment call.**
**Files affected:** none.
**Updated:** neither TDD nor FRD — no design change; Step 09's exit gate simply remains unmet.

## Step 10 — Code Review complete (2 findings, both fixed)

Full record: `docs/CodeReview.md`. Twelve dimensions scanned across all 32 objects by executed
scans (not a read-through): dead code, `Rec.` prefix, duplicate/unused `using`, duplicate field
exposure, ToolTip consistency, obsolete references, required metadata, `DelayedInsert`/`Editable`
mutability, `Error()` label usage, permission-set completeness, and cross-batch template drift.
Ten came back clean. Two scan hits were investigated and dismissed as false positives (documented
in CodeReview §3 rather than silently dropped).

## Issue 10-01 — Late-batch drift: catalog pages omitted the `"No."` column
**Problem:** The general Entitlements list (80313) and Card (80314) show the No.-series `"No."`;
the two catalog pages added later in 09F-13 (80328/80329) did not — so a user creating an
entitlement inline from the IP App or Customer catalog couldn't see or reference the number just
assigned to it.
**Root cause:** The catalog pages were written fresh against the *cross-reference* requirement
rather than derived from the existing list's column set — classic late-batch drift. Invisible to
the compiler and to every pre-flight rule; only visible by diffing the batches against each other,
which is exactly Step 10's job.
**Resolution:** Added `"No."` (`Editable = false`, ToolTip identical to its use elsewhere) as the
first column on both 80328 and 80329.
**Files affected:** `src/Pages/ocpfIPAppEntitlements.Page.al`, `src/Pages/ocpfCustomerEntitlements.Page.al`.
**Updated:** TDD (§8.1 column lists) — yes.

## Issue 10-02 — Item extension field carried no `DataClassification`
**Problem:** `tableextension 80323 "ocpf Item"`'s `"IP App"` field declared `Caption`, `ToolTip`
and `TableRelation` but no `DataClassification`, so it defaulted to `ToBeClassified` — the only
unclassified field in the app.
**Root cause:** Every other field in this app inherits `CustomerContent` from a **table-level**
declaration on our own tables. A field added to *Microsoft's* `Item` table inherits nothing from
ours. Nothing caught it: valid AL (compiler and all three analyzers silent), and `preflight.py`'s
TAB-01 checks table-level `DataClassification` and doesn't run against `tableextension` objects
at all.
**Resolution:** `DataClassification = CustomerContent;` added to the field.
**Files affected:** `src/TableExtensions/ocpfItem.TableExt.al`.
**Updated:** TDD (§8.3) — yes.
**Rule-level follow-up (not yet done):** `preflight.py` could gain a rule requiring
`DataClassification` on every `tableextension` field, so this class of gap can't recur. Left as a
deliberate note rather than scope-creeping the review — raised in `ProjectMemory.md`'s open items.

**Verification after both fixes:** `scripts/build.sh` → 32 files, pre-flight 0 failures, compile
0 errors / 0 warnings, 6 pre-accepted info.

---

## Step 11 — Update Design Documents (complete)

**Outputs:** `docs/PostDevTDD.md` (new), `docs/FRD.md` (re-baselined).

`PostDevTDD.md` is the as-built reference: final identity, all 32 objects with their real
properties, the five business rules as implemented (R-1…R-5), a 16-row deviation table tracing
every difference from the original design back to its ChangeLog entry, and the known limitations
carried forward. **Generated from the code, not memory** — a new `scripts/extract_asbuilt.py`
parses `src/` and emits the object/field/relationship/API-map tables that were pasted in.

`FRD.md` re-baselined per the runbook's "fold in every implementation decision that diverged, even
where the implementation is better." Two genuinely stale statements were found and corrected —
neither would have been caught by reading the doc casually:
1. §8's FlowField NFR still cited `Unit Price` on page 80313 as a bounded list FlowField. It
   hasn't been a FlowField since 09F-11. Corrected to name the two that actually remain.
2. §9 still listed "Setup table, number series" as **out of scope**. They've been in scope and
   built since 09F-07. Corrected, with the genuinely-still-out-of-scope list restated.
Also added: as-built compile state (0/0 + 6 accepted infos), and an explicit note that the
"deployable to sandbox and production" NFR is **asserted, not demonstrated**, since Step 09's
verification was skipped.

## Step 12 — Document the Code (complete)

**Outputs:** `docs/Documentation.md`, `docs/HumanUnitTestScript.md`, `docs/Deployment.md`.

- **`Documentation.md`** — consumer/integration reference. All four API field tables generated by
  `extract_asbuilt.py` straight from `src/`, so they cannot drift from the AL. Includes the
  **Mermaid `erDiagram`** required by the runbook's Step 12 rule, covering all five owned tables
  *plus* the four standard tables this extension touches (`Item`, `Customer`, `Currency`,
  `No. Series`), with cardinality and which side is Microsoft's. Also: auth/URL patterns,
  `$filter`/`$select`/create/update/delete examples, integration patterns, an 8-row limitations
  table, and a troubleshooting table.
- **`HumanUnitTestScript.md`** — 6 parts, 40 numbered steps, executable by a non-developer, with
  a Result column and sign-off block. Parts D and F are the red-team cases. **Carries an explicit
  banner that these tests have never been run** — Step 09 was skipped, so this is the
  specification of what must pass, not evidence that it did.
- **`Deployment.md`** — install, required post-install No. Series configuration, verification
  checklist, upgrade, uninstall. **Closes GA-01 / Issue 08-01**: §4 documents the base BC
  permissions consumers need beyond this extension's own two sets (`D365 BASIC`, Customer read,
  Item write where applicable, No. Series read) with a suggested role mapping — the open item
  carried since Step 08. Also records the unsigned-off `resourceExposurePolicy` (source ships
  inside the package) and the unresolved `v29Sandbox` version question.

**Exit gate (Step 12):** reference generated from actual code ✔; test script executable by a
non-developer ✔; **app ready for user acceptance testing — with the caveat that no live
verification has been performed**. Dev Manager review: outstanding (AJ).

**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, 6 pre-accepted info (unchanged).

---

## Step 12 correction + three framework rules (2026-09-05)

**Problem:** AJ asked "I see a post-dev TDD but no post-dev FRD?" Checking Step 11's actual text
confirmed there is deliberately no `PostDevFRD.md` — outputs are `PostDevTDD.md` plus an
**updated `FRD.md` in place**. So that was followed correctly. But checking Step 12's text at the
same time surfaced a **genuine miss**: its outputs list *four* documents — `Documentation.md`,
`HumanUnitTestScript.md`, **user guide**, `Deployment.md` — and only three were produced. The user
guide had been silently folded into `Documentation.md`, which is scoped as the integration/API
reference for developers, a different audience entirely. Caught by AJ, not by me.

**Resolutions:**
1. **`docs/UserGuide.md` written** — the missing Step 12 deliverable. End-user Markdown: what the
   app is for, the five screens, first-time setup, adding products/editions/prices, recording an
   entitlement from either direction, the two self-filling fields explained, a "when something is
   refused" table mapping each guard message to what to do, and who-can-do-what. No API content.
2. **Runbook Step 12 tightened** so this can't recur: the action now names `UserGuide.md`
   explicitly, states it is *a separate document from `Documentation.md` and must not be folded
   into it*, spells out the audience difference, and the Outputs line says "Four documents — check
   all four exist before claiming the step is complete."
3. **Runbook Step 11 now explains the FRD/TDD asymmetry** rather than just stating the outputs —
   why the TDD gets a new file (the plan-vs-built gap is information; the original is the artifact
   the code came from) and the FRD is updated in place (one current answer; a stale second copy
   misleads the next planner). It also now **requires a pointer to the pre-BUILD FRD** in the FRD's
   own header, since that asymmetry's one real cost is discoverability.
4. **`docs/FRD.md` gained that pointer** — `git show 3e32f4f:docs/FRD.md` for the pre-BUILD
   baseline, plus how to list every revision.
5. **New Operating Rule 6a — ask decisions in a selectable options box, not in prose.** AJ's
   feedback: a decision written as a paragraph of chat reads like the agent finished and is idling,
   so the project stalls waiting on an answer nobody realised was owed. The rule requires the
   harness's interactive multiple-choice mechanism for *decisions*, recommended option first —
   and explicitly forbids using it for ordinary progress (finishing a step, reporting a clean
   compile), because over-using it makes it noise.

**Files affected:** `docs/UserGuide.md` (new), `docs/FRD.md`, `BC_App_Build_Routine_Agent.md`
(Operating Rules, Step 11, Step 12).
**Verification:** `scripts/build.sh` → 0 errors, 0 warnings, 6 pre-accepted info (docs-only change).

---

## Issue 12-01 — The Mermaid schema diagram never rendered

**Problem:** AJ asked whether the runbook required a Mermaid schema. It does (Step 12), and one
*was* written into `Documentation.md` §2 — but on actually testing it, it failed to parse:
`Parse error on line 24 … Expecting 'ATTRIBUTE_WORD', got 'ATTRIBUTE_KEY'`. It had never rendered
anywhere.
**Root cause:** four composite-key attributes were written as `PK_FK`. Mermaid's `erDiagram`
accepts `PK`, `FK`, `UK`, or comma-separated (`PK,FK`) — `PK_FK` is not a valid token. The deeper
cause is process, not syntax: the diagram was written and shipped **without ever being rendered**.
Markdown stores an invalid diagram happily — it looks correct in the source and only fails at the
point someone views it — so nothing in the build, the pre-flight, or the compile could catch it.
I had even flagged "haven't seen it rendered" in the Step 12 handover and then did not go check.
**Resolution:** `PK_FK` → `PK,FK` (4 occurrences). Verified properly this time: extracted the
fenced block and rendered it with `@mermaid-js/mermaid-cli` → a 164 KB SVG containing all nine
entities (5 owned + `Item`, `Customer`, `Currency`, `No. Series`) and all relationship labels.
**Generalized into the runbook:** Step 12 now carries a separate action — *render the diagram to
prove it parses; never ship one you have not seen render* — with the command and this exact
`PK_FK` failure cited as the example.
**Files affected:** `docs/Documentation.md`, `BC_App_Build_Routine_Agent.md` (Step 12).
**Verification:** diagram renders clean; `scripts/build.sh` → 0 errors, 0 warnings (docs-only).

---

## Batch deviations
*(none — see individual batch/issue entries above; every deviation is logged at the point it occurred)*
