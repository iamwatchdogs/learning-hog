# 11 — Implementation References: How Existing Products & Agents Work

> Research date: 2026-09-08. **Grounding rule:** every claim traces to a fetched
> source in §7 — live GitHub REST API metadata, raw repo docs, or official
> product pages. Vendor-authored pages are marked. Closed-source products
> (Recall, Perplexity, Studr) are studied at **behavior level only** — no source
> code is available, so their "architecture" sections describe observable
> product behavior, not internals.
>
> Doc 10 already covers the curation/curriculum layer (roadmap.sh, OSSU,
> freeCodeCamp, Odin) and the OSS deep-research agents (dzhng/deep-research,
> open_deep_research, GPT Researcher) plus NotebookLM's product behavior.
> This doc covers the **discovery / answering / agentic layer** named in the
> brief (Perplexica, Open Notebook, Recall, Perplexity, Studr, NotebookLM) and
> adjacent self-hostable systems found during verification, without repeating
> doc 10.

## 0. Scope & method

Three layers studied:

- **(A) Self-hostable open-source discovery/answering engines** — Vane
  (formerly Perplexica), Morphic, Khoj.
- **(B) Open-source research workspaces & agentic research systems** — Open
  Notebook, SurfSense, STORM/Co-STORM.
- **(C) Closed products named in the brief** — Recall, Perplexity, Studr,
  NotebookLM (NotebookLM delta only; body in doc 10 §2.5).

Method: GitHub API metadata for every repo (stars/license/activity, fetched
2026-09-08); READMEs + architecture docs fetched raw from the default branch;
product pages fetched for closed products. Claims that could not be traced to a
primary source are quarantined in §6.

## 1. Shortlist table

| Project | Location | Type | Activity (2026-09-08) | License | What it is | Why studied |
| --- | --- | --- | --- | --- | --- | --- |
| **Vane** (formerly **Perplexica**) | <https://github.com/ItzCrazyKns/Vane> | OSS app (TS/Next.js) | 36,678★, 4,072 forks, pushed 2026-09-01 | MIT | Self-hosted AI answering engine over SearXNG | Closest OSS analog of Perplexity; the repo the brief calls "Perplexica" |
| **Open Notebook** | <https://github.com/lfnovo/open-notebook> | OSS app (Python+FastAPI+Next.js) | 38,400★, 4,448 forks, pushed 2026-09-06 | MIT | Self-hosted NotebookLM alternative | The most-starred open NotebookLM implementation; multi-provider + MCP |
| **STORM / Co-STORM** | <https://github.com/stanford-oval/storm> | OSS library (Python) | 31,251★, pushed 2025-09-30 | MIT | LLM knowledge-curation system (Wikipedia-like articles with citations) | Academic reference for agentic question-asking + multi-perspective research |
| **SurfSense** | <https://github.com/MODSetter/SurfSense> | OSS platform (Python+Next.js) | 16,105★, pushed 2026-09-08 | Apache-2.0 **+ BSL-1.1** for `surfsense_backend/app/proprietary/` | NotebookLM-alternative pivoted to "live data connectors for agents" + MCP server | Industry-direction signal (agents + MCP-first); connector business model |
| **Morphic** | <https://github.com/miurla/morphic> | OSS app (TS/Next.js) | pushed 2026-09-08 | Apache-2.0 (README) | AI search engine with generative UI | Pattern source: provider detection, search modes, bundled SearXNG |
| **Khoj** | <https://github.com/khoj-ai/khoj> | OSS app (Python) | 37,201★, pushed 2026-08-02 | **AGPL-3.0** (LICENSE fetched) | Self-hostable "AI second brain"; web + personal docs, agents, automations | License caution + scope-contrast (second brain vs resource finder) |
| **Recall** | <https://www.recall.it/> (was getrecall.ai) | Closed SaaS + browser/mobile apps | Site claims 700,000+ professionals | Proprietary | Personal AI knowledge base: save → summarize → auto-organize → chat → quiz | Behavior reference for knowledge-graph organization + retention layer |
| **Perplexity** | <https://www.perplexity.ai/> | Closed SaaS/API | n/a | Proprietary | Web-scale cited answer engine + Sonar/Search/Agent APIs | Ranking/retrieval architecture via its own engineering statements (Vespa post) |
| **Studr** | <https://studr.app/> | Closed app (iOS/Android/web) | Small scale (self-reported: 720+ students) | Proprietary | Uploads (PDF/YouTube/lecture audio) → summaries, flashcards, quizzes, spaced repetition | Retention/study-artifact layer built *on top of* saved learning material |
| NotebookLM | (Google) | Closed SaaS | n/a | Proprietary | Source-grounded notebook; Discover Sources ≤10 annotated recommendations | Covered in doc 10 §2.5; only deltas noted here |

## 2. Deep dives — open source

### 2.1 Vane (formerly Perplexica)

**Verification note.** The brief's "Perplexica" is now **Vane**: GitHub serves
`ItzCrazyKns/Perplexica` as a redirect to `ItzCrazyKns/Vane` (repo id 784181462,
fetched 2026-09-08). The README brands the project "Vane 🔍 — a privacy-focused
AI answering engine"; repo topics still include `perplexica`, and its
one-click deploy buttons still carry `perplexica` template names — the rename
is recent. Cite `ItzCrazyKns/Vane` and mention the rename.

**Architecture (from its own docs, fetched 2026-09-08).** Next.js app; chat via
`POST /api/chat`, programmatic search via `POST /api/search` (returns `message` -
`sources`, optional streaming); `GET /api/providers` lists configured
providers. Pipeline per `docs/architecture/WORKING.md`:

```text
question → classify (research needed? widget? rewrite into standalone form)
        → run research (SearXNG meta-search; optional uploaded-file semantic search)
          and widgets (weather/stocks/calculations) in parallel
        → answer generation with citations (citations rendered by the UI)
```

Three cost/quality presets: `optimizationMode: speed | balanced | quality`.
Search backend is **SearXNG** (bundled in the Docker image; slim image accepts
`SEARXNG_API_URL`; JSON output format must be enabled in SearXNG settings).
Local LLMs via Ollama/Lemonade with `host.docker.internal` gotchas documented;
cloud providers OpenAI/Claude/Gemini/Groq. Storage: chats/messages persisted
via drizzle migrations (embedded DB), uploaded files embedded for semantic
search. Tavily/Exa support is advertised as "coming soon" — not shipped in the
fetched README. Upcoming per README: custom agents, authentication.

**Worth borrowing.**

1. **Classify-first orchestration**: one cheap LLM call decides whether deep
   research is even needed — the same gate Learning-Hog's `planner.py` needs
   before spending adapter calls (doc 04/05).
2. **The speed/balanced/quality knob** is the user-facing contract for
   agentic depth. Learning-Hog's hidden-gem miner should expose the same kind
   of budget dial instead of a fixed loop depth.
3. **Bundled-SearXNG Docker** as the zero-config path — matches doc 04's
   SearXNG recommendation and removes its main setup objection.
4. **Parallel branch execution** (research ∥ widgets) — a trivially correct
   first use of parallelism that does not require a full agent framework.

**Not to copy.** Vane's output is an **answer with citations** — i.e., the
summarization-first artifact Learning-Hog's README explicitly positions
against. Its citation flow ("We prompt the model to cite the references it
used") is prompt-honest but does not validate links or label free-type — the
gap Learning-Hog's validator (doc 04) fills.

### 2.2 Open Notebook

**Architecture (from `docs/7-DEVELOPMENT/architecture.md`, fetched
2026-09-08).** "Three-tier, async-first architecture":

```text
Next.js frontend (:8502) → FastAPI backend (:5055) → SurrealDB (:8000)
```

- **Five LangGraph workflows** are the whole product spine:
  1. *Source processing* — extract (via its sibling lib **content-core**) →
     chunk → embed (via **Esperanto**) → store `source_embedding` rows → LLM
     topic extraction.
  2. *Chat* — build context from user-selected sources/notes → LLM → stream →
     persist session.
  3. *Ask* — **plan search strategy (LLM generates searches) → execute
     searches (vector + full-text) → score & rank → provide answers (LLM
     synthesizes) → stream**. This is a plan-execute agentic RAG loop in
     miniature — the closest OSS relative of Learning-Hog's `find` pipeline,
     pointed at the user's own corpus instead of the web.
  4. *Transformation* — Jinja2 prompt templates → SourceInsight records
     (summaries, key points, quotes, Q&A).
  5. *Prompt* — generic one-shot LLM task.
- **SurrealDB as single DB**: graph relationships (notebook↔source↔note),
  native vector embeddings, and full-text search in one store — "no separate
  vector DB". Rationale section explicitly considered and rejected
  PostgreSQL+pgvector for maturity reasons.
- **Provider abstraction = Esperanto** (sibling library): 18+ providers
  incl. OpenAI-compatible endpoints ("Supports LM Studio and any
  OpenAI-compatible endpoint"), with per-task default model assignments and
  per-request overrides; `provision_langchain_model(task=..., context_size=...)`
  picks by cost/context. README's own vs-NotebookLM table admits citations are
  "Basic references (will improve)".
- **Distribution**: REST API (`:5055/docs`) + MCP integration documented for
  Claude Desktop/VS Code; optional password protection; Docker-compose default
  with encryption key for stored API keys.

**Worth borrowing.**

1. **Task→model routing**: different models for strategy, answers, and
   transformation with sane defaults — the cost-discipline pattern doc 06
   should adopt beyond the single `LLM_MODEL` (parse/rank with a cheap model,
   synthesize with a strong one; STORM does the same, §2.3).
2. **The Ask workflow shape** (plan → hybrid search → score → synthesize) is
   validated at OSS scale and maps 1:1 onto doc 04's pipeline with the
   SourceRouter substituted for vector search.
3. **Fine-grained context control** (user picks exactly which sources/notes
   enter the prompt) — Learning-Hog `path`/`chat` should expose the same
   explicit selection rather than auto-injecting everything.
4. **MCP exposure of an existing core** confirms doc 08's V2 plan: the same
   operations (search, ingest, ask) are served as REST *and* MCP.

**Not to copy.** Open Notebook's unit of value is the **ingested corpus** (you
bring content; it organizes and answers). Learning-Hog's unit of value is the
**discovered, validated resource list** — ingestion of arbitrary user content
is out of V1 scope (doc 01 non-goals). Also SurrealDB adds an always-on
service — fine for its product, wrong for a no-DB CLI (doc 06).

### 2.3 STORM / Co-STORM (stanford-oval)

**Architecture (README fetched 2026-09-08; 31,251★ MIT, last push 2025-09-30 —
slow but not archived).** Two-stage generation: **pre-writing** (internet
research → collect references → outline) then **writing** (outline + references
→ cited article). Its research engine's key mechanism, quoted from the README:

- **Perspective-Guided Question Asking** — "Given the input topic, STORM
  discovers different perspectives by surveying existing articles from similar
  topics and uses them to control the question-asking process."
- **Simulated Conversation** — a Wikipedia-writer persona interviews a
  topic-expert persona grounded in retrieved sources, generating follow-up
  questions.

Co-STORM adds a **multi-agent discourse protocol** (LLM experts + a moderator
agent + the human) plus a dynamically updated **mind map** to keep a shared
conceptual space. Implementation is modular via dspy; retrieval is pluggable
(`YouRM, BingSearch, VectorRM, SerperRM, BraveRM, SearXNG, DuckDuckGoSearchRM,
TavilySearchRM, GoogleSearch, AzureAISearch`).

**Worth borrowing.**

1. **Perspective-guided query generation is the single best mechanism found
   for the hidden-gem miner's query step** (doc 10 §6.4): instead of one query
   per subtopic, generate queries from explicit personas (beginner /
   practitioner / skeptic / adjacent-field), which naturally surfaces
   differently-ranked, lower-SEO content.
2. **Role-routed models** — README's own comment: "STORM is a LM system so
   different components can be powered by different models to reach a good
   balance between cost and quality" (cheap model for the conversation
   simulator, strong model for article generation). Same lesson as Open
   Notebook.
3. **Stage flags** (`do_research`, `do_generate_outline`, …) let users re-run
   one stage from cached intermediates — Learning-Hog should cache between
   parse → fetch → rank → order so `--web` runs are resumable.
4. **SearXNG + Tavily both in its retriever list** independently corroborates
   doc 04's backend picks.

**Not to copy.** The output artifact (long article) and the heavyweight
multi-agent discourse: neither serves a resource-list product, and Co-STORM's
token cost is far beyond a CLI budget. Simulated conversations are optional
flavor for V2+ research, not V1.

### 2.4 SurfSense

**Verification.** 16,105★, pushed 2026-09-08. License file (fetched): Apache-2.0
for the repo **except** `surfsense_backend/app/proprietary/`, which is
**Business Source License 1.1** — a mixed-license repo, so treat code reuse
with the same per-path discipline doc 10 recommends for freeCodeCamp.

**Architecture & positioning (README fetched 2026-09-08).** Started as "the
open-source NotebookLM alternative" and officially pivoted: their note states
that "reasoning over a static index is becoming something every capable agent
does out of the box" and that what agents lack is **live data access** — so the
product is now: typed REST **connectors** (Reddit, YouTube, Instagram, TikTok,
Google Maps/Search, Indeed, Amazon, Walmart, web crawl), an **MCP server**
exposing every connector as a tool (`surfsense_reddit_scrape`, …), an agent
harness (retries, structured output, credit metering), plus a retained
knowledge base with "hybrid semantic and full-text search with cited,
Perplexity-style answers", scheduled/event-triggered agents producing briefs,
podcasts and reports. Business model: cloud pay-per-item; self-host free with
billing off.

**Worth borrowing.**

1. **MCP-first distribution** is now a proven go-to-market for retrieval
   tooling (also: Open Notebook, and Recall — §3.1). Doc 08's V2 MCP plan is
   not speculative; it is the industry default interface for this class of
   tool.
2. **Connector-as-typed-endpoint** (uniform JSON schema per source) is a
   cleaner framing of doc 03's adapter contract — each adapter returns one
   validated shape, and orchestration never sees source quirks.
3. **Its pivot thesis** is a live warning and an opportunity: static-index RAG
   is commoditizing, but *source diversity + trust labels* are not — which is
   exactly Learning-Hog's free-type/license/validator axis (docs 01/04/07).

**Not to copy.** SurfSense's connectors are **scraper APIs** that explicitly
bypass official-API rate limits ("without the official API's rate limits" for
Reddit/Instagram/TikTok). Learning-Hog's ToS stance (doc 03: Reddit =
approval-gated official API only or nothing; no X/Instagram scraping) forbids
that route. Also BSL directory: never assume whole-repo Apache-2.0.

### 2.5 Morphic (miurla)

Apache-2.0, active (pushed 2026-09-08). Next.js answer engine: "AI-powered
search with grounded, cited answers"; **generative UI** — answers render rich
inline components from a streamed JSON spec; **Quick and Adaptive search
modes**; **dynamic provider detection** (OpenAI, Anthropic, Google, Ollama,
Vercel AI Gateway, generic OpenAI-compatible); multiple search providers
(Tavily, SearXNG, Brave, Exa); Postgres chat history; Supabase auth; **guest
mode**; Docker compose bundles **SearXNG** so "no additional search API key is
needed".

**Worth borrowing.** (1) Guest mode — try-before-config frictionless onboarding
is the CLI equivalent of doc 02's "no login, instant answer". (2) Provider
*detection* (probe which env keys exist, enable accordingly) refines doc 06's
env contract. (3) Bundled SearXNG compose (second independent confirmation
after Vane). (4) Generative UI is a V2-frontend idea (doc 08): render a path as
structured cards, not markdown soup.

**Not to copy.** Same as Vane: output = cited answer, no link validation, no
free-type labeling.

### 2.6 Khoj (brief)

37,201★, **AGPL-3.0** (LICENSE fetched verbatim: "GNU AFFERO GENERAL PUBLIC
LICENSE Version 3"), pushed 2026-08-02. Self-hostable "AI second brain":
answers "from the web or your docs", custom agents, scheduled automations,
deep research, offline LLMs, Obsidian/Emacs clients. One third-party review
(promptquorum.com, 2026-09) reports **Khoj Cloud was sunset** in favor of
self-hosting — single-source, unconfirmed (§6).

**Worth borrowing.** The scope lesson: Khoj tries to be everything (chat,
agents, automation, image gen, multi-client) and its surface area is the
product's own complexity. Learning-Hog's doc 01 non-goals list is the correct
fence. **License lesson:** AGPL means Khoj's *code* is legally safe to read
but copying it into Learning-Hog would force AGPL-3.0 on the project — take
patterns only (same rule doc 10 applies to Anki/Exercism).

## 3. Deep dives — closed products (behavior level)

### 3.1 Recall (recall.it)

Closed-source personal knowledge base. Verified from the official site and
store listings (fetched 2026-09-08):

- **Capture & summarize**: browser extensions (Chrome/Safari/Firefox/Edge) +
  iOS/Android apps; "Summarize any content" — podcasts, YouTube, PDFs,
  articles, social posts; key-point summaries.
- **Auto-organization as a knowledge graph**: "Recall saves your content in a
  knowledge graph and resurfaces these connections as you browse" — automatic
  categorization + interlinking, graph view.
- **Chat with the corpus, optionally + web**: Google Play listing: "AGENTIC AI
  CHAT — Ask questions across your entire knowledge base, search the internet,
  or combine both in one conversation. Choose your AI model." Site framing:
  "Get answers from your trusted sources, not the Internet's best guess."
- **Retention layer**: built-in quizzes and "spaced repetition" ("Recall makes
  it easier with spaced repetition").
- **Interoperability & exit**: Markdown export "anytime"; App Store listing
  advertises "API and MCP access lets you connect your knowledge base to any
  other AI tool"; privacy posture (no AI training on content, EU-hosted
  servers); "Choose your AI model" (ChatGPT/Claude/Gemini/Grok/DeepSeek shown
  on site).
- Scale/UGC figures (700,000+ professionals; 4.7★/464 reviews) are
  self-reported marketing.

**Worth borrowing.**

1. **"Trusted corpus first, internet second"** is Recall's whole pitch — the
   consumer-market validation of Learning-Hog's resources-first thesis.
2. **Quiz + spaced repetition on saved learning material** is the standard
   retention companion in this market (Recall, Studr, Anki). Learning-Hog
   should at minimum **export `path` output as Anki-importable cards**
   (resource→question) so the retention loop exists without building an SRS
   (doc 07 already plans `ratings.json`; this extends it).
3. **Graph-style auto-linking** between saved items ("related") — for V1, the
   cheap version is tag/keyword co-occurrence in the output JSON, not a graph
   DB.
4. **MCP/API as an exit strategy** for a closed product signals where the
   ecosystem is: same direction as SurfSense/Open Notebook (§2.2, §2.4).

**Not to copy.** Summarize-everything default (README's explicit anti-position);
walled garden (no structured export of the resource list itself — only notes);
closed stack.

### 3.2 Perplexity

Closed web-scale answer engine. Two verified primary-adjacent sources:

- **Perplexity's own engineering statements, relayed by Vespa's blog**
  (vendor-authored post, 2025-10-06 — Vespa is Perplexity's search backend):
  their stated criteria for RAG-grade retrieval are **"Completeness, freshness,
  and speed"** (comprehensive, continuously updated, real-time index),
  **"Fine-grained content understanding"** — "treat the individual sections
  and spans of documents as first-class units in their own right" (chunk-level
  relevance selection, not just document-level), and **"Hybrid retrieval and
  ranking"** — lexical + semantic at both retrieval and ranking. Their ranking
  stack: "multiple stages of progressively advanced ranking. Earlier stages
  rely on lexical and embedding-based scorers optimized for speed. As the
  candidate set is gradually winnowed down, we then use more powerful
  cross-encoder reranker models to perform the final sculpting of the result
  set."
- **Productized API surface** (docs.perplexity.ai + api-platform page, fetched
  via search 2026-09-08): **Sonar API** = "web-grounded chat completions …
  through an OpenAI-compatible interface"; **Search API** = "real-time, ranked
  web results as structured data" with "domain filtering, multi-query search,
  and content extraction" — explicitly separate from the Agent API ("For an
  LLM-generated answer with citations, use the Agent API"); model ladder
  (sonar, sonar-pro, sonar-reasoning, sonar-deep-research). Deep-research
  product behavior already captured in doc 10 §2.5.

**Worth borrowing.**

1. **Progressive/multi-stage ranking**: cheap filters first (free-type gate,
   URL validation, language, level — doc 07's hard gates), metadata scoring
   next, LLM rerank last and only on survivors. Doc 07's score formula is
   already ordered this way; keep the LLM out of early stages for cost.
2. **Chunk/span-level selection** matters when Learning-Hog summarizes a
   fetched resource (`explain`): rank passages within the page, don't feed the
   whole page.
3. **Search/answer separation as API design**: Perplexity ships *ranked
   results* and *cited answers* as different products. That is exactly doc 02's
   `find` (list) vs `explain`/`chat` (answers) split — `find --json` should
   stay answer-free and machine-consumable.
4. **Domain filtering as a first-class parameter** corroborates R.A.I.S.E.
   `source:`/`type:` filter syntax (doc 02) — a mainstream engine treats it as
   core API surface, not a power-user flag.

**Not copyable.** The moat is the proprietary continuously-updated index +
inference fleet; irrelevant to a $0-cost CLI that must rely on source APIs and
meta-search (doc 04).

### 3.3 Studr

Closed-source study app (studr.app; iOS/Android/web; Devpost hackathon origin
Oct 2025 — self-reported). Official site (fetched 2026-09-08): "Turn any PDF,
lecture, or video into a study set that sticks". Pipeline: upload (PDF /
YouTube / lecture audio / slides / text) → **transcription with timestamps** →
instant **summary** + auto-generated **flashcards** + **practice quizzes**,
scheduled with **spaced repetition**; **chat grounded in your uploads only** —
"It answers using your own uploaded material … not the open internet."
Pedagogy framing on site: "built around the three study techniques cognitive
scientists rank highest" — active recall → flashcards; practice testing →
quizzes; spaced repetition → smart reviews. Scale figures (720+ students,
5,400+ flashcards) are self-reported.

**Worth borrowing.**

1. **Study artifacts generated *from* discovered resources** is the natural
   V2 extension of Learning-Hog `path`: each module can emit flashcard/quiz
   suggestions alongside resources. V1 stays resources-first (doc 01), but the
   Anki-export recommendation in §3.1 covers the cheapest slice of this.
2. **"Grounded in your material, not the open internet"** as a hard chat rule
   matches doc 05's citations-only guardrail — consumer products now advertise
   this as a feature, not just an engineering constraint.
3. Its landing page literally positions against summaries-as-endpoint ("Most
   apps stop at a summary") — further evidence the anti-summary positioning
   has market demand, provided the tool still adds retention value.

**Not to copy.** Ingest-first UX (Learning-Hog discovers rather than ingests),
mobile-first scope, closed stack.

### 3.4 NotebookLM (delta to doc 10)

Doc 10 §2.5 covers grounding, Discover Sources (≤10 annotated recommendations,
one-click import), Audio Overviews, and the "reflection of the sources you've
uploaded" disclaimer. Deltas relevant to this doc's comparison set: NotebookLM
remains **walled** (sources in, artifacts out; no structured resource-list
export, no API/MCP), which contrasts with Recall (Markdown export + API/MCP)
and Open Notebook (REST + MCP). Discover Sources' cap of ~10 curated
recommendations *with relevance annotations* is the UX bar for Learning-Hog
`find`'s top-N presentation (each row already plans a `why` — doc 07).

## 4. Cross-project patterns (analysis)

| # | Pattern | Seen in | Evidence strength | Lesson for Learning-Hog |
| --- | --- | --- | --- | --- |
| P1 | **Classify/plan first, retrieve second** | Vane (classify → research), Open Notebook (Ask: plan strategy), STORM (outline before article) | Primary docs, 3/3 | Keep `planner.py` cheap and always-on; gate deep research behind it (docs 04/05) |
| P2 | **User-facing depth/budget knob** | Vane `optimizationMode` speed/balanced/quality; STORM stage flags; Morphic Quick/Adaptive | Primary docs, 3/3 | Hidden-gem miner needs `--depth/--budget`, and cached stage resumption |
| P3 | **Task→model routing** (cheap roles vs strong roles) | STORM (explicit comment), Open Notebook (`provision_langchain_model(task=...)`) | Primary docs, 2/3 | Extend doc 06: `LLM_MODEL_PARSE` (cheap) vs `LLM_MODEL_SYNTH` (strong), both OpenAI-compatible |
| P4 | **Provider abstraction over OpenAI-compatible + native adapters** | Open Notebook/Esperanto (18+ providers incl. any OpenAI-compatible), Morphic dynamic detection, STORM/litellm | Primary docs, 3/3 | Doc 06's env-switch approach validated; add key-presence detection (Morphic) |
| P5 | **Bundled SearXNG as zero-config search** | Vane (Docker includes it), Morphic (compose includes it); STORM lists SearXNG retriever | Primary docs, 3/3 | Doc 04's SearXNG path is the consensus self-hosted meta-search; ship a compose file in V1.5 |
| P6 | **MCP + REST as twin distribution surfaces** | Open Notebook, SurfSense (MCP server for every connector), Recall (API + MCP), Khoj agents | Primary docs, 4/4 | Doc 08 V2 MCP plan is the industry default; keep core functions pure (doc 06) |
| P7 | **Retention layer (quiz + spaced repetition) attaches to saved resources** | Recall, Studr, (Anki FSRS from doc 10) | Product pages, 3/3 | Cheapest viable slice: Anki-exportable cards from `path` output; SRS app = V2+ |
| P8 | **Auto-organization / linking of saved items** | Recall (knowledge graph + resurfacing), Co-STORM (mind map), Open Notebook (topics + transformations) | Product pages/docs | V1: tags + co-occurrence in JSON; graph DB is a V2 decision, not a dependency now |
| P9 | **Progressive ranking: cheap scorers → cross-encoder/LLM rerank** | Perplexity (own statements via Vespa), Open Notebook Ask (score→rank before synth) | 2 sources (1 vendor-relayed) | Doc 07 formula already ordered correctly; enforce "LLM reranks survivors only" |
| P10 | **Answer engines converge on cited-report; none returns validated resource lists** | Vane, Morphic, Perplexity, deep-research products (doc 10), Open Notebook (corpus answers) | All studied | Confirms the whitespace doc 10 §3 claims; `find` remains the differentiating artifact |
| P11 | **Self-host OSS ⇄ hosted closed pairs** | Vane⇄Perplexity, Open Notebook⇄NotebookLM, (SurfSense cloud⇄self-host) | All studied | Learning-Hog occupies an empty cell: *local-first terminal* discovery tool — no studied project is CLI-first |
| P12 | **Live-connector pivot / scraping bypass** | SurfSense (connectors "without the official API's rate limits") | Vendor docs | Reject for ToS reasons (doc 03); monitor as market signal for V2 connector demand |

**Consensus pipeline across every studied system** (OSS code + closed-product
behavior):

```text
understand/plan the request → retrieve from pluggable sources →
dedupe/score progressively → (optional) agentic recursion for coverage →
synthesize/structure with citations → persist + organize for reuse
```

Learning-Hog's doc 04 pipeline is structurally identical through the synthesize
step; its deliberate divergences are (a) terminating at a **validated
resource list with free-type/license labels** instead of a report (P10), and
(b) **URL validation + Wayback fallback**, which no studied project performs.

## 5. What Learning-Hog should learn (recommendations)

**R1 — Keep `find` answer-free and machine-first (P10, Perplexity split).**
`learning-hog find --json` = ranked structured list (no prose answer);
`explain`/`chat` = the only answer surfaces. This is also the cleanest MCP-tool
boundary for V2 (`find_resources` vs `summarize_resource`, doc 08).

**R2 — Adopt the agentic-depth ladder, not a fixed agent.** The studied
systems justify four tiers; Learning-Hog should implement them as increasing
defaults of one pipeline, not separate products:

- **Tier 0 — no-LLM** (README promise): curated YAML + source APIs + validator
  - doc 07 scoring. No studied project offers this; it is both a differentiator
  and the offline baseline.
- **Tier 1 — LLM-as-functions** (doc 05): parse filters (grammar-restricted),
  rerank survivors, per-resource `why` annotations (NotebookLM's annotated
  recommendations, doc 10).
- **Tier 2 — light loop** (hidden-gem miner): STORM-style
  **perspective-guided query generation** (personas: beginner / practitioner /
  skeptic) + dzhng-style breadth/depth recursion (doc 10 §2.5/§6.4), Vane-style
  **`--depth speed|balanced|quality` knob**, stage caching so runs resume.
  Terminate at a validated list — never a report.
- **Tier 3 — multi-agent discourse** (Co-STORM, supervisor/researcher agents):
  **defer**; no studied product demonstrates it is necessary for resource
  discovery, and cost/latency is CLI-hostile.

**R3 — Route models per task (P3).** Add `LLM_MODEL_PARSE` (cheap: filter
parsing, tagging, rerank assists) and `LLM_MODEL_SYNTH` (strong: roadmap
ordering, `explain`), both over the same `OPENAI_BASE_URL`. Precedent: STORM
and Open Notebook. Pure config change, no code risk.

**R4 — Preserve the answer/`find` separation inside `path` ordering.** Roadmap
ordering (doc 05 `path`) should consume only adapter-validated rows and output
the msgspec-validated schema (doc 05/06) — the Open Notebook "Ask" workflow
proves plan→search→rank→synthesize survives OSS scale, but its *corpus* input
is the difference: Learning-Hog synthesizes over **web-of-source-APIs** results,
so the validator (doc 04) runs *before* any synthesis, unlike every product
studied.

**R5 — Retention: export, don't build (P7).** Ship `learning-hog path ...
--anki` (or a `--flashcards` field in path JSON) generating Anki-importable
cards from module resources. Borrows the Recall/Studr/Anki convergence at
near-zero maintenance cost; a built-in SRS stays V2+.

**R6 — Distribution: keep the MCP door open exactly as planned (P6).** Doc 08's
V2 (FastMCP tools over pure functions) matches what Open Notebook, SurfSense,
and even closed Recall now ship. No re-architecture needed — just keep doc 06's
side-effect-free core.

**R7 — Licenses constrain borrowing.** Pattern-copy freely from MIT/Apache
(Vane, Open Notebook, STORM, Morphic, SurfSense's non-proprietary parts);
**never** import Khoj code (AGPL-3.0) or SurfSense's `proprietary/` tree
(BSL-1.1); closed products are behavior references only.

**R8 — Source diversity is the durable moat, not the agent loop (P12).**
SurfSense's pivot shows agents commoditize static-index RAG; what it bought
connectors for (diverse live sources) Learning-Hog gets from source APIs +
curated YAML (doc 03) with trust labels — a position scrapers cannot fake
because validation + licensing metadata are the product. The moat extends
to *how* sources are acquired: the access ladder (open protocols → APIs →
logged-off permission-respecting crawl) and the per-URL permission gate
(doc 04) mean Learning-Hog's corpus carries provenance and lawful-basis
metadata that connector-scraped competitors lack — the EDPB's 2026
web-scraping guidelines make that documentation a requirement for any
AI-adjacent ingestion at scale.

## 6. Conflicts & unverified items (explicit)

- **Perplexica→Vane rename**: verified via GitHub redirect + README branding;
  but deploy templates/topics still say "perplexica", so older third-party
  docs disagree on the name. Cite `ItzCrazyKns/Vane` with a rename note.
- **Vane Tavily/Exa support** is "coming soon" in the fetched README — not a
  shipped capability; do not cite it as present.
- **Open Notebook provider count drift**: README says "18+ providers",
  architecture doc says 17 — treated as ≥17 + generic OpenAI-compatible.
- **Khoj Cloud sunset**: single third-party review (promptquorum.com);
  unconfirmed by primary source. Do not cite as fact.
- **Studr provenance**: Devpost (Oct 2025) indicates a hackathon origin; the
  commercial app's relationship to that project is not documented anywhere
  authoritative.
- **Self-reported scale numbers** (Recall 700k+ users; Studr 720+ students /
  5,400+ flashcards; Morphic/STORM star counts beyond the 2026-09-08 snapshot)
  are marketing figures — existence-level evidence only.
- **Perplexity internals** come from a Vespa-authored post quoting Perplexity
  (vendor-relayed) plus product/API docs; treat architecture details as
  directional, not audited.
- **STORM activity**: last push 2025-09-30 (~11 months before research date) —
  slow-moving but not archived; fine as a pattern reference, do not pin as a
  dependency.
- Not independently verified: Recall's quiz/SRS scheduling algorithm details;
  Open Notebook's SurrealDB vector-search performance claims (their own
  rationale, unbenchmarked); exact Morphic star count (API response truncated).

## 7. Source list (fetched 2026-09-08 unless noted)

**GitHub API metadata (live):**

1. <https://api.github.com/repos/ItzCrazyKns/Perplexica> → redirects to
   <https://api.github.com/repositories/784181462> = `ItzCrazyKns/Vane` —
   36,678★, 4,072 forks, MIT, TypeScript, pushed 2026-09-01, topics incl.
   `perplexica`, `searxng`
2. <https://api.github.com/repos/lfnovo/open-notebook> — 38,400★, MIT,
   homepage open-notebook.ai, pushed 2026-09-06
3. <https://api.github.com/repos/stanford-oval/storm> — 31,251★, MIT, pushed
   2025-09-30, topics incl. `agentic-rag`
4. <https://api.github.com/repos/MODSetter/SurfSense> — 16,105★, NOASSERTION
   (mixed, see #9), pushed 2026-09-08
5. <https://api.github.com/repos/miurla/morphic> — pushed 2026-09-08
   (Apache-2.0 per README #14)
6. <https://api.github.com/repos/khoj-ai/khoj> — 37,201★, AGPL-3.0, pushed
   2026-08-02

**Repo docs (raw fetches):**
7. <https://raw.githubusercontent.com/ItzCrazyKns/Vane/master/README.md> —
   features, Docker+SearXNG bundling, providers, "coming soon" list
8. <https://raw.githubusercontent.com/ItzCrazyKns/Vane/master/docs/architecture/README.md>
   <https://raw.githubusercontent.com/ItzCrazyKns/Vane/master/docs/architecture/WORKING.md>
      — classify → parallel research/widgets → cited answer; `optimizationMode`;
      `/api/search` returns `message`+`sources`
9. <https://raw.githubusercontent.com/MODSetter/SurfSense/main/LICENSE> —
   Apache-2.0 except `surfsense_backend/app/proprietary/` = BSL-1.1
10. <https://raw.githubusercontent.com/MODSetter/SurfSense/main/README.md> —
    connectors, MCP server, pivot note ("reasoning over a static index … out of
    the box"), self-host free / cloud pay-per-item
11. <https://raw.githubusercontent.com/lfnovo/open-notebook/main/README.md> —
    vs-NotebookLM table (citations "Basic references (will improve)"),
    Esperanto matrix, MCP integration
12. <https://raw.githubusercontent.com/lfnovo/open-notebook/main/docs/7-DEVELOPMENT/index.md>
    - <https://raw.githubusercontent.com/lfnovo/open-notebook/main/docs/7-DEVELOPMENT/architecture.md>
    — three-tier design, SurrealDB tables/vectors, five LangGraph workflows,
    Ask pipeline, `provision_langchain_model`, design patterns
13. <https://raw.githubusercontent.com/stanford-oval/storm/main/README.md> —
    two-stage pipeline, perspective-guided question asking, simulated
    conversation, Co-STORM roles + mind map, role-routed LM configs, retriever
    list incl. SearXNG/Tavily
14. <https://raw.githubusercontent.com/miurla/morphic/main/README.md> —
    generative UI, Quick/Adaptive modes, provider detection, bundled SearXNG,
    Apache-2.0
15. <https://raw.githubusercontent.com/khoj-ai/khoj/master/LICENSE> — AGPL-3.0
    verbatim

**Product pages / listings:**
16. <https://www.getrecall.ai/> (served as recall.it) — knowledge graph,
    "trusted sources, not the Internet's best guess", spaced repetition,
    Markdown export, model choice, 700k+ claim
17. <https://play.google.com/store/apps/details?id=com.recall.wiki> —
    "AGENTIC AI CHAT … knowledge base, search the internet, or combine both"
18. Apple App Store listing for Recall ("API and MCP access") — retrieved via
    search snapshot 2026-09-08
19. <https://blog.vespa.ai/perplexity-show-what-great-rag-takes/> —
    **vendor-authored**; quotes Perplexity's retrieval criteria (completeness/
    freshness/speed; chunk-level "sections and spans as first-class units";
    hybrid retrieval; multi-stage ranking → cross-encoder rerank)
20. <https://docs.perplexity.ai/docs/sonar/quickstart> — "OpenAI-compatible
    interface" (via search snapshot)
21. <https://www.perplexity.ai/api-platform> + <https://docs.perplexity.ai/docs/search/quickstart>
    — Search API ("ranked results, domain filtering, multi-query") vs Agent API
    separation (via search snapshots)
22. <https://studr.app/> — upload→transcript→summary/flashcards/quiz/SRS;
    grounded chat ("your own uploaded material … not the open internet");
    three-technique framing; self-reported scale
23. <https://devpost.com/software/studr-ai-notetaker> — hackathon origin
    (2025-10)
24. <https://www.promptquorum.com/power-local-llm/khoj-ai-second-brain-review>
    — single-source claim: Khoj Cloud sunset (unverified, §6)

**Search-discovery aids (not claim sources):** web_search for Recall listings,
Studr identification, Morphic repo relocation (`morphic-sh`→`miurla`), Khoj
license cross-check, Perplexity docs URLs.

*(Failed fetches recorded: Vane `WORKING.md` at repo root → 404, correct path
is `docs/architecture/WORKING.md`; `docs.perplexity.ai/api-reference/chat-completions`
→ 404, replaced by sonar quickstart + api-platform pages.)*
