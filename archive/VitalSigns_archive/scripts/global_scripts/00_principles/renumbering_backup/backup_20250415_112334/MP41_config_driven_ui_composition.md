# MP41: Configuration-Driven UI Composition

## Definition
UI components should be dynamically generated from configuration files rather than hardcoded, with UI structure and behavior defined as a composition of functions that transform configuration into components. This principle establishes that the UI can be completely determined by a declarative configuration.

## Explanation
When UI structure is derived from configuration files:

1. The relationship between configuration and UI is a mathematical function where:
   - UI = f(Configuration)
   - Each UI element is the result of applying transformation functions to configuration nodes
   - The entire UI becomes a composition of these transformation functions

2. This functional approach provides several benefits:
   - Separates structure (what to show) from implementation (how to show it)
   - Enables non-developers to modify UI structure through configuration
   - Creates predictable, testable relationships between config and UI
   - Allows for runtime UI adaptation without code changes

## Implementation Guidelines

### 1. Configuration as the Single Source of Truth

```yaml
# Configuration defines what components exist
components:
  micro:
    customer_profile:
      primary: customer_details
      history: customer_history
    sales: sales_by_customer_dta
  
  macro:
    trends:
      data_source: sales_trends
      parameters:
        show_kpi: true
```

```r
# UI is derived from configuration through function composition
ui <- configToUI(read_yaml("app_config.yaml"))

# More explicitly as function composition:
ui <- compose(
  read_config,    # f(config_path) -> config
  parse_sections, # g(config) -> section_configs
  map_to_ui,      # h(section_configs) -> ui_components
  create_union    # j(ui_components) -> final_ui
)("app_config.yaml")
```

### 2. Component Generators as Higher-Order Functions

Component generators are functions that take configuration and return UI components:

```r
# A higher-order function that generates UI based on config
microComponentGenerator <- function(config) {
  function(id) {
    # Generate UI based on config
    fluidRow(
      column(
        width = 12,
        if ("customer_profile" %in% names(config)) {
          div(...)  # Profile component
        },
        if ("sales" %in% names(config)) {
          div(...)  # Sales component
        }
      )
    )
  }
}

# Generate specific micro component from config
myMicroUI <- microComponentGenerator(config$components$micro)
```

### 3. Complete Functional Derivation

The entire UI can be derived from configuration with no hardcoded structure:

```r
# Create UI by applying component generators to config sections
ui_components <- lapply(names(config$components), function(section) {
  # Get the appropriate generator for this section
  generator <- component_generators[[section]]
  # Apply the generator to this section's config
  generator(config$components[[section]])
})

# Create union of components
oneTimeUnionUI(
  !!!ui_components,
  id = "main_content"
)
```

## Mathematical Foundation

This principle extends MP28 (NSQL Set Theory Foundations) by adding functional composition and state transformation:

1. **Set Operations**: UI components form sets that can be combined with union (∪) operations
2. **Function Composition**: Configuration is transformed to UI through function composition
3. **Functors**: Higher-order functions map configuration structures to UI structures
4. **State Transformation**: Processes are functions that transform states

### Functional Composition Formalism

Mathematically:
- Let C be the configuration space
- Let U be the UI component space
- Define a transformation function T: C → U
- For any configuration c ∈ C, the UI is T(c) ∈ U
- The transformation T is typically a composition T = T₃ ∘ T₂ ∘ T₁

### State Transformation Formalism

The UI generation pipeline can be viewed as a series of state transformations:
1. State₁ (config_path) → State₂ (config) via read_yaml
2. State₂ (config) → State₃ (component_defs) via config_to_component_defs
3. State₃ (component_defs) → State₄ (ui_components) via component_defs_to_ui
4. State₄ (ui_components) → State₅ (union_component) via ui_to_union

Each transformation is a pure function f(State₁) → State₂ that takes one state as input and produces a new state as output. The entire UI generation process is the composition of these state transformers.

```
UI = (ui_to_union ∘ component_defs_to_ui ∘ config_to_component_defs ∘ read_yaml)(config_path)
```

## Benefits

1. **Declarative Definition**: UI structure is defined declaratively in configuration
2. **Separation of Concerns**: Structure (what) is separated from presentation (how)
3. **Runtime Adaptability**: UI can adapt to configuration changes without code changes
4. **Testability**: Functions that transform config to UI can be unit tested
5. **Consistency**: Ensures consistent UI patterns across the application

## Anti-Patterns

### 1. Mixed Configuration and Hardcoding

Avoid:
```r
# Bad: Some structure from config, some hardcoded
ui <- fluidPage(
  configToHeader(config$header),
  # Hardcoded components not derived from config
  tabPanel("Hardcoded Tab", div(...)),
  configToFooter(config$footer)
)
```

### 2. Partial Derivation

Avoid:
```r
# Bad: Only using config for simple values, not structure
ui <- fluidPage(
  titlePanel(config$title),
  # Structure still hardcoded
  sidebarLayout(
    sidebarPanel(...),
    mainPanel(...)
  )
)
```

### 3. Direct Configuration Access

Avoid:
```r
# Bad: Directly accessing config throughout the codebase
ui <- fluidPage(
  if (config$components$micro$customer_profile$primary) {
    div(...)
  }
)
```

Instead:
```r
# Good: Using component generators
ui <- fluidPage(
  componentGenerator(config$components$micro)(id)
)
```

## Related Principles

- MP28: NSQL Set Theory Foundations
- MP39: One-Time Operations During Initialization
- P22: CSS Controls Over Shiny Conditionals
- MP16: Modularity
- R04: App YAML Configuration
- R16: YAML Parameter Configuration