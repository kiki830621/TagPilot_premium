---
id: "R0041"
title: "Folder Structure for Derivations, Sequences, Modules, and Nodes"
type: "rule"
date_created: "2025-04-07"
date_modified: "2025-04-09"
author: "Claude"
implements:
  - "MP0001": "Primitive Terms and Definitions"
  - "MP0002": "Structural Blueprint"
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
related_to:
  - "R0039": "Derivation Platform Independence"
  - "R0040": "Implementation Naming Convention for Derivations, Sequences, Modules, and Nodes"
---

# R0041: Folder Structure for Derivations, Sequences, Modules, and Nodes

This rule establishes the folder structure for organizing derivations, sequences, modules, and nodes, enhancing the organization and maintainability of the system.

## Core Requirements

1. **Location Requirement**: ALL metaprinciples (MP), principles (P), rules (R), derivations (D), sequences (S), modules (M), and nodes (N) MUST be located in the "global_scripts/00_principles" directory. NO exceptions are permitted.

2. **Structure Requirement**: Derivations (D), Sequences (S), Modules (M), and Nodes (N) MUST be organized in hierarchical folder structures that clearly separate abstract definitions from platform-specific implementations. The organization MUST follow the specific directory naming and structure patterns defined in this rule.

## Folder Structure Organization

### 1. Root Structure

ALL components MUST be organized within the global_scripts/00_principles directory using the following strict naming convention:

```
00_principles/                     # Root principles directory
  |-- MP{nn}_{description}.md      # Metaprinciples (MP0001_primitive_terms.md)
  |-- P{nn}_{description}.md       # Principles (P0001_script_separation.md)
  |-- R{nn}_{description}.md       # Rules (R0001_file_naming_convention.md)
  |-- D{nn}/                       # Directories for derivations (D01, D02, etc.)
  |-- S{nn}/                       # Directories for sequences (S00, S01, etc.)
  |-- M{nn}/                       # Directories for modules (M00, M01, etc.)
  |-- nodes/                       # Single directory for all node utilities
```

Where:
- {nn} represents a two-digit number (01, 02, etc.)
- Directory names MUST use exactly the format shown (D01, not D01_dna_analysis)
- File names for MP/P/R MUST include the underscore and description suffix
- All system definition files MUST reside in this directory structure

This standardized structure allows for easier synchronization across company repositories using the sync_global_scripts.sh script and ensures that all system definitions are in a known, centralized location.

### 2. Derivation Directory Structure

Derivations MUST follow this structure exactly:

```
00_principles/
  |-- D01/             # Directory MUST be named exactly "D01"
  |   |-- D01.md       # File MUST be named exactly "D01.md" 
  |   |-- platforms/   # MUST have a subdirectory named "platforms"
  |       |-- 01/      # Platform directories MUST use 2-digit numbers
  |       |   |-- D01_P0001_00.R
  |       |   |-- D01_P0001_01.R
  |       |   `-- ...
  |       |-- 06/      # eBay platform (06)
  |       |   |-- D01_P0006_00.R
  |       |   `-- ...
  |       `-- 07/      # Cyberbiz platform (07)
  |           |-- D01_P0007_00.R
  |           `-- ...
  |-- D02/             # Directory for D02 derivation
  |   `-- ...
```

The exact naming convention MUST be followed:
- The directory MUST be named exactly "D{nn}" (e.g., "D01", not "D01_dna_analysis")
- The abstract definition MUST be named exactly "D{nn}.md" (e.g., "D01.md", not "D01_dna_analysis.md")
- All implementation files MUST use the naming pattern defined in R40

### 3. Sequence Directory Structure

Sequences MUST follow this structure exactly:

```
00_principles/
  |-- S00/             # Directory MUST be named exactly "S00"
  |   |-- S00.md       # File MUST be named exactly "S00.md"
  |   |-- platforms/   # MUST have a subdirectory named "platforms"
  |       |-- 01/      # Platform directories MUST use 2-digit numbers
  |       |   |-- S00_P0001_00.R
  |       |   `-- ...
  |       `-- 07/      # Cyberbiz platform (07)
  |           |-- S00_P0007_00.R
  |           `-- ...
  |-- S01/             # Directory for S01 sequence
  |   `-- ...
```

The exact naming convention MUST be followed:
- The directory MUST be named exactly "S{nn}" (e.g., "S00", not "S00_preprocessing")
- The abstract definition MUST be named exactly "S{nn}.md" (e.g., "S00.md", not "S00_preprocessing.md")
- All implementation files MUST use the naming pattern defined in R40

### 4. Module Directory Structure

Modules MUST follow this structure exactly:

```
00_principles/
  |-- M01/             # Directory MUST be named exactly "M01"
  |   |-- M01.md       # File MUST be named exactly "M01.md"
  |   |-- functions/   # MUST have a subdirectory named "functions"
  |   |   |-- fn_xxx.R
  |   |   `-- ...
  |   |-- platforms/   # MUST have a subdirectory named "platforms" if implementations exist
  |       |-- 01/      # Platform directories MUST use 2-digit numbers
  |       |   |-- M01_P0001_fn.R
  |       |   `-- ...
  |-- M02/             # Directory for M02 module
  |   `-- ...
```

The exact naming convention MUST be followed:
- The directory MUST be named exactly "M{nn}" (e.g., "M01", not "M01_analysis")
- The abstract definition MUST be named exactly "M{nn}.md" (e.g., "M01.md", not "M01_analysis.md")
- All implementation files MUST use the naming pattern defined in R40

### 5. Node Directory Structure

Nodes MUST follow this flat directory structure exactly:

```
00_principles/
  |-- nodes/           # MUST be a single directory named exactly "nodes"
      |-- N0001.R      # Node utility #0001 (Data Export Utility)
      |-- N0002.R      # Node utility #0002 (Configuration Validator)
      |-- N0003.R      # Node utility #0003 (Logging Framework)
      |-- ...          # Additional node utilities
```

The exact naming convention MUST be followed:
- All nodes MUST be in a single directory named exactly "nodes"
- Node files MUST follow the N{four-digit-number}.R pattern defined in R40
- Nodes MUST NOT be organized in separate type directories or platform directories

## Implementation Guidelines

### 1. Directory Creation

When creating a new derivation, sequence, module, or node:

1. First create the appropriate directory structure
2. Create the abstract definition file (D01.md, S01.md, M01.md, N01.md)
3. Create platform-specific subdirectories as needed
4. Implement the specific files within their respective directories

### 2. File Paths in Source Statements

When sourcing files from within derivation or sequence implementations, use the get_root_path function:

```r
# From a derivation implementation D01_P0001_00.R
source(file.path(get_root_path(), "update_scripts", "global_scripts", "00_principles", "M01", "functions", "fn_xxx.R"))

# Or using a relative path from the current file
source(file.path(dirname(dirname(dirname(__FILE__))), "M01", "functions", "fn_xxx.R"))
```

### 3. Database Connection Structure

Database connections should follow a hierarchical structure that represents the data processing pipeline:

```
preraw_data.duckdb    # For raw data from APIs, pre-processing (S00 sequences)
raw_data.duckdb       # For standardized raw data (D01 derivations)
processed_data.duckdb # For processed analytical data (D02-D09 derivations)
app_data.duckdb       # For application-ready data (Dashboard use)
```

Each database represents a stage in the data processing pipeline, with transformations flowing from pre-raw to application-ready data.

## Conversion Guidelines

### 1. Converting Existing Files

When converting existing files to the new folder structure:

1. Create the appropriate directory structure in 00_principles (D01, S00, M01, N01, etc.)
2. Convert abstract definitions to .md files (D01.md, S00.md, M01.md, N01.md)
3. Move platform-specific implementations to platforms/{nn} subdirectories
4. Update source paths to use get_root_path() or relative paths
5. Update database connection logic to match the new structure

### 2. File Naming in the New Structure

Files within the folder structure should follow these naming patterns:

- Abstract definitions: `D01.md`, `S00.md`, `M01.md`, `N01.md`
- Platform implementations: `D01_P0001_00.R`, `S00_P0007_00.R`, `M01_P0001_fn.R`, `N01_P0002_00.R`
- Module functions: `fn_xxx.R`

All implementation files should follow the naming convention defined in R0040 (Implementation Naming Convention) with the pattern `{Type}{Number}_P{Platform}_{Step}.R`.

## Benefits

1. **Clear Organization**: Separates abstract definitions from implementations
2. **Platform Isolation**: Keeps platform-specific code separate
3. **Easy Navigation**: Makes it easier to locate specific files
4. **Improved Maintainability**: Reduces cognitive load when working with multiple platforms
5. **Explicit Relationships**: Makes relationships between different component types clear
6. **Consistency**: Provides a uniform approach for all component types (D/S/M/N)
7. **Scalability**: Allows for easy addition of new platforms and component types
8. **Centralization**: Ensures all system definitions are in a single, known location
9. **Synchronization**: Simplifies cross-repository synchronization with all files in a standard location

## Relationship to Other Rules

This rule is related to:

- **R0039 (Derivation Platform Independence)**: Organizes platform-independent and platform-specific components
- **R0040 (Derivation Implementation Naming Convention)**: Complements the file naming with directory structure

## Implementation Timeline

This folder structure should be implemented for all new derivations, sequences, and modules immediately. Existing resources should be migrated to this structure as part of regular maintenance cycles.

## Implementation Examples

### Example 1: Cyberbiz Pre-Processing (S00_P0007_00)

The S00 sequence for pre-processing Cyberbiz API data:

```
00_principles/
  |-- S00/
  |   |-- S00.md                # General pre-processing definition
  |   |-- platforms/
  |       |-- 07/               # Cyberbiz platform (07)
  |           |-- S00_P0007_00.R  # Pre-processing implementation for Cyberbiz
```

S00_P0007_00.R processes Cyberbiz API data from RDS files, converting nested JSON structures and creating tables in preraw_data.duckdb:

```r
# S00_P0007_00.R excerpt
import_cyberbiz_api_data <- function(conn, cyberbiz_api_path, verbose = TRUE) {
  if(verbose) message("Importing Cyberbiz API data...")
  
  # Process orders
  orders_file <- file.path(cyberbiz_api_path, "orders.RDS")
  if(file.exists(orders_file)) {
    orders <- readRDS(orders_file)
    orders <- process_json_columns(orders, verbose)
    DBI::dbWriteTable(conn, "cyberbiz_orders", orders, overwrite = TRUE)
  }
  
  # Join data to create combined dataset
  join_query <- "
  CREATE OR REPLACE TABLE df_cyberbiz_combined AS
  SELECT
    o.id AS order_id,
    o.customer_id,
    c.email AS customer_email,
    /* more fields... */
  FROM
    cyberbiz_orders o
  LEFT JOIN
    cyberbiz_customers c ON o.customer_id = c.id
  "
  DBI::dbExecute(conn, join_query)
}
```

### Example 2: Cyberbiz DNA Analysis Import (D01_P0007_00)

The D01 derivation implementation for Cyberbiz:

```
00_principles/
  |-- D01/
  |   |-- D01.md                # General DNA analysis definition
  |   |-- platforms/
  |       |-- 07/               # Cyberbiz platform (07)
  |           |-- D01_P0007_00.R  # Import implementation for Cyberbiz
```

D01_P0007_00.R imports data from preraw_data.duckdb to raw_data.duckdb:

```r
# D01_P0007_00.R excerpt
import_cyberbiz_raw_data <- function(preraw_conn, raw_conn, verbose = TRUE) {
  # Create df_cyberbiz_sales table in raw_data from preraw_data
  query <- "
  CREATE OR REPLACE TABLE df_cyberbiz_sales AS
  SELECT
    o.id AS order_id,
    o.customer_id,
    c.email AS customer_email,
    /* more fields... */
  FROM
    cyberbiz_orders o
  LEFT JOIN
    cyberbiz_customers c ON o.customer_id = c.id
  "
  DBI::dbExecute(raw_conn, query)
}
```

### Example 3: Data Export Utility Node (N0001.R)

A platform-agnostic data export utility node:

```
00_principles/
  |-- nodes/
      |-- N0001.R      # Data Export Utility
```

N0001.R provides various export functions for different formats:

```r
# N0001.R excerpt
export_data_to_csv <- function(data, export_path, include_headers = TRUE, 
                              date_format = "%Y-%m-%d", verbose = TRUE) {
  if(verbose) message("Exporting data to CSV...")
  
  # Process date columns
  date_cols <- sapply(data, function(x) inherits(x, "Date") || inherits(x, "POSIXt"))
  if(any(date_cols)) {
    for(col in names(data)[date_cols]) {
      data[[col]] <- format(data[[col]], format = date_format)
    }
  }
  
  # Write to file
  write.csv(data, export_path, row.names = FALSE, quote = TRUE)
  
  return(export_path)
}

export_query_results <- function(conn, query, export_path, format = "csv", verbose = TRUE) {
  # Execute query
  data <- DBI::dbGetQuery(conn, query)
  
  # Export based on format
  if(format == "csv") {
    return(export_data_to_csv(data, export_path, verbose = verbose))
  } else if(format == "excel") {
    return(export_data_to_excel(data, export_path, verbose = verbose))
  } else if(format == "json") {
    return(export_data_to_json(data, export_path, verbose = verbose))
  }
}
```

### Example 4: Configuration Validation Node (N0002.R)

A platform-agnostic configuration validation utility:

```
00_principles/
  |-- nodes/
      |-- N0002.R      # Configuration Validation Utility
```

N0002.R provides configuration loading and validation functions:

```r
# N0002.R excerpt
validate_yaml_config <- function(config_path, schema_path, verbose = TRUE) {
  if(verbose) message("Validating YAML configuration...")
  
  # Read configuration file
  config <- yaml::read_yaml(config_path)
  
  # Read schema file
  schema <- readLines(schema_path, warn = FALSE)
  schema <- paste(schema, collapse = "\n")
  
  # Convert YAML to JSON for validation
  config_json <- jsonlite::toJSON(config, auto_unbox = TRUE)
  
  # Validate JSON against schema
  is_valid <- jsonvalidate::json_validate(config_json, schema, verbose = verbose)
  
  return(is_valid)
}

get_config_value <- function(config, path, default = NULL) {
  # Split path by dots
  parts <- strsplit(path, "\\.")[[1]]
  
  # Navigate through the config
  current <- config
  for(part in parts) {
    if(is.null(current) || !is.list(current) || is.null(current[[part]])) {
      return(default)
    }
    current <- current[[part]]
  }
  
  return(current)
}
```
