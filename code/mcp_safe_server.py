from __future__ import annotations
from mcp.server.fastmcp import FastMCP
import re, ast, operator, json

OPS = {
    ast.Add: operator.add, ast.Sub: operator.sub,
    ast.Mult: operator.mul, ast.Div: operator.truediv,
    ast.Pow: operator.pow, ast.USub: operator.neg,
    ast.Mod: operator.mod, ast.FloorDiv: operator.floordiv
}
def _eval(node):
    if isinstance(node, ast.Num): return node.n
    if isinstance(node, ast.BinOp): return OPS[type(node.op)](_eval(node.left), _eval(node.right))
    if isinstance(node, ast.UnaryOp): return OPS[type(node.op)](_eval(node.operand))
    raise ValueError("Unsupported expression")

def safe_calculator(expression: str) -> str:
    node = ast.parse(expression, mode='eval').body
    return str(_eval(node))

POLICIES = [
    {"id": "TravelPlus-2024", "text": "TravelPlus provides coverage for business travel including delayed flights, lost baggage, and emergency medical expenses up to CHF 10,000. Personal electronics are covered if they are lost due to theft, with a deductible of CHF 200. Pure misplacement is not covered."},
    {"id": "DeviceCare-Pro", "text": "DeviceCare-Pro covers accidental damage to smartphones and laptops used for work. Loss or theft is covered only when a police report is filed within 48 hours. Maximum payout CHF 1,500 per device, 2 incidents per policy year."},
    {"id": "FleetAssist", "text": "FleetAssist covers rented vehicles during company travel. It excludes personal property inside the vehicle unless explicitly endorsed."},
]
def simple_search(query: str, top_k: int = 3):
    import re
    terms = [t.lower() for t in re.findall(r"\w+", query)]
    scored = []
    for doc in POLICIES:
        text = doc["text"].lower()
        score = sum(text.count(t) for t in set(terms))
        if score > 0:
            scored.append((score, doc))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [doc for _, doc in scored[:top_k]]

mcp = FastMCP("SR-Policies", stateless_http=True)
MAX_Q = 200
BANNED = re.compile(r"(?i)(rm\s|-rf|\bimport\b|__|eval\(|exec\()")

@mcp.tool()
def secure_search_policies(query: str) -> dict:
    if not query or len(query) > MAX_Q or BANNED.search(query or ""):
        return {"error": "query_rejected"}
    hits = simple_search(query, top_k=3)
    return {"results": [{"id": h["id"], "snippet": h["text"][:280]} for h in hits]}

@mcp.tool()
def safe_calc(expression: str) -> str:
    if len(expression or "") > 100 or BANNED.search(expression or ""):
        return "error: expression_rejected"
    try:
        return safe_calculator(expression)
    except Exception as e:
        return f"error: {e}"

if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="127.0.0.1", port=3001)
