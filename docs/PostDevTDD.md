# Post-Development TDD (As-Built) — IP Tracking

*Runbook phase: PROVE / Step 11 "Update Design Documents". Date: 2026-09-05. Version at time of writing: `1.2.0.1`.*
*Status: **as-built reference — this is what actually exists in `src/`, not what was planned**.*

> **How this differs from `TDD.md`.** `TDD.md` is the *design* document — the instruction set a
> developer generates code from, retained as historical context. **This** document describes the
> code as it actually stands after BUILD, two testing-feedback rounds, and Step 10's review.
> Where the two disagree, this one is right. `ChangeLog.md` is the bridge: every difference below
> traces to a numbered entry there.
>
> **Generated from the code, not from memory** — object, field, relationship and API-map tables
> were extracted from `src/` by `scripts/extract_asbuilt.py` and pasted from its output.

---

## 1. Final system identity

| Parameter | As-built value |
|---|---|
| Extension Name | `IP Tracking` |
| Publisher | `OnlyCopilotFans` *(was `DSW` — 09F-05)* |
| Namespace | `OnlyCopilotFans.IPTracking` *(was `DSW.IPTracking` — 09F-05)* |
| AL Object Prefix | `ocpf` *(was `ipt` — 09F-05)* |
| Permission Set Prefix | `OCPF - ` |
| APIPublisher / APIGroup / APIVersion | `'ocpf'` / `'ocpfIpManagement'` / `'v1.0'` |
| Deployment Target | SaaS PTE |
| Localization | W1 |
| AL Runtime | `17.0` *(was 16.0 — SC-08)* |
| Platform / Application | `28.0.0.0` / `28.0.0.0` |
| Object ID range | 80300–80339 — **32 used, 8 free (20% headroom)** |
| Dependencies | Business Foundation (Microsoft, `f3552374-a1f2-4356-848e-196002525837`, `28.4.53241.53312`) *(added 09F-07 for No. Series)* |
| Feature flags | `NoImplicitWith` |
| API base URL | `/api/ocpf/ocpfIpManagement/v1.0/companies({id})/<entitySet>` |

## 2. Final object inventory — 32 objects

| Kind | Count | IDs |
|---|---|---|
| Enums | 3 | 80300–80302 |
| Tables | 5 | 80303–80306, 80319 |
| UI pages (List/Card) | 9 | 80307–80314, 80322 |
| Catalog pages | 2 | 80328–80329 |
| ListParts | 2 | 80320–80321 |
| API pages | 4 | 80315–80318 |
| Table extension | 1 | 80323 |
| Page extensions | 4 | 80324–80327 |
| Permission sets | 2 | 80338–80339 |

### 2.1 Tables — as-built fields

**`table 80303 "ocpf IP App"`** — `DataClassification = CustomerContent`, Lookup/DrillDown = "ocpf IP Apps"

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Code | Code[10] | NotBlank; PK |
| 2 | Description | Text[250] | |
| 3 | License Type | Enum "ocpf IP License Type" | defaults blank |
| 4 | Other | Text[80] | Card-conditional visibility (R-2) |
| 5 | Default Billing Period | Enum "ocpf IP Billing Period" | defaults blank |
| 6 | Default Edition Code | Code[10] | → `"ocpf IP App Edition"."Edition Code" where("IP App Code" = field("Code"))` |
| 10 | Edition Count | Integer | FlowField (count), `Editable = false` |

`OnDelete`: blocks if any Edition, Price, Entitlement **or `Item`** references it (Item check added 09F-12).

**`table 80304 "ocpf IP App Edition"`** — Lookup/DrillDown = "ocpf IP App Editions"

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | IP App Code | Code[10] | NotBlank; → `"ocpf IP App"."Code"`; PK part 1 |
| 2 | Edition Code | Code[10] | NotBlank; PK part 2 |
| 3 | Description | Text[80] | |

*Field 4 "Unit Price" (Reference Unit Price) **removed** — 09F-04.* `OnDelete`: blocks if any Price or Entitlement references it.

**`table 80305 "ocpf IP App Price"`** — Lookup/DrillDown = "ocpf IP App Prices"

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | IP App Code | Code[10] | NotBlank; → `"ocpf IP App"."Code"` |
| 2 | Edition Code | Code[10] | NotBlank; → Edition, filtered by App |
| 3 | Billing Period | Enum "ocpf IP Billing Period" | defaults blank |
| 4 | Currency Code | Code[10] | → `Currency.Code`; blank = LCY |
| 5 | Unit Price | Decimal | MinValue 0 |

PK: all four of 1–4. No `OnDelete` guard — deliberate (rate table, SC-15).

**`table 80306 "ocpf IP Entitlement"`** — Lookup/DrillDown = "ocpf IP Entitlements"

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | No. | **Code[20]** | PK. No. Series-assigned in `OnInsert` (R-3). *Was `Entry No.` Integer AutoIncrement — 09F-07* |
| 2 | Customer No. | Code[20] | NotBlank; → `Customer."No."` |
| 3 | Customer Name | Text[100] | FlowField, `Editable = false` |
| 4 | IP App Code | Code[10] | NotBlank; → IP App; `OnValidate` → R-4 |
| 5 | Edition Code | Code[10] | NotBlank; → Edition filtered by App; `OnValidate` → R-4 |
| 6 | Description | Text[80] | FlowField, `Editable = false` |
| 7 | Date of Purchase | Date | `OnValidate` → R-1 |
| 8 | Status | Enum "ocpf IP Entitlement Status" | `InitValue = Active` |
| 9 | Billing Period | Enum "ocpf IP Billing Period" | defaults blank; `OnValidate` → R-1, R-4 |
| 10 | Quantity | Decimal | MinValue 0, `InitValue = 1` |
| 11 | Expiration Date | Date | suggested by R-1, user-editable |
| 12 | License Type | Enum "ocpf IP License Type" | FlowField, `Editable = false` |
| 13 | Unit Price | Decimal | **stored, not FlowField** — suggested by R-4, user-editable (09F-11) |
| 14 | License Key | Text[80] | New — 09F-14 |

Keys: `PK("No.")`, `Cust("Customer No.","IP App Code","Edition Code")`.

**`table 80319 "ocpf IP App Setup"`** — singleton (09F-07)

| # | Field | Type | Notes |
|---|---|---|---|
| 1 | Primary Key | Code[10] | PK; standard BC Setup convention |
| 2 | IP Entitlement Nos. | Code[20] | → `"No. Series".Code` |

`OnDelete`: unconditional error — the singleton must not be deleted (09F-12).

**`tableextension 80323 "ocpf Item"` extends `Item` (27)**

| # | Field | Type | Notes |
|---|---|---|---|
| 80300 | IP App | Code[10] | → `"ocpf IP App".Code`; optional; `DataClassification = CustomerContent` (added 10-02) |

### 2.2 Enums — as-built values

| Enum | Ordinals |
|---|---|
| 80300 `ocpf IP License Type` | 0 `" "` *(blank, default)*, 1 Perpetual, 2 FixedPricePerPeriod, 3 PerUser, 4 PerCompany, 5 PerEnvironment, 6 PerTenant, 7 PerOther, 8 Free, 9 FreeOpenSource |
| 80301 `ocpf IP Billing Period` | 0 `" "` *(blank, default)*, 1 Monthly, 2 Annual, 3 Triennial |
| 80302 `ocpf IP Entitlement Status` | 0 Gratis, 1 Active, 2 Demo |

All `Extensible = true`. **Ordinals 1–7 / 1–3 were shifted up by one (09F-01, 09F-03)** to insert
the blank default at 0 — a one-time exception to append-only, safe only pre-publish. From now on:
**append only.**

### 2.3 Pages — as-built

| ID | Name | Type | Source | UsageCategory | CardPageId |
|---|---|---|---|---|---|
| 80307 | ocpf IP Apps | List | ocpf IP App | Lists | ocpf IP App Card |
| 80308 | ocpf IP App Card | Card | ocpf IP App | — | — |
| 80309 | ocpf IP App Editions | List | ocpf IP App Edition | Lists | ocpf IP App Edition Card |
| 80310 | ocpf IP App Edition Card | Card | ocpf IP App Edition | — | — |
| 80311 | ocpf IP App Prices | List | ocpf IP App Price | Lists | ocpf IP App Price Card |
| 80312 | ocpf IP App Price Card | Card | ocpf IP App Price | — | — |
| 80313 | ocpf IP Entitlements | List | ocpf IP Entitlement | Lists | ocpf IP Entitlement Card |
| 80314 | ocpf IP Entitlement Card | Card | ocpf IP Entitlement | — | — |
| 80320 | ocpf IP App Editions Part | ListPart | ocpf IP App Edition | — | — |
| 80321 | ocpf IP App Prices Part | ListPart | ocpf IP App Price | — | — |
| 80322 | ocpf IP App Setup | Card | ocpf IP App Setup | Administration | — (InsertAllowed/DeleteAllowed = false) |
| **80328** | **ocpf IP App Entitlements** | List | ocpf IP Entitlement | — | **— (deliberate)** |
| **80329** | **ocpf Customer Entitlements** | List | ocpf IP Entitlement | — | **— (deliberate)** |

80328/80329 are the cross-reference catalog pages (09F-13 §2): no `UsageCategory` (reached only
via `RunObject`), no `CardPageId` (inline editing — this is what makes `RunPageLink` default a new
record correctly), and each hides its own linking field.

| ID | Page extension | Extends | Adds |
|---|---|---|---|
| 80324 | ocpf Item Card | Item Card (30) | `"IP App"` field, `addlast(Item)` |
| 80325 | ocpf Item List | Item List (31) | `"IP App"` field, `addlast(Control1)` |
| 80326 | ocpf Customer Card | Customer Card (21) | "IP Entitlements" action → 80329 |
| 80327 | ocpf Customer List | Customer List (22) | "IP Entitlements" action → 80329 |

### 2.4 Permission sets — as-built

| ID | Name | Caption | Grants |
|---|---|---|---|
| 80338 | `OCPF - IP Track Read` | IP Tracking - Read | `R` on all 5 tables |
| 80339 | `OCPF - IP Track Edit` | IP Tracking - Edit | Includes Read + `IMD` on all 5 tables |

Both names are exactly 20 characters — the `permissionset` identifier ceiling (SC-01).

---

## 3. Business rules as implemented

| Rule | Where | Behaviour |
|---|---|---|
| **R-1** Suggested Expiration Date | `ocpf IP Entitlement`, `OnValidate` of Date of Purchase / Billing Period | `Date of Purchase + <1M\|1Y\|3Y>` when both set and Expiration Date blank. Never overwrites a user value. Silent while Billing Period is blank |
| **R-2** Conditional "Other" | page 80308 | `Other` visible only when License Type = PerOther. Page-scoped Boolean recomputed in `OnAfterGetCurrRecord` + License Type's `OnValidate`. UI-only — API always returns the field |
| **R-3** No. Series assignment | `ocpf IP Entitlement`, `OnInsert` | If `"No."` blank: `IPAppSetup.Get()`, `TestField("IP Entitlement Nos.")`, `NoSeries.GetNextNo(...)`. Mandatory series, no manual override (Roadmap R-2) |
| **R-4** Suggested Unit Price | `ocpf IP Entitlement`, `OnValidate` of IP App Code / Edition Code / Billing Period | Looks up `ocpf IP App Price` on App+Edition+Period+blank Currency. Only when Unit Price is 0. **Known edge case:** a deliberate 0 is indistinguishable from "unset" |
| **R-5** Catalog-page defaulting | pages 80328/80329 | `RunPageLink` + no `CardPageId` + hidden linking field (the Base App "Item Vendor Catalog" pattern), plus an `OnNewRecord`/`GetFilter` backstop |
| Referential integrity | `OnDelete` on 80303, 80304, 80319 | Block-with-clean-error. `ocpf IP App Price` deliberately has none (rate table) |

---

## 4. Deviation summary — as-built vs. original TDD

Every row traces to `ChangeLog.md`. This is the list a future planner needs; the original `TDD.md`
alone would mislead.

| # | Deviation from original design | Entry |
|---|---|---|
| 1 | Publisher/prefix/namespace renamed `DSW`/`ipt` → `OnlyCopilotFans`/`ocpf` | 09F-05 |
| 2 | AL runtime 16.0 → 17.0; `platform` 1.0.0.0 → 28.0.0.0 | SC-08, SC-09 |
| 3 | Permission set names shortened to 20 chars (AL0305 ceiling) | SC-01 |
| 4 | API publisher/group lowercased to satisfy `AA0101`; **API URL changed** | SC-03 |
| 5 | Batch plan re-layered (3 batches, not 5) — mutual references + `PTE0004` | SC-02, SC-04 |
| 6 | Both enums gained a blank ordinal 0; existing ordinals shifted | 09F-01, 09F-03 |
| 7 | All three Billing Period fields now default blank, not Monthly | 09F-03 (AJ's explicit call) |
| 8 | `IP App Edition."Unit Price"` removed entirely | 09F-04 |
| 9 | Item ⇄ IP App tie added (tableextension + 2 pageextensions) | 09F-06 |
| 10 | Entitlement key `Entry No.` (Integer/AutoIncrement) → `No.` (Code[20]/No. Series); Setup table + page added; Business Foundation dependency added | 09F-07 |
| 11 | Cross-reference navigation added, then rebuilt as 2 dedicated catalog pages | 09F-08, 09F-13 |
| 12 | Entitlement `Unit Price`: FlowField → stored, suggested, user-editable | 09F-11 |
| 13 | `IP App.OnDelete` extended to block on referencing Items; Setup singleton guarded | 09F-12 |
| 14 | `License Key` (Text80) added to Entitlement | 09F-14 |
| 15 | `"No."` column added to both catalog pages (late-batch drift) | 10-01 |
| 16 | `DataClassification` added to the Item extension field | 10-02 |

---

## 5. Known limitations carried forward (not defects — recorded so nobody rediscovers them)

- **R-4's zero-sentinel:** a deliberately-entered Unit Price of 0 may be re-suggested.
- **No manual override for Entitlement `No.`** — mandatory No. Series (Roadmap R-2).
- **`ocpf IP App Price` has no delete guard** — deleting a price silently blanks nothing (Unit
  Price is now stored on the Entitlement, so historical entitlements keep their price).
- **6 × `AW0006` info** accepted permanently (4 Card pages, 2 catalog pages).
- **Step 09's live tests were never run** — no green/red-team evidence exists for this build.
- **`AL_PTE_Development_Standards_UNIFIED.md` is absent from the repo** — all Standards §
  references throughout resolve to the runbook's inline summaries only.
