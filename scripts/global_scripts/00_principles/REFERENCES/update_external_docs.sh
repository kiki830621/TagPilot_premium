#!/bin/bash
# Update external documentation references
# This script updates all external documentation that we reference

echo "Updating external documentation references..."

# DuckDB Documentation
if [ -d "technical_docs/duckdb-web" ]; then
    echo "Updating DuckDB documentation..."
    cd technical_docs/duckdb-web
    git pull origin master
    cd ../..
    echo "DuckDB documentation updated."
else
    echo "DuckDB documentation not found. Cloning..."
    git clone https://github.com/duckdb/duckdb-web.git technical_docs/duckdb-web
    echo "DuckDB documentation cloned."
fi

# Add more external docs here as needed
# Example:
# if [ -d "technical_docs/other-docs" ]; then
#     cd technical_docs/other-docs
#     git pull
#     cd ../..
# fi

echo "All external documentation updated!"
echo "Last update: $(date)" > technical_docs/LAST_UPDATE.txt