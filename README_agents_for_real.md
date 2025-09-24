
# Agents for Real — Separate Files Package (Full)

This archive contains: slides (Markdown), notebooks, code, and assets.

## Structure
- `presentation/Agents_for_Real_slides.md`
- `notebooks/llm_agents_langchain_langflow_demo.ipynb`
- `notebooks/mcp_addon_minimal.ipynb`
- `code/mcp_safe_server.py`
- `assets/images/agentic_frameworks_wordcloud_weighted_color_1y_all.png` (+ transparent)
- `requirements.txt`

## Quick Start
```bash
python -m venv .venv && source .venv/bin/activate  # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt

# OpenAI path:
export OPENAI_API_KEY=YOUR_KEY

# Offline path (Ollama):
#   install Ollama and pull a model:
#   ollama pull llama3.1:8b
```

## Run
1) Open `notebooks/llm_agents_langchain_langflow_demo.ipynb` and set `BACKEND` (OPENAI/OLLAMA).  
2) Optional — `langflow run --host 127.0.0.1 --port 7860`, then call your flow via REST from the notebook.  
    or `uv run langflow run`
3) Optional — start MCP server: `python code/mcp_safe_server.py` and attach tools in `notebooks/mcp_addon_minimal.ipynb`.
