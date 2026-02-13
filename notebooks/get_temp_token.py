"""
Test script for Azure OpenAI using client credentials from .env file.

Required environment variables in .env:
- AZURE_TENANT_ID=your-tenant-id
- AZURE_CLIENT_ID=your-client-id
- AZURE_CLIENT_SECRET=your-client-secret
- AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com
- AZURE_OPENAI_DEPLOYMENT=your-deployment-name
- AZURE_OPENAI_API_VERSION=2024-02-15-preview (optional)
- GDS_OPENAI_SCOPE=https://cognitiveservices.azure.com/.default (optional)

Run with: python test_demo_endpoint.py
"""

import os
from dotenv import load_dotenv
from azure.identity import ClientSecretCredential
import requests

# Load environment variables from .env file
load_dotenv()

# Get configuration from environment
tenant_id = os.getenv("AZURE_TENANT_ID")
client_id = os.getenv("AZURE_CLIENT_ID")
client_secret = os.getenv("AZURE_CLIENT_SECRET")
endpoint = os.getenv("AZURE_OPENAI_ENDPOINT")
deployment_name = os.getenv("AZURE_OPENAI_DEPLOYMENT", "gpt-4.1")
api_version = os.getenv("AZURE_OPENAI_API_VERSION", "2024-02-15-preview")
scope = os.getenv("GDS_OPENAI_SCOPE", "https://cognitiveservices.azure.com/.default")

# Validate required environment variables
required_vars = ["AZURE_TENANT_ID", "AZURE_CLIENT_ID", "AZURE_CLIENT_SECRET"]
missing = [var for var in required_vars if not os.getenv(var)]
if missing:
    print(f"❌ Missing required environment variables: {', '.join(missing)}")
    print("Please set them in your .env file or environment.")
    exit(1)

print("Azure OpenAI Direct Test with Client Credentials")
print("=" * 60)
print(f"Tenant ID: {tenant_id[:8]}..." if tenant_id else "Not set")
print(f"Client ID: {client_id[:8]}..." if client_id else "Not set")
print(f"Endpoint: {endpoint}")
print(f"Deployment: {deployment_name}")
print(f"API Version: {api_version}")
print(f"Scope: {scope}")
print("=" * 60)

# Get AAD token using client credentials
credential = ClientSecretCredential(
    tenant_id=tenant_id,
    client_id=client_id,
    client_secret=client_secret
)
token = credential.get_token(scope).token

print(f"This is the token:\n{token[:20]}...{token[-20:]}\n")

# Update config.json with the new token
config_path = os.path.join(os.path.dirname(__file__), "config.json")
import json
with open(config_path, 'r') as f:
    config_data = json.load(f)
config_data["API_KEY"] = token
with open(config_path, 'w') as f:
    json.dump(config_data, f, indent=2)
print(f"✓ Updated API_KEY in {config_path}\n")

url = f"{endpoint}/openai/deployments/{deployment_name}/chat/completions?api-version={api_version}"

headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {token}"
}

payload = {
    "messages": [{"role": "user", "content": "What is the capital of France?"}],
    "max_tokens": 50
}

print("\n✓ Sending request to Azure OpenAI...")
response = requests.post(url, headers=headers, json=payload)

if response.status_code == 200:
    print("✓ Success!")
    print(response.json())
else:
    print(f"❌ Error: {response.status_code}")
    print(response.text)