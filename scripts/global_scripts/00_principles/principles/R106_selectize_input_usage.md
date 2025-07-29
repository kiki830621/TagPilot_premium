# R106: Selectize Input Usage Rule

## Purpose

This rule establishes standard approaches for implementing and customizing selectize inputs in Shiny applications, ensuring consistency, performance, and user experience across all selection components.

## Definitions

- **Selectize Input**: An enhanced select input based on the selectize.js JavaScript library that provides search capability, custom rendering, and better user experience for selection interfaces.
- **Client-side Selectize**: Implementation where all options are loaded to the client and filtering is handled by JavaScript.
- **Server-side Selectize**: Implementation where option filtering is performed on the server based on user input.

## Requirements

### 1. Selection Method Determination

1.1. **Base Selection Rule**: Use standard `selectInput()` for simple selection scenarios with fewer than 20 options.

1.2. **Selectize Requirement**: Use `selectizeInput()` when any of these conditions apply:
   - Selection list contains more than 20 options
   - Users need to search within options
   - Custom option rendering is needed
   - Multiple selections with tags are required

1.3. **Server-side Requirement**: Use server-side selectize when:
   - Selection list contains more than 100 options
   - Options need to be dynamically filtered from database or large datasets
   - Performance optimization is critical

### 2. Initialization Standards

2.1. **Client-side Initialization**:
```r
selectizeInput(
  inputId = "selection_id",
  label = "Selection Label",
  choices = option_list,
  selected = default_option,
  multiple = FALSE,
  options = list(
    placeholder = "Select an option...",
    onDropdownOpen = I("function($dropdown) { /* consistency code */ }")
  )
)
```

2.2. **Server-side Initialization**:
```r
# In UI
selectizeInput(
  inputId = "selection_id",
  label = "Selection Label",
  choices = NULL,  # Empty initially
  multiple = FALSE,
  options = list(placeholder = "Start typing to search...")
)

# In Server
updateSelectizeInput(
  session = session,
  inputId = "selection_id",
  choices = full_option_dataset,
  server = TRUE,
  options = list(
    maxOptions = 15,
    searchField = c("label", "keywords"),
    searchConjunction = "and"
  )
)
```

### 3. Core Configuration Standards

3.1. **Required Option Settings**:
   - Always specify a `placeholder` option
   - Always set `maxOptions` to limit displayed products (default: 15)
   - For multiple selection, set `maxproducts` to establish selection limits

3.2. **Performance Configuration**:
   - Use `selectize_throttle = 300` for server-side inputs to limit request frequency 
   - Set `load_throttle = 300` to control search timing

3.3. **UI Consistency Options**:
```r
options = list(
  plugins = list("remove_button"),
  render = selectize_render_template,
  onDropdownOpen = I(standard_dropdown_js),
  onDropdownClose = I(standard_cleanup_js)
)
```

### 4. Custom Rendering Requirements

4.1. **Standard Render Function**:
```r
selectize_render_template <- I('{
  option: function(product, escape) {
    return "<div class=\"selectize-option\">" +
      "<span class=\"option-label\">" + escape(product.label) + "</span>" +
      (product.description ? "<span class=\"option-description\">" + 
        escape(product.description) + "</span>" : "") +
      "</div>";
  },
  product: function(product, escape) {
    return "<div class=\"selectize-selected-product\">" + 
      escape(product.label) + "</div>";
  }
}')
```

4.2. **Rich Content**:

When displaying images or complex content in options:
```r
options = list(
  render = I('{
    option: function(product, escape) {
      return "<div class=\"rich-option\">" +
        "<img src=\"" + escape(product.image_url) + "\" class=\"option-image\" />" +
        "<div class=\"option-text\">" +
          "<div class=\"option-title\">" + escape(product.label) + "</div>" +
          "<div class=\"option-subtitle\">" + escape(product.subtitle) + "</div>" +
        "</div>" +
      "</div>";
    }
  }')
)
```

### 5. Data Structure Requirements

5.1. **Standard Structure**: Client-side selectize data should be prepared as:
```r
choices <- c("Option 1" = "value1", "Option 2" = "value2")
```

5.2. **Rich Data Structure**: For server-side filtering with extended information:
```r
choices_df <- data.frame(
  label = c("Option 1", "Option 2"),
  value = c("value1", "value2"),
  description = c("Description 1", "Description 2"),
  keywords = c("key1 alt1", "key2 alt2"),
  stringsAsFactors = FALSE
)
```

### 6. Event Handling Requirements

6.1. **Standard Observers**:
```r
observeEvent(input$selection_id, {
  req(input$selection_id)
  if(input$selection_id == "") {
    # Handle empty selection case
  } else {
    # Handle selection 
  }
})
```

6.2. **Loading States**:
```r
# Show loading indicator during server-side filtering
options = list(
  onType = I('function() { 
    Shiny.setInputValue("selection_id_loading", true);
  }'),
  onLoad = I('function() {
    Shiny.setInputValue("selection_id_loading", false);
  }')
)
```

## Examples

### Basic Client-side Example

```r
selectizeInput(
  inputId = "state",
  label = "Select State:",
  choices = state.name,
  options = list(
    placeholder = "Select a state...",
    maxOptions = 10,
    plugins = list("remove_button")
  )
)
```

### Server-side Filtering Example

```r
# UI
selectizeInput(
  "customer_id", 
  "Select Customer:",
  choices = NULL,
  options = list(placeholder = "Start typing customer name...")
)

# Server
customer_data <- reactive({
  universal_data_accessor(connection, "customer_profile") %>%
    select(
      value = customer_id, 
      label = customer_name,
      keywords = search_terms
    )
})

observe({
  updateSelectizeInput(
    session, 
    "customer_id",
    choices = customer_data(),
    server = TRUE,
    options = list(
      valueField = "value",
      labelField = "label",
      searchField = c("label", "keywords"),
      maxOptions = 15
    )
  )
})
```

### Advanced Rendering Example

```r
# UI
selectizeInput(
  "product_id", 
  "Select Product:",
  choices = NULL,
  options = list(placeholder = "Search products...")
)

# Server
updateSelectizeInput(
  session, 
  "product_id",
  choices = product_data,
  server = TRUE,
  options = list(
    valueField = "id",
    labelField = "name",
    searchField = c("name", "description", "sku"),
    render = I('{
      option: function(product, escape) {
        return "<div class=\"product-option\">" +
          "<div class=\"product-image\">" +
            "<img src=\"" + escape(product.image_url) + "\" />" +
          "</div>" +
          "<div class=\"product-details\">" +
            "<div class=\"product-name\">" + escape(product.name) + "</div>" +
            "<div class=\"product-sku\">SKU: " + escape(product.sku) + "</div>" +
            "<div class=\"product-price\">$" + product.price.toFixed(2) + "</div>" +
          "</div>" +
        "</div>";
      },
      product: function(product, escape) {
        return "<div class=\"selected-product\">" + 
          "<span class=\"product-name\">" + escape(product.name) + "</span> " +
          "<span class=\"product-sku\">(" + escape(product.sku) + ")</span>" +
        "</div>";
      }
    }')
  )
})
```

## Related Principles and Rules

- **R102**: Shiny Reactive Observation Rule
- **P77**: Performance Optimization
- **P75**: Search Input Optimization
- **P71**: Row Aligned Tables
- **SLN05**: Avoiding Nested UI Rendering in Shiny

## Implementation Notes

1. Always wrap JavaScript functions with `I()` to prevent R from escaping the content
2. Use consistent CSS classes for styling selectize components
3. For very large datasets (10,000+ options), implement server-side pagination
4. When `multiple=TRUE`, always handle the empty string case explicitly in observers
5. Set `closeAfterSelect = TRUE` for better user experience in most cases