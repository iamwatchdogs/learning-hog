# 06 — Core Architecture (Python CLI V1)

## Verified facts

- **Typer (typer.tiangolo.com, github.com/fastapi/typer):** "build great CLIs,
  easy to code, based on Python type hints", FastAPI sibling. Auto `--help`, shell
  completion (bash/zsh/fish), Rich-formatted errors. Deps: `rich`,
  `shellingham`, `annotated-doc`. `typer-slim` without Rich available.
- **OpenAI Python SDK env behavior
  (github.com/openai/openai-python `src/openai/_client.py`):** infers `api_key`
  from `OPENAI_API_KEY`, `base_url` from `OPENAI_BASE_URL`, default
  `https://api.openai.com/v1` if unset. So `OpenAI()` with no args already
  implements the env-switch — V1 just documents it.
- **Ollama compat (docs.ollama.com/api/openai-compatibility):**
  `base_url='http://localhost:11434/v1/'`, `api_key='ollama'` ignored; endpoints
  `/v1/chat/completions, /v1/completions, /v1/embeddings, /v1/models`; streaming
  SSE identical.
- **LM Studio compat (lmstudio.ai/docs/developer/openai-compat):**
  `base_url="http://localhost:1234/v1"`, dummy key ignored, model must be
  pre-loaded in Server tab.
- **HTTP validation (python-httpx.org):** `httpx.head(url, timeout=5.0)` default;
  `httpx.Client(timeout=10.0)` for custom; `HEAD` carries no body — ideal for link
  checks.
- **MCP forward-compat (modelcontextprotocol/python-sdk, Tier-1):** `pip install
  mcp[cli]`, Python ≥3.10, transports stdio + Streamable HTTP. Same core functions
  become `@mcp.tool()` in V2 with no rewrite if kept pure.

## Analysis

V1 must be: single `openai` dependency for LLM (no per-provider SDKs), pure
functions for fetch/rank (MCP-reusable), file cache (no DB), env config (no config
server). Keeps "core only" promise while leaving V2 door open.

## Brainstorm — module layout

```text
learning-hog/
  cli.py          # Typer app: find / path / chat / sources
  llm_client.py   # OpenAI() with no args; model=os.getenv("LLM_MODEL","gpt-4o-mini")
  planner.py      # NL → structured filters (msgspec, temp=0)
  source_router.py# loads sources/<skill>.yaml, picks adapters
  adapters/
    github.py     # search/repositories (30/min)
    stackexchange.py # /search/advanced (key optional → 10k/day)
    youtube.py    # videos.list/playlistItems (1 unit), no search.list
    ocw.py        # static + Learn API (filter platform=ocw or price==0)
    hn_algolia.py # free, no key, optional V1 text adapter
    tavily.py     # only if TAVILY_API_KEY set + --web
    google_cscs.py# only if GOOGLE_CUSTOM_SEARCH_API_KEY + --web (100/day free)
    searxng.py    # only if SEARXNG_URL set
    bluesky.py    # searchPosts public, cache-first best-effort
  ranker.py       # dedup + free-type + freshness + level
  validator.py    # HEAD → streamed-GET fallback (405/403), follow redirects,
                  # UA, per-domain limit, Wayback fallback for dead links
  permissions.py  # per-URL permission gate: robots.txt + Content Signals
                  # (search/ai-input/ai-train) + TDMRep meta/header + noai
                  # meta tags + license sniff; logs raw signal snapshot per
                  # fetch (re-check on our own schedule — edge caches may
                  # serve stale robots.txt)
  provenance.py   # per-item record: source URL, fetch timestamp, HTTP status,
                  # signal snapshot, API endpoint; EU AI Act transparency +
                  # EDPB 03/2026 make the log a requirement, not hygiene
  security.py     # prompt-injection + SSRF rules for fetched text/URLs
  presenter.py    # Rich table + --json + markdown export; CC BY-SA attribution
  cache/          # JSON per query, 7d TTL
```

Env contract (documented in `--help`):

```text
OPENAI_BASE_URL=https://api.openai.com/v1  # or http://localhost:11434/v1
  (Ollama) / http://localhost:1234/v1 (LM Studio) /
  https://generativelanguage.googleapis.com/v1beta/openai/ (Gemini compat)
OPENAI_API_KEY=sk-...                      # or "ollama"/"lm-studio" dummy
  locally
LLM_MODEL=gpt-4o-mini                      # or llama3.2 / mistral-7b-instruct
  / gemini-compat model
YOUTUBE_API_KEY=... (optional)  GITHUB_TOKEN=... (raises 10→30/min)
TAVILY_API_KEY=... (optional, enables --web)  GOOGLE_CUSTOM_SEARCH_API_KEY=...
  (optional, enables free --web tier)
SEARXNG_URL=... (optional)
```

Free-LLM presets to document and test: Gemini via the OpenAI-compat layer uses
`base_url=https://generativelanguage.googleapis.com/v1beta/openai/`
(<https://ai.google.dev/gemini-api/docs/openai>) but json_schema may be ignored
through that layer
(<https://discuss.ai.google.dev/t/structured-output-not-working-via-the-openai-compatible-layer/108341>),
so treat it as `json_object`-tier until probed per model; Groq is OpenAI-compat
with a free tier of about 30 req/min
(<https://console.groq.com/docs/rate-limits>) and strict json_schema only on select
models (<https://console.groq.com/docs/structured-outputs>); OpenRouter free model
variants (`:free`) are 50 req/day and 20 req/min until a one-time $10 credit
purchase raises the daily cap
(<https://openrouter.ai/docs/api_reference/limits>).

## Recommendation

Build `find` + `path` first on `github + stackexchange + ocw(filtered) +
curated + hn-algolia` (all zero keys). Add
`youtube/tavily/google-custom-search/bluesky` behind flags. Every adapter returns
`{title,url,medium,source,free_type,license,attribution,permission,published_at}`
— `free_type` now includes `IMPLIED-LICENSE` (doc 01) and `permission`
carries the resolved signal state from `permissions.py`; LLM
never creates URLs, only ranks them. Because fetched titles/descriptions/summaries
are untrusted text, flow them into prompts only as delimited data (OWASP
LLM01:2025 —
<https://genai.owasp.org/llmrisk/llm01-prompt-injection/> +
<https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html>),
and harden any URL fetch for validation/explanation against SSRF: http/https scheme
allowlist, block private/loopback/link-local IPs, cap redirects
(<https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html>).
Keep functions side-effect-free for V2 `@mcp.tool()` wrapping.

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
