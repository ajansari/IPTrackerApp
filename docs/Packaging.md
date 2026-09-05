# Packaging Record — IP Tracking

*Runbook phase: PROVE / Step 09 "Package and Test the App" — **packaging only**. Date: 2026-09-04.*
*Status: package built and verified. Publish + green-team/red-team tests are the remainder of Step 09 and require a live BC tenant — not run here.*

> **Point-in-time record — not a living spec.** This predates the 2026-09-05 publisher/prefix
> rename (`DSW`/`ipt` → `OnlyCopilotFans`/`ocpf`, see `ChangeLog.md` 09F-05) — every `DSW`
> reference below is what was true on 2026-09-04, not current. §5's "remaining work" list is
> also superseded by `docs/ProjectMemory.md`'s "Open Decisions"/"Next" sections, which are kept
> current. Read `docs/ProjectMemory.md` first for anything you intend to act on.

## 1. Identity, runtime and dependencies confirmed against Parameter 1

| Field | `app.json` | TDD §1 | Match |
|---|---|---|---|
| id | `8bf69fdd-4440-48d7-b7b4-7608ac2e9266` | — (fixed at Step 01) | ✔ |
| name | `IP Tracking` | §1.1 Extension Name | ✔ |
| publisher | `DSW` | §1.1 Publisher | ✔ |
| version | `1.0.0.0` | — | ✔ |
| platform | `28.0.0.0` | §1.4 | ✔ |
| application | `28.0.0.0` | §1.4 BC Application Minimum | ✔ |
| runtime | `17.0` | §1.4 AL Runtime | ✔ |
| idRanges | `80300–80339` | §1.2 | ✔ |
| features | `["NoImplicitWith"]` | §1.5 | ✔ |
| dependencies | `[]` | — | ✔ correct — no explicit app dependency; Base App/System are implicit platform dependencies for a PTE, not listed here |

## 2. Build

```
./scripts/build.sh
  pre-flight: 23 file(s), 26 rules, 0 failure(s), 0 warning(s)
  compile:    0 error(s), 0 warning(s), 4 info
  GATE PASSED — out/app.app
```

The 4 infos are the pre-accepted `AW0006` on the four Card pages (SanityCheck SC-07) — unchanged
from Batch 2/3, no new diagnostic introduced by packaging.

## 3. Package contents verified

Opened `out/app.app` (40-byte navx header + zip) and read its **compiled** `SymbolReference.json`
directly — this is what a consumer or the BC service actually sees, independent of what's on
disk in `src/`:

| Kind | Count |
|---|---|
| Tables | 4 |
| Pages | 14 (8 List/Card + 2 ListPart + 4 API) |
| EnumTypes | 3 |
| PermissionSets | 2 |
| **Total** | **23** — matches ObjectRegister exactly |

Manifest (`NavxManifest.xml`) inside the package: `Id`, `Name`, `Publisher`, `Version`,
`Platform="28.0.0.0"`, `Runtime="17.0"`, `IdRange 80300–80339` — all match `app.json` above.

**Note:** the package's embedded source (`resourceExposurePolicy.includeSourceInSymbolFile`,
already `true` in `app.json` since the Step 05 scaffold) stores files under a doubled
`src/src/...` path — an artifact of the project's own top-level folder being named `src`. Purely
cosmetic; does not affect object registration or runtime behavior. Confirms source really is
bundled, per policy — worth a conscious yes/no before shipping to production, since it also
implies `allowDebugging`/`allowDownloadingSource = true`, appropriate for an internal PTE but
worth confirming deliberately rather than inheriting the scaffold default unexamined.

## 4. Output

`out/app.app` — 25,058 bytes, git-ignored (build artifact, not source).

## 5. Remaining Step 09 work (needs a live BC tenant — not done here)

- Publish to `v29Sandbox` (resolve SC-11: confirm whether that environment is BC v29, which
  would mean 28.4 symbols are downlevel for it).
- Green-team tests: `$metadata` schema, collection read, single-record read by `SystemId`,
  create on an editable endpoint, field update, confirm no read-only endpoint exists to test
  against (all four API pages are `DelayedInsert = true` per A-8 — there is no read-only
  endpoint in this app, so that specific green-team check is N/A by design).
- Red-team tests: invalid field, invalid key, delete a parent with children (exercises the
  `OnDelete` guards on IP App / IP App Edition), missing-permission call.
- Verify permission sets live: Read grants read on all four tables; Edit includes Read plus
  write. Document base `D365` permissions consumers need (closes GA-01 / Issue 08-01, folds
  into `Deployment.md` at Step 12).

**Exit gate for the full Step 09** (not yet met — packaging portion only):

| Condition | Status |
|---|---|
| App publishes cleanly | Pending — needs live tenant |
| All green-team tests pass | Pending |
| All red-team tests fail gracefully | Pending |
