# Rule 58: Global Parameter Organization

## Core Rule
Global parameters shared across multiple applications must be defined in Excel files within `global_scripts/parameters`, while application-specific implementations reference these global parameters through YAML configurations in their respective app directories.

## Implementation Guidelines

### Directory Structure
1. **Global Parameters Location**
   ```
   /update_scripts/global_scripts/parameters/
   ├── platform.xlsx
   ├── product_line.xlsx
   ├── ui_terminology_dictionary.xlsx
   └── [other shared parameter files].xlsx
   ```

2. **App-Specific Configuration Location**
   ```
   /precision_marketing_[APP_NAME]/precision_marketing_app/
   └── app_config.yaml
   ```

### Parameter File Responsibilities

#### Global Parameter Files (Excel)
- Core domain entities and their attributes
- Shared reference data (products, platforms, regions)
- Translation dictionaries
- Classification systems
- Entity relationships
- ID schemes and naming conventions

#### App-Specific Configuration (YAML)
- Which global parameters to use
- How to present shared entities
- App-specific behavior and settings
- Environmental configuration
- UI component selection and arrangement
- Feature toggles and customizations

### Reference Pattern
App-specific YAML should reference global Excel files:

```yaml
# In app_config.yaml
parameters:
  global_sources:
    product_line: "../global_scripts/parameters/product_line.xlsx"
    platform: "../global_scripts/parameters/platform.xlsx"
    ui_dictionary: "../global_scripts/parameters/ui_terminology_dictionary.xlsx"
  
  display:
    product_categories:
      enabled: true
      default: "000"  # "All Products"
      max_visible: 10
    
    platforms:
      enabled: true
      exclude: ["999"]  # Exclude "Other" platform
```

### Loading Sequence
1. Load global Excel parameters first
2. Apply app-specific YAML configurations second
3. Override with environment-specific settings if needed

```r
# Loading sequence
load_configuration <- function() {
  # 1. Load global parameters from Excel
  global_params <- load_global_excel_parameters("../global_scripts/parameters/")
  
  # 2. Load app-specific YAML
  app_config <- yaml::read_yaml("app_config.yaml")
  
  # 3. Merge configurations, with app-specific taking precedence
  config <- merge_configurations(global_params, app_config)
  
  # 4. Apply any environment-specific overrides
  config <- apply_environment_overrides(config)
  
  return(config)
}
```

## Benefits
1. **Single Source of Truth**: Domain entities defined once, used everywhere
2. **Reduced Duplication**: No need to maintain separate copies of reference data
3. **Consistency**: All apps use the same core definitions
4. **Flexibility**: Apps can customize how they use shared parameters
5. **Maintainability**: Update shared data in one place, affects all apps

## Example Implementation

### Global Excel File (product_line.xlsx)
```
| product_line_id | product_line_name_english | product_line_name_chinese |
|----------------|--------------------------|---------------------------|
| 000            | All Products             | 所有產品                   |
| 001            | Kitchen Tools            | 廚房工具                  |
| 002            | Cookware                 | 炊具                     |
| 003            | Small Appliances        | 小家電                    |
```

### App-Specific YAML (app_config.yaml)
```yaml
# Kitchen MAMA App configuration
app:
  name: "Kitchen MAMA"
  language: "zh_TW.UTF-8"

# Product display configuration
products:
  categories:
    source: "../global_scripts/parameters/product_line.xlsx"
    visible_categories: ["000", "001", "002"]  # Show only these categories
    default_category: "000"                    # Default to "All Products"
    order_by: "product_line_id"                # Sort order
  
  # Platform display configuration
  platforms:
    source: "../global_scripts/parameters/platform.xlsx"
    exclude_platforms: ["004", "005"]          # Hide certain platforms
```

## Related Rules and Principles
- P18 (Dual Parameter Sources)
- R08 (Global Scripts Synchronization)
- MP17 (Separation of Concerns)
- P17 (Config-Driven Customization)