# Deployment Guide — IP Tracking

*Runbook phase: PROVE / Step 12. Date: 2026-09-05. Covers extension version `1.2.0.1`.*
*Audience: a Business Central administrator. Closes GA-01 / Issue 08-01 (consumer permission documentation).*

---

## 1. Requirements

| Item | Requirement |
|---|---|
| BC version | **28.0.0.0 or later** (built and verified against Base Application 28.4.53241) |
| Deployment model | SaaS Per-Tenant Extension (PTE) |
| AL runtime | 17.0 |
| Required dependency | **Business Foundation** (Microsoft, 28.4.53241.53312 or later) — ships with BC; provides the No. Series engine |
| Localization | W1 |
| Object ID range | 80300–80339 — confirm no other extension in the tenant claims it |

## 2. Install

1. Obtain the package: `IP_Tracking_1.2.0.1.app`.
2. In Business Central, search for **Extension Management**.
3. **Manage → Upload Extension**, choose the `.app`, set language, accept terms, **Deploy**.
4. Watch **Extension Deployment Status** until it reads *Completed*.
5. Confirm **IP Tracking** by *OnlyCopilotFans* appears in Extension Management as **Installed**.

Per-tenant extensions install per environment. Repeat for each environment (sandbox first, then
production). Installing does not populate any data.

## 3. Post-install configuration — required before use

**This step is not optional.** Without it, every attempt to create an IP Entitlement fails.

1. Search for **IP App Setup**.
2. Set **IP Entitlement Nos.** to a No. Series (create one in **No. Series** first if needed —
   e.g. code `IPE`, starting number `IPE00001`).
3. Save.

## 4. Permissions — what to assign, and what else users need

This extension ships two permission sets:

| Set | Grants | Give it to |
|---|---|---|
| `OCPF - IP Track Read` | Read on all five extension tables | Anyone who only views the catalogue/register — support, BI service accounts |
| `OCPF - IP Track Edit` | Includes Read, plus Insert/Modify/Delete on all five | Product/commercial staff maintaining the catalogue and entitlements |

**These sets cover this extension's tables only.** They are not sufficient on their own — a user
also needs standard Business Central permissions, because the app reads and links to standard
tables:

| Also required | Why |
|---|---|
| `D365 BASIC` | Baseline BC access — required by every user, no exceptions |
| Read access to **Customer** (table 18) | IP Entitlement links to a customer and shows Customer Name. A set such as `D365 SALES DOC, EDIT`, `D365 BASIC ISV`, or any role granting Customer read will do |
| Read access to **Currency** (table 4) | IP App Price references a currency (blank = LCY). Usually already granted by `D365 BASIC` |
| Read/write on **Item** (table 27) — *only if* users will set the Item's IP App field | The extension adds a field to Item; editing it needs Item write access, e.g. `D365 INVENTORY` |
| Read on **No. Series** (table 308) | Needed to assign entitlement numbers. Normally covered by `D365 BASIC` |

**Suggested role mapping**

| Role | Assign |
|---|---|
| Product / commercial manager | `D365 BASIC` + Customer read + `OCPF - IP Track Edit` |
| Support / read-only staff | `D365 BASIC` + Customer read + `OCPF - IP Track Read` |
| BI / integration service account | `D365 BASIC` + Customer read + `OCPF - IP Track Read` (add `Edit` only if it writes back) |
| Administrator | The above plus rights to open **IP App Setup** (`OCPF - IP Track Edit`) |

## 5. Verify the install

| # | Check | Expected |
|---|---|---|
| 1 | Extension Management shows **IP Tracking** *Installed*, version `1.2.0.1` | ✔ |
| 2 | Search finds **IP Apps**, **IP App Editions**, **IP App Prices**, **IP Entitlements**, **IP App Setup** | ✔ |
| 3 | **IP App Setup** has a No. Series set (§3) | ✔ |
| 4 | Open an **Item** — an **IP App** field is present | ✔ |
| 5 | Open a **Customer** — an **IP Entitlements** action is present | ✔ |
| 6 | `GET .../api/ocpf/ocpfIpManagement/v1.0/companies({id})/ocpfIPApps` returns 200 | ✔ |

For a full functional pass, run `HumanUnitTestScript.md`.

## 6. Upgrade

Upload the newer `.app` the same way; BC replaces the installed version in place. Data is
preserved — no schema-breaking change has been made since `1.0.0.0`. Version history and what
changed in each is in `ChangeLog.md`.

## 7. Uninstall

1. **Extension Management** → select **IP Tracking** → **Uninstall**.
2. To also remove the data, tick **Delete Extension Data** — **this is irreversible** and drops
   every IP App, Edition, Price, Entitlement and the Setup record, and clears the `IP App` field
   added to Item.
3. Uninstalling without deleting data leaves the tables intact for a later reinstall.

## 8. Known deployment-relevant limitations

- **Source is shipped inside the package.** `app.json` sets `allowDebugging`,
  `allowDownloadingSource` and `includeSourceInSymbolFile` to `true` — appropriate for an internal
  PTE, but it means anyone who can download the extension can read its source. Flip these to
  `false` before distributing outside the organisation. *(Flagged at Step 09; never explicitly
  signed off.)*
- **Not yet verified on a live tenant.** Published to `v29Sandbox`, but the green-team/red-team
  pass was skipped — see `ChangeLog.md`, Step 09. Run `HumanUnitTestScript.md` before production.
- **Unresolved:** whether `v29Sandbox` is BC v29. If the target environment is newer than the
  28.4 symbols this was built against, re-download symbols and rebuild before production.
