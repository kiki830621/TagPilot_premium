---
id: "R42"
title: "Module Naming Convention"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-11"
author: "Claude"
implements:
  - "MP01": "Primitive Terms and Definitions"
  - "P05": "Naming Principles"
related_to:
  - "R40": "Implementation Naming Convention"
  - "R41": "Folder Structure"
---

# R42: Module Naming Convention

This rule establishes the naming convention for modules (M), ensuring clear, descriptive names that reflect the module's purpose and functionality while properly balancing human readability with system compatibility.

## Core Requirement

Module directories and definition files in the `00_principles` directory must follow a consistent naming pattern that includes both a numeric identifier and a descriptive title, ensuring modules are easily identifiable by both humans and automated systems. 

### Dual Naming Convention

This rule establishes a dual naming convention:

1. **Module Titles**: Use Title Case for human readability in documentation
   - Example: "External Raw Data Connection"
   - Used in front matter title field and H1 document heading
   - Ensures clarity and readability in documentation

2. **File/Directory Names**: Use snake_case for system compatibility
   - Example: `connection_helpers.R`, `sql_query_templates.R`
   - Applied to all additional files and utility scripts
   - Ensures cross-platform compatibility and consistency

## Module Naming Pattern

### Directory Naming

Module directories must follow this pattern:

```
M{number}
```

Where:
- **{number}**: The two-digit module number (e.g., 01, 02, 03)

### Module Definition File

The module definition file inside the directory must be named:

```
M{number}.md
```

### Front Matter Metadata

The module definition file must include front matter with the following properties:

```yaml
---
id: "M{number}"
title: "{Descriptive Title in Title Case}"
type: "module"
date_created: "YYYY-MM-DD"
date_modified: "YYYY-MM-DD"
author: "{author_name}"
implements:
  - "{referenced_principle}": "{principle_name}"
  - ...
related_to:
  - "{related_rule}": "{rule_name}"
  - ...
---
```

### Document Title

The document's H1 title must follow this pattern and use Title Case for the descriptive part:

```
# M{number}: {Descriptive Title in Title Case}
```

Example:
```
# M01: External Raw Data Connection
```

Note that the module title in documentation uses Title Case, while any file or folder names related to the module should use snake_case.

## Snake Case Convention for Additional Files

When additional files are needed within the module directory beyond the standard implementation files, they must follow snake_case naming convention:

1. Use only lowercase letters, numbers, and underscores
2. Separate words with underscores (not hyphens or spaces)
3. Be descriptive but concise
4. Indicate the file's purpose through its name

Examples:
- `connection_helpers.R` - Helper functions for connection module
- `sql_query_templates.R` - SQL templates for database queries
- `api_response_handlers.R` - Functions to handle API responses

This applies to all auxiliary files, utility scripts, and supporting documentation.

## Module Name Examples

| Module ID | Descriptive Title | Directory Name | Definition File | Document Title | Additional Files |
|-----------|-------------------|---------------|-----------------|---------------|------------------|
| M01 | External Raw Data Connection | M01/ | M01.md | # M01: External Raw Data Connection | connection_helpers.R |
| M02 | Customer Segmentation Engine | M02/ | M02.md | # M02: Customer Segmentation Engine | segment_utilities.R |
| M03 | Product Recommendation System | M03/ | M03.md | # M03: Product Recommendation System | recommendation_algorithms.R |
| M04 | Marketing Campaign Manager | M04/ | M04.md | # M04: Marketing Campaign Manager | campaign_templates.R |

## Implementation Files

Implementation files for modules follow the pattern defined in R40:

```
M{number}_P{platform}_{step}.R
```

Where:
- **{number}**: The two-digit module number (e.g., 01 for M01)
- **{platform}**: The two-digit platform number (e.g., 01 for Amazon) as defined in R38
- **{step}**: The two-digit step number (e.g., 00, 01, 02)

Example implementation files:
- `M01_P01_00.R`: Implementation of External Raw Data Connection for Amazon platform
- `M01_P06_00.R`: Implementation of External Raw Data Connection for eBay platform
- `M02_P01_00.R`: Implementation of Customer Segmentation Engine for Amazon platform

## Module Definition Requirements

Each module definition file must include:

1. **Purpose Statement**: A clear description of the module's function
2. **Interface Definition**: Required functions that each implementation must provide
3. **Expected Behavior**: How the module should behave across different platforms
4. **Platform Requirements**: Specific considerations for different platforms
5. **Examples**: Example code showing usage patterns

## Full Example

Directory structure:
```
00_principles/
  |-- M01/                            # Module directory
      |-- M01.md                      # Module definition
      |-- connection_helpers.R        # Helper functions (uses snake_case)
      |-- sql_query_templates.R       # SQL templates (uses snake_case)
      |-- platforms/                  # Platform implementations
          |-- 01/                     # Amazon platform
          |   |-- M01_P01_00.R        # Amazon implementation
          |-- 06/                     # eBay platform
              |-- M01_P06_00.R        # eBay implementation
```

Module definition file (`M01.md`):
```markdown
---
id: "M01"
title: "External Raw Data Connection"
type: "module"
date_created: "2025-04-09"
date_modified: "2025-04-09"
author: "Claude"
implements:
  - "MP01": "Primitive Terms and Definitions"
  - "MP16": "Modularity"
related_to:
  - "R38": "Platform Numbering Convention"
  - "R39": "Derivation Platform Independence"
  - "R40": "Implementation Naming Convention"
  - "R41": "Folder Structure"
---

# M01: External Raw Data Connection

This module defines standardized methods for connecting to external data sources across different platforms...
```

## Benefits

1. **Semantic Clarity**: Module names clearly communicate their purpose 
2. **Consistent Identification**: Uniform pattern across all modules
3. **Documentation Quality**: Encourages proper documentation through standard structure
4. **Navigability**: Makes finding modules and their implementations easier
5. **Extensibility**: Provides a framework for adding new modules systematically
6. **Cross-Platform Compatibility**: snake_case file naming avoids issues with case-sensitive filesystems
7. **Developer Ergonomics**: Consistent casing reduces cognitive load when navigating the codebase
8. **Balanced Approach**: Leverages Title Case for human readability in documentation and snake_case for system compatibility in files
9. **Clear Distinction**: Maintains clear separation between documentation elements and implementation elements

## Related Rules

This rule builds upon:
- **R40 (Implementation Naming Convention)**: Uses the same prefixing approach
- **R41 (Folder Structure)**: Complements the directory structure requirements

## Implementation Timeline

This naming convention is effective immediately for all new modules. Existing modules should be updated to conform to this standard as part of regular maintenance activities.