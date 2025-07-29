---
id: "R0103"
title: "Dependency-Based Sourcing"
type: "rule"
date_created: "2025-04-15"
author: "Claude"
implements:
  - "MP0031": "Initialization First"
  - "MP0016": "Modularity"
related_to:
  - "R0033": "Recursive Sourcing"
  - "R0056": "Folder-Based Sourcing"
  - "P0055": "N-tuple Independent Loading"
---

# Dependency-Based Sourcing Rule

## Core Concept

File sourcing must support explicit dependency management through code annotations, ensuring files are loaded in the correct order while preventing circular dependencies and redundant loading.

## Motivation

As application complexity grows, simple folder-based or lexical ordering for file sourcing becomes insufficient. Dependencies between components often cut across directory structures, requiring a more sophisticated approach to ensure proper initialization. This rule establishes a dependency annotation system that enables intelligent file loading based on actual dependencies rather than location or naming conventions.

## Implementation Requirements

### 1. Dependency Annotation Format

Files must declare their dependencies using standardized annotation formats at the top of the file:

```r
# Standard roxygen-style annotation
#' @requires path/to/dependency.R

# Alternative comment annotation 
# @requires path/to/dependency.R

# Alternative format with @depends
#' @depends path/to/dependency.R
```

These annotations should appear in the first 30 lines of the file to be properly detected by the sourcing system.

### 2. Enhanced Source Function

The system must implement an enhanced source function (`source_with_verbose`) with the following capabilities:

1. **Dependency Resolution**: Parse and resolve file dependencies before loading
2. **Loading Tracking**: Maintain a registry of already-loaded files to prevent redundant loading
3. **Cycle Detection**: Detect and prevent circular dependencies
4. **Verbose Logging**: Provide detailed logging for debugging
5. **Error Handling**: Gracefully handle loading failures with informative messages

```r
source_with_verbose <- function(file_path, verbose = VERBOSE_INITIALIZATION, max_attempts = 3) {
  # Implementation as per fn_source_with_verbose.R
  # Must track loaded files in global registry
  # Must extract dependencies and load them first
  # Must prevent circular loading and infinite recursion
}
```

### 3. Dependency Discovery

The system must implement robust dependency path resolution that:

1. **Handles Relative Paths**: Locate dependencies relative to the current file
2. **Resolves Ambiguous Names**: Find files across the application when not fully qualified
3. **Respects Application Structure**: Prioritize matches based on application directory hierarchy
4. **Handles File Extensions**: Add `.R` extension automatically when missing

The discovery process should search in these locations, in order:

1. Exact path if provided
2. Same directory as the requesting file
3. Same directory with `.R` extension added
4. Application-defined search directories (typically defined in the ordered_directories list)

### 4. Loading Safeguards

To prevent sourcing issues:

1. **Attempt Limiting**: Limit recursive loading attempts to avoid infinite loops
2. **Global Registry**: Maintain a global registry of loaded files (`LOADED_FILES`)
3. **Attempt Tracking**: Track loading attempts per file to detect problematic dependencies
4. **Warning Mechanism**: Provide clear warnings for unresolved dependencies

### 5. Utility Functions

The system must provide utility functions to:

1. **Get Loaded Files**: Retrieve the list of currently loaded files
   ```r
   get_loaded_files <- function() {
     # Return the registry of loaded files
   }
   ```

2. **Reset Tracking**: Reset the loading registry when needed
   ```r
   reset_source_tracking <- function(clear_loaded = TRUE) {
     # Reset the attempt counter and optionally clear loaded files
   }
   ```

## Usage Guidelines

### Basic Usage

```r
# Source a file with dependency resolution
source_with_verbose("path/to/component.R")

# View currently loaded files
loaded_files <- get_loaded_files()

# Reset tracking (typically before a fresh initialization)
reset_source_tracking()
```

### File Structure

Files should structure their dependencies as follows:

```r
#' @file example_component.R
#' @requires base_utilities.R
#' @requires data_functions.R
#' @depends component_shared.R
#'
#' # Component implementation follows...
```

### Initialization Integration

In the application initialization:

```r
# Set verbose mode during development
VERBOSE_INITIALIZATION <- TRUE

# Reset tracking at the start of initialization
reset_source_tracking(clear_loaded = TRUE)

# Source core components with dependency resolution
source_with_verbose("app/initialization/core_components.R")
```

## Debugging Tips

1. **Enable Verbose Mode**: Set `VERBOSE_INITIALIZATION <- TRUE` to see detailed loading logs
2. **Inspect Loaded Files**: Use `get_loaded_files()` to see what has already been loaded
3. **Check for Circular Dependencies**: If loading stops at `max_attempts`, look for circular references
4. **Verify Annotations**: Ensure dependency annotations are within the first 30 lines of each file
5. **Check Path Validity**: Ensure dependency paths are valid and resolvable

## Benefits

1. **Order Independence**: Files can be placed anywhere in the directory structure
2. **Self-Documenting**: Dependencies are explicitly declared in the files that need them
3. **Error Prevention**: Prevents the most common initialization errors due to missing dependencies
4. **Optimization**: Prevents redundant loading of files that are needed in multiple places
5. **Maintainability**: Makes dependency relationships explicit and visible

## Relationship to Other Principles

This rule:

1. **Implements MP0031 (Initialization First)**: Ensures proper initialization sequencing
2. **Implements MP0016 (Modularity)**: Supports creating truly modular components with explicit dependencies
3. **Extends R0033 (Recursive Sourcing)**: Adds dependency-aware sourcing to recursive file discovery
4. **Complements R0056 (Folder-Based Sourcing)**: Provides fine-grained dependency management while preserving folder-based organization
5. **Supports P0055 (N-tuple Independent Loading)**: Enables independent loading of component n-tuples

## Example Implementation

See `fn_source_with_verbose.R` in the `04_utils` directory for the reference implementation of this rule.

## Conclusion

Dependency-based sourcing creates a self-organizing loading system where files declare their own dependencies, eliminating the need for manual ordering or complex directory structures solely for loading purposes. This enables more flexible code organization while maintaining reliable initialization.