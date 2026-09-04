# Object Register — IP Tracking

Allocated range: **80300–80339**. Never allocate outside it.

| ID | Type | Name | Module | Source table | R/W | Batch | Status |
|---|---|---|---|---|---|---|---|
| 80300 | enum | ipt IP License Type | IP Tracking | — | — | 1 | Built |
| 80301 | enum | ipt IP Billing Period | IP Tracking | — | — | 1 | Built |
| 80302 | enum | ipt IP Entitlement Status | IP Tracking | — | — | 1 | Built |
| 80303 | table | ipt IP App | IP Tracking | new | R/W | 2 | Built |
| 80304 | table | ipt IP App Edition | IP Tracking | new | R/W | 2 | Built |
| 80305 | table | ipt IP App Price | IP Tracking | new | R/W | 2 | Built |
| 80306 | table | ipt IP Entitlement | IP Tracking | new | R/W | 2 | Built |
| 80307 | page (List) | ipt IP Apps | IP Tracking | ipt IP App | R/W | 2 | Built |
| 80308 | page (Card) | ipt IP App Card | IP Tracking | ipt IP App | R/W | 2 | Built |
| 80309 | page (List) | ipt IP App Editions | IP Tracking | ipt IP App Edition | R/W | 2 | Built |
| 80310 | page (Card) | ipt IP App Edition Card | IP Tracking | ipt IP App Edition | R/W | 2 | Built |
| 80311 | page (List) | ipt IP App Prices | IP Tracking | ipt IP App Price | R/W | 2 | Built |
| 80312 | page (Card) | ipt IP App Price Card | IP Tracking | ipt IP App Price | R/W | 2 | Built |
| 80313 | page (List) | ipt IP Entitlements | IP Tracking | ipt IP Entitlement | R/W | 2 | Built |
| 80314 | page (Card) | ipt IP Entitlement Card | IP Tracking | ipt IP Entitlement | R/W | 2 | Built |
| 80315 | page (API) | ipt IP App API | IP Tracking | ipt IP App | R/W | 3 | Planned |
| 80316 | page (API) | ipt IP App Edition API | IP Tracking | ipt IP App Edition | R/W | 3 | Planned |
| 80317 | page (API) | ipt IP App Price API | IP Tracking | ipt IP App Price | R/W | 3 | Planned |
| 80318 | page (API) | ipt IP Entitlement API | IP Tracking | ipt IP Entitlement | R/W | 3 | Planned |
| 80319 | — | *(free)* | | | | | Buffer |
| 80320 | page (ListPart) | ipt IP App Editions Part | IP Tracking | ipt IP App Edition | R/W | 2 | Built |
| 80321 | page (ListPart) | ipt IP App Prices Part | IP Tracking | ipt IP App Price | R/W | 2 | Built |
| 80322–80337 | — | *(free)* | | | | | Buffer / tail (16 IDs) |
| 80338 | permissionset | IPT - IP Track Read | IP Tracking | — | — | 2 | Built |
| 80339 | permissionset | IPT - IP Track Edit | IP Tracking | — | — | 2 | Built |

Total planned: **23** objects (3 enums, 4 tables, 8 UI pages, 2 ListParts, 4 API pages, 2 permission sets). Free: 17 IDs (42% headroom).

*Batch column re-layered at Step 04 (SanityCheck SC-02/SC-04): B1 enums, B2 tables + UI + parts + permission sets, B3 API pages. Permission set names shortened to 19 chars (SC-01 — the AL limit for `permissionset` identifiers is 20, not 30).*
