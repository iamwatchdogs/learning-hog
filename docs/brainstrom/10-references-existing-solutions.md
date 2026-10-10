# 10 — References: Existing Solutions & Implementation References

> Research date: 2026-09-08. **Grounding rule:** every claim below traces to a
> fetched source URL listed in §5. Repo metadata (stars, license, activity) was
> pulled live from the GitHub REST API on 2026-09-08; figures drift daily, so
> re-verify before citing externally. This doc covers three research layers:
> **(A)** aligned open-source discovery/aggregation projects, **(B)**
> programming-education projects as implementation references, **(C)** the
> products named in the README (deep research, NotebookLM) plus similar
> product behaviors, for behavior contrast.

## 0. Scope recap (from README.md)

Learning-Hog: gather free learning resources across **all mediums**, run
"high precision highly relevant topic specific research" to surface
"hidden gems" buried by bad SEO, and return resources **plus a roadmap** —
putting **actual resources ahead of summarization** ("unlike deep research &
NotebookLM that summarize everything and makes you lazy"). Requires an
OpenAI-API-compatible LLM endpoint for premium features (deep research, hidden
gem miner, personalized roadmap); standard search must work without one.
Currently a vibe-coded WIP.

## 1. Shortlist table

| Project | Repo URL | Activity | License | Core intent | Relevance to this project | Key differentiator |
| --- | --- | --- | --- | --- | --- | --- |
| roadmap.sh (developer-roadmap) | <https://github.com/nilbuild/developer-roadmap> | Pushed 2026-09-07 (daily) | **NOASSERTION** — custom all-rights-reserved (`license` file) | Community-curated interactive dev roadmaps | Roadmap structure/ordering is the direct model for `learning-hog path` | Node-per-file markdown + renderer; content NOT redistributable |
| OSSU computer-science | <https://github.com/ossu/computer-science> | Pushed 2026-07-14 | MIT | Complete free self-taught CS degree path | Proves curated free-first curricula with level sequencing scale via community | Degree-requirements-driven curriculum of third-party free courses |
| free-programming-books | <https://github.com/EbookFoundation/free-programming-books> | Pushed 2026-09-06 | CC-BY-4.0 | Curated free programming books/lists | Largest precedent for human-curated free-resource registries (our `sources/*.yaml` analog) | Multi-language list structure; CC-licensed so content is reusable |
| awesome (sindresorhus) | <https://github.com/sindresorhus/awesome> | Pushed 2026-09-02 | CC0-1.0 | Meta-index of awesome lists | Source of `awesome-*` discovery via GitHub search; list norms (badges, contributing rules) | Ecosystem standard for curation-as-repo |
| Anki | <https://github.com/ankitects/anki> | Pushed 2026-09-07 | **AGPL-3.0** (plus BSD-3 portions; mixed) | Spaced-repetition flashcards | Retention layer for a future `learning-hog` memory feature; desktop Rust + sync server | FSRS scheduler; content-agnostic, local-first |
| The Odin Project (curriculum) | <https://github.com/TheOdinProject/curriculum> | Pushed 2026-09-07 | **CC BY-NC-SA 4.0** (`license.md`) | Free full-stack web-dev curriculum | "Curriculum as repo" implementation reference (dir-per-course, lesson markdown) | Project-driven pedagogy; curriculum versioned in git |
| Exercism | <https://github.com/exercism/exercism> | Repo pushed 2024-03-01 (archived-era docs); live org repos active 2026 | No license on main repo; website **AGPL-3.0**; problem-specifications **MIT** | Crowd-sourced code practice + mentorship | `problem-specifications` = canonical machine-readable exercise-data pattern | Language-track monorepo; spec/tests decoupled from 60+ language tracks |
| Kolibri | <https://github.com/learningequality/kolibri> | Pushed 2026-09-03 | MIT | Offline-first learning platform | Niche-but-authoritative reference for offline/low-bandwidth resource distribution | Studio→Kolibri channel packaging; Python/Django |
| OpenPath | <https://github.com/DeepikaSidda/OpenPath> | Pushed 2026-04-15 | **No license** | Search→pick→build free courses from internet resources | Closest architectural comparable (YouTube API + Tavily + LLM structuring) | In-prompt RAG over resource summaries; documented hallucinated-links lesson |
| devroadmaps (fork) | <https://github.com/cxqeric/devroadmaps> | Pushed 2026-05-11 | MIT | JSON-ized roadmaps with ratings/filters | Proof that roadmap *structure* can be open-licensed data (17 paths, 1700+ resources) | Community 1–5★ ratings + type/difficulty filters without accounts |
| open_deep_research | <https://github.com/langchain-ai/open_deep_research> | Pushed 2026-08-10; **repo archived** | MIT | Open-source deep-research agent (LangGraph) | Reference for the "deep research" pipeline the README positions against | Supervisor/researcher/compression architecture; multi-provider via `init_chat_model()` |
| deep-research (dzhng) | <https://github.com/dzhng/deep-research> | Pushed 2026-04-11 | MIT | Minimal (<500 LoC) iterative deep-research agent | Simplest reference for breadth/depth recursive search loops | SERP-query generation + learnings/directions recursion |
| GPT Researcher | <https://github.com/assafelovic/gpt-researcher> | Pushed 2026-08-27 | Apache-2.0 | Plan-and-execute research agent with citations | Planner/execution-agent split + citation-first report generation | Parallelized agent work; Python package + docs site |

Diversity note: shortlist includes large mature projects (roadmap.sh ~366k★,
freeCodeCamp ~455k★, free-programming-books ~396k★, awesome ~504k★) and
smaller/niche ones (devroadmaps fork 0★, OpenPath 0★, Kolibri ~1.1k★) — both
ends genuinely align with Learning-Hog's intent.

## 2. Per-project deep dives (top 5)

### 2.1 roadmap.sh (developer-roadmap)

**Architecture overview.** Open-core Astro + Tailwind site deployed to GitHub
Pages; repo contains a `roadmaps/` directory where each roadmap is a directory
with a `content/` folder of **one markdown file per node**, filenames encoded
as `<node-slug>@<node-id>.md` (verified live on 2026-09-08 via GitHub contents
API for `roadmaps/python/content/`, e.g. `aiohttp@IBVAvFtN4mnIPbIuyUvEb.md`,
`basic-syntax@6xRncUs3_vxVbDur567QA.md`). Community proposes changes via
issues; a review process approves them. The site is the 7th most-starred open
source project on GitHub per its own about page. [Source: roadmap.sh/about;
GitHub contents API URL in §5]

**Design decisions worth borrowing.**

1. **Node-per-file content model** — every roadmap node is an addressable
   markdown unit with a stable ID. This is exactly the granularity
   Learning-Hog's `path` output needs (module → resources), and it makes
   diffs/reviews per node possible.
2. **Roadmaps as data + renderer** — the repo ships structure and content
   separately from the rendering site; third parties (devroadmaps fork) proved
   the structure can be re-serialized as JSON with type/difficulty filters.
3. **Community review funnel** — changes flow through issues + review, which
   keeps 365k★-scale curation coherent.

**Known limitations.**

- **License blocks reuse of content**: the repo `license` file states text and
  images are copyright-protected, personal use allowed, redistribution of
  content not allowed, links shareable ([source: raw `license` file, fetched
  2026-09-08]). GitHub API reports `NOASSERTION`.
- Node markdown files are **not** independently fetched-verified resources —
  each node links out to external resources, which can rot (no validator).
- Repo owner handle changed: GitHub now serves
  `nilbuild/developer-roadmap` (`nilbuild` = Kamran Ahmed, verified via
  profile fetch); the old `kamranahmedse/...` URL redirects. Docs 03/09 still
  cite the old handle — update at build time or use the redirect.

**What this project should NOT copy.** The all-rights-reserved content stance
is the opposite of Learning-Hog's free-first ethos; never redistribute node
markdowns (link out only, as doc 03 already mandates). Also do not copy the
"one mega-repo holds site + all content" coupling — Learning-Hog's
`sources/<skill>.yaml` registry stays cleaner as pure data.

### 2.2 OSSU computer-science

**Architecture overview.** A single MIT-licensed README-as-curriculum:
"complete education in computer science using online materials," designed
"according to the degree requirements of undergraduate computer science
majors," with explicit course-selection criteria (open enrollment, runs
regularly/self-paced, matches degree standards, etc.) — fetched from the repo
README on 2026-09-08. Community runs on Discord; the repo is effectively a
versioned, reviewable syllabus pointing at third-party free courses.

**Design decisions worth borrowing.**

1. **Explicit inclusion criteria for resources** — OSSU states the rules a
   course must meet before it enters the curriculum. Learning-Hog should
   encode equivalent gates (free-type, license, level, freshness) per
   source/adapter rather than per-run LLM vibes.
2. **Sequencing by prerequisite order** — curriculum sections are ordered
   (intro → core → advanced), which is the static skeleton `path` should
   reuse before LLM ordering.
3. **Community as the QA loop** — issue threads report dead links/better
   alternatives; a CLI can expose the same feedback affordance cheaply.

**Known limitations.** Coverage is CS-only (single-field); updates depend on
volunteer review cadence (pushed 2026-07-14 — active but slower than the
mega-lists); no API or machine-readable curriculum file — the "data" is the
README itself.

**What this project should NOT copy.** Hard-coding one field's curriculum in
prose. Learning-Hog's core differentiator is "expand by skill/field" via
registry files; a README-only curriculum is the anti-pattern to avoid.

### 2.3 freeCodeCamp

**Architecture overview.** Monorepo (BSD-3-Clause code; curriculum content
CC BY-SA 4.0 — dual license recorded per artifact, consistent with doc 03's
per-item license rule). The `curriculum/` directory contains
`curriculum.json`, `blocks/`, `superblocks/`, `challenges/`, `dictionaries/`,
`licenses/`, `schema/`, `structure/` (verified via GitHub contents API). The
curriculum is **structured data with a schema**, not prose: superblocks →
blocks → challenges, with i18n via `i18n-curriculum`.

**Design decisions worth borrowing.**

1. **Schema-first curriculum data** — a JSON schema for learning content
   (`curriculum/schema/`) plus generated site. Learning-Hog's roadmap/path
   output should have an explicit `msgspec`-validated schema so `--json`
   output is contract-stable.
2. **Per-artifact licensing discipline** — code BSD-3, content CC BY-SA,
   licenses directory in-repo. Directly mirrors Learning-Hog's per-item
   `license`/`attribution` fields.
3. **Structure/content separation** — `structure/` vs `challenges/` keeps
   ordering independent from content, the same split Learning-Hog needs
   between roadmap skeletons and resource items.

**Known limitations.** Curriculum is proprietary-shaped to its own platform
(challenge format tied to its web app); heavy monorepo tooling (turborepo,
vitest) is overkill for a CLI; contribution requires learning its
challenge-authoring workflow.

**What this project should NOT copy.** The platform-coupled challenge format
and the monorepo scale. Learning-Hog is an aggregator/roadmapper, not a
content host — it should never need its own exercise runtime.

### 2.4 The Odin Project (curriculum repo)

**Architecture overview.** "The open curriculum for learning web
development": directory-per-course (`foundations/`, `javascript/`,
`databases/`, `nodeJS/`, `getting_hired/`, …), each containing lesson
markdown; foundations splits into `html_css`, `javascript_basics`,
`installations`, `introduction`, `tying_it_all_together` (verified via
contents API). About page: 1,896,601 learners, 5000+ contributors, founded
2013, volunteer-maintained, curriculum "meticulously curated" with a
project-building emphasis. License: **CC BY-NC-SA 4.0** per `license.md`
(fetched 2026-09-08; GitHub shows NOASSERTION because CC licenses aren't
auto-detected).

**Design decisions worth borrowing.**

1. **Course = directory, lesson = file, with linting** — markdownlint,
   prettier, codespell configs in-repo keep 5,000+ contributors consistent.
   If Learning-Hog ever accepts community `sources/*.yaml` PRs, the same
   lint-on-PR pattern applies cheaply.
2. **Project-driven sequencing** — modules are punctuated by build-projects;
   `path` output could tag "practice checkpoint" nodes between resources.
3. **Versioned curriculum with an archive dir** — `archive/` holds retired
   lessons; a registry needs the same deprecation story instead of silent
   deletion.

**Known limitations.** Web-dev only; NC license limits commercial reuse;
curriculum quality depends on volunteer curation (they document their curation
process, not automated validation); no public API.

**What this project should NOT copy.** NC licensing (blocks downstream reuse
Learning-Hog wants to enable) and hand-curated-only updating — Learning-Hog's
adapters must refresh automatically, with curation as a seed, not the engine.

### 2.5 NotebookLM (+ deep-research products, Part C)

**Architecture overview (behavior-level).** NotebookLM: upload/import
sources → Gemini "instantly becomes an expert, grounding its responses in
your material with citations and relevant quotes"; personal data "never used
to train" (Google blog). **Discover Sources** (Apr 2, 2025): "describe your
topic, and NotebookLM will find and summarize relevant sources," gathering
"hundreds of potential web sources in seconds," presenting **up to 10 source
recommendations, each with an annotated summary explaining its relevance**;
one-click import; sources then feed Briefing Docs, FAQs, Audio Overviews
(Google Labs blog). Audio Overviews (Sep 11, 2024): two AI hosts discuss your
sources; explicitly "not a comprehensive or objective view of a topic, but
simply a reflection of the sources that you've uploaded" (Google blog).

**Design decisions worth borrowing.**

1. **Discover Sources = the exact behavior Learning-Hog's `find` generalizes**
   — but NotebookLM imports sources into a walled notebook for summarization;
   Learning-Hog instead hands back the URL list itself. The annotated-summary
   - relevance-explanation pattern is directly reusable in `find` output rows
   ("why this result").
2. **Citation-grounded answers only** — NotebookLM's "grounding + relevant
   quotes" matches Learning-Hog's "citations only from fetched content" rule
   (doc 05). The pattern is validated at consumer scale.
3. **Explicit epistemic framing** — Google's "reflection of the sources you've
   uploaded" disclaimer is honest about corpus bias; Learning-Hog should
   state which adapters were queried and which were skipped per run.

**Known limitations.** NotebookLM summarizes — the README's target critique.
Sources live inside a notebook (no export of a structured resource list);
no CLI, no per-item license/free-type taxonomy; Google-account gated.

**What this project should NOT copy.** Summarization-first UX. Learning-Hog's
thesis (README) is that summaries make learners passive; `explain` must stay
a per-resource side feature, never the default output.

**Deep-research product behaviors (README-mentioned + similar):**

- **OpenAI Deep Research** (Feb 2, 2025): "finds, analyzes, and synthesizes
  hundreds of online sources to create a comprehensive report"; 5–30 min
  runs; "every output is fully documented, with clear citations and a summary
  of its thinking"; single-question → report; later updates added MCP
  connections and trusted-site restriction (Feb 10, 2026 update on the same
  page). [OpenAI page fetched 2026-09-08]
- **Gemini Deep Research**: transforms the prompt "into a personalized
  multi-point research plan" the user can refine, searches/browses
  autonomously (incl. Gmail/Drive/Chat), shows a thinking panel, synthesizes
  "multi-page reports," self-critique passes; Google states it "pioneered the
  Deep Research product category … in December 2024." [Gemini page fetched]
- **Perplexity Deep Research** (Feb 14, 2025): "performs dozens of searches,
  reads hundreds of sources," 2–4 min runtime, report + export/share; free
  tier with daily limits. [Perplexity blog fetched]
- **Claude Research** (Apr 15, 2025): "multiple searches that build on each
  other," "easy-to-check citations," minutes-scale. [Anthropic/Claude page
  fetched]
- **Study-mode behaviors** (adjacent pattern): OpenAI **study mode** (Jul 29,
  2025) — Socratic questioning, scaffolding, knowledge checks, built "in
  collaboration with teachers… and pedagogy experts"; Google **Guided
  Learning** (Aug 6, 2025) — step-by-step breakdowns, quizzes, multimodal
  responses, LearnLM-based. These validate Learning-Hog's anti-summary thesis
  from the other direction: even the summarizer vendors now ship
  effort-preserving modes. [Both pages fetched]

**Common deep-research pipeline across OSS implementations** (dzhng
deep-research README, LangChain open_deep_research README, GPT Researcher
README — all fetched): generate targeted queries from a goal → search →
extract learnings → decide next directions → recurse (breadth/depth
parameters) → synthesize cited report. Confirmed benchmarks: Deep Research
Bench leaderboard (open_deep_research README cites a #6 ranking, 2025-08-02).

### 2.6 (brief) OpenPath — closest architectural comparable

Search (YouTube Data API v3 + Tavily) → pick (thumbnails, source tags) →
Build (Bedrock structures selections into sequenced modules) → Learn
(per-resource quizzes + in-prompt RAG chat with citations). Key technical
decisions stated in its README: **in-prompt RAG instead of a vector DB**,
YouTube Data API "for real video URLs and thumbnails — no fake/hallucinated
links," session-based no-auth. Hackathon-scale (0★, no license file, AWS-only
stack), so treat as a design reference, not a dependency. [README fetched
2026-09-08]

## 3. Comparison & critique (mapped to README goals)

**Goal: all-medium free resources, verified, no hallucinated URLs.**

- OSSU/free-programming-books/awesome solve this with **human curation**;
  OpenPath solves it with **source-API-only URLs**; roadmap.sh solves it with
  **community review**. Learning-Hog combines all three: adapters (API truth)
  - curated YAML seeds + validation + registry PR review. No shortlisted
  project has an automated URL validator — that remains differentiating.
- License spread matters: CC-BY-4.0 (free-programming-books), CC0 (awesome),
  MIT (OSSU, devroadmaps, deep-research agents), AGPL-3.0 (Anki, Exercism
  website), Apache-2.0 (GPT Researcher), CC BY-NC-SA (Odin curriculum),
  NOASSERTION/custom (roadmap.sh content, liuchong/awesome-roadmaps "Zero
  Public License" — verbatim: "ZERO PUBLIC LICENSE", restrictive despite the
  name), none (OpenPath, Exercism main repo). Copy *patterns* freely from
  MIT/Apache/CC-BY items; only *link* to NOASSERTION/NC content. The same
  spread is why per-item permission resolution exists (docs 01/04): an
  explicit license claims its terms, NOASSERTION/none items fall back to
  link-out or IMPLIED-LICENSE treatment (public + logged-off + index/snippet
  only — *Field v. Google*), never redistribution.

**Goal: roadmap generation, learner-paced.**

- Static-skeleton camp (OSSU, Odin, roadmap.sh): high quality, doesn't scale
  to arbitrary fields. LLM-structuring camp (OpenPath, deep-research agents):
  scales to any topic, variable quality. Learning-Hog's `path` = static
  skeletons where available + LLM ordering over validated resources — doc 08's
  plan is consistent with what the field converged on.

**Goal: anti-summary positioning (resources > summaries).**

- Deep-research products (OpenAI/Gemini/Perplexity/Claude) all converge on
  *report-as-output*; NotebookLM converges on *notebook-as-output*. None
  returns a clean, license-labeled, validated **resource list** as the
  primary artifact. That is the whitespace Learning-Hog occupies — and the
  study-mode/Guided-Learning trend confirms demand for effort-preserving
  learning tools.
- Conflict noted across sources: Gemini's page claims it "pioneered" deep
  research (Dec 2024) while Perplexity's and OpenAI's launches are Feb 2025;
  the Gemini claim is a vendor claim about the category, not independent
  history — treat chronology claims as marketing until a neutral source
  confirms.

**Goal: OpenAI-compatible endpoint, local-first.**

- dzhng/deep-research explicitly supports local LLMs via
  `OPENAI_ENDPOINT`/`OPENAI_MODEL` (LM Studio example in its README) — same
  env-switch pattern as Learning-Hog doc 06. LangChain's agent needs
  structured outputs + tool calling (limits which local models work). Anki
  and Kolibri prove fully-offline learning tooling is viable at scale.

**Where existing solutions are weak (opportunity list).**

1. No project combines free-type labeling (OER-CC/FREE-FULL/AUDIT-ONLY×
   TIME-LIMITED) with all-medium coverage.
2. Roadmap projects ship links without validation; link rot is managed by
   humans, not code.
3. Deep-research agents optimize for reports, not for curated resource lists
   with per-item licenses.
4. Per-field expansion is manual everywhere (new OSSU field = new repo; new
   roadmap.sh roadmap = community cycle); `sources/<skill>.yaml` + adapters
   is a genuinely different mechanism.

## 4. Conflicts & unverified items (explicit)

- **roadmap.sh repo ownership**: GitHub now serves the repo under
  `nilbuild` (verified: user `nilbuild` = Kamran Ahmed, blog kamran.fyi);
  earlier docs cite `kamranahmedse/...`, which redirects. Not a conflict of
  fact, but docs must standardize on one canonical URL.
- **langchain-ai/open_deep_research is archived** (GitHub API `archived:
  true`, pushed 2026-08-10) while its README presents it as active with 2025
  updates. Use it as a frozen reference; don't depend on it.
- **Exercism activity**: main `exercism/exercism` repo pushed 2024-03-01
  with no license file, but the org is active (`exercism/website` AGPL-3.0
  pushed 2026-09-04; `problem-specifications` MIT pushed 2026-09-02). Judge
  activity at org level, not the legacy main repo.
- **liuchong/awesome-roadmaps license**: file says "ZERO PUBLIC LICENSE"
  (restrictive, all-rights-like) despite the repo's listing in awesome
  indexes — do not redistribute its content; link only.
- **Unverified (needs confirmation before citing)**: exact current star
  counts beyond the snapshot above; NotebookLM's current source-import
  formats; whether OpenPath is still deployed (CloudFront demo URL not
  fetched); roadmap.sh current roadmap count (about page says "hundreds of
  thousands of developers every month" but no total count was verifiable
  from fetched pages; doc 03's 365k★ figure matched the 2026-09-08 API
  snapshot of 366,537★).

## 5. Source list

**GitHub API metadata (live, 2026-09-08; stars/license/activity per repo):**

1. <https://api.github.com/repos/nilbuild/developer-roadmap> — 366,537★, NOASSERTION, pushed 2026-09-07
2. <https://api.github.com/repos/freeCodeCamp/freeCodeCamp> — 455,189★, BSD-3-Clause, pushed 2026-09-07
3. <https://api.github.com/repos/EbookFoundation/free-programming-books> — 396,219★, CC-BY-4.0, pushed 2026-09-06
4. <https://api.github.com/repos/ossu/computer-science> — 208,809★, MIT, pushed 2026-07-14
5. <https://api.github.com/repos/TheOdinProject/curriculum> — 13,018★, NOASSERTION, pushed 2026-09-07
6. <https://api.github.com/repos/exercism/exercism> — 7,585★, no license, pushed 2024-03-01
7. <https://api.github.com/repos/ankitects/anki> — 30,404★, NOASSERTION (AGPL-3.0 per LICENSE), pushed 2026-09-07
8. <https://api.github.com/repos/sindresorhus/awesome> — 504,012★, CC0-1.0, pushed 2026-09-02
9. <https://api.github.com/repos/prakhar1989/awesome-courses> — 70,956★, no license, last push 2023-05-04 (stale)
10. <https://api.github.com/repos/ForrestKnight/open-source-cs> — 23,751★, MIT, pushed 2025-06-11
11. <https://api.github.com/repos/liuchong/awesome-roadmaps> — 7,325★, NOASSERTION, pushed 2026-08-03
12. <https://api.github.com/repos/cxqeric/devroadmaps> — MIT, pushed 2026-05-11
13. <https://api.github.com/repos/DeepikaSidda/OpenPath> — 0★, no license, pushed 2026-04-15
14. <https://api.github.com/repos/langchain-ai/open_deep_research> — 12,675★, MIT, **archived**, pushed 2026-08-10
15. <https://api.github.com/repos/dzhng/deep-research> — 19,650★, MIT, pushed 2026-04-11
16. <https://api.github.com/repos/assafelovic/gpt-researcher> — 29,337★, Apache-2.0, pushed 2026-08-27
17. <https://api.github.com/repos/learningequality/kolibri> — 1,114★, MIT, pushed 2026-09-03
18. <https://api.github.com/repos/exercism/problem-specifications> — 358★, MIT, pushed 2026-09-02
19. <https://api.github.com/repos/exercism/website> — 547★, AGPL-3.0, pushed 2026-09-04
20. <https://api.github.com/repos/mitodl/ocw-studio> — 14★, BSD-3-Clause, pushed 2026-09-07
21. <https://api.github.com/users/nilbuild> — profile: name Kamran Ahmed, blog kamran.fyi
22. <https://api.github.com/repos/missing-semester/missing-semester> — 6,038★, pushed 2026-09-08

**License files (raw fetches):**
23. <https://raw.githubusercontent.com/ankitects/anki/main/LICENSE> — "AGPL v3 or later, with portions… BSD-3"
24. <https://raw.githubusercontent.com/TheOdinProject/curriculum/main/license.md> — CC BY-NC-SA 4.0
25. <https://raw.githubusercontent.com/missing-semester/missing-semester/master/license.md> — CC BY-NC-SA 4.0
26. <https://raw.githubusercontent.com/nilbuild/developer-roadmap/master/license> — all-rights-reserved text (verbatim captured)
27. <https://raw.githubusercontent.com/liuchong/awesome-roadmaps/master/LICENSE> — "ZERO PUBLIC LICENSE"
28. <https://raw.githubusercontent.com/sindresorhus/awesome/main/readme.md> — list conventions

**Repo structure probes (GitHub contents API, 2026-09-08):**
29. contents of freeCodeCamp `curriculum/` — curriculum.json, blocks/, superblocks/, schema/, structure/, licenses/
30. contents of TheOdinProject `curriculum/` root + `foundations/` — dir-per-course layout
31. contents of developer-roadmap `roadmaps/python/content/` — node-per-file `<slug>@<id>.md` pattern
32. contents of devroadmaps root — roadmaps/ + JSON-driven PWA
33. contents of exercism `problem-specifications/exercises/` — per-exercise dirs
34. <https://raw.githubusercontent.com/exercism/problem-specifications/main/exercises/accumulate/canonical-data.json> — canonical test-data format
35. <https://raw.githubusercontent.com/ossu/computer-science/master/README.md> — curriculum criteria + sequencing
36. <https://raw.githubusercontent.com/DeepikaSidda/OpenPath/main/README.md> — full architecture + key decisions
37. <https://raw.githubusercontent.com/dzhng/deep-research/main/README.md> — breadth/depth recursion, local-LLM env vars
38. <https://raw.githubusercontent.com/langchain-ai/open_deep_research/main/README.md> — LangGraph architecture, DR Bench ranking
39. <https://raw.githubusercontent.com/assafelovic/gpt-researcher/master/README.md> — planner/execution agents, citations
40. <https://raw.githubusercontent.com/learningequality/kolibri/develop/README.md> — offline-first platform description

**Product pages (fetched 2026-09-08):**
41. <https://openai.com/index/introducing-deep-research/> — launch + behavior + updates timeline
42. <https://gemini.google/overview/deep-research/> — plan→search→reason→report pipeline; "pioneered Dec 2024" claim
43. <https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research> — 2–4 min runs, free tier
44. <https://claude.com/blog/research> (via anthropic.com/news/research redirect) — agentic search + citations
45. <https://blog.google/innovation-and-ai/products/notebooklm-audio-overviews/> — grounding, citations, "reflection of sources" disclaimer
46. <https://blog.google/innovation-and-ai/models-and-research/google-labs/notebooklm-discover-sources/> — Discover Sources behavior (≤10 annotated sources)
47. <https://openai.com/index/chatgpt-study-mode/> — study mode behaviors
48. <https://blog.google/products-and-platforms/products/education/guided-learning/> — Guided Learning + LearnLM
49. <https://docs.ankiweb.net/background.html> — active recall + spaced repetition rationale, FSRS
50. <https://www.theodinproject.com/about> — learners/contributors/founding stats
51. <https://roadmap.sh/about> — build (Astro/Tailwind/GH Pages), open-core, redistribution prohibition

**Search-discovery aids (used to locate/confirm URLs; not claim sources):**
52. web_search: Perplexity Deep Research announcement URL resolution
53. web_search: NotebookLM Discover Sources URL resolution
54. web_search: study mode / Guided Learning URL resolution

*(Failed fetches recorded for transparency: notebooklm.google.com → Google
sign-in redirect; support.google.com NotebookLM article → 404;
theodinproject.org → DNS/connect failure (correct domain is
theodinproject.com); perplexity /hub/getting-started/deep-research → 404
(correct URL is /hub/blog/...); docs.ankiweb.net fetch succeeded;
open.school returned 403 to automated fetch — its behavior remains sourced
from doc 02's earlier verified capture.)*

## 6. Recommended actions for Learning-Hog (from this research)

1. Keep `sources/<skill>.yaml` as pure data with a published JSON schema
   (freeCodeCamp pattern) — this is the strongest scaling mechanism observed.
2. Adopt node-per-file or node-per-ID addressing for `path` output so
   roadmaps are diffable and link-stable (roadmap.sh pattern) without
   copying its content.
3. Encode OSSU-style explicit inclusion criteria as validator gates, not
   prose.
4. For the "hidden gem miner," reuse the deep-research loop shape
   (query generation → search → learnings → recurse) but terminate at a
   **validated resource list**, not a report — that is the deliberate
   divergence from every deep-research product studied.
5. Record per-item `license`/`attribution` from day one (freeCodeCamp
   discipline); treat NOASSERTION/NC sources as link-out-only.
6. Standardize repo citations on `nilbuild/developer-roadmap` (or the
   redirect) and note the archived status of `open_deep_research` wherever
   it is referenced.
