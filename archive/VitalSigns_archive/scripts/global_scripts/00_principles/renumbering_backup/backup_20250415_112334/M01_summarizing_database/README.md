# M01 Summarizing Database

This module implements the database documentation functionality described in MP43 (Database Documentation Principle). It provides tools for automatically generating comprehensive documentation of database structures and content in Markdown format.

## Functor Description

This module implements the `summarize database` functor, which maps database structures to documentation artifacts.

- **Source Category**: Database structures (tables, columns, relationships)
- **Target Category**: Markdown documentation
- **Structure Preservation**: The documentation preserves the hierarchical structure of the database
- **Natural Transformations**: Documentation style can be parameterized

## Files

- `summarize_database.R` - Core implementation of database documentation functionality
- `sc_document_database.R` - Script for direct execution of database documentation
- `summarize_database_utils.R` - Helper functions (to be implemented)

## SNSQL Commands

This module provides the following SNSQL commands:

```
summarize database "app_data.duckdb" 
```

```
summarize database "app_data.duckdb" to "docs/database/app_structure.md" with sample_rows=10
```

```
document all databases in "docs/database"
```

## Integration with Other Modules

This module integrates with:

- SNSQL Language (MP27) - Provides commands through SNSQL extensions
- Documentation Organization (MP07) - Follows documentation organization principles
- Information Flow Transparency (MP10) - Makes database structures explicit

## Implementation Notes

The module follows the Functor-Module Correspondence Principle (MP44) by:

1. Implementing a clean functor from database structures to documentation
2. Providing a consistent interface through SNSQL commands
3. Maintaining the structural relationship between source and target categories