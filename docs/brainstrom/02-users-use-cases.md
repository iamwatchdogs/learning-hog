# 02 — Users & Use Cases

## Verified facts

- **open.school (open.school):** "own curated set of courses kept in own index
  for fast retrieval", "sometimes keep tutorials and articles when formal courses
  not available", "option to summarize a course with LLMs like GPT", "natural
  language interface — queries like 'data science courses', 'geometric deep
  learning' are valid; add 'online'/'open' to filter delivery mode."
- **R.A.I.S.E. (raise-education.org/about):** power-query syntax —
  `type:course level:beginner`, `source:mitocw,openstax`, `lang:en`. Only
  approved open platforms, every link validated.
- **OpenPath (github.com/DeepikaSidda/OpenPath + Devpost):** verified
  end-to-end flow — `Search (YouTube Data API v3 + Tavily) → Pick (thumbnails,
  source tags) → Build (Bedrock structures into modules) → Learn (per-resource
  quiz + RAG chat with citations)`. Explicit lesson: "Bedrock hallucinates YouTube
  links, so we use the real API." Uses in-prompt RAG (summaries in S3 injected
  into prompt), no vector DB needed for course-sized context. Session-based, no
  auth to reduce friction.
- **MDPI course-search study (mdpi.com/2673-4591/103/1/18):** LLM parses NL
  query → structured params (keywords + boolean/enum filters) with
  grammar-restricted generation to prevent hallucinated search terms;
  cosine-similarity relevance check decides if parsing is needed.

## Analysis

- General learners don't want 50 tabs; OpenPath proves they want to **pick from
  real results, then let AI sequence**. That maps directly to CLI.
- NL queries ("learn python for automation, free, beginner") must be parsed to
  structured filters (`level, medium, cost, source`) — grammar-restricted, not
  free-form.
- No-auth, instant-answer is the friction killer for V1.
- **The creator is a second user.** Most educational authors are happy to be
  discovered; what they fear is (a) being replaced by a system that answers
  from their content so nobody clicks through, and (b) loss of control. A
  recommender that surfaces the work and sends the click is structurally
  aligned with that interest — so attribution and outbound links should be
  the loudest part of the output, not a footnote, and a public "content
  policy" page (what is collected, how, and how to opt out) converts that
  goodwill into a defensible position. If the success metric is "how many
  users did I send to the source today," the product sits on the right side
  of both the law and the ethics; if it is "how long can I keep the user
  reading someone else's text inside my tool," the implied-license argument
  collapses. This aligns with *Authors Guild v. Google* (2d Cir. 2015),
  where full-text indexing with limited snippet display was held
  transformative fair use that does not substitute for the original
  (<https://law.justia.com/cases/federal/appellate-courts/ca2/13-4829/13-4829-2015-10-16.html>).

## Brainstorm — CLI use cases for V1

1. `learning-hog find "linear algebra" --level beginner --free-only`
   → ranked table: title | medium | source | free-type | URL. Mirrors
   open.school + R.A.I.S.E. filters.
2. `learning-hog path "become data analyst" --depth 5`
   → sequenced modules (foundations → advanced), each with 2-4 resources across
   mediums. Mirrors OpenPath Build + roadmap.sh nodes.
3. `learning-hog explain <url-or-topic> --brief`
   → LLM summary of a resource (open.school summarize pattern), citations only
   from fetched content.
4. `learning-hog chat` (stretch V1, core V2)
   → in-prompt RAG over chosen path summaries, answers with citations (OpenPath
   lesson).
5. `learning-hog policy` (V1.5, doc-only command or man page)
   → prints the project's content policy: what is collected, per-item license
   handling, and opt-out channels (Content Signals / TDMRep / robots.txt).
   Pairs with the creator-alignment stance in Analysis: opt-out signals must
   be honored by the same adapters that surface the creators' work.

The installed entry point is `learning-hog` (pyproject.toml), so the CLI examples
and help text should use `learning-hog ...` rather than the shorthand `learn ...`.
Docs and code must agree on the user-facing command; this is a docs-consistency
fix, not a behavioral change.

## Recommendation

V1 ships use cases 1+2 only, with `--free-only` default-on and `--level/--medium`
flags implementing R.A.I.S.E.-style syntax in CLI form. Output = markdown table +
JSON (`--json`) for scripting/MCP reuse. No login, no history DB — local file
cache only. Because the installed command is `learning-hog`, the same examples
should be written as `learning-hog find "..."` / `learning-hog path "..."` in
docs, help text, and README examples, so the documented command matches what a
user actually runs.

**External audit (2026-09-07):** full audit was folded into docs 01–08; no
separate gap-analysis doc remains.
