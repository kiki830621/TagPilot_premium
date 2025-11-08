# DuckDB MCP Extension 設置指南

## 方法 1：編譯 Extension（推薦給開發者）

### 前置需求
- macOS 上需要 Xcode Command Line Tools
- CMake
- C++ 編譯器

### 編譯步驟
```bash
cd /Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles/REFERENCES/technical_docs/duckdb_mcp

# 編譯 extension
make

# 編譯完成後會產生 ./build/release/duckdb 可執行檔
```

### 使用方式
```sql
-- 在 DuckDB 中載入 extension
LOAD 'duckdb_mcp';

-- 連接到 MCP server
ATTACH 'python3' AS data_server (
    TYPE mcp, 
    TRANSPORT 'stdio', 
    ARGS '["path/to/server.py"]'
);
```

## 方法 2：使用 Python DuckDB 與 MCP Client

### 安裝依賴
```bash
pip install duckdb mcp
```

### Python 腳本範例
```python
import duckdb
from mcp import Client
import asyncio

async def query_duckdb_via_mcp():
    # 連接到本地 DuckDB
    conn = duckdb.connect('/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/data/mamba_eby_analytical.duckdb')
    
    # 執行查詢
    result = conn.execute("SELECT * FROM tables LIMIT 5").fetchall()
    return result

# 執行
asyncio.run(query_duckdb_via_mcp())
```

## 方法 3：建立簡單的 MCP Server Wrapper

創建一個 Python MCP server 來包裝 DuckDB 查詢功能：

### 檔案：`duckdb_mcp_server.py`
```python
#!/usr/bin/env python3
"""
Simple MCP server for DuckDB queries
"""
import json
import sys
import duckdb
from typing import Any, Dict, List

class DuckDBMCPServer:
    def __init__(self, db_path: str):
        self.conn = duckdb.connect(db_path)
    
    def list_resources(self) -> List[Dict[str, Any]]:
        """List available tables as resources"""
        tables = self.conn.execute("SHOW TABLES").fetchall()
        return [
            {
                "uri": f"table://{table[0]}",
                "name": table[0],
                "mimeType": "application/json"
            }
            for table in tables
        ]
    
    def get_resource(self, uri: str) -> Dict[str, Any]:
        """Get table data"""
        if uri.startswith("table://"):
            table_name = uri.replace("table://", "")
            data = self.conn.execute(f"SELECT * FROM {table_name} LIMIT 100").fetchdf()
            return {"data": data.to_json(orient="records")}
        return {"error": "Unknown resource"}
    
    def call_tool(self, tool: str, args: Dict[str, Any]) -> Dict[str, Any]:
        """Execute SQL query"""
        if tool == "query":
            sql = args.get("sql", "")
            try:
                result = self.conn.execute(sql).fetchdf()
                return {"result": result.to_json(orient="records")}
            except Exception as e:
                return {"error": str(e)}
        return {"error": "Unknown tool"}

def main():
    # MCP server 主迴圈
    server = DuckDBMCPServer(
        "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/data/mamba_eby_analytical.duckdb"
    )
    
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            
            request = json.loads(line)
            method = request.get("method")
            
            if method == "resources/list":
                response = {"resources": server.list_resources()}
            elif method == "resources/get":
                uri = request.get("params", {}).get("uri")
                response = server.get_resource(uri)
            elif method == "tools/call":
                tool = request.get("params", {}).get("name")
                args = request.get("params", {}).get("arguments", {})
                response = server.call_tool(tool, args)
            else:
                response = {"error": "Unknown method"}
            
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()
            
        except Exception as e:
            sys.stderr.write(f"Error: {e}\n")
            break

if __name__ == "__main__":
    main()
```

## 在 Claude Desktop 中配置

### 1. 找到或創建 claude_desktop_config.json
位置：`~/Library/Application Support/Claude/claude_desktop_config.json`

### 2. 添加 MCP server 配置
```json
{
  "mcpServers": {
    "duckdb-mamba": {
      "command": "python3",
      "args": [
        "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles/REFERENCES/technical_docs/duckdb_mcp/duckdb_mcp_server.py"
      ]
    }
  }
}
```

### 3. 重啟 Claude Desktop
配置完成後需要重啟 Claude Desktop 來載入新的 MCP server。

## 測試連接

在 Claude 中可以使用以下方式測試：
1. 查看可用的 MCP 資源
2. 執行 SQL 查詢
3. 獲取表格資料

## 注意事項

1. **安全性**：確保只在受信任的環境中使用
2. **權限**：確保 Python 腳本有執行權限
3. **路徑**：所有路徑都需要是絕對路徑
4. **依賴**：確保安裝了必要的 Python 套件（duckdb, pandas）