---
id: "R23"
title: "Object File Name Translation"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
implements:
  - "R23": "Object Naming Convention"
  - "R25": "One Function, One File Rule"
related_to:
  - "P14": "Dot Notation Property Access Principle"
  - "R01": "File Naming Convention"
---

# Object File Name Translation

## Core Requirement

When translating object names (as defined in R23) to filenames, dots (.) in object names must be converted to underscores (_) to ensure compatibility with filesystem conventions, while preserving the hierarchical structure and meaning of the object identifier.

## Translation Rules

### 1. Basic Translation Pattern

```
object_name = type.purpose[___identifier]
filename = fn_type_purpose.ext  # For functions
filename = type_purpose.ext     # For other objects
```

Where:
- All dots (.) in the object name are converted to underscores (_) in the filename
- The optional identifier (after the triple underscore `___`) is omitted from the filename
- An appropriate file extension (.R, .py, etc.) is added based on the language

### 2. Examples of Translations

| Object Name | Filename |
|-------------|----------|
| dt.calculate_sales | fn_dt_calculate_sales.R |
| mdl.regression.sales | mdl_regression_sales.R |
| comp.ui.customer | comp_ui_customer.R |
| df.amazon.sales_data.by_item_index.at_ALL.at_now.at_001___clean | df_amazon_sales_data_by_item_index_at_ALL_at_now_at_001.R |

### 3. Handling Underscores in Object Names

When underscores already exist in object names (e.g., to separate words within a component), these underscores are preserved in the filename. This means that underscores in filenames may correspond to either:
- Dots (.) in object names (separating components)
- Underscores (_) in object names (separating words within components)

For example:
- Object: `fn.process.customer_data.remove_duplicates`
- Filename: `fn_process_customer_data_remove_duplicates.R`

### 4. Identifiers Exclusion

The optional identifier part (after the triple underscore `___`) in object names is NOT included in the filename, as it represents a state or variation of the same underlying object rather than a distinct entity.

For example:
- Object: `df.sales.transactions.by_customer.at_CA.at_q1_2025.at_000___agg`
- Filename: `df_sales_transactions_by_customer_at_CA_at_q1_2025_at_000.R`

## Implementation Requirements

### 1. Translation Functions

Create standardized utility functions for bidirectional translation:
- `object_name_to_filename(object_name, extension = ".R")` - Converts an object name to a filename
- `filename_to_object_name(filename)` - Converts a filename to its corresponding object name

### 2. Consistent Application

- All object-handling functions must use these translation functions
- File operations should reference objects by their object names and perform translation internally
- Document all cases where a filename does not follow this translation rule

### 3. IDE Integration

Integrate with IDE tools to support:
- Automatic file creation with properly translated names
- Navigation between object references and their corresponding files
- Refactoring support for consistent renaming

## Examples

### Example 1: Function Definition and File Creation

```r
# Object name as defined in code
calc.revenue <- function(sales_data, date_range, by_product = TRUE) {
  # Function implementation
}

# Save to appropriately named file
save_function_to_file(calc.revenue, "functions/")
# Creates: functions/fn_calc_revenue.R
```

### Example 2: Loading Objects from Files

```r
# Load a function from a file based on object name
calc.revenue <- load_function("calc.revenue")
# Internally translates to: load_function_from_file("functions/fn_calc_revenue.R")
```

### Example 3: Translation Functions Implementation

```r
object_name_to_filename <- function(object_name, extension = ".R") {
  # Extract the main part (before any triple underscore)
  main_part <- strsplit(object_name, "___")[[1]][1]
  
  # Replace dots with underscores
  filename <- gsub("\\.", "_", main_part)
  
  # Add extension
  paste0(filename, extension)
}

filename_to_object_name <- function(filename) {
  # Remove extension
  base_name <- tools::file_path_sans_ext(filename)
  
  # This is an approximate reverse mapping
  # Note: Cannot perfectly reconstruct original if there were underscores in components
  object_name_candidate <- gsub("_", ".", base_name)
  
  # Additional validation could be implemented here
  
  return(object_name_candidate)
}
```

## Benefits

1. **Filesystem Compatibility**: Ensures object names work with filesystem restrictions
2. **Hierarchical Preservation**: Maintains the hierarchical structure from object names
3. **Consistent Access**: Provides consistent access patterns between code and files
4. **Automated Management**: Enables automated file management based on object references
5. **Clear Associations**: Makes the relationship between objects and files explicit

## Relationship to Other Rules

### Relation to Object Naming Convention (R23)

This rule extends R23 by:
1. **Filesystem Translation**: Providing a filesystem-compatible representation of object names
2. **Preserving Hierarchy**: Maintaining the hierarchical components defined in R23
3. **Handling Identifiers**: Specifying how the optional identifier part is handled

### Relation to One Function, One File Rule (R25)

This rule supports R25 by:
1. **Standardized Mapping**: Creating a standardized way to map function names to filenames
2. **Consistent Organization**: Ensuring consistent organization of function files
3. **Namespace Support**: Supporting namespaced functions through the hierarchical naming

### Relation to Dot Notation Property Access Principle (P14)

This rule supports P14 by:
1. **Consistent Access**: Maintaining a consistent notation between code and filesystem
2. **Mapping Strategy**: Providing a clear mapping between notation styles

### Relation to File Naming Convention (R01)

This rule extends R01 by:
1. **Specific Pattern**: Providing a specific pattern for object-related files
2. **Consistency**: Ensuring consistent handling of different object types

## Conclusion

The Object File Name Translation rule establishes a clear, consistent approach for converting between object names (with dot notation) and filenames (with underscore notation), ensuring compatibility with filesystem conventions while preserving the hierarchical structure and meaning established in the Object Naming Convention (R23). By defining specific translation rules and providing utility functions, this rule enables seamless integration between code references and file operations, supporting the One Function, One File Rule (R25) and maintaining consistency throughout the system.
