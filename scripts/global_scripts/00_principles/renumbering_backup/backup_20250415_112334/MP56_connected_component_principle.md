---
id: "MP56"
title: "Connected Component Principle"
type: "meta-principle"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Development Team"
extends:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
  - "MP52": "Unidirectional Data Flow"
requires:
  - "MP44": "Functor Module Correspondence"
key_terms:
  - connected component
  - graph theory
  - cohesive module
  - edge nodes
  - state propagation
---

# MP56: Connected Component Principle

## Core Statement

Application modules should be designed as connected components in the graph theory sense — cohesive units where all internal elements are interconnected through data flows or event paths, with well-defined edge nodes that serve as the exclusive interface to external components.

## Rationale

Designing modules as connected components creates clear boundaries, improves maintainability, enhances reusability, and enables precise reasoning about application behavior. This approach:

1. **Enforces Encapsulation**: Ensures internal implementations remain hidden
2. **Clarifies Dependencies**: Makes relationships between system parts explicit
3. **Reduces Coupling**: Limits communication to well-defined interfaces
4. **Enables Reasoning**: Allows formal analysis of component properties
5. **Simplifies Testing**: Provides clear boundaries for test isolation

## Graph Theory Foundation

The principle applies concepts from graph theory to software architecture:

### 1. Graph Elements
- **Vertices (Nodes)**: Individual elements in a component (UI elements, functions, data structures)
- **Edges**: Connections between elements (data flows, event handlers, dependencies)
- **Connected Component**: A subgraph where any two vertices are connected by a path
- **Edge Nodes**: Vertices that interface with elements outside the component
- **Cut Set**: Minimal set of edges that, when removed, disconnect the component from external systems

### 2. Graph Properties
- **Cohesion**: How strongly connected vertices are within the component
- **Coupling**: Number and strength of connections to external components
- **Reachability**: Whether one vertex can affect another through some path
- **Dependency Direction**: Direction of data or control flow between vertices

## Implementation Framework

### 1. Component Identification

Identify connected components by analyzing:

- **Functional Cohesion**: Elements that work together to implement a single feature
- **Data Cohesion**: Elements that operate on the same data structures
- **Flow Cohesion**: Elements connected through the flow of data or events
- **Temporal Cohesion**: Elements that operate at the same time or lifecycle phase
- **Interface Isolation**: Ability to define clear boundaries with external systems

### 2. Component Boundaries

Establish clear boundaries by:

- **Minimizing Cut Sets**: Reduce the number of connections to external systems
- **Defining Edge Nodes**: Create explicit interface elements for external communication
- **Containing State**: Keep state variables within component boundaries
- **Isolating Effects**: Ensure side effects remain contained within the component
- **Controlling Event Propagation**: Manage how events enter and leave the component

### 3. Internal Structure

Design robust internal structure by:

- **Ensuring Connectivity**: Every element should be reachable from other elements
- **Avoiding Isolates**: Don't include disconnected elements in the component
- **Balancing Cohesion**: Elements should have appropriate levels of interconnection
- **Optimizing Paths**: Consider data and event flow efficiency
- **Managing Complexity**: Limit the number of vertices and edges to maintain clarity

### 4. External Interface

Create well-defined interfaces through:

- **Input Edge Nodes**: Define specific points where external events enter
- **Output Edge Nodes**: Define specific points where data or events exit
- **Parameter Passing**: Use explicit parameters rather than shared state
- **Contract Definition**: Document expected inputs and outputs
- **Invariant Preservation**: Maintain internal consistency regardless of inputs

## Implementation Patterns

### 1. UI-Server Connected Component Pattern

```r
# Defines a UI-Server connected component
myComponentModule <- function(id) {
  # Create namespace
  ns <- NS(id)
  
  # Return component parts
  list(
    # UI Edge Nodes (Input/Output Interface)
    ui = function() {
      div(
        # Input Edges (where external events enter)
        textInput(ns("input_text"), "Enter value"),
        selectInput(ns("input_option"), "Choose option", choices = c("A", "B", "C")),
        
        # Output Edges (where information leaves)
        plotOutput(ns("result_plot")),
        textOutput(ns("summary_text"))
      )
    },
    
    # Server Logic (Internal Vertices and Edges)
    server = function(input, output, session) {
      # Internal state vertices
      current_data <- reactiveVal(NULL)
      processing_status <- reactiveVal("idle")
      
      # Internal computation vertices
      processed_result <- reactive({
        req(current_data())
        # Internal processing
        process_data(current_data(), input$input_option)
      })
      
      # Event handling edges
      observeEvent(input$input_text, {
        # State transition
        processing_status("processing")
        
        # Update internal state
        current_data(parse_input(input$input_text))
        
        # Mark processing complete
        processing_status("complete")
      })
      
      # Output generation edges
      output$result_plot <- renderPlot({
        req(processed_result())
        create_visualization(processed_result())
      })
      
      output$summary_text <- renderText({
        req(processed_result())
        summarize_result(processed_result())
      })
      
      # Return reactive values for testing or composition
      list(
        result = processed_result,
        status = processing_status
      )
    }
  )
}
```

### 2. State Machine Component Pattern

```r
# Creates a component that implements a state machine
createStateMachineComponent <- function(id, initial_state = "idle") {
  ns <- NS(id)
  
  list(
    ui = function() {
      div(
        # State transition inputs
        actionButton(ns("event_a"), "Trigger Event A"),
        actionButton(ns("event_b"), "Trigger Event B"),
        actionButton(ns("reset"), "Reset"),
        
        # State visualization
        div(
          textOutput(ns("current_state")),
          uiOutput(ns("state_content"))
        )
      )
    },
    
    server = function(input, output, session) {
      # Central state vertex
      state <- reactiveVal(initial_state)
      
      # Transition function - internal vertex
      transition <- function(current, event) {
        # State transition logic
        if (current == "idle" && event == "a") return("state_a")
        if (current == "idle" && event == "b") return("state_b")
        if (current == "state_a" && event == "b") return("state_ab")
        if (current == "state_b" && event == "a") return("state_ba")
        if (event == "reset") return("idle")
        return(current)  # No transition
      }
      
      # Event handling edges
      observeEvent(input$event_a, {
        state(transition(state(), "a"))
      })
      
      observeEvent(input$event_b, {
        state(transition(state(), "b"))
      })
      
      observeEvent(input$reset, {
        state(transition(state(), "reset"))
      })
      
      # Output generation edges
      output$current_state <- renderText({
        paste("Current State:", state())
      })
      
      output$state_content <- renderUI({
        # Render different content based on state
        switch(state(),
               "idle" = div("System is idle. Trigger an event."),
               "state_a" = div("In State A", style = "color: blue"),
               "state_b" = div("In State B", style = "color: green"),
               "state_ab" = div("In State A→B", style = "color: purple"),
               "state_ba" = div("In State B→A", style = "color: orange"),
               div("Unknown state", style = "color: red")
        )
      })
      
      # Return state for composition
      return(list(
        current_state = state
      ))
    }
  )
}
```

### 3. Data Flow Component Pattern

```r
# Creates a component focused on data flow transformation
createDataFlowComponent <- function(id) {
  ns <- NS(id)
  
  list(
    ui = function() {
      div(
        # Input edge nodes
        fileInput(ns("data_input"), "Upload Data"),
        
        # Processing options
        selectInput(ns("transform_type"), "Transformation",
                   choices = c("Filter", "Aggregate", "Normalize")),
        
        # Parameter inputs
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Filter'", ns("transform_type")),
          textInput(ns("filter_expr"), "Filter Expression")
        ),
        
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Aggregate'", ns("aggregate_type")),
          selectInput(ns("aggregate_func"), "Aggregation Function",
                     choices = c("sum", "mean", "median", "count"))
        ),
        
        # Output edge nodes
        plotOutput(ns("result_viz")),
        downloadButton(ns("download_data"), "Download Results")
      )
    },
    
    server = function(input, output, session) {
      # Input data vertex
      raw_data <- reactive({
        req(input$data_input)
        read_csv(input$data_input$datapath)
      })
      
      # Processing vertices
      filtered_data <- reactive({
        req(raw_data())
        
        if (input$transform_type == "Filter" && nzchar(input$filter_expr)) {
          filter_expr <- rlang::parse_expr(input$filter_expr)
          return(filter(raw_data(), !!filter_expr))
        }
        return(raw_data())
      })
      
      transformed_data <- reactive({
        req(filtered_data())
        
        if (input$transform_type == "Aggregate" && !is.null(input$aggregate_func)) {
          # Apply aggregation
          group_by(filtered_data(), across(where(is.factor))) %>%
            summarize(across(where(is.numeric), input$aggregate_func))
        } else if (input$transform_type == "Normalize") {
          # Apply normalization
          mutate(filtered_data(), 
                 across(where(is.numeric), 
                        ~scale(.x)))
        } else {
          filtered_data()
        }
      })
      
      # Output generation edges
      output$result_viz <- renderPlot({
        req(transformed_data())
        
        if (ncol(transformed_data()) >= 2) {
          ggplot(transformed_data()) +
            geom_point(aes(x = .data[[names(transformed_data())[1]]], 
                           y = .data[[names(transformed_data())[2]]]))
        } else {
          ggplot(transformed_data()) +
            geom_histogram(aes(x = .data[[names(transformed_data())[1]]]))
        }
      })
      
      output$download_data <- downloadHandler(
        filename = function() {
          paste0("transformed_data_", Sys.Date(), ".csv")
        },
        content = function(file) {
          write_csv(transformed_data(), file)
        }
      )
      
      # Return transformed data for composition
      return(list(
        data = transformed_data
      ))
    }
  )
}
```

## Application Across Component Types

### 1. UI Components

- **Vertices**: UI elements, event handlers, state variables
- **Edges**: Event propagation, state updates, rendering flows
- **Edge Nodes**: Input controls, output displays
- **Properties**: Visual cohesion, interaction flow, state consistency

### 2. Data Processing Components

- **Vertices**: Data structures, transformation functions, validation rules
- **Edges**: Data flows, transformation sequences, dependency relationships
- **Edge Nodes**: Data inputs, processed outputs, error channels
- **Properties**: Data integrity, processing efficiency, transformation correctness

### 3. State Management Components

- **Vertices**: State variables, transition functions, validators
- **Edges**: State transitions, event handlers, side effects
- **Edge Nodes**: Event inputs, state outputs, notification channels
- **Properties**: State consistency, transition validity, invariant preservation

## Verification Methods

### 1. Graph Analysis

Verify connected component properties through:

- **Reachability Analysis**: Ensure all vertices are reachable from entry points
- **Cut Set Identification**: Identify and minimize external connection points
- **Cycle Detection**: Identify and manage circular dependencies
- **Path Analysis**: Verify data and control flow paths

### 2. Component Testing

Test connected components through:

- **Edge Node Testing**: Verify inputs and outputs at interface boundaries
- **State Transition Testing**: Verify internal state transitions
- **Isolation Testing**: Test component behavior in isolation
- **Integration Testing**: Verify correct interaction with external components

## Relationship to Other Principles

This meta-principle builds upon:

- **MP16 (Modularity)**: By providing formal criteria for module boundaries
- **MP17 (Separation of Concerns)**: By clarifying which concerns belong together
- **MP52 (Unidirectional Data Flow)**: By formalizing data flow directionality

And requires implementation of:

- **MP44 (Functor Module Correspondence)**: To ensure components can compose appropriately

## Benefits

1. **Enhanced Modularity**: Clear boundaries between system parts
2. **Improved Reusability**: Components can be used in different contexts
3. **Simplified Testing**: Components can be tested in isolation
4. **Better Reasoning**: Formal properties can be verified
5. **Reduced Coupling**: Components interact through minimal interfaces
6. **Clearer Dependencies**: Relationships between components are explicit

## Implementation Checklist

To apply this meta-principle to your application:

1. [ ] Identify logical cohesive units of functionality
2. [ ] Map vertices (elements) and edges (connections) within each unit
3. [ ] Verify connectedness (all elements can affect each other)
4. [ ] Identify edge nodes (interface points to external systems)
5. [ ] Minimize cut sets (reduce external connection points)
6. [ ] Define clear contracts for edge node interactions
7. [ ] Ensure internal state remains encapsulated
8. [ ] Document component graph structure

## Examples

### DNA Distribution Component Example

The KitchenMAMA application's DNA distribution visualization component demonstrates this principle:

1. **Component Graph Structure**:
   ```
                       ┌─────────────┐
                       │  DNA Data   │
                       └──────┬──────┘
                              │
                              ▼
   ┌─────────┐       ┌───────────────┐       ┌──────────────┐
   │ M_ecdf  │ ─────►│ M ECDF        │       │              │
   │ Button  │       │ Observer      │       │              │
   └─────────┘       └───────┬───────┘       │              │
                              │               │              │
   ┌─────────┐       ┌───────────────┐       │              │
   │ R_ecdf  │ ─────►│ R ECDF        │       │              │
   │ Button  │       │ Observer      │       │              │
   └─────────┘       └───────┬───────┘       │              │
                              │               │              │
   ┌─────────┐       ┌───────────────┐       │  DNA_Macro   │
   │ F_ecdf  │ ─────►│ F ECDF        │ ─────►│  _plot       │
   │ Button  │       │ Observer      │       │  Output      │
   └─────────┘       └───────┬───────┘       │              │
                              │               │              │
   ┌─────────┐       ┌───────────────┐       │              │
   │ IPT_ecdf│ ─────►│ IPT ECDF      │       │              │
   │ Button  │       │ Observer      │       │              │
   └─────────┘       └───────┬───────┘       │              │
                              │               │              │
   ┌─────────┐       ┌───────────────┐       │              │
   │F_barplot│ ─────►│ F Barplot     │ ─────►│              │
   │ Button  │       │ Observer      │       │              │
   └─────────┘       └───────┬───────┘       └──────────────┘
                              │
   ┌─────────┐       ┌───────────────┐
   │NES_bar  │ ─────►│ NES Barplot   │
   │ Button  │       │ Observer      │
   └─────────┘       └───────────────┘
   ```

2. **Connected Properties**:
   - **Vertices**: Action buttons, observers, plot output
   - **Edges**: Event flows, data transformations
   - **Edge Nodes**: Input buttons, plot output
   - **Cut Set**: The data input and plot output interfaces

3. **Implementation as Connected Component**:
   ```r
   # UI Edge Nodes
   actionButton(inputId = "M_ecdf", label = "購買金額(M)"),
   actionButton(inputId = "R_ecdf", label = "最近購買日(R)"),
   actionButton(inputId = "F_ecdf", label = "購買頻率(F)"),
   # ... other buttons
   
   # Output Edge Node
   plotlyOutput(outputId = "DNA_Macro_plot")
   
   # Inside Component - Event Handling
   observeEvent(input$M_ecdf, {
     # Internal state update
     current_visualization("M_ecdf")
     
     # Internal transformation
     ecdf_data <- calculate_ecdf(dna_data$m_value)
     
     # Output generation
     output$DNA_Macro_plot <- renderPlotly({
       create_ecdf_plot(ecdf_data, "購買金額(M)")
     })
   })
   ```

This component demonstrates:
- Clear boundary between internal implementation and external interface
- State encapsulation within the component
- Single responsibility (visualizing DNA distributions)
- Minimal interface (buttons in, visualization out)

By treating it as a connected component, this visualization module becomes reusable, maintainable, and can be reasoned about as a cohesive unit.