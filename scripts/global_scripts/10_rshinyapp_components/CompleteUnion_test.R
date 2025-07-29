#' @principle MP56 Connected Component Principle
#' @principle MP52 Unidirectional Data Flow
#' @principle MP54 UI-Server Correspondence
#' @principle R91 Universal Data Access Pattern
#' @title Complete Union Component Test
#' @description This is a complete test app demonstrating a union of multiple components with navbar integration

# Load necessary libraries
library(shiny)
library(bs4Dash)
library(shinyjs)
library(dplyr)

# This test file assumes the following files have been sourced:
# - microCustomer.R
# - microCustomer2.R
# - Union.R

# If running directly, uncomment these lines to source the necessary files:
# source("../micro/microCustomer/microCustomer.R")
# source("../micro/microCustomer/microCustomer2.R")
# source("./Union.R")

# ------------------------------------------------------------------------------
# This is a complete test that demonstrates a union of multiple components
# with navbar-based navigation. This file can be:
# 1. Run directly (when properly sourced)
# 2. Used as a reference for implementing component unions
# 3. Included in the main application
# ------------------------------------------------------------------------------

# If the universal_data_accessor is needed and not already loaded:
# if (!exists("universal_data_accessor")) {
#   source("../../00_principles/02_db_utils/fn_universal_data_accessor.R")
# }

# For the sake of this test, we'll define a simple version that works with our sample data
if (!exists("universal_data_accessor")) {
  universal_data_accessor <- function(data_connection, data_name, log_level = 0) {
    if (inherits(data_connection, "list_connection")) {
      # For test data, look for df_ prefixed entries
      df_name <- paste0("df_", data_name)
      if (df_name %in% names(data_connection)) {
        return(data_connection[[df_name]])
      }
    }
    
    # Fallback to direct access if df_ format not found
    if (data_name %in% names(data_connection)) {
      return(data_connection[[data_name]])
    }
    
    NULL
  }
}

# Create sample data
create_sample_data <- function() {
  # Create sample data
  customer_profile <- data.frame(
    customer_id = 1:10,
    buyer_name = paste0("Demo User ", 1:10),
    email = paste0("user", 1:10, "@example.com"),
    platform_id = sample(c(1, 2, 6), 10, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Create a consistent sample dataset - using set.seed for consistency
  set.seed(456)
  customer_dna <- data.frame(
    customer_id = 1:10,
    time_first = as.Date(Sys.Date() - sample(100:500, 10)),
    time_first_to_now = sample(100:500, 10),
    r_value = sample(5:200, 10),
    r_label = sample(c("極近", "近期", "一般", "久遠", "非常久遠"), 10, replace = TRUE),
    f_value = sample(1:20, 10),
    f_label = sample(c("極低", "低", "一般", "高", "非常高"), 10, replace = TRUE),
    m_value = round(runif(10, 50, 5000), 2),
    m_label = sample(c("極低", "低", "一般", "高", "非常高"), 10, replace = TRUE),
    cai = round(runif(10, 0, 1), 2),
    cai_label = sample(c("不活躍", "低度活躍", "一般活躍", "活躍", "非常活躍"), 10, replace = TRUE),
    ipt_mean = round(runif(10, 20, 120), 1),
    pcv = round(runif(10, 1000, 50000), 2),
    clv = round(runif(10, 2000, 100000), 2),
    cri = round(runif(10, 0, 1), 2),
    nrec = round(runif(10, 0, 1), 2),
    nes_status = sample(c("主力型", "成長型", "沉睡型"), 10, replace = TRUE),
    nt = round(runif(10, 500, 2000), 2),
    e0t = round(runif(10, 1000, 3000), 2),
    stringsAsFactors = FALSE
  )
  
  # Create a connection-like object that works with universal_data_accessor
  connection <- list(
    df_customer_profile = customer_profile,
    df_dna_by_customer = customer_dna
  )
  
  # Add class for universal_data_accessor compatibility
  class(connection) <- c("list_connection", "list")
  
  return(connection)
}

# NSQL DATA FLOW DESCRIPTION:
# 
# FROM INPUT.navbar_menu
# SELECT tab_selection
# STORE IN reactive::active_tab;
# 
# FROM reactive::active_tab
# JOIN WITH (SELECT all_tabs FROM components::unionUI)
# WHERE tab_name = reactive::active_tab
# UPDATE visibility = TRUE
# UPDATE visibility = FALSE WHERE tab_name != reactive::active_tab;
# 
# FROM filter_components
# JOIN WITH reactive::active_tab
# UPDATE filters.visibility = TRUE WHERE component_name = active_tab
# UPDATE filters.visibility = FALSE WHERE component_name != active_tab;

# Define UI components
ui <- bs4Dash::dashboardPage(
  # Basic page settings
  title = "Complete Union Component Test",
  fullscreen = TRUE,
  dark = FALSE,
  
  # Dashboard header 
  header = bs4Dash::dashboardHeader(
    title = "Complete Union Test",
    fixed = TRUE
  ),
  
  # Sidebar with menu for navigation and filters
  sidebar = bs4Dash::dashboardSidebar(
    fixed = TRUE,
    skin = "light",
    status = "primary",
    elevation = 3,
    
    # Add sidebarMenu for navigation - this connects with tabproducts
    bs4Dash::sidebarMenu(
      id = "navbar_menu",
      bs4Dash::menuproduct(
        text = "RFM Analysis",
        tabName = "rfm",
        icon = icon("chart-pie")
      ),
      bs4Dash::menuproduct(
        text = "Value Analysis",
        tabName = "value",
        icon = icon("dollar-sign")
      ),
      bs4Dash::menuproduct(
        text = "Time Series",
        tabName = "date",
        icon = icon("calendar")
      ),
      bs4Dash::menuproduct(
        text = "Product Analysis",
        tabName = "product",
        icon = icon("box")
      ),
      bs4Dash::menuproduct(
        text = "Regional Analysis",
        tabName = "region",
        icon = icon("globe")
      )
    ),
    
    # Component filters with dynamic visibility
    div(
      id = "sidebar_filters",
      style = "padding-top: 15px;",
      
      # Filters for each component
      div(id = "filter_rfm", class = "tab-filter", uiOutput("filter_rfm")),
      div(id = "filter_value", class = "tab-filter", uiOutput("filter_value")),
      div(id = "filter_date", class = "tab-filter", uiOutput("filter_date")),
      div(id = "filter_product", class = "tab-filter", uiOutput("filter_product")),
      div(id = "filter_region", class = "tab-filter", uiOutput("filter_region"))
    )
  ),
  
  # Main body with tabproducts for content
  body = bs4Dash::dashboardBody(
    shinyjs::useShinyjs(),
    
    # CSS styling
    tags$style(HTML("
      .tab-filter { display: none; transition: opacity 0.3s ease; }
      .component-display { transition: opacity 0.3s ease; }
    ")),
    
    # This is the correct way to use tabproducts in bs4Dash
    bs4Dash::tabproducts(
      # RFM Analysis tab
      bs4Dash::tabproduct(
        tabName = "rfm",
        fluidRow(
          column(12,
            bs4Dash::box(
              title = "RFM Analysis",
              width = 12,
              solidHeader = TRUE,
              status = "primary",
              uiOutput("display_rfm")
            )
          )
        )
      ),
      
      # Value Analysis tab
      bs4Dash::tabproduct(
        tabName = "value",
        fluidRow(
          column(12,
            bs4Dash::box(
              title = "Value Analysis",
              width = 12,
              solidHeader = TRUE,
              status = "info",
              uiOutput("display_value")
            )
          )
        )
      ),
      
      # Time Series tab
      bs4Dash::tabproduct(
        tabName = "date",
        fluidRow(
          column(12,
            bs4Dash::box(
              title = "Time Series Analysis",
              width = 12,
              solidHeader = TRUE,
              status = "warning",
              uiOutput("display_date")
            )
          )
        )
      ),
      
      # Product Analysis tab
      bs4Dash::tabproduct(
        tabName = "product",
        fluidRow(
          column(12,
            bs4Dash::box(
              title = "Product Analysis",
              width = 12,
              solidHeader = TRUE,
              status = "success",
              uiOutput("display_product")
            )
          )
        )
      ),
      
      # Regional Analysis tab
      bs4Dash::tabproduct(
        tabName = "region",
        fluidRow(
          column(12,
            bs4Dash::box(
              title = "Regional Analysis",
              width = 12,
              solidHeader = TRUE,
              status = "danger",
              uiOutput("display_region")
            )
          )
        )
      )
    )
  ),
  
  # Footer
  footer = bs4Dash::dashboardFooter(
    fixed = FALSE,
    left = "Complete Union Test",
    right = paste("Version", "1.0.0")
  )
)

# Server function
server <- function(input, output, session) {
  # Create sample data connection
  app_data_connection <- create_sample_data()
  
  # Reactive value to track the active tab
  active_tab <- reactiveVal("rfm")  # Default active tab
  
  # Keep track of the current page for other components to use
  current_page <- reactiveVal("rfm")
  
  # Create component configurations
  configs <- list(
    rfm = list(
      include_fields = c("recency", "frequency", "monetary"),
      filter_options = list(
        title = "RFM Filter",
        background_color = "#f8f9fa"
      )
    ),
    value = list(
      include_fields = c("pcv", "clv", "cri"),
      filter_options = list(
        title = "Value Metrics",
        background_color = "#f0f8ff"
      )
    ),
    date = list(
      include_fields = c("history", "ipt"),
      filter_options = list(
        title = "Time Series Analysis",
        background_color = "#f5f5f5"
      )
    ),
    product = list(
      include_fields = c("nt", "e0t"),
      filter_options = list(
        title = "Product Analysis",
        background_color = "#f0fff0"
      )
    ),
    region = list(
      include_fields = c("cai", "nes"),
      filter_options = list(
        title = "Regional View",
        background_color = "#fff0f0"
      )
    )
  )
  
  # Create individual components with their configs
  components <- list()
  for (name in names(configs)) {
    config <- configs[[name]]
    
    # Use microCustomer2Component for all components since it supports field selection
    components[[name]] <- microCustomer2Component(
      id = paste0("component_", name),
      app_data_connection = app_data_connection,
      include_fields = config$include_fields,
      filter_options = config$filter_options
    )
  }
  
  # Create union configuration - setting initial visibility
  union_config <- list(
    initial_visibility = setNames(
      # Set all to FALSE except the first one (rfm)
      c(TRUE, rep(FALSE, length(configs) - 1)),
      names(configs)
    )
  )
  
  # Create the union using do.call to handle the dynamic component list
  union_args <- c(list(id = "complete_union"), components, list(config = union_config))
  union <- do.call(Union, union_args)
  
  
  
  
  # Create a special reactive value for the filter union state
  filter_union_state <- reactiveValues()
  filter_union_state$toggle_component <- function(comp_name, show = NULL) {
    # This will be initialized with the union server
    if (!exists("union_server")) {
      return(FALSE)
    }
    
    return(union_server$component_state$toggle_component(comp_name, show))
  }
  
  # Initialize the union server
  union_server <- union$server("complete_union", app_data_connection, session)
  
  # Render component filters and displays for each component
  for (name in names(components)) {
    local({
      name_local <- name
      
      # Render filter UI for this component
      filter_id <- paste0("filter_", name_local)
      output[[filter_id]] <- renderUI({
        components[[name_local]]$ui$filter
      })
      
      # Render display UI for this component
      display_id <- paste0("display_", name_local)
      output[[display_id]] <- renderUI({
        components[[name_local]]$ui$display
      })
    })
  }
  
  # Handle navbar menu changes - now handled by tabBox
  observeEvent(input$navbar_menu, {
    selected_tab <- input$navbar_menu
    
    # Print for debugging
    cat("Tab selection changed to:", selected_tab, "\n")
    
    # 1. Update the active tab for tracking
    active_tab(selected_tab)
    
    # 2. Update the current page tracked in the app
    current_page(selected_tab)
    
    # 3. Show only the filter for the selected tab, hide others
    for (name in names(configs)) {
      # Determine if this component should be shown
      show_component <- name == selected_tab
      
      # Toggle filter visibility using direct DOM manipulation 
      display_style <- if (show_component) "block" else "none"
      filter_id <- paste0("filter_", name)
      
      # Update CSS display property of the filter
      shinyjs::runjs(sprintf('$("#sidebar_filters-%s").css("display", "%s");', 
                           filter_id, display_style))
    }
    
    # Log the result
    cat("Switched to component:", selected_tab, "\n")
  })
  
  # Initialize the default view - this runs once when the app starts
  observe({
    # Only run once
    isolate({
      # Set default tab
      default_tab <- "rfm"
      active_tab(default_tab)
      
      # Set initial navbar selection
      # Note: Update the navbar to the default tab - uncomment if needed
      # bs4Dash::updateTabproducts(session, inputId = "navbar_menu", selected = default_tab)
      
      # Initialize component visibility through the union
      for (name in names(configs)) {
        # Show only the default component
        show_component <- name == default_tab
        
        # Toggle component visibility in the union
        union_server$component_state$toggle_component(name, show_component)
        
        # Set initial filter visibility via CSS
        display_style <- if (show_component) "block" else "none"
        filter_id <- paste0("filter_", name)
        
        # Update CSS directly
        shinyjs::runjs(sprintf('$("#sidebar_filters-%s").css("display", "%s");', 
                             filter_id, display_style))
      }
    })
  })
}

# Run the app
shinyApp(ui, server)