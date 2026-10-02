# 09 — Research References (primary sources only)

> Rule followed: every design claim in `01–08` traces to a primary doc below, not
> model memory. Fetched September 2026. Verify again before building — quotas/pricing
> change. The 10-gap-analysis audit has been folded into docs 01–08; this file is
> the primary-source list.

## OER / free definitions

- UNESCO OER definition + 2019 Recommendation —
  <https://www.unesco.org/en/open-educational-resources>
- MIT OCW (2500+ courses, no signup, CC) —
  <https://ocw.mit.edu/> + <https://ocw.mit.edu/pages/get-started/>
- MIT Learn API export pattern —
  <https://github.com/mitodl/ocw_oer_export>
- freeCodeCamp (100% free, BSD-3, 453k★) —
  <https://www.freecodecamp.org/news/about/> +
  <https://github.com/freecodecamp/freecodecamp>
- Coursera enrollment options (Preview vs Full-No-Cert) —
  <https://www.coursera.support/s/article/learner-000001306>
- CC licenses (BY/SA/NC/ND, six combos; ND ≠ OER) —
  <https://creativecommons.org/course/cc-cert-edu/unit-3-anatomy-of-a-cc-license/3-3-license-types/>

## Aggregators / roadmaps (existence + patterns)

- ClassCentral reviews/rankings (Bayesian average) —
  <https://www.classcentral.com/> +
  <https://www.classcentral.com/rankings> +
  <https://www.classcentral.com/help/instructor-corner>
- MOOCable (200k courses) — <https://www.moocable.com/mooc>
- R.A.I.S.E. (verified-only, never fabricate URLs, filter syntax) —
  <https://raise-education.org/about>
- Open.School (own index + GPT summarization + NL queries) —
  <https://open.school/>
- OpenPath (YouTube Data API + Tavily + Bedrock, hallucinates-links lesson,
  in-prompt RAG) — <https://github.com/DeepikaSidda/OpenPath>
- roadmap.sh (365k★, open-core, node markdowns) —
  <https://github.com/kamranahmedse/developer-roadmap> +
  <https://roadmap.sh/about>
- awesome-roadmaps index — <https://github.com/liuchong/awesome-roadmaps>
- devroadmaps JSON (17 paths, 1706 resources, ratings/filters) —
  <https://github.com/cxqeric/devroadmaps>

## Source APIs / quotas

- YouTube Data API quota + calculator (10k units/day, 100 search.list/day bucket,
  videos.list=1) — <https://developers.google.com/youtube/v3/guides/quota_and_compliance_audits>
  - <https://developers.google.com/youtube/v3/determine_quota_cost>
- GitHub REST search (30/min auth, 10/min anon/code, 1000 results) —
  <https://docs.github.com/en/rest/search/search>
- Stack Exchange API (free, 300/day anon → 10k/day w/ key) —
  <https://api.stackexchange.com/docs> +
  <https://api.stackexchange.com/docs/search>
- Reddit API terms (100 QPM free personal, $0.24/1K commercial, ML ban) —
  <https://redditinc.com/news/apifacts>
- Bluesky rate limits + searchPosts (public.api.bsky.app, generous) —
  <https://bsky.network/docs/rate-limits/> +
  <https://endpoints.bsky.app/>
- Tavily (LLM search, 1000 credits/mo free, basic=1/advanced=2) —
  <https://docs.tavily.com/documentation/api-credits> +
  <https://docs.tavily.com/documentation/about>
- SearXNG search API (`/search?q=&format=json`, self-host, no key) —
  <https://docs.searxng.org/dev/search_api>

## LLM / CLI / MCP

- Ollama OpenAI-compat (`localhost:11434/v1`, key ignored) + structured
  outputs — <https://docs.ollama.com/api/openai-compatibility> +
  <https://docs.ollama.com/capabilities/structured-outputs>
- LM Studio OpenAI-compat (`localhost:1234/v1`) —
  <https://lmstudio.ai/docs/developer/openai-compat>
- OpenAI Structured Outputs vs JSON mode —
  <https://developers.openai.com/api/docs/guides/structured-outputs>
- openai-python env (`OPENAI_API_KEY`/`OPENAI_BASE_URL`, default
  `https://api.openai.com/v1`) —
  <https://github.com/openai/openai-python/blob/5e8f09c2/src/openai/_client.py>
- Typer (type-hint CLIs, Rich errors) — <https://typer.tiangolo.com/> +
  <https://github.com/fastapi/typer/>
- httpx HEAD/timeouts (5s default) —
  <https://www.python-httpx.org/api/> +
  <https://www.python-httpx.org/advanced/timeouts/>
- LLM course-search parsing (grammar-restricted, anti-hallucination) —
  <https://www.mdpi.com/2673-4591/103/1/18>
- MCP spec 2026-07-28 (tools/resources/prompts, JSON-RPC, stateless) —
  <https://modelcontextprotocol.io/specification/2026-07-28>
- MCP Python SDK Tier-1 (`mcp[cli]`, FastMCP→MCPServer) —
  <https://github.com/modelcontextprotocol/python-sdk>

## Re-verify before code

YouTube audit path, Reddit commercial terms, Tavily credit costs, Ollama/LM
Studio compat matrices — all change yearly.

### MCP / spec

- [F] MCP spec 2026-07-28 versioning/lifecycle — "Servers MUST implement
  `server/discover`"; no initialize handshake in modern revisions —
  <https://modelcontextprotocol.io/specification/2026-07-28/basic/lifecycle>

### Legal / licensing

- [V] Reddit Responsible Builder Policy (pre-approval for ALL Data API
  access) — <https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy>
- [V] RBP announcement thread —
  <https://www.reddit.com/r/redditdev/comments/1oug31u/>
- [V] Reddit Data API Terms (references RBP) —
  <https://redditinc.com/policies/data-api-terms>
- [V] Community reports on approval friction —
  <https://www.reddit.com/r/redditdev/comments/1r2ukkb/>
- [V] Reddit API 2026 overview —
  <https://www.redditapis.com/blogs/reddit-data-api-2026>
- [V] Timeline writeup (Nov 2025 self-serve closed; May 2026 .json → 403) —
  <https://medium.com/@alex_79882/reddits-api-is-officially-dead-in-2026-here-s-what-i-use-instead-f88ee5b809c8>
- [F] roadmap.sh repo license = custom all-rights-reserved (`NOASSERTION`):
  personal use; content sharing needs prior consent; links only —
  <https://api.github.com/repos/kamranahmedse/developer-roadmap/license>
- [V] Khan Academy API removal notice —
  <https://github.com/Khan/khan-api> +
  <https://support.khanacademy.org/hc/en-us/community/posts/10760720860813-API-Key>
- [V] edX audit = temporary access —
  <https://help.edx.org/edxlearner/s/article/What-is-the-audit-track> +
  <https://help.edx.org/edxlearner/s/article/What-are-the-differences-between-audit-free-and-verified-paid-courses>
- [V] freeCodeCamp curriculum CC BY-SA 4.0 —
  <https://www.freecodecamp.org/news/building-a-data-science-curriculum-with-advanced-math-and-machine-learning/>
- [V] Stack Exchange content CC BY-SA 4.0 —
  <https://meta.stackexchange.com/help/licensing>
- [V] Stack Overflow Data Licensing (separate AI/LLM product) —
  <https://stackoverflow.co/data-licensing/>
- [V] Wikimedia content reuse —
  <https://developer.wikimedia.org/en-gb/use-content/content/>

### Data acquisition, scraping & permissions (doc 00 amendment section, docs 01–08 weaving; researched 2026-09-08)

> Origin: research conversation archived at
> `chats/addressing-concerns-regarding-data-fetching-and-scraping.json`.
> Claims below were re-verified against the primary sources listed here
> before integration (chat-only figures that could not be re-verified —
> e.g. X's exact monthly read cap — were dropped or softened).

- [V] *hiQ Labs v. LinkedIn* (9th Cir. Apr 18, 2022) — scraping publicly
  available data is not "unauthorized access" under CFAA —
  <https://cdn.ca9.uscourts.gov/datastore/opinions/2022/04/18/17-16783.pdf>
  - <https://www.eff.org/cases/hiq-v-linkedin>
- [V] *Meta Platforms, Inc. v. Bright Data Ltd.* (N.D. Cal. Jan 2024,
  summary judgment) — logged-off visitors are not "users" bound by Meta's
  ToS; breach-of-contract claim dismissed —
  <https://www.fbm.com/publications/major-decision-affects-law-of-scraping-and-online-data-collection-meta-platforms-v-bright-data/>
  - <https://blog.ericgoldman.org/archives/2024/01/game-on-bright-data-scores-major-victory-in-web-scraping-dispute-with-meta-guest-blog-post.htm>
- [V] *Field v. Google, Inc.* (D. Nev. 2006) — implied license for indexing
  and caching from publishing publicly without robots.txt/ToS barriers —
  <https://fairuse.stanford.edu/case/field-v-google-inc/> +
  <https://en.wikipedia.org/wiki/Field_v._Google,_Inc.>
- [V] *Authors Guild v. Google, Inc.* (2d Cir. Oct 16, 2015) — full-text
  book indexing with limited snippet display is transformative fair use —
  <https://law.justia.com/cases/federal/appellate-courts/ca2/13-4829/13-4829-2015-10-16.html>
- [V] U.S. Copyright Office, *Copyright and Artificial Intelligence — Part 3:
  Generative AI Training* (pre-publication, May 2025) — training on
  copyrighted works "may constitute prima facie infringement"; fair use is
  fact-specific —
  <https://www.copyright.gov/ai/Copyright-and-Artificial-Intelligence-Part-3-Generative-AI-Training-Report-Pre-Publication-Version.pdf>
  - <https://www.skadden.com/insights/publications/2025/05/copyright-office-report>
- [V] EDPB Guidelines 03/2026 on web scraping in the context of generative AI
  (draft for public consultation, Jul 2026) — legitimate interest is the
  realistic lawful basis; documented balancing test required —
  <https://www.edpb.europa.eu/system/files/2026-07/edpb_guidelines_2020603_webscraping_v1_en_0.pdf>
- [V] Cloudflare Content Signals Policy (Sep 2025) — `search` / `ai-input` /
  `ai-train` categories in robots.txt —
  <https://blog.cloudflare.com/content-signals-policy/> + docs
  <https://developers.cloudflare.com/bots/additional-configurations/managed-robots-txt/>
- [V] W3C TDM Reservation Protocol (TDMRep) CG FINAL Report (May 2024) —
  `tdm-reservation` meta tag / HTTP header + ODRL policy URL —
  <https://www.w3.org/community/reports/tdmrep/CG-FINAL-tdmrep-20240510/>
- [V] Cloudflare Pay Per Crawl (private beta, Jul 1, 2025) — HTTP 402
  payment flow for AI crawlers —
  <https://blog.cloudflare.com/introducing-pay-per-crawl/> + changelog
  <https://developers.cloudflare.com/changelog/post/2025-07-01-pay-per-crawl/>
- [V] Bluesky Jetstream docs (public WebSocket firehose, collection
  filtering incl. `app.bsky.feed.post`) — <https://bsky.network/docs/jetstream/>
- [V] X API pay-per-use pricing (post read $0.005, user read $0.01; no
  subscriptions) — <https://docs.x.com/x-api/getting-started/pricing> +
  pilot announcement
  <https://devcommunity.x.com/t/announcing-the-x-api-pay-per-use-pricing-pilot/250253>
- [V] Instagram Basic Display API deprecation (end of life Dec 4, 2024) —
  <https://developers.facebook.com/blog/post/2024/09/04/update-on-instagram-basic-display-api/>
- [V] Instagram hashtag search limit (30 unique hashtags / 7-day window) —
  <https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/hashtag-search>
- [V] Meta Content Library & API (qualified academic/research institutions;
  CASD proposal review) —
  <https://transparency.meta.com/researchtools/meta-content-library/> +
  <https://developers.facebook.com/docs/content-library-and-api/get-access/>
- [V] Mastodon rate limits (300 req / 5 min per account/IP default,
  admin-adjustable) — <https://docs.joinmastodon.org/api/rate-limits/>
- [V] Common Crawl (300B+ pages, ~monthly crawls, WET text extracts) —
  <https://commoncrawl.org/> + <https://commoncrawl.org/about>
- [V] FineWeb (15T-token dataset from 96 Common Crawl snapshots) —
  <https://huggingface.co/spaces/HuggingFaceFW/blogpost-fineweb-v1> + paper
  <https://arxiv.org/html/2406.17557v1>
- [V] GDELT Project (100+-language news monitoring, free and open) —
  <https://www.gdeltproject.org/>
- [V] Pushshift access restricted to approved moderators, moderation use
  cases only —
  <https://support.reddithelp.com/hc/en-us/articles/16470271632404-Pushshift-Access-Request>
  - <https://pushshift.io/>
- [V] Meta Content Library rate limit (500,000 records per rolling 7-day
  window, Library UI + API combined) —
  <https://developers.facebook.com/docs/content-library-and-api/content-library-api/guides/rate-limiting/>
- [V] LinkedIn API Terms of Use (self-serve: ≤100,000 lifetime users) —
  <https://www.linkedin.com/legal/l/api-terms-of-use>
- [V] LinkedIn Marketing API data storage (profile 24h, member content
  48h) —
  <https://learn.microsoft.com/en-us/linkedin/marketing/data-storage-requirements?view=li-lms-2026-08>
- [V] CNIL focus sheet: web scraping lawful basis = legitimate interest —
  <https://www.cnil.fr/en/legal-basis-legitimate-interest-focus-sheet-measures-implement-case-data-collection-web-scraping>
- [V] GDPR consent criteria (freely given, specific, informed, unambiguous
  — unattainable for scraping's data subjects) —
  <https://www.cnil.fr/en/ensuring-lawfulness-data-processing-legal-basis>
- [V] YouTube Developer Policies III.E (delete or refresh stored data after
  30 calendar days) —
  <https://developers.google.com/youtube/terms/developer-policies>
- [F] YouTube quota calculator (captions.list = 50 units) —
  <https://developers.google.com/youtube/v3/determine_quota_cost>
- [F] X restricted use cases / enforcement (suspension for misuse) —
  <https://docs.x.com/developer-terms/restricted-use-cases>
- [F] navigator.webdriver / headless fingerprint detection (Playwright
  stealth context) —
  <https://scrapfly.io/blog/posts/playwright-stealth-bypass-bot-detection>
- [V] Clearview AI BIPA class settlement (~$51.75M, approved Mar 2025) —
  <https://www.regulatoryoversight.com/2025/04/51-75m-settlement-in-clearview-ai-biometric-privacy-litigation-illustrates-creative-resolution-for-startups-facing-parallel-litigation-and-enforcement-action/>
  - <https://www.aclu.org/cases/aclu-v-clearview-ai>
- [F] Clickwrap vs browsewrap enforceability —
  <https://www.termsfeed.com/blog/browsewrap-clickwrap/>
- [F] TDM.AI opt-out vocabulary (no-tdm vs no-generative-ai) —
  <https://openfuture.eu/publication/a-vocabulary-for-opting-out-of-ai-training-and-other-forms-of-tdm/>
  - <https://docs.tdmai.org/opt-out-opt-in-and-content-licensing>
- [F] The Guardian Open Platform (free Developer key, archive to 1999) —
  <https://open-platform.theguardian.com/>
- [F] NewsAPI.org free Developer tier (~100 req/day, attribution) —
  <https://newsapi.org/pricing>
- [V] Data Provenance Initiative, *Consent in Crisis* (Longpre et al.,
  2024): ~45% of C4 restricted by source-site ToS for AI/for-profit use —
  <https://www.dataprovenance.org/Consent_in_Crisis.pdf>
- [F] Common Crawl snapshots moving to Hugging Face hosting —
  <https://commoncrawl.org/blog/april-2026-crawl-archive-now-available-in-a-hugging-face-storage-bucket>
- [F] Van Buren v. United States (U.S. 2021) — CFAA "gates-up-or-down"
  framing — <https://www.supremecourt.gov/opinions/20pdf/19-783_k53l.pdf>
  (background context for the hiQ analysis)

### Additional source APIs (taxonomy gaps)

- [V] Hacker News Algolia Search API (free, no key) —
  <https://hn.algolia.com/api>
- [V] MediaWiki API etiquette (identify + contact info) —
  <https://www.mediawiki.org/wiki/API:Etiquette>
- [V] Wikimedia User-Agent policy (403/429 for missing UA) —
  <https://foundation.wikimedia.org/wiki/Policy:Wikimedia_Foundation_User-Agent_Policy>
- [V] arXiv API Terms of Use (≤1 req/3s) —
  <https://info.arxiv.org/help/api/tou.html>
- [V] OpenAlex pricing (key required since Feb 2026, $1/day free) —
  <https://help.openalex.org/access/pricing/> +
  <https://blog.openalex.org/openalex-api-new-features-and-usage-based-pricing/>
- [V] OpenAlex rate limits —
  <https://github.com/ourresearch/openalex-docs/blob/main/how-to-use-the-api/rate-limits-and-authentication.md>
- [V] Open Library APIs (free, no key) —
  <https://openlibrary.org/developers/api> +
  <https://openlibrary.org/dev/docs/api/search>
- [V] OER Commons API (token auth) — <http://docs.oercommons.org/api/>
- [V] Internet Archive tools & APIs —
  <https://archive.org/developers/index-apis.html> +
  <https://archive.org/advancedsearch.php>
- [V] Wayback Machine availability API (free, no key) —
  <https://archive.org/help/wayback_api.php>
- [F] Openverse API (openly-licensed media; key optional for light use) —
  <https://api.openverse.org/> + ToS
  <https://wordpress.github.io/openverse-api/terms_of_service.html>
- [F] Openverse throttling tiers (standard/enhanced/exempt) —
  <https://docs.openverse.org/api/reference/authentication_and_throttling.html>
- [V] Openverse anonymous limits (20 req/min, 200 req/day) —
  <https://github.com/WordPress/openverse/issues/5315>
- [V] Podcast Index API (free dev key) —
  <https://podcastindex-org.github.io/docs-api/>
- [V] Google Custom Search JSON API (100 queries/day free) —
  <https://developers.google.com/custom-search/v1/overview>
- [V] Gutendex (Project Gutenberg JSON API, no key) — <https://gutendex.com/>
- [V] Project Gutenberg robot policy (no site scraping; use Gutendex) —
  <https://www.gutenberg.org/policy/robot_access.html>

### LLM providers / structured outputs

- [F] Groq Structured Outputs (strict json_schema on select models; no
  streaming/tool-use) — <https://console.groq.com/docs/structured-outputs>
- [F] Gemini OpenAI-compat endpoint —
  <https://ai.google.dev/gemini-api/docs/openai>
- [F] Gemini native structured outputs (JSON Schema subset) —
  <https://ai.google.dev/gemini-api/docs/structured-output>
- [V] Gemini structured-output improvement announcement —
  <https://blog.google/innovation-and-ai/technology/developers-tools/gemini-api-structured-outputs/>
- [V] Gemini OpenAI-compat layer ignoring schemas (community report) —
  <https://discuss.ai.google.dev/t/structured-output-not-working-via-the-openai-compatible-layer/108341>
- [F] OpenRouter credit & rate limits —
  <https://openrouter.ai/docs/api_reference/limits>
- [V] OpenRouter free-tier numbers (50/day, 20/min) —
  <https://openrouter.zendesk.com/hc/en-us/articles/39501163636379-OpenRouter-Rate-Limits-What-You-Need-to-Know>
- [V] Groq rate limits (~30 RPM free tier) —
  <https://console.groq.com/docs/rate-limits>
- [V] Instructor validate-and-retry pattern —
  <https://python.useinstructor.com/>

### Security / validation

- [V] OWASP LLM Top 10 — LLM01:2025 Prompt Injection —
  <https://genai.owasp.org/llmrisk/llm01-prompt-injection/>
- [V] OWASP LLM Prompt Injection Prevention Cheat Sheet —
  <https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html>
- [V] OWASP SSRF Prevention Cheat Sheet —
  <https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html>
- [V] MDN HTTP 405 (HEAD-only link-check false negatives) —
  <https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405>

### Comparables / misc

- [F] Bluesky rate limits (writes: 5,000 pts/hr, 35,000 pts/day; reads
  "generous", no published numbers; PDS global 3,000 req/5min by IP) —
  <https://bsky.network/docs/rate-limits/>
- [V] Bluesky searchPosts 429 reports (~10–31 rapid calls) —
  <https://github.com/bluesky-social/atproto/discussions/2820> +
  <https://www.reddit.com/r/BlueskySocial/comments/1hs2f5m/bluesky_rate_limits/>
- [F] MOOCable HN launch (existence; cohort platform; stats unverified) —
  <https://news.ycombinator.com/item?id=41024964>
- [V] MIT Learn API live probe (HTTP 200, count 12489; paid xPRO items mixed
  in) — <https://api.learn.mit.edu/api/v1/learning_resources/?search=python&limit=2>
  - schema <https://api.learn.mit.edu/api/v1/schema/>
- [F] YouTube Data API quota calculator (search.list own 100/day bucket @ 1
  unit) — <https://developers.google.com/youtube/v3/determine_quota_cost>
- [F] PyPI name check (`learning-hog` available, 404) —
  <https://pypi.org/pypi/learning-hog/json>

### Still unverified after audit (do not cite as fact)

- MOOCable course/subject counts; OpenRouter live docs-table daily numbers
  (support article says 50/day); Groq free RPM/RPD exact figures; Gemini
  OpenAI-compat strict-schema behavior per model; Bluesky numeric read limits;
  X API monthly post-read cap (third-party sources conflict: ~2M vs ~3M);
  Instagram ≈25-posts/24h publishing cap (third-party reporting only);
  X Basic/Pro tier replacement dates (third-party reporting only).

## Prior-art / existing-solutions research (doc 10, fetched 2026-09-08)

> Repo metadata below was pulled live from the GitHub REST API on 2026-09-08
> (stars drift daily — re-verify before external citation). Product pages
> were fetched the same day. Full claim-by-claim mapping is in
> `10-references-existing-solutions.md`.

### Repo metadata (GitHub API, live)

- [F] roadmap.sh repo (owner now `nilbuild`; `kamranahmedse/...` redirects;
  profile confirms nilbuild = Kamran Ahmed) — 366,537★, license NOASSERTION,
   pushed 2026-09-07 — <https://api.github.com/repos/nilbuild/developer-roadmap>
  - <https://api.github.com/users/nilbuild>
- [F] freeCodeCamp — 455,189★, BSD-3-Clause, pushed 2026-09-07 —
  <https://api.github.com/repos/freeCodeCamp/freeCodeCamp>
- [F] free-programming-books — 396,219★, CC-BY-4.0, pushed 2026-09-06 —
  <https://api.github.com/repos/EbookFoundation/free-programming-books>
- [F] OSSU computer-science — 208,809★, MIT, pushed 2026-07-14 —
  <https://api.github.com/repos/ossu/computer-science>
- [F] The Odin Project curriculum — 13,018★, NOASSERTION (CC BY-NC-SA 4.0
  per license.md), pushed 2026-09-07 —
  <https://api.github.com/repos/TheOdinProject/curriculum>
- [F] Anki — 30,404★, AGPL-3.0+BSD-3 portions (per LICENSE file), pushed
  2026-09-07 — <https://api.github.com/repos/ankitects/anki>
- [F] awesome (sindresorhus) — 504,012★, CC0-1.0, pushed 2026-09-02 —
  <https://api.github.com/repos/sindresorhus/awesome>
- [F] awesome-courses (prakhar1989) — 70,956★, no license, stale (last push
  2023-05-04) — <https://api.github.com/repos/prakhar1989/awesome-courses>
- [F] open-source-cs (ForrestKnight) — 23,751★, MIT, pushed 2025-06-11 —
  <https://api.github.com/repos/ForrestKnight/open-source-cs>
- [F] awesome-roadmaps (liuchong) — 7,325★, "ZERO PUBLIC LICENSE" (custom,
  restrictive), pushed 2026-08-03 —
  <https://api.github.com/repos/liuchong/awesome-roadmaps>
- [F] devroadmaps (cxqeric) — MIT, pushed 2026-05-11 —
  <https://api.github.com/repos/cxqeric/devroadmaps>
- [F] OpenPath (DeepikaSidda) — 0★, **no license**, pushed 2026-04-15 —
  <https://api.github.com/repos/DeepikaSidda/OpenPath>
- [F] open_deep_research (langchain-ai) — 12,675★, MIT, **ARCHIVED**, pushed
  2026-08-10 — <https://api.github.com/repos/langchain-ai/open_deep_research>
- [F] deep-research (dzhng) — 19,650★, MIT, pushed 2026-04-11 —
  <https://api.github.com/repos/dzhng/deep-research>
- [F] GPT Researcher — 29,337★, Apache-2.0, pushed 2026-08-27 —
  <https://api.github.com/repos/assafelovic/gpt-researcher>
- [F] Kolibri (Learning Equality) — 1,114★, MIT, pushed 2026-09-03 —
  <https://api.github.com/repos/learningequality/kolibri>
- [F] Exercism org activity: main repo pushed 2024-03-01 (no license);
  website AGPL-3.0 pushed 2026-09-04; problem-specifications MIT pushed
  2026-09-02 — <https://api.github.com/repos/exercism/website> +
  <https://api.github.com/repos/exercism/problem-specifications>
- [F] ocw-studio (mitodl) — 14★, BSD-3-Clause, pushed 2026-09-07 —
  <https://api.github.com/repos/mitodl/ocw-studio>
- [F] Missing Semester (MIT) — 6,038★, CC BY-NC-SA 4.0 (license.md), pushed
  2026-09-08 — <https://api.github.com/repos/missing-semester/missing-semester>

### License files (raw fetches)

- [F] Anki LICENSE — "GNU Affero General Public License, version 3 or later,
  with portions contributed by Anki users licensed under the BSD-3 license" —
  <https://raw.githubusercontent.com/ankitects/anki/main/LICENSE>
- [F] Odin curriculum license.md — CC BY-NC-SA 4.0 —
  <https://raw.githubusercontent.com/TheOdinProject/curriculum/main/license.md>
- [F] Missing Semester license.md — CC BY-NC-SA 4.0 —
  <https://raw.githubusercontent.com/missing-semester/missing-semester/master/license.md>
- [F] roadmap.sh `license` file (verbatim capture) — all-rights-reserved:
  personal use only; sharing links OK; redistribution of content requires
  prior consent —
  <https://raw.githubusercontent.com/nilbuild/developer-roadmap/master/license>
- [F] awesome-roadmaps LICENSE — "ZERO PUBLIC LICENSE" (restrictive) —
  <https://raw.githubusercontent.com/liuchong/awesome-roadmaps/master/LICENSE>

### Implementation-structure probes (GitHub contents API / raw)

- [F] freeCodeCamp `curriculum/` = curriculum.json + blocks/ + superblocks/
  - schema/ + structure/ + licenses/ + i18n-curriculum (schema-first
  curriculum data) — <https://api.github.com/repos/freeCodeCamp/freeCodeCamp/contents/curriculum>
- [F] roadmap.sh roadmaps data = `roadmaps/<slug>/content/<node-slug>@<node-id>.md`
  (node-per-file addressing; sample listing fetched for python) —
  <https://api.github.com/repos/nilbuild/developer-roadmap/contents/roadmaps/python/content?ref=master>
- [F] Odin curriculum = dir-per-course (foundations/ javascript/ databases/
  nodeJS/ getting_hired/ …) with markdownlint/prettier/codespell linting —
  <https://api.github.com/repos/TheOdinProject/curriculum/contents/>
- [F] OSSU README — degree-requirements design + explicit course criteria
  (open enrollment, regular/self-paced runs) —
  <https://raw.githubusercontent.com/ossu/computer-science/master/README.md>
- [F] Exercism canonical-data.json — machine-readable exercise specs with
  UUIDs, cases, expected values —
  <https://raw.githubusercontent.com/exercism/problem-specifications/main/exercises/accumulate/canonical-data.json>
- [F] OpenPath README — full architecture (React SPA + 7 Lambdas + Bedrock
  Nova Pro + DynamoDB single-table + S3 in-prompt RAG), "YouTube Data API for
  real video URLs… no fake/hallucinated links" —
  <https://raw.githubusercontent.com/DeepikaSidda/OpenPath/main/README.md>
- [F] dzhng/deep-research README — breadth/depth recursive loop, learnings +
  directions, local-LLM via OPENAI_ENDPOINT/OPENAI_MODEL —
  <https://raw.githubusercontent.com/dzhng/deep-research/main/README.md>
- [F] open_deep_research README — LangGraph supervisor/researcher/compression
  architecture; #6 on Deep Research Bench (2025-08-02); needs structured
  outputs + tool calling —
  <https://raw.githubusercontent.com/langchain-ai/open_deep_research/main/README.md>
- [F] GPT Researcher README — planner/execution agents + publisher; inspired
  by Plan-and-Solve + RAG papers —
  <https://raw.githubusercontent.com/assafelovic/gpt-researcher/master/README.md>
- [F] Kolibri README — offline-first learning platform by Learning Equality —
  <https://raw.githubusercontent.com/learningequality/kolibri/develop/README.md>

### Product behavior pages (fetched 2026-09-08)

- [F] OpenAI Deep Research launch + updates (Feb 2025 → Feb 2026: MCP
  connections, trusted-site restriction, real-time progress) —
  <https://openai.com/index/introducing-deep-research/>
- [F] Gemini Deep Research — plan→search→reason→report pipeline; user-editable
  research plan; "pioneered the Deep Research product category … December
  2024" (vendor claim) — <https://gemini.google/overview/deep-research/>
- [F] Perplexity Deep Research — dozens of searches, hundreds of sources,
  2–4 min, free tier —
  <https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research>
- [F] Claude Research — iterative agentic search, "easy-to-check citations"
  — <https://claude.com/blog/research>
- [F] NotebookLM Audio Overviews — grounded in user sources with citations;
  "not a comprehensive or objective view … simply a reflection of the sources
  that you've uploaded" —
  <https://blog.google/innovation-and-ai/products/notebooklm-audio-overviews/>
- [F] NotebookLM Discover Sources — describe topic → gathers hundreds of web
  sources → presents up to 10 recommendations with annotated summaries →
  one-click import —
  <https://blog.google/innovation-and-ai/models-and-research/google-labs/notebooklm-discover-sources/>
- [F] ChatGPT study mode — Socratic questioning, scaffolding, knowledge
  checks, built with pedagogy experts —
  <https://openai.com/index/chatgpt-study-mode/>
- [F] Gemini Guided Learning — step-by-step, quizzes, multimodal, LearnLM —
  <https://blog.google/products-and-platforms/products/education/guided-learning/>
- [F] Anki manual — active recall + spaced repetition rationale; FSRS —
  <https://docs.ankiweb.net/background.html>
- [F] The Odin Project about — 1,896,601 learners, 5000+ contributors,
  founded 2013 — <https://www.theodinproject.com/about>
- [F] roadmap.sh about — Astro + Tailwind on GitHub Pages, open-core,
  "7th most starred opensource project", redistribution prohibited —
  <https://roadmap.sh/about>

### New conflicts / unverified (doc 10 §4)

- roadmap.sh canonical URL must standardize on `nilbuild/...` (redirect
  verified) — update older citations in docs 03/07/09 opportunistically.
- open_deep_research archived vs active-presenting README — frozen reference
  only.
- Gemini "pioneered Dec 2024" is a vendor claim; Perplexity/OpenAI launched
  Feb 2025 — chronology not independently confirmed.
- Unverified: OpenPath demo deployment status; NotebookLM current import
  formats; live star counts beyond the 2026-09-08 snapshot; roadmap.sh total
  roadmap count.
