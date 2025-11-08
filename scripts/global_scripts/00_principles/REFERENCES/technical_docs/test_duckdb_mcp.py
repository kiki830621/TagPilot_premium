#!/usr/bin/env python3
"""
測試 DuckDB MCP Server 是否正常運作
"""

import json
import subprocess
import sys

def test_mcp_server():
    """測試 MCP server 基本功能"""
    server_path = "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles/REFERENCES/technical_docs/duckdb_mamba_mcp_server.py"
    
    # 啟動 MCP server
    process = subprocess.Popen(
        ["python3", server_path],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True
    )
    
    try:
        # 測試初始化
        request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {}
        }
        
        process.stdin.write(json.dumps(request) + "\n")
        process.stdin.flush()
        
        response = process.stdout.readline()
        print("Initialize response:", response)
        
        # 測試列出工具
        request = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/list",
            "params": {}
        }
        
        process.stdin.write(json.dumps(request) + "\n")
        process.stdin.flush()
        
        response = process.stdout.readline()
        print("Tools list response:", response)
        
        # 測試列出資源
        request = {
            "jsonrpc": "2.0",
            "id": 3,
            "method": "resources/list",
            "params": {}
        }
        
        process.stdin.write(json.dumps(request) + "\n")
        process.stdin.flush()
        
        response = process.stdout.readline()
        print("Resources list response:", response)
        
    finally:
        process.terminate()
        process.wait()

if __name__ == "__main__":
    print("Testing MAMBA DuckDB MCP Server...")
    test_mcp_server()
    print("Test completed!")