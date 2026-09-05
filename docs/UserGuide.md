# IP Tracking — User Guide

*For people using IP Tracking inside Business Central. No technical knowledge assumed.*
*Version `1.2.0.1` · 2026-09-05*

> Looking for something else? `Documentation.md` is the API/integration reference for developers.
> `Deployment.md` is for the administrator installing this. This guide is for using the app.

---

## 1. What this app is for

IP Tracking keeps a record of the software products your company licenses out to customers:

- **What you sell** — each product ("IP App"), its **editions**, and its **prices**.
- **Who has what** — the **entitlement** register: which customer holds which product and edition,
  from when, until when, at what price, under what licence key.

Think of it as a catalogue plus a register of who owns what.

## 2. The five screens

| Screen | What it holds | Find it by searching (Alt+Q) |
|---|---|---|
| **IP Apps** | Your products | "IP Apps" |
| **IP App Editions** | The editions of each product (Standard, Pro…) | "IP App Editions" |
| **IP App Prices** | The price list — per edition, per billing period, per currency | "IP App Prices" |
| **IP Entitlements** | Who holds what | "IP Entitlements" |
| **IP App Setup** | One-time configuration | "IP App Setup" |

You rarely need Editions and Prices as standalone screens — both are editable directly on the
IP App card, which is usually easier.

---

## 3. First-time setup (once, by an administrator)

Open **IP App Setup** and set **IP Entitlement Nos.** to a number series.

This is what assigns each entitlement its number (e.g. `IPE00001`). **Until it's set, you cannot
create any entitlement** — you'll get a message telling you the field must have a value. That's
expected, not a fault.

---

## 4. Adding a product

1. Search for **IP Apps** → **New**.
2. Fill in:

| Field | What to put in it |
|---|---|
| **Code** | Short unique identifier, e.g. `ACME1`. Required |
| **Description** | The full product name |
| **License Type** | How it's licensed — Perpetual, Per User, Free, etc. Starts blank |
| **Other** | *Only appears when License Type is "Per Other".* Type what "other" means here — e.g. "per Salesforce org", "per ticket" |
| **Default Billing Period** | The period proposed on new prices/entitlements. Starts blank |
| **Default Edition Code** | Which edition to treat as the default (fill this after adding editions) |
| **Edition Count** | Counts itself — you can't type in it |

> **Why the Other field keeps disappearing:** it's only relevant when the licence type is "Per
> Other", so it hides itself otherwise. Nothing is lost — switch back and your text is still there.

### Adding editions and prices

On the same IP App card, scroll to the two sections at the bottom:

- **Editions** — add a row per edition: Edition Code (`STD`, `PRO`) and Description.
- **Prices** — add a row per priced combination: Edition, Billing Period, Currency Code, Unit Price.

**Leave Currency Code blank for your local currency.** A blank currency is the normal case, not an
omission. You can have several price rows for the same edition — one per billing period and
currency.

---

## 5. Recording that a customer has bought something

**The easiest way** is from the product or the customer, because it fills in half the record for you.

### From the product
1. Open the **IP App** → click **Entitlements** in the ribbon.
2. Click **New**. The product is filled in automatically — you won't even see the column, because
   everything in that list is for this product.

### From the customer
1. Open the **Customer** → click **IP Entitlements** in the ribbon.
2. Click **New**. The customer is filled in automatically.

### Then fill in the rest

| Field | Notes |
|---|---|
| **No.** | Assigned automatically. You can't type in it |
| **Customer No.** / **IP App Code** | Whichever wasn't filled in for you |
| **Edition Code** | Only editions belonging to the chosen product are offered |
| **Date of Purchase** | When they bought it |
| **Billing Period** | Monthly / Annual / Triennial |
| **Expiration Date** | **Fills itself in** once purchase date and billing period are both set — purchase date plus one month, one year, or three years. Change it if you need something different |
| **Status** | Starts as *Active*. Also *Gratis* or *Demo* |
| **Quantity** | Defaults to 1 |
| **Unit Price** | **Fills itself in** from your price list. You can overwrite it — a price you type is never overwritten afterwards |
| **License Key** | The key issued to the customer, if you track it |

> **The same customer can hold the same product more than once** — that's intentional, for
> renewals or separate environments. Each is its own entitlement with its own number.

### Two things that fill themselves in

Both are *suggestions*, not locks — overwrite either whenever you need to:

- **Expiration Date** appears once purchase date *and* billing period are set. If billing period
  is blank, nothing is suggested.
- **Unit Price** appears once product, edition and billing period are set, taken from the price
  list in your local currency. It only fills in while the price is still zero — once you've typed
  a real figure, changing the product or period won't overwrite it.

---

## 6. Linking a product to an inventory item

If you also sell a product as a stock/service **Item**, open the Item and set the **IP App**
field. This is optional — most items won't have one. It's a tag, so you can see which item relates
to which licensed product.

---

## 7. When something is refused

These messages are the app protecting your data, not errors to work around.

| Message | Why | What to do |
|---|---|---|
| "You cannot delete IP App … because related editions, prices, entitlements or items exist." | Something still points at it | Delete or repoint those first. Consider setting it inactive instead of deleting |
| "You cannot delete Edition … because related prices or entitlements exist." | Same, one level down | Remove the prices/entitlements first |
| "You cannot delete the IP App Setup record." | It's the single configuration record the app needs | Nothing — this is by design |
| "IP Entitlement Nos. must have a value…" | Number series not configured | See §3 |
| Edition you want isn't in the list | Editions are filtered to the chosen product | Check the IP App is right; add the edition to that product first |

**Prices can be deleted freely** — they're a rate list, and deleting one doesn't disturb existing
entitlements, which keep the price recorded at the time.

---

## 8. Things worth knowing

- **Blank is a real starting value** for License Type and Billing Period — they don't default to
  anything, so nothing is chosen for you by accident.
- **Expiration Date is not a status.** An entitlement doesn't become "Expired" — you'll see the
  date has passed. Filter or sort by Expiration Date to find lapsed ones.
- **The price on an entitlement is a snapshot.** Changing your price list later doesn't rewrite
  entitlements already recorded.
- **License Key isn't shown in list views**, only on the entitlement card — deliberate, so keys
  aren't on screen when you're scrolling a list in front of others.

## 9. Who can do what

| Permission set | What it allows |
|---|---|
| `OCPF - IP Track Read` | View everything, change nothing |
| `OCPF - IP Track Edit` | View and maintain products, editions, prices, entitlements and setup |

Your administrator assigns these alongside your normal Business Central permissions. If a screen
is missing or read-only when you expect otherwise, that's the place to check.
