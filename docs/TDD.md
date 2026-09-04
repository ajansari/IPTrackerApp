# Technical Design Document — IP Tracking

*Runbook phase: DESIGN / Step 03. Status: **Step 04 sanity check passed; resolutions SC-01…SC-15 applied and signed off 2026-09-04**.*
*Self-sufficiency intent: a developer who has never seen this project can generate every object from this document alone.*

---

## 1. System identity (authoritative — from the Step 01 intake sheet)

### 1.1 Extension identity
| Parameter | Value |
|---|---|
| Extension Name | `IP Tracking` |
| Publisher | `DSW` |
| Deployment Target | `SaaS PTE` |
| Namespace | `DSW.IPTracking` |
| Localization | `W1` |

### 1.2 Object ID allocation
| Block | From | To |
|---|---|---|
| Primary | 80300 | 80339 |
| Additional | — | — |

Permission Sets required: **Yes** → 80338, 80339 reserved in the primary range.
**Rule:** never use an ID outside 80300–80339. The Object Register (`docs/ObjectRegister.md`) is the running ledger.

### 1.3 Naming & API parameters
| Parameter | Value |
|---|---|
| AL Object Prefix | `ipt` |
| APIPublisher | `'dsw'` |
| APIGroup | `'iptIpManagement'` |
| APIVersion | `'v1.0'` |
| Namespace | `DSW.IPTracking` |
| Permission Set Prefix | `IPT - ` |

> **Permission set identifiers are capped at 20 characters** (not 30) — AL0305. Names below are 19. Captions carry the readable form. (SanityCheck SC-01)

Entity-naming (all ≤ 30 chars incl. prefix):
| Table | EntityName | EntitySetName |
|---|---|---|
| ipt IP App | `iptIPApp` | `iptIPApps` |
| ipt IP App Edition | `iptIPAppEdition` | `iptIPAppEditions` |
| ipt IP App Price | `iptIPAppPrice` | `iptIPAppPrices` |
| ipt IP Entitlement | `iptIPEntitlement` | `iptIPEntitlements` |

`ODataKeyFields = SystemId` on every API page.

### 1.4 Platform & runtime
| Parameter | Value |
|---|---|
| AL Runtime | `17.0` |
| BC Application Minimum | `28.0.0.0` |
| Recommended BC Version | `28.4+` |
| Symbol Source | Base Application 28.4.53241.54031 (`.alpackages`) — `Platform="28.0.0.0" Runtime="17.0"` |

### 1.5 Feature flags
`NoImplicitWith` — enabled/enforced (`app.json "features"`). Every field source prefixed `Rec.`.

---

## 2. Module grouping & ID sub-blocks

Single functional module: **IP Tracking**. Sub-blocks inside 80300–80339:

| Sub-block | Range | Contents |
|---|---|---|
| Enums | 80300–80302 | 3 enums |
| Tables | 80303–80306 | 4 tables |
| UI pages | 80307–80314 | 4 List + 4 Card |
| Card parts | 80320–80321 | Editions ListPart, Prices ListPart |
| API pages | 80315–80318 | 4 API |
| Growth / tail buffer | 80319, 80322–80337 | 17 IDs unallocated (>40% headroom) |
| Permission sets | 80338–80339 | Read, Edit |

---

## 3. Batch / phase plan (re-layered at Step 04 — SanityCheck SC-02, SC-04)

Entity-by-entity batching is impossible here: tables 80303–80306 are mutually referential
(App's delete guard needs Entitlement; Edition's `TableRelation` needs App; App's
`TableRelation` needs Edition), each table's `LookupPageId`/`DrillDownPageId` needs its List
page, each List page's `CardPageId` needs its Card page, and the IP App Card needs both
ListParts. Tables + UI pages are therefore one indivisible dependency cluster. Permission sets
join it because PerTenantExtensionCop reports `PTE0004` — a *compile error* — for any table
without a matching permission set.

| Batch | Objects | Count | Why |
|---|---|---|---|
| **1** | Enums 80300–80302 | 3 | No dependencies; compiles standalone |
| **2** | Tables 80303–80306; List/Card pages 80307–80314; ListParts 80320–80321; permission sets 80338–80339 | 16 | The mutual-reference cluster + PTE0004; smallest unit that compiles |
| **3** | API pages 80315–80318 | 4 | Depend only on the tables |

Verified: **0 forward references**. Within batch 2, generate in this order — tables 80303,
80304, 80305, 80306, then parts 80320, 80321, then Card pages 80310, 80312, 80314, 80308,
then List pages 80307, 80309, 80311, 80313, then permission sets 80338, 80339.

Compile to **0 errors / 0 warnings** after every batch before starting the next.

---

## 4. `using` directives (verified against the 28.4 symbol file at Step 04)

| Referenced object | Namespace (verified at Step 04 against the 28.4 symbol file) |
|---|---|
| Customer (table 18) | `Microsoft.Sales.Customer` ✔ |
| Currency (table 4) | `Microsoft.Finance.Currency` ✔ |
| Base types / enums (this app) | `DSW.IPTracking` (own namespace) |

Every generated file begins:
```al
namespace DSW.IPTracking;

using Microsoft.Finance.Currency;    // only where Currency is referenced
using Microsoft.Sales.Customer;      // only where Customer is referenced
```

`using` statements must be **alphabetically sorted** — `Microsoft.Finance.Currency` before
`Microsoft.Sales.Customer` — or CodeCop reports `AA0477`. (SanityCheck SC-05)

### 4.1 File naming (CodeCop `AA0215`)
One object per file, named `<ObjectNameWithoutSpaces>.<Type>.al`:
`iptIPApp.Table.al`, `iptIPAppEdition.Table.al`, `iptIPApps.Page.al`, `iptIPAppCard.Page.al`,
`iptIPAppEditionsPart.Page.al`, `iptIPEntitlementAPI.Page.al`, `iptIPLicenseType.Enum.al`,
`IPTIPTrackRead.PermissionSet.al`, … (SanityCheck SC-06)

---

## 5. Standard object templates

### 5.1 Table template
```al
namespace DSW.IPTracking;
// using ... (only if a standard table is referenced)

table <ID> "ipt <Name>"
{
    Caption = '<Name>';
    DataClassification = CustomerContent;
    LookupPageId = "ipt <ListPage>";
    DrillDownPageId = "ipt <ListPage>";

    fields
    {
        field(<n>; "<Field>"; <Type>)
        {
            Caption = '<Field>';
            // NotBlank / MinValue / TableRelation / InitValue as specified
            // trigger OnValidate only where a rule is specified below
        }
    }
    keys
    {
        key(PK; <PK fields>) { Clustered = true; }
        // secondary keys as specified
    }
    trigger OnDelete()
    begin
        // referential-integrity guard as specified
    end;
}
```

### 5.2 List / Card page template
```al
namespace DSW.IPTracking;

page <ID> "ipt <PluralOrCardName>"
{
    PageType = List | Card;
    ApplicationArea = All;
    UsageCategory = Lists;              // List pages only
    SourceTable = "ipt <Name>";
    CardPageId = "ipt <Card>";          // List pages only
    Caption = '<Name>';

    layout
    {
        area(Content)
        {
            // List: repeater(Group) ; Card: group(General)
            field("<Field>"; Rec."<Field>")
            {
                ApplicationArea = All;
                ToolTip = '<self-describing tooltip>';
            }
        }
    }
}
```

### 5.3 API page template
```al
namespace DSW.IPTracking;

page <ID> "ipt <Name> API"
{
    PageType = API;
    Caption = '<Name> API';
    APIPublisher = 'dsw';
    APIGroup = 'iptIpManagement';
    APIVersion = 'v1.0';
    EntityName = '<entityName>';
    EntitySetName = '<entitySetName>';
    SourceTable = "ipt <Name>";
    ODataKeyFields = SystemId;
    DelayedInsert = true;               // all four API pages are editable
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(<camelCaseId>; Rec."<Field>")
                {
                    Caption = '<Field>';
                }
            }
        }
    }
}
```
No `Editable = false` on any API page in this project — all four use `DelayedInsert = true`.

---

## 6. Enum specs

### 6.1 `enum 80300 "ipt IP License Type"` — `Extensible = true`
| Ordinal | Value name | Caption |
|---|---|---|
| 0 | Perpetual | Perpetual |
| 1 | "FixedPricePerPeriod" | Fixed Price per Period |
| 2 | "PerUser" | Per User |
| 3 | "PerCompany" | Per Company |
| 4 | "PerEnvironment" | Per Environment |
| 5 | "PerTenant" | Per Tenant |
| 6 | "PerOther" | Per Other |

### 6.2 `enum 80301 "ipt IP Billing Period"` — `Extensible = true`
| 0 | Monthly | Monthly |
| 1 | Annual | Annual |
| 2 | Triennial | Triennial |

Period → date offset (used for Expiration Date): Monthly `<1M>`, Annual `<1Y>`, Triennial `<3Y>`.

### 6.3 `enum 80302 "ipt IP Entitlement Status"` — `Extensible = true`
| 0 | Gratis | Gratis |
| 1 | Active | Active |
| 2 | Demo | Demo |

---

## 7. Table specs

### 7.1 `table 80303 "ipt IP App"`
`LookupPageId`/`DrillDownPageId = "ipt IP Apps"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "Code" | Code[10] | `NotBlank = true` |
| 2 | "Description" | Text[250] | |
| 3 | "License Type" | Enum "ipt IP License Type" | |
| 4 | "Other" | Text[80] | ToolTip on page: *Define what Other is, e.g. Salesforce, Ticket, etc.* |
| 5 | "Default Billing Period" | Enum "ipt IP Billing Period" | |
| 6 | "Default Edition Code" | Code[10] | `TableRelation = "ipt IP App Edition"."Edition Code" where("IP App Code" = field("Code"))` |
| 10 | "Edition Count" | Integer | FlowField, `CalcFormula = count("ipt IP App Edition" where("IP App Code" = field("Code")))`; `Editable = false` |

Keys: `key(PK; "Code") { Clustered = true; }`
`OnDelete`: error if any `"ipt IP App Edition"`, `"ipt IP App Price"` or `"ipt IP Entitlement"` row exists with `"IP App Code" = "Code"`. Message: `You cannot delete IP App %1 because related editions, prices or entitlements exist.`

### 7.2 `table 80304 "ipt IP App Edition"`
`LookupPageId`/`DrillDownPageId = "ipt IP App Editions"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ipt IP App"."Code"` |
| 2 | "Edition Code" | Code[10] | `NotBlank` |
| 3 | "Description" | Text[80] | |
| 4 | "Unit Price" | Decimal | `MinValue = 0`; caption *Reference Unit Price* |

Keys: `key(PK; "IP App Code", "Edition Code") { Clustered = true; }`
Field-number buffer: next field starts at 10. (SanityCheck SC-13)
`OnDelete`: error if any `"ipt IP App Price"` or `"ipt IP Entitlement"` row references this `("IP App Code","Edition Code")`.

### 7.3 `table 80305 "ipt IP App Price"`
`LookupPageId`/`DrillDownPageId = "ipt IP App Prices"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ipt IP App"."Code"` |
| 2 | "Edition Code" | Code[10] | `NotBlank`; `TableRelation = "ipt IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"))` |
| 3 | "Billing Period" | Enum "ipt IP Billing Period" | |
| 4 | "Currency Code" | Code[10] | `TableRelation = Currency.Code`; blank = LCY |
| 5 | "Unit Price" | Decimal | `MinValue = 0` |

Keys: `key(PK; "IP App Code", "Edition Code", "Billing Period", "Currency Code") { Clustered = true; }`
Field-number buffer: next field starts at 10. (SanityCheck SC-13)
`OnDelete`: none (rate table).

### 7.4 `table 80306 "ipt IP Entitlement"`
`LookupPageId`/`DrillDownPageId = "ipt IP Entitlements"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "Entry No." | Integer | `AutoIncrement = true` |
| 2 | "Customer No." | Code[20] | `NotBlank`; `TableRelation = Customer."No."` |
| 3 | "Customer Name" | Text[100] | FlowField `lookup(Customer.Name where("No." = field("Customer No.")))`; `Editable = false` |
| 4 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ipt IP App"."Code"` |
| 5 | "Edition Code" | Code[10] | `NotBlank`; `TableRelation = "ipt IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"))` |
| 6 | "Description" | Text[80] | FlowField `lookup("ipt IP App Edition".Description where("IP App Code" = field("IP App Code"), "Edition Code" = field("Edition Code")))`; `Editable = false` |
| 7 | "Date of Purchase" | Date | `OnValidate`: recompute suggested "Expiration Date" (see rule R-1) |
| 8 | "Status" | Enum "ipt IP Entitlement Status" | `InitValue = Active` |
| 9 | "Billing Period" | Enum "ipt IP Billing Period" | `OnValidate`: recompute suggested "Expiration Date" (R-1) |
| 10 | "Quantity" | Decimal | `MinValue = 0`; `InitValue = 1` |
| 11 | "Expiration Date" | Date | user-editable; default per R-1 |
| 12 | "License Type" | Enum "ipt IP License Type" | FlowField `lookup("ipt IP App"."License Type" where("Code" = field("IP App Code")))`; `Editable = false` |
| 13 | "Unit Price" | Decimal | FlowField `lookup("ipt IP App Price"."Unit Price" where("IP App Code" = field("IP App Code"), "Edition Code" = field("Edition Code"), "Billing Period" = field("Billing Period"), "Currency Code" = const('')))`; `Editable = false` |

Keys:
`key(PK; "Entry No.") { Clustered = true; }`
`key(Cust; "Customer No.", "IP App Code", "Edition Code") { }`

**Rule R-1 (suggested Expiration Date):** when `"Date of Purchase"` and `"Billing Period"` are both set and `"Expiration Date"` is blank, set `"Expiration Date" := CalcDate(<offset for Billing Period, §6.2>, "Date of Purchase")`. Never overwrite a user-entered Expiration Date.

---

## 8. Page specs

### 8.1 UI pages
| ID | Name | PageType | SourceTable | Notes |
|---|---|---|---|---|
| 80307 | "ipt IP Apps" | List | "ipt IP App" | `UsageCategory = Lists`; `CardPageId = "ipt IP App Card"`. Columns: Code, Description, License Type, Default Billing Period, Default Edition Code, Edition Count |
| 80308 | "ipt IP App Card" | Card | "ipt IP App" | `group(General)`: Code, Description, License Type, Other, Default Billing Period, Default Edition Code. `part(Editions; "ipt IP App Editions Part")` on `"IP App Code" = field("Code")`. `part(Prices; "ipt IP App Prices Part")` on `"IP App Code" = field("Code")` |
| 80309 | "ipt IP App Editions" | List | "ipt IP App Edition" | `UsageCategory = Lists`; `CardPageId = "ipt IP App Edition Card"`. Columns: IP App Code, Edition Code, Description, Unit Price |
| 80310 | "ipt IP App Edition Card" | Card | "ipt IP App Edition" | `group(General)`: IP App Code, Edition Code, Description, Unit Price |
| 80311 | "ipt IP App Prices" | List | "ipt IP App Price" | `UsageCategory = Lists`; `CardPageId = "ipt IP App Price Card"`. Columns: IP App Code, Edition Code, Billing Period, Currency Code, Unit Price |
| 80312 | "ipt IP App Price Card" | Card | "ipt IP App Price" | `group(General)`: all five fields |
| 80313 | "ipt IP Entitlements" | List | "ipt IP Entitlement" | `UsageCategory = Lists`; `CardPageId = "ipt IP Entitlement Card"`. Columns: Entry No., Customer No., Customer Name, IP App Code, Edition Code, Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price |
| 80314 | "ipt IP Entitlement Card" | Card | "ipt IP Entitlement" | `group(General)`: Entry No., Customer No., Customer Name; `group(Product)`: IP App Code, Edition Code, Description, License Type; `group(Terms)`: Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price |
| 80320 | "ipt IP App Editions Part" | ListPart | "ipt IP App Edition" | Columns: Edition Code, Description, Unit Price |
| 80321 | "ipt IP App Prices Part" | ListPart | "ipt IP App Price" | Columns: Edition Code, Billing Period, Currency Code, Unit Price |

Every page field: `ApplicationArea = All` + `ToolTip`.

### 8.2 API pages (`PageType = API`, `APIPublisher = 'dsw'`, `APIGroup = 'iptIpManagement'`, `APIVersion = 'v1.0'`, `ODataKeyFields = SystemId`, `DelayedInsert = true`)

| ID | Name | EntityName | EntitySetName | SourceTable |
|---|---|---|---|---|
| 80315 | "ipt IP App API" | `iptIPApp` | `iptIPApps` | "ipt IP App" |
| 80316 | "ipt IP App Edition API" | `iptIPAppEdition` | `iptIPAppEditions` | "ipt IP App Edition" |
| 80317 | "ipt IP App Price API" | `iptIPAppPrice` | `iptIPAppPrices` | "ipt IP App Price" |
| 80318 | "ipt IP Entitlement API" | `iptIPEntitlement` | `iptIPEntitlements` | "ipt IP Entitlement" |

Field identifier map (camelCase; source field in quotes):

**80315 IP App API:** `code`←"Code", `description`←"Description", `licenseType`←"License Type", `other`←"Other", `defaultBillingPeriod`←"Default Billing Period", `defaultEditionCode`←"Default Edition Code", `editionCount`←"Edition Count", `systemId`←SystemId, `lastModifiedDateTime`←SystemModifiedAt.

**80316 IP App Edition API:** `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `description`←"Description", `unitPrice`←"Unit Price", `systemId`, `lastModifiedDateTime`.

**80317 IP App Price API:** `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `billingPeriod`←"Billing Period", `currencyCode`←"Currency Code", `unitPrice`←"Unit Price", `systemId`, `lastModifiedDateTime`.

**80318 IP Entitlement API:** `entryNo`←"Entry No.", `customerNo`←"Customer No.", `customerName`←"Customer Name", `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `description`←"Description", `dateOfPurchase`←"Date of Purchase", `status`←"Status", `billingPeriod`←"Billing Period", `quantity`←"Quantity", `expirationDate`←"Expiration Date", `licenseType`←"License Type", `unitPrice`←"Unit Price", `systemId`, `lastModifiedDateTime`.

---

## 9. Permission sets

### `permissionset 80338 "IPT - IP Track Read"`
`Caption = 'IP Tracking - Read'`, `Assignable = true`.
`Permissions = tabledata "ipt IP App" = R, tabledata "ipt IP App Edition" = R, tabledata "ipt IP App Price" = R, tabledata "ipt IP Entitlement" = R;`

### `permissionset 80339 "IPT - IP Track Edit"`
`Caption = 'IP Tracking - Edit'`, `Assignable = true`.
`IncludedPermissionSets = "IPT - IP Track Read";`
`Permissions = tabledata "ipt IP App" = IMD, tabledata "ipt IP App Edition" = IMD, tabledata "ipt IP App Price" = IMD, tabledata "ipt IP Entitlement" = IMD;`

Consumers additionally need `D365 BASIC` and read access to Customer (e.g. `D365 SALES DOC, EDIT` or equivalent) — state this in `Deployment.md`.

---

## 10. Special design notes
- **Singletons:** none.
- **Header/line pairs:** none — IP App ⇄ Editions ⇄ Prices are three independent top-level pages plus two ListParts on the IP App Card.
- **Naming conflicts / reserved keywords:** none identified; `Code`, `Description`, `Other`, `Status`, `Quantity` are standard field names, safe as quoted identifiers.
- **High-volume table:** `ipt IP Entitlement` is the only one expected to grow; `Entry No.` autoincrement PK + `Cust` secondary key cover the expected access paths.
- **camelCase conversions shown:** §8.2 map. "IP App Code" → `ipAppCode` (leading two-letter acronym lower-cased per API convention).
- **Localization (W1):** no field is excluded; there are no localized base-table fields referenced.

---

## 11. Step 04 outcome — all open items closed

Full record: `docs/SanityCheck.md`.

| # | Open item | Outcome |
|---|---|---|
| 1 | Customer = table 18, field `"No."`, ns `Microsoft.Sales.Customer` | **Confirmed** against `SymbolReference.json`; `"No."` is `Code[20]`, `Name` is `Text[100]`, neither obsolete |
| 2 | Currency = table 4, field `Code`, ns `Microsoft.Finance.Currency` | **Confirmed**; `Code` is `Code[10]`, not obsolete |
| 3 | `SystemModifiedAt` valid for `lastModifiedDateTime` | **Confirmed** by compiling an API page against these symbols |
| 4 | No `ObsoleteState` on any referenced standard field | **Confirmed** — none of the three carries the property |
| 5 | All entity/set names and field identifiers ≤ 30 | **Confirmed** for objects, fields, enum values, entity/set names and API field ids — **except** `permissionset`, whose limit is **20** (SC-01, resolved above) |

Defects found and resolved at Step 04: SC-01 (AL0305), SC-02 (batch forward references),
SC-03 (AA0101 → API URL change), SC-04 (PTE0004). The corrected object model compiles to
**0 errors / 0 warnings** under CodeCop + UICop + PerTenantExtensionCop.
