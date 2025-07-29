---
id: "R0033"
title: "Recursive Sourcing"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "R0013": "Initialization Sourcing"
  - "P0003": "Debug Principles"
related_to:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
---

# Recursive Sourcing Rule

## Core Requirement

All initialization scripts must recursively source R files from subdirectories to ensure that all components are properly loaded regardless of their directory depth.

## Motivation

Component organization by functionality often leads to nested directory structures. Without recursive sourcing, components in subdirectories may not be loaded during initialization, causing application failures. This rule ensures that the system can properly load all components regardless of their location in the directory hierarchy.

## Implementation Guidelines

### 1. Recursive File Discovery

Initialization scripts must recursively search for R files in all subdirectories:

```r
# Function to recursively discover R files
get_r_files_recursive <- function(dir_path, 
                                 include_pattern = "\\.R$", 
                                 exclude_pattern = NULL,
                                 max_depth = Inf) {
  
  # Check if directory exists
  if (!dir.exists(dir_path)) {
    warning("Directory does not exist: ", dir_path)
    return(character(0))
  }
  
  # Get all files and directories
  all_contents <- list.files(dir_path, full.names = TRUE, recursive = FALSE, 
                             include.dirs = TRUE, all.files = FALSE)
  
  # Split into files and directories
  is_dir <- dir.exists(all_contents)
  files <- all_contents[!is_dir]
  subdirs <- all_contents[is_dir]
  
  # Filter files based on include pattern
  if (!is.null(include_pattern)) {
    files <- files[grepl(include_pattern, basename(files))]
  }
  
  # Filter files based on exclude pattern
  if (!is.null(exclude_pattern)) {
    files <- files[!grepl(exclude_pattern, basename(files))]
  }
  
  # Recursively process subdirectories if not at max depth
  if (length(subdirs) > 0 && max_depth > 1) {
    subdir_files <- lapply(subdirs, function(subdir) {
      get_r_files_recursive(subdir, 
                          include_pattern = include_pattern,
                          exclude_pattern = exclude_pattern,
                          max_depth = max_depth - 1)
    })
    
    # Combine all files
    files <- c(files, unlist(subdir_files))
  }
  
  return(files)
}
```

### 2. Deterministic Loading Order

Files must be loaded in a deterministic order to ensure consistent behavior:

1. **Sort By Path**: Files should be sorted by their full path
2. **Priority Loading**: Consider implementing priority markers in filenames
3. **Dependency Resolution**: When possible, analyze and resolve dependencies

```r
# Sort files for deterministic loading
r_files <- sort(r_files)
```

### 3. Comprehensive Error Handling

Sourcing failures must be properly handled and reported:

```r
# Source a file with error handling
source_with_verbose <- function(file_path, verbose = VERBOSE_INITIALIZATION) {
  if (verbose) {
    message(paste("Sourcing file:", file_path))
  }
  
  result <- tryCatch({
    source(file_path)
    if (verbose) message(paste("Successfully loaded:", file_path))
    TRUE
  }, error = function(e) {
    message(paste("Error loading", file_path, ":", e$message))
    FALSE
  })
  
  return(result)
}
```

### 4. Comprehensive Source Function

A unified function should be used for sourcing files from directories:

```r
# Source all files in a directory and its subdirectories
source_all_files <- function(dir_path, 
                           include_pattern = "^(fn_|ui_|server_|defaults_|.*UI|.*Server|.*Defaults).*\\.R$",
                           exclude_pattern = "(initialization|deinitialization)",
                           verbose = VERBOSE_INITIALIZATION) {
  
  # Get all R files recursively
  r_files <- get_r_files_recursive(dir_path, 
                                 include_pattern = include_pattern,
                                 exclude_pattern = exclude_pattern)
  
  # Sort files to ensure deterministic loading order
  r_files <- sort(r_files)
  
  # Track results
  loaded_files <- character(0)
  failed_files <- character(0)
  
  # Source each file
  if (length(r_files) > 0) {
    if (verbose) {
      message(paste("Found", length(r_files), "files in", dir_path))
    }
    
    for (file in r_files) {
      result <- source_with_verbose(file, verbose)
      
      if (result) {
        loaded_files <- c(loaded_files, file)
      } else {
        failed_files <- c(failed_files, file)
      }
    }
  } else if (verbose) {
    message(paste("No files found in", dir_path, "matching pattern"))
  }
  
  # Return results
  return(list(
    loaded = loaded_files,
    failed = failed_files
  ))
}
```

### 5. Pattern Matching for Components

Two types of patterns must be supported for component discovery:

1. **Standard Naming Patterns**:
   - Files with standard prefixes (e.g., `"^(fn_|ui_|server_|defaults_).*\\.R$"`)
   - Used for general utility functions and standard components

2. **Component-Specific Naming Patterns**:
   - Files with component-specific naming, including:
     - UI components: `".*UI\\.R$"` (e.g., "sidebarHybridUI.R")
     - Server components: `".*Server\\.R$"` (e.g., "microCustomerServer.R")
     - Default configurations: `".*Defaults\\.R$"` (e.g., "sidebarHybridDefaults.R")
   - Used for custom components with consistent naming conventions

3. **Exclude Patterns**:
   - Files to be excluded (e.g., `"(initialization|deinitialization)"`)

The combined pattern should include both standard and component-specific naming:

```r
include_pattern = "^(fn_|ui_|server_|defaults_|.*UI|.*Server|.*Defaults).*\\.R$"
```

These patterns should be consistent across all operating modes.

## Application to Initialization Modes

### APP_MODE Initialization

The APP_MODE initialization script must use recursive sourcing to load all components:

```r
# For each directory in the ordered list
for (dir_name in ordered_directories) {
  dir_path <- file.path(Func_dir, dir_name)
  
  # Check if directory exists
  if (dir.exists(dir_path)) {
    # Source all files recursively
    results <- source_all_files(
      dir_path,
      include_pattern = "^(fn_|ui_|server_|defaults_|.*UI|.*Server|.*Defaults).*\\.R$",
      exclude_pattern = "(initialization|deinitialization)",
      verbose = VERBOSE_INITIALIZATION
    )
    
    # Update tracking
    loaded_files <- c(loaded_files, results$loaded)
    failed_files <- c(failed_files, results$failed)
  }
}
```

### GLOBAL_MODE and UPDATE_MODE

The same recursive sourcing pattern should be applied to GLOBAL_MODE and UPDATE_MODE initialization.

## Directory Organization Best Practices

To work effectively with recursive sourcing:

1. **Logical Grouping**: Organize related components in subdirectories
2. **Depth Limitation**: Avoid excessive nesting (>3-4 levels deep)
3. **Clear Naming**: Use descriptive directory names for easier debugging
4. **Readme Files**: Include README.md in each directory explaining its purpose

Example directory structure:

```
10_rshinyapp_components/
├── README.md
├── charts/
│   ├── README.md
│   ├── ui_barChart.R
│   ├── ui_lineChart.R
│   └── ui_pieChart.R
├── inputs/
│   ├── README.md
│   ├── ui_dateRange.R
│   └── ui_filterInput.R
├── micro/
│   ├── README.md
│   └── microCustomer/
│       ├── microCustomerUI.R
│       ├── microCustomerServer.R
│       └── microCustomerDefaults.R
└── sidebars/
    ├── README.md
    ├── sidebarBasic/
    │   ├── ui_sidebarBasic.R
    │   └── server_sidebarBasic.R
    └── sidebarHybrid/
        ├── sidebarHybridUI.R
        ├── sidebarHybridServer.R
        └── sidebarHybridDefaults.R
```

## Debugging Recursive Sourcing

When debugging sourcing issues:

1. **Enable Verbose Mode**: Set `VERBOSE_INITIALIZATION <- TRUE`
2. **Check Loading Order**: Review the order in which files are being loaded
3. **Inspect Failures**: Examine the list of failed files and their error messages
4. **Verify Patterns**: Confirm that file naming follows the expected patterns

## Relationship to Other Principles

This rule:

1. **Extends R0013 (Initialization Sourcing)**: Adds the requirement for recursive sourcing
2. **Implements P0003 (Debug Principles)**: Improves error reporting for debugging
3. **Supports MP0016 (Modularity)**: Enables better organization by functional grouping
4. **Aligns with MP0017 (Separation of Concerns)**: Allows separation of components into logical subdirectories

## Common Issues and Solutions

| Issue | Solution |
|-------|----------|
| Files not being sourced | Check file naming patterns and ensure they match include patterns |
| Loading order problems | Implement priority prefixes in filenames or explicit dependency management |
| Circular dependencies | Restructure code to eliminate circular references between files |
| Excessive loading time | Limit recursive depth or implement lazy loading for rarely used components |
| Path-related errors | Use platform-neutral path construction (file.path) in all path references |

## Conclusion

Recursive sourcing ensures that all components are properly loaded regardless of their location in the directory hierarchy. By implementing this rule, the system can support more logical organization of components while maintaining reliable initialization across all operating modes.
