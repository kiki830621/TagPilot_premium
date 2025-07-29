---
id: "R0093"
title: "Function Location Rule"
type: "rule"
date_created: "2025-04-13"
date_modified: "2025-04-13"
author: "Claude"
derives_from:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
  - "R0021": "One Function One File"
influences:
  - "P0004": "App Construction Principles"
---

# Function Location Rule

## Core Rule

Functions must be placed in appropriate functional directories based on their purpose, not in the meta-principles directory. The `00_principles` directory should contain only principle documentation (MP, P, R documents) and no implementation code.

## Implementation Guidelines

1. **Proper Location**: All function files (prefixed with `fn_`) must be placed in the appropriate functional directory matching their purpose:
   - Database utility functions → `02_db_utils/`
   - Configuration functions → `03_config/functions/`
   - General utility functions → `04_utils/`
   - Data processing functions → `05_data_processing/`
   - Etc.

2. **Prohibited Location**: Functions must NOT be placed in:
   - `00_principles/` (reserved for MP, P, R documentation)
   - `00_principles/[subdirectories]/` (except for module implementation directories like M01)

3. **Module Exception**: The only exception to this rule is for module implementation directories (e.g., `00_principles/M01_summarizing_database/`) which may contain implementation code according to the Functor-Module Correspondence Principle (MP0044).

4. **Reorganization Required**: Any function files currently located in `00_principles/` or its subdirectories (except module implementation directories) must be moved to the appropriate functional directory.

## Examples

### Correct Function Placement

```
global_scripts/
├── 02_db_utils/
│   ├── fn_db_connection_factory.R       # ✓ Correct
│   ├── fn_universal_data_accessor.R     # ✓ Correct
│   └── fn_list_to_mock_dbi.R            # ✓ Correct
├── 03_config/
│   └── functions/
│       └── fn_root_path_config.R        # ✓ Correct
└── 04_utils/
    └── fn_clean_column_names.R          # ✓ Correct
```

### Incorrect Function Placement

```
global_scripts/
└── 00_principles/
    ├── fn_root_path_config.R            # ✗ Incorrect
    └── 02_db_utils/
        ├── fn_universal_data_accessor.R # ✗ Incorrect
        └── fn_list_to_mock_dbi.R        # ✗ Incorrect
```

## Implementation Notes

When moving functions between directories:

1. Update all source references in other files
2. Ensure file paths in documentation remain accurate
3. Update any direct path references in code
4. Test functionality after moving to ensure everything works correctly

## Rationale

This rule enforces:

1. **Clear Organization**: Maintains a clean separation between principle documentation and implementation code
2. **Improved Discoverability**: Makes functions easier to find when located in directories that match their purpose
3. **Logical Structure**: Reinforces the structural blueprint of the application
4. **Consistent Application**: Ensures all developers follow the same organization pattern

## Related Rules

- **R0021** (One Function One File): Functions should be defined in their own files
- **R0033** (Recursive Sourcing): Details how to source files from directories
- **MP0044** (Functor-Module Correspondence): Defines module structure for implementation code allowed in principles directory
