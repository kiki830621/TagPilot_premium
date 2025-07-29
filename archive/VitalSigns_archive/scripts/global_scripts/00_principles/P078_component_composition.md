---
id: "P0078"
title: "Component Composition"
type: "principle"
date_created: "2025-04-09"
author: "Claude"
derives_from:
  - "MP0016": "Modularity Principle"
  - "MP0017": "Separation of Concerns"
influences:
  - "R0009": "UI-Server-Defaults Triple"
related_to:
  - "P0007": "App Bottom-Up Construction"
  - "MP0052": "Unidirectional Data Flow"
---

# P0078: Component Composition Principle

## Core Principle

Applications should be constructed by composing smaller, specialized components with well-defined interfaces. Component composition must follow consistent patterns for communication, nesting, and state sharing while maintaining clear boundaries and responsibilities.

## Composition Patterns

### 1. Hierarchical Composition

Components should be organized in a clear hierarchy:

1. **Root Components**: Top-level application containers that manage routing and global state
2. **Section Components**: Components that represent major application sections
3. **Feature Components**: Components that implement specific features
4. **Base Components**: Reusable atomic components that provide fundamental UI elements

```
App                        # Root Component
├── Dashboard              # Section Component
│   ├── MetricsPanel       # Feature Component  
│   │   ├── MetricCard     # Base Component
│   │   └── TrendChart     # Base Component
│   └── ActivityFeed       # Feature Component
└── Settings               # Section Component
    ├── UserProfile        # Feature Component
    └── Preferences        # Feature Component
```

### 2. Communication Patterns

Components should communicate using these patterns:

1. **Parent-Child Props**: Parents pass data and callbacks to children
2. **Child-Parent Events**: Children notify parents of changes via callbacks
3. **Sibling Communication**: Siblings communicate through shared parent state
4. **Distant Communication**: Distant components communicate through shared services or state

### 3. Composition Types

Different composition types serve different purposes:

1. **Containment Composition**: Parent wraps children and controls their arrangement
2. **Specialization Composition**: Components extend or specialize other components
3. **Functional Composition**: Components combine to create a functional chain
4. **Layout Composition**: Components combine to create layout structures

## Implementation Guidelines

### 1. Component Interface Design

Components should have clear, consistent interfaces:

```r
#' Metric Card Component UI
#'
#' @param id Module ID
#' @param title Card title
#' @param icon Optional icon name
#' @param color Card theme color
#' @param elevation Card elevation (1-5)
#'
#' @return UI element
#' @export
metricCardUI <- function(id, title, icon = NULL, color = "default", elevation = 3) {
  ns <- NS(id)
  
  card(
    id = ns("card"),
    class = paste0("metric-card metric-card-", color),
    style = paste0("--card-elevation: ", elevation, "px;"),
    
    # Card header with title and icon
    card_header(
      div(class = "metric-card-header",
        if (!is.null(icon)) icon(icon) else NULL,
        h4(title)
      )
    ),
    
    # Card body with metric value (rendered by server)
    card_body(
      div(class = "metric-value-container",
        textOutput(ns("value")),
        div(class = "metric-trend", 
          uiOutput(ns("trend"))
        )
      )
    )
  )
}

#' Metric Card Component Server
#'
#' @param id Module ID
#' @param value_provider Reactive expression that provides the value to display
#' @param previous_value_provider Optional reactive for previous value (for trend)
#' @param formatter Function to format the value (default: format with commas)
#'
#' @return Reactive list with card state
#' @export
metricCardServer <- function(
  id, 
  value_provider, 
  previous_value_provider = NULL,
  formatter = function(x) format(x, big.mark = ",")
) {
  moduleServer(id, function(input, output, session) {
    # Get current value
    current_value <- reactive({
      req(value_provider())
      value_provider()
    })
    
    # Render the value
    output$value <- renderText({
      formatter(current_value())
    })
    
    # Calculate and render trend if previous value is provided
    output$trend <- renderUI({
      # Skip if no previous value provider
      if (is.null(previous_value_provider)) return(NULL)
      
      req(previous_value_provider())
      prev_value <- previous_value_provider()
      curr_value <- current_value()
      
      if (is.na(prev_value) || is.na(curr_value) || prev_value == 0) {
        return(NULL)
      }
      
      # Calculate percent change
      pct_change <- (curr_value - prev_value) / abs(prev_value) * 100
      
      # Determine direction and appearance
      if (pct_change > 0) {
        div(class = "trend positive",
          icon("arrow-up"),
          sprintf("%.1f%%", pct_change)
        )
      } else if (pct_change < 0) {
        div(class = "trend negative",
          icon("arrow-down"),
          sprintf("%.1f%%", abs(pct_change))
        )
      } else {
        div(class = "trend neutral",
          icon("minus"),
          "0.0%"
        )
      }
    })
    
    # Return reactive values
    return(list(
      value = current_value
    ))
  })
}
```

### 2. Composition Implementation

#### Parent-Child Composition
```r
#' Dashboard Metrics Panel UI
#'
#' @param id Module ID
#' @return UI element
#' @export
dashboardMetricsPanelUI <- function(id) {
  ns <- NS(id)
  
  div(class = "metrics-panel",
    h3("Key Metrics"),
    
    div(class = "metrics-grid",
      # Composed metric cards with different configurations
      metricCardUI(ns("revenue"), "Total Revenue", icon = "dollar-sign", color = "primary"),
      metricCardUI(ns("customers"), "Active Customers", icon = "users", color = "success"),
      metricCardUI(ns("orders"), "New Orders", icon = "shopping-cart"),
      metricCardUI(ns("conversion"), "Conversion Rate", icon = "percentage", color = "info")
    )
  )
}

#' Dashboard Metrics Panel Server
#'
#' @param id Module ID
#' @param data_source Reactive data source
#' @return Reactive list with panel state
#' @export
dashboardMetricsPanelServer <- function(id, data_source) {
  moduleServer(id, function(input, output, session) {
    # Current period data
    current_data <- reactive({
      req(data_source())
      data_source()$current
    })
    
    # Previous period data
    previous_data <- reactive({
      req(data_source())
      data_source()$previous
    })
    
    # Initialize child components 
    revenue <- metricCardServer("revenue", 
      value_provider = reactive({ current_data()$total_revenue }),
      previous_value_provider = reactive({ previous_data()$total_revenue }),
      formatter = function(x) paste0("$", format(x, big.mark = ","))
    )
    
    customers <- metricCardServer("customers",
      value_provider = reactive({ current_data()$active_customers }),
      previous_value_provider = reactive({ previous_data()$active_customers })
    )
    
    orders <- metricCardServer("orders", 
      value_provider = reactive({ current_data()$new_orders }),
      previous_value_provider = reactive({ previous_data()$new_orders })
    )
    
    conversion <- metricCardServer("conversion", 
      value_provider = reactive({ current_data()$conversion_rate * 100 }),
      previous_value_provider = reactive({ previous_data()$conversion_rate * 100 }),
      formatter = function(x) paste0(format(x, nsmall = 1, digits = 1), "%")
    )
    
    # Return panel state
    return(list(
      metrics = reactive({
        list(
          revenue = revenue$value(),
          customers = customers$value(),
          orders = orders$value(),
          conversion = conversion$value()
        )
      })
    ))
  })
}
```

#### Specialization Composition
```r
#' Create a specialized version of a component
#'
#' @param base_component Base component function to specialize
#' @param default_args Default arguments to override
#' @return A new component function with preset defaults
#' @export
specialize_component <- function(base_component, default_args) {
  function(...) {
    # Combine provided args with defaults, with provided args taking precedence
    args <- c(list(...), default_args[!names(default_args) %in% names(list(...))])
    do.call(base_component, args)
  }
}

# Create specialized versions of the metric card
successMetricCard <- specialize_component(metricCardUI, 
  list(color = "success", elevation = 4, icon = "check-circle")
)

warningMetricCard <- specialize_component(metricCardUI, 
  list(color = "warning", elevation = 2, icon = "exclamation-triangle")
)

# Usage in a component
div(
  successMetricCard(id = ns("completion"), title = "Completion Rate"),
  warningMetricCard(id = ns("errors"), title = "Error Count")
)
```

#### Functional Composition
```r
#' Data processing pipeline composition
#'
#' @param data_source Reactive data source
#' @param transformations List of transformation functions to apply
#' @return Reactive expression with transformed data
#' @export
compose_data_pipeline <- function(data_source, transformations) {
  # Create a reactive pipeline
  result <- reactive({
    # Start with the source data
    current_data <- data_source()
    
    # Skip if no data or no transformations
    if (is.null(current_data) || length(transformations) == 0) {
      return(current_data)
    }
    
    # Apply each transformation in sequence
    for (transform_fn in transformations) {
      current_data <- transform_fn(current_data)
    }
    
    return(current_data)
  })
  
  return(result)
}

# Usage in a component
data_pipeline <- compose_data_pipeline(
  data_source = raw_data,
  transformations = list(
    function(data) { filter(data, region %in% input$selected_regions) },
    function(data) { mutate(data, revenue_per_customer = revenue / customers) },
    function(data) { arrange(data, desc(revenue_per_customer)) }
  )
)
```

#### Layout Composition
```r
#' Create a two-column layout
#'
#' @param left_component UI for left column
#' @param right_component UI for right column
#' @param left_width Width of left column (1-12)
#' @param container_class Additional CSS class for container
#' @return UI element
#' @export
twoColumnLayout <- function(left_component, right_component, left_width = 4, container_class = "") {
  right_width <- 12 - left_width
  
  fluidRow(
    class = paste("two-column-layout", container_class),
    
    column(left_width, left_component),
    column(right_width, right_component)
  )
}

# Usage
twoColumnLayout(
  left_component = filterPanelUI(ns("filters")),
  right_component = dataTableUI(ns("results")),
  left_width = 3,
  container_class = "data-explorer"
)
```

### 3. State Management in Composition

#### Passing State Down
```r
#' Parent component that passes state down
parentComponentServer <- function(id, data_source) {
  moduleServer(id, function(input, output, session) {
    # Process data for all children
    processed_data <- reactive({
      req(data_source())
      process_data(data_source())
    })
    
    # Set up filtering
    filtered_data <- reactive({
      req(processed_data())
      filter_data(processed_data(), input$filter_criteria)
    })
    
    # Initialize child components with the processed data
    child1 <- child1Server("child1", filtered_data)
    child2 <- child2Server("child2", filtered_data)
    
    # Handle child interactions if needed
    observe({
      req(child1$selected_item())
      # React to child state changes
    })
  })
}
```

#### Lifting State Up
```r
#' Child component that lifts state up to parent
childComponentServer <- function(id, data_source) {
  moduleServer(id, function(input, output, session) {
    # Local state
    selected_item <- reactiveVal(NULL)
    
    # Handle selection
    observeEvent(input$select, {
      item_id <- input$select
      item_data <- data_source()[data_source()$id == item_id, ]
      selected_item(item_data)
    })
    
    # Return selected item to parent
    return(list(
      selected_item = selected_item
    ))
  })
}

#' Parent component that receives lifted state
parentComponentServer <- function(id, data_source) {
  moduleServer(id, function(input, output, session) {
    # Initialize child component
    child <- childComponentServer("child", data_source)
    
    # Use lifted state from child
    selected_details <- reactive({
      req(child$selected_item())
      generate_details(child$selected_item())
    })
    
    # Use the lifted state
    output$details <- renderUI({
      req(selected_details())
      # Render details
    })
  })
}
```

## Composition Anti-patterns

### 1. Tightly Coupled Components
**Problem**: Components with implicit dependencies on parent or sibling implementation details
**Solution**: Define clear interfaces and use dependency injection

### 2. Prop Drilling
**Problem**: Passing props through many intermediate components that don't use them
**Solution**: Use composition patterns to avoid deep prop drilling

### 3. Mega-Components
**Problem**: Large components that try to do too much
**Solution**: Break into smaller, focused components with single responsibilities

### 4. Global State Abuse
**Problem**: Using global state for component-specific concerns
**Solution**: Keep state at the appropriate level in the component hierarchy

### 5. Poor Boundary Definition
**Problem**: Unclear responsibility boundaries between parent and child components
**Solution**: Clearly define which component owns what data and behavior

## Benefits of Component Composition

1. **Reusability**: Well-composed components can be reused across the application
2. **Maintainability**: Smaller, focused components are easier to understand and maintain
3. **Testability**: Components with clear interfaces are easier to test in isolation
4. **Developer Efficiency**: Composition speeds development through reuse and consistency
5. **Flexibility**: Well-composed systems can be reconfigured more easily
6. **Separation of Concerns**: Composition naturally encourages separation of concerns

## Relationship to Other Principles

This principle:

1. **Extends MP0016 (Modularity Principle)** by providing specific patterns for component composition
2. **Implements MP0017 (Separation of Concerns)** through component boundary definition
3. **Supports P0007 (App Bottom-Up Construction)** by defining how bottom-up components combine
4. **Complements MP0052 (Unidirectional Data Flow)** by defining how data flows between components

## Common Composition Patterns

### 1. Container/Presentational Pattern
Separate data management from presentation:

```r
#' Presentational component - just renders UI, no data handling
userCardUI <- function(id) {
  ns <- NS(id)
  div(class = "user-card",
    div(class = "user-avatar", uiOutput(ns("avatar"))),
    div(class = "user-info",
      h4(textOutput(ns("name"))),
      p(textOutput(ns("role"))),
      p(textOutput(ns("email")))
    )
  )
}

#' Container component - handles data fetching/processing
userCardContainer <- function(id, user_id) {
  ui <- userCardUI(id)
  
  server <- function(id) {
    moduleServer(id, function(input, output, session) {
      # Fetch user data
      user_data <- reactive({
        req(user_id())
        get_user_data(user_id())
      })
      
      # Render user details
      output$avatar <- renderUI({
        req(user_data())
        img(src = user_data()$avatar_url, alt = "User avatar")
      })
      
      output$name <- renderText({
        req(user_data())
        user_data()$name
      })
      
      output$role <- renderText({
        req(user_data())
        user_data()$role
      })
      
      output$email <- renderText({
        req(user_data())
        user_data()$email
      })
    })
  }
  
  list(ui = ui, server = server)
}
```

### 2. Higher-Order Component Pattern
Enhance components with additional functionality:

```r
#' Add loading state to any component
#'
#' @param component_ui UI function for the component
#' @param data_source Reactive data source to check
#' @return Enhanced UI function
#' @export
withLoading <- function(component_ui) {
  function(id, ...) {
    ns <- NS(id)
    
    div(class = "with-loading",
      # Loading overlay
      div(id = ns("loading_overlay"), class = "loading-overlay",
        div(class = "loading-spinner",
          icon("spinner", class = "fa-spin"),
          "Loading..."
        )
      ),
      
      # The wrapped component
      component_ui(id, ...)
    )
  }
}

#' Server-side implementation of loading state
#'
#' @param component_server Server function for the component
#' @param data_source Reactive data source to check
#' @return Enhanced server function
#' @export
withLoadingServer <- function(component_server, data_source) {
  function(id, ...) {
    moduleServer(id, function(input, output, session) {
      # Show/hide loading based on data availability
      observe({
        is_loading <- is.null(data_source()) || isTRUE(attr(data_source(), "loading", exact = TRUE))
        
        if (is_loading) {
          shinyjs::show(id = "loading_overlay")
        } else {
          shinyjs::hide(id = "loading_overlay")
        }
      })
      
      # Initialize the wrapped component
      component_server(id, ...)
    })
  }
}

# Usage
UserCardWithLoading <- withLoading(userCardUI)
userCardWithLoadingServer <- withLoadingServer(userCardServer, user_data)
```

### 3. Provider Pattern
Share state across a component tree:

```r
#' Create a data provider
#'
#' @param data_source Reactive data source
#' @return List with provider_context and consumer functions
#' @export
createDataProvider <- function(data_source) {
  # Create a reactive context for the provider
  context <- reactiveValues(data = NULL)
  
  # Update context when data source changes
  observe({
    context$data <- data_source()
  })
  
  # Create consumer function
  consumer <- function() {
    reactive({ context$data })
  }
  
  # Return provider context and consumer functions
  list(
    provider_context = context,
    consumer = consumer
  )
}

# Usage in a component hierarchy
app_server <- function(input, output, session) {
  # Create data provider
  data_provider <- createDataProvider(fetch_app_data())
  
  # Create consumer function
  get_data <- data_provider$consumer
  
  # Initialize components with the consumer
  component1Server("comp1", get_data())
  component2Server("comp2", get_data())
}
```

## Conclusion

The Component Composition Principle establishes patterns for building complex applications from smaller, focused components. By following consistent composition patterns, developers can create maintainable, reusable, and testable components that can be combined to create rich user experiences while maintaining clear boundaries and responsibilities.
