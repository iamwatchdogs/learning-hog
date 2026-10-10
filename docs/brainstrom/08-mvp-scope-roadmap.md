# 08 — MVP Scope & Roadmap (V1 CLI → V2 MCP + frontend)

## Verified facts

- **MCP spec 2026-07-28 (modelcontextprotocol.io/specification):** open
  protocol, JSON-RPC 2.0, stateless per-request (`_meta` carries
  version/capabilities), `server/discover` mandatory. Server primitives:
  **Tools** (`tools/list`, `tools/call`, `inputSchema`/`outputSchema` JSON
  Schema, deterministic order for caching), **Resources** (context data),
  **Prompts** (reusable templates). Extensions opt-in: Tasks (async long-run),
  Skills-over-MCP, MCP Apps (inline UI).
- **MCP Python SDK (github.com/modelcontextprotocol/python-sdk, Tier-1):**
  `pip install mcp[cli]`, Python ≥3.10, transports stdio + Streamable HTTP.
  V1 API = `FastMCP`, V2 = `MCPServer` (spec 2026-07-28). Same
  `@mcp.tool()` decorates a type-hinted function — docstring becomes
  description, hints become schema.
- **Cost ceilings verified:** YouTube `search.list` 100/day; Tavily 1000
  credits/mo free; GitHub 30/min; StackExchange 10k/day w/ free key; Reddit
  100 QPM personal. All fit CLI personal use, none fit unthrottled server scale
  without keys/cache.

## Analysis

V1 must prove retrieval+ranking core with zero paid deps. V2 turns the same
pure functions into MCP tools (Claude Desktop, IDEs, web frontend can all call
them). Frontend and server hosting are the expensive parts — correctly deferred.

## Brainstorm — scope

**V1 MVP (CLI, 2-3 weeks):**

- [ ] `find` + `path` commands (Typer), `--free-only` default, `--json`
  output; the installed command is `learning-hog`, so examples/help text use
  that name
- [ ] Adapters: `curated YAML + github + stackexchange + ocw (Learn API
  filtered to platform=ocw or price==0) + hn-algolia` (all zero keys);
  `youtube` needs 1 key; `tavily --web` and `google-custom-search --web`
  optional
- [ ] `validator.py` (HEAD → streamed-GET fallback for 405/403, follow
  redirects, realistic User-Agent, per-domain rate limit, Wayback
  availability-API fallback for dead links) + `cache/` 7d TTL
- [ ] `permissions.py` per-URL gate (robots.txt + Content Signals + TDMRep +
  noai; log the signal snapshot per fetch — doc 04) runs before any long-tail
  text is stored; V1 collects only from APIs/curated YAML, so the gate guards
  the `--web`/long-tail path
- [ ] `OPENAI_BASE_URL/MODEL/API_KEY` switch tested against Ollama 11434 + LM
  Studio 1234 + 1 cloud; also document Gemini-compat `base_url` and Groq/
  OpenRouter free variants as test targets
- [ ] free-type labels (OER-CC/FREE-FULL/AUDIT-ONLY/IMPLIED-LICENSE ×
  persistent|TIME-LIMITED)
  - level tags + per-item `license`/`attribution` for CC BY-SA sources
  - IMPLIED-LICENSE items rendered as index + snippet + attribution + link
    only (doc 01 scope; *Field v. Google*)
- Out: auth, accounts, DB, web UI, write-APIs (Reddit post, etc.), X/Insta
  scraping, certificates, payments. **Reddit is out of V1** because the
  Responsible Builder Policy requires pre-approval for all Data API access
  (<https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy>);
  it becomes a V2 optional source behind a documented user-approval flow.
  **roadmap.sh node markdown is out of V1** because it is all-rights-reserved
  (<https://github.com/kamranahmedse/developer-roadmap/blob/master/license>);
  V1 uses its structure/ordering for skeletons and links out to nodes only.
  **X/Instagram/Threads stay out** on the same grounds as doc 03: X is
  pay-per-use with no free tier and ToS-prohibited scraping; Instagram's
  Basic Display API ended 2024-12-04 and only account-owner-consented Graph
  access remains; Threads text is gated behind Meta Content Library
  research access (qualified institutions, CASD review). **No
  authentication-with-collection anywhere in the pipeline** — logged-off or
  sanctioned paths only (*hiQ*; *Meta v. Bright Data*).

**V1.5:** SearXNG self-host option, Bluesky adapter (searchPosts + optional
Jetstream ingest), local ratings file, more `sources/*.yaml` skills,
RSS/sitemap-first long-tail adapter with the permission gate, and optional
zero-cost corpus adapters (Common Crawl WET/FineWeb for historical depth,
GDELT for news breadth — sample, don't query).

**V2 (server/MCP + frontend):**

- Wrap `find/path/explain` as MCP tools: `find_resources`, `build_path`,
  `summarize_resource` with `inputSchema/outputSchema`; expose
  `sources/*.yaml` as MCP Resources; `find/path` prompts as MCP Prompts.
- Transports: stdio (Claude Desktop local) first, Streamable HTTP second
  (frontend/hosted). Use Tasks extension for slow `--web` searches.
- Frontend: thin chat/search UI calling MCP; progress/bookmarks (deferred
  from V1).

## Recommendation

Gate V1 exit on: 5 diverse topics return ≥8 validated free results each, zero
fabricated URLs in 50 runs, works offline except `--web`, switches LLM via env
with no code change. Only then start V2 MCP wrapper — no rewrite, just
decorators.

**External audit (2026-09-07):** the 2026-07-28 spec states "Servers MUST
implement `server/discover`"
(<https://modelcontextprotocol.io/specification/2026-07-28/basic/lifecycle>),
so the earlier ⚠️ on the V2 plan is resolved. Modern MCP revisions also have no
initialize handshake (per-request `_meta` versioning); 2025-11-25 and earlier
are "legacy". The V1 exit criteria mention validated links; measure them with
the upgraded validator (HEAD → GET fallback + Wayback fallback), not the old
`httpx.head 5s, drop failures` pattern that misses 405/403 false negatives
(<https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/405>).
