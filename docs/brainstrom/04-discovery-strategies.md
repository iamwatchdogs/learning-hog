# 04 — Discovery Strategies (how we find without hallucinating)

## Verified facts

- **Anti-pattern proven:** OpenPath team documents "Bedrock hallucinates YouTube
  links, so we use the real API" (github.com/DeepikaSidda/OpenPath). R.A.I.S.E.
  policy: "AI never fabricates URLs. All links come directly from source APIs or
  domain-restricted searches" + pre-display URL validation.
- **Option A — source APIs (free tiers verified):**
  YouTube `videos.list` 1 unit (10k/day) vs `search.list` 100/day bucket;
  GitHub search 30/min auth; StackExchange 300/day anon → 10k/day with free key;
  Bluesky `searchPosts` public, generous limits.
- **Option B — LLM-optimized search API:** Tavily (docs.tavily.com): 1000 free
  credits/mo, no card; basic search = 1 credit, advanced = 2; aggregates ≤20
  sites/call with AI scoring/filtering for RAG. Purpose-built alternative to raw
  Serp/Bing snippets.
- **Option C — self-hosted meta-search:** SearXNG (docs.searxng.org): aggregates
  70+ engines, `GET /search?q=...&format=json`, no key when self-hosted (`docker
  run -p 8888:8080 searxng/searxng`), fully local-first compatible. Public
  instances often disable `json` → self-host recommended.
- **Option D — curated seed + LLM structuring:** roadmap.sh node markdowns +
  devroadmaps JSON (1706 resources) + `awesome-roadmaps` index prove static
  curation scales via community.
- **Permission signals are now machine-readable, and a crawler must resolve
  them per URL.** Cloudflare's Content Signals Policy (Sep 2025) adds three
  categories to robots.txt — `search` (index for search engines), `ai-input`
  (feed into AI for real-time answers), `ai-train` (use for model training)
  (<https://blog.cloudflare.com/content-signals-policy/> +
  <https://developers.cloudflare.com/bots/additional-configurations/managed-robots-txt/>);
  W3C TDMRep expresses a rights *reservation* via `<meta
  name="tdm-reservation">` or HTTP header plus a `tdm-policy` URL
  (<https://www.w3.org/community/reports/tdmrep/CG-FINAL-tdmrep-20240510/>);
  the `noai` / `noimageai` meta-tag convention asks AI crawlers not to train
  while still allowing search indexing; the **TDM.AI vocabulary** (Open
  Future) distinguishes a broad `no-tdm` opt-out from a
  generative-AI-specific `no-generative-ai` one
  (<https://openfuture.eu/publication/a-vocabulary-for-opting-out-of-ai-training-and-other-forms-of-tdm/> +
  <https://docs.tdmai.org/opt-out-opt-in-and-content-licensing>); Cloudflare
  pay-per-crawl (Jul 2025, private beta) returns HTTP 402 to flip the
  default from free to paid
  (<https://blog.cloudflare.com/introducing-pay-per-crawl/>). A site with no
  robots.txt in 2026 is not the same as a site with no robots.txt in 2006:
  behind Cloudflare, a flipped "block AI training" switch produces a 402 or
  a challenge even though the raw HTML remains publicly viewable.
- **The default legal posture for long-tail crawling is "public, logged-off,
  permission-respecting."** *Van Buren v. United States* (U.S. 2021) framed
  CFAA as a "gates-up-or-down" inquiry — going around a technological or
  credential barrier is unauthorized
  (<https://www.supremecourt.gov/opinions/20pdf/19-783_k53l.pdf>); *hiQ Labs
  v. LinkedIn* (9th Cir. 2022) held that scraping publicly accessible data
  is not a CFAA violation
  (<https://cdn.ca9.uscourts.gov/datastore/opinions/2022/04/18/17-16783.pdf>),
  and *Meta v. Bright Data* (N.D. Cal. 2024) held that a logged-off visitor
  is not a "user" bound by the site ToS — but authenticating flips both
  (<https://www.fbm.com/publications/major-decision-affects-law-of-scraping-and-online-data-collection-meta-platforms-v-bright-data/>).
  Clickwrap ("I agree" at signup) is enforceable; browsewrap (a passive
  footer link) is much weaker
  (<https://www.termsfeed.com/blog/browsewrap-clickwrap/>) — never rely on
  the weaker form to justify collection. GDPR consent is **not** a workable
  basis for scraped data — it cannot be informed and voluntary for data
  subjects who don't know the scraper exists; legitimate interest is the
  standard basis (CNIL focus sheet on web scraping,
  <https://www.cnil.fr/en/legal-basis-legitimate-interest-focus-sheet-measures-implement-case-data-collection-web-scraping>).
  robots.txt is not legally binding by itself, but violating it reads as bad
  faith in court and some ToS incorporate it by reference — respect it.
- **Biometric risk is out of scope by construction:** BIPA (Illinois)
  litigation shows the cost of scraping facial imagery — Clearview AI's
  class settlement (approved Mar 2025) was worth ~$51.75M
  (<https://www.regulatoryoversight.com/2025/04/51-75m-settlement-in-clearview-ai-biometric-privacy-litigation-illustrates-creative-resolution-for-startups-facing-parallel-litigation-and-enforcement-action/>
  - <https://www.aclu.org/cases/aclu-v-clearview-ai>). Learning-Hog is
  text-only, which sidesteps this entire exposure.
- **Zero-cost corpora exist for historical depth and news breadth:** Common
  Crawl (>300B pages, monthly ~2B+ page crawls since 2007, WET files carry
  extracted text for text-heavy pipelines; FineWeb is a 15T-token
  quality-filtered derivative of 96 Common Crawl snapshots —
  <https://commoncrawl.org/> + <https://commoncrawl.org/about> +
  <https://huggingface.co/spaces/HuggingFaceFW/blogpost-fineweb-v1>).
  Provenance caveat from the Data Provenance Initiative's *Consent in
  Crisis* study (Longpre et al., 2024): **~45% of the C4 derivative's
  content is restricted by the source sites' ToS** for AI/for-profit use
  (<https://www.dataprovenance.org/Consent_in_Crisis.pdf> +
  <https://en.wikipedia.org/wiki/Common_Crawl>) — another reason
  per-source provenance tracking is mandatory if corpus items ever feed
  anything beyond retrieval-and-recommend; FineWeb's own filtering does not
  resolve the underlying rights question. Recent CC snapshots have also
  moved to Hugging Face hosting (<https://commoncrawl.org/blog/april-2026-crawl-archive-now-available-in-a-hugging-face-storage-bucket>).
  GDELT monitors world news in 100+ languages, free and open
  (<https://www.gdeltproject.org/>); its Global Knowledge Graph adds
  machine-readable entities, themes, and tone — useful metadata for
  recommendation; RSS/Atom feeds and sitemap.xml are
  fully-sanctioned distribution — many "bad SEO" sites publish sitemaps
  without realizing it, which is the site literally telling crawlers "here
  is my content index."

## Analysis / evaluation

|Strategy|Cost V1|Trust|Coverage|Verdict|
|---|---|---------------|---------------|--------------------------|
|LLM-only generation|$0|❌ hallucinates|broad but fake|reject|
|Source APIs + curated YAML|$0|✅ real URLs|deep where|**V1 default**|
|Tavily (1000 free/mo)|$0 to start|✅ real + snippets|broad web|**V1 optional flag** (`--web`)|
|Google Custom Search JSON (100/day free)|$0 to start|✅ real URLs|broad web|**free `--web` baseline**|
|SearXNG self-host|$0 + docker|✅ real|broad, needs hosting|V1.5 local-first alt|
|Full crawl/Scrape|high + ToS risk|⚠️ fragile|broad|defer|
|Zero-cost corpora (Common Crawl WET/FineWeb, GDELT, RSS/sitemaps)|$0|✅ sanctioned or public|historical + news breadth|**V1.5 optional adapters** (CC is archive-scale, not query-scale — sample, don't query)|

Math: 1000 Tavily basic searches/mo ≈ 33/day free — enough for CLI personal use,
not for server scale. YouTube `search.list` 100/day is the binding constraint if
misused; `videos.list` 10k/day is not.

## Brainstorm — V1 pipeline

```text
NL query → LLM parses structured filters (grammar-restricted, MDPI pattern)
  → SourceRouter (skill YAML picks adapters)
  → parallel fetch: github / stackexchange / youtube-playlist / ocw-static /
    hn-algolia / [tavily if --web or GCS if --web]
  → validate URLs (HTTP HEAD with streamed-GET fallback for 405/403, <5s
    timeout, follow redirects, realistic User-Agent, per-domain rate limit) +
    dedup by normalized URL
  → for dead links, attempt the free Wayback availability API
    (<https://archive.org/help/wayback_api.php>) and show the archived URL
    with a flag rather than dropping it
  → permission gate (per URL, first stage of ingest; resolves before any
    content is stored):
      robots.txt allows our UA? → no ⇒ reject
      Content Signals (search/ai-input/ai-train) in robots.txt → honor
      TDMRep meta/header (`tdm-reservation`) → honor
      noai / noimageai meta tags → honor
      explicit license found (CC-BY/CC0/MIT…)? → yes ⇒ follow its terms
      public, no login required? → yes ⇒ proceed as IMPLIED-LICENSE
        (index + snippet + attribution, log the signal snapshot)
      → model training or republication is NEVER presumed from implied
        license — separate analysis required (Copyright Office Part 3:
        training on copyrighted works "may constitute prima facie
        infringement")
    log per fetch: source URL, timestamp, HTTP status, raw signal values,
    ToS/robots state at fetch time (re-robots.txt changes are then
    provable as post-dating the crawl); re-check signals on our own
    schedule — Cloudflare caches robots.txt at the edge by default, so
    signal changes can lag the origin
  → LLM rerank + summarize (only over fetched items, with citations)
  → present table + save JSON cache
```

## Recommendation

V1 = **curated + source-APIs by default, Tavily behind `--web` flag, Google
Custom Search behind `--web` as the free baseline (100 queries/day,
<https://developers.google.com/custom-search/v1/overview>), SearXNG URL via
`SEARXNG_URL` env**. Hard rule (copy R.A.I.S.E.): any URL not returned by an
adapter or validation step is dropped, never shown. For long-tail text
(news sites, forums, niche blogs), the crawl posture is **public,
logged-off, permission-respecting**: seed from sitemap.xml and RSS/Atom
  feeds first (explicit invitations), fall back to seed-URL crawling only
  for sites with no signals at all, respect `Crawl-delay`, keep per-domain
  crawls conservative (≈1 req/s ceiling, exponential backoff on 429/503,
  and a priority queue of domains ordered by next-allowed-request time so
  workers always pull the most-eligible target),
  and never authenticate with a real user account on the target platform —
  authenticating places collection inside clickwrap ToS (*Meta v. Bright
  Data* protects only logged-off scraping). The anti-bot reality for the
  long tail: major sites deploy Cloudflare/DataDome/PerimeterX-class
  defenses, and stock Playwright is trivially flagged (`navigator.webdriver`,
  headless fingerprints —
  <https://scrapfly.io/blog/posts/playwright-stealth-bypass-bot-detection>).
  Stealth plugins, residential proxies, and behavioral simulation are the
  scrapers' standard countermeasures, but every bypass technique
  strengthens a "knowing circumvention" argument under CFAA/contract law —
  so anti-bot bypass (stealth plugins, residential proxies, challenge
  solving) is out of scope, and if a site's defenses make compliant
  crawling impossible, that source is dropped rather than defeated. GDPR
applies regardless of author intent: any text tied to an identifiable
person is personal data, the lawful basis is legitimate interest with a
documented three-part test (CNIL guidance; EDPB Guidelines 03/2026 on web
scraping for generative AI —
<https://www.edpb.europa.eu/system/files/2026-07/edpb_guidelines_2020603_webscraping_v1_en_0.pdf>),
so minimize at ingestion: store content hash + source URL, strip author
PII unless the byline is needed for attribution, and honor deletion
requests. The validator must not stop at
HEAD — many servers return 405 or bot-blocking 403 on HEAD even when the resource
is fine (<https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405>),
so the check must HEAD-first and then fall back to a streamed GET with capped
bytes, follow redirects, send a realistic User-Agent, and rate-limit per domain.
In addition, fetched titles/descriptions/summaries are **untrusted text** flowing
into LLM prompts (OWASP LLM01:2025 —
<https://genai.owasp.org/llmrisk/llm01-prompt-injection/> +
<https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html>);
treat them as data, delimit + sanitize, never follow instructions found in them.
Any fetch of an adapter-returned URL for validation or explanation also needs SSRF
hardening: http/https scheme allowlist, block private/loopback/link-local IPs, cap
redirects
(<https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html>).
This keeps V1 $0-cost, offline-capable except optional web, and hallucination-free.

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
