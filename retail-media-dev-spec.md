# Retail Media Wireframe — Technical Rebuild Spec (for React)

**Source of truth:** `retail-media-wireframe.html` (single static file, vanilla JS, no
framework, no build step — everything is one `<script>` tag that does `innerHTML` string
templating).
**Goal of this document:** let a developer or an AI coding agent rebuild the same structure,
states and behavior as React components, without having to reverse-engineer the HTML/JS.
**Not covered here:** visual design. The source file is deliberately greyscale with no brand
styling — colors, spacing, type and iconography in this spec are wireframe placeholders only,
carried over verbatim so nothing is lost, not because they are final.

Companion files in this folder:
- [retail-media-user-stories.md](retail-media-user-stories.md) — product/business framing and
  KPI-to-screen mapping.
- `screenshots/01-report-full.png`, `02-list-full.png`, `03-compare-full.png`,
  `04-share-dialog.png` — full-page renders of every screen and the modal.

---

## 1. What is, and isn't, part of the real product

The HTML file contains two layers that must **not** be confused:

| Layer | Elements | Build it? |
|---|---|---|
| **QA/dev harness** | The dark "Wireframe" bar at the very top with the 3 screen-switch buttons, and the grey "Low-fidelity wireframe" warning banner above it | **No.** This exists only so a reviewer can flip between screens in one static file. In React, screens are reached by normal navigation/routing instead. |
| **Host app shell** | `.frame > .chrome` (a fake browser-style top bar reading "Activate" with a logo placeholder) and `.chrome__nav` (5 blank icon placeholders on the left) | **No, not as built here.** This is a stand-in for the real host product ("Activate") that this feature is embedded inside. Treat it as "this feature lives inside an existing shell with its own top bar and left nav" — do not build a fake one, integrate into the real one. |
| **The actual feature** | Everything inside `.page` → `.phead` (page header) and `.content` (page body), across 3 screens, plus the Share modal | **Yes.** This is the real scope of the rebuild. |
| **Footer disclaimer** | `.foot` box | No — scoping note only. |

---

## 2. Screen map

```mermaid
flowchart LR
  List["Campaign List\n(/campaigns)"] -- click a row --> Report["Campaign Report\n(/campaigns/:id)"]
  List -- "Compare campaigns" button --> Compare["Compare Campaigns\n(/campaigns/compare)"]
  Report -- breadcrumb "Retail Media" --> List
  Compare -- breadcrumb "Retail Media" --> List
  Compare -- click a row with a result --> Report
  Report -- "Share approved result" button --> ShareModal["Share dialog (modal, overlays Report)"]
```

Current wireframe limitation to resolve in the real app: every row in List and the top row in
Compare link to **the same single hard-coded report** (`Saint Germain`). There is no real
per-campaign routing yet — plan for `/campaigns/:campaignId` from the start.

---

## 3. Shared building-block components

These 7 helper functions in the source (`kv`, `kpi`, `table`, `prop`, `stack`, `stateBlock`,
`readBlock`) are the real component library. Everything on every screen is built from these.
Recommended React component names in parentheses.

### 3.1 Key-value fact list (`<KeyValueList />`)
Renders a two-column `label : value` list. Used for campaign facts, the "export will state"
preview, and the conclusion's metadata.

```ts
interface KeyValueListProps {
  rows: Array<[label: string, value: string]>;
}
```
Layout: fixed label column (~215px), value fills the rest. Label is muted/secondary text.

### 3.2 KPI card (`<KpiCard />`, usually rendered in a `<KpiRow />` of several)
A single number with a label and an optional reference/benchmark line.

```ts
interface KpiCardProps {
  label: string;
  value: string;
  reference?: string;   // benchmark/estimate to compare against; if absent, show
                         // "no reference value supplied" styled as muted/disabled
  note?: string;         // short extra qualifier appended after " · ", e.g. "lower is better"
}
```
`KpiRow` lays cards out in a flex-wrap row, each card min-width ~170px, growing to fill.

### 3.3 Data table (`<DataTable />`)
A standard table with: first column left-aligned (dimension name), all other columns
right-aligned and using tabular/monospaced numerals, an optional pinned/total row, and
column-header tooltips.

```ts
interface DataTableProps {
  columns: string[];                 // first entry = row-label column
  rows: string[][];
  pinnedRow?: string[];              // rendered first, bold + shaded background
  columnHeaderTooltip?: string;      // shown on every column except the first;
                                      // wireframe text: "One agreed business definition per KPI"
}
```
Wrap in a horizontally-scrollable container on narrow screens — do not let it squash columns.
Any cell whose value is `"—"` should be rendered as a muted, "supressed" value with a tooltip
explaining why (see §7, "no silent substitutes" rule) — don't hard-code one reason for every
dash; make the reason per-cell/per-column once real data exists.

**Important nuance found in the source:** the "pinned row" is implemented by reusing the same
visual slot as a "grand total" row (`tr.total`, bold + shaded). In the Report screens this
slot really is a sum/total. In the List and Compare screens, the *same visual slot* is instead
used to pin "my own campaign" at the top of a list of other campaigns — it is not a total
there at all. **Recommendation:** split this into two distinct, separately-named props/
components in React (`totalRow` for real aggregates vs. a `pinnedRow`/`highlightedRow` concept
for "the row this page is about"), so the component's meaning isn't overloaded.

### 3.4 Proportion / mini-funnel card (`<ProportionCard />`)
Shows a "whole → part" relationship as two big numbers connected by an arrow, with a
percentage bar and a one-line finding underneath.

```ts
interface ProportionCardProps {
  wholeLabel: string; wholeValue: string;   // e.g. "Exposable group", "4.8 M"
  partLabel: string;  partValue: string;    // e.g. "Purchasing shoppers", "12.2 K"
  percent: number;                           // 0–100
  headline: string;                          // bold one-liner, e.g. "0.25 % of the exposable group bought"
  detail: string;                            // muted explanatory sentence underneath
}
```
Bar rule: give the bar a **minimum visible width** (source uses `max(percent, 0.6)%`) so a
tiny percentage like 0.25% still renders as a sliver, not nothing — the number carries the
meaning, the bar is a visual anchor only.

### 3.5 Paired 100%-stacked bar chart (`<PairedStackedBarChart />`)
Two columns (e.g. "this brand" vs. "category") each broken into the same ordered set of
segments that sum to 100%, with a shared legend and a short interpretive note.

```ts
interface PairedStackedBarChartProps {
  categories: string[];        // ordered segment names, shared legend order, length 5 in all current examples
  seriesA: number[];            // percentages, same length/order as categories
  seriesB: number[];
  captionA: string;             // column caption under column A, e.g. advertiser name
  captionB: string;             // column caption under column B, e.g. "Category"
  note: string;                 // interpretive sentence below the chart
  benchmarkIsPlaceholder?: boolean; // if true, show a disclaimer that seriesB figures are
                                      // unverified placeholders (both current usages set this true)
}
```
Rendering rules from the source: only print the percentage label inside a segment if it's
≥8% (smaller segments would overflow/overlap); use a fixed 5-step greyscale palette in
category order; the two tallest/darkest segments get white text, the rest get dark text
(wireframe-only — real contrast rules should be computed from actual colors later, not
hard-coded by index).

### 3.6 "Not ready yet" state block (`<NotReadyState />`)
Replaces a section's real content when its data isn't available. See full taxonomy in §6.

```ts
type NotReadyKind = 'unsupported' | 'insufficient' | 'issue' | 'processing';

interface NotReadyStateProps {
  kind: NotReadyKind;
  shortTitle: string;   // e.g. "Not supported in release 1" — shown next to the section title too
  text: string;         // one bold sentence, what's blocked
  why: string;
  who: string;          // who can unblock it
  when: string;         // when it's expected
}
```
Always render a skeleton-loader placeholder (a few grey bars of varying width) below the
explanation, to visually hint "real content will look roughly like this, later".

### 3.7 Calculated-interpretation row (`<ReadoutRow />`, usually several in a `<Readout />`)
A short, system-generated (not hand-typed) sentence that interprets a KPI against a
benchmark, shown above a section's main content.

```ts
type ReadoutTone = 'good' | 'flat'; // 'good' = favorable vs. benchmark, 'flat' = in line/neutral
                                     // (no negative/bad tone exists in the current content —
                                     // confirm with the team whether one is needed)
interface ReadoutRowProps {
  tone: ReadoutTone;
  label: string;     // e.g. "The conversion rate"
  value: string;     // bold, e.g. "0.25 %"
  explanation: string; // e.g. "0.07pp above the 0.18 % category norm"
}
```

---

## 4. Screen specs

### 4.1 Campaign List

**Route:** `/campaigns` (suggested)
**Page header:** H1 "Retail Media", subtitle "Campaigns you are permitted to see". Toolbar:
"Filters" button (not yet specified what it filters by — needs real user research, per the
source's own note), "Compare campaigns" button → navigates to Compare.
**Body:** one `<DataTable />`:

| Column | Notes |
|---|---|
| Advertiser | |
| Campaign | campaign name |
| Period | date range |
| *(status)* | **Naming bug in the source:** this column's header literally says `"Campaign"` again, duplicating the second column's header. Rename it to something like **"Status"** in the real build. Values seen: `Running`, `Finished`. |
| Measurement | plain-text measurement status: `Processing`, `Data issue`, `Result published`, `Partly suppressed` |

Example data (pinned/highlighted row = the user's current campaign, shown first):

| Advertiser | Campaign | Period | Status | Measurement |
|---|---|---|---|---|
| **Saint Germain** | Social Retail — Spring Launch | 29/04 – 31/05/2026 | Finished | Result published |
| Maison Verte | Always-on category support | 17/08 – 30/11/2026 | Running | Processing |
| Brasserie Nord | Seasonal takeover | 21/09 – 05/10/2026 | Running | Data issue |
| Cave Lumière | Launch support | 01/06 – 27/07/2026 | Finished | Result published |
| Atelier du Thé | Awareness burst | 06/04 – 18/05/2026 | Finished | Partly suppressed |

Caption under the table: *"One row per permitted campaign. Measurement status is plain text;
only exceptions need emphasis. Clicking a row opens the report."*
**Interaction:** clicking anywhere on a row opens that campaign's report (in the source, every
row incorrectly opens the same demo report — fix this in the real build, each row must open
its own campaign).

### 4.2 Campaign Report

**Route:** `/campaigns/:campaignId` (suggested)
**Page header:** breadcrumb `Retail Media › {advertiser name}` (breadcrumb root navigates back
to List). H1: `"{advertiser} — {campaign name}"`. Subtitle: `"{channel} · campaign {period} ·
attribution window {window} · result v{version}"`. Toolbar: "Export" button, "Share approved
result" button (primary/filled style) → opens the Share modal (§4.4).

The body has two parts: the **Verdict block**, then the **Story** (contents nav + 14
sections).

#### 4.2.1 Verdict block (`<ReportVerdict />`)
Always at the top, not part of the numbered sections, not data-state-aware (always renders —
it's the one thing assumed always ready). Content, top to bottom:
1. Label "Approved conclusion" + one big number (`€334 K`) + a small qualifier line
   (`revenue from 12.2 K purchasing shoppers · Descriptive`).
2. One free-text headline sentence summarizing the strongest finding **and** explicitly
   restating the method's limit (example: *"Conversion among summer liquor buyers is the
   strongest signal at 0.81%, 3.2× the campaign average of 0.25%. Nothing in the measured set
   falls below its reference. Does not prove the ads caused the purchase."*). This sentence is
   written by a person each time, built on top of the calculated KPI readouts — not auto-
   generated.
3. "What stands out" — a short list of 1–2 rows, each either a **good** highlight (dark dot) or
   a **blocked** callout (e.g. *"Blocked — Attributed result — the attribution rule is not yet
   agreed"*) linking conceptually to a locked section below.
4. "How strong is this claim?" — a fixed 3-step horizontal ladder, always shown in full even
   though only step 1 is reachable today:
   - **Descriptive** (alias shown: *"Alternative conversion"*) — *"what the selected shoppers
     bought"* — marked `current`.
   - **Attributed** — *"purchases linked to exposure"* — marked `blocked`.
   - **Incremental** — *"the extra outcome caused by the campaign"* — marked `blocked`.
   Followed by one explanatory line: *"The report we deliver today is called 'Alternative
   conversion'. That is rung one of three, and saying so is what stops 'an effective campaign'
   drifting into 'the ads caused this'."*
   This ladder is a reusable idea worth its own component (`<ClaimStrengthLadder currentStep={1} />`) since it should appear consistently any time a result's rigor level needs to be
   communicated.

#### 4.2.2 Contents nav + the 14 sections (`<ReportContentsNav />` + `<ReportSection />`×14)
Two-column layout: a sticky left-hand contents nav, and the sections themselves on the right,
each with an anchor so the nav can scroll to it.

**Contents nav:** one row per section, grouped under 4 question headers (inserted whenever the
group changes): *"What was this campaign?"* (sections 1–2) → *"Did it deliver as planned?"*
(section 3) → *"What did the selected shoppers buy?"* (sections 4–11) → *"What is the approved
conclusion?"* (sections 12–14). Each row shows: section number, a status dot, the section
title, and — if the section isn't in its normal "ready" state — a short right-aligned status
note (e.g. *"Not supplied"*, *"Outcome period still open"*).

**Status-dot shade mapping found in the source** (darker = more attention-worthy, not a
stoplight/severity color — flag this for a real design pass):

| Status | Dot shade (current greyscale) |
|---|---|
| `ready` (no issue) | lightest (`#dcdcdf`) |
| `unsupported` | light (`#c4c4c8`) |
| `processing` | mid (`#a1a1aa`) |
| `insufficient` | darker (`#71717a`) |
| `issue` | darkest (`#3f3f46`) |

**Each section**, in order, with its exact content:

| # | Section title | Building blocks used | Source citation shown? |
|---|---|---|---|
| 1 | Campaign overview | `KeyValueList` (9 facts: report type, campaign type, objective, campaign period, attribution window, measurement period, redirection link, targeting basis, campaign ID) | Yes — retailer loyalty data source line |
| 2 | Audience definitions | Numbered list of 4 mutually-exclusive shopper segments, each with an "excluding..." note except the first, plus a hint paragraph explaining the exclusivity rule | Yes |
| 3 | Campaign delivery | `Readout` (2 rows: Impressions, CPM) + `KpiRow` (Impressions, CPM, Reach, Clicks) + hint that these numbers come from the media partner, unvalidated by us | Media-partner source line (different from the retailer source used elsewhere) |
| 4 | How this was measured | 3-step process explainer (`Audience building` → `Exposable group` → `Sales measure`) + hint stating the method's limits | No |
| 5 | Conversion overview | `DataTable` (1 total row only, no breakdown rows) + `ProportionCard` (exposable group → purchasing shoppers, 0.25%) + `Readout` (1 row) | Yes |
| 6 | Conversion by segment | `Readout` (2 rows) + `DataTable` (4 segment rows + total) | Yes |
| 7 | Business equation by audience | `Readout` (3 rows) + `DataTable` (4 segment rows + total, 8 numeric columns) | Yes |
| 8 | Repeat purchase | `Readout` (1 row) + `ProportionCard` (purchasing shoppers → repeat shoppers, 9%) | Yes |
| 9 | Performance by retailer channel | `Readout` (1 row) + `KpiRow` (1 card: e-commerce revenue share) + `DataTable` (3 channel rows + total) + hint distinguishing *retailer* channel from *media* channel | Yes |
| 10 | Shopper profile — lifestage | `PairedStackedBarChart` (5 life-stage segments, brand vs. category) | Yes |
| 11 | Shopper profile — consumption style | `PairedStackedBarChart` (5 shopping-style segments, brand vs. category) — **shown as `NotReadyState` (`insufficient`) in the default data state**, see §6 | Yes (when ready) |
| 12 | Attributed result | `KpiRow` (3 cards) + hint + an "illustrative, not real yet" marker — **shown as `NotReadyState` (`unsupported`) in the default data state**, see §6 | Yes (when ready) |
| 13 | Incremental impact | `KpiRow` (3 cards, one showing a range) + hint + "illustrative" marker — **shown as `NotReadyState` (`unsupported`) in the default data state**, see §6 | Yes (when ready) |
| 14 | Conclusion | `KeyValueList` (result type, data used, data period, result version) + two-column list ("Learnings" / "Recommendations", 3 bullets each) + a separate always-visible "Limitations" box (3 bullets) + hint clarifying this prose is human-written on top of system-generated readouts | Yes |

Exact body copy for every section (facts, bullet text, table values) is in the HTML source
and should be treated as realistic example/seed content, not literal copy to ship — see the
file's own disclaimer: *"Example content is real so the structure is tested against
something, not so the numbers are reviewed."*

### 4.3 Compare Campaigns

**Route:** `/campaigns/compare` (suggested)
**Page header:** breadcrumb `Retail Media › Compare campaigns`. H1 "Compare campaigns".
Subtitle: *"Every permitted campaign on the same fixed KPI set, each against its own agreed
revenue target."* Toolbar: "Filters", "Export".
**Body:** one `<DataTable />`, 8 columns: Campaign, Exposable group, Shoppers, Conv. rate,
Revenue, Revenue / client, Repeat share, vs. target. Pinned/highlighted row = the user's own
campaign (same overloaded-pinned-row issue as the List screen, see §3.3).

Example data:

| Campaign | Exposable group | Shoppers | Conv. rate | Revenue | Revenue/client | Repeat share | vs. target |
|---|---|---|---|---|---|---|---|
| **Saint Germain** | 4.8 M | 12.2 K | 0.25% | €334 K | €27.5 | 9% | 111% |
| Maison Verte | 6.1 M | 19.4 K | 0.32% | €502 K | €25.9 | 11% | 90% |
| Cave Lumière | 1.2 M | 4.1 K | 0.34% | €118 K | €28.8 | 7% | 118% |
| Atelier du Thé | 660 K | 2.0 K | 0.30% | €44 K | €22.2 | — | 73% |
| Brasserie Nord | 940 K | — | — | — | — | — | — |

Two caption paragraphs under the table:
1. *"A campaign with no result shows why on hover rather than being hidden. Never substitute a
   replacement result silently."*
2. (bold lead-in **"Scope note."**) *"A configurable explorer depends on a KPI and dimension
   list that is still an open decision. This fixed list keeps the comparison promise and can be
   estimated today. Comparing across retail media networks — the thing advertisers say they
   want most — is a separate, larger piece of work. See the concept document."*

**Interaction:** clicking a row with a published result opens that campaign's report (in the
source, only row 1 is wired up — fix in real build so every row with a real result is
clickable). Dash (`—`) cells get a tooltip explaining why the number is missing — in the source
every dash uses one hard-coded reason ("Delivery data not supplied by the media partner"),
which isn't actually correct for every column (e.g. a missing *Repeat share* has nothing to do
with delivery data) — **in the real build, the reason must be specific to what's actually
missing for that cell**, reusing the same `NotReadyState` taxonomy as the report (§6).

### 4.4 Share dialog (modal)

Triggered from the Report screen's "Share approved result" button. Renders as a centered modal
over a dark overlay.

```ts
interface ShareDialogProps {
  recipientsPlaceholder: string;      // "Search people or teams" — not wired to real search yet
  exportPreview: Array<[string, string]>; // same shape as KeyValueListProps.rows
  onCancel: () => void;
  onShare: () => void;                // NOTE: in the source, "Share" has no behavior wired at
                                        // all yet — only Cancel/overlay-click close the dialog.
}
```

Content:
- H2 "Share approved result".
- "Recipients" field (visual placeholder only in the source — needs a real
  people/teams-picker component).
- "The export will state" preview box, a `KeyValueList` with: Campaign scope (`{advertiser} ·
  {campaign ID}`), Result type, Data period, Status and version — plus the note *"A fixed
  export header, independent of the export format — which is still an open decision."*
- Note: *"The link re-checks the recipient's access when it is opened."* → real build must
  actually re-validate permissions on every open of a shared link, not just at share-time.
- Footer: "Cancel" and "Share" buttons.

**Accessibility gaps to fix in the real build** (not handled in the wireframe): no
`role="dialog"`/`aria-modal`, no focus trap, no Escape-to-close, no initial focus management.

---

## 5. Data model (suggested TypeScript shapes)

```ts
interface CampaignMeta {
  id: string;            // e.g. "RM-SG-0426"
  advertiser: string;
  name: string;
  retailer: string;
  mediaChannel: string;  // e.g. "Social — Meta"
  campaignPeriod: { start: string; end: string };
  attributionWindow: { start: string; end: string };
  measurementPeriod: { start: string; end: string };
  resultVersion: string; // e.g. "v1.0"
}

type QuestionGroup = 0 | 1 | 2 | 3; // the 4 "Q" headers in the contents nav

interface ReportSection {
  number: number;         // 1..14, display order
  id: string;             // stable key, e.g. "bysegment"
  questionGroup: QuestionGroup;
  title: string;
  dataSourceLabel?: string; // footer citation line, varies per section (retailer vs. media partner)
  readouts?: ReadoutRowProps[];
  notReady?: NotReadyStateProps; // if present, render NotReadyState instead of real content
}

interface KpiBenchmarkReadout {
  tone: 'good' | 'flat';
  label: string;
  value: string;
  explanation: string;
}
```

Keep the **data-state override** concept (§6) separate from the section's own definition — a
section's normal content and its "what if it's not ready" content are two different data
sources that get merged at render time, exactly like the source's `SECTIONS` + `SCENARIOS`
split.

---

## 6. The "not ready" data-state system

This is the most important behavioral pattern in the whole file and should be built as one
shared system, not duplicated per section. Four kinds exist, each a tuple of
`(kind, shortTitle, text, why, who, when)`:

| Kind | Meaning | Example in the source |
|---|---|---|
| `unsupported` | The feature doesn't exist in this release at all | Attributed result, Incremental impact — always blocked in every scenario below except the hypothetical "complete" future state |
| `insufficient` | The feature exists, but this particular retailer/campaign doesn't have the data for it | Consumption-style shopper profile, for retailers who don't supply that data |
| `issue` | A required upstream data file didn't arrive | Campaign delivery, when the media partner hasn't sent their exposure file |
| `processing` | The result depends on a time window that hasn't closed yet | Conversion-related sections + Conclusion, while a campaign is still running |

Every one of the 4 kinds **always** answers the same 3 questions in the UI: **why**, **who**
unblocks it, **when** it'll resolve — never just a blank or a generic "No data" label.

**Important:** the source file defines 4 named *scenarios* (`complete`, `phase1`, `partner`,
`running`) as example combinations of which sections are blocked and why — but **only
`phase1` is ever actually rendered** (`const scenario = 'phase1'` is hard-coded; there is no
real UI switcher despite the data existing for all 4). Treat `phase1` as the only state you've
actually seen in the screenshots; treat `partner`, `running`, and `complete` as **extra
documented examples of the same system in different situations** — useful for designing the
general-purpose mechanism, but not something to copy 1:1 as hard-coded states in React. The
real system should compute which sections are blocked, and why, from live pipeline/data-
quality signals (several of which map to the catalog's **Diagnostic** KPIs, e.g. *Media Event
Deduplication Rate*, *Late-Arriving Data Rate*), not from a hard-coded scenario name.

**`phase1` (what's in the screenshots):**
- §11 Shopper profile — consumption style → `insufficient`: *"Consumption-style profiling is
  not part of the agreed data set for this retailer."* / who: *Data operations, with the
  retailer* / when: *Not scheduled.*
- §12 Attributed result → `unsupported`: *"An attributed result needs shopper exposure data
  and an approved attribution rule."* / who: *Data Science defines the rule, governance
  approves it* / when: *A later release.*
- §13 Incremental impact → `unsupported`: *"Incremental measurement needs an approved control
  or causal method and sign-off."* / who: *Data Science, with the retailer and partner
  supplying control data* / when: *A later release.*

**`partner` (documented, not currently shown):** adds §3 Campaign delivery → `issue`:
*"The media partner has not delivered the exposure file for this campaign."* / who: *Media
partner, chased by Data operations* / when: *When the file arrives. No replacement result is
created.* — plus the same two `unsupported` blocks as above.

**`running` (documented, not currently shown):** sections §5, §6, §7, §8 all → `processing`
("Outcome period still open", each with its own one-line reason) and §14 Conclusion →
`processing` ("Written after the result is final" — who: *Retail Media Manager*) — plus the
same two `unsupported` blocks as above.

---

## 7. Behavioral rules worth preserving exactly

1. **Never silently substitute a number.** If data is missing, show the `NotReadyState`
   explanation — never a zero, a blank, or a guessed value standing in for a real result.
2. **Every "not ready" state always explains why, who, and when** — all three, every time.
3. **Benchmarks/estimates are always shown next to the real number**, not just the number
   alone, so results are never presented without their point of comparison.
4. **Ranges stay ranges.** The Incremental impact example explicitly keeps a `±23%`/range
   format and must never be collapsed to one falsely-precise number.
5. **The claim-strength ladder (Descriptive → Attributed → Incremental) is always shown in
   full**, even for steps that are completely locked, so users always know what's possible
   and what isn't yet, rather than discovering it by it being absent.
6. **Retailer channel ≠ media channel.** Section 9 explicitly warns against conflating "where
   someone shopped" (e-commerce/hypermarket/supermarket) with "what ad channel reached them"
   (e.g. "Social — Meta"). Keep these as clearly separate concepts/fields in the data model.

---

## 8. Suggested React project structure

```
src/
  components/
    shared/
      KeyValueList.tsx
      KpiCard.tsx
      KpiRow.tsx
      DataTable.tsx
      ProportionCard.tsx
      PairedStackedBarChart.tsx
      NotReadyState.tsx
      Readout.tsx            (renders ReadoutRow[])
      ClaimStrengthLadder.tsx
    report/
      ReportVerdict.tsx
      ReportContentsNav.tsx
      ReportSection.tsx       (generic wrapper: number, title, flag, citation, chooses
                               NotReadyState vs. real content)
      sections/
        CampaignOverviewSection.tsx
        AudienceDefinitionsSection.tsx
        CampaignDeliverySection.tsx
        MethodSection.tsx
        ConversionOverviewSection.tsx
        ConversionBySegmentSection.tsx
        BusinessEquationSection.tsx
        RepeatPurchaseSection.tsx
        ChannelPerformanceSection.tsx
        ShopperProfileSection.tsx   (reused for both lifestage and consumption-style)
        AttributedResultSection.tsx
        IncrementalImpactSection.tsx
        ConclusionSection.tsx
    list/
      CampaignListPage.tsx
    compare/
      CompareCampaignsPage.tsx
    share/
      ShareDialog.tsx
  data/
    campaignMeta.ts
    kpiCatalog.ts           (generated from the KPI Catalog spreadsheet — see user-stories doc)
    notReadyRules.ts        (the "why/who/when" system, computed, not hard-coded per scenario)
  types/
    index.ts                (interfaces from §5)
```

---

## 9. Open items to confirm with the team before/while building

1. Fix the duplicate `"Campaign"` column header on the List screen (§4.1).
2. Decide real per-cell "why is this missing" tooltip text for Compare's dash cells instead of
   one hard-coded reason (§4.3).
3. Wire real per-campaign routing — List/Compare currently all point at one demo report.
4. Decide the real color/severity semantics for status dots — the current shade scale
   (darker = needs more attention) is a wireframe convenience, not a confirmed design decision
   (§4.2.2).
5. Decide whether `ReadoutRow` needs a 3rd, "unfavorable" tone — only `good`/`flat` exist in
   the current example content, but real data will likely produce a KPI below its benchmark.
6. Build the `NotReadyState` reasons from real pipeline/data-quality signals (the catalog's
   Diagnostic KPIs), not from a hard-coded scenario switch (§6).
7. Add accessibility behavior to the Share dialog (focus trap, Escape, `aria-modal`) (§4.4).
8. Decide the real behavior of the Share dialog's "Share" button — it currently does nothing.
