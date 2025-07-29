---
id: "R21"
title: "One Main Function, One File Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-10"
author: "Claude"
implements:
  - "MP17": "Separation of Concerns"
  - "MP18": "Don't Repeat Yourself"
related_to:
  - "P01": "Script Separation"
---

# One Main Function, One File Rule

## Core Requirement

Each main function in the precision marketing system should be defined in its own dedicated file, with the filename matching the function name. Auxiliary functions that support the main function may be defined in the same file. Collection modules may use a main file to source all related function files and provide a unified interface.

## Implementation Guidelines

### 1. File Naming and Structure

For main functions:
- The file should be named exactly after the main function it contains
- Example: Main function `get_sales_data()` should be in file `get_sales_data.R`
- Auxiliary functions that support this main function may be defined in the same file

For utility collections:
- Create a directory for the collection (e.g., `object_id`)
- Place a main file at the root of the directory (e.g., `object_identification.R`)
- Create a `functions` subdirectory containing individual function files
- The main file should source all individual function files

### 2. Function Organization Patterns

Two primary organization patterns are supported for structuring function files:

#### Top-Down Organization (Main Function First)

This organization starts with the main function followed by auxiliary functions. It provides a clear entry point at the beginning of the file:

```r
#' Main Function Description
#'
#' Detailed description of what the main function does.
#'
#' @param param1 Description of first parameter
#' @param param2 Description of second parameter
#' @return Description of return value
#' @examples
#' example_usage()
#'
main_function_name <- function(param1, param2) {
  # Implementation that calls auxiliary functions
  result <- auxiliary_function_name(param1)
  return(process_result(result, param2))
}

#' Auxiliary Function Description
#'
#' Description of what this auxiliary function does.
#' Auxiliary functions should only be used by the main function
#' or other auxiliary functions in this file.
#'
#' @param param1 Description of first parameter
#' @return Description of return value
#'
auxiliary_function_name <- function(param1) {
  # Implementation of auxiliary functionality
}

#' Process Result Function
#'
#' Another auxiliary function that processes results.
#'
#' @param result Result from auxiliary function
#' @param param2 Additional parameter
#' @return Processed result
#'
process_result <- function(result, param2) {
  # Implementation
}
```

#### Bottom-Up Organization (Auxiliary Functions First)

This organization defines auxiliary functions before the main function, following the "initialization first" pattern common in functional programming. This pattern naturally builds from simple building blocks to the composed solution:

```r
#' Auxiliary Function Description
#'
#' Description of what this auxiliary function does.
#' Auxiliary functions should only be used by the main function
#' or other auxiliary functions in this file.
#'
#' @param param1 Description of first parameter
#' @return Description of return value
#'
auxiliary_function_name <- function(param1) {
  # Implementation of auxiliary functionality
}

#' Process Result Function
#'
#' Another auxiliary function that processes results.
#'
#' @param result Result from auxiliary function
#' @param param2 Additional parameter
#' @return Processed result
#'
process_result <- function(result, param2) {
  # Implementation
}

#' Main Function Description
#'
#' Detailed description of what the main function does.
#' By placing it last, all its dependencies are already defined.
#'
#' @param param1 Description of first parameter
#' @param param2 Description of second parameter
#' @return Description of return value
#' @examples
#' example_usage()
#'
main_function_name <- function(param1, param2) {
  # Implementation that calls auxiliary functions
  result <- auxiliary_function_name(param1)
  return(process_result(result, param2))
}
```

Either organization pattern is acceptable, but should be used consistently within a project. The bottom-up approach is often preferred for functional programming patterns as it follows the natural dependency order, while top-down may be more suitable for procedural code or when the main function serves as a clear entry point.

### 3. Required Structure for Collection Main Files

Main files for collections should follow this structure:

```r
#' Collection Name - Main Module
#'
#' This file serves as the main entry point for the collection.
#' It sources all individual function files to make them available.
#'
#' @author Author Name
#' @date Date

# Source all function files
function_dir <- "functions"
function_files <- list.files(function_dir, pattern = "\\.R$", full.names = TRUE)

for (file in function_files) {
  source(file)
}
```

### 4. Documentation Requirements

Each function file must include:
- Function description
- Parameter descriptions
- Return value description
- At least one usage example
- Any other relevant documentation (dependencies, side effects, etc.)

## Guidelines for Main and Auxiliary Functions

### Main Functions

A **main function** is one that:
1. Provides the primary capability of the file
2. Is intended to be called from external code
3. Serves as the primary entry point for the file's functionality
4. Is typically exported or made available in the public API
5. Has its name matching the file name

### Auxiliary Functions

An **auxiliary function** is one that:
1. Supports the operation of a main function
2. Is typically only called by the main function or other auxiliary functions within the same file
3. Implements a sub-task of the main function
4. Is usually not exported or exposed as part of the public API
5. Should be well-documented within the file

## Exceptions

The following exceptions to the one-main-function-one-file rule are permitted:

1. **Sibling Functions**: A set of closely related functions that form a coherent API but don't have a clear "main" function may be defined in a single file with a descriptive name.

2. **Generated Functions**: Functions generated programmatically (e.g., by metaprogramming) are exempt.

3. **Legacy Code**: Existing legacy code may be gradually refactored to comply with this rule over time.

4. **Test Functions**: Test functions for a main function may be placed in a separate test file.

## Benefits

1. **Improved Maintainability**: Each function can be maintained independently
2. **Better Version Control**: Changes to functions are clearly tracked
3. **Easier Testing**: Functions can be tested in isolation
4. **Better Organization**: Project structure clearly reflects functionality
5. **Enhanced Reusability**: Single-purpose files are easier to reuse
6. **Reduced Merge Conflicts**: Developers are less likely to conflict when editing different functions
7. **Focused Code Reviews**: Reviews can focus on specific functionality

## Examples

### Example 1: Single Function File

File: `calculate_revenue.R`
```r
#' Calculate Revenue
#'
#' Calculates total revenue from sales data.
#'
#' @param sales_data Data frame containing sales records
#' @param include_tax Boolean indicating whether to include tax in calculation
#' @return Numeric value representing total revenue
#' @examples
#' calculate_revenue(sales_df, include_tax = TRUE)
#'
calculate_revenue <- function(sales_data, include_tax = FALSE) {
  if (include_tax) {
    return(sum(sales_data$amount * (1 + sales_data$tax_rate), na.rm = TRUE))
  } else {
    return(sum(sales_data$amount, na.rm = TRUE))
  }
}
```

### Example 2: Collection Structure

Directory: `object_id/`
- `object_identification.R` (main file)
- `functions/`
  - `get_rigid_id.R`
  - `get_descriptors.R`
  - `load_latest.R`
  - `load_version.R`
  - `list_versions.R`
  - `save_version.R`

Main file: `object_identification.R`
```r
#' Object Identification Utilities - Main Module
#'
#' This file serves as the main entry point for the object identification utilities.
#' It sources all individual function files to make them available.
#'
#' @author Developer Name
#' @date 2025-04-04

# Source all function files
function_dir <- "functions"
function_files <- list.files(function_dir, pattern = "\\.R$", full.names = TRUE)

for (file in function_files) {
  source(file)
}
```

## Implementation Strategy

1. **New Functions**: All new functions should immediately follow this rule
2. **Existing Code**: Gradually refactor existing code as it is modified
3. **Documentation**: Update documentation to reflect this organization pattern
4. **Testing**: Ensure each function file has corresponding tests

## Relation to Other Principles

This rule implements:

1. **MP17 (Separation of Concerns)**: By isolating each function, concerns are naturally separated
2. **MP18 (Don't Repeat Yourself)**: Functions in individual files are easier to reuse without duplication

This rule relates to:

1. **P01 (Script Separation)**: Extends the concept of separation to the function level

## Conclusion

The One Function, One File Rule creates a clear, organized code structure that enhances maintainability, testability, and collaboration. By giving each function its dedicated space, we improve the overall quality and structure of the codebase while making it easier for developers to work with the system.
