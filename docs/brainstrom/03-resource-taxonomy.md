# 03 — Resource Taxonomy (all mediums + how we grow by skill)

## Verified facts (primary sources)

- **Video:** YouTube Data API v3 free, no billing. `10,000 units/day` shared
  pool + separate `100x search.list/day` bucket (developers.google.com/youtube/v3
  /guides + quota calculator). `videos.list/channels.list/playlistItems.list = 1
  unit`; `captions.list = 50 units`; `search.list` = limited bucket. No paid tier — only audit extension. Compliance constraint beyond quota: the
  Developer Policies require API Clients to **delete or refresh stored data
  after 30 calendar days** (Section III.E,
  <https://developers.google.com/youtube/terms/developer-policies>), so the
  cache layer must treat YouTube metadata as refreshable, not archival.
- **Code/OSS:** GitHub REST search — 30 req/min authenticated (10/min code
  search), 10/min unauthenticated, ≤1000 results, 4000 repos scanned
  (docs.github.com/en/rest/search). `awesome-*` lists are plain repos →
  discoverable via `GET
  /search/repositories?q=awesome+<topic>`.
- **Q&A/forums:** Stack Exchange API v2.3 entirely free; 300 req/day/IP no key,
  10,000/day with free key from stackapps.com (api.stackexchange.com/docs +
  publicapis.io). `/search/advanced?q=&tagged=&site=stackoverflow` covers
  "existing answers as learning resource".
- **Social/community:** Reddit Data API free 100 QPM OAuth personal/research, 10
  QPM anon; commercial $0.24/1K + contract, ML-training banned
  (redditinc.com 2023-06-15). Since late 2025 the **Responsible Builder Policy
  requires pre-approval for ALL Data API access, including personal/non-commercial**,
  and self-serve OAuth apps no longer get tokens automatically
  (<https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy>;
  announcement:
  <https://www.reddit.com/r/redditdev/comments/1oug31u/>; terms:
  <https://redditinc.com/policies/data-api-terms>). The "100 QPM personal" line
  is true only *after* approval, so Reddit is **not a V1 adapter** — it
  becomes a V2/optional source behind a documented user-supplied-approval
  flow (user applies,
  user's own client id, cache-first reads). Related archival caveat:
  **Pushshift** (historical Reddit dumps) is now restricted to approved
  moderators for community-moderation use only
  (<https://support.reddithelp.com/hc/en-us/articles/16470271632404-Pushshift-Access-Request>)
  — plan around its unavailability, not with it. Bluesky AT Protocol:
  `app.bsky.feed.searchPosts` public via `https://public.api.bsky.app`, generous
  limits, `limit≤100`, no token for reads (bsky.network/docs/rate-limits,
  endpoints.bsky.app). There is **no published numeric read limit**; official
  guidance asks devs to use the cached `public.api.bsky.app` and considers reads
  "generous". Community reports show 429s on `searchPosts` after roughly 10–31
  rapid calls (<https://github.com/bluesky-social/atproto/discussions/2820>), so
  Bluesky is a cache-first, best-effort social-signal tier, not a ranking
  dependency. **Bluesky Jetstream** is the push-based alternative for
  real-time text: a public, unauthenticated WebSocket feed of the full AT
  Protocol firehose, filtered server-side by collection (e.g.
  `wantedCollections=app.bsky.feed.post`), per
  <https://bsky.network/docs/jetstream/> — the documented, sanctioned path and
  the single best source of real-time public social text; Jetstream is
  read-scale infrastructure, so a client should still cache and sample rather
  than treat it as a query API. X/Instagram: no viable free tier → link-out
  only in V1 — X since early 2026 bills the API **pay-per-use with no real
  free tier** (post read ≈ $0.005, user read ≈ $0.01, per the official
  pricing page <https://docs.x.com/x-api/getting-started/pricing> and the
  pay-per-use pilot announcement
  <https://devcommunity.x.com/t/announcing-the-x-api-pay-per-use-pricing-pilot/250253>;
  the old $200/mo Basic and $5,000/mo Pro tiers were replaced by this model
  in early 2026 — third-party reporting),
  X's ToS also explicitly prohibits unauthorized scraping, so there is no
  legal scrape fallback — if X content ever becomes core to the product,
  the options are budgeting for the API or inheriting a licensed data
  reseller's compliance posture, not scraping), and Instagram's Basic
  Display API reached end of life 2024-12-04
  (<https://developers.facebook.com/blog/post/2024/09/04/update-on-instagram-basic-display-api/>):
  personal accounts cannot use the Graph API, and hashtag search is capped at
  30 unique hashtags per 7-day rolling window per
  <https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/hashtag-search>
  (publishing is likewise capped, ≈25 posts/24h per account — third-party
  reporting, unverified against Meta docs), so the only compliant path is
  account-owner-consented Graph API access — breadth is structurally
  impossible. **Threads** is research-only: Meta
  Content Library access requires affiliation with a qualified academic or
  research institution and CASD review
  (<https://transparency.meta.com/researchtools/meta-content-library/> +
  <https://developers.facebook.com/docs/content-library-and-api/get-access/>),
  so Threads text is out of reach through developer channels — and even
  approved researchers face a combined **500,000-record cap per rolling
  7-day window** across Library UI and API
  (<https://developers.facebook.com/docs/content-library-and-api/content-library-api/guides/rate-limiting/>).
  **LinkedIn** rounds out the walled gardens: self-serve API terms cap apps
  at **≤100,000 lifetime users**
  (<https://www.linkedin.com/legal/l/api-terms-of-use>), member profile data
  may be stored only **24 hours** and social-activity data **48 hours**
  (<https://learn.microsoft.com/en-us/linkedin/marketing/data-storage-requirements?view=li-lms-2026-08>),
  and the Partner/Vetted programs approve established products in
  Talent/Marketing/Sales/Learning — not general data collection. So
  LinkedIn is link-out only, same as X/Instagram. **Mastodon** is
  the best "free + legal" social source after Bluesky: open REST API per
  instance, default limit **300 requests per 5 minutes per IP/account**
  (adjustable by instance admins,
  <https://docs.joinmastodon.org/api/rate-limits/>).
- **OER/courses:** MIT OCW 2500+ CC courses, no signup (ocw.mit.edu); MIT Learn
  API exposes `title/url/description/topics/instructors` for export
  (github.com/mitodl/ocw_oer_export) **but the live data mixes paid xPRO items
  with free OCW**, so an OCW adapter must filter `platform=ocw` or `price==0`.
  freeCodeCamp curriculum content is **CC BY-SA 4.0** while its code is BSD-3, so
  license must be recorded per item, not per provider. Coursera audit =
  lectures+readings, no graded/cert (coursera.support).
- **Khan Academy** (khanacademy.org) is frequently mentioned as a free curriculum
  source, but it has had **no public API since 2020**
  (<https://github.com/Khan/khan-api> +
  <https://support.khanacademy.org/hc/en-us/community/posts/10760720860813-API-Key>).
  Its K-12 courses can still enter V1, only as **curated YAML entries**, not as
  an API adapter.
- **Roadmaps/guides:** roadmap.sh 365k★, open-core, role+skill roadmaps; its
  structure (node ids/order) is reusable, but **node markdown content is
  all-rights-reserved** — the repo `license` file (GitHub API `NOASSERTION`) is a
  custom all-rights-reserved notice allowing personal use only and requiring prior
  consent to share content outside the repo, with only links shareable
  (<https://github.com/kamranahmedse/developer-roadmap/blob/master/license>, via
  <https://api.github.com/repos/kamranahmedse/developer-roadmap/license>). So
  V1 should **link out to nodes only** and never import or redistribute node
  markdowns; the `devroadmaps` fork is still useful as proof that the *structure*
  can be JSON-ized (17 roadmaps, 795 topics, 1706 free resources with
  type/difficulty filters). `awesome-roadmaps` (liuchong) indexes dozens of niche
  roadmaps.

## Analysis

- Three access tiers emerge: (A) **API-stable** (GitHub, StackExchange, Bluesky,
  OCW/Learn) → build adapters now. (B) **Quota-gated** (YouTube search, Reddit)
  → use sparingly + cache. (C) **No-API** (X/Insta, many wikis/blogs) →
  LLM-assisted domain-restricted search + curated seed lists, never scrape against
  ToS.
- **The access ladder generalizes across tiers:** open protocols first
  (Jetstream, Mastodon timelines, RSS/Atom, sitemap.xml) → official APIs →
  and only for the long tail a logged-off crawl that resolves the
  permission-signal layer first (doc 04). The legal posture per run is fixed
  by two facts: scraping publicly accessible data without login is not a CFAA
  violation (*hiQ Labs v. LinkedIn*, 9th Cir. 2022 —
  <https://cdn.ca9.uscourts.gov/datastore/opinions/2022/04/18/17-16783.pdf> +
  <https://www.eff.org/cases/hiq-v-linkedin>), and a logged-off visitor is
  not a "user" bound by the site ToS (*Meta v. Bright Data*, N.D. Cal. 2024 —
  <https://www.fbm.com/publications/major-decision-affects-law-of-scraping-and-online-data-collection-meta-platforms-v-bright-data/>
  - <https://blog.ericgoldman.org/archives/2024/01/game-on-bright-data-scores-major-victory-in-web-scraping-dispute-with-meta-guest-blog-post.htm>).
  The moment a real account authenticates, collection enters clickwrap-ToS
  territory — so the rule is: never authenticate to collect.
- **Two EU regimes bind any ingestion at scale.** EU copyright (DSM
  Directive Art. 4) permits text-and-data mining **unless the rights-holder
  has reserved it via machine-readable opt-out** — the TDMRep/Content
  Signals layer (doc 04) is exactly that reservation, so honoring it is a
  legal requirement, not etiquette. And if Learning-Hog ever adds model
  training beyond retrieval-and-recommend, the EU AI Act's GPAI transparency
  obligations require publishing a summary of training-content sources and
  respecting the same opt-outs — the provenance log (doc 06) is the
  groundwork for both.
- "Grow by skill/field" cannot be hard-coded. Verified precedent (roadmap.sh node
  markdowns + devroadmaps JSON) shows the way: data-driven registry.

## Brainstorm — taxonomy V1

|Tier|Mediums|V1 adapter|
|---|---|-------------------------------------------------------------------------------|
|video|YouTube (curated channels/playlists)|`videos.list`+`playlistItems.list` (1 unit), cache 7d|
|courses|OCW (Learn API, filtered), freeCodeCamp, Khan, Coursera-audit, edX-audit|static YAML + filtered Learn API pull|
|code|GitHub repos, awesome-lists, gists|`search/repositories` (30/min)|
|qa|StackOverflow/Exchange|SE API (10k/day w/ key); CC BY-SA 4.0 since 2018-05-02; snippets need attribution (<https://meta.stackexchange.com/help/licensing>)|
|social-signal|Bluesky search (cache-first, best-effort) + Jetstream firehose (optional real-time ingest); Mastodon public timelines (300 req/5 min default); link-out for X/Insta/LinkedIn|`searchPosts q+sort=top`; Jetstream WebSocket filtered to `app.bsky.feed.post`; Reddit deferred to V2 behind user-approval flow|
|text|wikis, guides, docs, ebooks (OpenStax, MDN) + RSS/Atom feeds + sitemap.xml as the primary crawl invitation|curated domains + validation; feed/sitemap discovery before any crawl|
|roadmaps|roadmap.sh structure, awesome-roadmaps, devroadmaps JSON|skeleton/ordering only, never redistribute node markdowns|

## Recommendation — `SourceRegistry` design (core differentiator)

```yaml
# sources/python.yaml (example — one file per skill)
skill: python
sources:
  - id: ocw-python
    type: oer-api
    endpoint: https://api.learn.mit.edu/api/v1/courses/?platform=ocw&topic=python
    free_type: OER-CC
  - id: awesome-python
    type: github-search
    query: "awesome python language:markdown"
    free_type: FREE-FULL
  - id: freecodecamp-python
    type: curated
    urls: [https://www.freecodecamp.org/learn/scientific-computing-with-python/]
    license: CC-BY-SA-4.0
  - id: yt-core
    type: youtube-playlist
    playlist_ids: ["PL-..."]   # avoid search.list
  - id: so-python
    type: stackexchange
    site: stackoverflow
    tagged: python
    license: CC-BY-SA-4.0
    attribution: "Stack Exchange — CC BY-SA 4.0 (https://meta.stackexchange.com/help/licensing)"
```

New skill = new YAML, no code change. Router picks relevant sources by skill tag;
LLM only ranks/summarizes retrieved items. (Third-party scraping services such
as Apify/Firecrawl exist for walled platforms, but Learning-Hog does not use
them against ToS-prohibited platforms — the validator + permission gate docs
04/06 define our compliant posture instead.) Each source row should carry
`free_type` and, where relevant, `license` and `attribution`, because license is
per-item not per-provider (e.g. freeCodeCamp curriculum = CC BY-SA 4.0 while its
code = BSD-3).

**External audit (2026-09-07):** the additional verified-free sources are HN
Algolia (free, no key — <https://hn.algolia.com/api>),
Wikimedia/Wikipedia/Wikibooks/Wikiversity (free; descriptive User-Agent required
or 403/429 — <https://www.mediawiki.org/wiki/API:Etiquette>,
<https://foundation.wikimedia.org/wiki/Policy:Wikimedia_Foundation_User-Agent_Policy>)
with attribution required for content reuse
(<https://developer.wikimedia.org/en-gb/use-content/content/>), arXiv (≤1 req/3s
— <https://info.arxiv.org/help/api/tou.html>), OpenAlex (key required since Feb
2026, $1/day free allowance — <https://help.openalex.org/access/pricing/>), Open
Library (no key — <https://openlibrary.org/developers/api>), Internet Archive
advancedsearch + /metadata (no key —
<https://archive.org/developers/index-apis.html>), Wayback availability API
(link-rot fallback — <https://archive.org/help/wayback_api.php>), Openverse
(openly-licensed media, anon ~20 req/min & 200/day —
<https://api.openverse.org/>,
<https://github.com/WordPress/openverse/issues/5315>), Podcast Index (free dev
key — <https://podcastindex-org.github.io/docs-api/>), Google Custom Search JSON
(100 queries/day free —
<https://developers.google.com/custom-search/v1/overview>), Gutendex (~76k books,
no key — <https://gutendex.com/>; gutenberg.org forbids scraping —
<https://www.gutenberg.org/policy/robot_access.html>), and OER Commons (token
auth — <http://docs.oercommons.org/api/>).

**External audit (2026-09-07):** still-deferred taxonomy decisions are Khan =
curated-only (no public API since 2020), Reddit = not V1 (pre-approval under the
Responsible Builder Policy for all access), roadmap.sh nodes = link-out only
(all-rights-reserved content), MIT Learn adapter must filter `platform=ocw` or
`price==0`, Stack Exchange content is CC BY-SA 4.0 (snippets need attribution; SE
sells a separate AI/LLM data-licensing product,
<https://stackoverflow.co/data-licensing/>), and Bluesky reads have no published
numeric limit (best-effort, cache-first).
