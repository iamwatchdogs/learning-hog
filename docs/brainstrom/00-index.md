# Brainstorm Index — AI Learning-Resource Finder

> Workflow followed: **Research → Analyse/Evaluate → Document**.
> Every claim below is grounded in verified primary sources (see
> `09-research-references.md`). No design decision is based on model memory alone.

## User constraints (locked)

- Audience: **general learners** (any skill/field).
- Scope: **all mediums** — video+articles, MOOCs/courses, interactive/code,
  audio/books, plus reddit, forums, social (X/Instagram/Bluesky), wikis, guides,
  OSS, `awesome-*` lists, pre-existing roadmaps. App must **expand by
  skill/field**.
- V1: **simple Python CLI**. V2: server logic / MCP endpoint + frontend.
- LLM: **OpenAI-API-compatible endpoint** so user can pick free / premium /
  local-first.
- Focus: **core functionality only** (find free resources). No auth, billing,
  social, mobile in V1.## Documents in this session

|File|Question it answers|Research basis|
|---|---|------------------------------------------------------|
|`01-vision-problem.md`|Why does this exist? What is "free"?|UNESCO OER definition; Coursera audit vs cert; freeCodeCamp BSD-3|
|`02-users-use-cases.md`|Who uses CLI V1 and how?|R.A.I.S.E. filter syntax; open.school NL queries; Typer CLI UX|
|`03-resource-taxonomy.md`|What mediums? How to grow by skill?|YouTube Data API quotas; GitHub search limits; Reddit 100 QPM; MIT OCW 2500+ + Learn API|
|`04-discovery-strategies.md`|How to find without hallucinating?|R.A.I.S.E. "never fabricate URLs"; Open.School index+LLM-summarize; YouTube 100/day trap|
|`05-ai-interaction-modes.md`|Chat vs search vs roadmap?|Ollama/LM Studio compat + JSON mode; MCP prompts spec|
|`06-core-architecture-cli.md`|What does V1 CLI look like in code?|Typer docs; Ollama localhost:11434; LM Studio localhost:1234; `OPENAI_BASE_URL` env-switch|
|`07-ranking-quality-trust.md`|How to rank free, fresh, leveled results?|ClassCentral; devroadmaps ratings/filters; OCW CC license|
|`08-mvp-scope-roadmap.md`|What is V1 cut vs V2?|MCP Python SDK Tier-1 (`FastMCP` v1 / `MCPServer` v2, stdio + Streamable HTTP)|
|`09-research-references.md`|Where is every fact from?|Primary URLs only|
|`10-references-existing-solutions.md`|What prior art exists to copy/avoid?|Live GitHub API metadata + fetched product pages (2026-09-08)|
|`11-implementation-references-agentic.md`|How do Perplexica/Vane, Open Notebook, Recall, Perplexity, Studr et al. actually work?|Live GitHub API metadata + repo architecture docs + product pages (2026-09-08)|
|`12-agentic-fetch-validation.md`|How do other agents/MCP servers/harnesses fetch data and validate facts?|Live GitHub API metadata + fetched source code (MCP fetch server, smolagents, dzhng, GPT Researcher) + official harness docs (2026-09-08)|

## Key decisions (preview)

1. Retrieval-first, LLM-second. LLM never invents URLs — validated in `04`.
2. Avoid YouTube `search.list` in V1 (100/day bucket). Use curated IDs +
   `videos.list` (1 unit = 10k/day).
3. Pluggable `sources/<skill>.yaml` registry — how we "grow by skill/field".
4. One backend, three CLI presenters (`find`, `path`, `chat`) — resolves
   "not sure, explore all".
5. `OPENAI_BASE_URL/MODEL/API_KEY` env switch covers free/premium/local with
   zero code change.
6. Reddit/social = occasional personal-use reads in V1; commercial
   monitoring deferred (requires contract at $0.24/1K).

## Key decisions amended by external audit (2026-09-07)

1. **Reddit is NOT a V1 adapter** — Responsible Builder Policy requires
   pre-approval for ALL Data API access, incl. personal/non-commercial (amends
   decisions 6 and docs 03/08).
2. **roadmap.sh = link-out only** — repo license is custom all-rights-reserved
   (`NOASSERTION`); never redistribute node markdowns.
3. **Khan Academy = curated YAML only** — no public API since 2020.
4. **Free-type labels gain a `TIME-LIMITED` dimension** — edX/Coursera audit
   access can expire.
5. **Zero-key V1 adapter set:** curated + github + stackexchange + ocw
   (filtered to free) + hn-algolia; MIT Learn data must be filtered
   (`platform=ocw` or price==0) — it mixes paid xPRO items.
6. **Validator: HEAD→GET fallback + Wayback availability fallback** (HEAD-only
   checks false-negative with 405/403); dead links get archived copies instead
   of being dropped.
7. **Security is now an explicit dimension:** untrusted fetched text treated as
   data (OWASP LLM01 prompt injection); SSRF hardening (scheme allowlist,
   block private IPs, cap redirects) for validator/explain fetches.
8. **Schema validation via `msgspec`** (repo dep), not Pydantic; provider
   capability matrix for strict `json_schema`: OpenAI ✅, Ollama ✅, LM Studio
   ✅, Groq select models ✅, Gemini native ✅ / OpenAI-compat ⚠️,
   OpenRouter per-model ⚠️.
9. **`server/discover` confirmed mandatory** in MCP 2026-07-28 spec — doc
   08's V2 plan stands.

## Prior-art findings (2026-09-08, doc 10)

1. **roadmap.sh repo moved**: GitHub now serves it as
   `nilbuild/developer-roadmap` (`nilbuild` = Kamran Ahmed, verified via
   profile fetch); old `kamranahmedse/...` URL redirects. Cite the new handle
   or the redirect.
2. **`langchain-ai/open_deep_research` is archived** (API `archived: true`,
   pushed 2026-08-10) — use as frozen reference only, never as a dependency.
3. **License map for reference projects:** MIT (OSSU, devroadmaps,
   deep-research agents), Apache-2.0 (GPT Researcher), AGPL-3.0 (Anki,
   Exercism website), CC-BY-4.0 (free-programming-books), CC0 (awesome),
   CC BY-NC-SA (Odin curriculum, Missing Semester), custom all-rights
   (roadmap.sh content), "Zero Public License" (liuchong/awesome-roadmaps —
   restrictive despite the name), none (OpenPath, Exercism main repo).
   Patterns may be copied from MIT/Apache/CC-BY items; NOASSERTION/NC/none
   items are link-out only.
4. **Closest architectural comparable = OpenPath** (search→pick→build,
   in-prompt RAG, source-API-only URLs) — hackathon-scale, no license; design
   reference only.
5. **Implementation patterns worth borrowing:** freeCodeCamp schema-first
   curriculum data (`curriculum/schema/`, per-artifact licensing); roadmap.sh
   node-per-file addressing (`roadmaps/<slug>/content/<node>@<id>.md`); OSSU
   explicit course-inclusion criteria; Odin lint-on-PR curriculum repo;
   Exercism canonical-data.json machine-readable specs.
6. **Deep-research products** (OpenAI, Gemini, Perplexity, Claude) all
   converge on report-as-output; NotebookLM on notebook-as-output. None
   returns a validated, license-labeled resource list as the primary
   artifact — that whitespace is Learning-Hog's position. Study-mode
   (OpenAI) / Guided Learning (Google) confirm demand for effort-preserving
   learning UX.
7. **Hidden-gem miner loop shape:** query generation → search → learnings →
   recurse (breadth/depth) → synthesize — terminate at a validated resource
   list, not a report (deliberate divergence from all studied agents).

## Key findings amended by implementation-reference research (2026-09-08, doc 11)

1. **"Perplexica" is now `ItzCrazyKns/Vane`** (GitHub redirect verified, 36.7k★,
   MIT) — classify → parallel research/widgets → cited answer over bundled
   SearXNG; its answer-with-citations output is the summarization-first
   artifact Learning-Hog positions against.
2. **Open Notebook (`lfnovo/open-notebook`, 38.4k★, MIT)** = FastAPI + Next.js
   - SurrealDB + 5 LangGraph workflows; its *Ask* workflow (plan search →
   hybrid retrieval → rank → synthesize) validates doc 04's pipeline shape; its
   Esperanto layer proves the 18+-provider OpenAI-compatible abstraction at
   scale.
3. **Four-tier agentic-depth ladder recommended (doc 11 R2):** Tier 0 no-LLM
   (unique to Learning-Hog), Tier 1 LLM-as-functions, Tier 2 hidden-gem loop
   with STORM-style perspective-guided queries + a Vane-style
   `speed|balanced|quality` depth knob, Tier 3 multi-agent discourse = deferred.
4. **Task→model routing** (cheap parse/rerank model vs strong synthesis model,
   both OpenAI-compatible) is standard practice at STORM and Open Notebook —
   adopt as `LLM_MODEL_PARSE`/`LLM_MODEL_SYNTH` env vars.
5. **Retention layer convergence (Recall, Studr, Anki):** quiz + spaced
   repetition attach to saved learning material everywhere — Learning-Hog V1
   should export Anki-importable cards from `path` output instead of building
   an SRS.
6. **MCP + REST twin surfaces are now the industry default** (Open Notebook,
   SurfSense, even closed Recall ships API+MCP) — doc 08's V2 MCP plan needs no
   revision. SurfSense's mixed Apache-2.0/BSL-1.1 license and Khoj's AGPL-3.0
   constrain code borrowing (patterns only).
7. **Perplexity's ranking stack** (vendor-relayed via Vespa): progressive
   multi-stage ranking with cross-encoder rerank — validates doc 07's ordered
   gates-before-LLM design; its Search API vs Agent API split validates doc 02's
   `find`-is-a-list / `explain`-is-an-answer split.
8. **Every studied system outputs either a cited report or a corpus-grounded
   answer; none returns a validated, license-labeled resource list** — doc 10's
   whitespace claim re-confirmed on a second, implementation-focused sample.

## Key decisions from data-acquisition & legal research (2026-09-08)

1. **Access ladder (applies to every source):** open protocols first (Bluesky
   Jetstream firehose, per-instance Mastodon APIs, RSS/sitemaps) → official
   APIs second → only then a logged-off, permission-respecting crawl for the
   long tail. **Never authenticate with a real account and then collect** —
   that flips collection into clickwrap-ToS territory (docs 03/04).
2. **Platform matrix deltas:** X is pay-per-use with no free tier (post read
   ≈ $0.005, user read ≈ $0.01); Instagram's Basic Display API is gone since
   2024-12-04; Threads text is research-only via Meta Content Library
   (qualified institutions, CASD review, 500k records/7-day window);
   LinkedIn self-serve caps at ≤100k lifetime users with 24h/48h storage
   limits — also link-out only; Mastodon allows 300 req/5 min per
   IP/account by default. X/Instagram/LinkedIn stay link-out only in V1.
   YouTube metadata is refreshable-not-archival (Developer Policies:
   delete/refresh stored data after 30 days). Pushshift is
   moderators-only — plan around it.
3. **Permission signals are machine-readable now:** robots.txt Content
   Signals (`search`/`ai-input`/`ai-train`), W3C TDMRep, the `noai` meta
   convention, and Cloudflare pay-per-crawl (HTTP 402). A no-robots.txt site
   in 2026 is not a no-robots.txt site in 2006 — ingest resolves signals per
   URL instead of assuming permission.
4. **Implied license (Field v. Google):** publishing publicly with no
   barriers communicates permission for indexing + snippet + attribution —
   exactly what Learning-Hog outputs — but never for republishing or model
   training (Copyright Office Part 3, 2025). New `IMPLIED-LICENSE` free-type
   label (docs 01/04) covers these no-explicit-license items.
5. **Provenance logging is a legal requirement, not hygiene:** EU AI Act
   transparency + EDPB Guidelines 03/2026 expect a documented lawful basis
   (legitimate interest — consent is unworkable for scraped data per CNIL)
   and a per-fetch signal snapshot.
6. **New zero-cost sources:** Common Crawl WET/FineWeb (historical depth),
   GDELT (100+-language news, free), Guardian Open Platform + NewsAPI.org
   free tiers, RSS/Atom + sitemap.xml (sanctioned distribution,
   highest-priority for news/editorial text).
7. **Two-level dedup:** URL-normalized hash for the index + content hash
   (simhash/MinHash) for near-duplicates — cross-platform reposts are
   common and ranking must surface the original (doc 07).
8. **Gray-zone spectrum is documented (doc 01):** defensible (snippet +
   attribution indexing), contestable (ai-train:no-but-discovery-allowed;
   public objections without machine signals; soft paywalls), and
   do-not-touch (bypassing access controls, auth-then-scrape, UA spoofing,
   ignoring machine-readable opt-outs). Text-only scope also sidesteps
   BIPA/biometric exposure entirely (Clearview ≈$51.75M settlement).

## Key findings from agentic fetch & validation research (2026-09-08, doc 12)

1. **The only fetch implementation in the survey that gates is the official
   MCP fetch server** (source read): honest self-identifying UA,
   robots.txt fail-closed (explicit override flag), markdownify, and
   resumable `max_length`/`start_index` pagination instead of silent
   truncation. Popular scraping backends (Firecrawl, Crawl4AI, Jina Reader)
   advertise no permission gate — compliance is the caller's job. Learning-Hog's
   per-URL permission gate (docs 01/04) is a differentiator, confirmed against
   the field.
2. **Ecosystem-standard fetch contract:** `scrape(url) → {markdown,
   metadata}` (Firecrawl/Crawl4AI/Jina all converge on it) + Haystack-style
   batch ergonomics (retry with backoff, per-URL error isolation,
   `content_type`/`url` metadata). Keep static HTTP as the $0 default;
   browser fetch is a separate V2 adapter (fetcher-mcp pattern).
3. **Validation is layered and free:** RARR (post-hoc claim→evidence revision
   — for us, the already-fetched resource is the evidence), FActScore
   (atomic-fact % as the offline eval metric), Vectara HHEM (Apache-2.0 local
   cross-encoder as a runtime `explain` gate). lychee shows the link
   validator as CI (run it on `sources/*.yaml` PRs).
4. **Even first-party harnesses don't own fetch:** OpenAI Agents SDK ships
   hosted *search* only; Gemini grounds inside the API boundary; Claude Code
   gates WebFetch per-domain. Owning fetch + per-URL provenance is what makes
   an auditable resource list (vs a "grounded answer") — the doc 05 contrast
   case.
5. **Preservation is the missing stage** in every studied agent stack;
   linkwarden/monolith (CC0) show the snapshot pattern as the V2 companion
   for `path` output.

## How to read these docs

Read in numeric order. Each doc has: **Verified facts → Analysis → Brainstorm
options → Recommendation for V1**.
