---
id: "R22"
title: "App Mode Naming Simplicity Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "P04": "App Construction Principles"
  - "P12": "App R is Global"
related_to:
  - "R23": "Object Naming Convention"
  - "MP03": "Operating Modes"
---

# App Mode Naming Simplicity Rule

## Core Requirement

In APP_MODE, all data objects must use only rigid identifiers without optional descriptors. This ensures consistency, predictability, and eliminates ambiguity in the application runtime environment.

## Detailed Requirements

### 1. No Optional Descriptors in APP_MODE

```
# In APP_MODE:
# ALLOWED:
df.amazon.sales_data.by_item_index.at_ALL.at_now.at_001

# NOT ALLOWED:
df.amazon.sales_data.by_item_index.at_ALL.at_now.at_001___clean
```

In APP_MODE, all data objects must be referenced by their rigid identifier only, without any optional descriptors after triple underscores. This applies to all object types that support optional descriptors in the naming convention.

### 2. Canonical Version Selection

When transitioning objects from UPDATE_MODE to APP_MODE, a canonical version must be selected from among the potentially multiple versions with different descriptors. This selection process must:

1. Be deterministic (always select the same version given the same inputs)
2. Be documented and consistent across all components
3. Typically prefer:
   - Manually edited versions (`___manual`) when available
   - Fully processed versions (`___clean`) when no manual version exists
   - Latest versions when no clear qualitative distinction exists

### 3. Loading Functions for APP_MODE

Loading functions in APP_MODE must be simplified to use only rigid identifiers:

```r
# APP_MODE loading function
load_app_data <- function(rigid_id) {
  # Always loads the canonical version without needing descriptors
  return(data)
}
```

### 4. Implementation Mechanisms

Two approaches are allowed for implementing this rule:

#### 4.1. Pre-processing Approach

Before APP_MODE initialization, process all data objects to create canonical versions without optional descriptors:

```r
# During transition from UPDATE_MODE to APP_MODE
canonicalize_data <- function(rigid_id) {
  # Find best version based on prioritization rules
  best_version <- select_canonical_version(rigid_id)
  
  # Load that version
  data <- load_version(rigid_id, best_version)
  
  # Save as canonical version (no descriptor)
  assign(rigid_id, data)
  
  # Optionally persist to disk
  saveRDS(data, paste0(rigid_id, ".rds"))
}
```

#### 4.2. Aliasing Approach

Create aliases in APP_MODE environment that point to the canonical versions:

```r
# During APP_MODE initialization
create_canonical_aliases <- function() {
  for (rigid_id in get_all_rigid_ids()) {
    best_version <- select_canonical_version(rigid_id)
    full_name <- if (best_version == "") rigid_id else paste0(rigid_id, "___", best_version)
    
    # Create alias in APP_MODE environment
    if (exists(full_name)) {
      assign(rigid_id, get(full_name), envir = app_env)
    }
  }
}
```

## Benefits

1. **Simplicity**: Simplifies data access patterns in APP_MODE
2. **Reliability**: Eliminates ambiguity about which version is used
3. **Performance**: Reduces lookup overhead in data loading functions
4. **Clarity**: Makes application code cleaner and more maintainable
5. **Error Prevention**: Prevents accidental use of non-canonical data versions

## Relation to Other Principles

This rule implements:

1. **P04 (App Construction Principles)**: By ensuring consistent and predictable data access patterns
2. **P12 (App R is Global)**: By standardizing naming in APP_MODE global namespace

This rule relates to:

1. **R23 (Object Naming Convention)**: By restricting its full application in APP_MODE
2. **MP03 (Operating Modes)**: By defining specific data object handling for APP_MODE

## Examples

### Example 1: APP_MODE Data Preparation

```r
# During transition to APP_MODE
prepare_app_data <- function() {
  # For each data object required by the app
  required_data <- c(
    "df.amazon.sales_data.by_item_index.at_ALL.at_now.at_001",
    "df.sales.transactions.by_customer.at_NY.at_q1_2025.at_000"
  )
  
  for (rigid_id in required_data) {
    # Get canonical version
    canonicalize_data(rigid_id)
  }
}
```

### Example 2: APP_MODE Data Access

```r
# In APP_MODE
render_sales_dashboard <- function() {
  # Access by rigid_id only
  sales_data <- df.amazon.sales_data.by_item_index.at_ALL.at_now.at_001
  
  # Process and visualize
  plot_sales(sales_data)
}
```

## Conclusion

The App Mode Naming Simplicity Rule ensures a clean, unambiguous data namespace in the application runtime environment. By removing optional descriptors in APP_MODE, this rule simplifies code, improves reliability, and creates a clear separation between the flexible, version-rich development environment (UPDATE_MODE) and the streamlined, deterministic production environment (APP_MODE).
