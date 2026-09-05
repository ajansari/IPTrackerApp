# Functional Requirements Document — IP Tracking

*Runbook phase: DESIGN / Step 02, **re-baselined at Step 11 (2026-09-05)**.*
*Status: **this is the forward baseline** — every implementation decision that diverged from the
original requirements has been folded in, including where the implementation turned out better
than the plan. The next planning session starts from this document, not from the pre-BUILD text.
For the object-level as-built truth see `PostDevTDD.md`; for why each thing changed, `ChangeLog.md`.*
*Companion: `BC_App_Build_Routine_Agent.md`. Detailed rules: `AL_PTE_Development_Standards_UNIFIED.md` (not present in repo — inline runbook summaries used).*

---

## 1. Purpose & scope
Provide a Business Central Per-Tenant Extension that records the IP software products the
company licenses, their editions and prices, and the register of which customers hold which
product/edition. Deliver both an in-client UI (List + Card) and a v1.0 API surface.

**Out of scope:** billing/posting, currency conversion, renewal automation, usage metering,
workflow. (See ProblemStatement "Out of scope".)

**Revised 2026-09-05:** a module Setup table and No. Series were originally deferred (A-4) but
are now in scope, added by testing feedback (09F-07) — the IP Entitlement `No.` is now
series-driven, requiring `ocpf IP App Setup`. A-4's reasoning ("avoid a Setup object + number-
series dependency in the first cut") is superseded for this one field; `Code` fields on IP App /
IP App Edition remain manual entry.

## 2. Business objectives & value
- One authoritative catalogue of licensed IP assets and their commercial terms.
- A queryable customer-entitlement register for support, renewals and revenue visibility.
- API access so BI/integration can consume the same data without a separate export.

## 3. Target consumers
| Consumer | Access |
|---|---|
| Internal users (product/commercial/support) | UI List + Card pages |
| BI / integration | API v1.0 pages (OData, `$metadata`) — read; write enabled where the table is editable |
| Administrators | Permission sets (read-only, read/write) |

## 4. Platform requirements
| Item | Value |
|---|---|
| BC version | 2026 Wave 1 (v28); recommended 28.4+ |
| Deployment model | SaaS Per-Tenant Extension |
| AL runtime | 17.0 |
| BC application minimum | 28.0.0.0 |
| Localization | W1 |
| Feature flags | `NoImplicitWith` (enforced) |
| Symbol source | Base Application 28.4.53241.54031 (in `.alpackages`) |
| Dependency (added 2026-09-05) | Business Foundation (Microsoft, 28.4.53241.53312) — No. Series |

## 5. Design rules (non-negotiable)
1. Every name, ID, prefix, version and quoting decision derives from the TDD's System Identity block (copied from the intake sheet). Nothing hardcoded.
2. Source table numbers, namespaces and field names verified against the 28.4 symbol files before code generation (Step 04).
3. Every table field: `Caption`, and every page field: `ToolTip` + `ApplicationArea = All`.
4. Every page: one `namespace`, explicit `using`, `Rec.`-qualified fields.
5. Every API page: `APIPublisher`, `APIGroup`, `APIVersion`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and exactly one of `DelayedInsert = true` / `Editable = false`.
6. No dead code, empty triggers, commented-out fields or `// TODO`.
7. Referential integrity: deleting a parent that has children is blocked with a clean error.

## 6. Entity / object inventory
*Revised 2026-09-05 — rows 10–11 added, row 5 enum values expanded (09F-01, 09F-07).*

| # | Entity | Type | Source | R/W | Notes |
|---|---|---|---|---|---|
| 1 | IP App | Master table (new) | new | R/W | Product header |
| 2 | IP App Edition | Master table (new) | new | R/W | Editions per IP App; PK = App + Edition; no longer carries a price (09F-04) |
| 3 | IP App Price | Setup/rate table (new) | new | R/W | Price per App + Edition + Billing Period + Currency |
| 4 | IP Entitlement | Document/register table (new) | new | R/W | Customer holds App/Edition; Service-Item analogue; key field is now `No.` (No. Series), not an autoincrement Entry No. |
| 5 | IP License Type | Enum (new) | new | — | *(blank, default)*, Perpetual, Fixed Price per Period, Per User, Per Company, Per Environment, Per Tenant, Per Other, Free, Free Open Source |
| 6 | IP Billing Period | Enum (new) | new | — | *(blank, default)*, Monthly, Annual, Triennial |
| 7 | IP Entitlement Status | Enum (new) | new | — | Gratis, Active, Demo |
| 8 | Customer | Standard table 18 | BC | R (lookup) | Referenced by IP Entitlement; now also carries an "IP Entitlements" navigation action (09F-08) |
| 9 | Currency | Standard table 4 | BC | R (lookup) | Referenced by IP App Price (blank = LCY) |
| 10 | Item | Standard table 27 | BC | R/W (extension field only) | New field "IP App" ties an item to an IP App; optional (09F-06) |
| 11 | IP App Setup | Setup table (new) | new | R/W | Holds the No. Series code for IP Entitlement `No.` (09F-07) |

Each of tables 1–4 gets: a **List** page, a **Card** page, and an **API** page. IP App Card
also hosts an Editions ListPart and a Prices ListPart, plus an "Entitlements" navigation action
(as does the IP Apps list). IP App Setup gets a singleton Card page.

## 7. Functional requirements

### 7.1 IP App
- Key `Code` (Code10, not blank). `Description` (Text250).
- `License Type` (enum #5, **defaults blank**) — values: *(blank)*, Perpetual, Fixed Price per Period, Per User, Per Company, Per Environment, Per Tenant, Per Other, Free, Free Open Source (09F-01).
- `Other` (Text80) — free text describing "Per Other" (tooltip: *Define what Other is, e.g. Salesforce, Ticket, etc.*). **Shown on the Card only when License Type = Per Other** (09F-02, rule R-2 in the TDD); the field itself, and the API, are unaffected — this is a UI-visibility rule only.
- `Default Billing Period` (enum #6, **defaults blank**, 09F-03) — the period proposed on new prices/entitlements.
- `Default Edition Code` (Code10) — optional pointer to one edition of this app.
- `Edition Count` — FlowField, count of child editions.
- Cannot be deleted while editions, prices or entitlements exist.
- **New:** an "Entitlements" navigation action on both the List and Card, opening IP Entitlements filtered to this app (09F-08).

### 7.2 IP App Edition
- Key `IP App Code` + `Edition Code` (both Code10, not blank).
- `Description` (Text80).
- **Removed 2026-09-05 (09F-04): `Unit Price` ("Reference Unit Price").** It duplicated the pricing matrix (§7.3) without being tied to it — nothing validated the two stayed consistent. `IP App Price` is now the only source of anything price-shaped for an edition.
- Cannot be deleted while prices or entitlements reference it.

### 7.3 IP App Price (pricing matrix)
- Key `IP App Code` + `Edition Code` + `Billing Period` (**defaults blank**, see ripple note below) + `Currency Code` (Currency Code blank = LCY).
- `Unit Price` (Decimal ≥ 0).
- This table is now the **only** source of price for an app/edition — there is no fallback reference price (09F-04 superseded the old "fallback" language in this section).

### 7.4 IP Entitlement (customer register)
- Key **`No.`** (Code20, No. Series-driven — renamed from `Entry No.` (autoincrement Integer), 09F-07). The same customer may hold the same App/Edition on more than one entry (renewals, multiple environments). Populated automatically on insert from `ocpf IP App Setup."IP Entitlement Nos."` via the modern `codeunit "No. Series"`; not user-editable.
- `Customer No.` (Code20 → Customer 18), `Customer Name` (FlowField).
- `IP App Code` (→ IP App), `Edition Code` (→ IP App Edition, filtered by App), `Description` (FlowField from Edition).
- `Date of Purchase` (Date). `Status` (enum #7). `Billing Period` (enum #6, **defaults blank**). `Quantity` (Decimal ≥ 0, default 1).
- `Expiration Date` (Date) — suggested as Date of Purchase + 1M/1Y/3Y on validation of Date of Purchase or Billing Period; user-editable. Does not fire while Billing Period is blank. A lapsed entitlement is one whose Expiration Date is in the past (there is no "Expired" status value).
- `License Type` (FlowField from IP App). `Unit Price` — **not a FlowField (changed 2026-09-05, 09F-11)**: a real, user-editable field auto-suggested from IP App Price (App + Edition + Billing Period + blank Currency) once all three are known, and never overwritten once it holds a non-zero value.
- `License Key` (Text80, new 2026-09-05, 09F-14) — plain field, entered manually today. A generator for it is on the roadmap (R-4), details not yet decided.
- **Defect fixed (09F-13, revised):** creating a new Entitlement from the IP App or Customer cross-reference actions (§7.8) fell outside the filter it was created under. First attempted fix (a trigger on the shared general list) did not actually resolve it in testing. Fixed properly by mirroring Base App's real "Item Vendor Catalog" pattern — two dedicated, Card-less catalog pages, each hiding its own linking field.

**Billing Period default ripple (explicit decision, 2026-09-05):** the blank default added for
"Default Billing Period" (§7.1) is on a *shared* enum, so it also changed the default for this
field and for IP App Price's Billing Period — all three now start blank rather than Monthly. The
alternative (keep Price/Entitlement defaulting to Monthly) was offered and declined.

### 7.5 API surface
- API group `ocpfIpManagement`, version `v1.0`, publisher `ocpf` (renamed from `dsw`/`ipt_ipManagement` per 09F-05 — publisher/prefix change to OnlyCopilotFans/ocpf). Base URL: `/api/ocpf/ocpfIpManagement/v1.0/companies({id})/…`
- One entity per table 1–4, `ODataKeyFields = SystemId`, all four editable (`DelayedInsert = true`).
- Field identifiers camelCase; captions/tooltips are self-describing schema for consumers.
- IP App Edition API loses `unitPrice` (09F-04). IP Entitlement API's `entryNo` becomes `no` (09F-07).

### 7.6 Permission sets
- **OCPF - IP Track Read** — read on all four app tables **plus IP App Setup** (renamed 2026-09-05, 09F-05/09F-07).
- **OCPF - IP Track Edit** — includes the Read set + insert/modify/delete on all five tables.
  (Names are 20 chars — the exact `permissionset` identifier limit. Captions remain 'IP Tracking - Read' / 'IP Tracking - Edit'.)
- Documentation states the base `D365 BASIC` + Customer read permissions consumers also need. Still open — GA-01/Issue 08-01, deferred to `Deployment.md`.

### 7.7 Item ⇄ IP App tie (new 2026-09-05, 09F-06)
- New field `"IP App"` (Code[10], `TableRelation = "ocpf IP App".Code`) added to the standard
  `Item` table via `tableextension`, surfaced on Item Card and Item List via `pageextension`.
- **Optional** — not every item has an IP association; blank is valid.

### 7.8 Cross-reference navigation (new 2026-09-05, 09F-08; revised 09F-13 §2)
- IP App List/Card → "Entitlements" action → dedicated page `ocpf IP App Entitlements`, filtered
  by IP App Code (hidden on that page).
- Customer Card/List → "IP Entitlements" action → dedicated page `ocpf Customer Entitlements`,
  filtered by Customer No. (hidden on that page).
- Modeled on BC's own Item↔Vendor "Item Vendor Catalog" pattern, per direct request — verified
  against the actual Base App symbols, not assumed: `RunObject`/`RunPageLink` on the action (as
  originally built), **plus a dedicated target page with no Card and the linking field hidden**
  (not initially built — added in 09F-13 §2 once the first attempt proved insufficient in
  testing). An action opening a filtered, inline-editable list, not a FactBox.

## 8. Non-functional requirements
- Compiles with **0 errors / 0 warnings** (warnings treated as errors).
- No reference to any field/table/procedure with `ObsoleteState = Pending`/`Removed`.
- API list reads return within normal BC page limits. FlowFields on list pages are permitted where each is bounded to a single row or a single count; no unbounded aggregation (SC-12). **As-built:** the remaining list FlowFields are `Edition Count` (80307) and `Customer Name` (80313/80328) — `Unit Price` is no longer a FlowField at all (09F-11), so the original example in this rule no longer applies.
- All objects use IDs strictly within **80300–80339**.
- Deployable as a signed `.app` to a SaaS sandbox and then production. **As-built status:** published to `v29Sandbox` by AJ at `1.2.0.1`; the green-team/red-team verification that would confirm this NFR was skipped by instruction, so this requirement is **asserted, not demonstrated** (see ChangeLog, Step 09).
- **As-built compile state:** 0 errors / 0 warnings, plus 6 permanently-accepted `AW0006` infos (4 Card pages + 2 catalog pages, none of which carry `UsageCategory` by design).

## 9. Validation against DEFINE artifacts
- Every entity from the intake conversation appears in §6. **Re-baselined:** the Setup table and number series, originally deferred as out of scope (A-4), are now **in scope and built** (09F-07) — `ocpf IP App Setup` drives the IP Entitlement `No.` series. Still genuinely out of scope: billing/posting, currency conversion, renewal automation, usage metering, workflow.
- Consumer use cases from PRE-01 (internal maintenance + BI/integration read) are both addressed (§7.5, §7.6).
- Platform assumptions **verified at Step 04** against the 28.4 symbol files: Customer = table 18 (`Microsoft.Sales.Customer`, `"No."` Code[20], `Name` Text[100]); Currency = table 4 (`Microsoft.Finance.Currency`, `Code` Code[10]); none obsolete. Full record: `docs/SanityCheck.md`.
