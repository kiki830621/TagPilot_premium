---
id: "R37"
title: "Two-Tier Directory Structure"
type: "rule"
date_created: "2025-04-05"
date_modified: "2025-04-05"
author: "Claude"
implements:
  - "MP02": "Structural Blueprint"
  - "P00": "Project Principles"
related_to:
  - "R03": "Platform-Neutral Code"
  - "R13": "Initialization Sourcing"
  - "R04": "App YAML Configuration"
---

# Two-Tier Directory Structure Rule

This rule establishes a standardized two-tier directory structure for path organization, enabling consistent path references regardless of execution environment or platform.

## Core Concept

All projects must follow a consistent two-tier directory structure where:

1. **APP_DIR**: Current working directory (`getwd()`) - Contains application-specific files and directories
2. **ROOT_DIR**: Parent directory of APP_DIR (`dirname(getwd())`) - Contains shared resources and sibling projects

This structure ensures consistent path references and simplifies project organization.

## Rationale

A standardized two-tier directory structure provides:

1. **Consistent organization** across all projects in an organization
2. **Predictable relationships** between application and shared resources
3. **Simplified deployment** across different environments
4. **Cross-project resource sharing** without complex path resolution
5. **Platform neutrality** that works identically on Windows, macOS, and Linux
6. **Clear separation** between application-specific and shared resources

This approach establishes a clear convention that eliminates ambiguity and reduces the need for environment-specific path handling.

## Implementation Guidelines

### 1. Path Declaration

Declare and initialize path variables at the beginning of initialization:

```r
# Path initialization - establishes two-tier structure
detect_paths <- function() {
  # Get the current working directory (APP_DIR)
  app_dir <- getwd()
  
  # Get the parent directory (ROOT_DIR)
  root_dir <- dirname(app_dir)
  
  return(list(
    APP_DIR = app_dir,
    ROOT_DIR = root_dir
  ))
}

# Set path variables globally
paths <- detect_paths()
APP_DIR <- paths$APP_DIR
ROOT_DIR <- paths$ROOT_DIR

# For backward compatibility
ROOT_PATH <- APP_DIR
```

### 2. Directory Organization

Follow a consistent organization pattern within APP_DIR:

```
APP_DIR/
├── app_data/           # Application-specific data
├── app_configs/        # Configuration files
├── logs/               # Application logs
└── update_scripts/     # Update scripts
    └── global_scripts/ # Shared scripts
```

And within ROOT_DIR:

```
ROOT_DIR/
├── precision_marketing_WISER/     # Current application
├── precision_marketing_ACME/      # Sibling application 
├── precision_marketing_FOO/       # Another sibling application
└── shared_resources/             # Resources shared across applications
```

### 3. Path References

Always use the appropriate path variable for constructing paths:

```r
# CORRECT: App-specific path references
app_config_path <- file.path(APP_DIR, "app_configs", "config.yaml")
app_data_path <- file.path(APP_DIR, "app_data", "processed_data")

# CORRECT: References to shared or sibling resources
sibling_app_path <- file.path(ROOT_DIR, "precision_marketing_ACME")
shared_resource_path <- file.path(ROOT_DIR, "shared_resources")

# CORRECT: Path to another application using two-tier structure
other_app_path <- get_company_path("ACME")
```

### 4. Database Paths

Configure database paths based on the two-tier structure:

```r
# CORRECT: Application database paths
db_path_list <- list(
  app_data = file.path(APP_DIR, "app_data", "app_data.duckdb"),
  processed_data = file.path(APP_DIR, "app_data", "processed_data.duckdb")
)

# CORRECT: Global database path
global_db_path <- file.path(APP_DIR, "update_scripts", "global_scripts", "global_data", "global_scd_type1.duckdb")
```

## Common Pitfalls

### 1. Hard-coded Absolute Paths

```r
# INCORRECT: Hard-coded absolute path
data_path <- "C:/Users/username/precision_marketing/data"

# CORRECT: Using APP_DIR
data_path <- file.path(APP_DIR, "data")
```

### 2. Inconsistent Directory Structure

```r
# INCORRECT: Inconsistent organization
logs_dir <- file.path(APP_DIR, "logs")
data_dir <- file.path(ROOT_DIR, "precision_marketing_WISER", "data")  # Redundant nesting

# CORRECT: Consistent organization
logs_dir <- file.path(APP_DIR, "logs")
data_dir <- file.path(APP_DIR, "data")
```

### 3. Direct Directory Creation

```r
# INCORRECT: Creating directories without checking existence
dir.create(file.path(APP_DIR, "data"))

# CORRECT: Check existence first
data_dir <- file.path(APP_DIR, "data")
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}
```

## Special Considerations

### 1. Migration from Legacy Structure

When migrating from a legacy structure:

```r
# Maintain compatibility with legacy code
legacy_mapping <- function() {
  # Map old variable names to new structure
  ROOT_PATH <- APP_DIR
  DATA_PATH <- file.path(APP_DIR, "app_data")
  assign("ROOT_PATH", ROOT_PATH, envir = .GlobalEnv)
  assign("DATA_PATH", DATA_PATH, envir = .GlobalEnv)
}
```

### 2. Working with External Libraries

When using external libraries that expect different path structures:

```r
# Adapt to external library expectations
shiny_www_dir <- file.path(APP_DIR, "www")
if (!dir.exists(shiny_www_dir)) {
  dir.create(shiny_www_dir)
}
```

### 3. Multi-level Organization

For large projects requiring more than two tiers:

```r
# Three-tier organization within APP_DIR
project_dir <- file.path(APP_DIR, "projects", "project_name")
```

## Example Implementation

A complete example of implementing the two-tier directory structure:

```r
# Two-tier directory structure implementation
detect_paths <- function() {
  app_dir <- getwd()
  root_dir <- dirname(app_dir)
  
  message("App directory: ", app_dir)
  message("Root directory: ", root_dir)
  
  return(list(
    APP_DIR = app_dir,
    ROOT_DIR = root_dir
  ))
}

# Set path variables
paths <- detect_paths()
APP_DIR <- paths$APP_DIR
ROOT_DIR <- paths$ROOT_DIR

# For backward compatibility
ROOT_PATH <- APP_DIR

# Create required directories
required_dirs <- c(
  file.path(APP_DIR, "app_data"),
  file.path(APP_DIR, "app_configs"),
  file.path(APP_DIR, "logs"),
  file.path(APP_DIR, "update_scripts")
)

for (dir in required_dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
    message("Created directory: ", dir)
  }
}

# Function to get paths to sibling applications
get_sibling_app_path <- function(app_name) {
  if (app_name == "WISER") {
    return(APP_DIR)  # Current application
  } else {
    return(file.path(ROOT_DIR, paste0("precision_marketing_", app_name)))
  }
}

# Function to access shared resources
get_shared_resource_path <- function(resource_name) {
  return(file.path(ROOT_DIR, "shared_resources", resource_name))
}

# Export to an R file for persistence
write_path_config <- function() {
  config_file <- file.path(APP_DIR, "path_config.R")
  writeLines(c(
    "# Auto-generated path configuration",
    paste0("APP_DIR <- \"", APP_DIR, "\""),
    paste0("ROOT_DIR <- \"", ROOT_DIR, "\""),
    paste0("ROOT_PATH <- APP_DIR  # For backward compatibility")
  ), config_file)
}

# Write configuration to file
write_path_config()
```

## Integration with Other Rules

### Platform-Neutral Code (R03)

This rule complements R03 by providing a standardized structure for path organization while maintaining platform neutrality through the use of `file.path()` and dynamic path detection.

### Initialization Sourcing (R13)

The two-tier structure should be established during initialization before loading any other resources, as specified in R13.

### App YAML Configuration (R04)

Configuration files should be organized following the two-tier structure, with app-specific configs in APP_DIR/app_configs and shared configs in appropriate ROOT_DIR locations.

## Conclusion

The Two-Tier Directory Structure Rule provides a clear, consistent approach to organizing and referencing paths across projects. By establishing APP_DIR and ROOT_DIR as the foundation for path references, projects become more portable, easier to maintain, and can share resources effectively while avoiding environment-specific path issues.