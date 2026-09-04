# Functional Requirements Document — IP Tracking

*Runbook phase: DESIGN / Step 02. Status: **Step 04 sanity check passed; resolutions applied and signed off 2026-09-04**.*
*Companion: `BC_App_Build_Routine_Agent.md`. Detailed rules: `AL_PTE_Development_Standards_UNIFIED.md` (not present in repo — inline runbook summaries used).*

---

## 1. Purpose & scope
Provide a Business Central Per-Tenant Extension that records the IP software products the
company licenses, their editions and prices, and the register of which customers hold which
product/edition. Deliver both an in-client UI (List + Card) and a v1.0 API surface.

**Out of scope:** billing/posting, currency conversion, number series, module setup table,
renewal automation, usage metering, workflow. (See ProblemStatement "Out of scope".)

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

## 5. Design rules (non-negotiable)
1. Every name, ID, prefix, version and quoting decision derives from the TDD's System Identity block (copied from the intake sheet). Nothing hardcoded.
2. Source table numbers, namespaces and field names verified against the 28.4 symbol files before code generation (Step 04).
3. Every table field: `Caption`, and every page field: `ToolTip` + `ApplicationArea = All`.
4. Every page: one `namespace`, explicit `using`, `Rec.`-qualified fields.
5. Every API page: `APIPublisher`, `APIGroup`, `APIVersion`, `EntityName`, `EntitySetName`, `ODataKeyFields = SystemId`, and exactly one of `DelayedInsert = true` / `Editable = false`.
6. No dead code, empty triggers, commented-out fields or `// TODO`.
7. Referential integrity: deleting a parent that has children is blocked with a clean error.

## 6. Entity / object inventory
| # | Entity | Type | Source | R/W | Notes |
|---|---|---|---|---|---|
| 1 | IP App | Master table (new) | new | R/W | Product header |
| 2 | IP App Edition | Master table (new) | new | R/W | Editions per IP App; PK = App + Edition |
| 3 | IP App Price | Setup/rate table (new) | new | R/W | Price per App + Edition + Billing Period + Currency |
| 4 | IP Entitlement | Document/register table (new) | new | R/W | Customer holds App/Edition; Service-Item analogue |
| 5 | IP License Type | Enum (new) | new | — | Perpetual, Fixed Price per Period, Per User, Per Company, Per Environment, Per Tenant, Per Other |
| 6 | IP Billing Period | Enum (new) | new | — | Monthly, Annual, Triennial |
| 7 | IP Entitlement Status | Enum (new) | new | — | Gratis, Active, Demo |
| 8 | Customer | Standard table 18 | BC | R (lookup) | Referenced by IP Entitlement |
| 9 | Currency | Standard table 4 | BC | R (lookup) | Referenced by IP App Price (blank = LCY) |

Each of tables 1–4 gets: a **List** page, a **Card** page, and an **API** page. IP App Card
also hosts an Editions ListPart and a Prices ListPart.

## 7. Functional requirements

### 7.1 IP App
- Key `Code` (Code10, not blank). `Description` (Text250).
- `License Type` (enum #5). `Other` (Text80) — free text describing "Per Other" (tooltip: *Define what Other is, e.g. Salesforce, Ticket, etc.*).
- `Default Billing Period` (enum #6) — the period proposed on new prices/entitlements.
- `Default Edition Code` (Code10) — optional pointer to one edition of this app.
- `Edition Count` — FlowField, count of child editions.
- Cannot be deleted while editions, prices or entitlements exist.

### 7.2 IP App Edition
- Key `IP App Code` + `Edition Code` (both Code10, not blank).
- `Description` (Text80). `Unit Price` (Decimal ≥ 0) — the edition's reference/list price; pricing basis is implied by the parent IP App's `License Type`.
- Cannot be deleted while prices or entitlements reference it.

### 7.3 IP App Price (pricing matrix)
- Key `IP App Code` + `Edition Code` + `Billing Period` + `Currency Code` (Currency Code blank = LCY).
- `Unit Price` (Decimal ≥ 0).
- This table is the authoritative period-specific price; `IP App Edition."Unit Price"` is the fallback reference when a period is not priced.

### 7.4 IP Entitlement (customer register)
- Key `Entry No.` (autoincrement). The same customer may hold the same App/Edition on more than one entry (renewals, multiple environments).
- `Customer No.` (Code20 → Customer 18), `Customer Name` (FlowField).
- `IP App Code` (→ IP App), `Edition Code` (→ IP App Edition, filtered by App), `Description` (FlowField from Edition).
- `Date of Purchase` (Date). `Status` (enum #7). `Billing Period` (enum #6). `Quantity` (Decimal ≥ 0, default 1).
- `Expiration Date` (Date) — suggested as Date of Purchase + 1M/1Y/3Y on validation of Date of Purchase or Billing Period; user-editable. A lapsed entitlement is one whose Expiration Date is in the past (there is no "Expired" status value).
- `License Type` (FlowField from IP App). `Unit Price` (FlowField lookup from IP App Price on App + Edition + Billing Period + blank Currency).

### 7.5 API surface
- API group `iptIpManagement`, version `v1.0`, publisher `dsw` — lower camelCase is required by CodeCop `AA0101` (SanityCheck SC-03). Base URL: `/api/dsw/iptIpManagement/v1.0/companies({id})/…`
- One entity per table 1–4, `ODataKeyFields = SystemId`, all four editable (`DelayedInsert = true`).
- Field identifiers camelCase; captions/tooltips are self-describing schema for consumers.

### 7.6 Permission sets
- **IPT - IP Track Read** — read on all four tables.
- **IPT - IP Track Edit** — includes the Read set + insert/modify/delete on all four tables.
  (Names are 19 chars: `permissionset` identifiers are capped at 20, not 30 — SanityCheck SC-01. Captions remain 'IP Tracking - Read' / 'IP Tracking - Edit'.)
- Documentation states the base `D365 BASIC` + Customer read permissions consumers also need.

## 8. Non-functional requirements
- Compiles with **0 errors / 0 warnings** (warnings treated as errors).
- No reference to any field/table/procedure with `ObsoleteState = Pending`/`Removed`.
- API list reads return within normal BC page limits. FlowFields on list pages are permitted where each is bounded to a single row or a single count (`Edition Count` on 80307, `Unit Price` on 80313); no unbounded aggregation. (Clarified at Step 04 — SanityCheck SC-12.)
- All objects use IDs strictly within **80300–80339**.
- Deployable as a signed `.app` to a SaaS sandbox and then production.

## 9. Validation against DEFINE artifacts
- Every entity from the intake conversation appears in §6 (IP App, Editions, Pricing, customer register) or is listed out of scope (Setup table, number series).
- Consumer use cases from PRE-01 (internal maintenance + BI/integration read) are both addressed (§7.5, §7.6).
- Platform assumptions **verified at Step 04** against the 28.4 symbol files: Customer = table 18 (`Microsoft.Sales.Customer`, `"No."` Code[20], `Name` Text[100]); Currency = table 4 (`Microsoft.Finance.Currency`, `Code` Code[10]); none obsolete. Full record: `docs/SanityCheck.md`.
