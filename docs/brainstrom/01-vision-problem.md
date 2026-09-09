# 01 — Vision & Problem

## Verified facts

- **OER definition (UNESCO, Recommendation on OER adopted 2019-11-25,
  unesco.org):**
  > "learning, teaching and research materials in any format and medium that
  > reside in the public domain or are under copyright that have been released
  > under an open license, that permit no-cost access, re-use, re-purpose,
  > adaptation and redistribution."
  Open license = right to access, re-use, adapt, redistribute. This is
  stricter than "free to watch".
- **"Free" is tiered in practice:**
  - Coursera (coursera.support): `Preview` (first module only) vs `Full
    Course, No Certificate` (select courses, full materials, no cert) vs paid
    (certificate + graded work). Audit ≈ video+readings, no graded assignments.
  - Coursera Plus 2026: ~$59/mo or $399/yr for 7000+ courses (third-party
    pricing roundups, consistent with support page structure).
  - MIT OCW (ocw.mit.edu): 2500+ courses, no signup, no cert, CC-licensed,
    explicitly remixable for non-commercial use.
  - MIT Learn API (github.com/mitodl/ocw_oer_export) exposes
    `title/url/description/topics/instructors`, but the live data **mixes paid
    xPRO items with free OCW** — for example a $1,100 professional-cert item
    appears in `learning_resources`. An OCW adapter must therefore filter
    `platform=ocw` or `price==0`, or the free-first promise breaks. Schema:
    <https://api.learn.mit.edu/api/v1/schema/>; probe:
    <https://api.learn.mit.edu/api/v1/learning_resources/?search=python&limit=2>
  - freeCodeCamp (freecodecamp.org/news/about + GitHub 453k★). Code is BSD-3;
    curriculum content is **CC BY-SA 4.0** ("CC-BY-SA 4.0 to be exact" —
    <https://www.freecodecamp.org/news/building-a-data-science-curriculum-with-advanced-math-and-machine-learning/>).
    "Every aspect is 100% free — courses, projects, certifications."
    Donor-supported 501(c)(3), 100k+ claimed job transitions. License is
    two-part, so it must be recorded per item, not per provider.
- **"Free" has a fourth kind with no explicit license at all — implied
  license.** *Field v. Google* (D. Nev. 2006) held that an author who
  published publicly with no ToS, no robots.txt, and no license notice had
  granted an implied license for indexing and caching: website owners know
  crawlers exist and how to block them, and choosing not to communicates
  permission (<https://fairuse.stanford.edu/case/field-v-google-inc/> +
  <https://en.wikipedia.org/wiki/Field_v._Google,_Inc.>). The boundary that
  keeps a recommender safe: implied license covers *reading, indexing,
  recommending* — not republishing or model training. The U.S. Copyright
  Office's Part 3 report (May 2025) states that using copyrighted works to
  train AI models "may constitute prima facie infringement," with fair use a
  "matter of degree"
  (<https://www.copyright.gov/ai/Copyright-and-Artificial-Intelligence-Part-3-Generative-AI-Training-Report-Pre-Publication-Version.pdf>
  - <https://www.skadden.com/insights/publications/2025/05/copyright-office-report>).
- **Permission is now machine-readable, so "no license notice" no longer
  means "no signal."** Cloudflare's Content Signals Policy (Sep 2025) adds
  `search` / `ai-input` / `ai-train` categories to robots.txt
  (<https://blog.cloudflare.com/content-signals-policy/> +
  <https://developers.cloudflare.com/bots/additional-configurations/managed-robots-txt/>);
  the W3C TDMRep Community Group defines a `tdm-reservation` meta tag / HTTP
  header pointing to an ODRL policy
  (<https://www.w3.org/community/reports/tdmrep/CG-FINAL-tdmrep-20240510/>);
  the `noai` meta-tag convention asks AI crawlers not to train while
  allowing search; Cloudflare's pay-per-crawl (Jul 2025, private beta) sends
  HTTP 402 to flip the default from free to paid
  (<https://blog.cloudflare.com/introducing-pay-per-crawl/>). A site with no
  robots.txt in 2026 is not the same as one in 2006 — a Cloudflare-fronted
  site with "block AI training" flipped will 402 or challenge a crawler even
  though the HTML is publicly viewable.
- **News/text free tiers (broader than one publisher):** The Guardian Open
  Platform offers a free Developer key (non-commercial, archive back to
  1999, <https://open-platform.theguardian.com/>); NewsAPI.org's free
  Developer tier (~100 req/day, delayed articles, attribution required,
  <https://newsapi.org/pricing>) gives broad shallow coverage. These
  complement GDELT (free, open) for news breadth without any crawler.
- **The gray zone is a spectrum, not a binary.** Defensible: caching with
  snippets + attribution (*Authors Guild v. Google*), archival indexing of
  public content that drives traffic back, aggressive use of sitemaps/RSS
  (explicit invitations). Legally contestable but litigable: crawling sites
  whose `ai-train: no` signal blocks training but not discovery (the
  author's *spirit* may be "no AI at all" — if any fine-tuning exists, the
  letter-vs-spirit line becomes real); crawling sites whose author has
  objected publicly though no machine signal exists (documented objections
  weaken implied license); scraping soft-paywall content that is technically
  public but monetized behind auth. Legally risky, do not touch: bypassing
  access controls, authenticating then scraping, spoofing a User-Agent to
  impersonate another crawler (e.g. Googlebot), and scraping content an
  opt-out signal explicitly excludes — being told "no" in machine-readable
  form destroys the "I didn't know" defense and undermines any fair-use
  argument.
- **Discovery is fragmented (verified by existence, not opinion):**
  ClassCentral (reviews/bookmarks), open.school (own index + LLM
  summarization), Eduqia (Google-search wrapper over 15 platforms), roadmap.sh
  (365k★ community roadmaps). No single tool covers video + MOOC + GitHub +
  reddit + wikis + awesome-lists with a free-first filter — that gap is the
  opportunity. MOOCable (<https://www.moocable.com/mooc>) is a real comparable
  here as a cohort-based learning platform (HN launch 2024-07:
  <https://news.ycombinator.com/item?id=41024964>), but its claimed "200k
  courses / 2050 subjects" figure could not be verified on moocable.com or any
  independent source; the site is JS-rendered and the only trace of the "largest
  aggregator" phrasing is a college LinkedIn post, so it should be treated as an
  existence-check comparable only, not as a verified data point. Khan Academy is
  also a useful comparable for K-12/free curriculum, but it has had **no public
  API since 2020** (<https://github.com/Khan/khan-api> +
  <https://support.khanacademy.org/hc/en-us/community/posts/10760720860813-API-Key>),
  so it can only enter the taxonomy as a curated YAML entry.

## Analysis

- Users conflate three kinds of "free": (a) truly OER/CC, (b) audit-only (no
  cert/graded), (c) time-limited trial. V1 must label which one each result is,
  or trust collapses.
- Incumbents either curate narrowly (OCW, freeCodeCamp) or aggregate shallowly
  (Eduqia = Google wrapper). R.A.I.S.E.'s differentiator — "only verified open
  platforms, validate each URL, never fabricate" — is the trust bar to copy.
- General-learner scope is the hardest (any field) but also avoids competing
  head-on with dev-only roadmaps.

## Brainstorm — problem statements considered

1. "Too many tabs, no map." → solve with `path` (ordered roadmap, not list).
2. "Free means trap." → solve with free-type labels + license filter.
3. "Links rot / hallucinated." → solve with validation + source-API-only URLs.
4. "New fields have no coverage." → solve with expandable source registry (see
   `03`).
5. "Good content is buried by bad SEO and has no license notice." → not a
   gap but a match: implied license (Field v. Google) covers index + snippet
   - link-back, and the machine-readable signal layer (Content Signals,
   TDMRep, `noai`) is what must be *resolved*, not absent, before ingesting.

## Recommendation for V1

- **Vision:** "Ask any topic, get a verified free-first learning path across all
  mediums, in your terminal."
- **Non-goals (to remove distraction):** no certificates, no progress accounts,
  no paid recommendations, no mobile/web, no social features, no
  biometric/face-image collection (BIPA exposure — see Verified facts), no
  gray-zone tactics from the "do not touch" tier.
- **Free taxonomy V1 (must show in output):** `OER-CC` / `FREE-FULL`
  (freeCodeCamp, Khan) / `AUDIT-ONLY` (Coursera/edX audit) / `IMPLIED-LICENSE`
  (public, no paywall/login/opt-out signal — index + snippet + link back
  under *Field v. Google*; never republish or train on it without separate
  analysis) / `TRIAL` — never show trial as "free". The label is two-dimensional because audit access is
  **time-limited, not permanently free**: edX states "As a free audit learner,
  you will have temporary access to course materials except graded assignments"
  (<https://help.edx.org/edxlearner/s/article/What-is-the-audit-track> +
  <https://help.edx.org/edxlearner/s/article/What-are-the-differences-between-audit-free-and-verified-paid-courses>),
  and Coursera audit is likewise scope-limited. So each result should also say
  whether an AUDIT-ONLY item is persistent or TIME-LIMITED.
- **MIT Learn adapter rule:** any OCW source powered by
  <https://api.learn.mit.edu/api/v1/courses/> must filter `platform=ocw` or
  `price==0`, because the same endpoint also returns paid xPRO items.

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
