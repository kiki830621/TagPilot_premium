---
id: "R04"
title: "App YAML Configuration"
type: "rule"
date_created: "2025-04-02"
date_modified: "2025-04-02"
author: "Claude"
implements:
  - "P04": "App Construction Principles"
derives_from:
  - "MP01": "Primitive Terms and Definitions"
  - "MP05": "Instance vs. Principle"
  - "MP10": "Information Flow Transparency"
  - "MP11": "Sensible Defaults"
related_to:
  - "P07": "App Bottom-Up Construction"
  - "MP06": "Data Source Hierarchy"
  - "MP08": "Terminology Axiomatization"
---

# App YAML Configuration Rule

This rule establishes specific implementation guidelines for using YAML configuration files in the precision marketing application, enabling declarative app construction and promoting separation of configuration from implementation.

## Core Concept

Application configuration should be externalized in YAML files that define the structure, components, and data sources without requiring code changes. This enables non-developers to modify application behavior and supports a clear separation between configuration (instances) and implementation (principles).

## Configuration Location

All YAML configuration files should be stored in the `app_configs` directory at the project root:

```
precision_marketing_app/
└── app_configs/
    ├── customer_dna_app.yaml   # Main app configuration
    ├── component_config.yaml   # Component-specific configuration
    └── data_sources.yaml       # Data source mappings
```

This follows the Instance vs. Principle Meta-Principle by placing instance-specific configurations outside the global_scripts directory.

## YAML Structure Guidelines

### 1. Basic Structure

Every YAML configuration file should include:

```yaml
# [File Description]
# [Author]
# [Date Created]
title: [Application Title]
version: [Configuration Version]

# Main configuration sections follow...
```

### 2. Standard Format Patterns

The configuration follows six standard patterns for data source and environment specifications. A key principle is: **If there is only one data source, the role is unnecessary; if there are multiple sources, they are discriminated by their roles.**

```yaml
# Pattern 1: Simple String Format
component_name: dataset_name

# Pattern 2: Array Format 
component_name: 
  - dataset1
  - dataset2
  - dataset3

# Pattern 3: Object Format with Roles
component_name:
  role1: dataset1
  role2: dataset2
  role3: dataset3

# Pattern 4a: Single Data Source with Parameters
component_name:
  data_source: dataset_name    # Single data source
  parameters:                  # Component parameters
    param1: value1
    param2: value2

# Pattern 4b: Multiple Data Sources with Roles and Parameters
component_name:
  role1: dataset1              # Multiple data sources with roles
  role2: dataset2
  parameters:                  # Component parameters
    param1: value1
    param2: value2

# Pattern 5: Environment Configuration Pattern
environment_name:
  data_source: "path/to/data"  # Data source path
  parameters:                  # Environment parameters
    param1: value1
    param2: value2

# Pattern 6: External Parameter Files Pattern
component_name:
  data_source: dataset_name    # Data source
  parameters:                  # Component parameters
    # Simple inline parameters
    param1: value1
    param2: value2
    
    # Complex parameters in external file
    external_params:
      file: "path/to/parameters.xlsx"  # External file path
      sheet: "ParameterSheet"          # Sheet name for Excel files
      refresh_on_startup: true         # Whether to reload on app startup
```

### 3. Data Source Specification Formats

These are the specific implementations of the patterns for component data sources:

#### 1. Simple String Format
For components requiring a single data source (no role needed):

```yaml
components:
  macro:
    overview: sales_summary_view
```

### 4. Brand Configuration

Brand-specific settings should be defined in the YAML configuration, not hardcoded in R scripts:

```yaml
# Brand-specific settings
brand:
  name: "COMPANY_NAME"
  language: "chinese"  # Language settings for UI and data
  raw_data_folder: "../rawdata_COMPANY_NAME"
```

### 5. External Parameter Files for Components

For complex component parameters, reference external files with explicit paths (following Pattern 6):

```yaml
components:
  advanced_analytics:
    data_source: analytics_data
    parameters:
      # Simple inline parameters
      show_filters: true
      default_view: "summary"
      
      # Complex parameters in external file
      model_config:
        file: "app_data/parameters/model_parameters.xlsx"
        sheet: "AdvancedAnalytics"
        refresh_on_startup: true
  
  customer_segmentation:
    primary: customer_data
    reference: segment_definitions
    parameters:
      # Simple inline parameters
      max_segments: 8
      
      # Complex parameters in external file
      segment_rules:
        file: "app_data/parameters/segment_parameters.xlsx"
        sheet: "SegmentRules"
        refresh_on_startup: false
        
  market_analysis:
    data_source: market_data
    parameters:
      # Simple inline parameters
      show_trends: true
      time_range: "quarterly"
      
      # Multiple external parameter files
      pricing_models:
        file: "app_data/parameters/pricing_models.xlsx"
        sheet: "ModelParameters"
        refresh_on_startup: true
      competitive_analysis:
        file: "app_data/parameters/competitor_data.csv"
        refresh_on_startup: false
      geographic_weights:
        file: "app_data/parameters/geo_weights.json"
        refresh_on_startup: true
```

This streamlined approach:
- Associates parameters directly with their components
- Uses file extension to determine the source type
- Avoids redundant descriptions
- Maintains clear file paths for transparency
- Preserves component encapsulation
- Supports multiple external parameter files per component
- Accommodates various file formats (Excel, CSV, JSON, etc.)
- Allows fine-grained control over refresh behavior

#### 2. Array Format
For components requiring multiple tables in a specific order (implicit indexing):

```yaml
components:
  target:
    segmentation:
      - customer_segments
      - segment_definitions
      - segment_metrics
```

#### 3. Object Format
For components requiring multiple tables with specific roles (explicit roles):

```yaml
components:
  micro:
    customer_profile:
      primary: customer_details
      preferences: customer_preferences
      history: customer_history
```

#### 4. Brand Configuration
Brand-specific settings should be defined in the YAML configuration, not hardcoded in R scripts:

```yaml
# Brand-specific settings
brand:
  name: "COMPANY_NAME"
  language: "chinese"  # Language settings for UI and data
  raw_data_folder: "../rawdata_COMPANY_NAME"
```

### 5. Comments and Documentation

YAML configurations should be well-documented:

```yaml
# Customer DNA Application Configuration
# This configuration defines the structure and data sources for the Customer DNA app

title: AI行銷科技平台

# Theme settings control the visual appearance
# version: Bootstrap version
# bootswatch: Theme name from the Bootswatch library
theme:
  version: 5  # Using Bootstrap 5
  bootswatch: cosmo  # Clean, modern appearance
```

### 6. Hierarchical Organization

Configuration should be hierarchically organized by category, using the data source formats described above:

```yaml
# App-level settings
title: AI行銷科技平台
theme:
  version: 5
  bootswatch: cosmo
layout: navbar

# Component configuration
components:
  # Section 1 components
  macro:
    # Simple component with single data source (Format 1)
    overview: sales_summary_view
    
    # Component with data source and parameters
    trends:
      data_source: sales_trends  # Single data source
      parameters:                # Component parameters
        show_kpi: true
        refresh_interval: 300
  
  # Section 2 components
  micro:
    # Component with multiple data sources (Format 3)
    customer_profile:
      primary: customer_details        # Multiple data sources with roles
      preferences: customer_preferences
      history: customer_history
      
    # Component with multiple data sources and parameters
    advanced_profile:
      primary: customer_details        # Multiple data sources with roles
      history: customer_history
      parameters:                      # Component parameters
        default_view: "summary"
        enable_export: false
```

## Implementation Guidelines

### 1. YAML Loading

Use the standardized `readYamlConfig` utility to load YAML configurations:

```r
# Load configuration
config <- readYamlConfig("customer_dna_app.yaml")

# Access configuration values with safe fallbacks
app_title <- config$title %||% "Default Title"
theme_settings <- config$theme %||% list(version = 5, bootswatch = "default")
```

### 2. Configuration Validation

Always validate configurations before using them:

```r
# Validate required fields
validateConfig <- function(config) {
  required_fields <- c("title", "components")
  missing_fields <- required_fields[!required_fields %in% names(config)]
  
  if (length(missing_fields) > 0) {
    warning("Configuration missing required fields: ", 
            paste(missing_fields, collapse = ", "))
    return(FALSE)
  }
  
  return(TRUE)
}
```

### 3. Data Source Processing

Use the `processDataSource` utility to handle all data source formats consistently:

```r
# In server component
data_tables <- reactive({
  processDataSource(
    data_source = config$components$micro$customer_profile,
    table_names = c("primary", "preferences", "history")
  )
})

# Then access the standardized structure
customer_data <- reactive({ data_tables()$primary })
preferences_data <- reactive({ data_tables()$preferences })
```

### 4. Default File Locations

Implement sensible defaults for file locations to reduce configuration burden:

```r
# Define system-wide default paths
DEFAULT_PATHS <- list(
  app_data = "app_data/",
  database = "app_data/app.db",
  parameters = "app_data/parameters/",
  temp = "temp/"
)

# Function with sensible defaults
loadDatabase <- function(db_path = NULL) {
  # Use default path if not specified
  if (is.null(db_path)) {
    db_path <- DEFAULT_PATHS$database
    log_info(paste("Using default database path:", db_path))
  }
  
  # Load database
  conn <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  return(conn)
}

# Example YAML that doesn't need to specify common defaults
components:
  data_explorer:
    # No need to specify database path if using default
    parameters:
      show_tables: true
      max_rows: 1000
```

### 5. External Parameter Loading

Load external parameter files with explicit source logging for transparency:

```r
# Load component parameters including external files
loadComponentParameters <- function(component_config) {
  # Get basic parameters first
  params <- component_config$parameters %||% list()
  
  # Process any external parameter files
  for (param_name in names(params)) {
    param_value <- params[[param_name]]
    
    # Check if this is an external file reference
    if (is.list(param_value) && !is.null(param_value$file)) {
      log_info(paste("Loading external parameters from", param_value$file))
      
      # Determine file type and load accordingly
      file_path <- param_value$file
      file_ext <- tools::file_ext(file_path)
      
      external_params <- switch(
        file_ext,
        # Excel files
        xlsx = {
          sheet_name <- param_value$sheet %||% 1
          readxl::read_excel(file_path, sheet = sheet_name)
        },
        
        # CSV files
        csv = {
          readr::read_csv(file_path)
        },
        
        # JSON files
        json = {
          jsonlite::fromJSON(file_path)
        },
        
        # RDS files
        rds = {
          readRDS(file_path)
        },
        
        # YAML files
        yml = , yaml = {
          yaml::read_yaml(file_path)
        },
        
        # Default case
        {
          warning(paste("Unsupported file extension for external parameters:", file_ext))
          NULL
        }
      )
      
      # If successfully loaded, replace the reference with actual data
      if (!is.null(external_params)) {
        # Replace the file reference with actual data
        params[[param_name]] <- external_params
        
        # Add metadata for traceability
        attr(params[[param_name]], "source_file") <- param_value$file
        attr(params[[param_name]], "load_time") <- Sys.time()
        attr(params[[param_name]], "file_type") <- file_ext
        if (!is.null(param_value$sheet)) {
          attr(params[[param_name]], "sheet") <- param_value$sheet
        }
        if (!is.null(param_value$refresh_on_startup)) {
          attr(params[[param_name]], "refresh_on_startup") <- param_value$refresh_on_startup
        }
      }
    }
  }
  
  return(params)
}

# Usage in component
component_params <- loadComponentParameters(config$components$advanced_analytics)

# Check if parameters need refresh on app restart
needsRefresh <- function(param_obj) {
  !is.null(attr(param_obj, "refresh_on_startup")) && 
    attr(param_obj, "refresh_on_startup") == TRUE
}
```

### 4. Environment-Specific Configuration

Environment configurations should combine data path assignment with parameters:

```yaml
# App-wide environment-specific configurations
environments:
  development:
    data_source: "development_data/"  # Data source path
    parameters:                       # Environment parameters
      debug: true
  production:
    data_source: "app_data/"          # Data source path
    parameters:                       # Environment parameters
      debug: false
```

This approach follows the pattern where each environment specifies its data source path directly while keeping configuration parameters separate in a parameters object.

## Complete Configuration Example

```yaml
# Customer DNA Analysis Dashboard Configuration
title: AI行銷科技平台
theme:
  version: 5
  bootswatch: cosmo
layout: navbar

# Brand-specific settings
brand:
  name: "COMPANY_NAME"
  language: "chinese"  # Language settings for UI and data
  raw_data_folder: "../rawdata_COMPANY_NAME"

# Components with their data sources - demonstrates all formats
components:
  macro:
    # Format 1: Simple string format (single data source, no role needed)
    overview: sales_summary_view
    
    # Component with single data source and parameters
    trends:
      data_source: sales_trends      # Single data source
      parameters:                    # Component parameters
        show_kpi: true
        refresh_interval: 300
  
  micro:
    # Format 3: Object format with named roles (multiple data sources)
    customer_profile:
      primary: customer_details
      preferences: customer_preferences
      history: customer_history
    
    # Format 1: Simple string format again (single data source)
    transactions: transaction_history
  
  target:
    # Format 2: Array format for ordered tables (multiple sources with implicit ordering)
    segmentation:
      - customer_segments
      - segment_definitions
      - segment_metrics
    
    # Format 3 with parameters (multiple sources with explicit roles)
    advanced_segmentation:
      primary: customer_segments      # Primary data source
      reference: segment_definitions  # Reference data source
      parameters:                     # Component parameters
        visualization_type: "tree"
        max_depth: 3
  
  analytics:
    # Format 6: External parameter files pattern
    predictive_models:
      data_source: customer_data
      parameters:
        # Simple inline parameters
        prediction_horizon: 90
        confidence_threshold: 0.75
        
        # External parameter files
        model_configurations:
          file: "app_data/parameters/model_config.xlsx"
          sheet: "PredictiveModels"
          refresh_on_startup: true
        feature_weights:
          file: "app_data/parameters/feature_weights.json"
          refresh_on_startup: false
    
    market_basket:
      primary: transaction_data
      secondary: product_catalog
      parameters:
        # Simple inline parameters
        min_support: 0.05
        min_confidence: 0.3
        
        # External parameter files with multiple formats
        product_associations:
          file: "app_data/parameters/product_associations.csv"
          refresh_on_startup: true
        category_rules:
          file: "app_data/parameters/category_rules.xlsx"
          sheet: "AssociationRules"
          refresh_on_startup: false

# Environment-specific configurations
environments:
  development:
    data_source: "development_data/"  # Data source path
    parameters:                       # Environment parameters
      debug: true
  production:
    data_source: "app_data/"          # Data source path
    parameters:                       # Environment parameters
      debug: false
```

## Benefits

1. **Separation of Concerns**: Configurations are separate from implementation code
2. **Non-Developer Access**: Non-developers can modify app behavior through configuration
3. **Environment Flexibility**: Different configurations for different environments
4. **Reduced Code Changes**: App modifications without code changes
5. **Self-Documentation**: YAML format with comments provides clear documentation
6. **Consistency**: Standardized configuration format across applications

## Relationship to Other Principles

This rule implements:

1. **App Construction Principles** (P04): Follows the Component Reuse Rule and Bottom-Up Construction Rule

And derives from:

1. **Instance vs. Principle Meta-Principle** (MP05): Configurations are instances, separate from implementation principles
2. **Primitive Terms and Definitions** (MP01): Uses primitive terms defined in the system
3. **Information Flow Transparency** (MP10): Makes information sources explicit and traceable
4. **Sensible Defaults** (MP11): Reduces configuration burden through use of well-designed defaults

It is also related to:

1. **App Bottom-Up Construction** (P07): Uses YAML configurations to build apps
2. **Data Source Hierarchy** (MP06): Respects the data source hierarchy in configurations
3. **Terminology Axiomatization** (MP08): Uses consistent terminology as defined in the axiomatization

## Structural Rules and Patterns

The YAML configuration follows specific structural rules that maintain consistency and clarity:

1. **Component Structure Rule**: Components can only contain:
   - A direct dataset reference (string format)
   - An array of dataset references (array format)
   - Named dataset references with roles (object format)
   - A data_source field with an optional parameters object

2. **Role Assignment Rule**: Roles are only used when there are multiple data sources that need to be distinguished by their function. A single data source should never have a role assigned.

3. **Parameter Encapsulation Rule**: All configuration parameters must be contained within a dedicated `parameters` object, which is a sibling to data source definitions.

4. **Structure Simplification Rule**: Use the simplest form possible for data source specification:
   - One data source → Simple string format
   - Multiple ordered data sources → Array format
   - Multiple data sources with specific roles → Object format

5. **Hierarchy Containment Rule**: All component-specific configuration must remain within its component definition block, while app-wide configurations (like environments) stay at the root level.

6. **Consistency Pattern**: Similar components should follow similar patterns for data source specification and parameter definition.

7. **Mutually Exclusive Rule**: Within a component, data sources and parameters are mutually exclusive concepts - parameters configure how a component behaves, while data sources specify what data the component uses.

8. **External Reference Transparency Rule**: When referencing external files for configuration or parameters, always use explicit file paths that clearly indicate the source location and nature, enabling direct traceability.

9. **Sensible Defaults Rule**: Configuration should rely on sensible defaults wherever possible. Explicit configuration should only be required for values that differ from defaults, reducing complexity and improving maintainability. Standard file locations, common settings, and typical behaviors should have well-documented defaults.

These structural rules ensure that YAML configurations remain consistent, maintainable, and easy to understand for both developers and non-technical users.

## Best Practices

1. **Validate Configurations**: Always validate configuration files before use
2. **Provide Defaults**: Include sensible defaults for missing configuration elements
3. **Document with Comments**: Use YAML comments to explain configuration options
4. **Version Control**: Track configuration changes in version control when appropriate
5. **Test Different Formats**: Ensure components work with all data source formats
6. **Use Platform-Neutral Paths**: Follow platform-neutral path construction in configurations
7. **Keep Configurations DRY**: Avoid redundancy in configurations
8. **Use Environment-Specific Sections**: Support different environments with dedicated sections
9. **Follow the Role Necessity Principle**: Only use roles for data sources when multiple sources are present; avoid unnecessary roles for single data sources
10. **Log External File Loading**: Always log when loading external parameter files
11. **Maintain Transparency**: Keep file paths explicit and traceable in configurations
12. **Parameter Visibility**: Make parameters visible and inspectable to users
13. **Path Consistency**: Use consistent path formatting for all external references
