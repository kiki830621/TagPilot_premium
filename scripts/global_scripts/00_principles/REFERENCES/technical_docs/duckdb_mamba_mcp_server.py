#!/usr/bin/env python3
"""
MCP Server for MAMBA DuckDB databases
Provides access to DuckDB databases via MCP protocol for Claude Desktop
"""

import json
import sys
import os
import duckdb
import pandas as pd
from typing import Any, Dict, List, Optional
from pathlib import Path

class MAMBADuckDBServer:
    def __init__(self):
        # MAMBA 專案的基礎路徑
        self.base_path = Path("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA")
        
        # 預設的資料庫連接
        self.databases = {
            "analytical": self.base_path / "data/mamba_eby_analytical.duckdb",
            "raw": self.base_path / "data/mamba_eby_raw.duckdb",
            "app_data": self.base_path / "data/app_data/app_data.duckdb",
            "global_scd": self.base_path / "scripts/global_scripts/global_data/global_scd_type1.duckdb"
        }
        
        self.connections = {}
        self._init_connections()
    
    def _init_connections(self):
        """初始化資料庫連接"""
        for name, path in self.databases.items():
            if path.exists():
                try:
                    self.connections[name] = duckdb.connect(str(path), read_only=True)
                    sys.stderr.write(f"Connected to {name}: {path}\n")
                except Exception as e:
                    sys.stderr.write(f"Failed to connect to {name}: {e}\n")
    
    def list_resources(self) -> List[Dict[str, Any]]:
        """列出所有可用的資源（資料庫和表格）"""
        resources = []
        
        for db_name, conn in self.connections.items():
            try:
                # 列出資料庫中的所有表格
                tables = conn.execute("SHOW TABLES").fetchall()
                for table in tables:
                    table_name = table[0]
                    # 獲取表格的行數
                    row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
                    
                    resources.append({
                        "uri": f"duckdb://{db_name}/{table_name}",
                        "name": f"{db_name}.{table_name}",
                        "description": f"Table with {row_count} rows",
                        "mimeType": "application/json"
                    })
            except Exception as e:
                sys.stderr.write(f"Error listing resources for {db_name}: {e}\n")
        
        return resources
    
    def get_resource(self, uri: str) -> Dict[str, Any]:
        """獲取特定資源的內容"""
        try:
            # 解析 URI: duckdb://database_name/table_name
            if uri.startswith("duckdb://"):
                parts = uri.replace("duckdb://", "").split("/")
                if len(parts) == 2:
                    db_name, table_name = parts
                    
                    if db_name in self.connections:
                        conn = self.connections[db_name]
                        # 獲取前 1000 筆資料作為預覽
                        df = conn.execute(f"SELECT * FROM {table_name} LIMIT 1000").fetchdf()
                        
                        return {
                            "contents": [{
                                "uri": uri,
                                "mimeType": "application/json",
                                "text": df.to_json(orient="records", date_format="iso")
                            }]
                        }
            
            return {"error": f"Resource not found: {uri}"}
        except Exception as e:
            return {"error": f"Error getting resource: {str(e)}"}
    
    def list_tools(self) -> List[Dict[str, Any]]:
        """列出可用的工具"""
        return [
            {
                "name": "query",
                "description": "Execute SQL query on MAMBA DuckDB databases",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "database": {
                            "type": "string",
                            "enum": list(self.connections.keys()),
                            "description": "Database to query"
                        },
                        "sql": {
                            "type": "string",
                            "description": "SQL query to execute"
                        },
                        "limit": {
                            "type": "integer",
                            "description": "Maximum rows to return",
                            "default": 1000
                        }
                    },
                    "required": ["database", "sql"]
                }
            },
            {
                "name": "describe_table",
                "description": "Get table schema and statistics",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "database": {
                            "type": "string",
                            "enum": list(self.connections.keys())
                        },
                        "table": {
                            "type": "string",
                            "description": "Table name"
                        }
                    },
                    "required": ["database", "table"]
                }
            },
            {
                "name": "list_tables",
                "description": "List all tables in a database",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "database": {
                            "type": "string",
                            "enum": list(self.connections.keys())
                        }
                    },
                    "required": ["database"]
                }
            }
        ]
    
    def call_tool(self, name: str, arguments: Dict[str, Any]) -> List[Dict[str, Any]]:
        """執行工具"""
        try:
            if name == "query":
                db_name = arguments.get("database")
                sql = arguments.get("sql")
                limit = arguments.get("limit", 1000)
                
                if db_name not in self.connections:
                    return [{"type": "text", "text": f"Database '{db_name}' not found"}]
                
                conn = self.connections[db_name]
                
                # 如果查詢沒有 LIMIT，自動加上
                if "LIMIT" not in sql.upper():
                    sql = f"{sql} LIMIT {limit}"
                
                df = conn.execute(sql).fetchdf()
                
                # 返回結果
                result_text = f"Query executed successfully. Returned {len(df)} rows.\n\n"
                result_text += df.to_string(max_rows=50, max_cols=10)
                
                return [{
                    "type": "text",
                    "text": result_text
                }]
            
            elif name == "describe_table":
                db_name = arguments.get("database")
                table_name = arguments.get("table")
                
                if db_name not in self.connections:
                    return [{"type": "text", "text": f"Database '{db_name}' not found"}]
                
                conn = self.connections[db_name]
                
                # 獲取表格結構
                schema = conn.execute(f"DESCRIBE {table_name}").fetchdf()
                
                # 獲取統計資訊
                stats = conn.execute(f"""
                    SELECT 
                        COUNT(*) as row_count,
                        COUNT(DISTINCT *) as distinct_rows
                    FROM {table_name}
                """).fetchdf()
                
                result = f"Table: {table_name}\n"
                result += f"Database: {db_name}\n\n"
                result += "Schema:\n"
                result += schema.to_string()
                result += f"\n\nStatistics:\n"
                result += stats.to_string()
                
                return [{"type": "text", "text": result}]
            
            elif name == "list_tables":
                db_name = arguments.get("database")
                
                if db_name not in self.connections:
                    return [{"type": "text", "text": f"Database '{db_name}' not found"}]
                
                conn = self.connections[db_name]
                tables = conn.execute("SHOW TABLES").fetchdf()
                
                result = f"Tables in {db_name}:\n"
                for _, row in tables.iterrows():
                    table_name = row[0]
                    try:
                        count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
                        result += f"  - {table_name} ({count} rows)\n"
                    except:
                        result += f"  - {table_name}\n"
                
                return [{"type": "text", "text": result}]
            
            else:
                return [{"type": "text", "text": f"Unknown tool: {name}"}]
                
        except Exception as e:
            return [{"type": "text", "text": f"Error: {str(e)}"}]

def handle_request(request: Dict[str, Any], server: MAMBADuckDBServer) -> Dict[str, Any]:
    """處理 MCP 請求"""
    method = request.get("method")
    params = request.get("params", {})
    request_id = request.get("id")
    
    result = None
    error = None
    
    try:
        if method == "initialize":
            result = {
                "protocolVersion": "2024-11-05",
                "capabilities": {
                    "resources": {},
                    "tools": {}
                }
            }
        
        elif method == "resources/list":
            result = {"resources": server.list_resources()}
        
        elif method == "resources/read":
            uri = params.get("uri")
            result = server.get_resource(uri)
        
        elif method == "tools/list":
            result = {"tools": server.list_tools()}
        
        elif method == "tools/call":
            name = params.get("name")
            arguments = params.get("arguments", {})
            result = {"content": server.call_tool(name, arguments)}
        
        else:
            error = {
                "code": -32601,
                "message": f"Method not found: {method}"
            }
    
    except Exception as e:
        error = {
            "code": -32603,
            "message": f"Internal error: {str(e)}"
        }
    
    response = {"jsonrpc": "2.0", "id": request_id}
    if error:
        response["error"] = error
    else:
        response["result"] = result
    
    return response

def main():
    """主程式"""
    sys.stderr.write("Starting MAMBA DuckDB MCP Server...\n")
    
    # 檢查必要的套件
    try:
        import duckdb
        import pandas
    except ImportError as e:
        sys.stderr.write(f"Missing required package: {e}\n")
        sys.stderr.write("Please install: pip install duckdb pandas\n")
        sys.exit(1)
    
    server = MAMBADuckDBServer()
    sys.stderr.write(f"Server initialized with {len(server.connections)} databases\n")
    
    # MCP 通訊迴圈
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            
            request = json.loads(line)
            response = handle_request(request, server)
            
            sys.stdout.write(json.dumps(response) + "\n")
            sys.stdout.flush()
            
        except json.JSONDecodeError as e:
            sys.stderr.write(f"Invalid JSON: {e}\n")
        except KeyboardInterrupt:
            sys.stderr.write("Server shutting down...\n")
            break
        except Exception as e:
            sys.stderr.write(f"Unexpected error: {e}\n")

if __name__ == "__main__":
    main()