# Principle 18: Dual Parameter Sources

## Core Principle
Application parameters must be sourced from the most appropriate format based on their structure and purpose:
1. **YAML Configuration** for hierarchical, simple, or unstructured parameters
2. **Excel (.xlsx) Files** for tabular, relationship-driven, or structured parameters

All parameters, regardless of source, must be integrated into a unified configuration object during initialization.

## Rationale
This principle acknowledges that different parameter types have different natural representations:

1. **Format Appropriateness**: Each parameter type has an optimal storage format
2. **User Accessibility**: Excel files are more accessible to non-developers for certain parameters
3. **Data Structure Alignment**: Tabular data belongs in tabular files; hierarchical data in hierarchical files
4. **Integration Efficiency**: Loading all parameters at initialization creates a single source of truth
5. **Flexible Extensibility**: New parameters can be added in either format without code restructuring

## Parameter Type Guidelines

### YAML-Appropriate Parameters
Store these parameters in app_config.yaml:
- Application settings (ports, paths, modes)
- Feature flags and toggles
- Simple key-value pairs
- Configuration hierarchies
- Default values
- Connection strings
- Environment-specific settings
- **Function-driven configurations** where structure is determined by code
- **Component-defined structures** that don't require user editing

### Excel-Appropriate Parameters
Store these parameters in .xlsx files:
- Marketing channels and platform information
- Product catalogs and attributes
- Mapping tables between systems
- User interface terminology
- Calculation tables and lookup values
- Classification systems
- Multi-column data relationships
- **User-editable configurations** requiring frequent updates

## Implementation Guidelines

### YAML Configuration Structure
- Use hierarchical organization
- Group related parameters logically
- Use consistent naming conventions
- Document parameters with comments
- Example:
  ```yaml
  # Application settings
  app:
    port: 3838
    mode: "production"
    debug: false
  
  # Brand configuration  
  brand:
    name: "MAMBA"
    language: "zh_TW.UTF-8"
    parameters_folder: "app_data/parameters"
  ```

### Excel File Organization
- Store all Excel parameter files in the designated parameters folder
- Use descriptive filenames indicating the parameter domain
- Include a header row with clear column names
- First column should be a unique identifier when appropriate
- Example files:
  - `platform.xlsx` - Contains marketing channels, platforms
  - `product_line.xlsx` - Contains product information
  - `ui_terminology_dictionary.xlsx` - Contains UI translations

### Integration Pattern
All parameters should be loaded during initialization and integrated into a unified configuration object:

```r
# Standard pattern for parameter loading
load_all_parameters <- function(yaml_path = "app_config.yaml") {
  # 1. Load YAML configuration
  config <- yaml::read_yaml(yaml_path)
  
  # 2. Determine parameters folder
  params_folder <- if (!is.null(config$brand$parameters_folder)) {
    config$brand$parameters_folder
  } else {
    file.path("app_data", "parameters")
  }
  
  # 3. Load Excel parameter files
  excel_files <- list.files(params_folder, pattern = "\\.xlsx$", full.names = TRUE)
  
  # 4. Initialize parameters section
  config$parameters <- list()
  
  # 5. Process each Excel file
  for (file_path in excel_files) {
    file_name <- tools::file_path_sans_ext(basename(file_path))
    
    tryCatch({
      # Load Excel file
      data <- readxl::read_excel(file_path)
      
      # Store in config
      config$parameters[[file_name]] <- data
      
      # Special processing for specific parameter types
      process_special_parameters(config, file_name, data)
      
    }, error = function(e) {
      message("Error loading parameter file ", file_name, ": ", e$message)
    })
  }
  
  return(config)
}

# Process special parameter types that need integration with main config
process_special_parameters <- function(config, file_name, data) {
  # Platform-specific processing
  if (file_name == "platform" && all(c("marketing_channel", "marketing_channel_id") %in% colnames(data))) {
    # Create marketing channels list
    channels <- setNames(as.list(data$marketing_channel_id), data$marketing_channel)
    config$company$marketing_channels <- channels
    if (length(channels) > 0) {
      config$company$default_channel <- names(channels)[1]
    }
  }
  
  # Other special parameter processing can be added here
  
  return(config)
}
```

## Parameter Access Pattern
Access parameters using consistent patterns based on their source:

```r
# Access YAML-based configuration
debug_mode <- config$app$debug
app_language <- config$brand$language

# Access Excel-based parameters
marketing_channels <- config$company$marketing_channels  # Pre-processed
product_info <- config$parameters$product_line  # Raw data frame
ui_terms <- config$parameters$ui_terminology_dictionary
```

## Overriding Parameters
Parameters can be overridden in the following order of precedence:
1. Command-line arguments (highest priority)
2. Environment variables
3. Excel files
4. YAML configuration (lowest priority)

## Decision Framework for Configuration Format
When deciding between YAML and Excel for a specific parameter type, consider:

1. **Structure Determinism**:
   - If the structure is completely determined by a function or component:
     - Use YAML when the component defines all structure details
     - Use Excel when the structure is fixed but values frequently change
   
2. **Edit Frequency and Audience**:
   - Use Excel for configurations that:
     - Require frequent updates by non-developers
     - Benefit from spreadsheet-like editing
     - Need to be handed off to business users
   - Use YAML for configurations that:
     - Change rarely or only by developers
     - Are closely tied to application architecture
     - Require developer review for each change

3. **Content Complexity**:
   - Use Excel for:
     - Data with many rows of similar structure
     - Multi-language content with parallel translations
     - Complex relationships between items
   - Use YAML for:
     - Deeply nested structures
     - Configurations with many different property types
     - Hierarchical settings

For UI components like sidebars, if the structure is completely determined by rshinyapp_components and doesn't need frequent non-developer updates, YAML is typically the better choice.

## Related Principles
- P0017 (Config-Driven Customization)
- R0004 (App YAML Configuration)
- MP0011 (Sensible Defaults)
- MP0017 (Separation of Concerns)
- P0020 (Sidebar Filtering Only)
