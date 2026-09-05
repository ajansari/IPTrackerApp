# Code Review — IP Tracking

*Runbook phase: PROVE / Step 10 "Code Review". Date: 2026-09-05. Reviewed at version `1.2.0.1`, 32 objects.*
*Status: **complete — 2 findings, both fixed; exit gate met**.*

> **Point-in-time record — not a living spec.** Reflects the codebase as of the date above.
> For current status, read `docs/ProjectMemory.md` first.

**Inputs:** the full built extension (`src/`, 32 objects), `docs/TDD.md`, the runbook's inline
Standards summaries (Parts 3, 4, 6, 9, 11 — the companion `AL_PTE_Development_Standards_UNIFIED.md`
is still not present in the repo, a limitation logged since Step 01).

**Method — executed scans, not a read-through.** Every dimension below was checked by running a
scan across all 32 objects (regex/AST-ish extraction over `src/`, plus the 26-rule `preflight.py`
and a full analyzer compile), not by reading files and forming an impression. Where a scan
produced hits, each hit was opened and judged individually — two were false positives from the
scan's own grouping, and both are recorded here rather than silently dropped.

---

## 1. Findings by dimension

| # | Dimension | Result |
|---|---|---|
| 1 | Dead code — `// TODO`, commented-out AL, empty triggers | **Clean.** Zero hits across all 32 objects |
| 2 | `Rec.` prefix everywhere (`NoImplicitWith`) | **Clean.** No unqualified field reference in any code block |
| 3 | Duplicate `using` directives | **Clean.** None |
| 4 | Unused `using` directives | **Clean.** Each of the 4 namespaces used in the file that declares it |
| 5 | Duplicate field exposure within a page | **Clean** — 1 scan hit, false positive (see §3) |
| 6 | ToolTip consistency for the same field | **Clean** — 6 scan hits, all false positives (see §3) |
| 7 | Obsolete references (`ObsoleteState` Pending/Removed) | **Clean.** `preflight.py` SYM-02 verifies every referenced standard field against the symbol files on every run; passes |
| 8 | Required metadata (Caption / ToolTip / ApplicationArea / API properties) | **Clean.** `preflight.py` TAB-01/02/03, PAGE-01/02/03 cover these; 32 files, 0 failures |
| 9 | `DelayedInsert` / `Editable` per mutability | **Clean.** All 4 API pages: page-level `Editable` count = 0, `DelayedInsert = true` — exactly one of the pair, as required. Field-level `Editable = false` appears only on FlowFields, `SystemId`/`SystemModifiedAt`, and the No.-series `"No."` — all correct |
| 10 | `Error()` uses `Label`, never a hardcoded string | **Clean.** All 3 `Error()` calls use declared `Label` variables with `Comment` placeholders |
| 11 | Permission set completeness | **Clean.** All 5 app tables covered in both Read (R) and Edit (IMD) sets — verified by diffing the table list against the permission set contents |
| 12 | Template/structural consistency across batches | **2 findings — CR-01, CR-02 (§2)** |

---

## 2. Findings requiring a fix — both applied

### CR-01 — Late-batch drift: catalog pages omitted the `"No."` column *(severity: low)*
**Found by:** column-set diff of the three pages over `ocpf IP Entitlement`.
```
ocpfIPEntitlements      "No." "Customer No." "Customer Name" "IP App Code" ...
ocpfIPAppEntitlements         "IP App Code" "Customer No." "Customer Name" ...   <- no "No."
ocpfCustomerEntitlements      "Customer No." "IP App Code" ...                   <- no "No."
```
The general list (80313) and the Card (80314) both show the No.-series `"No."`; the two catalog
pages added later in 09F-13 did not. A user creating an entitlement inline from the IP App or
Customer catalog could not see or reference the number just assigned to it. This is precisely the
"early and late batches drift — normalize" case Step 10 exists to catch: not a compiler problem,
not a pre-flight rule violation, only visible by comparing the batches against each other.
**Fix applied:** added `"No."` (`Editable = false`, same ToolTip as elsewhere) as the first column
on both 80328 and 80329.
**Note on the Base App comparison:** "Item Vendor Catalog" shows no equivalent column, but that's
because table `Item Vendor` has no `No.` field at all (composite key) — not a precedent for
omitting one that exists.

### CR-02 — Extension field carried no `DataClassification` *(severity: medium)*
**Found by:** property matrix across all objects.
`tableextension 80323 "ocpf Item"`'s new `"IP App"` field declared `Caption`, `ToolTip` and
`TableRelation` but no `DataClassification`. Every other field in this app is `CustomerContent`
— but via a **table-level** declaration on our own tables. A field added to *Microsoft's* `Item`
table inherits nothing from ours, so it silently defaults to `ToBeClassified` and would show as
unclassified in data-classification reporting.
**Why nothing caught it:** the compiler and all three analyzers are silent on this (it's valid AL);
`preflight.py`'s TAB-01 checks table-level `DataClassification` and doesn't run against
`tableextension` objects at all. Compiler-clean but standards-inconsistent — exactly the gap a
human-level review is for.
**Fix applied:** `DataClassification = CustomerContent;` added to the field.

---

## 3. Scan hits investigated and dismissed (recorded, not silently dropped)

- **Duplicate field exposure on `ocpfIPAppCard`** — the scan flagged `field("Code"` three times.
  Lines 57 and 63 are `SubPageLink = "IP App Code" = field("Code");` — the AL syntax for
  *referencing a parent field*, not a field control. Only one actual control. False positive from
  the regex, not a defect.
- **ToolTip "inconsistency" on 6 fields** — the first scan grouped by field *name* across all
  pages, so `"Description"` on `IP App` vs on `IP App Edition`, `"Unit Price"` on `IP App Price`
  vs on `IP Entitlement`, etc. appeared to conflict. Re-run grouped by **(SourceTable, field)**:
  **zero** genuine inconsistencies — every field's ToolTip is identical everywhere the same table
  exposes it, and different where the table differs, which is correct.

## 4. Deliberate patterns confirmed as intentional (no action)

- **`ApplicationArea = All` at both page and field level** — redundant in AL, but required
  explicitly by FRD design rule 3. Kept.
- **6 × `AW0006` info** — 4 Card pages plus the 2 catalog pages, none of which carry
  `UsageCategory`. Pre-accepted at SanityCheck SC-07; the catalog pages match Base App's own
  equivalents, which also have no `UsageCategory` (they're reached only via `RunObject`).
- **Two near-identical catalog pages (80328/80329)** — "more complex than needed?" No: Base App
  carries three near-identical pages over table `Item Vendor` for exactly this reason (one per
  navigation direction, each hiding its own linking field). Justified duplication.

---

## 5. Exit gate

| Condition | Status |
|---|---|
| All critical findings resolved | **Met** — no critical findings; both (low/medium) fixed |
| Dead-code scan 100% clean across every file | **Met** — zero TODOs, commented-out AL, or empty triggers |
| No obsolete references remain | **Met** — SYM-02 verifies against symbols on every pre-flight run |

**Verification after fixes:** `scripts/build.sh` → 32 files, pre-flight 0 failures, compile
**0 errors / 0 warnings**, 6 pre-accepted info.

**Next:** Step 11 (Update Design Documents — `PostDevTDD.md` as-built + FRD baseline refresh),
then Step 12 (Document the Code). Step 09's remaining live tests were skipped by AJ's explicit
instruction — see `ChangeLog.md`.
