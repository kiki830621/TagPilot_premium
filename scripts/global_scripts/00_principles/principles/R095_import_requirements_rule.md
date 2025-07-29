---
id: "R0095"
title: "Import Requirements Rule"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Development Team"
extends:
  - "MP0017": "Separation of Concerns"
  - "MP0018": "Don't Repeat Yourself"
  - "MP0031": "Initialization First"
aliases:
  - Package Import Rule
  - Library Declaration Rule
  - Centralized Package Management
key_terms:
  - dependency management
  - package import
  - library declaration
  - initialization-based imports
---

# R0095: Import Requirements Rule

## Core Statement

All package dependencies must be imported through centralized initialization scripts rather than directly in individual script files. When direct imports are unavoidable, they must follow a standardized format.

## Rationale

Centralizing package imports in initialization scripts increases code maintainability by:

1. Providing a single source of truth for all package dependencies
2. Eliminating redundant imports across multiple files
3. Ensuring consistent package versions across the application
4. Facilitating automated dependency analysis and management
5. Simplifying onboarding for new developers by clearly documenting all dependencies
6. Enabling more robust error handling and fallback mechanisms

## Implementation

To implement this rule:

1. Create centralized initialization scripts (e.g., `initialize_packages.R`) that import all required packages
2. Source these initialization scripts at the start of application execution
3. Organize packages by functional area within initialization scripts
4. Implement error handling and version checking in centralized location
5. When direct imports are necessary, follow standardized format

### Example: Initialization Script Implementation

```r
#' @file initialize_packages.R
#' @principle R0095 Import Requirements Rule
#' @author Data Team
#' @date 2025-04-10

# !! CENTRALIZED PACKAGE MANAGEMENT !!

# Core packages
required_core <- c("shiny", "dplyr", "tidyr", "ggplot2")

# Database packages
required_db <- c("DBI", "RSQLite", "duckdb")

# Optional visualization packages
optional_viz <- c("plotly", "leaflet", "DT")

# Import and check core packages (must have these)
missing_core <- required_core[!sapply(required_core, requireNamespace, quietly = TRUE)]
if (length(missing_core) > 0) {
  stop("Missing required core packages: ", paste(missing_core, collapse = ", "))
}
invisible(sapply(required_core, library, character.only = TRUE))

# Import database packages with version checking
for (pkg in required_db) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Installing required database package: ", pkg)
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
}

# Import optional packages if available
available_viz <- optional_viz[sapply(optional_viz, requireNamespace, quietly = TRUE)]
if (length(available_viz) > 0) {
  invisible(sapply(available_viz, library, character.only = TRUE))
}

# Export a list of available packages for other scripts to reference
AVAILABLE_PACKAGES <- list(
  core = required_core,
  db = required_db,
  viz = available_viz
)
```

### Example: Application Script Using Initialization

```r
#' @file app.R
#' @principle R0095 Import Requirements Rule
#' @author Data Team
#' @date 2025-04-10

# Source the initialization script that loads all packages
source("initialize_packages.R")

# No direct library() calls needed here since packages are loaded via initialization

# Function definitions begin here
...
```

### Example: Direct Import When Necessary

In rare cases when direct imports are required:

```r
#' @file specialized_analysis.R
#' @principle R0095 Import Requirements Rule
#' @author Analytics Team
#' @date 2025-04-10

# Check if already loaded via initialization
if (!exists("AVAILABLE_PACKAGES") || !("randomForest" %in% unlist(AVAILABLE_PACKAGES))) {
  # !! DIRECT PACKAGE IMPORT - REQUIRED FOR STANDALONE EXECUTION !!
  if (!requireNamespace("randomForest", quietly = TRUE)) {
    install.packages("randomForest")
  }
  library(randomForest)
}

# Function definitions begin here
...
```

## Integration with NSQL

This rule complements NSQL's structured documentation approach by:

1. Using the special attention notation `!! CENTRALIZED PACKAGE MANAGEMENT !!` that visually stands out
2. Supporting the hierarchical file organization principles of NSQL
3. Reinforcing the initialization-first approach (MP0031) of application structure

## Exceptions

Exceptions to this rule are limited to:

1. Scripts designed for standalone execution outside the main application
2. Testing scripts that intentionally test behavior with different package combinations
3. Scripts with specialized package requirements that aren't used elsewhere

In these exceptional cases, direct imports must:
- Include explicit documentation of why centralized imports aren't used
- Follow the standardized format for direct imports
- Check if packages are already loaded before importing

## Relationship to Other Rules

R0095 builds upon:

- **MP0017 (Separation of Concerns)**: By separating dependency management from functional code
- **MP0018 (Don't Repeat Yourself)**: By eliminating redundant imports across multiple files
- **MP0031 (Initialization First)**: By moving package management to initialization phase
- **R0013 (Initialization Sourcing)**: By organizing imports within the initialization framework

## Benefits

Following this rule provides:

1. **Single source of truth**: Package dependencies defined in one place
2. **Easier maintenance**: Update dependencies in one location
3. **Better error handling**: Centralized error handling for missing dependencies
4. **Reduced startup time**: Only load packages once at initialization
5. **Enhanced compatibility**: Consistent package versions across application
6. **Clearer dependency documentation**: All required packages visible in one place

## Implementation Checklist

- [ ] Create centralized initialization scripts for package imports
- [ ] Group packages by functional area in initialization scripts
- [ ] Implement error handling for missing or incompatible packages
- [ ] Source initialization scripts at application startup
- [ ] Remove direct library() calls from individual scripts
- [ ] Document exceptional cases where direct imports are necessary
