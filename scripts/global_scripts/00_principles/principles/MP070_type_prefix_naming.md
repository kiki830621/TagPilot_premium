---
id: "MP070"
title: "Type-Prefix Naming Meta-Principle"
type: "meta-principle"
date_created: "2025-04-16"
date_modified: "2025-04-16"
author: "Claude"
related_to:
  - "MP068": "Language as Index Meta-Principle"
  - "R001": "File Naming Convention"
  - "R019": "Object Naming Convention"
---

# MP070: TYPE-PREFIX NAMING META-PRINCIPLE

## Summary

The Type-Prefix Naming Meta-Principle establishes that names of code entities should include a standardized prefix that identifies their type and purpose. This creates immediate visual distinction between different categories of code elements and makes the codebase more navigable, self-documenting, and maintainable.

## Principles

1. **Type Visibility**: The type or purpose of code elements should be immediately visible in their names.

2. **Consistent Prefixing**: Standard prefixes should be used for all code elements of the same type.

3. **Semantic Separation**: Functions (behavior) and objects (data) should be clearly distinguished through naming.

4. **Hierarchical Organization**: Names should support natural organization in file browsers and search tools.

5. **Self-Documentation**: Names should function as documentation, indicating both purpose and type.

## Application

In the Precision Marketing system, this meta-principle is applied through a system of type-based prefixes:

1. **Function Prefixing**: Functions use the `fn_` prefix (e.g., `fn_create_table`, `fn_transform_data`).

2. **Script Prefixing**: Scripts use the `sc_` prefix (e.g., `sc_initialization_update_mode`, `sc_import_data`).

3. **Data Structure Prefixing**: Data objects use type-specific prefixes:
   - `df_` for data frames (e.g., `df_customer_data`)
   - `tbl_` for database tables (e.g., `tbl_sales`)
   - `lst_` for lists (e.g., `lst_parameters`)
   - `vec_` for vectors (e.g., `vec_customer_ids`)
   - `con_` for connections (e.g., `con_app_data`)

4. **Testing Prefixing**: Test files use the `test_` prefix (e.g., `test_create_table`, `test_data_import`).

5. **Principle Prefixing**: Principle documents use specific prefixes:
   - `MP` for meta-principles (e.g., `MP070_type_prefix_naming`)
   - `R` for rules (e.g., `R092_universal_dbi_approach`)
   - `D` for derivations (e.g., `D00_create_app_data_frames`)

## Implementation

The implementation of this meta-principle includes:

1. Consistent use of prefixes in all file and object names.

2. Documentation of naming conventions in the `naming_convention_syntax.md` file.

3. Type checking to ensure variables match their implied types.

4. Refactoring tools to bring existing code into compliance.

5. Code reviews that enforce the naming conventions.

## Benefits

1. **Enhanced Readability**: Names explicitly indicate both purpose and type.

2. **Reduced Cognitive Load**: Developers can focus on the meaning of code without inferring types.

3. **Improved Navigation**: Type-based prefixes enable efficient filtering in IDEs and file browsers.

4. **Error Reduction**: Mismatched types become immediately apparent through naming violations.

5. **Self-Documenting Code**: Names serve as documentation, reducing the need for explicit type annotations.

## Examples

### Function Definition

```r
#' @file fn_transform_customer_data.R
fn_transform_customer_data <- function(data_df, rules_lst) {
  # Implementation...
}
```

### Object Usage

```r
df_customer_data <- read.csv("customers.csv")
vec_customer_ids <- df_customer_data$customer_id
result_df <- fn_transform_customer_data(df_customer_data, rules_lst)
```

### Script Naming

```
sc_initialization_update_mode.R
sc_import_data.R
sc_generate_reports.R
```

## Related Principles

- **MP068: Language as Index Meta-Principle** - Names serve as an index to functionality
- **R001: File Naming Convention** - Broader file naming rules
- **R019: Object Naming Convention** - Broader object naming rules