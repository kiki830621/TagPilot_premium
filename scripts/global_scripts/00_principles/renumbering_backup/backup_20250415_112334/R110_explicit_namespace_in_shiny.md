# R110: Explicit Namespace in Shiny Applications Rule

## 🔄 Principle Overview

This rule mandates the consistent and explicit use of namespace prefixes for all package functions in Shiny applications, eliminating any reliance on implicit namespace resolution through package loading order.

## 🧩 Rule Definition

All functions from external packages in Shiny applications must be prefixed with their explicit namespace qualifier (`package::function()`), regardless of whether the package has been loaded with library() or not.

## 📋 Requirements

1. **Universal Application**: This rule applies to all external package functions in Shiny applications, with the exception noted in point 6.

2. **Explicit Over Implicit**: Always use explicit namespace prefixes, even when:
   - The package has been loaded with library() or require()
   - No apparent conflicts exist in the current environment
   - The function name appears to be unique

3. **Common Shiny Packages**: Apply namespaces to functions from all packages, including but not limited to:
   - `shiny::` for all Shiny functions (e.g., `shiny::renderUI`, `shiny::reactive`)
   - `shinyjs::` for ShinyJS functions (e.g., `shinyjs::useShinyjs`, `shinyjs::hidden`)
   - `bs4Dash::` for bs4Dash functions (see R109 for specifics)
   - `DT::` for data table functions (e.g., `DT::renderDataTable`, `DT::dataTableOutput`)
   - `plotly::` for plotly functions (e.g., `plotly::renderPlotly`, `plotly::plotlyOutput`)
   - `dplyr::` for dplyr functions (e.g., `dplyr::filter`, `dplyr::mutate`)

4. **Documentation Code**: Include namespace prefixes in all examples and documentation code.

5. **Consistency**: Apply this approach consistently throughout the entire application codebase.

6. **Core Shiny Exception**: As a pragmatic exception, core `shiny` package functions may omit the `shiny::` prefix if all of these conditions are met:
   - The shiny package is explicitly loaded with `library(shiny)` at the start of the script
   - The function is commonly used across the application (e.g., UI elements, renderUI, observe)
   - There is a team-wide agreement to consistently omit shiny prefixes
   - There is no risk of namespace conflict with other packages in the project
   
   This exception acknowledges that in Shiny-centric applications, requiring `shiny::` prefixes for every HTML element and core function can reduce readability. However, note that for maximum safety, using the `shiny::` prefix is still recommended even for core functions.

## 💻 Implementation Pattern

```r
# CORRECT - BS4DASH EXAMPLE:
ui <- shiny::fluidPage(
  bs4Dash::dashboardPage(
    header = bs4Dash::dashboardHeader(title = "My App"),
    sidebar = bs4Dash::dashboardSidebar(),
    body = bs4Dash::dashboardBody(
      shinyjs::useShinyjs(),
      shiny::h1("My Application"),
      shiny::fluidRow(
        shiny::column(
          width = 6,
          DT::dataTableOutput("table")
        ),
        shiny::column(
          width = 6,
          plotly::plotlyOutput("plot")
        )
      )
    )
  )
)

# CORRECT - BSLIB EXAMPLE:
ui <- bslib::page_fillable(
  shinyjs::useShinyjs(),
  bslib::layout_sidebar(
    sidebar = bslib::sidebar(
      shiny::h4("Settings"),
      shiny::sliderInput("n", "Number of points", 10, 100, 50)
    ),
    bslib::navset_card_tab(
      bslib::nav_panel(
        title = "Data",
        icon = shiny::icon("table"),
        DT::dataTableOutput("table")
      ),
      bslib::nav_panel(
        title = "Visualization",
        icon = shiny::icon("chart-bar"),
        plotly::plotlyOutput("plot")
      ),
      bslib::nav_panel(
        title = "Analysis",
        icon = shiny::icon("calculator"),
        bslib::card(
          bslib::card_header("Statistical Summary"),
          shiny::verbatimTextOutput("summary")
        )
      )
    )
  )
)

server <- function(input, output, session) {
  data <- shiny::reactive({
    dplyr::tibble(
      x = 1:input$n,
      y = stats::rnorm(input$n)
    )
  })
  
  output$table <- DT::renderDataTable({
    DT::datatable(data())
  })
  
  output$plot <- plotly::renderPlotly({
    plotly::plot_ly(data(), x = ~x, y = ~y, type = "scatter", mode = "markers")
  })
  
  output$summary <- shiny::renderPrint({
    stats::summary(data()$y)
  })
}

# INCORRECT:
ui <- fluidPage(
  dashboardPage(
    header = dashboardHeader(title = "My App"),
    sidebar = dashboardSidebar(),
    body = dashboardBody(
      useShinyjs(),
      h1("My Application"),
      fluidRow(
        column(
          width = 6,
          dataTableOutput("table")
        ),
        column(
          width = 6,
          plotlyOutput("plot")
        )
      )
    )
  )
)
```

## ⚠️ Common Packages and Functions to Watch 

1. **Shiny Functions**:
   - `fluidPage`, `navbarPage`, `tagList`, `div`, `h1`-`h6`, `p` should be `shiny::`
   - All render functions (`renderText`, `renderPlot`) should be `shiny::`
   - All input/output functions (`textInput`, `plotOutput`) should be `shiny::`

2. **ShinyJS Functions**:
   - `useShinyjs`, `hidden`, `show`, `hide`, `toggle` should be `shinyjs::`
   
3. **Modern Shiny UI Packages**:
   - `page_fillable`, `layout_columns`, `card` should be `bslib::`
   - `nav_panel`, `nav_item`, `nav_menu` should be `bslib::`
   - `input_switch`, `input_slider`, `accordion` should be `bslib::`

4. **Table/Plot Packages**:
   - `renderDataTable`, `dataTableOutput` should be `DT::`
   - `renderPlotly`, `plotlyOutput` should be `plotly::`
   - `renderHighchart`, `highchartOutput` should be `highcharter::`

5. **Data Manipulation**:
   - `filter`, `select`, `mutate`, `group_by` should be `dplyr::`

## 🔄 Related Principles

- **MP58**: Namespace Conflict Avoidance
- **R109**: bs4Dash Namespace Rule
- **R95**: Import Requirements Rule
- **MP19**: Package Consistency
- **R10**: Package Consistency Naming

## 📝 Notes

Consistently using explicit namespaces in Shiny applications provides significant benefits:

1. **Reliability**: Applications behave consistently regardless of which packages are loaded or their loading order.

2. **Maintainability**: Code is self-documenting regarding which package each function comes from.

3. **Error Prevention**: Prevents subtle bugs caused by namespace conflicts or masked functions.

4. **Learning**: Helps developers learn which functions come from which packages.

5. **Stability**: Protects against future package updates that might introduce new functions with conflicting names.

6. **Selective Omission**: The exception for core shiny functions acknowledges the balance between safety and readability:
   - Pure Shiny apps with few other packages may reasonably omit `shiny::` prefixes
   - Applications with many packages or complex dependencies should always use explicit prefixes
   - All non-shiny packages should always use explicit prefixes regardless of context

7. **Recommended Team Practice**: Agree on one of these approaches team-wide:
   - **Strict mode**: Use `shiny::` for all functions from all packages with no exceptions 
   - **Balanced mode**: Omit `shiny::` for core HTML/UI elements only, use prefixes for everything else
   - **Pragmatic mode**: Omit `shiny::` for most common functions, but explicitly document this decision

While it may seem verbose initially, the benefits in reliability and maintainability far outweigh the minor additional typing required. This approach also allows for more granular control of package dependencies, as you can use specific functions from packages without loading the entire package namespace.