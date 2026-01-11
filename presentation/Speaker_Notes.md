# AI Agents Unplugged - Speaker Notes

**Presentation Duration: 25 minutes**

---

## Slide 1: Title Slide - AI Agents Unplugged

- Hi everyone — welcome. "Unplugged" means practical and no hype.
- In the next 25 minutes, we'll move from simple prompts to reliable, observable agent workflows.
- Stick around for a short demo and a clear path you can replicate.

---

## Slide 2: Agent's Framework (Word Cloud)

- This word cloud shows just how many agent frameworks exist today.
- Different names, similar goals: build useful, reliable agent workflows.
- Today's path: prototype quickly, then harden for production.

---

## Slide 3: Why Agents?

- Prompts are single-shot instructions. Agents are stateful workers that plan, act with tools, observe, and finish.
- We'll look at tool-calling, retries, and shared state — the ingredients of a reliable agent.

---

## Slide 4: Agentic Patterns

- We'll climb a simple ladder of patterns: ReAct → Planner/Executor → Graph.
- ReAct is fast; add step limits and parsing checks. Planner/Executor adds structure and retries. Graphs add control and observability.
- We'll start simple and escalate, ending with human-in-the-loop and MCP.

### Detailed Notes:
- **ReAct**: Reason + Act → Observation loop; great for short tasks and few tools. Show a single tool call trace from the notebook. Mention guardrails: step limit and parsing errors.
- **Planner/Executor**: LLM drafts a plan, executor runs steps, re-plans on failure; better global context but slower. Call out retries, timeouts, and cost tracking.
- **Graph / multi‑agent**: Nodes = skills; edges = routing; shared state; easy to version, test, and add human‑review. Demo LangGraph g3: route (calc vs retrieve) → answer → human_review (interrupt) → accept/reject loop.
- **Trade‑offs**: ReAct (simple, fast) vs Planner/Executor (structured, costlier) vs Graph (most control/observability).
- **Transition line**: "We'll start with ReAct, then add routing, then close with human‑in‑the‑loop and MCP tools."

---

## Slide 5: LangChain vs. LangFlow

- Prototype visually in LangFlow, then ship with LangChain.
- Export JSON and call it via REST or load it directly in code.
- Operational guardrails in both: allow-lists, rate limits, circuit breakers.

### Detailed Presenter Notes:

**Definitions**
- **LangChain (code-first)**: Python-first framework. LCEL = LangChain Expression Language (composable chains, streaming, retries).
- **LangFlow (visual)**: Drag-and-drop DAG editor for LangChain objects. Export/import JSON. Run flows via REST; can expose endpoints/tools (incl. MCP).

**When to choose each**
- Use **LangChain** when you need: 
  - Version control + PR review, unit tests, CI/CD, reproducible builds, fine-grained error handling.
  - Library interop (LangGraph, LangSmith), typed state, and custom tool/security wrappers.
- Use **LangFlow** when you need:
  - Fast prototyping with non-dev collaborators, quick parameter tuning, and live demos.
  - Visual DAGs that you can export to JSON and call from services via REST.

**Deployment paths**
- **LangChain**: package as a service or notebook; containerize; add observability (LangSmith) and evaluations; store prompts and chains in repo.
- **LangFlow**: self-host or local; secure REST with API keys; export JSON and keep it versioned alongside code; treat environment variables as secrets.

**Costs/latency and ops**
- Both call the same models/tools; cost is similar. Visual runtime may add a small network hop for REST.
- Keep tool allow-lists, rate limits, and circuit breakers in both.

**Interop patterns**
- Prototype in LangFlow → export JSON → either invoke via REST or load the exported config into a LangChain service.
- Surface the same tools directly in LangChain and (optionally) via an MCP server for controlled access by multiple agents/clients.

**Demo cue**
- Flow today: code-first agent → call a LangFlow flow via REST → show MCP tools and controlled access.

**Takeaway**
- Start visual to align on design, then move stable graphs into code for tests, CI, and hardened security.

---

## Slide 6: LangChain vs. LangGraph (Diagram)

- On the left: LangChain's linear chains — great for straightforward sequences.
- On the right: LangGraph with central state, cycles, branching, tools, and human checks.
- Notice the control, traceability, and testable steps; observability and risk controls become first-class.

---

## Slide 7: MCP (Model-Context-Protocol)

- MCP is the safe handshake: an agent asks for a manifest, gets scoped credentials, and calls tools with auditability.
- Think of this as API governance for LLMs — controlled, observable access to tools and even other agents.
- I'll highlight where MCP fits into the demo flow.

---

## Slide 8: MCP (GitHub Servers)

- The number of MCP servers is growing fast — great momentum.
- Quality varies, so use trusted servers, scoped credentials, and strict allow-lists.
- Aim for speed with safety, not unchecked access.

---

## Slide 9: Risks & Guardrails

- Here are the top risks and what we do about them.
- **Prompt injection**: sanitize inputs and sandbox tools. **Data leakage**: use RBAC and scoped MCP credentials.
- **Infinite loops and cost**: add step limits and circuit breakers. **Hallucinations**: ground answers with retrieval.
- **Tool abuse**: enforce rate limits and keep audit logs.

---

## Slide 10: Live Demo

- Three beats to watch: first, a ReAct agent that retrieves and calculates; second, a hand-off to a LangFlow REST flow; third, tools accessed with MCP.
- I'll narrate decisions, retries, and guardrails, pausing briefly so you can see traces.
- By the end, you'll see a complete path from idea to controlled execution.

---

## Slide 11: Prompt Technique 1

- Common prompting techniques: zero-shot, few-shot, chain-of-thought, ReAct, tree-of-thoughts, RAG, self-consistency, prompt chaining, self-reflection, and persona.
- For the demo, we'll lean on ReAct and RAG — simple, effective, and observable.
- Keep these labels in mind; they help name patterns when we review traces.

---

## Slide 12: Prompt Technique 2

- Agent-based approaches structure the model's thinking into clear steps and tool calls.
- This reduces variance, increases reliability, and makes testing and debugging easier.
- Prefer small, explicit steps over giant, fragile prompts.

---

## Slide 13: LangChain Deprecation

- LangChain's `AgentType` is deprecated for new scenarios; the recommended path is LangGraph.
- Graphs offer better tool-calling, persistent state, and human-in-the-loop support.
- We start simple, then align to graphs as we add control.

---

## Slide 14: Prompt Engineering Techniques

- Prompt engineering still matters, but structure wins.
- Use concise prompts plus explicit steps, tools, and testable graphs rather than oversized prompts.
- This keeps systems easier to maintain and reason about.

---

## Slide 15: LangSmith

- Agent lifecycle: build, deploy, observe, evaluate, and iterate.
- Traces and dashboards give visibility; alerts keep production healthy.
- Evals help catch regressions early.

---

## Slide 16: Closing Thoughts

- Agents are stateful, tool-using programs — not magic.
- Start small with ReAct, move to graphs when you need control and observability.
- This turns LLMs into dependable software.

---

## Slide 17: Links & Resources

- Next steps: the Prompting Guide covers techniques; the "anti-intelligence" article gives broader context.
- Build with LangChain and LangFlow; add LangGraph docs and MCP server lists to your reading.
- Links included so you can explore further.

---

**End of Speaker Notes**
