# Technical Design Document — IP Tracking

*Runbook phase: DESIGN / Step 03. Status: **Step 04 sanity check passed (2026-09-04); testing-feedback batch 09F-01…09F-08 applied (2026-09-05, see `ChangeLog.md` and `TestingFeedback.md`)**.*
*Self-sufficiency intent: a developer who has never seen this project can generate every object from this document alone.*

---

## 1. System identity (authoritative — from the Step 01 intake sheet, revised 2026-09-05 per 09F-05)

### 1.1 Extension identity
| Parameter | Value |
|---|---|
| Extension Name | `IP Tracking` |
| Publisher | `OnlyCopilotFans` |
| Deployment Target | `SaaS PTE` |
| Namespace | `OnlyCopilotFans.IPTracking` |
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
| AL Object Prefix | `ocpf` |
| APIPublisher | `'ocpf'` |
| APIGroup | `'ocpfIpManagement'` |
| APIVersion | `'v1.0'` |
| Namespace | `OnlyCopilotFans.IPTracking` |
| Permission Set Prefix | `OCPF - ` |

> **Permission set identifiers are capped at 20 characters** (not 30) — AL0305. `"OCPF - IP Track Read"` / `"OCPF - IP Track Edit"` are exactly 20. Captions carry the readable form. (SanityCheck SC-01; re-verified at the exact boundary after the 09F-05 rename)

Entity-naming (all ≤ 30 chars incl. prefix):
| Table | EntityName | EntitySetName |
|---|---|---|
| ocpf IP App | `ocpfIPApp` | `ocpfIPApps` |
| ocpf IP App Edition | `ocpfIPAppEdition` | `ocpfIPAppEditions` |
| ocpf IP App Price | `ocpfIPAppPrice` | `ocpfIPAppPrices` |
| ocpf IP Entitlement | `ocpfIPEntitlement` | `ocpfIPEntitlements` |

`ODataKeyFields = SystemId` on every API page. API base URL:
`/api/ocpf/ocpfIpManagement/v1.0/companies({id})/ocpfIPApps` (and siblings).

### 1.4 Platform & runtime
| Parameter | Value |
|---|---|
| AL Runtime | `17.0` |
| BC Application Minimum | `28.0.0.0` |
| Recommended BC Version | `28.4+` |
| Symbol Source | Base Application 28.4.53241.54031 (`.alpackages`) — `Platform="28.0.0.0" Runtime="17.0"` |

**Dependency (added 2026-09-05, per 09F-07):** Business Foundation (Microsoft,
`f3552374-a1f2-4356-848e-196002525837`, `28.4.53241.53312`) — provides codeunit "No. Series"
(310) and table "No. Series" (308), `Microsoft.Foundation.NoSeries`, used by the IP Entitlement
No. Series and the IP App Setup table.

### 1.5 Feature flags
`NoImplicitWith` — enabled/enforced (`app.json "features"`). Every field source prefixed `Rec.`.

---

## 2. Module grouping & ID sub-blocks

Single functional module: **IP Tracking**. Sub-blocks inside 80300–80339 (revised 2026-09-05 —
the Setup table/page and the Item/Customer ties consumed 7 of the former buffer IDs):

| Sub-block | Range | Contents |
|---|---|---|
| Enums | 80300–80302 | 3 enums |
| Tables | 80303–80306 | 4 tables |
| UI pages | 80307–80314 | 4 List + 4 Card |
| API pages | 80315–80318 | 4 API |
| Setup table | 80319 | `ocpf IP App Setup` |
| Card parts | 80320–80321 | Editions ListPart, Prices ListPart |
| Setup page | 80322 | `ocpf IP App Setup` |
| Extensions | 80323–80327 | Item tableextension; Item Card/List, Customer Card/List pageextensions |
| Catalog pages | 80328–80329 | `ocpf IP App Entitlements`, `ocpf Customer Entitlements` (09F-13 §2) |
| Growth / tail buffer | 80330–80337 | 8 IDs unallocated (20% headroom) |
| Permission sets | 80338–80339 | Read, Edit |

32 objects total (was 23 at BUILD-complete; +7 from the first 2026-09-05 feedback batch;
+2 catalog pages from 09F-13's second pass).

---

## 3. Batch / phase plan

Batches 1–3 (BUILD, 2026-09-04) unchanged — see §3.1. The 2026-09-05 feedback batch (§3.2) is a
new, separate batch: it revises existing objects and adds new ones, and was generated and
compiled as one unit rather than sub-batched, because the rename (namespace, prefix, publisher)
touches every existing file simultaneously and the new objects depend on the renamed ones.

### 3.1 Original BUILD batches (2026-09-04)
| Batch | Objects | Count | Why |
|---|---|---|---|
| **1** | Enums 80300–80302 | 3 | No dependencies; compiles standalone |
| **2** | Tables 80303–80306; List/Card pages 80307–80314; ListParts 80320–80321; permission sets 80338–80339 | 16 | Mutual-reference cluster + `PTE0004`; smallest unit that compiles |
| **3** | API pages 80315–80318 | 4 | Depend only on the tables |

### 3.2 Feedback batch (2026-09-05, issues 09F-01…09F-08)
| Objects | Count | Notes |
|---|---|---|
| All 23 batch 1–3 objects | 23 | Renamed (`ipt`→`ocpf`, namespace, permission-set identifiers); Edition drops "Unit Price"; Entitlement's `Entry No.`→`No.` (Code[20], No. Series); both enums gain a blank ordinal 0; both IP App pages and both new Customer pageextensions gain an "Entitlements"/"IP Entitlements" navigation action |
| `ocpf IP App Setup` (table 80319) + page 80322 | 2 | New — holds the No. Series code for Entitlement `No.` |
| `ocpf Item` tableextension (80323) | 1 | New — adds `"IP App"` field to Item |
| `ocpf Item Card`/`ocpf Item List` pageextensions (80324–80325) | 2 | New — surface the `"IP App"` field |
| `ocpf Customer Card`/`ocpf Customer List` pageextensions (80326–80327) | 2 | New — "IP Entitlements" navigation action, filtered by Customer No. |

Compiled as one unit (30 files): **0 errors / 0 warnings**, 4 pre-accepted info (`AW0006`,
unchanged from BUILD). Two real defects were found and fixed during this compile — logged in
`ChangeLog.md` 09F-09 and 09F-10 — rather than assumed correct in advance.

---

## 4. `using` directives

| Referenced object | Namespace |
|---|---|
| Customer (table 18) | `Microsoft.Sales.Customer` |
| Currency (table 4) | `Microsoft.Finance.Currency` |
| Item (table 27) | `Microsoft.Inventory.Item` |
| No. Series (table 308) / codeunit "No. Series" (310) | `Microsoft.Foundation.NoSeries` |
| Base types / enums (this app) | `OnlyCopilotFans.IPTracking` (own namespace) |

Every generated file begins:
```al
namespace OnlyCopilotFans.IPTracking;

using Microsoft.Finance.Currency;     // only where Currency is referenced
using Microsoft.Foundation.NoSeries;  // only where No. Series is referenced
using Microsoft.Inventory.Item;       // only in the Item extension objects
using Microsoft.Sales.Customer;       // only where Customer is referenced
```

`using` statements must be **alphabetically sorted** or CodeCop reports `AA0477` (SanityCheck
SC-05). **A page extension that extends a base-app page must `using` that page's owning
namespace even though the page itself carries no namespace prefix in AL syntax** — omitting it
produces `AL0247: The target Page '<Name>' for the extension object is not found`, found and
fixed during the 2026-09-05 compile (09F-09).

### 4.1 File naming (CodeCop `AA0215`)
One object per file, named `<ObjectNameWithoutSpaces>.<Type>.al`. Extension objects use their
own suffix, **not** the base type's: `TableExt` / `PageExt`, not `Table` / `Page`:
`ocpfIPApp.Table.al`, `ocpfIPAppSetup.Table.al`, `ocpfIPApps.Page.al`, `ocpfIPAppSetup.Page.al`,
`ocpfItem.TableExt.al`, `ocpfItemCard.PageExt.al`, `OCPFIPTrackRead.PermissionSet.al`, …

---

## 5. Standard object templates

### 5.1 Table template
```al
namespace OnlyCopilotFans.IPTracking;
// using ... (only if a standard table is referenced)

table <ID> "ocpf <Name>"
{
    Caption = '<Name>';
    DataClassification = CustomerContent;
    LookupPageId = "ocpf <ListPage>";
    DrillDownPageId = "ocpf <ListPage>";

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
namespace OnlyCopilotFans.IPTracking;

page <ID> "ocpf <PluralOrCardName>"
{
    PageType = List | Card;
    ApplicationArea = All;
    UsageCategory = Lists;              // List pages only
    SourceTable = "ocpf <Name>";
    CardPageId = "ocpf <Card>";         // List pages only
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
                // Visible = <PageBooleanVariable> where a field is conditionally shown
                // (§7.1 R-2) — never a raw Rec expression in the property value.
            }
        }
    }
}
```

### 5.3 API page template
```al
namespace OnlyCopilotFans.IPTracking;

page <ID> "ocpf <Name> API"
{
    PageType = API;
    Caption = '<Name> API';
    APIPublisher = 'ocpf';
    APIGroup = 'ocpfIpManagement';
    APIVersion = 'v1.0';
    EntityName = '<entityName>';
    EntitySetName = '<entitySetName>';
    SourceTable = "ocpf <Name>";
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

### 5.4 Table/page extension templates (new 2026-09-05)
```al
namespace OnlyCopilotFans.IPTracking;

using <BaseObject's owning namespace>;      // required — see §4

tableextension <ID> "ocpf <Name>" extends <BaseTable>
{
    fields
    {
        field(<ID>; "<Field>"; <Type>)
        {
            Caption = '<Field>';
            ToolTip = '<self-describing tooltip>';
            // TableRelation as specified
        }
    }
}
```
```al
namespace OnlyCopilotFans.IPTracking;

using <BaseObject's owning namespace>;

pageextension <ID> "ocpf <Name>" extends "<Base Page>"
{
    layout
    {
        addlast(<AnchorGroupOrControl>)
        {
            field("<Field>"; Rec."<Field>") { ApplicationArea = All; ToolTip = '...'; }
        }
    }
    actions
    {
        addlast(Navigation)
        {
            action(<Name>) { ApplicationArea = All; Caption = '...'; ToolTip = '...';
                Image = List; RunObject = page "ocpf <Target>"; RunPageLink = "<Field>" = field("<Field>"); }
        }
    }
}
```
`Image = Entity` is **not** a valid action image in this AL version (`AL0482`); use `Image = List`
for a "view related records" action (found during the 2026-09-05 compile, 09F-10).

---

## 6. Enum specs

### 6.1 `enum 80300 "ocpf IP License Type"` — `Extensible = true`
*Revised 2026-09-05, 09F-01: added a blank default (ordinal 0) and two new values.*

| Ordinal | Value name | Caption |
|---|---|---|
| 0 | `" "` (single-space quoted identifier) | *(blank)* — **default** |
| 1 | Perpetual | Perpetual |
| 2 | "FixedPricePerPeriod" | Fixed Price per Period |
| 3 | "PerUser" | Per User |
| 4 | "PerCompany" | Per Company |
| 5 | "PerEnvironment" | Per Environment |
| 6 | "PerTenant" | Per Tenant |
| 7 | "PerOther" | Per Other |
| 8 | Free | Free |
| 9 | FreeOpenSource | Free Open Source |

An enum value's internal name cannot be a truly empty string — AL requires at least one
character — so the blank/default value uses a single space as its quoted identifier
(`value(0; " ")`) with an empty `Caption`. Verified by compilation before use (not assumed).

**Renumbering note:** ordinals 1–7 were shifted up by one (previously 0–6) to make room for the
blank value at 0. This is a **one-time, deliberate exception** to the "extensible enums are only
ever appended to" rule — safe only because no data has ever been published/committed against the
old ordinals (BUILD had not reached Step 09 publish). Once this app is live, only append.

### 6.2 `enum 80301 "ocpf IP Billing Period"` — `Extensible = true`
*Revised 2026-09-05, 09F-03: added a blank default (ordinal 0).*

| Ordinal | Value name | Caption |
|---|---|---|
| 0 | `" "` | *(blank)* — **default** |
| 1 | Monthly | Monthly |
| 2 | Annual | Annual |
| 3 | Triennial | Triennial |

Period → date offset (used for Expiration Date): Monthly `<1M>`, Annual `<1Y>`, Triennial `<3Y>`.
Blank has no offset — rule R-1 (§7.4) simply does not fire until a real period is chosen.

**Default-value ripple (explicit decision by AJ, 2026-09-05):** this enum is shared by three
fields — `ocpf IP App."Default Billing Period"`, `ocpf IP App Price."Billing Period"`, and
`ocpf IP Entitlement."Billing Period"`. None of the three carries an explicit `InitValue`, so
**all three now default to blank**, not Monthly as before. A new Price row or Entitlement starts
with no Billing Period until the user picks one — which also means rule R-1 and the Entitlement's
`Unit Price` FlowField lookup produce nothing until then. This was a deliberate choice (the
alternative — keep Price/Entitlement defaulting to Monthly via explicit `InitValue` — was offered
and declined).

Same renumbering note as §6.1 applies (Monthly/Annual/Triennial shifted 0–2 → 1–3).

### 6.3 `enum 80302 "ocpf IP Entitlement Status"` — `Extensible = true`
*Unchanged.*
| 0 | Gratis | Gratis |
| 1 | Active | Active |
| 2 | Demo | Demo |

---

## 7. Table specs

### 7.1 `table 80303 "ocpf IP App"`
`LookupPageId`/`DrillDownPageId = "ocpf IP Apps"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "Code" | Code[10] | `NotBlank = true` |
| 2 | "Description" | Text[250] | |
| 3 | "License Type" | Enum "ocpf IP License Type" | defaults blank (§6.1) |
| 4 | "Other" | Text[80] | ToolTip on page: *Define what Other is, e.g. Salesforce, Ticket, etc.* — **page-conditional, see R-2 below** |
| 5 | "Default Billing Period" | Enum "ocpf IP Billing Period" | defaults blank (§6.2) |
| 6 | "Default Edition Code" | Code[10] | `TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("Code"))` |
| 10 | "Edition Count" | Integer | FlowField, `CalcFormula = count("ocpf IP App Edition" where("IP App Code" = field("Code")))`; `Editable = false` |

Keys: `key(PK; "Code") { Clustered = true; }`
`OnDelete`: error if any `"ocpf IP App Edition"`, `"ocpf IP App Price"`, `"ocpf IP Entitlement"`
**or `Item` (added 2026-09-05, 09F-12 — the Item↔IP App tie from 09F-06 is a referencing "child"
too, per FRD design rule 7, and the guard was updated to match once that gap was noticed)** row
exists with the matching code. Message: `You cannot delete IP App %1 because related editions,
prices, entitlements or items exist.`

**Rule R-2 (Other, conditionally visible — new 2026-09-05, 09F-02):** on the Card page (§8.1),
`"Other"` is shown only when `"License Type" = "License Type"::PerOther`. Implemented with a
page-scoped `Boolean` variable (`OtherVisible`) recomputed in `OnAfterGetCurrRecord` and in the
License Type field's `OnValidate` — **not** a direct Rec-expression in the `Visible` property.
Table-level, the field itself is unchanged — this is a UI concern only; the API always returns
`Other` regardless of License Type.

### 7.2 `table 80304 "ocpf IP App Edition"`
`LookupPageId`/`DrillDownPageId = "ocpf IP App Editions"`.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ocpf IP App"."Code"` |
| 2 | "Edition Code" | Code[10] | `NotBlank` |
| 3 | "Description" | Text[80] | |

**Removed 2026-09-05 (09F-04):** field 4 `"Unit Price"` (caption *Reference Unit Price*). It was
disconnected from the pricing engine (nothing calculated from it, nothing validated it against
`ocpf IP App Price`) and created the exact "which price is real" ambiguity SC-A-3 tried to
resolve by renaming it. `ocpf IP App Price` is now the sole source of anything price-shaped for
an edition. Removed from: this table, pages 80309/80310/80320, and API page 80316.

Keys: `key(PK; "IP App Code", "Edition Code") { Clustered = true; }`
Field-number buffer: next field starts at 10.
`OnDelete`: error if any `"ocpf IP App Price"` or `"ocpf IP Entitlement"` row references this
`("IP App Code","Edition Code")`.

### 7.3 `table 80305 "ocpf IP App Price"`
`LookupPageId`/`DrillDownPageId = "ocpf IP App Prices"`. *Unchanged except rename.*

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ocpf IP App"."Code"` |
| 2 | "Edition Code" | Code[10] | `NotBlank`; `TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"))` |
| 3 | "Billing Period" | Enum "ocpf IP Billing Period" | defaults blank (§6.2 ripple) |
| 4 | "Currency Code" | Code[10] | `TableRelation = Currency.Code`; blank = LCY |
| 5 | "Unit Price" | Decimal | `MinValue = 0` |

Keys: `key(PK; "IP App Code", "Edition Code", "Billing Period", "Currency Code") { Clustered = true; }`
`OnDelete`: none (rate table) — deliberate (SC-15).

### 7.4 `table 80306 "ocpf IP Entitlement"`
`LookupPageId`/`DrillDownPageId = "ocpf IP Entitlements"`.

**Key field renamed 2026-09-05 (09F-07):** `"Entry No."` (Integer, `AutoIncrement`) →
`"No."` (Code[20]), populated by the modern No. Series codeunit — not `NoSeriesManagement`
(deprecated), the current `codeunit "No. Series"` (310, `Microsoft.Foundation.NoSeries`),
verified against the Business Foundation symbols, not assumed.

| # | Field | Type | Properties / rules |
|---|---|---|---|
| 1 | "No." | Code[20] | No `NotBlank`, no `AutoIncrement` — populated in `OnInsert` (R-3 below); not user-editable |
| 2 | "Customer No." | Code[20] | `NotBlank`; `TableRelation = Customer."No."` |
| 3 | "Customer Name" | Text[100] | FlowField `lookup(Customer.Name where("No." = field("Customer No.")))`; `Editable = false` |
| 4 | "IP App Code" | Code[10] | `NotBlank`; `TableRelation = "ocpf IP App"."Code"` |
| 5 | "Edition Code" | Code[10] | `NotBlank`; `TableRelation = "ocpf IP App Edition"."Edition Code" where("IP App Code" = field("IP App Code"))` |
| 6 | "Description" | Text[80] | FlowField `lookup("ocpf IP App Edition".Description where("IP App Code" = field("IP App Code"), "Edition Code" = field("Edition Code")))`; `Editable = false` |
| 7 | "Date of Purchase" | Date | `OnValidate`: recompute suggested "Expiration Date" (R-1) |
| 8 | "Status" | Enum "ocpf IP Entitlement Status" | `InitValue = Active` (unchanged) |
| 9 | "Billing Period" | Enum "ocpf IP Billing Period" | defaults blank (§6.2 ripple); `OnValidate`: recompute R-1 |
| 10 | "Quantity" | Decimal | `MinValue = 0`; `InitValue = 1` |
| 11 | "Expiration Date" | Date | user-editable; default per R-1 |
| 12 | "License Type" | Enum "ocpf IP License Type" | FlowField `lookup("ocpf IP App"."License Type" where("Code" = field("IP App Code")))`; `Editable = false` |
| 13 | "Unit Price" | Decimal | **Not a FlowField (changed 2026-09-05, 09F-11).** Real stored field, `MinValue = 0`; suggested via rule R-4 (below) on `OnValidate` of IP App Code, Edition Code, Billing Period; user-editable, never overwritten once non-zero |
| 14 | "License Key" | Text[80] | New 2026-09-05, 09F-14. Plain field, no validation, no default. Not shown on the List (grid exposure of license keys wasn't wanted); shown on the Card and the API |

Keys:
`key(PK; "No.") { Clustered = true; }`
`key(Cust; "Customer No.", "IP App Code", "Edition Code") { }`

**Rule R-1 (suggested Expiration Date):** unchanged — when `"Date of Purchase"` and
`"Billing Period"` are both set (not blank) and `"Expiration Date"` is blank, set
`"Expiration Date" := CalcDate(<offset for Billing Period, §6.2>, "Date of Purchase")`. Never
overwrites a user-entered Expiration Date. Does not fire while Billing Period is blank.

**Rule R-3 (No. Series assignment — new 2026-09-05):**
```al
trigger OnInsert()
var
    IPAppSetup: Record "ocpf IP App Setup";
    NoSeries: Codeunit "No. Series";
begin
    if Rec."No." = '' then begin
        IPAppSetup.Get();
        IPAppSetup.TestField("IP Entitlement Nos.");
        Rec."No." := NoSeries.GetNextNo(IPAppSetup."IP Entitlement Nos.");
    end;
end;
```
Minimal-viable pattern: mandatory series, no "Manual Nos." override. A manual-entry escape hatch
is a reasonable v2 ask (candidate for `Roadmap.md`) but was not requested and is not built.

**Naming note:** the field's short `Caption` is `'No.'` (matching BC convention, e.g.
`Customer."No."`); every ToolTip and prose reference calls it "the IP Entitlement No." in full,
per AJ's instruction that the field be short on the grid but unambiguous in context.

**Rule R-4 (suggested Unit Price — new 2026-09-05, 09F-11):**
```al
procedure SuggestUnitPrice()
var
    IPAppPrice: Record "ocpf IP App Price";
begin
    if Rec."Unit Price" <> 0 then
        exit;

    if IPAppPrice.Get(Rec."IP App Code", Rec."Edition Code", Rec."Billing Period", '') then
        Rec."Unit Price" := IPAppPrice."Unit Price";
end;
```
Called from `OnValidate` of `"IP App Code"`, `"Edition Code"` and `"Billing Period"`. Field 13
is no longer a `FlowField` — the computed-field-pattern rule (runbook §03) requires deciding
explicitly between a read-only `FlowField` and a stored, suggested, user-overridable field; this
one needed the latter, mirroring R-1. **Known edge case:** 0 is used as the "not yet suggested"
sentinel, so a deliberately-entered `0` (e.g. a Gratis entitlement) is indistinguishable from
"unset" and may be silently re-suggested if App, Edition or Billing Period changes again
afterward. Accepted as a minor, documented limitation rather than adding a separate
"has the user touched this" flag for a single field.

**Rule R-5 (cross-reference catalog pattern — revised 2026-09-05, 09F-13, second pass):**

The first attempt at this fix (an `OnNewRecord` trigger on the shared general list, page 80313)
did **not** actually resolve the defect in testing — AJ reported it "still broken in v1.2.0.0"
from both directions. Rather than keep guessing, the real Base App pattern for exactly this
scenario was checked directly against the symbols (Operating Rule 2), not assumed:

**Verified from `Microsoft_Base Application` symbols** — Item Card's real "Ven&dors" action:
```
RunObject = 'Item Vendor Catalog'; RunPageLink = '"Item No." = field("No.")';
RunPageView = 'sorting("Item No.")';
```
Same `RunObject`/`RunPageLink` mechanism this project already used — that part was never wrong.
The difference: the target page ("Item Vendor Catalog", table "Item Vendor") has **no
`CardPageId`** — new records are created and edited **inline** in the list, never navigating to
a separate Card page — and the linking field (`"Item No."`) is simply **hidden**
(`Visible = false`), since it's implied by the direction you navigated from. Our original fix
kept `CardPageId = "ocpf IP Entitlement Card"` on the shared target list, which routes "New"
through a *separate* Card page object — breaking exactly this. The general list's `CardPageId`
is genuinely useful for its own direct/Tell-Me entry point; the fix isn't to remove it there,
it's to stop reusing that page for the cross-reference actions at all.

**Resolution — two new dedicated catalog pages, mirroring "Item Vendor Catalog" exactly:**
- `page 80328 "ocpf IP App Entitlements"` — List, no `CardPageId`, `"IP App Code"` hidden
  (`Visible = false`). Target of the "Entitlements" action on 80307/80308.
- `page 80329 "ocpf Customer Entitlements"` — List, no `CardPageId`, `"Customer No."` hidden.
  Target of the "IP Entitlements" action on the Customer pageextensions (80326/80327).

Both keep an `OnNewRecord` trigger reading `Rec.GetFilter` on their one relevant field as
defense-in-depth (harmless, and guards against any client-version nuance in native
`RunPageLink` defaulting) — but the structural fix (no `CardPageId`, field hidden) is what
actually mirrors the proven-correct Microsoft pattern. The general list (80313, unchanged
otherwise) had its now-unnecessary `OnNewRecord` removed — it's no longer reached via
`RunPageLink`. All four actions gained `RunPageView = sorting(...)` to match the real pattern.

---

## 8. Page specs

### 8.1 UI pages

| ID | Name | PageType | SourceTable | Notes |
|---|---|---|---|---|
| 80307 | "ocpf IP Apps" | List | "ocpf IP App" | `UsageCategory = Lists`; `CardPageId = "ocpf IP App Card"`. Columns: Code, Description, License Type, Default Billing Period, Default Edition Code, Edition Count. `action(Entitlements)` under `area(Navigation)`, `RunObject = page "ocpf IP App Entitlements"` (**retargeted 09F-13 §2** — was the general list 80313), `RunPageLink = "IP App Code" = field(Code)`, `RunPageView = sorting("IP App Code")` |
| 80308 | "ocpf IP App Card" | Card | "ocpf IP App" | `group(General)`: Code, Description, License Type, Other (**Visible = OtherVisible**, R-2), Default Billing Period, Default Edition Code. `part(Editions; "ocpf IP App Editions Part")` on `"IP App Code" = field("Code")`. `part(Prices; "ocpf IP App Prices Part")` on `"IP App Code" = field("Code")`. Same retargeted `Entitlements` action as 80307 |
| 80309 | "ocpf IP App Editions" | List | "ocpf IP App Edition" | `UsageCategory = Lists`; `CardPageId = "ocpf IP App Edition Card"`. Columns: IP App Code, Edition Code, Description — **Unit Price column removed (09F-04)** |
| 80310 | "ocpf IP App Edition Card" | Card | "ocpf IP App Edition" | `group(General)`: IP App Code, Edition Code, Description — **Unit Price field removed (09F-04)** |
| 80311 | "ocpf IP App Prices" | List | "ocpf IP App Price" | Unchanged except rename. Columns: IP App Code, Edition Code, Billing Period, Currency Code, Unit Price |
| 80312 | "ocpf IP App Price Card" | Card | "ocpf IP App Price" | Unchanged except rename. `group(General)`: all five fields |
| 80313 | "ocpf IP Entitlements" | List | "ocpf IP Entitlement" | `UsageCategory = Lists`; the general/Tell-Me entry point, `CardPageId = "ocpf IP Entitlement Card"` retained. Columns: **No.** (was Entry No.; `Editable = false`), Customer No., Customer Name, IP App Code, Edition Code, Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price. **License Key deliberately not shown here** (09F-14). **No longer a `RunPageLink` target (09F-13 §2)** — its `OnNewRecord` workaround was removed as unnecessary |
| 80314 | "ocpf IP Entitlement Card" | Card | "ocpf IP Entitlement" | `group(General)`: **No.** (`Editable = false`), Customer No., Customer Name; `group(Product)`: IP App Code, Edition Code, Description, License Type; `group(Terms)`: Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price, **License Key** (09F-14) |
| 80319 | *(table, not a page)* | | | |
| 80320 | "ocpf IP App Editions Part" | ListPart | "ocpf IP App Edition" | Columns: Edition Code, Description — **Unit Price removed (09F-04)** |
| 80321 | "ocpf IP App Prices Part" | ListPart | "ocpf IP App Price" | Unchanged except rename. Columns: Edition Code, Billing Period, Currency Code, Unit Price |
| 80328 | "ocpf IP App Entitlements" | List | "ocpf IP Entitlement" | **New, 09F-13 §2 (revised fix).** Dedicated catalog page mirroring Base App's "Item Vendor Catalog" exactly. No `UsageCategory`, no `CardPageId` — reached only via `RunObject`, edited inline. `"IP App Code"` hidden (`Visible = false`, implied by context). Columns: **No.** (`Editable = false`, added 10-01), Customer No., Customer Name, Edition Code, Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price. `OnNewRecord` defaults `"IP App Code"` from `Rec.GetFilter` (defense-in-depth) |
| 80329 | "ocpf Customer Entitlements" | List | "ocpf IP Entitlement" | **New, 09F-13 §2.** Same pattern, mirrored for the Customer direction. `"Customer No."` hidden. Columns: **No.** (`Editable = false`, added 10-01), IP App Code, Edition Code, Status, Billing Period, Quantity, Date of Purchase, Expiration Date, Unit Price. `OnNewRecord` defaults `"Customer No."` |
| 80322 | "ocpf IP App Setup" | Card | "ocpf IP App Setup" | **New (09F-07).** `UsageCategory = Administration`; `InsertAllowed = false`; `DeleteAllowed = false`. `OnOpenPage`: `if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end;` — singleton, standard Setup-page pattern. Field: "IP Entitlement Nos." |

Every page field: `ApplicationArea = All` + `ToolTip` (except the one conditionally-hidden field,
which still carries both — visibility is separate from the tooltip requirement).

### 8.2 API pages (`PageType = API`, `APIPublisher = 'ocpf'`, `APIGroup = 'ocpfIpManagement'`, `APIVersion = 'v1.0'`, `ODataKeyFields = SystemId`, `DelayedInsert = true`)

| ID | Name | EntityName | EntitySetName | SourceTable |
|---|---|---|---|---|
| 80315 | "ocpf IP App API" | `ocpfIPApp` | `ocpfIPApps` | "ocpf IP App" |
| 80316 | "ocpf IP App Edition API" | `ocpfIPAppEdition` | `ocpfIPAppEditions` | "ocpf IP App Edition" |
| 80317 | "ocpf IP App Price API" | `ocpfIPAppPrice` | `ocpfIPAppPrices` | "ocpf IP App Price" |
| 80318 | "ocpf IP Entitlement API" | `ocpfIPEntitlement` | `ocpfIPEntitlements` | "ocpf IP Entitlement" |

Field identifier map (camelCase; source field in quotes):

**80315 IP App API:** `code`←"Code", `description`←"Description", `licenseType`←"License Type", `other`←"Other", `defaultBillingPeriod`←"Default Billing Period", `defaultEditionCode`←"Default Edition Code", `editionCount`←"Edition Count", `systemId`←SystemId, `lastModifiedDateTime`←SystemModifiedAt.

**80316 IP App Edition API:** `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `description`←"Description", `systemId`, `lastModifiedDateTime`. **`unitPrice` removed 09F-04** (source field gone).

**80317 IP App Price API:** `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `billingPeriod`←"Billing Period", `currencyCode`←"Currency Code", `unitPrice`←"Unit Price", `systemId`, `lastModifiedDateTime`.

**80318 IP Entitlement API:** `no`←"No." (**was `entryNo`←"Entry No.", 09F-07**), `customerNo`←"Customer No.", `customerName`←"Customer Name", `ipAppCode`←"IP App Code", `editionCode`←"Edition Code", `description`←"Description", `dateOfPurchase`←"Date of Purchase", `status`←"Status", `billingPeriod`←"Billing Period", `quantity`←"Quantity", `expirationDate`←"Expiration Date", `licenseType`←"License Type", `unitPrice`←"Unit Price", `licenseKey`←"License Key" (**new, 09F-14**), `systemId`, `lastModifiedDateTime`.

### 8.3 Extension objects (new 2026-09-05, 09F-06 / 09F-08)

| ID | Object | Extends | Notes |
|---|---|---|---|
| 80323 | `tableextension "ocpf Item"` | table 27 Item | Adds `"IP App"` (Code[10], `TableRelation = "ocpf IP App".Code`, `DataClassification = CustomerContent` — added 10-01/10-02; an extension field on a Microsoft table inherits no table-level classification from this app; optional — not every item has an IP association) |
| 80324 | `pageextension "ocpf Item Card"` | page 30 "Item Card" | `addlast(Item)` — adds the `"IP App"` field to the existing `Item` group |
| 80325 | `pageextension "ocpf Item List"` | page 31 "Item List" | `addlast(Control1)` — the repeater's real internal name (confirmed against symbols, not assumed) |
| 80326 | `pageextension "ocpf Customer Card"` | page 21 "Customer Card" | `addlast(Navigation)` — action `"IP Entitlements"`, `RunObject = page "ocpf Customer Entitlements"` (**retargeted 09F-13 §2** — was the general list 80313), `RunPageLink = "Customer No." = field("No.")`, `RunPageView = sorting("Customer No.")` |
| 80327 | `pageextension "ocpf Customer List"` | page 22 "Customer List" | Same retargeted action as 80326 |

`addlast(Navigation)` targets the page's `area(Navigation)` directly — it does not require
finding and naming one of the base page's existing action *groups* (e.g. `&Customer`), which
would be a much more fragile anchor across BC versions.

---

## 9. Permission sets

### `permissionset 80338 "OCPF - IP Track Read"`
`Caption = 'IP Tracking - Read'`, `Assignable = true`.
`Permissions = tabledata "ocpf IP App" = R, tabledata "ocpf IP App Edition" = R, tabledata "ocpf IP App Price" = R, tabledata "ocpf IP App Setup" = R, tabledata "ocpf IP Entitlement" = R;`

### `permissionset 80339 "OCPF - IP Track Edit"`
`Caption = 'IP Tracking - Edit'`, `Assignable = true`.
`IncludedPermissionSets = "OCPF - IP Track Read";`
`Permissions = tabledata "ocpf IP App" = IMD, tabledata "ocpf IP App Edition" = IMD, tabledata "ocpf IP App Price" = IMD, tabledata "ocpf IP App Setup" = IMD, tabledata "ocpf IP Entitlement" = IMD;`

**`ocpf IP App Setup` added 2026-09-05** — `PerTenantExtensionCop`'s `PTE0004` requires every
app-owned table to have a matching permission set, and the new Setup table is no exception.
**The `ocpf Item` tableextension needs no permission-set entry** — `PTE0004` only fires for
tables this app *owns*; extending Microsoft's `Item` is covered by Item's own base permission
sets (confirmed by the compile producing no `PTE0004` for it, not assumed).

Consumers additionally need `D365 BASIC` and read access to Customer (e.g. `D365 SALES DOC, EDIT`
or equivalent) — state this in `Deployment.md` (still open, GA-01/Issue 08-01).

---

## 10. Special design notes
- **Singletons:** `ocpf IP App Setup` (new, 2026-09-05) — one record, PK `"Primary Key"` (Code[10]), the standard BC Setup-table convention (verified against `Sales & Receivables Setup` / `Marketing Setup`, not assumed). `DeleteAllowed = false` on the page blocks UI deletion; an unconditional table-level `OnDelete` error (09F-12) blocks it from code or a future API page too.
- **Header/line pairs:** none — IP App ⇄ Editions ⇄ Prices are three independent top-level pages plus two ListParts on the IP App Card.
- **Naming conflicts / reserved keywords:** none identified; `Code`, `Description`, `Other`, `Status`, `Quantity`, `No.` are standard field names, safe as quoted identifiers.
- **High-volume table:** `ocpf IP Entitlement` is the only one expected to grow; `No.` (Code[20], No. Series) PK + `Cust` secondary key cover the expected access paths.
- **camelCase conversions shown:** §8.2 map. "IP App Code" → `ipAppCode` (leading two-letter acronym lower-cased per API convention).
- **Localization (W1):** no field is excluded; there are no localized base-table fields referenced.
- **Conditional field visibility (R-2, new):** the one and only case in this app — `"Other"` on the IP App Card. Pattern: page-scoped `Boolean`, recomputed on `OnAfterGetCurrRecord` and on the driving field's `OnValidate`, bound via `Visible = <variable>`. Do not attempt a direct `Rec`-expression in a `Visible` property value.
- **Cross-reference navigation (new):** "view the other side" actions (IP App/List → Entitlements; Customer Card/List → IP Entitlements) use `RunObject` + `RunPageLink`, not a FactBox — analogous to BC's own Item↔Vendor "Item Vendor Catalog" pattern, per AJ's explicit request.

---

## 11. Step 04 outcome — all open items closed (historical, 2026-09-04)

Full record: `docs/SanityCheck.md`.

| # | Open item | Outcome |
|---|---|---|
| 1 | Customer = table 18, field `"No."`, ns `Microsoft.Sales.Customer` | **Confirmed** against `SymbolReference.json`; `"No."` is `Code[20]`, `Name` is `Text[100]`, neither obsolete |
| 2 | Currency = table 4, field `Code`, ns `Microsoft.Finance.Currency` | **Confirmed**; `Code` is `Code[10]`, not obsolete |
| 3 | `SystemModifiedAt` valid for `lastModifiedDateTime` | **Confirmed** by compiling an API page against these symbols |
| 4 | No `ObsoleteState` on any referenced standard field | **Confirmed** — none of the three carries the property |
| 5 | All entity/set names and field identifiers ≤ 30 | **Confirmed** for objects, fields, enum values, entity/set names and API field ids — **except** `permissionset`, whose limit is **20** (SC-01, resolved) |

Defects found and resolved at Step 04: SC-01 (AL0305), SC-02 (batch forward references),
SC-03 (AA0101 → API URL change), SC-04 (PTE0004).

## 12. Feedback batch outcome (2026-09-05) — see `ChangeLog.md` 09F-01…09F-10, `TestingFeedback.md`

Two real defects were found by compiling, not by inspection, exactly as at Step 04:

| Issue | Defect | Fix |
|---|---|---|
| 09F-09 | `AL0247`/`AL0118`/`AL0186` — 4 page extensions failed: the base page's owning namespace must be `using`-imported even though the base page itself has no namespace prefix | Added `using Microsoft.Inventory.Item;` / `using Microsoft.Sales.Customer;` to the four extension files |
| 09F-10 | `AL0482` — `Image = Entity` is not a valid action image in this AL version | Changed to `Image = List` on all four affected actions |

Final compile: **0 errors / 0 warnings**, 4 pre-accepted info (`AW0006`, unchanged).
