---
id: "R119"
title: "Memory-Resident Parameters Rule"
type: "rule"
date_created: "2025-04-30"
author: "Claude"
derives_from:
  - "MP015": "Currency Principle"
  - "MP031": "Initialization First"
  - "MP048": "Universal Initialization"
influences:
  - "P": "Application Performance"
  - "P": "Uniform Parameter Access" 
  - "P": "Real-time Parameter Editing"
---

# R119: Memory-Resident Parameters Rule

## Statement

All configuration parameters and reference data must be loaded into R memory (globalenv) during initialization of app mode and accessed directly from memory throughout application execution. Memory will be cleared during deinitialization.

## Rationale

Memory-resident parameters offer several critical advantages:

1. **Performance**: Eliminates repeated disk/database access for frequently used values
2. **Consistency**: Ensures all application components reference identical parameter values
3. **Centralization**: Provides a single source of truth for configuration settings
4. **Observability**: Allows direct inspection of current parameter values
5. **Modifiability**: Enables real-time modification of parameters during execution
6. **Lifecycle Management**: Parameters are loaded in app mode initialization and cleared in deinitialization

This approach allows for efficient operation while maintaining clear traceability of parameter sources and changes and proper memory management.

## Implementation Requirements

### 1. Parameter Loading Sequence

- Global parameters MUST be loaded into memory during initialization phase
- Parameter loading MUST occur before any dependent components are initialized
- Parameters MUST be stored in the globalenv with properly prefixed names
- Source file paths MUST be documented in initialization logs
- Loading sequence MUST follow the R048 Universal Initialization principle

### 2. Parameter Naming Convention

- Parameter data frames MUST use the `df_` prefix (e.g., `df_product_line_profile`)
- List parameters MUST use the `list_` prefix
- Vector parameters MUST use the `vec_` prefix
- Scalar parameters MUST use descriptive names without prefixes
- All parameter objects SHOULD include provenance attributes documenting their source

### 3. Memory Management

- Parameter objects MUST be kept reasonably sized to prevent memory issues
- Large datasets SHOULD remain in database with only indices/lookups in memory
- Reference tables with fewer than 10,000 rows SHOULD be fully memory-resident
- Dynamic parameters MUST be protected from unintended modification
- All parameters MUST be loaded during app mode initialization
- All parameters MUST be cleared during app mode deinitialization

### 4. Source File Structure

- Source CSV/Excel files MUST follow the established organization rules
- Files for SCD Type 1 parameters MUST be placed in the `app_data/parameters/scd_type1/` directory
- Files for SCD Type 2 parameters MUST be placed in the `app_data/parameters/scd_type2/` directory
- Global parameter files MUST be placed in `global_scripts/parameters/`

### 5. Access Pattern

- Components MUST access parameters directly from globalenv
- Functions SHOULD NOT reload parameters from disk/database unnecessarily 
- Validation of parameter existence SHOULD occur in initialization, not at usage time
- Updates to parameters MUST follow controlled patterns that maintain memory/disk synchronization

## Examples

### Correct Implementation

```r
# In initialization script
# 1. Load from source file
product_line_csv <- file.path("app_data", "parameters", "scd_type1", "product_line.csv")
df_product_line_profile <- read_csvxlsx(product_line_csv)

# 2. Add provenance attribute
attr(df_product_line_profile, "source_file") <- product_line_csv
attr(df_product_line_profile, "load_time") <- Sys.time()

# 3. Place in global environment with prescribed prefix
assign("df_product_line_profile", df_product_line_profile, envir = globalenv())

# Later in application code - direct access from memory
filtered_products <- filter(df_product_line_profile, included == 1)
```

### Incorrect Implementation

```r
# Incorrect: Reloading from disk in function
get_product_lines <- function() {
  # BAD: Reloads from disk each time instead of using memory-resident version
  product_line_csv <- file.path("app_data", "parameters", "scd_type1", "product_line.csv")
  read_csvxlsx(product_line_csv)
}

# Incorrect: Not following naming convention
# BAD: Missing df_ prefix for data frame
product_line_profile <- read_csvxlsx(product_line_csv)
assign("product_line_profile", product_line_profile, envir = globalenv())
```

## Relationship to Other Principles

- **MP015: Currency Principle** - Memory-resident parameters must still follow currency requirements
- **MP031: Initialization First** - Parameter loading is a critical initialization step
- **MP033: Deinitialization Final** - Memory clearing occurs during deinitialization
- **MP048: Universal Initialization** - Parameters are part of universal initialization sequence
- **R058: Global Parameter Organization** - Defines structure for parameter source files
- **P018: Dual Parameter Sources** - Defines YAML and Excel as primary parameter sources

## Benefits

1. **Performance Optimization**: Eliminates file I/O and database queries during normal operation
2. **Simplified Development**: Creates a consistent access pattern for all application components
3. **Enhanced Debugging**: Enables direct inspection of current parameter values
4. **Audit Capability**: Parameter provenance attributes support comprehensive auditing
5. **Real-time Adaptation**: Supports controlled modification of parameters during execution