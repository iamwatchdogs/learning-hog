# 12 — How Agentic Tools Do Data Fetching & Fact Validation (Implementation Research)

> Research date: 2026-09-08. **Grounding rule:** every claim below traces to a
> fetched source in §7 — live GitHub REST API metadata, raw source files pulled
> from the default branch, official docs pages, or arXiv abstracts. Vendor docs
> are marked where applicable. Method: for every project, (1) live API metadata
> (stars/license/activity, 2026-09-08 snapshot), (2) **actual source code**
> fetched and read for the fetch/validation layer (not just READMEs), (3)
> official docs for closed harnesses. Claims that could not be traced are
> quarantined in §6. This doc follows docs 10/11: it does not repeat them —
> doc 10/11's research agents (dzhng, GPT Researcher) and answer engines (Vane,
> Morphic, STORM) are only cited here where their *fetch/validation*
> mechanics matter.

**The question this doc answers:** when other agents need a resource or need to
validate a fact/URL, how exactly do they fetch it, what guardrails do they
apply, and what can Learning-Hog adopt for docs 03/04/06/07?

## 0. Scope & method

Four layers studied:

- **(A) MCP fetch servers** — the standard tool interface agents use for URL
  fetching: official `modelcontextprotocol/servers` fetch server (source read),
  jae-jae/fetcher-mcp (Playwright-based).
- **(B) Agent frameworks' built-in fetch tools** — huggingface/smolagents
  (`WebSearchTool`, `VisitWebpageTool` — source read), OpenAI Agents SDK
  (hosted tools), Haystack `LinkContentFetcher` (source-level API study).
- **(C) Scraping/crawling backends agents call** — firecrawl, crawl4ai,
  jina-ai/reader (the three dominant "URL → LLM-ready markdown" services);
  linkwarden/monolith (archive-preservation pattern); lychee (link validation).
- **(D) Fact-validation research systems** — RARR (post-hoc
  retrieve-and-revise), FActScore (atomic-fact verification), Vectara HHEM
  (hallucination-detection model), plus how closed harnesses (Claude/Claude
  Code web tools, Gemini grounding, OpenAI Agents SDK) design fetch/validate.

## 1. Shortlist table (live GitHub API, 2026-09-08)

| Project | Repo | Activity (pushed) | License | Stars | What it is | Why studied |
| --- | --- | --- | --- | --- | --- | --- |
| MCP fetch server | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) (`src/fetch/`) | 2026-09-03 | **MIT→Apache-2.0 transition** (LICENSE verbatim: new contributions Apache-2.0, docs CC-BY-4.0, legacy MIT contributions remain MIT) | 90,165 | The reference `fetch` MCP tool | The de-facto fetch contract every MCP agent sees |
| fetcher-mcp | [jae-jae/fetcher-mcp](https://github.com/jae-jae/fetcher-mcp) | 2026-01-14 | MIT | 1,083 | MCP server fetching via Playwright headless browser | The "browser when static HTTP fails" pattern |
| smolagents | [huggingface/smolagents](https://github.com/huggingface/smolagents) | 2026-08-25 | Apache-2.0 | 29,237 | Barebones agent library; `default_tools.py` | Canonical minimal `web_search` + `visit_webpage` tool source |
| OpenAI Agents SDK | [openai/openai-agents-python](https://github.com/openai/openai-agents-python) | 2026-09-08 | MIT | 29,273 | Multi-agent framework with hosted tools | How a first-party harness ships fetch as a hosted tool |
| Haystack | [deepset-ai/haystack](https://github.com/deepset-ai/haystack) | 2026-09-08 | Apache-2.0 | 26,450 | Pipeline framework; `LinkContentFetcher` | Production fetcher component design (retries, UA rotation) |
| Firecrawl | [firecrawl/firecrawl](https://github.com/firecrawl/firecrawl) | 2026-09-08 | **AGPL-3.0** | 177,987 | "Context API to search, scrape, and interact with the web" — markdown/JSON output, OSS + hosted | The service most research agents default to for scraping |
| Crawl4AI | [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai) | 2026-09-08 | Apache-2.0 | 81,981 | Open-source LLM-friendly crawler | Full OSS crawl stack: hooks, content filters, extraction strategies |
| Jina Reader | [jina-ai/reader](https://github.com/jina-ai/reader) | 2026-05-22 | Apache-2.0 | 11,965 | URL→LLM input via `r.jina.ai/` prefix; search via `s.jina.ai/` | Zero-code URL→markdown; search+fetch composite pattern |
| lychee | [lycheeverse/lychee](https://github.com/lycheeverse/lychee) | 2026-09-08 | Apache-2.0 | 3,895 | Async link checker (Rust) — broken URLs + mail addresses in local files/sites | Direct precedent for doc 04's URL validator; has a GitHub Action |
| linkwarden | [linkwarden/linkwarden](https://github.com/linkwarden/linkwarden) | 2026-09-08 | AGPL-3.0 | 19,710 | Collaborative bookmark manager that preserves pages | Snapshot/archive preservation of saved links |
| monolith | [Y2Z/monolith](https://github.com/Y2Z/monolith) | 2026-05-25 | CC0-1.0 | 15,468 | Bundles any web page into one HTML file (assets embedded as data URLs) | Cheapest preservation primitive; renderable offline |
| RARR | [anthonywchen/RARR](https://github.com/anthonywchen/RARR) | 2023-06-22 (dormant) | no license file | 53 | Research-And-Revise: post-hoc retrieve evidence, edit LLM output to match | The canonical post-generation validation loop (arXiv:2210.08726) |
| FActScore | [shmsw25/FActScore](https://github.com/shmsw25/FActScore) | 2025-04-13 | MIT | 457 | Atomic-fact decomposition + per-fact verification vs a knowledge source | Factuality metric for `explain`/`chat` QA (EMNLP 2023) |
| HHEM | model [vectara/hallucination_evaluation_model](https://huggingface.co/vectara/hallucination_evaluation_model) (+ [vectara/hallucination-leaderboard](https://github.com/vectara/hallucination-leaderboard)) | repo 2026-05-11 | Apache-2.0 (both) | model 220,919 downloads / 364 likes; repo 3,313★ | Cross-encoder hallucination-rating model + LLM hallucination leaderboard | Free local model that scores consistency of text vs sources |

## 2. Deep dives — fetch layer (how they fetch)

### 2.1 MCP fetch server — the standard fetch contract (source read)

Read from `src/fetch/src/mcp_server_fetch/server.py` (288 lines, fetched raw
2026-09-08). The design is small enough to summarize completely, and every
decision in it maps to a Learning-Hog doc:

1. **Two user-agent identities, honesty by default.** `DEFAULT_USER_AGENT_AUTONOMOUS = "ModelContextProtocol/1.0 (Autonomous; +https://github.com/modelcontextprotocol/servers)"` vs `DEFAULT_USER_AGENT_MANUAL = "ModelContextProtocol/1.0 (User-Specified; …)"`. The autonomous agent identifies itself truthfully — no UA spoofing (the opposite of doc 04's "dark" gray-zone tier).
2. **robots.txt gate before autonomous fetch.** `check_may_autonomously_fetch_url()` fetches robots.txt with the autonomous UA; if robots.txt *cannot be fetched* (connection issue), or returns an error status, it **fails closed** — the error message says autonomous fetching is "not allowed" and the user may fetch manually via the prompt. `ignore_robots_txt` exists as an explicit opt-out flag (`serve(ignore_robots_txt=...)`), which makes the default opt-in-safe.
3. **Content negotiation is trivially simple.** `fetch_url()` checks `content-type` and sniffs `<html` in the first 100 bytes; if HTML and not `force_raw`, run markdownify → markdown; otherwise return raw text with a prefix note "Content type … cannot be simplified to markdown". No readability heuristics, no JS rendering — static HTTP only.
4. **Pagination instead of truncation-as-loss.** The `fetch` tool exposes `max_length` + `start_index` so the model *pulls* more content in follow-up calls — context-window management as an explicit, resumable API rather than silent truncation.
5. **Chunking is upstream**: the server's README documents optional chunking via `MCP_SERVER_REQUEST_MAX_SIZE` / `progress` notifications — the server stays simple, the protocol carries the size.

**Adopt for Learning-Hog (doc 04/06):** the whole tool is ~300 lines — the
right size budget for our fetch layer. Take: (a) truthful UA identifying the
tool, (b) robots.txt fail-closed gate with explicit override flag, (c)
`max_length`/`start_index` resumable pagination rather than silent truncation,
(d) markdownify for HTML→markdown.

### 2.2 fetcher-mcp — the browser fallback pattern

1,083★, MIT, Playwright-based headless fetch (repo metadata + description,
fetched 2026-09-08). Design role in the ecosystem: when the static-HTTP fetch
of the official server fails (JS-rendered SPA pages), MCP users reach for this
server — same tool interface, heavier execution. **Lesson:** the ecosystem's
answer to JS-rendering is *a second specialized server*, not baking a browser
into the base fetch tool. Learning-Hog doc 06 should keep `fetcher.py` static-HTTP-only in V1 and treat a Playwright fallback as a V2 optional extra (doc 04's anti-bot cost/risk analysis applies to every headless-browser fetch).

### 2.3 smolagents `default_tools.py` — minimal agent fetch tools (source read)

Fetched raw 2026-09-08 (698 lines). Two tools matter here:

- **`WebSearchTool`**: pluggable engine (`duckduckgo` | `bing` | `exa`), DuckDuckGo implementation is a plain `requests.get("https://lite.duckduckgo.com/lite/", params={"q": ...}, headers={"User-Agent": "Mozilla/5.0"})` scrape of the HTML results page, parsed to `[{title, link, description}]`. Raises "No results found! Try a less restrictive/shorter query" on empty. Note: it sends a *browser* UA to DDG's HTML endpoint — minimal scraping, but UA differs from the MCP server's honest-UA stance; treat DDG-HTML scraping as fragile (any markup change breaks it) rather than a dependency for Learning-Hog.
- **`VisitWebpageTool`**: `requests.get(url, timeout=20)` → `raise_for_status()` → `markdownify(...)` → strip whitespace → **hard character truncation** (`max_output_length=40000`, truncation marker appended). No robots.txt check, no content-type negotiation, no pagination.

**Contrast with 2.1 is the key finding:** the two most-copied tool designs in
the ecosystem differ exactly on the guardrails doc 04 mandates. smolagents'
`visit_webpage` would violate Learning-Hog's permission gate (no robots.txt,
no permission resolution) and its context discipline (hard truncation vs
resumable pagination). smolagents compensates with a *separate* validation
stage in its examples (search → visit → extract-learnings), not fetch-time
gates. For Learning-Hog, gates belong in the fetch layer (doc 04's
permission-gate stage) because the CLI has no human watching each call.

### 2.4 Haystack `LinkContentFetcher` — production fetcher ergonomics

Official docs (fetched 2026-09-08): "Fetches and extracts content from URLs.
It supports various content types, retries on failures, and automatic
user-agent rotation for failed web requests." Constructor surface:
`raise_on_failure`, `user_agents`, `retry_attempts=2`, `timeout=3`,
`http2`, `client_kwargs`, `request_headers`; output = one `ByteStream` per URL
with `meta = {'content_type', 'url'}`; per-URL failures are logged and skipped
for multi-URL runs (exception only when a single-URL run fails and
`raise_on_failure=True`). Related: `haystack.utils.request_with_retry` —
"configurable exponential backoff retry".

**Adopt:** the *component contract* — (a) batch fetch with per-URL error
isolation (one dead link must not kill the batch — this is exactly doc 04's
pipeline stage boundary), (b) retry with exponential backoff as a fetcher
constructor parameter, (c) content-type carried in per-item metadata (doc 06's
provenance record should carry `content_type` next to `fetched_at`/`permission`).

### 2.5 Closed harnesses: fetch as hosted tool (behavior/docs level)

- **Claude API web fetch tool** (`web_fetch_20260318`, official docs fetched 2026-09-08): a **server tool** — "the API fetches the content during the request and inserts the results into the conversation. You don't run anything". Parameters: `max_uses`, `allowed_domains` / `blocked_domains` (mutually exclusive), `citations: {enabled}`, `max_content_tokens`; latest version adds **dynamic filtering — "Claude can write and execute code to filter fetched content before it reaches the context window, keeping only relevant information"** (context-window protection as code, not truncation). Known limitation stated in docs: "does not support websites dynamically rendered with JavaScript" — JS pages are routed to the separate browser-use tool. Claude Code's WebFetch additionally (a) requires per-domain permission by default (docs/blogs: "asks for permission every time it fetches content from a domain you haven't already whitelisted") and (b) implements a ~15-minute cache and HTML→markdown conversion (third-party analysis, mikhail.io — corroborated by Anthropic's Boris Cherny noting WebFetch sends `Accept: text/markdown`).
- **OpenAI Agents SDK** (official tools page fetched 2026-09-08): built-in tools **only work with `OpenAIResponsesModel`** — `WebSearchTool` (hosted search), `FileSearchTool`, `CodeInterpreterTool`, `HostedMCPTool`, `ImageGenerationTool`, `ToolSearchTool` (deferred tool loading). No first-party `WebFetchTool` in Python SDK docs — fetching is expected to come from function tools or hosted MCP. **Lesson:** even the largest harnesses ship *search* hosted and leave *fetch* to the developer or MCP — validating Learning-Hog's choice to own its fetch layer (doc 06) while depending on external search APIs (doc 04).
- **Gemini "Grounding with Google Search"** (official docs fetched 2026-09-08): `tools=[{"type": "google_search"}]`; "the model automatically generates one or multiple search queries and executes them", processes results, returns a grounded response with "the model's text ans[wer] plus verifiable citations to sources beyond its knowledge cutoff"; supported across current Gemini Flash/Pro models; usage-based pricing per docs. Grounding is *search-side*: Google runs retrieval inside the API boundary; the developer never handles raw fetch. **Lesson:** this is the exact opposite of Learning-Hog's architecture (own the fetch, log provenance per URL) — because its goal is answers, not an auditable resource list. Useful as the contrast case for doc 05: "grounded answer" ≠ "validated resource with per-URL provenance".

## 3. Deep dives — scraping backends (what agents call instead of DIY)

### 3.1 Firecrawl — the default scraping service of research agents

177,987★ (the most-starred repo in this doc), AGPL-3.0, OSS + hosted API.
README (fetched): endpoints `scrape` (any URL → "markdown, HTML, screenshots,
or structured JSON"), plus crawl/map/search; the whole pitch is "LLM-ready
output: Clean markdown, structured JSON… spend fewer tokens"; Python/JS/Go/Java
clients with `formats=["markdown"]` as the canonical call. dzhng/deep-research
imports `@mendable/firecrawl-js` as its only fetch dependency (source read, §4.2);
GPT Researcher ships it as one pluggable scraper. **Compliance caveat, from the
README of its own client docs:** no robots.txt/permission gate is advertised —
compliance is the caller's problem. **License caution:** AGPL-3.0 — reading and
self-hosting is safe; copying its code into Learning-Hog would force AGPL.
Calling the hosted API is unaffected.

**Adopt:** the *interface* (`scrape(url) → {markdown, metadata}`) is the
de-facto standard shape — doc 06's adapter contract returns the same pair.
For V1, Learning-Hog can even call Firecrawl/Jina as an optional "heavy
fetch" backend behind that interface, keeping the static-HTTP fetch as default
($0 cost, full provenance).

### 3.2 Crawl4AI — the OSS crawl stack agents self-host

81,981★, Apache-2.0. README (fetched): "Reliable, large-scale web extraction"
with async-first design; **`BrowserConfig` / `CrawlerRunConfig` split** —
browser identity (headless, proxies, UA) separate from per-run crawl policy;
**hooks at every step** ("Define hooks at every step to customize crawling
behavior"); content filtering via **`PruningContentFilter` (threshold-based
boilerplate pruning) and `BM25ContentFilter`** ("Employs BM25-based filtering
for extracting core information and removing irrelevant content"); structured
extraction via LLM, cosine-similarity chunk selection, or CSS/XPath schemas;
`MemoryAdaptiveDispatcher` for concurrency; sessions, cookies, JS execution.
No robots.txt gate advertised either.

**Adopt:** (a) the config split (browser identity vs crawl policy) maps to
doc 06's `fetcher.py` (identity: UA, timeout) vs `permissions.py`+`scheduler`
(policy: gates, rate limits); (b) BM25/pruning content filters are the OSS
answer to doc 07's "rank passages within the page before `explain`" — a
$0-cost local alternative to LLM-based chunk selection; (c) hooks-at-every-step
is how to keep the permission gate non-invasive (a pre-fetch hook that can
abort).

### 3.3 Jina Reader — zero-code URL→markdown + search composite

11,965★, Apache-2.0; the OSS branch of the `r.jina.ai` service. README
(fetched): **Read** = prepend `https://r.jina.ai/` to any URL → LLM-friendly
markdown "at no cost" (base tier); **Search** = `https://s.jina.ai/<query>` —
"Behind the scenes, Reader searches the web, fetches the top 5 results, visits
each URL, and applies r.jina.ai to it… you don't have to handle browser
rendering, blocking, or any issues related to JavaScript and CSS yourself."
Output controlled via headers (`x-respond-with: markdown|…`), PDFs parsed with
PDF.js; in-site search via `?site=` params; source of truth for options in
`src/dto/crawler-options.ts`.

**Lesson:** `s.jina.ai` is a **search-then-fetch composite** — the same
composite doc 04's pipeline builds manually (search stage → fetch stage). Its
design confirms the composite is a product category, but as a *closed-service
dependency* it violates Learning-Hog's $0/auditable constraints (no per-URL
permission gate you control). Fine for bootstrapping/experiments; not a
dependency.

### 3.4 Preservation pattern — linkwarden, monolith (what to do with a link you want to keep)

- **linkwarden** (19,710★, AGPL-3.0): self-hosted collaborative bookmark
  manager that "collect[s], read[s], annotate[s], and fully preserve[s]" pages
  — snapshots as first-class features (repo metadata + description).
- **monolith** (15,468★, CC0-1.0): CLI that bundles a page into a single HTML
  file, embedding CSS/images/JS as data URLs so "browsers render the saved page
  exactly the way it was on the Internet, even when no network connection is
  available" (README fetched). Domain allow/block flags (`-d`/`-B`), cookie
  support.

**Why this matters for Learning-Hog:** doc 04's validator catches dead links,
but validated links still rot *after* they reach the user. The ecosystem's
answer is archival. Cheapest V1 slice: document `monolith`/archival as the
recommended companion for `path` output (user runs it), or embed a
"save snapshot" hook in V2. CC0 licensing makes monolith's *approach* freely
copyable (its Rust code could be replaced by a trivial Python archiver later).

### 3.5 lychee — the link validator as a finished product

3,895★, Apache-2.0, Rust. README (fetched): "Finds broken hyperlinks and mail
addresses in websites" and local files (Markdown/HTML); "fast, asynchronous";
feature table: **exclude patterns, retry and backoff, caching**; runs
offline-mode checks; ships as a GitHub Action (`lycheeverse/lychee-action`)
so repos check their own links on CI. This is exactly the product category of
doc 04's validator stage — and the strongest signal that Learning-Hog's
validator should be: async, cached, retry-with-backoff, exclude-list aware,
and runnable as a CI job for `sources/*.yaml` (the registry PR-review gate
from doc 10 §2.4 can lint links mechanically with lychee).

## 4. Deep dives — fact/resource validation (how they verify)

### 4.1 RARR — post-hoc research-and-revise (the validation loop)

anthonywchen/RARR (CMU/Google Research/UC Irvine; arXiv:2210.08726, cited 662+
per search), dormant repo (last push 2023-06-22, no license file — read the
paper, take the *pattern*). README (fetched): "improves the attribution and
factuality of language models by taking their outputs and applying a post-hoc
retrieve-and-edit approach." Pipeline from the README: (1) generate a query
per claim, (2) **"For each query, we search for relevant webpages, then apply
a passage extractor to retrieve the most relevant passage(s) for the query as
evidence"** (Bing in their impl), (3) iteratively **edit the claim against the
evidence** — evidence either supports (keep, with attribution URL) or
contradicts (revise/delete). Original output is preserved as an "editable"
trace.

**Adopt for Learning-Hog (doc 05):** `explain`'s summary should never be
shipped unvalidated: split it into claims → for each claim, the *already-fetched*
resource content is the evidence → drop or mark any claim not supported.
Unlike RARR we need no extra search round-trips — the fetched resource is
local evidence. This is doc 05's citations-only guardrail made mechanical.

### 4.2 FActScore — atomic-fact decomposition (the metric)

shmsw25/FActScore (457★, MIT, EMNLP 2023; abstract fetched from arXiv:2305.14251):
"Evaluating the factuality of long-form text… generations often contain a
mixture of supported and unsupported pieces of information, making binary
judgments of quality inadequate." FActScore "breaks a generation into a series
of atomic facts and computes the percentage of atomic facts supported by a
reliable knowledge source."

**Adopt:** not a runtime dependency (an eval harness), but the right
**offline eval metric** for Learning-Hog's `explain`/`chat` quality: sample
outputs, decompose to atomic facts, check each against the fetched resources,
report % supported. That gives doc 07's trust scorecard an objective,
published metric instead of vibes. (Doc 10/11's research agents optimize
reports; none reports a factuality score — this is differentiating QA.)

### 4.3 Vectara HHEM — hallucination scoring as a free local model

Model `vectara/hallucination_evaluation_model` (Apache-2.0; HF API: 220,919
downloads, 364 likes, fetched 2026-09-08): a cross-encoder that scores
consistency between a summary and its source text. Vectara also maintains
vectara/hallucination-leaderboard (3,313★, Apache-2.0) benchmarking LLMs'
hallucination rates when summarizing. Hugging Face model card is the primary
doc.

**Adopt:** the $0-cost, local, per-summary QA gate for `explain`: run
`summary ↔ fetched resource text` through HHEM; below-threshold summaries get
regenerated or flagged. This complements FActScore (metric for evals) with a
**runtime guard**. Both are free and run on CPU.

### 4.4 Validation architecture across the studied systems

| Stage | Studied systems doing it | Learning-Hog mapping |
| --- | --- | --- |
| URL liveness | lychee (async, cache, retry, CI Action) | doc 04 validator stage; CI job for `sources/*.yaml` |
| Permission gate at fetch | MCP fetch server (robots.txt fail-closed); none of Firecrawl/Crawl4AI/Jina (caller's job) | doc 04 permission gate; doc 06 `permissions.py` — a differentiator, not table stakes |
| Content → clean markdown | MCP server (markdownify), smolagents (markdownify), Firecrawl/Crawl4AI/Jina (services) | doc 06 `fetcher.py` — markdownify is the ecosystem default |
| Claim→evidence check | RARR (search+revise), FActScore (atomic facts), HHEM (NLI-style scorer) | doc 05 guardrail mechanics + offline eval; doc 07 trust metrics |
| Preservation after validation | linkwarden/monolith (snapshots) | optional companion for `path` output (V2 hook) |

## 5. Cross-project patterns (analysis)

| # | Pattern | Seen in | Lesson for Learning-Hog |
| --- | --- | --- | --- |
| Q1 | **Honest UA + robots.txt fail-closed is the OSS-ethics standard** | MCP fetch server (source); Claude Code per-domain permission gate | doc 04/06 gates are aligned with the most-trusted implementation; contrast: smolagents DDG scraping + browser-UA, Firecrawl/Crawl4AI (no gate advertised) |
| Q2 | **Fetch tools fragment by capability** (static HTTP / browser / JS-render) | MCP fetch vs fetcher-mcp vs Anthropic browser-use | Keep `fetcher.py` static-only in V1; browser fallback is a separate V2 adapter |
| Q3 | **Context discipline: resumable pagination > silent truncation** | MCP server (`start_index`), Anthropic dynamic filtering vs smolagents 40k hard cut | doc 06 fetch contract returns `{content, total_length, next_index}` |
| Q4 | **Retry + per-URL error isolation is table stakes** | Haystack (`retry_attempts=2`, log-and-skip), lychee (retry/backoff/cache) | doc 04 pipeline must survive one dead URL |
| Q5 | **Scraping services standardize on `scrape(url) → {markdown, metadata}`** | Firecrawl, Crawl4AI, Jina Reader | doc 06 adapter contract matches the de-facto interface; enables optional backend swap |
| Q6 | **Search+fetch composites exist as products** (s.jina.ai fetches top-5 fully) | Jina Reader; deep-research agents (doc 10) | Our search→fetch→validate pipeline is the manual, auditable version of a proven composite |
| Q7 | **Post-generation validation is real and layered**: retrieve-revise (RARR) → atomic facts (FActScore) → NLI scoring (HHEM) | all three | `explain` gets claim-evidence discipline (runtime) + FActScore-style eval (offline) + optional HHEM gate |
| Q8 | **Even first-party harnesses don't own fetch** (OpenAI SDK: hosted search only; Gemini: grounding inside API) | OpenAI Agents SDK docs, Gemini docs | Learning-Hog owning fetch+provenance is a feature (auditable resource lists), the differentiator vs "grounded answers" |
| Q9 | **Preservation is the missing stage in agent stacks** | only linkwarden/monolith; no studied agent archives | optional `path`→snapshot companion; cheap differentiator |

## 6. Conflicts & unverified items (explicit)

- **MCP servers repo license:** GitHub API says `NOASSERTION`; the LICENSE
  file (fetched verbatim) documents an **in-progress MIT→Apache-2.0
  transition** (new code Apache-2.0, docs CC-BY-4.0, un-relicensed legacy
  contributions remain MIT). Any code reuse must check per-file headers —
  same per-path discipline as doc 11's SurfSense BSL note.
- **RARR has no license file** and is dormant (pushed 2023-06-22): treat as
  paper-pattern reference only; do not copy code (and do not need to).
- **dzhng/deep-research reads Firecrawl results in full:** its SERP step
  consumes search-result page contents directly (`pageContents` in
  `writeLearnings`); no per-URL permission check is visible in
  `src/deep-research.ts` (fetched, 294 lines). Stated as observed absence, not
  an accusation.
- **smolagents DuckDuckGo scraping fragility:** implementation scrapes
  `lite.duckduckgo.com/lite/` HTML with a browser UA — verified in source
  today, but such scraping breaks without notice (and its UA practice
  contradicts Q1). Not recommended as a Learning-Hog dependency.
- **Claude Code WebFetch internals (15-min cache, HTML→markdown, per-domain
  permission):** the cache/markdown details come from a third-party analysis
  (mikhail.io, 2025-10) plus an Anthropic employee post on X re: the
  `Accept: text/markdown` header; Anthropic's own docs pages fetched do not
  spell out the cache TTL. Treat cache-TTL as third-party-reported.
- **Not independently re-verified here:** Firecrawl/Crawl4AI/Jina *runtime*
  anti-bot behavior at scale (their docs don't document it; benchmarking is
  out of scope); exact current star counts beyond the 2026-09-08 snapshot;
  Gemini grounding per-1k-requests pricing figure (docs page fetched does not
  render the table — pricing page not fetched).

*(Failed fetches recorded for transparency: docs.anthropic.com
`.md` mirror path → 7-line stub (resolved via docs.claude.com HTML page);
code.claude.com tools/settings pages → empty bodies (JS-rendered docs site);
Haystack source path guess
`components/fetching/link_content_fetcher.py` → 404 (actual path:
`components/fetchers/link_content.py` per search; docs used instead);
google-research/rarr and JBDBronstein/rarr → do not exist (RARR lives at
anthonywchen/RARR).)*

## 7. Source list

**GitHub API metadata (live, 2026-09-08):**

1. <https://api.github.com/repos/modelcontextprotocol/servers> — 90,165★, NOASSERTION (see #14), pushed 2026-09-03
2. <https://api.github.com/repos/jae-jae/fetcher-mcp> — 1,083★, MIT, pushed 2026-01-14
3. <https://api.github.com/repos/huggingface/smolagents> — 29,237★, Apache-2.0, pushed 2026-08-25
4. <https://api.github.com/repos/openai/openai-agents-python> — 29,273★, MIT, pushed 2026-09-08
5. <https://api.github.com/repos/deepset-ai/haystack> — 26,450★, Apache-2.0, pushed 2026-09-08
6. <https://api.github.com/repos/firecrawl/firecrawl> — 177,987★, AGPL-3.0, pushed 2026-09-08
7. <https://api.github.com/repos/unclecode/crawl4ai> — 81,981★, Apache-2.0, pushed 2026-09-08
8. <https://api.github.com/repos/jina-ai/reader> — 11,965★, Apache-2.0, pushed 2026-05-22
9. <https://api.github.com/repos/lycheeverse/lychee> — 3,895★, Apache-2.0, pushed 2026-09-08
10. <https://api.github.com/repos/linkwarden/linkwarden> — 19,710★, AGPL-3.0, pushed 2026-09-08
11. <https://api.github.com/repos/Y2Z/monolith> — 15,468★, CC0-1.0, pushed 2026-05-25
12. <https://api.github.com/repos/anthonywchen/RARR> — 53★, no license, pushed 2023-06-22
13. <https://api.github.com/repos/shmsw25/FActScore> — 457★, MIT, pushed 2025-04-13
14. <https://raw.githubusercontent.com/modelcontextprotocol/servers/main/LICENSE> — MIT→Apache-2.0 transition text (verbatim, first lines)
15. <https://api.github.com/repos/vectara/hallucination-leaderboard> — 3,313★, Apache-2.0, pushed 2026-05-11

**Source code read (raw fetches from default branch, 2026-09-08):**
16. <https://raw.githubusercontent.com/modelcontextprotocol/servers/main/src/fetch/src/mcp_server_fetch/server.py> — 288 lines; UAs, `check_may_autonomously_fetch_url`, `fetch_url`, `max_length`/`start_index`, `ignore_robots_txt`
17. <https://raw.githubusercontent.com/huggingface/smolagents/main/src/smolagents/default_tools.py> — 698 lines; `WebSearchTool` (DDG/Bing/Exa engines, DDG HTML scrape w/ browser UA), `VisitWebpageTool` (timeout=20, markdownify, 40,000-char truncation)
18. <https://raw.githubusercontent.com/dzhng/deep-research/main/src/deep-research.ts> — 294 lines; Firecrawl-only fetch, concurrency=2 env knob, breadth/depth recursion, learnings feedback
19. <https://raw.githubusercontent.com/assafelovic/gpt-researcher/master/gpt_researcher/scraper/scraper.py> — scraper registry (arxiv, beautiful_soup, browser, firecrawl, pymupdf, tavily_extract, web_base_loader) + `get_scraper()` dispatch
20. <https://raw.githubusercontent.com/assafelovic/gpt-researcher/master/gpt_researcher/config/config.py> — `RETRIEVER` env (default `tavily`), multi-retriever parsing/validation
21. <https://github.com/assafelovic/gpt-researcher/tree/master/gpt_researcher/scraper> — directory listing confirming scraper package layout

**Official docs pages (fetched 2026-09-08; vendor-authored where noted):**
22. <https://docs.claude.com/en/docs/agents-and-tools/tool-use/web-fetch-tool> — web fetch server tool: `web_fetch_20260318`, dynamic filtering, `max_uses`/`allowed_domains`/`blocked_domains`/`citations`/`max_content_tokens`, no-JS-rendering limitation (vendor)
23. <https://openai.github.io/openai-agents-python/tools/> — built-in hosted tools list, `OpenAIResponsesModel` requirement, `ToolSearchTool` deferred loading (vendor)
24. <https://ai.google.dev/gemini-api/docs/google-search> — Grounding with Google Search: `google_search` tool, model-generated queries, grounded citations, supported models (vendor)
25. <https://docs.haystack.deepset.ai/reference/fetchers-api> — `LinkContentFetcher` contract: retries, UA rotation, per-URL error isolation, ByteStream meta (`content_type`, `url`) (vendor)
26. <https://raw.githubusercontent.com/firecrawl/firecrawl/main/README.md> — scrape/crawl/map/search API, markdown formats, clients
27. <https://raw.githubusercontent.com/unclecode/crawl4ai/main/README.md> — BrowserConfig/CrawlerRunConfig, hooks, Pruning/BM25 content filters, dispatchers
28. <https://raw.githubusercontent.com/jina-ai/reader/main/README.md> — r.jina.ai / s.jina.ai semantics, `x-respond-with`, s.jina.ai top-5 full fetch composite
29. <https://raw.githubusercontent.com/lycheeverse/lychee/master/README.md> — async link checking, retry/backoff/cache, GitHub Action
30. <https://raw.githubusercontent.com/Y2Z/monolith/master/README.md> — single-file bundling, data-URL embedding, domain flags
31. <https://raw.githubusercontent.com/anthonywchen/RARR/main/README.md> — post-hoc research+revision pipeline, per-claim queries, passage extraction, evidence-based editing

**Papers/models:**
32. <https://arxiv.org/abs/2210.08726> — RARR: Researching and Revising What Language Models Say, Using Language Models (Gao et al., 2022)
33. <https://arxiv.org/abs/2305.14251> — FActScore: Fine-grained Atomic Evaluation of Factual Precision in Long Form Text Generation (Min et al., EMNLP 2023) — abstract fetched
34. <https://huggingface.co/vectara/hallucination_evaluation_model> (via <https://huggingface.co/api/models/vectara/hallucination_evaluation_model>) — Apache-2.0, 220,919 downloads, 364 likes

**Third-party corroboration (marked, not primary):**
35. <https://mikhail.io/2025/10/claude-code-web-tools/> — Claude Code WebFetch behavior analysis (15-min cache, HTML→markdown, deny-list, same-host redirects)
36. <https://x.com/bcherny/status/1988860326306087102> — Anthropic employee on WebFetch `Accept: text/markdown` header

**Search-discovery aids (used to locate URLs; not claim sources):**
37. web_search: RARR repo resolution (anthonywchen/RARR, arXiv 2210.08726)
38. web_search: OpenAI Agents SDK tools page / Claude Code WebFetch corroboration
39. web_search: Haystack LinkContentFetcher docs resolution
40. web_search: pydantic-ai native tools (noted `fetch` live/cached toggle exists in the ecosystem; not deep-dived)

## 8. Recommended actions for Learning-Hog (from this research)

1. **Budget the fetch layer at ~300 lines** like the MCP fetch server: honest
   UA, robots.txt fail-closed with explicit override, markdownify, and
   `max_length`/`start_index` resumable pagination (replaces silent
   truncation) — doc 06 `fetcher.py`.
2. **Adopt Haystack's batch contract**: per-URL error isolation + retry with
   backoff + `content_type`/`url` metadata per item — doc 04 pipeline stage
   and doc 06 provenance fields.
3. **Keep the doc 04 permission gate — it is the differentiator.** None of
   the popular scraping backends (Firecrawl, Crawl4AI, Jina) advertises a
   robots.txt/permission gate; the only studied implementation that gates is
   the official MCP server. Learning-Hog's per-URL permission resolution
   (docs 01/04) is table-stakes nowhere else in this survey.
4. **Match the ecosystem interface** `scrape(url) → {markdown, metadata}` so
   Firecrawl/Jina/Crawl4AI can plug in later as optional backends behind the
   same contract; static-HTTP remains the $0 default (docs 04/06).
5. **Run lychee (or equivalent) as CI on `sources/*.yaml`** — the registry PR
   gate from doc 10 gets mechanical link checking for free; validator design
   in doc 04 should be async + cached + retry for the runtime path.
6. **Make `explain` validation mechanical (doc 05):** claim-split vs the
   fetched resource (RARR pattern, no extra search needed), optional local
   HHEM gate (free, CPU), FActScore-style atomic-fact scoring as the offline
   eval metric for doc 07's trust scorecard.
7. **Add a preservation note to `path` output** (V2): recommend/offer
   monolith-style snapshotting for validated resources — the one stage no
   studied agent provides (link-rot insurance for curated lists).
8. **License discipline confirmed:** Firecrawl/linkwarden = AGPL (patterns
   only), MCP servers = MIT→Apache transition (check per-file), RARR = no
   license (paper reference only). Everything else here is Apache-2.0/MIT
   (patterns freely adoptable).
