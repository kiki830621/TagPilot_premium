# Refactoring Documentation

This directory contains historical refactoring proposals and plans for the MAMBA principles system.

## Contents

### REFACTORING_PROPOSAL.md
- **Date**: 2025-08-28
- **Purpose**: Original proposal for refactoring principles to comply with MP097
- **Key Change**: Move implementation code from principles to separate R scripts
- **Status**: Completed for DuckDB documentation (DU01-DU10)

### REFACTORING_EXAMPLE_DU08.md
- **Date**: 2025-08-28
- **Purpose**: Demonstrates the refactoring pattern applied to DU08
- **Shows**: Before/after transformation of principle documentation
- **Status**: Template for other refactoring efforts

### IMMEDIATE_ACTION_PLAN.md
- **Date**: 2025-08-28
- **Purpose**: Action plan for systematic refactoring of all principles
- **Scope**: Covers all principle files requiring code extraction
- **Status**: In progress

## Refactoring Guidelines

1. **MP097 Compliance**: No principle file should contain >20 lines of implementation code
2. **Code Location**: Implementation code moves to `/scripts/global_scripts/` subdirectories
3. **Reference Pattern**: Use callout boxes to reference implementation files
4. **Documentation Focus**: Principles should explain concepts, not implement them

## Implementation Map

Extracted implementations are organized as follows:

```
/scripts/global_scripts/
├── 02_db_utils/duckdb/       # Database utility functions
│   ├── fn_duckdb_connection.R
│   ├── fn_duckdb_type_conversion.R
│   ├── fn_duckdb_list_columns.R
│   ├── fn_duckdb_optimization.R
│   └── fn_duckdb_import_export.R
├── 26_platform_apis/duckdb/  # Platform-specific API functions
└── ...
```

## Reference Format

When updating principle files, use this format:

```markdown
::: {.callout-note}
## Implementation Reference
**R Implementation**: `scripts/global_scripts/02_db_utils/category/filename.R`
**Function**: `function_name()`
**Purpose**: Brief description of what the function does
:::
```