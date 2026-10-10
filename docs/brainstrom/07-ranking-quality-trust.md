# 07 — Ranking, Quality & Trust

## Verified facts

- **ClassCentral ranking (classcentral.com/help + /rankings):** 200k+ learner
  reviews; "courses with many positive reviews rank higher"; annual "Best of
  Year/All Time" ranked by **Bayesian average** (accounts for quantity +
  recency), minimum-review threshold so small providers can compete; monthly
  popular = bookmark counts. Non-completion reviews allowed (reasons useful).
- **devroadmaps fork (github.com/cxqeric/devroadmaps):** 1706 resources with
  1-5★ community ratings + type filter (docs/video/course/tutorial/tool) +
  difficulty + search-within-roadmap. Proves lightweight local rating works
  without accounts.
- **CC licenses (creativecommons.org + Temple/Iowa OER guides):** six combos of
  BY/SA/NC/ND. Only BY, BY-SA, BY-NC, BY-NC-SA fully satisfy OER 5Rs
  (retain/reuse/revise/remix/redistribute); **BY-ND and BY-NC-ND forbid sharing
  adaptations → not OER**. YouTube's single CC option = CC BY 3.0.
- **R.A.I.S.E. trust pattern:** domain-restricted sources only + pre-display URL
  validation + `type:/level:/source:/lang:` filters.

## Analysis

V1 has no user base for Bayesian reviews yet. Proxy signals must come from source
metadata: GitHub ★/forks/updated-at, StackExchange score/accepted, YouTube
viewCount/duration, OCW completeness, Tavily relevance score. Freshness matters
(2022 React tutorial vs 2025 one). Difficulty must be explicit or beginners
drown.

## Brainstorm — scoring V1

```text
score = 0.35*source_authority + 0.25*community_signal +
  0.20*freshness + 0.20*level_match
- source_authority: OCW/freeCodeCamp/Khan/MDN=1.0; awesome-list curated=0.8;
  YT edu-channel=0.6; random blog=0.3
- community_signal: normalized log(stars|votes|ratings) per medium (no
  cross-medium raw compare)
- freshness: decay 1.0 (<1y) → 0.5 (3y) → 0.2 (>5y), except timeless (math)
  decay slower
- level_match: +1 if LLM-tagged level == requested level

Hard gates: URL must validate (HEAD with streamed-GET fallback for 405/403, plus
  Wayback fallback for dead links — see doc 04), permission gate must pass
  (robots.txt + Content Signals + TDMRep + noai resolved — see doc 04's
  permission stage), free_type in {OER-CC, FREE-FULL, AUDIT-ONLY,
  IMPLIED-LICENSE} (TRIAL hidden unless --include-trial), language match.
  If `free_type` is AUDIT-ONLY, the output must also say whether access is
  persistent or TIME-LIMITED (edX audit is explicitly temporary —
  <https://help.edx.org/edxlearner/s/article/What-is-the-audit-track>).
  IMPLIED-LICENSE items may appear only as index + snippet + attribution
  with a link back — never full-text republication, never training input
  (Field v. Google scope; Copyright Office Part 3 on training).
```

Dedup: normalize URL (strip tracking params,
youtu.be→youtube.com/watch?v=), keep highest-score copy. **Dedup is
two-level:** the URL-normalized hash feeds the index, and a content hash
(simhash or MinHash) catches near-duplicates — cross-platform reposts and
blog mirrors of the same article are common, and a recommender is judged on
surfacing the original, not the 14th repost.

## Recommendation

Show `score + why` (e.g., "★ 12k GitHub, updated 2026-03, beginner"). Store
`free_type` + `license` (CC BY/SA/NC) per item — ND items flagged "no-remix".
The `license` field is per item, not per provider: for example freeCodeCamp
curriculum is CC BY-SA 4.0 while its code is BSD-3
(<https://www.freecodecamp.org/news/building-a-data-science-curriculum-with-advanced-math-and-machine-learning/>

- <https://github.com/freecodecamp/freecodecamp>). For any CC BY-SA source —
Stack Exchange posts since 2018-05-02
(<https://meta.stackexchange.com/help/licensing>) and Wikimedia content
(<https://developer.wikimedia.org/en-gb/use-content/content/>) — store an
`attribution` string per item and render any shown snippet with its source link.
Note SE sells a separate AI/LLM data-licensing product, so bulk AI reuse is
  a different grant than display
  (<https://stackoverflow.co/data-licensing/>). Local `ratings.json`
  (1-5★, like devroadmaps) seeds future Bayesian ranking without accounts.
 LLM tags
`{level, prerequisites, minutes}` via strict schema; human-readable justification
required. Social signals (Bluesky, Reddit) stay cache-first, best-effort tiers
and never a hard ranking dependency: Bluesky has no published numeric read limit
and 429s have been reported after roughly 10–31 rapid calls
(<https://github.com/bluesky-social/atproto/discussions/2820>), and Reddit
requires pre-approval for all Data API access under the Responsible Builder
Policy
(<https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy>).

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
