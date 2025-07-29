---
id: "P0018"
title: "Parameter Organization Structure Principle"
type: "principle"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "MP0017": "Separation of Concerns Principle"
related_to:
  - "R0016": "YAML Parameter Configuration Rule"
  - "MP0006": "Data Source Hierarchy"
  - "MP0041": "Configuration-Driven UI Composition"
---

# Parameter Organization Structure Principle

## Principle

**Parameter files should be organized according to a consistent structure where company-specific parameters are stored in app-specific locations (`app_data/parameters/[company]`) and global parameters are stored in the global scripts location (`global_scripts/global_data/parameters`).**

## Implementation Requirements

### 1. Company-Specific Parameter Storage

1. **Location**: Company-specific parameters must be stored in `app_data/parameters/[company]` where `[company]` is the name of the company or an identifier.
2. **Contents**: These parameters should contain company-specific configurations, including:
   - Marketing channels (platform.xlsx)
   - Product lines (product_line.xlsx)
   - UI terminology dictionaries (ui_terminology_dictionary.xlsx)
   - Company-specific reference data

### 2. Global Parameter Storage

1. **Location**: Global parameters must be stored in `global_scripts/global_data/parameters`.
2. **Contents**: These parameters should contain shared configuration data, including:
   - System-wide reference data
   - Default values that can be overridden by company-specific parameters
   - Common configurations shared across all implementations

### 3. Parameter Loading Sequence

1. **Loading Order**:
   - Global parameters should be loaded first
   - Company-specific parameters should be loaded second, overriding global parameters where appropriate
2. **Fallback Mechanism**:
   - When a parameter file is missing from the company-specific location, fall back to the global location
   - When a parameter is missing from both locations, use sensible defaults defined in code

### 4. Parameter File Naming

1. **Consistent Naming**: Parameter files should have consistent names across environments
2. **Content Identification**: Names should clearly identify the content (e.g., platform.xlsx, product_line.xlsx)
3. **Versioning**: When parameter files have versions, use a suffix format: `filename_vX.xlsx`

## Implementation Examples

### Example 1: Proper Parameter Organization

```
/app_root
├── app_data/
│   └── parameters/
│       ├── KitchenMAMA/               # Company-specific folder
│       │   ├── platform.xlsx          # Marketing channels specific to KitchenMAMA
│       │   ├── product_line.xlsx      # Product lines specific to KitchenMAMA
│       │   └── ui_terminology_dictionary.xlsx
│       └── WISER/                     # Another company's folder
│           ├── platform.xlsx
│           └── product_line.xlsx
└── update_scripts/
    └── global_scripts/
        └── global_data/
            └── parameters/            # Global parameters folder
                ├── platform.xlsx      # Default marketing channels
                ├── product_line.xlsx  # Default product lines
                └── regions.xlsx       # Global parameter used by all companies
```

### Example 2: Parameter Loading Implementation

```r
# Function to load parameters with proper fallback
load_parameter_file <- function(filename, company = NULL) {
  # Try company-specific location first
  if (!is.null(company)) {
    company_path <- file.path("app_data", "parameters", company, filename)
    if (file.exists(company_path)) {
      message("Loading company-specific parameter: ", company_path)
      return(readxl::read_excel(company_path))
    }
  }
  
  # Fall back to global location
  global_path <- file.path("update_scripts", "global_scripts", "global_data", "parameters", filename)
  if (file.exists(global_path)) {
    message("Loading global parameter: ", global_path)
    return(readxl::read_excel(global_path))
  }
  
  # Neither exists, return empty data frame
  message("Parameter file not found: ", filename)
  return(data.frame())
}

# Usage in initialization
company <- config$brand$name
platform_df <- load_parameter_file("platform.xlsx", company)
product_line_df <- load_parameter_file("product_line.xlsx", company)
regions_df <- load_parameter_file("regions.xlsx") # Global parameter
```

## Common Errors and Solutions

### Error 1: Inconsistent Parameter Organization

**Problem**: Storing some company parameters in company-specific folders and others in global folders without a clear pattern.

**Solution**:
- Follow the structure outlined in this principle
- Document any exceptions to the structure
- Use the consistent loading function to hide complexity from application code

### Error 2: Hardcoded Parameter Paths

**Problem**: Hardcoding absolute paths to parameter files throughout the codebase.

**Solution**:
- Use the loading function that implements the fallback mechanism
- Reference parameters by logical names rather than physical paths
- Allow configuration to override default parameter locations

### Error 3: Duplicated Parameters Without Overrides

**Problem**: Duplicating parameter files in both locations without leveraging the override capability.

**Solution**:
- Global parameters should be complete but minimal
- Company-specific parameters should only include what differs from global
- Document the override strategy for each parameter type

## Relationship to Other Principles

### Relation to Separation of Concerns (MP0017)

This principle supports Separation of Concerns by:
1. **Clear Boundaries**: Establishing clear boundaries between company-specific and global parameters
2. **Responsibility Assignment**: Assigning parameter organization according to scope and usage
3. **Modular Organization**: Organizing parameters in a modular way that supports multiple companies

### Relation to YAML Parameter Configuration (R0016)

This principle complements YAML Parameter Configuration by:
1. **Hierarchical Structure**: Supporting the hierarchical configuration structure defined in R16
2. **Consistent Strategy**: Providing a consistent strategy for parameter file organization
3. **Environment Support**: Supporting different environments as described in R16

### Relation to Data Source Hierarchy (MP0006)

This principle aligns with Data Source Hierarchy by:
1. **Hierarchical Access**: Implementing a hierarchical access pattern for parameters
2. **Fallback Mechanism**: Providing a fallback mechanism similar to data source hierarchy
3. **Logical Organization**: Organizing parameters according to their logical scope and owner

## Benefits

1. **Clear Organization**: Parameters are clearly organized by scope and owner
2. **Simplified Maintenance**: Company-specific parameters can be maintained separately
3. **Reduced Duplication**: Global parameters are shared rather than duplicated
4. **Consistent Access**: Parameters are accessed through a consistent mechanism
5. **Transparent Fallback**: Fallback to global parameters is transparent to application code
6. **Reusable Implementation**: Parameter loading logic can be reused across applications
7. **Company Isolation**: Company-specific configurations are isolated from each other
8. **Upgrade Path**: Clear path for migrating from default to company-specific configurations

## Conclusion

The Parameter Organization Structure Principle establishes a clear and consistent organization for parameter files, separating company-specific parameters from global ones. By following this structure, applications can maintain clean separation between different companies while sharing common parameters where appropriate. The fallback mechanism ensures robustness even when specific parameter files are missing, maintaining application functionality with sensible defaults.
