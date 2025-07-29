#' Example app.R Implementing Universal DBI Approach
#'
#' This file demonstrates how to restructure an app.R file to follow
#' the Universal DBI Approach (R92) for consistent data access.
#'
#' @principle R92 Universal DBI Approach
#' @principle R91 Universal Data Access Pattern
#' @principle R76 Module Data Connection Rule

library(shiny)
library(bs4Dash)
library(dplyr)

# 1. Source Required Utilities
# Source the key utilities at application startup
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_db_connection_factory.R")
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_universal_data_accessor.R")
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_list_to_mock_dbi.R")

# 2. Source Application Components
# Source the customer module with universal data access support
source("update_scripts/global_scripts/10_rshinyapp_components/micro/microCustomer/microCustomer_universal.R")

# 3. Configuration
# Define the configuration options for the application
app_config <- list(
  mode = Sys.getenv("APP_MODE", "development"),  # Can be "production", "development", or "test"
  database = list(
    duckdb = list(
      dbdir = "app_data/app_data.duckdb"
    )
  ),
  mock_data_path = "app_data/mock_data/",
  app_language = "en"
)

# 4. Initialize Database Connection
# Use the connection factory to create the appropriate connection
app_db_conn <- initialize_app_db_connection(app_config)

# 5. UI Definition
ui <- bs4Dash::dashboardPage(
  title = "Precision Marketing App",
  header = bs4Dash::dashboardHeader(
    title = "Universal DBI Approach Example"
  ),
  sidebar = bs4Dash::dashboardSidebar(
    bs4Dash::sidebarMenu(
      bs4Dash::menuItem(
        text = "Customers",
        tabName = "customers",
        icon = icon("users")
      ),
      bs4Dash::menuItem(
        text = "Database Info",
        tabName = "db_info",
        icon = icon("database")
      )
    )
  ),
  body = bs4Dash::dashboardBody(
    bs4Dash::tabItems(
      bs4Dash::tabItem(
        tabName = "customers",
        fluidRow(
          column(12,
                 box(
                   title = "Customer Filter",
                   width = 12,
                   microCustomerFilterUI("customer_module")
                 )
          )
        ),
        fluidRow(
          column(12,
                 box(
                   title = "Customer Details",
                   width = 12,
                   microCustomerUI("customer_module")
                 )
          )
        )
      ),
      bs4Dash::tabItem(
        tabName = "db_info",
        fluidRow(
          column(12,
                 box(
                   title = "Database Connection Information",
                   width = 12,
                   verbatimTextOutput("connection_info"),
                   hr(),
                   h4("Available Tables"),
                   tableOutput("tables_info")
                 )
          )
        )
      )
    )
  ),
  controlbar = bs4Dash::dashboardControlbar(
    bs4Dash::controlbarMenu(
      id = "controlbar_menu",
      bs4Dash::controlbarItem(
        title = "Settings",
        icon = icon("gear"),
        selectInput(
          "app_mode",
          "Application Mode:",
          choices = c("Production", "Development", "Test"),
          selected = app_config$mode
        ),
        actionButton(
          "refresh_connection",
          "Refresh Connection",
          icon = icon("sync")
        )
      )
    )
  )
)

# 6. Server Logic
server <- function(input, output, session) {
  # 6.1 Track connection state reactively
  current_connection <- reactiveVal(app_db_conn)
  
  # 6.2 Initialize Modules
  # Pass the database connection to all modules that need data
  filtered_data <- microCustomerServer(
    "customer_module", 
    reactive(current_connection())
  )
  
  # 6.3 Display connection information
  output$connection_info <- renderPrint({
    conn <- current_connection()
    conn_info <- get_connection_info(conn)
    
    # Format connection info for display
    list(
      status = conn_info$status,
      type = conn_info$type,
      connection_type = if (!is.null(conn_info$connection_type)) conn_info$connection_type else "unknown",
      created_at = if (!is.null(conn_info$created_at)) conn_info$created_at else Sys.time(),
      valid = conn_info$valid,
      table_count = if (!is.null(conn_info$tables)) length(conn_info$tables) else 0
    )
  })
  
  # 6.4 Display table information
  output$tables_info <- renderTable({
    conn <- current_connection()
    conn_info <- get_connection_info(conn)
    
    if (!is.null(conn_info$tables) && length(conn_info$tables) > 0) {
      tables <- conn_info$tables
      
      # Try to get row counts for each table
      row_counts <- vapply(tables, function(table) {
        tryCatch({
          data <- universal_data_accessor(conn, table, log_level = 0)
          if (!is.null(data)) nrow(data) else 0
        }, error = function(e) 0)
      }, numeric(1))
      
      data.frame(
        table_name = tables,
        row_count = row_counts,
        stringsAsFactors = FALSE
      )
    } else {
      data.frame(
        table_name = character(0),
        row_count = numeric(0),
        stringsAsFactors = FALSE
      )
    }
  })
  
  # 6.5 Handle connection refresh
  observeEvent(input$refresh_connection, {
    # Get current app mode from input
    new_mode <- tolower(input$app_mode)
    
    # Update config
    app_config$mode <- new_mode
    
    # Create new connection
    new_conn <- initialize_app_db_connection(app_config)
    
    # Update reactive connection
    current_connection(new_conn)
    
    # Show notification
    showNotification(
      paste("Connection refreshed in", new_mode, "mode"),
      type = "message"
    )
  })
  
  # 6.6 Clean up when session ends
  session$onSessionEnded(function() {
    # Close current connection if it's a real connection
    conn <- current_connection()
    if (!inherits(conn, "mock_dbi_connection") && 
        requireNamespace("DBI", quietly = TRUE)) {
      tryCatch({
        DBI::dbDisconnect(conn)
      }, error = function(e) {
        # Just log error but don't crash
        message("Error disconnecting: ", e$message)
      })
    }
  })
}

# 7. Run the Application
shinyApp(ui = ui, server = server)