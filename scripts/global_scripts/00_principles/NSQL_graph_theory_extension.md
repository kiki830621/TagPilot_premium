# NSQL Graph Theory Extension

## Overview

This document extends the Natural Structured Query Language (NSQL) with graph theory terminology to support the connected component principle (MP56) and enable formal reasoning about application structure through graph-based concepts.

## Graph Theory Types and Operators

### New Type Definitions

```
TYPE Vertex = Element ID and properties
TYPE Edge = Connection between vertices with optional direction and weight
TYPE Graph = Collection of vertices and edges
TYPE Path = Ordered sequence of vertices connected by edges
TYPE Component = Subgraph where all vertices are connected by some path
```

### Graph Definition Syntax

```
GRAPH(name) {
  VERTICES {
    name: properties,
    ...
  }
  EDGES {
    source -> destination [: properties],
    ...
  }
}
```

### Component Identification

```
COMPONENT(component_name) FROM graph_name {
  ENTRY_POINTS: [vertex_ids]
  EXIT_POINTS: [vertex_ids]
  INTERNAL_VERTICES: [vertex_ids]
}
```

### Path Expression

```
PATH(path_name) FROM source TO destination {
  // Path definition or constraints
  MAX_LENGTH: n
  AVOID: [vertex_ids]
  REQUIRE: [vertex_ids]
}
```

## Application Flow Documentation

### Module Structure Documentation

```
MODULE(module_name) {
  // Graph structure definition
  GRAPH {
    VERTICES {
      // UI elements, data structures, functions
      "input_control": { type: "input", subtype: "text" },
      "process_function": { type: "function" },
      "output_display": { type: "output", subtype: "plot" }
    }
    
    EDGES {
      // Data and control flows
      "input_control" -> "process_function": { type: "event" },
      "process_function" -> "output_display": { type: "data_flow" }
    }
  }
  
  // Component boundaries
  COMPONENT {
    ENTRY_POINTS: ["input_control"],
    EXIT_POINTS: ["output_display"],
    INTERNAL: ["process_function"]
  }
}
```

### Flow Documentation

```
FLOW(flow_name) {
  // Event-driven flow definition
  TRIGGER: [event_source]
  
  VERTICES {
    // Flow-specific vertices
    "user_input": { type: "input" },
    "validation": { type: "function" },
    "transformation": { type: "function" },
    "storage": { type: "data_store" },
    "notification": { type: "output" }
  }
  
  EDGES {
    // Flow topology
    "user_input" -> "validation": { condition: "always" },
    "validation" -> "transformation": { condition: "valid_input" },
    "validation" -> "notification": { condition: "invalid_input" },
    "transformation" -> "storage": { condition: "always" },
    "storage" -> "notification": { condition: "always" }
  }
  
  // Graph properties
  PROPERTIES {
    "cyclical": false,
    "guaranteed_termination": true,
    "critical_path": ["user_input", "validation", "transformation", "storage"]
  }
}
```

## State Machine Documentation

```
STATE_MACHINE(name) {
  STATES {
    "idle": { type: "initial" },
    "processing": { type: "transient" },
    "success": { type: "terminal" },
    "error": { type: "terminal" }
  }
  
  TRANSITIONS {
    "idle" -> "processing": { event: "start_process", guard: "input_valid" },
    "processing" -> "success": { event: "process_complete", guard: "no_errors" },
    "processing" -> "error": { event: "process_error" },
    "error" -> "idle": { event: "reset" },
    "success" -> "idle": { event: "reset" }
  }
}
```

## Component Interconnection

```
SYSTEM(system_name) {
  COMPONENTS {
    "component_a": { type: "input_processor" },
    "component_b": { type: "data_transformer" },
    "component_c": { type: "output_generator" }
  }
  
  CONNECTIONS {
    "component_a.output" -> "component_b.input": { type: "data_flow" },
    "component_b.result" -> "component_c.data_source": { type: "data_flow" },
    "component_c.status" -> "component_a.feedback": { type: "event" }
  }
  
  // Cut sets between components
  CUT_SETS {
    "a_to_b": ["component_a.output", "component_b.input"],
    "b_to_c": ["component_b.result", "component_c.data_source"],
    "feedback_loop": ["component_c.status", "component_a.feedback"]
  }
}
```

## Graph Analysis Operations

```
// Find all paths between two vertices
PATHS = FIND_PATHS(graph, source, destination)

// Calculate graph metrics
METRICS = ANALYZE_GRAPH(graph) {
  "connectivity": CONNECTIVITY_SCORE,
  "cyclical": HAS_CYCLES,
  "diameter": MAX_PATH_LENGTH,
  "centrality": {
    vertex_id: centrality_score,
    ...
  }
}

// Identify connected components
COMPONENTS = FIND_COMPONENTS(graph)

// Find minimum cut set
CUT_SET = FIND_MIN_CUT(graph, source_set, destination_set)
```

## Example: DNA Distribution Component

```
// Define the DNA Distribution component as a graph
COMPONENT(dna_distribution) {
  GRAPH {
    VERTICES {
      // UI Elements
      "m_ecdf_button": { type: "ui_element", subtype: "button" },
      "r_ecdf_button": { type: "ui_element", subtype: "button" },
      "f_ecdf_button": { type: "ui_element", subtype: "button" },
      "ipt_ecdf_button": { type: "ui_element", subtype: "button" },
      "f_barplot_button": { type: "ui_element", subtype: "button" },
      "nes_barplot_button": { type: "ui_element", subtype: "button" },
      "plot_output": { type: "ui_element", subtype: "plot" },
      
      // Internal Logic
      "m_ecdf_handler": { type: "event_handler" },
      "r_ecdf_handler": { type: "event_handler" },
      "f_ecdf_handler": { type: "event_handler" },
      "ipt_ecdf_handler": { type: "event_handler" },
      "f_barplot_handler": { type: "event_handler" },
      "nes_barplot_handler": { type: "event_handler" },
      
      // Data and State
      "dna_data": { type: "data_source" },
      "current_state": { type: "state" }
    }
    
    EDGES {
      // Event flows from buttons to handlers
      "m_ecdf_button" -> "m_ecdf_handler": { type: "event" },
      "r_ecdf_button" -> "r_ecdf_handler": { type: "event" },
      "f_ecdf_button" -> "f_ecdf_handler": { type: "event" },
      "ipt_ecdf_button" -> "ipt_ecdf_handler": { type: "event" },
      "f_barplot_button" -> "f_barplot_handler": { type: "event" },
      "nes_barplot_button" -> "nes_barplot_handler": { type: "event" },
      
      // Data flows
      "dna_data" -> "m_ecdf_handler": { type: "data_flow" },
      "dna_data" -> "r_ecdf_handler": { type: "data_flow" },
      "dna_data" -> "f_ecdf_handler": { type: "data_flow" },
      "dna_data" -> "ipt_ecdf_handler": { type: "data_flow" },
      "dna_data" -> "f_barplot_handler": { type: "data_flow" },
      "dna_data" -> "nes_barplot_handler": { type: "data_flow" },
      
      // Output flows
      "m_ecdf_handler" -> "plot_output": { type: "render" },
      "r_ecdf_handler" -> "plot_output": { type: "render" },
      "f_ecdf_handler" -> "plot_output": { type: "render" },
      "ipt_ecdf_handler" -> "plot_output": { type: "render" },
      "f_barplot_handler" -> "plot_output": { type: "render" },
      "nes_barplot_handler" -> "plot_output": { type: "render" },
      
      // State updates
      "m_ecdf_handler" -> "current_state": { type: "state_update" },
      "r_ecdf_handler" -> "current_state": { type: "state_update" },
      "f_ecdf_handler" -> "current_state": { type: "state_update" },
      "ipt_ecdf_handler" -> "current_state": { type: "state_update" },
      "f_barplot_handler" -> "current_state": { type: "state_update" },
      "nes_barplot_handler" -> "current_state": { type: "state_update" }
    }
  }
  
  // Define component boundaries
  BOUNDARIES {
    ENTRY_POINTS: [
      "m_ecdf_button", "r_ecdf_button", "f_ecdf_button", 
      "ipt_ecdf_button", "f_barplot_button", "nes_barplot_button"
    ],
    EXIT_POINTS: ["plot_output"],
    DATA_SOURCES: ["dna_data"]
  }
  
  // Define the component's state machine
  STATE_MACHINE {
    STATES {
      "idle": { type: "initial" },
      "m_ecdf_active": { type: "active" },
      "r_ecdf_active": { type: "active" },
      "f_ecdf_active": { type: "active" },
      "ipt_ecdf_active": { type: "active" },
      "f_barplot_active": { type: "active" },
      "nes_barplot_active": { type: "active" }
    }
    
    TRANSITIONS {
      "idle" -> "m_ecdf_active": { event: "m_ecdf_click" },
      "idle" -> "r_ecdf_active": { event: "r_ecdf_click" },
      "idle" -> "f_ecdf_active": { event: "f_ecdf_click" },
      "idle" -> "ipt_ecdf_active": { event: "ipt_ecdf_click" },
      "idle" -> "f_barplot_active": { event: "f_barplot_click" },
      "idle" -> "nes_barplot_active": { event: "nes_barplot_click" },
      
      "m_ecdf_active" -> "r_ecdf_active": { event: "r_ecdf_click" },
      "m_ecdf_active" -> "f_ecdf_active": { event: "f_ecdf_click" },
      // ... other transitions
    }
  }
}
```

## Integration with Existing NSQL Features

This graph theory extension integrates with the core NSQL language:

```
// Data flow can reference graph components
DATA_FLOW(component: customer_filter) {
  GRAPH {
    VERTICES {
      "app_data_connection": { type: "data_source" },
      "dna_data": { type: "transformed_data" },
      "profiles": { type: "transformed_data" },
      "valid_ids": { type: "transformed_data" },
      "dropdown_options": { type: "ui_data" }
    }
    
    EDGES {
      "app_data_connection" -> "dna_data": { operation: "EXTRACT" },
      "app_data_connection" -> "profiles": { operation: "EXTRACT" },
      "dna_data" -> "valid_ids": { operation: "DISTINCT" },
      "profiles" -> "dropdown_options": { operation: "FILTER", condition: "customer_id IN valid_ids" }
    }
  }
  
  SOURCE: app_data_connection
  INITIALIZE: {
    EXTRACT(app_data_connection → GET dna_data → dna_data)
    EXTRACT(app_data_connection → GET customer_profiles → profiles)
    EXTRACT(dna_data → DISTINCT customer_id → valid_ids)
    FILTER(profiles → WHERE customer_id IN valid_ids → dropdown_options)
  }
  // ... rest of the data flow
}
```

## Benefits of Graph Theory Extension

1. **Formal Component Definition**: Precise definition of component boundaries
2. **Flow Visualization**: Clear documentation of data and event flows
3. **Property Verification**: Ability to verify component properties (connectivity, cyclicality)
4. **System Analysis**: Tools for reasoning about system-wide behaviors
5. **Interface Documentation**: Explicit documentation of component interfaces
6. **Optimization Opportunities**: Identification of critical paths and bottlenecks

## Implementation Guidelines

1. Document component structures using graph theory notation
2. Verify connectedness of components during design
3. Identify and minimize cut sets between components
4. Ensure state is properly contained within components
5. Validate that all elements within a component are reachable