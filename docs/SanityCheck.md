# Sanity Check & Validation — IP Tracking

*Runbook phase: DESIGN / Step 04. Date: 2026-09-04. Status: **CLOSED — 0 blocking issues; all resolutions signed off and applied**.*

**Inputs:** `docs/FRD.md`, `docs/TDD.md`, `docs/ObjectRegister.md`, `app.json`, symbol files in `.alpackages`.

**Method — this was an executed review, not a read-through.** Three evidence sources were used:

1. **Symbol extraction.** `Microsoft_Base Application_28.4.53241.54031.app` and `Microsoft_Application_28.4.53241.53312.app` were unpacked and their `SymbolReference.json` namespace trees walked (1,597 tables) to verify every standard object number, namespace and field the TDD references.
2. **Compiler probe.** A disposable project outside the repo (`scratchpad/probe2`) was built containing the riskiest constructs from TDD §6–§9 — all three enums, all four tables with their real `TableRelation`s, FlowField `CalcFormula`s, `OnDelete` guards and `AutoIncrement` key, the Card page with both ListParts, and an API page — and compiled with **alc 17.0.34.45391** against the project's own symbols, with **CodeCop + UICop + PerTenantExtensionCop** enabled. No AL was written into the project.
3. **Dependency graph.** Every compile-time reference in TDD §7–§9 was modelled and the batch plan tested for forward references.

**Headline:** BC can do everything the FRD asks, and the TDD implements the FRD — the object model compiles to **0 errors / 0 warnings** once four defects are corrected. All four were found by the compiler, not by inspection.

---

## 1. Question A — can BC actually do what the FRD asks?

**Yes.** Every construct was compiled, not assumed.

| FRD requirement | Construct proved | Result |
|---|---|---|
| §7.4 Customer link | `TableRelation = Customer."No."` + `using Microsoft.Sales.Customer` | compiles |
| §7.3 Currency link, blank = LCY | `TableRelation = Currency.Code` + `using Microsoft.Finance.Currency` | compiles |
| §7.4 Customer Name / Description / License Type | FlowField `lookup(...)` across three tables | compiles |
| §7.4 Unit Price from the price matrix | 4-term FlowField lookup incl. `"Currency Code" = const('')` | compiles |
| §7.1 Edition Count | FlowField `count(...)` | compiles |
| §7.4 `Entry No.` autoincrement PK | `AutoIncrement = true` + editable API page | compiles |
| §7.4 R-1 suggested Expiration Date | `CalcDate('<1M>'/'<1Y>'/'<3Y>', ...)` in a table procedure called from two `OnValidate` triggers | compiles |
| §5.7 referential integrity | `OnDelete` guard with `IsEmpty()` + `Label` | compiles |
| §7.5 API surface | `PageType = API`, `ODataKeyFields = SystemId`, `DelayedInsert = true`, `Rec.SystemId`, `Rec.SystemModifiedAt` | compiles |
| §6 IP App ⇄ Edition mutual reference | 80303→80304 and 80304→80303 `TableRelation` in one compilation | compiles |
| §7.6 permission sets | `permissionset` with `IncludedPermissionSets` | compiles **after rename — see SC-01** |

Final probe result: **0 errors, 0 warnings, 1 info** (`AW0006`, see SC-07), `.app` produced.

---

## 2. Question B — does the TDD implement the FRD?

Every FRD §6 entity maps to at least one TDD object; no TDD object is unmapped.

| FRD §6 entity | TDD object(s) | UI | API | Permission |
|---|---|---|---|---|
| 1 IP App | table 80303 | 80307 List, 80308 Card | 80315 | R / IMD |
| 2 IP App Edition | table 80304 | 80309, 80310, part 80320 | 80316 | R / IMD |
| 3 IP App Price | table 80305 | 80311, 80312, part 80321 | 80317 | R / IMD |
| 4 IP Entitlement | table 80306 | 80313, 80314 | 80318 | R / IMD |
| 5 IP License Type | enum 80300 | — | via 80315/80318 | n/a |
| 6 IP Billing Period | enum 80301 | — | via 80315/80317/80318 | n/a |
| 7 IP Entitlement Status | enum 80302 | — | via 80318 | n/a |
| 8 Customer (18) | referenced only | lookup | — | consumer needs base read |
| 9 Currency (4) | referenced only | lookup | — | consumer needs base read |

Every FRD §7 functional rule appears in a TDD §7 field spec or rule R-1. No FRD requirement is unimplemented; no TDD object is unrequested.

**Object structure when built:** 23 objects — 3 enums, 4 tables, 8 UI pages, 2 ListParts, 4 API pages, 2 permission sets. IDs 80300–80339, 17 free (42% headroom).

---

## 3. Runbook §2.4 checklist

| # | Check | Finding | Resolution |
|---|---|---|---|
| 1 | Every FRD entity maps to ≥1 TDD object | **Pass** — §2 above, 9/9 | — |
| 2 | Every TDD object ID valid and in range | **Pass** — 23 IDs, no duplicates, all in 80300–80339; no Base App or Application object occupies any ID in that range | — |
| 3 | Source table numbers verified against symbols | **Pass** — Customer = **18**, ns `Microsoft.Sales.Customer`; Currency = **4**, ns `Microsoft.Finance.Currency`. Read from `SymbolReference.json`, not estimated | TDD §11 items 1–2 closed |
| 4 | Fields comply with Localization (W1) | **Pass** — only `Customer."No."` (Code[20]), `Customer.Name` (Text[100]), `Currency.Code` (Code[10]) are referenced; none is a localized field. TDD field lengths match the symbols exactly | — |
| 5 | Obsolete / pending fields excluded | **Pass** — none of the three referenced standard fields carries an `ObsoleteState` property | TDD §11 item 4 closed |
| 6 | Every `using` sourced from the symbol file | **Pass** on content, **fail on order** | **SC-05** |
| 7 | Document-type `const()` quoting | **N/A** — this app has no document-type-filtered page. The one `const()` in the design (`"Currency Code" = const('')`) compiles | — |
| 8 | Entity names ≤ 30 chars; field identifiers ≤ 30 | **Fail** — object and field names all pass at 30, but `permissionset` identifiers are capped at **20**, not 30 | **SC-01** |
| 9 | Read vs read/write designations | **Pass** — all four API pages `DelayedInsert = true` per A-8; all FlowFields `Editable = false` on both table and API page | — |
| 10 | Growth buffers planned | **Pass** on object IDs (42%). **Partial** on field numbers | **SC-13** |
| 11 | Permission sets planned | **Pass** — and PerTenantExtensionCop *requires* them | **SC-01**, **SC-04** |

---

## 4. Blocking issues — must be resolved before BUILD

### SC-01 — Permission set names exceed the AL 20-character limit *(compiler error)*
Both names in TDD §9 are 22 characters. The compiler rejects them:

```
error AL0305: The length of the application object identifier
'IPT - IP Tracking Read' cannot exceed 20 characters.
'IPT - IP Tracking Edit' cannot exceed 20 characters.
```

The 30-char rule in the runbook checklist does not apply to `permissionset` — its identifier limit is 20. The design's own pre-flight rule would have passed these.

**Recommended resolution:** rename to **`"IPT - IP Track Read"`** and **`"IPT - IP Track Edit"`** (19 each) — keeps the Parameter 1.3 prefix `IPT - `. Captions stay `'IP Tracking - Read'` / `'IP Tracking - Edit'`, which is what users actually see; captions have no such limit.
*Alternative:* `"IPT - Read"` / `"IPT - Edit"` (10 each) if a shorter object name is preferred.
**Verified:** with the rename, both permission sets compile clean.

### SC-02 — The batch plan cannot compile batch-by-batch *(5 forward references)*
TDD §3 assigns objects to batches that reference objects built in *later* batches. Batches 2 and 3 would each fail to compile, breaking the Step 06 exit gate ("each batch compiles clean before the next began"):

| Object (batch) | references | in batch | via |
|---|---|---|---|
| 80303 IP App (B2) | 80305 IP App Price | B3 | `OnDelete` guard |
| 80303 IP App (B2) | 80306 IP Entitlement | B4 | `OnDelete` guard |
| 80304 Edition (B2) | 80305 IP App Price | B3 | `OnDelete` guard |
| 80304 Edition (B2) | 80306 IP Entitlement | B4 | `OnDelete` guard |
| 80308 IP App Card (B2) | 80321 Prices Part | B3 | `part(Prices; ...)` |

This is structural, not an oversight in sequencing: the four tables are **mutually referential** (App's delete guard needs Entitlement; Edition's `TableRelation` needs App; App's `TableRelation` needs Edition), and each table's `LookupPageId`/`DrillDownPageId` needs its List page, whose `CardPageId` needs its Card page, which needs both ListParts. The whole table+page set is one dependency cluster. Entity-by-entity batching cannot produce a compiling batch without deferring properties and reworking delivered files.

**Recommended resolution — re-layer into 3 batches:**

| Batch | Objects | Count |
|---|---|---|
| **1** | Enums 80300–80302 | 3 |
| **2** | Tables 80303–80306; List/Card 80307–80314; parts 80320–80321; permission sets 80338–80339 | 16 |
| **3** | API pages 80315–80318 | 4 |

**Verified:** 0 forward references. Batch 2 is large, but it is the minimum compiling unit given the mutual references, and it is exactly what the probe compiled clean. Permission sets are pulled into batch 2 because of SC-04, not by preference.

*Alternative if smaller batches matter more:* keep the 5 entity batches and accept that 80303/80304 are written in batch 2 without their full delete guards and revisited in batch 4, and that 80308 is revisited in batch 3 — i.e. three files touched twice, each needing a ChangeLog entry. Not recommended; it trades a clean gate for churn.

### SC-03 — API publisher and group names fail CodeCop *(warning, and NFR §8 treats warnings as errors)*
```
warning AA0101: For pages of the type API the value of properties APIPublisher,
APIGroup, EntityName, and EntitySetName should be camel-cased.
```
Both `APIPublisher = 'DSW'` (all caps) and `APIGroup = 'ipt_ipManagement'` (underscore) are flagged. `EntityName`/`EntitySetName` (`iptIPApp`, `iptIPApps`, …) pass.

**Recommended resolution:** `APIPublisher = 'dsw'`, `APIGroup = 'iptIpManagement'`.
**Verified:** clears AA0101 with no other diagnostic.

**This changes the API URL and needs an explicit decision** (Parameter 1.3 is the source of truth for both values):

```
before:  /api/DSW/ipt_ipManagement/v1.0/companies({id})/iptIPApps
after:   /api/dsw/iptIpManagement/v1.0/companies({id})/iptIPApps
```

Nothing consumes this API yet, so the cost of changing it now is zero — after publishing it is a breaking change for every consumer. This is the single most valuable catch of Step 04.

### SC-04 — Tables without a permission set are a PerTenantExtensionCop **error**
```
error PTE0004: Table 80303 'ipt IP App' is missing a matching permission set.   (and 80304, 80305, 80306)
```
For a SaaS PTE this cop should be enabled. It makes permission sets a *compile-time dependency of the tables*, so scheduling them in the last batch (TDD §3, batch 5) guarantees every earlier batch fails.

**Recommended resolution:** ship 80338/80339 in the same batch as the tables — folded into batch 2 of the SC-02 plan. Decide explicitly whether PerTenantExtensionCop is enabled; if it is not, this downgrades to advisory, but disabling it for a PTE is not recommended.
**Verified:** with both permission sets present, PTE0004 clears for all four tables.

---

## 5. Advisory findings — resolve, but not gating

| # | Finding | Evidence | Suggested resolution |
|---|---|---|---|
| SC-05 | TDD §4 prescribes the `using` block in the wrong order | `info AA0477: The using statements are not in a sorted order.` | Swap the template: `Microsoft.Finance.Currency` **then** `Microsoft.Sales.Customer` |
| SC-06 | File naming convention not yet pinned; CodeCop enforces one | 13 × `warning AA0215: ... The valid name is iptIPApp.Table.al` | Pin `<ObjectNameWithoutSpaces>.<Type>.al` in the Step 05 scaffold (e.g. `iptIPAppEditionsPart.Page.al`). Verified: correct names clear all 13 warnings |
| SC-07 | Card pages report an info diagnostic | `info AW0006: The page 'ipt IP App Card' should use the UsageCategory and ApplicationArea properties to be searchable` | **Accept.** Card pages are reached through their List; adding `UsageCategory` would put four cards in Tell-Me. Info-level only — does not breach the 0-warning gate |
| SC-08 | `app.json "runtime": "16.0"` vs symbols built for runtime **17.0** | `NavxManifest.xml`: `Platform="28.0.0.0" Runtime="17.0"`; AL Language extension is 17.0 | **Decide deliberately.** The probe compiled clean at 16.0, so this is not a defect — but BC v28's platform runtime is 17.0, and 16.0 locks the app out of runtime-17 features for no stated benefit. Recommend 17.0 unless downlevel intent exists. Parameter 1.4 must be updated either way |
| SC-09 | `app.json "platform": "1.0.0.0"` is stale | app.json | Set to `28.0.0.0` or drop the property; `application` is what governs |
| SC-10 | Object Register footer says "Total planned: 21 objects" | Actual count is **23** (the two ListParts from A-9 were never added to the total) | Correct the footer to 23 |
| SC-11 | `launch.json` targets `"environmentName": "sandbox"` | The tenant's only environment is **`v29Sandbox`** | Update at Step 05. Also confirm before Step 09 whether that environment is BC v29 — an app built against 28.4 symbols with `application 28.0.0.0` deploys there, but you may want v29 symbols for PROVE |
| SC-12 | FRD §8 says "no unbounded FlowField calculations on list pages", but 80307 shows `Edition Count` (count) and 80313 shows `Unit Price` (lookup) | TDD §8.1 | Bounded per row and normal BC practice — **accept and soften the NFR wording**, or drop `Unit Price` from the Entitlements list |
| SC-13 | Field-number growth buffers exist only in table 80303 (gap 7–9) | TDD §7.2–§7.4 are contiguous | Leave gaps before the FlowField block in 80304/80305/80306 for symmetry |
| SC-14 | TDD §9 defers consumer permission guidance to `Deployment.md`, which does not exist and is not tracked | `docs/` | Add `Deployment.md` to the Step 12 deliverables |
| SC-15 | `ipt IP App Price` has no `OnDelete` guard, so deleting a price silently blanks the Entitlement `Unit Price` FlowField | TDD §7.3 | **By design** (rate table, per A-6 semantics) — document the behaviour rather than change it |

---

## 6. Exit gate — **met**

| Gate condition | Status |
|---|---|
| 0 blocking issues | **Met** — SC-01…SC-04 resolved |
| Every gap resolved | **Met** — SC-01…SC-15 applied to the design documents |
| Technical Lead sign-off | **Given** 2026-09-04 |

### Decisions taken at sign-off
| Item | Decision |
|---|---|
| SC-02 / SC-04 batch plan | Re-layer into 3 batches (B1 enums 3, B2 tables + UI + parts + permission sets 16, B3 API 4) |
| SC-03 API naming | Fix to camelCase — `APIPublisher = 'dsw'`, `APIGroup = 'iptIpManagement'`; URL becomes `/api/dsw/iptIpManagement/v1.0/…` |
| SC-08 AL runtime | Move to **17.0** |
| SC-01 permission set names | `"IPT - IP Track Read"` / `"IPT - IP Track Edit"` (19 chars); captions unchanged |

### Changes applied
| File | Change |
|---|---|
| `docs/TDD.md` | §1.3 API publisher/group + permission-set 20-char note; §1.4 runtime 17.0; §3 re-layered batch plan with in-batch generation order; §4 usings verified + sort rule; **new §4.1** file-naming convention; §5.3 API template; §7.2/§7.3 field buffers; §9 permission-set names; §11 rewritten as the Step 04 outcome |
| `docs/FRD.md` | §4 runtime 17.0; §7.5 API group/publisher + base URL; §7.6 permission-set names; §8 FlowField NFR reworded; §9 platform assumptions marked verified |
| `docs/ObjectRegister.md` | Batch column re-layered; permission-set names; total corrected 21 → **23** |
| `app.json` | `runtime` 16.0 → 17.0; `platform` 1.0.0.0 → 28.0.0.0 |
| `.vscode/launch.json` | `environmentName` `sandbox` → `v29Sandbox` |
| `docs/ChangeLog.md` | Issues 04-01 … 04-05 logged in the runbook's entry format |

### Post-change verification
The probe was recompiled using the project's **final** `app.json` (runtime 17.0, platform 28.0.0.0) and the shortened permission-set names:

```
Compilation started for project 'PROBE' containing '17' files
iptIPAppCard.Page.al(6,12): info AW0006: The page 'ipt IP App Card' should use the
    UsageCategory and ApplicationArea properties to be searchable.
Compilation ended.
```

**0 errors, 0 warnings, 1 accepted info** (SC-07). `.app` produced.

---

## 7. Next — Step 05, Plan the Code

Carried into Step 05: the batch order above (already agreed), the file-naming convention from
TDD §4.1, the folder structure, `launch.json`, and a pre-flight checklist that must now include
the **20-character permission-set limit** (SC-01), the **`using` sort order** (SC-05) and the
**camelCase API property rule** (SC-03) alongside the existing 30-character, reserved-keyword,
localization and `ObsoleteState` checks. `Deployment.md` is booked as a Step 12 deliverable
(SC-14). Confirm before Step 09 whether `v29Sandbox` is BC v29 and whether v29 symbols are
wanted for PROVE (SC-11).
