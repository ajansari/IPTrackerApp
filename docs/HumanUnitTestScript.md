# Human Unit Test Script — IP Tracking

*Runbook phase: PROVE / Step 12. Date: 2026-09-05. Written against extension version `1.2.0.1`.*
*Audience: a non-developer. No AL knowledge required. Follow in order — later tests depend on data created earlier.*

> **These tests have not been run.** Step 09's live green-team/red-team pass was skipped by
> instruction, so this is the *specification* of what must pass, not a record that it did.
> Nothing below has been executed against a running BC instance. Record actual results in the
> Result column as you go.

**Before you start:** the extension must be installed in the company you're testing, and you need
a user with `OCPF - IP Track Edit` plus normal BC access. Allow ~30 minutes.

---

## Part A — Setup (must pass first; everything else depends on it)

| # | Step | Expected result | Result |
|---|---|---|---|
| A1 | Search (Alt+Q) for **IP App Setup** and open it | Page opens. A single record exists (it creates itself on first open) | |
| A2 | Set **IP Entitlement Nos.** to an existing No. Series (e.g. one that produces `IPE00001`) | Value saves without error | |

> If A2 is skipped, **every** entitlement creation later will fail with "IP Entitlement Nos. must have a value". That's correct behaviour, not a bug.

## Part B — Green team: the catalogue (happy path)

| # | Step | Expected result | Result |
|---|---|---|---|
| B1 | Search for **IP Apps**, click **New** | Card opens, empty | |
| B2 | Enter Code `ACME1`, Description `Acme Platform` | Saves | |
| B3 | Set **License Type** to `Per Other` | An **Other** field appears that wasn't visible before | |
| B4 | Set **License Type** to `Per User` | The **Other** field disappears again | |
| B5 | Leave **Default Billing Period** untouched | It is blank — blank is the intended default, not a bug | |
| B6 | In the **Editions** part, add Edition Code `STD`, Description `Standard` | Row saves. IP App Code is filled in for you | |
| B7 | In the **Prices** part, add Edition `STD`, Billing Period `Annual`, leave Currency blank, Unit Price `1200` | Row saves (blank currency = local currency) | |
| B8 | Close and reopen the IP App card | **Edition Count** shows `1` | |

## Part C — Green team: entitlements + the cross-reference navigation

| # | Step | Expected result | Result |
|---|---|---|---|
| C1 | On the **ACME1** IP App card, click **Entitlements** | A list opens, filtered to this app, currently empty. The IP App column is not shown — it's implied | |
| C2 | Click **New** and pick any customer | **A new row is created and stays visible.** It must not vanish. (This was the 09F-13 defect — its fix is what C2 verifies) | |
| C3 | Set Edition `STD`, Billing Period `Annual`, Date of Purchase = today | **Expiration Date** auto-fills to today + 1 year; **Unit Price** auto-fills to `1200` | |
| C4 | Change **Unit Price** to `999` | The value sticks — it is editable, not locked | |
| C5 | Change **Billing Period** to `Monthly` | Unit Price stays `999` (a user-entered price is never overwritten) | |
| C6 | Note the **No.** — it should match your No. Series (e.g. `IPE00001`) | Assigned automatically; the field is not editable | |
| C7 | Enter a **License Key** on the Entitlement Card | Saves (Text, max 80 chars) | |
| C8 | Open the **Customer** you used → click **IP Entitlements** | The same entitlement is listed, this time with the Customer column hidden | |
| C9 | Click **New** on that customer's list, set app/edition | Row stays visible, Customer already filled in | |
| C10 | Open an **Item**, set its **IP App** to `ACME1` | Saves. (Not every item needs one — blank is valid) | |

## Part D — Red team: these must fail *gracefully* (a clean message, never a crash or silent loss)

| # | Step | Expected result | Result |
|---|---|---|---|
| D1 | Try to delete IP App **ACME1** | Blocked: "You cannot delete IP App ACME1 because related editions, prices, entitlements or items exist." | |
| D2 | Try to delete Edition **STD** | Blocked with a message naming the app and edition | |
| D3 | Delete the Price row from B7 | **Allowed** — prices are a rate table with no dependents. This is intended | |
| D4 | On an Entitlement, clear **Customer No.** and try to save | Blocked — the field is mandatory | |
| D5 | On an Entitlement, type a non-existent IP App code | Blocked — the value must exist in the IP App list | |
| D6 | On an Entitlement, set Edition to one belonging to a *different* app | Not offered in the lookup / rejected — editions are filtered by the chosen app | |
| D7 | Try to delete the **IP App Setup** record | Blocked: "You cannot delete the IP App Setup record." | |
| D8 | Sign in as a user with **only** `OCPF - IP Track Read` and try to edit anything | Blocked with a permission error, not a crash | |

## Part E — Green team: API (needs a REST client, e.g. Postman or VS Code REST Client)

Base URL and auth are in `Documentation.md` §3. Substitute your tenant/environment/company.

| # | Step | Expected result | Result |
|---|---|---|---|
| E1 | `GET {base}/$metadata` | Returns the schema; the four `ocpf…` entity sets are present | |
| E2 | `GET {base}/ocpfIPApps` | Returns `ACME1` from Part B | |
| E3 | `GET {base}/ocpfIPApps({systemId})` using the `systemId` from E2 | Returns exactly one record. (Note: the key is `systemId`, **not** `code`) | |
| E4 | `POST {base}/ocpfIPApps` with `{"code":"ACME2","description":"Second"}` | `201 Created` | |
| E5 | `PATCH` that record's `description`, with the `If-Match` etag from E4 | `200 OK`, value changed | |
| E6 | `POST {base}/ocpfIPEntitlements` with customer/app/edition/period | `201`; the response's `no` is populated by the No. Series | |
| E7 | Repeat E5 **without** the `If-Match` header | `412 Precondition Failed` — expected, not a bug | |

## Part F — Red team: API

| # | Step | Expected result | Result |
|---|---|---|---|
| F1 | `POST` an IP App with a field that doesn't exist (`{"nonsenseField":"x"}`) | `400 Bad Request` naming the unknown property — clean, not a 500 | |
| F2 | `GET {base}/ocpfIPApps(00000000-0000-0000-0000-000000000000)` | `404 Not Found` | |
| F3 | `PATCH` `no` on an entitlement | Rejected/ignored — it's read-only | |
| F4 | `PATCH` `customerName` or `licenseType` on an entitlement | Rejected/ignored — FlowFields are read-only | |
| F5 | `DELETE` an IP App that has editions | Fails with the same guard message as D1, surfaced as an API error | |
| F6 | Call any endpoint with a token lacking BC permissions | `401`/`403`, not a 500 | |

---

## Sign-off

| | |
|---|---|
| Tested by | |
| Date | |
| Version tested | `1.2.0.1` |
| Environment | |
| All Part A–C green-team tests passed | ☐ |
| All Part D/F red-team tests failed *gracefully* | ☐ |
| Defects raised (list) | |

Raise anything that fails into `TestingFeedback.md` verbatim, per the runbook's Testing Feedback
Log rule — don't summarise it away before it's recorded.
