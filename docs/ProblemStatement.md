# Problem Statement — IP Tracking (PTE)

*Runbook phase: DEFINE / PRE-01. Status: drafted by agent under time constraint; pending Functional Consultant sign-off.*

## Purpose
Track the intellectual-property software assets our company licenses out, the editions of
each, their pricing, and which customers hold which IP app / edition (a Service-Item-style
register).

## Target consumers
- **Internal BC users** — maintain the catalogue and the customer entitlement register through List/Card pages.
- **Integration / BI** — read (and optionally write) the same data through v1.0 API pages (`$metadata`, OData).

## In scope
- Master catalogue: **IP App**, **IP App Edition**, **IP App Price** (pricing matrix).
- **IP Entitlement** register: customer ⇄ IP app ⇄ edition, with purchase date, status, billing period, quantity, expiration.
- List + Card + API page per table.
- Read-only and read/write permission sets.

## Out of scope (v1)
- Billing / invoicing / posting; no ledger entries, no integration to Sales documents.
- Currency conversion (Currency Code is captured, not converted).
- Number-series-driven codes and a module Setup table (deferred — see ChangeLog A-4).
- Usage metering, contract renewal automation, approval workflow.

## Domain vocabulary
IP App, Edition, License Type, Billing Period, Entitlement, Pricing matrix, Gratis/Demo/Active.

## Open questions carried forward (answered by agent assumption — see ChangeLog "Assumptions A-1..A-9")
1. Price duplication between Edition and Pricing → resolved: Edition holds reference price, Pricing holds period/currency-specific price.
2. IP App "Edition" field → resolved as **Default Edition Code** (pointer to one edition).
3. Entitlement key → **Entry No.** (autoincrement); same customer+app+edition may repeat.
4. Status has no terminal value → **Expiration Date** represents lapse, not a status.
