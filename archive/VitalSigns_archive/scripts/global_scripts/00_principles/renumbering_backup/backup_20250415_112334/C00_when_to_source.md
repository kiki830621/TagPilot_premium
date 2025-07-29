# C00: When to Source Components

## Overview
This concept document provides guidance on when, where, and how to source components in the application lifecycle, connecting various related principles and rules.

## Core Principle
All component sourcing should occur during initialization following MP31 (Initialization First), using folder-based sourcing per R56, with independent aspect-based loading per P55.

## Decision Tree

### WHEN to source:
1. **Initialization Phase ONLY** - MP31 (Initialization First)
   - Components should be sourced during the application initialization phase
   - Runtime sourcing is prohibited
   - Dynamic loading should be handled through initialization-time configurations

2. **Ordered by Aspect** - P55 (N-tuple Independent Loading)
   - UI components first
   - Server components second
   - Filters components third
   - Defaults components fourth

### HOW to source:
1. **By Folder, Not File** - R56 (Folder-Based Sourcing)
   - Source entire directories rather than individual files
   - Use pattern matching to target specific component types
   - Define sourcing functions once in initialization scripts

2. **Organized by Component** - R54 (Component Folder Organization)
   - Each component should have its own folder
   - All aspects of a component should be in the same folder
   - Folder names should match component names

### WHERE to define sourcing:
1. **Initialization Scripts**
   - All sourcing logic belongs in `sc_initialization_*.R` scripts
   - Application code should never contain source() calls
   - Component usage is separate from component loading

2. **Environment-Specific Loading**
   - APP_MODE: Load stable components and interfaces only
   - UPDATE_MODE: Load all components including experimental ones
   - Always document which components are loaded in each mode

## Implementation Pattern

```r
# In initialization script:

# 1. Define sourcing function
source_component_directory <- function(dir_path, pattern, recursive = TRUE) {
  files <- list.files(path = dir_path, pattern = pattern, 
                     full.names = TRUE, recursive = recursive)
  files <- sort(files)  # Ensure consistent order
  lapply(files, source)
  invisible(length(files))
}

# 2. Define component directory
components_dir <- file.path(APP_DIR, "components")

# 3. Source by aspect type (P55)
source_component_directory(components_dir, pattern = "UI\\.R$")
source_component_directory(components_dir, pattern = "Server\\.R$")
source_component_directory(components_dir, pattern = "Filters\\.R$")
source_component_directory(components_dir, pattern = "Defaults\\.R$")
```

## Common Anti-patterns to Avoid

1. **Runtime Sourcing**
   ```r
   # BAD: Sourcing at runtime
   observeEvent(input$load_module, {
     source("components/newModule/newModuleUI.R")
   })
   ```

2. **Individual File Sourcing**
   ```r
   # BAD: Sourcing individual files
   source("components/sidebar/marketingChannelUI.R")
   source("components/sidebar/marketingChannelServer.R")
   ```

3. **Component-based (not aspect-based) Sourcing**
   ```r
   # BAD: Sourcing all aspects of one component before moving to next
   source_all_in_directory("components/sidebar")
   source_all_in_directory("components/dataTable")
   ```

## Related Principles
- MP31: Initialization First
- P55: N-tuple Independent Loading
- R56: Folder-Based Sourcing
- R54: Component Folder Organization
- MP17: Separation of Concerns
- R33: Recursive Sourcing