# 05 — AI Interaction Modes (chat vs search vs roadmap)

## Verified facts

- **OpenAI Structured Outputs
  (developers.openai.com/api/docs/guides/structured-outputs):**
  `response_format: {type:"json_schema", strict:true}` guarantees schema
  adherence via constrained decoding (not just valid JSON). Legacy
  `type:"json_object"` guarantees only parseable JSON. SDKs derive schema from
  Pydantic/Zod; `refusal` field for safety declines. Supported on
  `gpt-4o-mini/2024-08-06` and later.
- **Ollama structured outputs
  (docs.ollama.com/capabilities/structured-outputs):** native
  `format: <json-schema>` + OpenAI-compat via `response_format`. Tips: define
  schema with Pydantic/Zod, set `temperature:0`, also instruct "return as JSON"
  in prompt. `format:"json"` = loose JSON mode only.
- **Precedent mapping:** open.school = search + LLM summarize; OpenPath =
  search→pick→build (roadmap) + per-resource quiz + RAG chat (summaries injected
  into prompt, no vector DB); R.A.I.S.E. = filter-syntax search.
- **MCP prompts (modelcontextprotocol.io):** reusable prompt templates exposable
  as MCP `prompts` — V2 hook for all three modes.

## Analysis

All three modes share one retrieval backend (`04`). Difference is only prompt +
output schema + presenter. Forcing a single mode in V1 would discard user intent
("not sure — explore" was explicit). CLI can offer all three cheaply as
subcommands over the same code.

## Brainstorm — options evaluated

1. **Chat tutor:** lowest friction for vague goals, highest hallucination risk,
   needs conversation state. Needs RAG grounding to be safe.
2. **Search + ranking:** best precision, maps to `find`, JSON-schema output fits
   tables. Loses sequencing.
3. **Roadmap generator:** best for "become X", reuses roadmap.sh skeletons, needs
   ordering logic (prereq graph). Risk: generic paths.
4. **Hybrid (recommended):** `find` (search) + `path` (roadmap) now; `chat` as
   thin REPL over chosen path summaries (OpenPath in-prompt RAG, no vector DB).

## Recommendation — V1 CLI mapping

- `learning-hog find "<nl query>"` → parse filters (JSON schema:
  `{keywords, level, mediums[], free_types[]}`) → adapters → table. Uses
  `json_object` or `json_schema` depending on endpoint capability; **always
  validate locally with `msgspec`** (the repo already depends on it; it emits
  JSON Schema and needs no extra dependency), which covers Ollama/LM Studio
  variance.
- `learning-hog path "<goal>"` → same retrieval, second LLM call orders into
  modules `{title, why, resources[{title,url,medium,level}]}` with strict schema.
- `learning-hog chat` (experimental flag): loads last path JSON summaries into
  system prompt, answers with citations only.
- Shared guardrail: temperature 0 for parse/rank calls; model name + base_url
  from env; every resource must carry a validated URL or be dropped. **Provider
  capability for strict `json_schema` varies:** OpenAI, Ollama, and LM Studio are
  verified; Groq supports it only on select models (`openai/gpt-oss-20b`,
  `openai/gpt-oss-120b`, `qwen/qwen3.8-27b`) with all fields required and
  `additionalProperties:false`, and **no streaming/tool-use with structured
  outputs** (<https://console.groq.com/docs/structured-outputs>); Gemini supports
  a JSON Schema subset natively
  (<https://ai.google.dev/gemini-api/docs/structured-output>) but the
  OpenAI-compat layer can ignore the schema
  (<https://discuss.ai.google.dev/t/structured-output-not-working-via-the-openai-compatible-layer/108341>),
  so treat Gemini-via-compat as `json_object`-tier until tested per model;
  OpenRouter free model variants (`:free`) are 50 req/day and 20 req/min until a
  one-time $10 credit purchase raises the daily cap
  (<https://openrouter.ai/docs/api_reference/limits> +
  <https://openrouter.zendesk.com/hc/en-us/articles/39501163636379-OpenRouter-Rate-Limits-What-You-Need-to-Know>).
  When strict `json_schema` is unavailable, use a validate-and-retry loop
  (instructor pattern, <https://python.useinstructor.com/>); keep msgspec as the
  local validator either way.
- For `chat`/`explain`, fetched titles/descriptions/summaries are **untrusted
  text** (OWASP LLM01:2025 —
  <https://genai.owasp.org/llmrisk/llm01-prompt-injection/>); delimit them as
  data, never follow instructions found inside, and keep citations only from
  fetched content.
- Snippet discipline in `explain` output doubles as the legal posture:
  quoting short passages with prominent attribution and an outbound link is
  the exact pattern *Authors Guild v. Google* (2d Cir. 2015) held
  transformative — full-text indexing with limited snippet display does not
  substitute for the original
  (<https://law.justia.com/cases/federal/appellate-courts/ca2/13-4829/13-4829-2015-10-16.html>).
  So `explain` renders quotes, never wholesale reproduction, and always the
  link — which also keeps `IMPLIED-LICENSE` items (doc 01) inside their
  permitted scope. Answers synthesized from a resource must drive the user
  to the source rather than replace the visit: the recommender's alignment
  with creators (doc 02) is what preserves the implied-license argument.

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
