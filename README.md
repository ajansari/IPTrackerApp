# OnlyCopilotFans Intellectual Property Tracker for Business Central

A per-tenant extension (PTE) for Microsoft Dynamics 365 Business Central that records the
intellectual-property software assets your company licenses out — each product, its editions and
prices, and the register of which customer holds which product and edition.

Created by **AJ Ansari, Microsoft MVP**.

- **Publisher:** OnlyCopilotFans
- **Most recent version:** 1.2.0.1
- **Last updated:** 2026-09-10

---

## What it does

- **Catalogue** — maintain your products (*IP Apps*), their **editions**, and a **pricing matrix**
  keyed by edition, billing period and currency.
- **Entitlement register** — track which customer holds which product/edition, from when, until
  when, at what price, and under which licence key. The same customer may hold the same product
  more than once (renewals, separate environments).
- **In-client UI** — List and Card pages for all five entities, with Editions and Prices editable
  directly on the IP App card.
- **v1.0 API** — an OData API surface (`api/ocpf/ocpfIpManagement/v1.0`) over the same data, with
  all four entity sets writable.
- **Standard-table integration** — an optional *IP App* tag on `Item`, and navigation actions from
  the Customer card/list to that customer's entitlements.

## Requirements

| Item | Requirement |
|---|---|
| BC version | 28.0.0.0 or later (verified against Base Application 28.4.53241) |
| Deployment model | SaaS Per-Tenant Extension (PTE) |
| AL runtime | 17.0 |
| Dependency | Business Foundation (Microsoft) — provides the No. Series engine |
| Localization | W1 |
| Object ID range | 80300–80339 |

## Install & setup

1. Deploy `IP_Tracking_1.2.0.1.app` via **Extension Management → Manage → Upload Extension**.
2. Open **IP App Setup** and set **IP Entitlement Nos.** to a No. Series.
   *This step is required — entitlements cannot be created until it is configured.*
3. Assign permissions:
   - `OCPF - IP Track Read` — view the catalogue/register.
   - `OCPF - IP Track Edit` — maintain products, editions, prices, entitlements and setup.

   These cover this extension's tables only; users also need their standard Business Central
   permissions.

## Documentation

| Document | Audience |
|---|---|
| [docs/UserGuide.md](docs/UserGuide.md) | People using the app inside Business Central |
| [docs/Documentation.md](docs/Documentation.md) | Developers integrating via the API |
| [docs/Deployment.md](docs/Deployment.md) | Administrators installing the extension |
| [docs/FRD.md](docs/FRD.md) / [docs/TDD.md](docs/TDD.md) | Functional and technical design |
| [docs/ChangeLog.md](docs/ChangeLog.md) | What was built and why |

## License

See [LICENSE](LICENSE). Copyright AJ Ansari and OnlyCopilotFans.
