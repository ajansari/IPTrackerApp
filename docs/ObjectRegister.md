# Object Register — IP Tracking

Allocated range: **80300–80339**. Never allocate outside it.
*Revised 2026-09-05 — renamed `ipt`→`ocpf` / `DSW`→`OnlyCopilotFans` (09F-05); 7 objects added
(09F-06/09F-07/09F-08). See `ChangeLog.md`.*

| ID | Type | Name | Module | Source table | R/W | Batch | Status |
|---|---|---|---|---|---|---|---|
| 80300 | enum | ocpf IP License Type | IP Tracking | — | — | 1 | Built |
| 80301 | enum | ocpf IP Billing Period | IP Tracking | — | — | 1 | Built |
| 80302 | enum | ocpf IP Entitlement Status | IP Tracking | — | — | 1 | Built |
| 80303 | table | ocpf IP App | IP Tracking | new | R/W | 2 | Built |
| 80304 | table | ocpf IP App Edition | IP Tracking | new | R/W | 2 | Built |
| 80305 | table | ocpf IP App Price | IP Tracking | new | R/W | 2 | Built |
| 80306 | table | ocpf IP Entitlement | IP Tracking | new | R/W | 2 | Built |
| 80307 | page (List) | ocpf IP Apps | IP Tracking | ocpf IP App | R/W | 2 | Built |
| 80308 | page (Card) | ocpf IP App Card | IP Tracking | ocpf IP App | R/W | 2 | Built |
| 80309 | page (List) | ocpf IP App Editions | IP Tracking | ocpf IP App Edition | R/W | 2 | Built |
| 80310 | page (Card) | ocpf IP App Edition Card | IP Tracking | ocpf IP App Edition | R/W | 2 | Built |
| 80311 | page (List) | ocpf IP App Prices | IP Tracking | ocpf IP App Price | R/W | 2 | Built |
| 80312 | page (Card) | ocpf IP App Price Card | IP Tracking | ocpf IP App Price | R/W | 2 | Built |
| 80313 | page (List) | ocpf IP Entitlements | IP Tracking | ocpf IP Entitlement | R/W | 2 | Built |
| 80314 | page (Card) | ocpf IP Entitlement Card | IP Tracking | ocpf IP Entitlement | R/W | 2 | Built |
| 80315 | page (API) | ocpf IP App API | IP Tracking | ocpf IP App | R/W | 3 | Built |
| 80316 | page (API) | ocpf IP App Edition API | IP Tracking | ocpf IP App Edition | R/W | 3 | Built |
| 80317 | page (API) | ocpf IP App Price API | IP Tracking | ocpf IP App Price | R/W | 3 | Built |
| 80318 | page (API) | ocpf IP Entitlement API | IP Tracking | ocpf IP Entitlement | R/W | 3 | Built |
| 80319 | table | ocpf IP App Setup | IP Tracking | new | R/W | 4 (feedback) | Built |
| 80320 | page (ListPart) | ocpf IP App Editions Part | IP Tracking | ocpf IP App Edition | R/W | 2 | Built |
| 80321 | page (ListPart) | ocpf IP App Prices Part | IP Tracking | ocpf IP App Price | R/W | 2 | Built |
| 80322 | page (Card, singleton) | ocpf IP App Setup | IP Tracking | ocpf IP App Setup | R/W | 4 (feedback) | Built |
| 80323 | tableextension | ocpf Item | IP Tracking | Item (27) | R/W | 4 (feedback) | Built |
| 80324 | pageextension | ocpf Item Card | IP Tracking | Item Card (30) | R/W | 4 (feedback) | Built |
| 80325 | pageextension | ocpf Item List | IP Tracking | Item List (31) | R/W | 4 (feedback) | Built |
| 80326 | pageextension | ocpf Customer Card | IP Tracking | Customer Card (21) | — (action only) | 4 (feedback) | Built |
| 80327 | pageextension | ocpf Customer List | IP Tracking | Customer List (22) | — (action only) | 4 (feedback) | Built |
| 80328–80337 | — | *(free)* | | | | | Buffer (10 IDs) |
| 80338 | permissionset | OCPF - IP Track Read | IP Tracking | — | — | 2 | Built |
| 80339 | permissionset | OCPF - IP Track Edit | IP Tracking | — | — | 2 | Built |

Total: **30 objects** (3 enums, 5 tables, 9 UI pages, 2 ListParts, 4 API pages, 1 tableextension,
4 pageextensions, 2 permission sets). Free: 10 IDs (25% headroom, down from 42% at BUILD-complete
— the 09F-06/07/08 feedback consumed 7 of the former buffer IDs).

*Field-removal note: `ocpf IP App Edition` field 4 "Unit Price" was removed (09F-04) — this
frees a field number, not an object ID; the table's own object ID (80304) is unchanged.*
