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

## R-3 — Rename the "IP App" entity

**Source:** Discussion 2026-09-04/05 (before the 09F feedback batch). Explicitly deferred by the
human — "hold off on that for now" — until testing is complete; captured here so the thread
isn't lost, not because a decision is imminent.

**Problem:** "IP App" reads badly on two fronts — "IP" collides with *IP address* well before
*intellectual property* in most readers' minds, and "App" collides with Business Central's own
vocabulary (an "app" is the extension itself — `app.json`, "publish the app"). Given what the
entity actually is (per `ProblemStatement.md`: the company's *own* software products, licensed
out to customers — not third-party software being tracked), a clearer name is available.

**Candidates discussed, ranked:**

1. **"Licensed Product"** (recommended) — `ocpf Licensed Product`, `ocpf Licensed Product Edition`, `ocpf Licensed Product Price`. Unambiguous, doesn't collide with "Item" (BC's own term for physical/service goods) the way plain "Product" would.
2. **"Software Title"** — `ocpf Software Title`. Clean, common in software/media licensing verticals; slightly less natural for straight B2B licensing language.
3. **"Offering"** — `ocpf Offering`, `ocpf Offering Edition`. Short, current SaaS vocabulary; "Offering Edition"/"Offering Price" read a little awkwardly.
4. **"IP Asset"** — smallest change (drops "App", keeps "IP"), but keeps the IP-address collision risk that's the main reason for renaming at all.

**Ripple if actioned:** table 80303's name, its List/Card/API page names and captions, the enum
"ocpf IP License Type" (→ e.g. "Licensed Product License Type" or just "License Type"), TDD/FRD/
ObjectRegister, `app.json`'s extension `name` (currently "IP Tracking" — would likely become
something like "Licensed Product Tracking" or "Software License Tracking" to match), and the
Item tableextension's "IP App" field/caption (09F-06) and the "Entitlements"/"IP Entitlements"
navigation actions (09F-08), which all reference the entity by name. No ID or field-count
changes — pure rename.

**Status:** Idea only, deliberately deferred. Revisit once testing is done.

---

*(Add new items above this line as they come up. Each entry: source, idea, open questions,
status.)*
