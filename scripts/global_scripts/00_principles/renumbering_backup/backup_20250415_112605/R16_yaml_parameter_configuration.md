---
id: "R16"
title: "YAML Parameter Configuration Rule"
type: "rule"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
implements:
  - "P12": "app.R Is Global Principle"
  - "R04": "App YAML Configuration"
related_to:
  - "R18": "Defaults From Triple Rule"
  - "R15": "Initialization Sourcing Rule"
  - "MP17": "Separation of Concerns Principle"
---

# YAML Parameter Configuration Rule

## Core Requirement

Application parameters (configurable values) must be specified in YAML configuration files, focusing on positioning, connections, and behavior that varies between applications. When a parameter is not specified in YAML, it should default to nothing rather than using hardcoded values in app.R or server code. Components must handle undefined parameters gracefully using their Defaults component.

## Implementation Requirements

### 1. YAML Parameter Scope

YAML configuration should specify:

1. **Positioning Parameters**: Layout, order, and structural relationships
2. **Connection Parameters**: Data source connections, APIs, and integration points
3. **Behavior Parameters**: Configurable behaviors that vary between applications
4. **Appearance Parameters**: Theming, styling, and visual configuration
5. **Module Selection**: Which modules are enabled/disabled or included
6. **Integration Parameters**: How components connect to each other

### 2. Parameter Omission Handling

When parameters are omitted from YAML:

1. **Empty Default**: The parameter should default to nothing (NULL, empty string, etc.)
2. **Triple Defaults**: Components should fall back to values from their Defaults component
3. **Graceful Handling**: Components must function reasonably with missing parameters
4. **No Hardcoded Fallbacks**: No hardcoded fallbacks in app.R or server code

### 3. YAML Structure

YAML configuration should be structured:

1. **Hierarchically**: Following the application's component hierarchy
2. **Component-Based**: Organized by component rather than by function
3. **Environment-Aware**: Supporting different environments (dev, test, prod)
4. **Modular**: Supporting partial application of configuration
5. **Validated**: Validated against a schema or by initialization code

### 4. Configuration Loading

Configuration should be loaded:

1. **Early**: Before component initialization
2. **Validated**: With validation of required parameters
3. **Environment-Specific**: With environment-specific overrides
4. **Centralized**: From a single source of truth
5. **Cached**: Cached for performance when appropriate

## Implementation Examples

### Example 1: Proper YAML Parameter Configuration

**app_config.yaml:**
```yaml
title: "Precision Marketing App"
theme:
  version: 5
  bootswatch: "cerulean"

components:
  micro:
    sidebar_data:
      # Parameter positions specified, data will come from component defaults if empty
      position: "left"
      width: "300px"
    
    customer_profile:
      # Connection parameters
      data_source: "customer_db"
      table: "customer_profiles"
      
    # Note: No defaults specified in YAML
      
  macro:
    sidebar_data:
      position: "left"
      width: "300px"
    
    trends:
      # Behavior parameters
      parameters:
        refresh_interval: 300  # seconds
        # Note: Other parameters omitted, will use defaults from triple

environments:
  development:
    parameters:
      debug: true
  production:
    parameters:
      debug: false
```

**Component Using Configuration:**
```r
# Server component using configuration parameters
sidebarServer <- function(id, data_source = NULL, config = NULL) {
  moduleServer(id, function(input, output, session) {
    # Get defaults - always define defaults in the triple
    defaults <- sidebarDefaults()
    
    # Use config parameters if available, otherwise use defaults
    position <- if (!is.null(config) && !is.null(config$position)) {
      config$position
    } else {
      defaults$position  # From triple defaults
    }
    
    width <- if (!is.null(config) && !is.null(config$width)) {
      config$width
    } else {
      defaults$width  # From triple defaults
    }
    
    # Component implementation using position and width
    # ...
  })
}
```

**App.R Use of Configuration:**
```r
# Load configuration
config <- readYamlConfig("app_config.yaml")

# Server logic - pass configuration to components, no defaults in app.R
server <- function(input, output, session) {
  # Initialize sidebar with configuration parameters
  sidebarServer("app_sidebar", 
               data_source = reactive({ getDataSource() }),
               config = config$components$micro$sidebar_data)  # May be NULL
  
  # No hardcoded defaults in app.R
}
```

### Example 2: Incorrect Parameter Handling (Violates Rule)

```r
# INCORRECT: Hardcoded defaults in app.R
server <- function(input, output, session) {
  # Hardcoded fallback values in app.R (VIOLATES RULE)
  sidebar_config <- config$components$micro$sidebar_data
  if (is.null(sidebar_config)) {
    # INCORRECT: Default values should be in the triple, not here
    sidebar_config <- list(
      position = "left",
      width = "300px"
    )
  }
  
  # INCORRECT: Default parameters if not in configuration
  if (is.null(sidebar_config$position)) {
    sidebar_config$position <- "left"  # Should come from triple defaults
  }
  
  # Initialize sidebar with the potentially modified configuration
  sidebarServer("app_sidebar", 
               data_source = reactive({ getDataSource() }),
               config = sidebar_config)
}
```

## Common Errors and Solutions

### Error 1: Hardcoded Parameter Defaults in app.R

**Problem**: Setting default parameter values in app.R when they're not specified in YAML.

**Solution**: 
- Let parameters default to nothing (NULL) when not in YAML
- Rely on the Defaults component of the triple to handle undefined parameters
- Keep app.R free of default values
- Design components to work with missing parameters

### Error 2: Overly Specific YAML Configuration

**Problem**: YAML configuration includes details that should be in the component defaults.

**Solution**:
- Keep YAML focused on parameters that vary between applications
- Leave implementation details to the component's Defaults
- Don't duplicate default values in YAML
- Separate positioning/connections from implementation details

### Error 3: Inconsistent Parameter Handling

**Problem**: Different approaches to handling missing parameters across components.

**Solution**:
- Standardize parameter handling across all components
- Create helper functions for parameter extraction with defaults
- Document the expected parameter structure
- Test components with both specified and unspecified parameters

### Error 4: Complex Conditional Logic for Defaults

**Problem**: Complex conditional logic to handle various parameter configurations.

**Solution**:
- Design parameters to be simple and orthogonal
- Use parameter transformation functions to handle complex cases
- Avoid deep nesting of parameter structures
- Create helper functions for parameter normalization

## Relationship to Other Principles

### Relation to app.R Is Global Principle (P12)

This rule supports app.R Is Global by:
1. **Configuration-Driven**: Enabling configuration-driven customization without modifying app.R
2. **Portable Structure**: Keeping app.R free of implementation details and defaults
3. **Template Role**: Allowing app.R to serve as a template across applications
4. **Flexibility**: Supporting flexible application customization through YAML

### Relation to Defaults From Triple Rule (R18)

This rule complements Defaults From Triple by:
1. **Clear Boundary**: Establishing a clear boundary between parameters (YAML) and defaults (triple)
2. **Responsibility Assignment**: Assigning parameter configuration to YAML, defaults to triple
3. **Consistent Strategy**: Providing a consistent strategy for configuration and defaults
4. **Graceful Degradation**: Supporting graceful degradation when parameters are undefined

### Relation to Separation of Concerns Principle (MP17)

This rule supports Separation of Concerns by:
1. **Configuration vs. Implementation**: Separating configuration from implementation
2. **Parameters vs. Defaults**: Separating parameters from default values
3. **Application vs. Component**: Separating application concerns from component concerns
4. **Structure vs. Behavior**: Separating structural concerns from behavioral concerns

## Benefits

1. **Cleaner Application Code**: app.R and server code remain free of default values
2. **Clear Parameter Strategy**: Clear strategy for parameter specification
3. **Component Independence**: Components can function independently with or without configuration
4. **Configuration Flexibility**: Applications can be customized through configuration alone
5. **Consistent Parameter Handling**: Consistent approach to parameter handling across components
6. **Maintainable Configuration**: Configuration is easier to understand and maintain
7. **Resilient Components**: Components can handle missing or partial configuration
8. **Testing Simplicity**: Components can be tested with or without configuration

## Conclusion

The YAML Parameter Configuration Rule establishes a clear strategy for application configuration: parameters that vary between applications should be specified in YAML, while default values should reside in component triples. When parameters are not specified in YAML, they should default to nothing, with components falling back to their built-in defaults. This approach keeps app.R clean and focused on application structure, supports component independence, and enables configuration-driven customization.
