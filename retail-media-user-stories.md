# Retail Media Reporting — User Stories for Development

**Based on:** `retail-media-wireframe.html` (low-fidelity wireframe) and
`Retail_Media_Phase1_MVP_KPI_Catalog (2).xlsx` (50-KPI Phase 1 catalog)
**Purpose:** give developers clear, simple stories to start building the pages, components
and charts. This is scoping, not final design — layout and visuals are still open.

---

## How to read this document

- Every story is written the way a Product Owner writes them: **"As a ___, I want ___, so
  that ___."** No technical words about databases, code, or APIs.
- Every story says **which KPIs (numbers) from the KPI Catalog appear on that screen**, in
  plain English, so developers know exactly what data they are building for.
- Stories are grouped into **Epics**. The wireframe's own code already grouped most sections
  under ticket codes (`FE-3` to `FE-8`) — this document keeps those codes and fills the gaps
  (`FE-1`, `FE-2`, `FE-9`, `FE-10`) so it lines up with what the team already started.
- Two people matter in these stories:
  - **Retail Media Manager** — the person who sets up campaigns and checks results before
    sharing them.
  - **Advertiser** — the brand's marketing person who receives the finished result.
- Screenshots of every screen are in the `screenshots/` folder next to this file:
  [01-report-full.png](screenshots/01-report-full.png) (Campaign report, all 14 sections),
  [02-list-full.png](screenshots/02-list-full.png) (Campaign list),
  [03-compare-full.png](screenshots/03-compare-full.png) (Compare campaigns),
  [04-share-dialog.png](screenshots/04-share-dialog.png) (Share pop-up).

---

## Epic map

| Epic | Name | Screen / section(s) covered |
|---|---|---|
| FE-1 | See all my campaigns | Campaign list |
| FE-2 | Compare my campaigns | Compare campaigns |
| FE-3 | Explain the campaign and the method | Report §1 Overview, §2 Audiences, §4 Method |
| FE-4 | Give the headline verdict | Report top summary block, §14 Conclusion |
| FE-5 | Show media delivery (+ what's coming later) | Report §3 Delivery, §12 Attributed, §13 Incremental |
| FE-6 | Show what shoppers bought | Report §5, §6, §7, §9 |
| FE-7 | Show who comes back | Report §8 Repeat purchase |
| FE-8 | Show who the buyers are | Report §10 Life stage, §11 Consumption style |
| FE-9 | Share and export the result | Share pop-up |
| FE-10 | Explain when something isn't ready | Applies across every screen (cross-cutting) |

---

## Epic FE-1 — See all my campaigns

### Story FE-1.1: See every campaign I'm allowed to see, in one list

**As a** Retail Media Manager,
**I want** to see one simple list of every campaign I have permission to see,
**so that** I can quickly find the campaign I need without asking anyone for access.

**What this page shows:** one row per campaign — advertiser name, campaign name, the dates it
ran, whether it is still running or finished, and whether its result is ready, still being
calculated, or has a problem. Clicking a row opens that campaign's report.

**KPIs used:** none — this page shows facts about the campaign (who, when, what status), not
calculated numbers. The status word (e.g. "Processing", "Data issue") comes from the same
health checks described in Epic FE-10.

**What "done" looks like:**
- I see every campaign I'm allowed to see, one row each, with no extra steps.
- I can tell at a glance if a campaign is still running or already finished.
- I can tell at a glance if the result is ready, still cooking, or stuck, without opening it.
- Clicking anywhere on a row takes me straight into that campaign's full report.
- There's a way to open the campaign comparison page and a way to filter the list (what
  exactly can be filtered is still to be decided with real users).

---

## Epic FE-2 — Compare my campaigns

### Story FE-2.1: Compare all my campaigns side by side, against their own goals

**As a** Retail Media Manager,
**I want** to see every campaign I'm allowed to see in one table, using the same columns,
**so that** I can quickly spot which campaigns are doing well and which need attention.

**What this page shows:** one row per campaign, one fixed set of columns for every campaign
(so it's a fair comparison), and a column showing how each campaign did against its own
revenue goal. If a number can't be shown yet, the cell shows a dash and explains why when you
hover over it, instead of hiding the row or making up a number.

**KPIs used:**
- **Exposable Audience** — how many shoppers could have seen the campaign.
- **Shoppers** — how many of them actually bought something.
- **Conversion Rate** — the share of shoppers who bought something.
- **Revenue** — total sales credited to the campaign.
- **Revenue per Shopper** — average amount each buying shopper spent.
- **Loyal Shopper Rate** — the share of shoppers who bought at least twice (shown here as
  "repeat share").
- Performance against the agreed revenue goal (this number isn't in the KPI Catalog yet —
  see the Open Questions section at the end of this document).

**What "done" looks like:**
- Every campaign I'm allowed to see appears in the same table with the same columns.
- Each campaign is judged against its own goal, not someone else's.
- If a number is missing, I see a dash with a plain-English reason on hover — never a fake
  number standing in for a real one.
- Clicking a finished campaign's row takes me to its full report. Campaigns without a
  finished result are not clickable in the same way.
- A note on the page makes clear this is a fixed set of columns for now, and that comparing
  across different advertising networks is a bigger project for later.

---

## Epic FE-3 — Explain the campaign and the method

### Story FE-3.1: See the basic facts about a campaign in one place

**As an** Advertiser,
**I want** to see the key facts about my campaign (who ran it, when, how, and why) as soon as
I open the report,
**so that** I know exactly what I'm looking at before I look at any numbers.

**What this page shows:** a simple fact sheet — report type, campaign type, the goal of the
campaign, the dates it ran, the extra window after it ended where purchases still count, the
full measurement period, where the "Shop now" link sends people, what shopper data the
targeting was based on, and the campaign's ID number.

**KPIs used:** none — this section is plain facts about the campaign setup, not calculated
numbers.

**What "done" looks like:**
- I can see all the campaign facts without scrolling through numbers first.
- The dates are shown clearly: when the campaign ran, and the extra time after it ended that
  still counts towards the result.
- I can see this is the first, simplest type of result ("descriptive"), not a claim that the
  ads caused sales.

### Story FE-3.2: See exactly who the campaign was aimed at

**As an** Advertiser,
**I want** to see the exact groups of shoppers the campaign targeted, in plain language,
**so that** I understand whose purchases are being counted and why.

**What this page shows:** a numbered list of shopper groups (for example "Summer liquor
buyers", "Winter liquor buyers"), with a short note when a group excludes shoppers already
counted in a group above it, so nobody is counted twice.

**KPIs used:**
- **Exposable Audience** — the size of each group that could be reached.
- **Shopper Share by Audience Segment** — how big a slice of all buyers came from each group.

**What "done" looks like:**
- Every shopper group used in the campaign is listed, in the same order they appear later in
  the report, so I can match them up.
- It's clear when a group excludes people already counted in an earlier group.
- A short note explains that every group here counts as "new" recruitment, because this
  product had no previous buyers.

### Story FE-3.3: Understand how the result was measured, in plain language

**As an** Advertiser,
**I want** a short, plain-language explanation of how the shopper data was turned into a
result,
**so that** I can trust the numbers and know what they do and don't prove.

**What this page shows:** three simple steps (building the shopper groups, finding everyone
who could have seen the ad, measuring what they bought), followed by one honest sentence: this
method shows what the selected shoppers bought, but it does not prove the ads caused it.

**KPIs used:** none — this is a plain-language explanation of method, not a number.

**What "done" looks like:**
- The three steps are shown in order, each with one short explanation a non-expert can follow.
- The limitation (this does not prove cause and effect) is stated here, not hidden in small
  print elsewhere.

---

## Epic FE-4 — Give the headline verdict

### Story FE-4.1: See the headline result the second I open the report

**As an** Advertiser,
**I want** to see the one most important number and the one most important finding right at
the top of the report,
**so that** I get the answer immediately, without reading the whole report first.

**What this page shows:** the total revenue and how many shoppers it came from, one sentence
explaining the strongest finding, a short "what stands out" list (best result, and anything
still blocked), and a three-step ladder showing how strong a claim this result is allowed to
make (today: "Descriptive" — what shoppers bought; later: "Attributed" and "Incremental").

**KPIs used:**
- **Revenue** — the headline number.
- **Shoppers** — how many people that revenue came from.
- **Conversion Rate** (for the segment that performed best, compared with the campaign
  average) — the strongest finding.

**What "done" looks like:**
- The headline revenue number and shopper count are the biggest, clearest thing on the page.
- The one-sentence summary never claims more than the data supports — it never says the ads
  "caused" the sale.
- The three-step ladder clearly shows which step this result is on, and that the other two
  steps are not available yet, with a one-line reason why.
- Clicking any item in the "what stands out" list jumps straight to the matching section
  further down the page.

### Story FE-4.2: Read the final, human-written conclusion

**As an** Advertiser,
**I want** a short written conclusion with learnings and recommendations at the end of the
report,
**so that** I know what to do next, not just what happened.

**What this page shows:** the type and version of this result, a "Learnings" list, a
"Recommendations" list, and a clearly separated "Limitations" box reminding the reader what
this result does not prove and how long it stays valid for.

**KPIs used:** none directly — this section is a short write-up built on top of the numbers
shown earlier in the report (revenue, conversion rate, e-commerce share, and so on).

**What "done" looks like:**
- Learnings and recommendations are shown as two clearly separate short lists, not one long
  paragraph.
- The limitations box is always visible, never hidden behind a click.
- The version number of the result is shown, so people know if they're looking at the latest
  one.

---

## Epic FE-5 — Show media delivery (and what's coming later)

### Story FE-5.1: See how well the ads actually delivered, versus what was planned

**As an** Advertiser,
**I want** to see how many people saw my ad and what it cost, compared with what was planned,
**so that** I know if the media partner delivered what they promised.

**What this page shows:** four simple number cards — impressions delivered, cost per
thousand impressions, reach, and clicks — each compared against the planned estimate where
one exists. A note makes clear these numbers come from the media partner, not from our own
calculations.

**KPIs used:**
- **Impressions** — how many times the ad was shown.
- **Estimated Impressions** — how many were planned (the benchmark for the card above).
- **CPM** — cost for every 1,000 impressions shown.
- **Estimated CPM** — the planned cost per 1,000 impressions (the benchmark for the card
  above).
- **Reach** — how many different shoppers saw the ad at least once.
- **Clicks** — how many times someone clicked the ad.

**What "done" looks like:**
- Each number card shows the actual result, and underneath it, the planned/estimated figure
  it's being compared with (or a clear "no reference value supplied" message if there isn't
  one).
- It's clear on screen that these four numbers come from the media partner and are not
  checked or calculated by us.

### Story FE-5.2: See a clear placeholder for "Attributed result", not an empty gap

**As an** Advertiser,
**I want** to see that a more advanced result type ("Attributed result") exists and will be
available later, with a reason why it isn't available yet,
**so that** I know what's coming and don't think something is broken or missing.

**What this page shows:** a locked/placeholder card explaining this result links a purchase to
a specific ad view using an agreed rule, that the rule isn't approved yet, who needs to
approve it, and roughly when it will arrive. Example numbers are shown greyed-out as a
preview of the shape of the future result.

**KPIs used (once unlocked, from the catalog, not shown live yet):**
- Attributed shoppers and attributed revenue — purchases linked to a specific ad view.
- **Average Time to Purchase** / **Median Time to Purchase** — how long after seeing the ad
  people bought.
- **Attribution Eligibility Rate** / **Attribution Link Creation Rate** — how much of the data
  was good enough to link a purchase to an ad view.

**What "done" looks like:**
- The section is visibly present on the page today, not hidden, even though it's locked.
- It explains in one sentence why it's locked, who can unlock it, and roughly when.
- The preview numbers are clearly marked as illustrative, not real results for this campaign.

### Story FE-5.3: See a clear placeholder for "Incremental impact", not an empty gap

**As an** Advertiser,
**I want** to see that the most advanced result type ("Incremental impact" — the extra sales
the campaign actually caused) exists and will be available later, with a reason why,
**so that** I understand this is the strongest possible claim and know what it takes to get
there.

**What this page shows:** a locked/placeholder card explaining this measures the extra sales
caused by the campaign (not just what selected shoppers bought), that it needs an approved
comparison method and sign-off, who needs to approve it, and that any future number here will
always be shown as a range, never a single confident figure.

**KPIs used:** none exist yet in the KPI Catalog for incremental/causal impact — see the Open
Questions section at the end of this document.

**What "done" looks like:**
- The section is visibly present today, clearly locked, with a plain reason why.
- Any future example number is shown as a range (a low and a high estimate), never as one
  exact number, because that's the whole point of this measurement type.

---

## Epic FE-6 — Show what shoppers bought

### Story FE-6.1: See how many shoppers bought something, out of everyone who could see the ad

**As an** Advertiser,
**I want** to see, in one glance, what share of people who could see my ad actually bought the
product,
**so that** I can judge whether the campaign led to real purchases.

**What this page shows:** a simple table total row, plus a "funnel" style card: the exposable
group on the left, an arrow, the number of buying shoppers on the right, and underneath, a bar
and a one-line explanation of what the percentage means.

**KPIs used:**
- **Exposable Audience** — everyone who could have seen the ad.
- **Shoppers** — how many of them bought something.
- **Conversion Rate** — the share of the exposable audience who bought something.

**What "done" looks like:**
- The bar always stays visible, even when the percentage is very small — the number, not the
  bar, should carry the meaning.
- The one-line explanation underneath always says something sensible about whether the
  percentage is normal, high, or low for this kind of campaign.

### Story FE-6.2: See which shopper group bought the most

**As an** Advertiser,
**I want** to see conversion results broken down by shopper group, side by side,
**so that** I can see which audience worked best and focus future campaigns there.

**What this page shows:** a table with one row per shopper group, showing the exposable
group, buying shoppers, and conversion rate for each, plus a total row at the top for
comparison.

**KPIs used:**
- **Exposable Audience**, **Shoppers**, **Conversion Rate** — same three numbers as the
  overview, but broken down per shopper group.
- **Shopper Share by Audience Segment** — how much of all buyers came from each group.
- **Conversion-Rate Difference** — how far each group's conversion rate is from the overall
  campaign average (used in the "what stands out" summary at the top of the report).

**What "done" looks like:**
- Every shopper group defined earlier in the report (Epic FE-3) appears here as its own row,
  in the same order.
- The total row is easy to tell apart from the individual group rows (for example, it's
  visually bolder).
- Column headers explain, on hover, that every number has one single agreed business
  definition behind it.

### Story FE-6.3: See the full shopping math for each shopper group

**As an** Advertiser,
**I want** to see the complete spending breakdown (revenue, baskets, items, prices) for each
shopper group,
**so that** I understand not just how many people bought, but how they spent their money.

**What this page shows:** a detailed table, one row per shopper group, with: how many
shoppers, total revenue, number of purchases, revenue per shopper, how often they bought,
average basket size, items per basket, and average price per item — plus a total row.

**KPIs used:**
- **Shoppers**, **Revenue**, **Transactions**, **Revenue per Shopper**, **Purchase
  Frequency**, **Average Basket Value**, **Items per Basket**, **Average Price per Product**.

**What "done" looks like:**
- All eight numbers are shown for every shopper group and for the total, lined up in
  columns so they're easy to compare row by row.
- The table scrolls sideways on smaller screens instead of squashing the numbers.

### Story FE-6.4: See how shoppers bought — online versus in physical stores

**As an** Advertiser,
**I want** to see how my campaign performed across the retailer's different shopping
channels (website versus physical stores),
**so that** I know whether my campaign is working everywhere or only in one channel.

**What this page shows:** a headline number card for online sales' share of revenue compared
with the category average, plus a table breaking down spending per channel (e-commerce,
hypermarket, supermarket).

**KPIs used:**
- **E-commerce Revenue Share** — what share of revenue came from online.
- **E-commerce Revenue Share Difference vs Category** — how that compares with the typical
  product in this category.
- **Revenue per Shopper**, **Average Basket Value**, **Average Price per Product**, **Items
  per Basket** — each repeated per channel.

**What "done" looks like:**
- The headline card clearly shows whether online share is above or below the category
  average, and by how much.
- A short note explains this is about where people shopped (online vs. in store), not which
  advertising channel was used — these are two different things and must not be confused.

---

## Epic FE-7 — Show who comes back

### Story FE-7.1: See how many shoppers came back to buy a second time

**As an** Advertiser,
**I want** to see how many of the shoppers who bought once came back and bought again,
**so that** I know if the campaign is building real repeat customers, not just one-off sales.

**What this page shows:** the same "funnel" style card as conversion — all buying shoppers on
the left, an arrow, repeat shoppers on the right, a bar, and a one-line explanation of exactly
what counts as a "repeat" shopper.

**KPIs used:**
- **Shoppers** — everyone who bought at least once (shown here as "purchasing shoppers").
- **Loyal Shoppers** — shoppers who bought at least twice.
- **Loyal Shopper Rate** — the share of shoppers who came back for a second purchase.

**What "done" looks like:**
- The definition of "repeat shopper" (bought on at least two separate occasions during the
  campaign) is always shown next to the number, not just implied.
- This card looks and behaves the same way as the conversion funnel card in Epic FE-6, so
  people learn the pattern once and reuse it.

---

## Epic FE-8 — Show who the buyers are

### Story FE-8.1: See what stage of life my buyers are in, compared with the category

**As an** Advertiser,
**I want** to see the age/life-stage mix of people who bought my product, compared with the
typical buyer in this category,
**so that** I know if I'm reaching the audience I expected.

**What this page shows:** two stacked, 100%-tall bar charts side by side — one for this
product's buyers, one for the category average — split into life-stage groups (for example
"Families", "25–39 years"), with a short note explaining what the comparison means. If the
category comparison figures weren't readable in the source report, the bar is clearly marked
as a placeholder.

**KPIs used:**
- **Buyer Share** — the life-stage mix of this product's buyers.
- **Category Buyer Share** — the life-stage mix of typical buyers in this category
  (the benchmark).
- **Buyer Share Difference vs Category** — how far apart the two are (used in the written
  note under the chart).

**What "done" looks like:**
- Both bars use the same colour for the same life-stage group, with one shared legend.
- Any benchmark value that is a placeholder (not a real confirmed number) is clearly labelled
  as such, so nobody mistakes it for a confirmed figure.

### Story FE-8.2: See what shopping style my buyers have, compared with the category

**As an** Advertiser,
**I want** to see whether my buyers are driven by quality, convenience, price, or deals,
compared with the category average,
**so that** I understand what message and offer will resonate with them.

**What this page shows:** the same style of two stacked bar charts as Epic FE-8.1, but split
by shopping style (for example "Gourmet", "Budget", "Deal seekers") instead of life stage.

**KPIs used:** same three KPIs as Story FE-8.1 — **Buyer Share**, **Category Buyer Share**,
**Buyer Share Difference vs Category** — applied to shopping style instead of life stage.

**What "done" looks like:**
- This section visually matches FE-8.1 exactly (same chart style, same legend behaviour) so
  it's clearly "the same kind of thing, different grouping".
- If this data isn't supplied by a particular retailer, the section shows the same
  "not supplied" explanation used elsewhere (see Epic FE-10), not a broken or empty chart.

---

## Epic FE-9 — Share and export the result

### Story FE-9.1: Share the approved result with the right people, safely

**As an** Advertiser or Retail Media Manager,
**I want** to share the finished report with specific people or teams, and see exactly what
information will be included before I send it,
**so that** I can confidently pass on results without oversharing or sending something
unfinished.

**What this page shows:** a pop-up with a box to search for people or teams, a preview of
exactly what the shared export will say (campaign, result type, data period, status and
version), and a note that the shared link re-checks the recipient's access every time it's
opened.

**KPIs used:** none directly — this is a summary of the metadata already shown elsewhere
(campaign scope, result type, data period, status/version), not new numbers.

**What "done" looks like:**
- Before sending, I can see exactly what the recipient will see — no surprises.
- Access is checked again every time the link is opened, not just once when it's shared, so
  someone who later loses permission can't still use an old link.
- Cancelling the pop-up changes nothing and loses no work.
- An "Export" button exists on the list and compare screens too, even though the exact file
  format is still an open decision (see Open Questions).

---

## Epic FE-10 — Explain when something isn't ready (applies everywhere)

### Story FE-10.1: Always tell me clearly why a number isn't showing yet, instead of hiding it or guessing

**As an** Advertiser,
**I want** any section that isn't ready to clearly say why, who can fix it, and roughly when
it will be ready,
**so that** I never mistake "not ready yet" for "there's nothing here" or get shown a wrong
number.

**What this page shows:** any section that can't show real numbers yet displays a plain
message box instead of a blank space or an empty chart. There are four reasons this can
happen, and each is explained in plain words:
- **Not available in this release** — the feature itself doesn't exist yet (for example,
  the Attributed result and Incremental impact sections).
- **Not supplied by the retailer** — the data needed for this section wasn't given to us for
  this retailer (for example, shopping-style profiles for some retailers).
- **Still being calculated** — the time window the result depends on hasn't closed yet, so
  the numbers will appear automatically once it does.
- **Data problem** — the media partner hasn't sent a file we need yet, and we won't guess a
  number in its place.

**KPIs used:** none — this is about the absence of a number, and the honest explanation for
that absence. The underlying health checks that can trigger this behaviour are data-quality
measures from the KPI Catalog's Diagnostic category, for example **Media Event Deduplication
Rate**, **Shopper Identity Match Rate**, and **Late-Arriving Data Rate** — these monitor data
health behind the scenes rather than being shown to the Advertiser directly.

**What "done" looks like:**
- Every "not ready" message always answers three questions: why, who can unblock it, and when.
- A "not ready" section never silently shows a zero, a dash with no explanation, or a made-up
  substitute number.
- The visual style for "not ready" sections is consistent everywhere it's used, so people
  learn to recognise it instantly.
- On the Campaign list and Compare screens, the same plain-English reasons appear as a status
  word or as a hover explanation, so the behaviour feels consistent across the whole product.

---

## Open questions for the team (found while mapping KPIs to the wireframe)

These are small gaps worth a quick conversation before development starts — not blockers.

1. **"Performance vs. target"** (shown on the Compare screen and in the Conclusion) isn't in
   the current KPI Catalog. It looks like it needs an agreed revenue target per campaign,
   which isn't defined as a KPI yet.
2. **Incremental impact** (Epic FE-5, Story FE-5.3) has no matching KPI anywhere in the
   current 50-KPI catalog. This makes sense since it's explicitly "not available in Release
   1", but it means the team will need to define this KPI from scratch before that section
   can ever go live.
3. The KPI Catalog itself still lists several KPIs as "Requires additional table" or
   "Requires confirmed physical table" (for example Exposable Audience, Conversion Rate,
   Media Spend, CPM Efficiency Ratio). Worth double-checking with Data Engineering which of
   the sections above are realistically buildable first.
4. Three fields the client still needs to supply are called out in the KPI Catalog:
   planned impressions, planned media spend, and currency code. Planned impressions and
   planned media spend directly affect the benchmark numbers used in Epic FE-5, Story
   FE-5.1 (the "estimated" comparisons on the delivery cards).
