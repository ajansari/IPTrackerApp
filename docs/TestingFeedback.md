# Testing Feedback Log — IP Tracking

*Required by the runbook's "Testing Feedback Log" (ALL ALONG — Continuous Discipline), added
2026-09-05 in response to this very session's feedback. Captures what the tester actually said,
verbatim, before it is triaged into ChangeLog Issues or Roadmap items — distinct from the
ChangeLog (records decisions/reasoning) and the Step 09 test-run record (automated pass/fail).*

---

## Session 2026-09-05 — first manual test pass, post-Step 09 (partial packaging)

**Tested by:** AJ Ansari. **Context:** first hands-on review after BUILD + Step 08 Gap-Fit +
partial Step 09 (package built, not yet published/tested live).

### Raw feedback (verbatim)

> On the IP App, we need more Values in License Type
> - '' (i.e, blank; this should be the default value)
> - Free
> - Free Open Source
>
> On the same page, the field "Other" should be conditionally visible and only shown
> LicenseType::"Per Other"
>
> The "Default Billing Period" field should have one more value
> - '' (i.e., blank and it should be the default value)
>
> In Editions, remove the `Reference Unit price` field on table and any associated pages.
>
> For our app, Prefix should be `ocpf`, Publisher should be `OnlyCopilotFans`. Are there any
> other references to DSW or DSWi?
>
> Create a tie on the Item card to IP. As in, on the Item table, card and list page, there
> should be a field called IP App and a user can choose an IP app record to associate with that
> item. Not every item will have an IP association.
>
> For IP entitlements, I don't like the Entry No. field as the default. It should be called
> No. (and elsewhere if needed, referred to as the IP Entitlement No.) and this should be
> Code20. And it should be populated via No. Series management codeunit (the new one, not the
> old one). And of course, this means we need a IP App Setup table and page for all of this.
>
> For IP entitlements, we should have a lookup from both the IP app card/list pages and the
> Customer card/list pages to see if who has that IP, or which IP is owned by said customer.
> Kinda like the Item-Vendor thing in BC.
>
> Create a new file Roadmap.md and I'll identify some stuff to add to it. We will not do this
> now but in the future, we'll look there for what to do next and add things from there. One
> functionality to add to our roadmap: When we sell an Item from a Sales Invoice or Sales Order
> to a customer, we should have an option for an IP Entitlement record to be created. Still not
> sure how we'd track which edition, etc. was sold.
>
> Lastly, two questions - and I want you to answer these first:
> Will my feedback from testing be recorded somewhere? Where? And if not, we need to extend the
> framework to log this somewhere consistent
> Is Memory.md truly being used? Does the framework explicitly call for it or did the model just
> decide it? If not in framework, add to it

### Triage

| # | Item | Disposition | Tracking |
|---|---|---|---|
| 1 | Testing feedback not durably logged | Fixed now | This document; runbook "Testing Feedback Log" section added |
| 2 | Memory.md not framework-mandated | Confirmed not mandated; framework extended | Runbook "Session Memory" section added |
| 3 | License Type: add blank (default), Free, Free Open Source | **Done** | ChangeLog Issue 09F-01 |
| 4 | "Other" conditionally visible on License Type = Per Other | **Done** | ChangeLog Issue 09F-02 |
| 5 | Default Billing Period: add blank (default) | **Done** — human chose "let all three [Default Billing Period, IP App Price.Billing Period, IP Entitlement.Billing Period] default blank" when the ripple was flagged | ChangeLog Issue 09F-03 |
| 6 | Remove Reference Unit Price (table + pages) | **Done** — supersedes the "hold off" from the prior session | ChangeLog Issue 09F-04 |
| 7 | Rename prefix `ipt`→`ocpf`, publisher `DSW`→`OnlyCopilotFans`; audit other DSW/DSWi refs | **Done** — audit found the namespace `DSW.IPTracking` also needed renaming (not explicitly asked, caught by "any other DSW references") | ChangeLog Issue 09F-05 |
| 8 | Item ⇄ IP App tie (field on Item table/Card/List) | **Done** | ChangeLog Issue 09F-06 |
| 9 | Entitlement `Entry No.` → `No.` (Code[20], No. Series-driven) + IP App Setup table/page | **Done** — added a Business Foundation app dependency for the No. Series codeunit | ChangeLog Issue 09F-07 |
| 10 | Entitlement lookup from IP App Card/List and Customer Card/List | **Done** | ChangeLog Issue 09F-08 |
| 11 | Roadmap.md created | **Done** | `docs/Roadmap.md` |
| 12 | Sales Invoice/Order → optional IP Entitlement creation | Scheduled, not built | `docs/Roadmap.md` item R-1 |

Items 3–10 implemented and compiled as one batch (30 files, 0 errors/0 warnings). Two additional
defects were found by the compile itself, not requested by the tester — logged as ChangeLog
Issues 09F-09 (missing `using` on 4 page extensions) and 09F-10 (`Image = Entity` invalid).

---

## Session 2026-09-05 — follow-up (same day, second pass)

**Tested by:** AJ Ansari. **Context:** immediately following the first pass above.

### Raw feedback (verbatim)

> Let's also add the rename thread to the roadmap - with your current suggestions. We can then
> decide if we want to do it later.
>
> Are these two now enshrined in the BC_App_Build_Routine_Agent.md file?
> - Unit Price on IP Entitlement card should auto-populate BUT should be editable
> - What deletion controls should we have?
>
> If not, do it.
>
> Also enshrine in that file that when we create documentation, it should create a mermaid
> schema showing the table relationships (both custom and the standard objects that are
> affected via this extension).
>
> And what on earth is Remote Control that is showing up in the Claude Code sidecar?

### Triage

| # | Item | Disposition | Tracking |
|---|---|---|---|
| 1 | IP App entity rename thread → Roadmap | Done | `docs/Roadmap.md` item R-3 |
| 2 | "Unit Price should auto-populate but be editable" — enshrined? | Not previously in the runbook. Generalized into a runbook rule (Step 03 per-field spec) **and** implemented for this app (converted from FlowField to a suggested, editable stored field) | Runbook §03; ChangeLog Issue 09F-11 |
| 3 | "What deletion controls should we have?" — enshrined? | Not previously in the runbook as a required consideration. Added as a Step 04 checklist item (generalizable). The *specific* open question for this app's newest objects (IP App Setup, Item tie) is a live design decision, not something to decide unilaterally — raised back to the human rather than assumed | Runbook §04 checklist; open question raised in this response |
| 4 | Mermaid schema diagram requirement | Not previously in the runbook. Added to Step 12 | Runbook §12 |
| 5 | "What is Remote Control?" | Answered directly (Claude Code product question, not a project item) | — |
