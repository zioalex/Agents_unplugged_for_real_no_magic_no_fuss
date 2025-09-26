---
marp: true
---



# AI Agents Unplugged: Live, No Magic, No Fuss.

**LangChain · LangFlow · MCP (safe)**  
25-minute live tour + code

CoP Zurich 2025 - Alessandro Surace

---

![Agents Wordcloud](/assets/images/agentic_frameworks_wordcloud_weighted_color_1y_all.png)

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

---

# LangChain vs LangGraph

[LangChain vs LangGraph](./langchain-vs-langgraph.svg)

---

![bg](image-5.png)

---
## MCP (Model Context Protocol)

It is a standard way to allow LLMs to interact with external tools "in a safe and controlled manner".

It allows automous agents calling and agents to agents communication.

---

## Risks & Guardrails

**Prompt injection** · **PII/secrets leakage** · **Uncontrolled tool access** · **Model hallucinations** · **Cost escalation** · **Infinite loops** · **Cross-agent privilege escalation** · **Training data poisoning** · **Adversarial prompts** · **Resource exhaustion** · **Data exfiltration** · **Supply chain attacks** · **Model drift** · **Observability blind spots** · **Evaluation gaps**

**Mitigations:** MCP sandboxing · Input validation · Rate limiting · Audit logging · Role-based access · Circuit breakers

---

## Live Demo
1) Build **ReAct** agent (retriever + calculator)  
2) Call **LangFlow** flow via REST  
3) Attach **MCP** safe tools

---
![AgentType](image-2.png)

---

![AgentType2](image-3.png)

---

![LangChain Deprecated](image-1.png)

---

# [Prompt Techniques](image-4.png)

![Prompt Techniques](image-4.png)

---

# LangSmith

![LangSmith](image.png)

---

## Closing
Agents are **tools-first** systems. Ship-ready means versioned graphs, safe tools (MCP), and evaluation & observability.

---

## Links

https://www.promptingguide.ai/techniques
