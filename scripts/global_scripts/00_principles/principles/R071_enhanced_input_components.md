# R0071: Enhanced Input Components Rule

## Purpose
This rule establishes that enhanced input components (such as selectizeInput, pickerInput) should be used in place of their basic counterparts (like selectInput, checkboxInput) throughout the application UI to ensure consistency, better user experience, and improved functionality.

## Implementation

### 1. Select Component Substitution

Always use enhanced select components instead of basic ones:

| Instead of | Use |
|------------|-----|
| `selectInput()` | `selectizeInput()` |
| `selectInput(selectize=FALSE)` | `selectizeInput()` |
| Standard `<select>` HTML tags | `selectizeInput()` |

```r
# INCORRECT: Basic select input
selectInput("category", "Select Category:", choices = categories)

# CORRECT: Enhanced select input
selectizeInput("category", "Select Category:", choices = categories)
```

### 2. Configuration for Different Dataset Sizes

Configure selectizeInput differently based on dataset size (as specified in P0075):

#### Small Datasets (<100 products)
```r
selectizeInput(
  "small_dataset",
  "Select product:",
  choices = small_dataset,
  options = list(
    placeholder = "Select an product...",
    searchField = c("label", "value"),
    render = I("{
      option: function(product, escape) {
        return '<div>' + escape(product.label) + '</div>';
      }
    }")
  )
)
```

#### Medium Datasets (100-1,000 products)
```r
selectizeInput(
  "medium_dataset",
  "Select product:",
  choices = medium_dataset,
  options = list(
    placeholder = "Type to search...",
    maxOptions = 10,
    searchField = c("label", "value"),
    render = I("{
      option: function(product, escape) {
        return '<div>' + escape(product.label) + '</div>';
      }
    }")
  )
)
```

#### Large Datasets (>1,000 products)
```r
selectizeInput(
  "large_dataset",
  "Select product:",
  choices = NULL, # Will be populated server-side
  options = list(
    placeholder = "Type to search...",
    loadThrottle = 300,
    maxOptions = 10,
    searchField = c("label", "value")
  )
)

# With server-side handler
observe({
  query <- input$large_dataset_search
  if (is.null(query) || nchar(query) < 2) return()
  
  # Search logic here...
  results <- search_dataset(query)
  
  updateSelectizeInput(session, "large_dataset", choices = results)
})
```

### 3. Required Configuation Parameters

All selectizeInput components should include these basic configurations:

```r
selectizeInput(
  "input_id",
  "Label:",
  choices = dataset,
  options = list(
    placeholder = "Descriptive placeholder...",
    searchField = c("label", "value"),  # Fields to search in
    maxOptions = 10,                   # Limit displayed options
    render = I("{
      option: function(product, escape) {
        return '<div>' + escape(product.label) + '</div>';
      }
    }")
  )
)
```

### 4. Other Enhanced Input Types

Apply the same principle to other input types:

| Basic Component | Enhanced Alternative |
|-----------------|----------------------|
| `checkboxInput()` | `shinyWidgets::prettyCheckbox()` |
| `radioButtons()` | `shinyWidgets::prettyRadioButtons()` |
| `sliderInput()` | `shinyWidgets::sliderTextInput()` (when appropriate) |
| `dateInput()` | `shinyWidgets::airDatepickerInput()` |

## Exceptions

The following exceptions are permitted:

1. **Legacy Code**: Existing code may continue to use basic inputs but should be updated incrementally
2. **Performance-Critical Sections**: When performance testing shows significant benefits to using simpler components
3. **Specialized Requirements**: Cases where the enhanced components lack specific needed functionality
4. **Preview/Demo Versions**: Simple prototypes or demos that will be improved before production

## Benefits

1. **Consistency**: Creates a consistent user experience throughout the application
2. **User Experience**: Provides better search, filtering, and selection capabilities
3. **Accessibility**: Enhanced components often have better accessibility features
4. **Mobile Usability**: Better experience on mobile and touch devices
5. **Search Performance**: More efficient searching, especially for large datasets
6. **Visual Appearance**: More modern and professional UI

## Relationship to Other Rules and Principles

### Implements and Extends

1. **P0075 (Search Input Optimization)**: Formalizes the component selection guidance from P75
2. **P0072 (UI Package Consistency)**: Extends UI consistency to input components specifically
3. **P0070 (Complete Input Display)**: Supports showing all options with visual indicators

### Related Rules

1. **R0010 (Package Consistency Naming)**: Complements the consistent usage of packages
2. **P0026 (Reactive Requirement Validation)**: Enhanced inputs work better with validation
3. **P0022 (CSS Over Conditional Controls)**: Enhanced inputs use styling for states

## Verification Process

1. **Visual Inspection**: Review UI components for compliance
2. **Code Review**: Check input component usage in UI definitions
3. **Prototype Testing**: Verify performance with large datasets

## Additional Guidelines

1. **Documentation**: Document any custom configurations in code comments
2. **Helper Functions**: Create helper functions for frequently used configurations
3. **Standard Options**: Maintain a central list of standard configuration options
4. **Style Consistency**: Ensure all enhanced inputs follow the same styling guidelines

#LOCK FILE
