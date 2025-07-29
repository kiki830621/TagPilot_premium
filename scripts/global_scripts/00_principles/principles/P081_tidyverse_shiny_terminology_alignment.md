# P0081: Tidyverse-Shiny Terminology Alignment Principle

## Statement
Shiny application component naming shall follow consistent terminology aligned with tidyverse operations to maintain conceptual integrity across data manipulation and UI interactions.

## Description
This principle establishes a standardized naming convention that aligns Shiny UI component identifiers with tidyverse data operations. It ensures the terminology used in user interfaces and data pipelines is conceptually consistent, reducing cognitive load and improving maintainability.

## Rationale
1. **Cognitive Consistency**: Maintaining consistent mental models between data operations and UI interactions
2. **Reduced Context Switching**: Using the same terminology across pipeline operations and interface components
3. **Self-Documentation**: Making component purpose clear through standardized naming
4. **Improved Maintainability**: Enabling easier navigation between data manipulation and UI code
5. **Natural Language Clarity**: Using verb-noun patterns that align with NSQL (Natural SQL) documentation

## Implementation Patterns

### Data Operations to UI Mapping

| Tidyverse Operation | UI Component Purpose | Naming Pattern |
|---------------------|----------------------|----------------|
| `filter()` rows     | Select from a subset of records | `{entity}_select` |
| `select()` columns  | Choose specific fields | `{field}_select` |
| `arrange()` order   | Change sort order | `{entity}_order` |
| `mutate()` new fields | Create/modify values | `{field}_input` |
| `summarize()` aggregate | Show aggregated data | `{metric}_display` |
| `group_by()` clustering | Group-level selection | `{group}_select` |
| `join()` related data | Cross-entity selection | `{entity}_relation_select` |

### Input Component Naming Convention

```r
# CORRECT: Follows tidyverse-aligned naming pattern
selectInput(
  inputId = ns("customer_select"),  # Filter rows from customers dataset
  label = "Select Customer:",
  choices = customer_choices
)

# CORRECT: For column selection
checkboxGroupInput(
  inputId = ns("metrics_select"),   # Select columns from metrics
  label = "Choose Metrics:",
  choices = available_metrics
)

# CORRECT: For data ordering
selectInput(
  inputId = ns("transactions_order"), # Arrange transactions
  label = "Sort By:",
  choices = c("Date (Newest)", "Date (Oldest)", "Amount (High-Low)", "Amount (Low-High)")
)
```

### Server Function Naming Convention

```r
# CORRECT: Handler for customer selection
observeEvent(input$customer_select, {
  # Filter customer data (using tidyverse filter() internally)
  filtered_data <- customers %>%
    filter(customer_id == as.integer(input$customer_select))
    
  # Update UI accordingly
})

# CORRECT: Handler for selecting data fields/columns
observeEvent(input$metrics_select, {
  # Select columns from data (using tidyverse select() internally)
  selected_data <- base_data %>%
    select(all_of(input$metrics_select))
    
  # Display the selected columns
})
```

### Output Component Naming Convention

```r
# CORRECT: Display for filtered data
output$customer_details <- renderUI({
  req(filtered_customer())
  
  # Render the filtered customer details
})

# CORRECT: Display for aggregated metrics
output$sales_summary <- renderTable({
  # Uses summarize() internally
  req(input$group_by_field)
  
  aggregated_data <- data %>%
    group_by(!!sym(input$group_by_field)) %>%
    summarize(
      total_sales = sum(amount),
      avg_order = mean(amount),
      count = n()
    )
    
  aggregated_data
})
```

## Anti-patterns

### Inconsistent Terminology
```r
# INCORRECT: Misalignment between tidyverse concept and UI component name
selectInput(
  inputId = ns("customer_filtered"), # "filtered" is the outcome, not the action
  label = "Select Customer:",
  choices = customer_choices
)

# CORRECT: Aligns with tidyverse filter concept
selectInput(
  inputId = ns("customer_select"), # "select" is the action, matching the filter() concept
  label = "Select Customer:",
  choices = customer_choices
)
```

### Incorrect Operation Mapping
```r
# INCORRECT: Using "filter" in name when actually selecting columns
checkboxGroupInput(
  inputId = ns("metrics_filter"), # Incorrect - we're selecting columns, not filtering rows
  label = "Choose Metrics:",
  choices = available_metrics
)

# CORRECT: Align with tidyverse select() operation
checkboxGroupInput(
  inputId = ns("metrics_select"), # Correct - selecting columns aligns with select()
  label = "Choose Metrics:",
  choices = available_metrics
)
```

### Missing Action Component
```r
# INCORRECT: Missing the action verb in the component name
selectInput(
  inputId = ns("customer"), # Too vague - missing the action
  label = "Customer:",
  choices = customer_choices
)

# CORRECT: Includes action component
selectInput(
  inputId = ns("customer_select"), # Includes the action (select)
  label = "Select Customer:",
  choices = customer_choices
)
```

## Examples

### Complete Module with Aligned Naming

```r
# UI Component
customerAnalysisUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Filter rows: customer_select
    selectInput(
      inputId = ns("customer_select"),
      label = "Select Customer:",
      choices = NULL
    ),
    
    # Select columns: metric_select
    checkboxGroupInput(
      inputId = ns("metrics_select"),
      label = "Select Metrics:",
      choices = c("Revenue", "Orders", "Frequency", "Recency")
    ),
    
    # Arrange output: transaction_order
    selectInput(
      inputId = ns("transactions_order"),
      label = "Sort Transactions By:",
      choices = c("Date (Newest)" = "date_desc", 
                  "Date (Oldest)" = "date_asc", 
                  "Amount (High-Low)" = "amount_desc", 
                  "Amount (Low-High)" = "amount_asc")
    ),
    
    # Group by: timeframe_group
    radioButtons(
      inputId = ns("timeframe_group"),
      label = "Group By:",
      choices = c("Day", "Week", "Month", "Quarter")
    ),
    
    # Output displays
    h4("Customer Details"),
    uiOutput(ns("customer_details")),
    
    h4("Transaction History"),
    tableOutput(ns("transactions_display")),
    
    h4("Metrics Over Time"),
    plotOutput(ns("metrics_trend_plot"))
  )
}

# Server Component
customerAnalysisServer <- function(id, data_connection) {
  moduleServer(id, function(input, output, session) {
    
    # Initialize customer choices
    observe({
      customers <- data_connection$get_customers()
      
      updateSelectInput(
        session,
        "customer_select",
        choices = setNames(
          customers$customer_id,
          customers$customer_name
        )
      )
    })
    
    # 1. FILTER operation: Customer selection
    selected_customer <- reactive({
      req(input$customer_select)
      
      customer_id <- as.integer(input$customer_select)
      
      data_connection$get_customers() %>%
        filter(customer_id == customer_id)
    })
    
    # 2. FILTER operation: Customer transactions 
    customer_transactions <- reactive({
      req(selected_customer())
      
      customer_id <- selected_customer()$customer_id
      
      data_connection$get_transactions() %>%
        filter(customer_id == customer_id)
    })
    
    # 3. ARRANGE operation: Transaction ordering
    ordered_transactions <- reactive({
      req(customer_transactions(), input$transactions_order)
      
      transactions <- customer_transactions()
      
      # Apply ordering based on selection
      switch(input$transactions_order,
        "date_desc" = arrange(transactions, desc(transaction_date)),
        "date_asc" = arrange(transactions, transaction_date),
        "amount_desc" = arrange(transactions, desc(amount)),
        "amount_asc" = arrange(transactions, amount)
      )
    })
    
    # 4. SELECT operation: Metrics selection
    selected_metrics <- reactive({
      req(input$metrics_select)
      
      # Convert user-friendly names to actual column names
      metric_map <- c(
        "Revenue" = "amount",
        "Orders" = "order_count",
        "Frequency" = "purchase_frequency",
        "Recency" = "days_since_last"
      )
      
      # Return the actual column names
      metric_map[input$metrics_select]
    })
    
    # 5. GROUP_BY and SUMMARIZE operation: Metrics by timeframe
    metrics_by_timeframe <- reactive({
      req(customer_transactions(), input$timeframe_group, selected_metrics())
      
      transactions <- customer_transactions()
      
      # Create timeframe grouping variable
      transactions <- transactions %>%
        mutate(
          timeframe = case_when(
            input$timeframe_group == "Day" ~ as.character(transaction_date),
            input$timeframe_group == "Week" ~ format(transaction_date, "%Y-W%V"),
            input$timeframe_group == "Month" ~ format(transaction_date, "%Y-%m"),
            input$timeframe_group == "Quarter" ~ paste0(
              format(transaction_date, "%Y-Q"),
              quarter(transaction_date)
            )
          )
        )
      
      # Group and summarize
      transactions %>%
        group_by(timeframe) %>%
        summarize(
          amount = sum(amount),
          order_count = n_distinct(order_id),
          purchase_frequency = n_distinct(order_id) / n_distinct(customer_id),
          days_since_last = as.integer(
            difftime(max(transaction_date), min(transaction_date), units = "days")
          )
        ) %>%
        select(timeframe, all_of(selected_metrics()))
    })
    
    # OUTPUT RENDERING
    
    # Customer details output
    output$customer_details <- renderUI({
      req(selected_customer())
      customer <- selected_customer()
      
      div(
        p(strong("Name: "), customer$customer_name),
        p(strong("Email: "), customer$email),
        p(strong("Customer Since: "), format(customer$first_purchase_date, "%Y-%m-%d")),
        p(strong("Total Purchases: "), customer$total_purchases),
        p(strong("Lifetime Value: "), sprintf("$%.2f", customer$lifetime_value))
      )
    })
    
    # Transactions table output
    output$transactions_display <- renderTable({
      req(ordered_transactions())
      ordered_transactions()
    })
    
    # Metrics trend plot
    output$metrics_trend_plot <- renderPlot({
      req(metrics_by_timeframe(), selected_metrics())
      
      # Plot metrics over time
      metrics_data <- metrics_by_timeframe()
      
      # Plot logic...
    })
  })
}
```

### NSQL Documentation with Aligned Terminology

```sql
-- NSQL Documentation for Customer Analysis Module

-- FILTER OPERATIONS
-- Used for customer_select input
SELECT *
FROM customers
WHERE customer_id = ?  -- Parameter from input$customer_select

-- Used for customer_transactions reactive
SELECT *
FROM transactions 
WHERE customer_id = ?  -- Parameter derived from selected_customer()

-- ARRANGE OPERATIONS 
-- Used for transactions_order input and ordered_transactions reactive
SELECT * 
FROM customer_transactions
ORDER BY 
  CASE 
    WHEN ? = 'date_desc' THEN transaction_date DESC
    WHEN ? = 'date_asc' THEN transaction_date ASC
    WHEN ? = 'amount_desc' THEN amount DESC
    WHEN ? = 'amount_asc' THEN amount ASC
  END

-- SELECT OPERATIONS
-- Used for metrics_select input and selected_metrics reactive
SELECT timeframe, ${selected_metrics}
FROM metrics_by_timeframe

-- GROUP BY and SUMMARIZE OPERATIONS
-- Used for timeframe_group input and metrics_by_timeframe reactive
SELECT 
  CASE
    WHEN ? = 'Day' THEN transaction_date
    WHEN ? = 'Week' THEN FORMAT(transaction_date, 'YYYY-WW')
    WHEN ? = 'Month' THEN FORMAT(transaction_date, 'YYYY-MM') 
    WHEN ? = 'Quarter' THEN CONCAT(YEAR(transaction_date), '-Q', QUARTER(transaction_date))
  END AS timeframe,
  SUM(amount) AS amount,
  COUNT(DISTINCT order_id) AS order_count,
  COUNT(DISTINCT order_id) / COUNT(DISTINCT customer_id) AS purchase_frequency,
  DATEDIFF('day', MIN(transaction_date), MAX(transaction_date)) AS days_since_last
FROM transactions
WHERE customer_id = ?
GROUP BY timeframe
```

## Related Principles and Rules
- MP0052: Unidirectional Data Flow
- MP0054: UI-Server Correspondence
- P0080: Integer ID Consistency Principle
- R0072: Component ID Consistency Rule
- R0088: Shiny Module ID Handling
- R0089: Integer ID Type Conversion
- R0090: ID Relationship Validation
- MP0024: Natural SQL Language
- MP0027: Specialized Natural SQL Language
