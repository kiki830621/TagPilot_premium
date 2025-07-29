---
id: "R0015"
title: "Defaults From Triple Rule"
type: "rule"
date_created: "2025-04-03"
date_modified: "2025-04-03"
author: "Claude"
implements:
  - "P0012": "app.R Is Global Principle"
  - "R0011": "UI-Server-Defaults Triple Rule"
related_to:
  - "MP0017": "Separation of Concerns Principle"
  - "R0015": "Initialization Sourcing Rule"
---

# Defaults From Triple Rule

## Core Requirement

All default values, placeholder data, and fallback options must be defined in the Defaults component of the UI-Server-Defaults triple, not in the app.R file, YAML configuration, or other application code. While parameters (configurable values) should be specified in YAML configuration, the actual defaults when parameters are unspecified must reside in the Defaults component. The app.R file should focus solely on structure and composition, relying on the triple components for implementation details including default values.

## Implementation Requirements

### 1. Default Values Placement

Default values must be placed in:

1. **Defaults Component**: All default values must be defined in the Defaults component file (e.g., `componentDefaults.R`)
2. **Defaults Function**: Default values must be returned by a function in the Defaults component
3. **Component-Specific Defaults**: Each component must have its own Defaults component with relevant defaults
4. **Comprehensive Coverage**: Defaults must be provided for all inputs, outputs, and reactives used by the component

### 2. Prohibited Default Values Locations

Default values must NOT be defined in:

1. **App.R File**: The main application file should not contain any default values
2. **UI Component**: The UI component should reference defaults, not define them
3. **Server Component**: The server component should use defaults when needed, not define them
4. **Global Variables**: Default values should not be stored in global variables

### 3. Default Values vs. Configuration Parameters

There is a clear distinction between defaults and parameters:

1. **Defaults (in Triple)**: Fallback values when parameters are not specified
   - Must be defined in the Defaults component file
   - Should provide sensible, working values
   - Handle all possible undefined parameter scenarios
   - Allow components to function without external configuration

2. **Parameters (in YAML)**: Configurable values that override defaults
   - Should be specified in YAML configuration
   - Define positioning, connections, and customizable behavior
   - May be omitted, in which case defaults from the triple apply
   - Focus on what needs to change between applications

3. **Default Parameter Handling**: When parameters are not specified in YAML
   - The parameter should default to nothing rather than a hardcoded value
   - The Defaults component should handle this gracefully
   - Never set default parameter values in app.R or server code

### 4. Default Values Usage

Default values should be used:

1. **When Data is Unavailable**: As fallbacks when expected data sources are unavailable
2. **When Parameters are Undefined**: When YAML configuration omits specific parameters
3. **For Demonstration**: As sample data for demonstration purposes
4. **During Development**: As placeholders during development
5. **For Testing**: As consistent test data for component testing

### 5. Default Values Structure

Default values should be structured as:

1. **Typed Returns**: Return types that match what UI and server components expect
2. **Comprehensive Objects**: Complete objects with all required properties
3. **Realistic Values**: Realistic-looking data rather than empty or placeholder content
4. **Internationalized Content**: Content in the appropriate language(s) for the application
5. **Graceful Degradation**: Values that allow a component to work with limited functionality

## Implementation Examples

### Example 1: Proper Defaults in Triple Structure

**SidebarDefaults.R:**
```r
sidebarDefaults <- function() {
  list(
    # Default product categories
    product_categories = list(
      "服裝 (Clothing)" = "clothing",
      "電子產品 (Electronics)" = "electronics",
      "家居用品 (Home Goods)" = "homegoods"
    ),
    
    # Default geographic regions
    geographic_regions = list(
      "全部 (All)" = "all",
      "北部 (North)" = "north",
      "南部 (South)" = "south"
    ),
    
    # Default customer segments
    customer_segments = list(
      "高價值忠誠客戶 (High-Value Loyal)" = "high_value_loyal",
      "休眠顧客 (Dormant)" = "dormant",
      "新顧客 (New Customers)" = "new_customers"
    )
  )
}
```

**SidebarServer.R (Using Defaults):**
```r
sidebarServer <- function(id, data_source = NULL) {
  moduleServer(id, function(input, output, session) {
    # Get defaults
    defaults <- sidebarDefaults()
    
    # Update UI with data or defaults
    observe({
      product_data <- if (!is.null(data_source) && !is.null(data_source$products)) {
        data_source$products()
      } else {
        NULL
      }
      
      if (!is.null(product_data) && nrow(product_data) > 0) {
        # Use actual data
        categories <- setNames(
          as.list(product_data$category_id),
          product_data$category_name
        )
      } else {
        # Use defaults when data is unavailable
        categories <- defaults$product_categories
      }
      
      updateSelectInput(session, "product_category", choices = categories)
    })
  })
}
```

**App.R (No Defaults):**
```r
ui <- page_navbar(
  title = config$title,
  
  nav_panel(
    title = "Micro Analysis",
    page_sidebar(
      sidebar = sidebarUI("app_sidebar"),
      microCustomerUI("customer_module")
    )
  )
)

server <- function(input, output, session) {
  # Initialize sidebar with data source
  sidebarServer("app_sidebar", data_source = reactive({
    # Get data from configuration or database
    # No defaults here - those come from sidebarDefaults
    list(
      products = function() { productData() },
      regions = function() { regionData() }
    )
  }))
  
  # Initialize customer module
  microCustomerServer("customer_module", data_source = customerData)
}
```

### Example 2: Incorrect Default Values in App (Violates Rule)

```r
# INCORRECT: Default values defined in app.R
ui <- page_navbar(
  title = config$title,
  
  nav_panel(
    title = "Micro Analysis",
    page_sidebar(
      sidebar = sidebarUI("app_sidebar"),
      microCustomerUI("customer_module")
    )
  )
)

server <- function(input, output, session) {
  # INCORRECT: Default values defined directly in server function
  default_products <- data.frame(
    category_id = c("electronics", "clothing", "homegoods"),
    category_name = c("電子產品", "服裝", "家居用品")
  )
  
  default_regions <- data.frame(
    region_id = c("north", "south", "east", "west"),
    region_name = c("北部", "南部", "東部", "西部")
  )
  
  # Initialize sidebar with default values in the data source
  sidebarServer("app_sidebar", data_source = reactive({
    list(
      # INCORRECT: Using default values defined in app.R
      products = function() { default_products },
      regions = function() { default_regions }
    )
  }))
}
```

## Common Errors and Solutions

### Error 1: Hardcoded Defaults in App.R

**Problem**: Default values are hardcoded directly in the app.R file.

**Solution**: 
- Move all default values to the Defaults component
- Reference defaults through the component's default function
- Use data sources in app.R that can fall back to defaults when needed

### Error 2: Incomplete Defaults

**Problem**: Default values don't cover all inputs and outputs used by a component.

**Solution**:
- Ensure default values are comprehensive
- Create sample data that represents realistic use cases
- Test components with just default values to ensure completeness

### Error 3: Inconsistent Default Structure

**Problem**: Default values don't match the expected structure in UI and server components.

**Solution**:
- Align default structure with the expected data structure
- Use the same typing and naming conventions as the actual data
- Document the expected structure in the Defaults component

### Error 4: Global Default Values

**Problem**: Using global variables for default values.

**Solution**:
- Encapsulate default values in component-specific functions
- Avoid global variables for defaults
- Use function closures to maintain state if needed

## Relationship to Other Principles

### Relation to app.R Is Global Principle (P0012)

This rule supports app.R Is Global by:
1. **Removing Details**: Removing implementation details like default values from app.R
2. **Focusing on Structure**: Keeping app.R focused on structure and composition
3. **Portability**: Making app.R more portable across applications
4. **Separation of Concerns**: Separating application structure from component implementation

### Relation to UI-Server-Defaults Triple Rule (R0011)

This rule implements the UI-Server-Defaults Triple Rule by:
1. **Proper Usage**: Ensuring proper usage of the Defaults component
2. **Complete Triple**: Reinforcing the importance of all three components
3. **Clear Responsibilities**: Clarifying the responsibility of each component
4. **Consistency**: Ensuring consistency across all UI-Server-Defaults triples

### Relation to Separation of Concerns Principle (MP0017)

This rule supports Separation of Concerns by:
1. **Data vs. Structure**: Separating data concerns from structural concerns
2. **Defaults vs. Live Data**: Separating default values from live data
3. **Component Independence**: Supporting component independence through self-contained defaults
4. **Testing Isolation**: Enabling isolated testing of components with defaults

## Benefits

1. **Cleaner App Code**: App.R remains clean and focused on structure
2. **Component Independence**: Components are more self-contained and independent
3. **Better Testing**: Components can be tested in isolation with defaults
4. **Easier Maintenance**: Default values are centralized and easier to update
5. **Resilient Components**: Components function even when data is unavailable
6. **Consistent Experience**: Users see consistent placeholders when data is loading
7. **Development Efficiency**: Developers can work on components without real data
8. **Documentation**: Default values serve as documentation of expected data structure

## Conclusion

The Defaults From Triple Rule ensures that all default values, placeholder data, and fallback options are defined in the Defaults component of the UI-Server-Defaults triple, not in the app.R file. This approach keeps the app.R file clean and focused on application structure, while making components more self-contained, testable, and resilient. By following this rule, developers create applications that are easier to maintain, test, and extend.
