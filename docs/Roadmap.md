# Roadmap — IP Tracking

*Forward-looking backlog. Not scheduled into a batch until pulled from here — this is where we
look for what to do next, not a commitment to build any of it. Populated from
`TestingFeedback.md` triage and direct human input.*

---

## R-1 — Create an IP Entitlement from a sales document

**Source:** Testing session 2026-09-05 (`TestingFeedback.md`).

**Idea:** When an Item is sold on a Sales Invoice or Sales Order to a customer, offer an option
to create a corresponding `ipt IP Entitlement` record for that customer.

**Open question (not yet resolved):** how to determine which Edition (and Billing Period,
Quantity, etc.) was actually sold. The sales line only carries the Item; the IP App association
added in 09F-06 is Item-level, not Item-*variant*-level, so there's no direct line from "this
sales line" to "this specific Edition." Needs design thought before this becomes a TDD entry —
candidates include: a new field on the sales line, a prompt at posting time, or extending the
Item↔IP App tie to be Item↔Edition instead of Item↔App.

**Status:** Idea only. Not designed, not scheduled.

---

## R-2 — Manual Nos. override for IP Entitlement `No.`

**Source:** ChangeLog Issue 09F-07 (2026-09-05), noticed while implementing.

**Idea:** The current No. Series wiring on `ocpf IP Entitlement."No."` is mandatory-series-only
— there's no "Manual Nos." escape hatch on `ocpf IP App Setup` the way many BC Setup tables offer
(a boolean that lets a user type their own number instead of taking the next series value). Not
requested; flagged as a reasonable, small future refinement if it turns out to matter.

**Status:** Idea only. Not designed, not scheduled.

---

*(Add new items above this line as they come up. Each entry: source, idea, open questions,
status.)*
