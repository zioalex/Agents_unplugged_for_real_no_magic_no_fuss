
# Agents for Real — Separate Files Package (Full)

This archive contains: slides (Markdown), notebooks, code, and assets.

## Structure
- `presentation/Agents_for_Real_slides.md`
- `notebooks/llm_agents_langchain_langflow_demo.ipynb`
- `notebooks/mcp_addon_minimal.ipynb`
- `code/mcp_safe_server.py`
- `assets/images/agentic_frameworks_wordcloud_weighted_color_1y_all.png`
- `requirements.txt`

## Quick Start

```bash
python -m venv .venv && source .venv/bin/activate  # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

## Configuration

Update the file notebooks/config.json with your settings:

```json
{
  "OPENAI_API_BASE": "your_openai_api_base_here",  // e.g., https://api.openai.com/v1
  "API_KEY": "your_openai_api_key_here", // your OpenAI API key
  "LANGFLOW_API_KEY": "your_langflow_api_key_here"  // specify the Langflow API key if using Langflow
}
```

## Offline path (Ollama) or vllm backend:

Install Ollama and pull a model:

```bash
   ollama pull llama3.1:8b
```

```bash
  vllm serve "swiss-ai/Apertus-8B-Instruct-2509" --gpu-memory-utilization 0.4
```

## Run
1) Open `notebooks/llm_agents_langchain_langflow_demo.ipynb` and set `BACKEND` (OPENAI/OLLAMA).  
2) Optional — `langflow run --host 127.0.0.1 --port 7860`, then call your flow via REST from the notebook.  
    or `uv run langflow run`
3) Optional — start MCP server: `python notebooks/mcp_safe_server.py` and attach tools in `notebooks/mcp_addon_minimal.ipynb`.
