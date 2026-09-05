# Build Plan — IP Tracking

*Runbook phase: BUILD / Step 05 "Plan the Code". Date: 2026-09-04. Status: **complete — exit gate met, ready for Step 06**.*

> **Point-in-time record — not a living spec.** This reflects project state as of the date
> above (e.g. publisher/prefix may since have changed — see `ChangeLog.md`). For current
> status, read `docs/ProjectMemory.md` first.

**Inputs:** `docs/TDD.md` (§2 module grouping, §3 batch plan, §4.1 file naming), `docs/ObjectRegister.md`, `docs/SanityCheck.md`.
**Outputs:** ordered batch plan (§2), project scaffold (§1), pre-flight validation script (§3), build command (§4).

---

## 1. Project scaffold

Single functional module, so objects are grouped by type. Folder names match the object-type
suffix in the file-naming convention (TDD §4.1), which keeps `iptIPApp.Table.al` in `src/Tables/`
without a second rule to remember.

```
IPTrackerApp/                   (folder renamed from ANZProject, 2026-09-05)
├── app.json                    runtime 17.0, platform/application 28.0.0.0,
│                               idRanges 80300-80339, features ["NoImplicitWith"]
├── .gitignore                  out/, *.app (except .alpackages), symbol cache, .DS_Store
├── .vscode/
│   ├── launch.json             Microsoft cloud sandbox → environment v29Sandbox
│   └── settings.json           CodeCop + UICop + PerTenantExtensionCop enabled;
│                               4-space indent, no tabs, format+trim on save
├── .alpackages/                BC 28.4 symbols (Platform 28.0.0.0, Runtime 17.0)
├── src/
│   ├── Enums/                  batch 1
│   ├── Tables/                 batch 2
│   ├── Pages/                  batch 2  (List, Card, ListPart)
│   ├── PermissionSets/         batch 2
│   └── API/                    batch 3
├── scripts/
│   ├── preflight.py            26-rule validator (§3)
│   └── build.sh                pre-flight + compile with all three analyzers (§4)
└── docs/                       ProblemStatement, FRD, TDD, ObjectRegister, SanityCheck,
                                BuildPlan, ChangeLog
```

**Scaffold verified:** `./scripts/build.sh` on the empty scaffold → `0 error(s), 0 warning(s)`,
`out/app.app` produced. The Step 05 exit gate "scaffold compiles empty" is met.

---

## 2. Batch plan (ordered)

Layering and rationale are in TDD §3; the reference-graph analysis that forced it is in
SanityCheck SC-02/SC-04. Within each batch, objects are listed in generation order — every
object's dependencies are already written by the time it is generated.

### Batch 1 — Enums (3 objects) → `src/Enums/`
| # | ID | Object | File |
|---|---|---|---|
| 1 | 80300 | `enum "ipt IP License Type"` | `iptIPLicenseType.Enum.al` |
| 2 | 80301 | `enum "ipt IP Billing Period"` | `iptIPBillingPeriod.Enum.al` |
| 3 | 80302 | `enum "ipt IP Entitlement Status"` | `iptIPEntitlementStatus.Enum.al` |

No dependencies. Spec: TDD §6.

### Batch 2 — Tables, UI pages, permission sets (16 objects)
Lookup/reference tables precede the entities that reference them; ListParts precede the Card
that hosts them; Cards precede the Lists that name them via `CardPageId`; permission sets last
because they name all four tables.

| # | ID | Object | Folder / file | Depends on |
|---|---|---|---|---|
| 1 | 80303 | `table "ipt IP App"` | `Tables/iptIPApp.Table.al` | 80300, 80301, 80304, 80305, 80306, 80307 |
| 2 | 80304 | `table "ipt IP App Edition"` | `Tables/iptIPAppEdition.Table.al` | 80303, 80305, 80306, 80309 |
| 3 | 80305 | `table "ipt IP App Price"` | `Tables/iptIPAppPrice.Table.al` | 80301, 80303, 80304, 80311, Currency |
| 4 | 80306 | `table "ipt IP Entitlement"` | `Tables/iptIPEntitlement.Table.al` | 80300-80302, 80303-80305, 80313, Customer |
| 5 | 80320 | `page "ipt IP App Editions Part"` | `Pages/iptIPAppEditionsPart.Page.al` | 80304 |
| 6 | 80321 | `page "ipt IP App Prices Part"` | `Pages/iptIPAppPricesPart.Page.al` | 80305 |
| 7 | 80310 | `page "ipt IP App Edition Card"` | `Pages/iptIPAppEditionCard.Page.al` | 80304 |
| 8 | 80312 | `page "ipt IP App Price Card"` | `Pages/iptIPAppPriceCard.Page.al` | 80305 |
| 9 | 80314 | `page "ipt IP Entitlement Card"` | `Pages/iptIPEntitlementCard.Page.al` | 80306 |
| 10 | 80308 | `page "ipt IP App Card"` | `Pages/iptIPAppCard.Page.al` | 80303, 80320, 80321 |
| 11 | 80307 | `page "ipt IP Apps"` | `Pages/iptIPApps.Page.al` | 80303, 80308 |
| 12 | 80309 | `page "ipt IP App Editions"` | `Pages/iptIPAppEditions.Page.al` | 80304, 80310 |
| 13 | 80311 | `page "ipt IP App Prices"` | `Pages/iptIPAppPrices.Page.al` | 80305, 80312 |
| 14 | 80313 | `page "ipt IP Entitlements"` | `Pages/iptIPEntitlements.Page.al` | 80306, 80314 |
| 15 | 80338 | `permissionset "IPT - IP Track Read"` | `PermissionSets/IPTIPTrackRead.PermissionSet.al` | 80303-80306 |
| 16 | 80339 | `permissionset "IPT - IP Track Edit"` | `PermissionSets/IPTIPTrackEdit.PermissionSet.al` | 80303-80306, 80338 |

The four tables are mutually referential, so they only resolve once all four are on disk —
compile at the **end** of the batch, not after each file. Spec: TDD §7, §8.1, §9.

### Batch 3 — API pages (4 objects) → `src/API/`
| # | ID | Object | File |
|---|---|---|---|
| 1 | 80315 | `page "ipt IP App API"` | `iptIPAppAPI.Page.al` |
| 2 | 80316 | `page "ipt IP App Edition API"` | `iptIPAppEditionAPI.Page.al` |
| 3 | 80317 | `page "ipt IP App Price API"` | `iptIPAppPriceAPI.Page.al` |
| 4 | 80318 | `page "ipt IP Entitlement API"` | `iptIPEntitlementAPI.Page.al` |

Depend only on the tables. Spec: TDD §8.2 (field identifier map).

**Verified: 0 forward references across all three batches.**

---

## 3. Pre-flight validation

`scripts/preflight.py` — run before compiling each batch (Step 06 action 3). Every rule encodes
a Standards requirement or a Step 04 defect. Parameters (namespace, prefixes, ID range, API
publisher/group/version, localization) are read from one `PARAM` block at the top of the script,
derived from TDD §1 — Operating Rule 1, nothing hardcoded downstream.

```bash
python3 scripts/preflight.py                 # everything under src/
python3 scripts/preflight.py src/Enums       # one batch
python3 scripts/preflight.py --list-rules
```

| Rule | Check | Origin |
|---|---|---|
| FILE-01 | File named `<ObjectNameWithoutSpaces>.<Type>.al` | CodeCop AA0215 / SC-06 |
| FILE-02 | Exactly one top-level object per file | Standards |
| FILE-03 | 4-space indentation, no tabs | Standards §9.2 |
| FILE-04 | No trailing whitespace; final newline | Standards |
| NS-01 | Exactly one namespace, matching Parameter 1.1 | Standards §3.3 |
| NS-02 | `using` statements alphabetically sorted | CodeCop AA0477 / SC-05 |
| NS-03 | Every `using` namespace exists in the symbol files | Operating Rule 2 |
| ID-01 | Object ID inside 80300–80339 | Parameter 1.2 |
| ID-02 | No duplicate object IDs | Parameter 1.2 |
| NAME-01 | Object identifier ≤ 30, **≤ 20 for `permissionset`** | AL0305 / **SC-01** |
| NAME-02 | Object name carries the Parameter 1.3 prefix | Parameter 1.3 |
| NAME-03 | Field / enum-value / entity-name identifier ≤ 30 | Standards |
| NAME-04 | No unquoted reserved keyword as an identifier | Standards |
| TAB-01 | Table declares `DataClassification` | Standards §3.3 |
| TAB-02 | Every table field declares a `Caption` | Standards §4.5 |
| TAB-03 | Every FlowField is `Editable = false` | Standards §4.2 |
| PAGE-01 | Every non-API page field has `ApplicationArea` + `ToolTip` | Standards §3.1, §4.6 |
| PAGE-02 | API page declares all six required properties; `ODataKeyFields = SystemId` | Standards §3.4 |
| PAGE-03 | API page has exactly one of `DelayedInsert = true` / `Editable = false` | Standards §3.4 |
| API-01 | `APIPublisher` / `APIGroup` are camelCase | CodeCop AA0101 / **SC-03** |
| API-02 | API properties match Parameter 1.3 exactly | Operating Rule 1 |
| CLEAN-01 | No `// TODO`, no commented-out field definitions | Standards §3.5 |
| CLEAN-02 | No empty trigger or procedure bodies | Standards §3.5 |
| SYM-01 | Referenced standard table/field exists in the symbol file | Operating Rule 2 |
| SYM-02 | No referenced standard field is `ObsoleteState` Pending/Removed | Standards |
| LOC-01 | W1 build references no localization-range field | Standards Part 5 |

SYM-01/SYM-02/LOC-01 and NS-03 resolve against a symbol index the script builds directly from
`.alpackages` (strip the 40-byte navx header, read `SymbolReference.json` from the zip, walk the
recursive `Namespaces` tree) and caches in `scripts/.symbolcache.json` — 1,962 tables, 389
namespaces. Delete the cache to force a rebuild after a symbol refresh.

**Validator tested both ways**, so it is trusted before it is relied on:
- Against the 17 compile-clean object files from the Step 04 probe → **0 failures**.
- Against the same files with 12 defects injected — the four Step 04 blockers (over-long
  permission-set name, `'DSW'`, `'ipt_ipManagement'`, unsorted `using`) plus an out-of-range ID,
  a missing `DataClassification`, a non-existent `Customer` field, a tab, a missing `ToolTip`
  and a `// TODO` → **all 12 caught, no false positives.**

Three bugs in the validator itself were found and fixed during that testing: a line-anchored
property matcher that silently skipped single-line field blocks, a page-level property search
that mistook a field-level `Editable = false` for a page property, and an end-anchored page-field
pattern that skipped `field(...) { ... }` written on one line.

---

## 4. Build command

```bash
./scripts/build.sh              # pre-flight, then compile with all three analyzers
./scripts/build.sh src/Enums    # pre-flight just that batch, then compile the project
```

Runs `alc` with CodeCop, UICop and PerTenantExtensionCop, then **fails on any warning as well as
any error** (Operating Rule 5 / FRD §8). Log at `out/build.log`. The AL extension and platform
binary are located dynamically, so no absolute path is baked in.

---

## 5. Per-batch procedure (Step 06)

1. **Pause for human approval before writing the first file of the batch** (Operating Rule 6).
2. Extract source-table and field data for the batch's objects from the symbol file.
3. Run `scripts/preflight.py` on the planned names/fields; if anything fails, **fix the TDD
   first**, then generate.
4. Generate the batch's files in the order in §2, from the TDD §5 templates, substituting only
   Parameter values.
5. Run `./scripts/build.sh`. Gate: 0 errors, 0 warnings.
6. Log any deviation in `ChangeLog.md`, update `ObjectRegister.md` status to Built, commit the
   batch referencing its ChangeLog entries, then start the next batch.

---

## 6. Exit gate

| Gate condition | Status |
|---|---|
| Batch order agreed with the human | **Met** — agreed at Step 04 sign-off; expanded to per-object order here |
| Scaffold compiles empty | **Met** — `0 error(s), 0 warning(s)`, `out/app.app` produced |
| Pre-flight checks ready | **Met** — 26 rules, tested against clean and defective input |

**Next:** Step 06, Batch 1 — the three enums. Pauses for approval before the first file.
