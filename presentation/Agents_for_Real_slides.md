---
marp: true
---



# Agents for Real — Plan. Act. Deliver.

**LangChain · LangFlow · MCP (safe)**  
25-minute live tour + code

---

## Why agents (vs prompts)?
**Tools > Prompts.** Agents plan, call tools, verify, and finish tasks.

---

## Patterns
- ReAct — think/act/observe
- Planner/Executor — global plan across steps
- Graph / multi-agent — parallel skills, routing, shared state

---

## LangChain vs LangFlow
**LangChain** (code-first): LCEL, tests, CI/CD  
**LangFlow** (visual): DAGs, tweak params, export JSON, REST/MCP endpoints  
**Workflow**: ideate in LangFlow → codify in LangChain

---

## MCP (Model Context Protocol)
- Standardizes tool servers (stdio / streamable-HTTP)
- Safer: allow-list, input validation, stateless by default
- Works with LangChain & LangFlow

---

## Risks & Guardrails
Prompt injection · PII/secrets · Observability & eval (task KPIs)

---

## Live Demo
1) Build **ReAct** agent (retriever + calculator)  
2) Call **LangFlow** flow via REST  
3) Attach **MCP** safe tools

---

## Agent Landscape (1-year)
Size = **50%** GitHub stars (log) + **30%** enterprise + **20%** momentum  
(Use the all‑in‑one notebook to regenerate the word cloud)

---

## Closing
Agents are **tools-first** systems. Ship-ready means versioned graphs, safe tools (MCP), and evaluation & observability.
