# Gap Analysis — IP Tracking

*Runbook phase: PROVE / Step 08 "Gap-Fit Test, Fidelity Validation". Date: 2026-09-04.*
*Status: **complete — 1 gap found, classified Intentional; exit gate met.***

> **Point-in-time record — not a living spec.** This reflects project state as of the date
> above (e.g. publisher/prefix may since have changed — see `ChangeLog.md`). For current
> status, read `docs/ProjectMemory.md` first.

**Inputs:** `docs/FRD.md`, `docs/TDD.md`, the built AL in `src/` (23 objects, 4 commits), `docs/ChangeLog.md`.

**Method — evidence, not recollection.** Every claim below was checked against the file on
disk with `grep`/inspection at the time of writing this document, not against memory of having
written the code. Field lists, FlowField formulas, page columns, group contents and permission
grants were extracted from the actual compiled source and compared line-for-line to TDD §7–§9.
The full project was recompiled at the end (`./scripts/build.sh`) to confirm no drift since
Batch 3: **0 errors, 0 warnings, 4 info** (unchanged).

---

## 1. Object inventory — FRD ⇄ TDD ⇄ as-built

| FRD §6 entity | TDD object(s) | As-built | Match |
|---|---|---|---|
| IP App | table 80303 | `src/Tables/iptIPApp.Table.al` — 7 fields | ✔ |
| IP App Edition | table 80304 | `src/Tables/iptIPAppEdition.Table.al` — 4 fields | ✔ |
| IP App Price | table 80305 | `src/Tables/iptIPAppPrice.Table.al` — 5 fields | ✔ |
| IP Entitlement | table 80306 | `src/Tables/iptIPEntitlement.Table.al` — 13 fields | ✔ |
| IP License Type | enum 80300 | `src/Enums/iptIPLicenseType.Enum.al` — 7 values | ✔ |
| IP Billing Period | enum 80301 | `src/Enums/iptIPBillingPeriod.Enum.al` — 3 values | ✔ |
| IP Entitlement Status | enum 80302 | `src/Enums/iptIPEntitlementStatus.Enum.al` — 3 values | ✔ |
| List/Card ×4 | pages 80307–80314 | 8 pages present, correct `SourceTable` each | ✔ |
| ListParts ×2 | pages 80320–80321 | present, correct `SourceTable` each | ✔ |
| API ×4 | pages 80315–80318 | present, correct `SourceTable` each | ✔ |
| Permission sets ×2 | 80338–80339 | present | ✔ |

**23/23 TDD objects built. 0 objects built that are not in the FRD/TDD (no scope creep). 0 FRD
entities without a built object.**

Field counts confirmed against TDD §7 exactly: App 7, Edition 4, Price 5, Entitlement 13 — no
field silently dropped or added.

---

## 2. Rule-by-rule fidelity — TDD → as-built

| Rule (TDD ref) | As-built evidence | Match |
|---|---|---|
| App `OnDelete` guard vs Edition/Price/Entitlement (§7.1) | `iptIPApp.Table.al` — `IsEmpty()` on all three, correct error message with `%1` | ✔ |
| Edition `OnDelete` guard vs Price/Entitlement (§7.2) | `iptIPAppEdition.Table.al` — `IsEmpty()` on both, correct error message | ✔ |
| Price has **no** `OnDelete` guard (§7.3, rate table) | Confirmed absent | ✔ intentional (SC-15) |
| R-1 suggested Expiration Date (§7.4) | `SuggestExpirationDate()` procedure; called from **both** `"Date of Purchase"` and `"Billing Period"` `OnValidate` triggers; guards on blank purchase date and non-blank expiration date; `CalcDate` offsets `<1M>`/`<1Y>`/`<3Y>` match §6.2 exactly | ✔ |
| Every FlowField `Editable = false` (§4.2) | 5 FlowFields across the 4 tables (Edition Count, Customer Name, Description, License Type, Unit Price) — all 5 have `Editable = false` | ✔ |
| 4-key Unit Price lookup incl. `"Currency Code" = const('')` (§7.4) | Present verbatim in `iptIPEntitlement.Table.al` | ✔ |
| `LookupPageId`/`DrillDownPageId` → own List page (§5.1, §7.1–§7.4) | All 4 tables point to their List page by exact name | ✔ |
| `CardPageId` on every List page (§5.2) | All 4 List pages set it to the matching Card | ✔ |
| IP App Card hosts both parts with correct `SubPageLink` (§8.1) | Both `part()` blocks present, both `SubPageLink = "IP App Code" = field("Code")` | ✔ |
| List/Part column sets (§8.1) | Extracted from all 6 list-type pages — every column present, none extra, same order as spec | ✔ |
| Card group contents incl. 3-group split on Entitlement Card (§8.1) | Extracted — General/Product/Terms groups match field-for-field | ✔ |
| API field identifier map, all 4 pages (§8.2) | Extracted from all 4 API pages — every `camelCase` identifier and its source field matches §8.2 exactly, same order | ✔ |
| API page properties (§5.3, §8.2) | `APIPublisher='dsw'`, `APIGroup='iptIpManagement'`, `APIVersion='v1.0'`, `ODataKeyFields=SystemId`, `DelayedInsert=true`, no `Editable=false` on any API page | ✔ |
| Permission sets — Read/Edit content (§9) | `IPT - IP Track Read`: R on all 4 tables. `IPT - IP Track Edit`: `IncludedPermissionSets` + IMD on all 4. Names 19/19 chars (SC-01) | ✔ |

**0 rules implemented differently from the TDD without a ChangeLog entry.** Every batch's
ChangeLog entry ("no deviation — generated verbatim") holds up under this line-by-line check.

---

## 3. FRD requirements not literally restated in the TDD

The FRD carries a few statements the TDD doesn't restate word-for-word; each was traced
independently to code or to a deliberate scheduling decision.

| FRD requirement | Where it lives |
|---|---|
| §5.7 referential integrity on delete | `OnDelete` guards, §2 above |
| §7.4 "no Expired status, a date represents lapse" | `Status` enum has 3 values (Gratis/Active/Demo), no fourth; `Expiration Date` is the only lapse signal — matches |
| §8 NFR: 0 errors/0 warnings, warnings as errors | `scripts/build.sh` enforces this on every batch; verified again at the top of this document |
| §8 NFR: no `ObsoleteState` reference | `grep -rn "ObsoleteState" src/` → none; the three standard fields referenced (`Customer."No."`, `Customer.Name`, `Currency.Code`) were confirmed non-obsolete at Step 04 | ✔ |
| §8 NFR: bounded FlowFields on list pages | `Edition Count` (count) and `Unit Price` (single lookup) are both single-row-bounded per SC-12's clarified wording | ✔ |
| §8 NFR: IDs strictly 80300–80339 | `preflight.py` rule ID-01 enforces this on every batch | ✔ |

---

## 4. Gaps found

### GA-01 — Consumer permission documentation not yet written
**Type:** FRD requirement not yet implemented.
**FRD §7.6:** *"Documentation states the base `D365 BASIC` + Customer read permissions consumers also need."*
**Finding:** No such document exists yet. This is not a code gap — permission sets 80338/80339 are built and correct — it is a documentation gap.
**Classification: Intentional.** Deferred at Step 04 sign-off (SanityCheck SC-14) to Step 12 ("Document the Code"), where `Deployment.md` is already a scheduled deliverable. TDD §9 carries the substance of the guidance (`D365 BASIC` + a Customer-read set such as `D365 SALES DOC, EDIT`); it only needs to be published as its own document.
**Resolution:** No action now. Tracked to Step 12; will be closed when `Deployment.md` is written.

**No other gap was found.** No FRD entity without a built object, no built object without an FRD entity, no TDD rule left unimplemented, no implementation contradicting the FRD, no undisclosed deviation from the TDD.

---

## 5. Exit gate

| Gate condition | Status |
|---|---|
| Every gap classified and resolved or scheduled | **Met** — 1 gap (GA-01), classified Intentional, scheduled to Step 12 |
| No unexplained divergence from FRD/TDD | **Met** — every object, field, rule and property checked against source; all match |

**No gap-fill work items required** — GA-01 is documentation, not code, and needs no reserved
growth ID.

**Next:** Step 09 — Package and Test the App (deploy `out/app.app` to `v29Sandbox`; confirm
whether that environment's BC version needs v29 symbols, per the open item from SanityCheck
SC-11).
