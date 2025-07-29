# Proposed app.R Redesign Using Union Pattern

This document outlines a proposed refactoring of the Precision Marketing app using the Union component pattern. The changes maintain the existing functionality while adding modularity, better separation of concerns, and improved state management.

## Key Changes

1. Implement Union pattern for navigation levels (top-level and second-level)
2. Use consistent component structure following UI-Server-Defaults Triple Rule
3. Centralize state management for component visibility
4. Create a more maintainable and extensible application architecture

## High-Level Architecture

The application will follow the existing navigation hierarchy with Union components at each level. Components are enabled or disabled based on the YAML configuration:

```
App (config determines which components are active)
├── TopLevelUnion (main app tabs - based on config$components)
│   ├── MicroTab (if "micro" in config$components)
│   │   └── MicroComponentsUnion (second-level navigation)
│   │       ├── CustomerComponent (if "micro.customer_profile" in config)
│   │       ├── DNADistributionComponent (if "micro.dna" in config)
│   │       └── TransactionsComponent (if "micro.sales" in config)
│   ├── MacroTab (if "macro" in config$components)
│   │   └── MacroComponentsUnion
│   │       ├── TrendsComponent (if "macro.trends" in config)
│   │       └── Other components based on config
│   └── Other top-level tabs defined in config$components
│
└── SidebarUnion (filters - based on active tabs from config)
    ├── CommonFiltersComponent (always included)
    ├── MicroFiltersComponent (if "micro" in config$components)
    ├── MacroFiltersComponent (if "macro" in config$components)
    └── Other filter components based on config
```

## Implementation

The implementation will use the existing component structure and directories, with the addition of Union components to manage navigation and state:

```
/update_scripts/global_scripts/10_rshinyapp_components/
  ├── micro/
  │   ├── microCustomer/microCustomer.R  
  │   ├── microDNADistribution/microDNADistribution.R
  │   ├── microTransactions/microTransactions.R
  │   └── MicroComponentsUnion.R  (new - combines micro components)
  │
  ├── sidebars/
  │   └── SidebarUnion.R  (new - combines filter components)
  │
  └── app_components/  (new)
      └── TopLevelUnion.R  (new - combines top-level tabs)
```

### Main app.R Implementation

```r
# Precision Marketing app based on bs4Dash and Union Component Pattern
# Following P72: UI Package Consistency Principle and P73: Server-to-UI Data Flow Principle
# Implements R91: Universal Data Access Pattern, R95: Import Requirements Rule, and R09: UI-Server-Defaults Triple Rule

# Source initialization script first
init_script_path <- file.path("update_scripts", "global_scripts", "00_principles", 
                            "sc_initialization_app_mode.R")
source(init_script_path)

# Verify packages were properly initialized
if (!exists("PACKAGES_INITIALIZED") || !is.list(PACKAGES_INITIALIZED)) {
  stop("Package initialization failed. Please check initialization script.")
}

# Initialize data availability registry
availability_registry <- list()
availability_registry <- initialize_data_availability()

# Source Union components
source("update_scripts/global_scripts/10_rshinyapp_components/unions/Union.R")
source("update_scripts/global_scripts/10_rshinyapp_components/filters/SidebarComponent.R")
source("update_scripts/global_scripts/10_rshinyapp_components/displays/MainDisplayComponent.R")

# Define CSS styling
css_dir <- file.path("update_scripts", "global_scripts", "19_CSS")
options(shiny.staticPath = css_dir)
css_dependencies <- tags$head(
  tags$link(rel = "stylesheet", type = "text/css", href = "minimal.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "main.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "sidebar-fixes.css"),
  tags$link(rel = "stylesheet", type = "text/css", href = "component-styles.css")
)

# Define the UI
ui <- bs4Dash::dashboardPage(
  title = translate("AI Marketing Technology Platform"),
  fullscreen = TRUE,
  dark = FALSE,
  help = FALSE,
  
  # Dashboard header with navbar
  header = bs4Dash::dashboardHeader(
    title = bs4Dash::dashboardBrand(
      title = shiny::div(
        class = "centered-title",
        translate("AI Martech")
      ),
      color = "primary",
      href = "#"
    ),
    fixed = TRUE,
    leftUi = NULL,
    rightUi = bs4Dash::dropdownMenu(
      type = "notifications",
      badgeStatus = "success",
      bs4Dash::notificationproduct(
        text = "Welcome to Precision Marketing",
        icon = icon("info"),
        status = "primary"
      )
    )
  ),
  
  # Sidebar with union component
  sidebar = uiOutput("sidebar_container"),
  
  # Main body with tabs and union display component
  body = bs4Dash::dashboardBody(
    # Include CSS dependencies and JavaScript support
    css_dependencies,
    shinyjs::useShinyjs(),
    
    # Simple navbar using buttons
    div(
      class = "navbar-custom panel-header",
      
      # Dynamically generate buttons based only on configured components
    # This ensures only components specified in the YAML config are included
    lapply(names(config$components), function(comp_name) {
      # Default labels and icons with fallbacks
      button_config <- switch(comp_name,
        "micro" = list(label = translate("Micro Analysis"), icon = "user"),
        "macro" = list(label = translate("Macro Analysis"), icon = "chart-bar"),
        "target" = list(label = translate("Target Marketing"), icon = "bullseye"),
        # Default for any other component type
        list(label = translate(paste0(toupper(substring(comp_name, 1, 1)), 
                               substring(comp_name, 2), " Analysis")), 
             icon = "cube")
      )
      
      # Create the button
      actionButton(
        paste0(comp_name, "_tab"),
        button_config$label,
        icon = icon(button_config$icon),
        class = paste0("tab-button", if(comp_name == "micro") " active" else "")
      )
    })
    ),
    
    # Content container for union display component
    uiOutput("main_container")
  ),
  
  # Optional: Control sidebar for additional settings/filters
  controlbar = bs4Dash::dashboardControlbar(
    id = "controlbar",
    skin = "light",
    pinned = FALSE,
    overlay = TRUE,
    bs4Dash::controlbarMenu(
      id = "controlbarMenu",
      bs4Dash::controlbarproduct(
        title = translate("Display"),
        icon = icon("sliders-h"),
        selectizeInput(
          "display_density",
          translate("Display Density"),
          choices = c("Compact", "Comfortable", "Spacious"),
          selected = "Comfortable"
        )
      ),
      bs4Dash::controlbarproduct(
        title = translate("Data"),
        icon = icon("database"),
        shinyWidgets::prettyCheckbox(
          "show_raw_data",
          translate("Show Raw Data"),
          value = FALSE,
          status = "primary",
          animation = "smooth"
        )
      )
    )
  ),
  
  # Footer with version information
  footer = bs4Dash::dashboardFooter(
    fixed = FALSE,
    left = paste("Precision Marketing App", format(Sys.Date(), "%Y")),
    right = paste("Version", "1.0.0")
  )
)

# Server function
server <- function(input, output, session) {
  # Create a reactive value to track the active tab
  active_tab <- reactiveVal("micro_tab")
  
  # Create a connection object for data access
  app_data_connection <- reactive({
    # Return the existing database connection if it exists
    if (exists("app_data_conn") && !is.null(app_data_conn) && DBI::dbIsValid(app_data_conn)) {
      message("Using existing database connection")
      return(app_data_conn)
    } 
    
    # If no database connection is available, stop the application
    # No fake/sample data is generated - follow MP principle of data integrity
    stop("ERROR: No valid database connection available. Application requires a proper data connection.")
  })
  
  # Create the sidebar component using Union
  sidebar_component <- ExtendedSidebarComponent(
    id = "app_sidebar",
    app_data_connection = app_data_connection,
    active_tab = active_tab,
    translate = translate
  )
  
  # Create the main display component using Union
  main_component <- MainDisplayComponent(
    id = "app_main",
    app_data_connection = app_data_connection,
    active_tab = active_tab,
    translate = translate
  )
  
  # Render the sidebar
  output$sidebar_container <- renderUI({
    sidebar_component$ui("app_sidebar")
  })
  
  # Render the main container
  output$main_container <- renderUI({
    main_component$ui("app_main")
  })
  
  # Initialize the components' servers
  sidebar_server <- sidebar_component$server(input, output, session)
  main_server <- main_component$server(input, output, session)
  
  # Tab switching logic
  observeEvent(input$micro_tab, {
    # Update active tab
    active_tab("micro_tab")
    
    # Update tab buttons
    shinyjs::removeClass(selector = ".tab-button", class = "active")
    shinyjs::addClass(id = "micro_tab", class = "active")
  })
  
  observeEvent(input$macro_tab, {
    # Update active tab
    active_tab("macro_tab")
    
    # Update tab buttons
    shinyjs::removeClass(selector = ".tab-button", class = "active")
    shinyjs::addClass(id = "macro_tab", class = "active")
  })
  
  observeEvent(input$target_tab, {
    # Update active tab
    active_tab("target_tab")
    
    # Update tab buttons
    shinyjs::removeClass(selector = ".tab-button", class = "active")
    shinyjs::addClass(id = "target_tab", class = "active")
  })
  
  # Access filter values from sidebar - driven by YAML config
  observe({
    # Get current active tab without "_tab" suffix
    current_tab_name <- sub("_tab$", "", active_tab())
    
    # Initialize with common filters (always present)
    filter_values <- list(
      common = sidebar_server$server_outputs$common()
    )
    
    # Add filters for components defined in YAML config only
    if (!is.null(config) && !is.null(config$components)) {
      # For each component in the YAML configuration
      for (comp_name in names(config$components)) {
        # Only include filter values for this component if it's the active tab
        # and if the corresponding server output exists
        if (comp_name == current_tab_name && 
            comp_name %in% names(sidebar_server$server_outputs)) {
          filter_values[[comp_name]] <- sidebar_server$server_outputs[[comp_name]]()
        }
      }
    }
    
    # Use filter values for data filtering
    # (Filter logic would go here)
  })
  
  # Helper function for toast messages
  showToast <- function(title, message, options = list()) {
    bs4Dash::toast(
      title = title,
      body = message,
      options = options
    )
  }
}

# Deinitialization for clean shutdown
shiny::onStop(function() {
  message("Application shutting down. Running deinitialization...")
  
  # Close database connection if it exists
  if (!is.null(app_data_conn) && DBI::dbIsValid(app_data_conn)) {
    DBI::dbDisconnect(app_data_conn)
    message("Database connection closed.")
  }
})

# Run the app
shinyApp(ui = ui, server = server, options = list(
  host = "0.0.0.0",
  port = 4849,
  launch.browser = TRUE
))
```

## Component Implementations

### 1. SidebarComponent.R

```r
#' @principle MP56 Connected Component Principle
#' @principle MP52 Unidirectional Data Flow
#' @principle MP54 UI-Server Correspondence
#' @principle P22 CSS Component Display Controls

#' Create extended sidebar with filter tabs
#'
#' @param id The component ID 
#' @param app_data_connection Data connection
#' @param active_tab Reactive value tracking active tab
#'
#' @return A sidebar component with UI and server parts
#' @export
ExtendedSidebarComponent <- function(id, app_data_connection = NULL, active_tab = reactiveVal("micro_tab"), translate = function(x) x) {
  # Load required filter components
  source("update_scripts/global_scripts/10_rshinyapp_components/filters/CommonFiltersComponent.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/filters/MicroFiltersComponent.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/filters/MacroFiltersComponent.R")
  
  # Create a unified sidebar using Union
  sidebar_union <- Union(
    id,
    common = CommonFiltersComponent(paste0(id, "_common"), app_data_connection, NULL, translate),
    micro = MicroFiltersComponent(paste0(id, "_micro"), app_data_connection, NULL, translate),
    macro = MacroFiltersComponent(paste0(id, "_macro"), app_data_connection, NULL, translate),
    config = list(
      initial_visibility = list(
        common = TRUE,
        micro = TRUE,
        macro = FALSE
      )
    )
  )
  
  # Create the sidebar container
  sidebar_ui <- function(id) {
    bs4Dash::dashboardSidebar(
      fixed = TRUE,
      skin = "light",
      status = "primary",
      elevation = 3,
      
      # Filters header
      div(
        class = "filters-header app-header",
        h3(
          class = "app-title",
          translate("Application Settings")
        )
      ),
      
      # Include the union filter UI
      sidebar_union$ui$filter(id)
    )
  }
  
  # Sidebar server function
  sidebar_server <- function(input, output, session) {
    # Initialize the union server
    union_server <- sidebar_union$server(id, app_data_connection, session)
    
    # Control visibility based on active tab
    observe({
      current_tab <- active_tab()
      
      # Toggle filter component visibility based on active tab
      if (current_tab == "micro_tab") {
        union_server$component_state$toggle_component("micro", TRUE)
        union_server$component_state$toggle_component("macro", FALSE)
      } else if (current_tab == "macro_tab") {
        union_server$component_state$toggle_component("micro", FALSE)
        union_server$component_state$toggle_component("macro", TRUE)
      }
    })
    
    # Return the union server for external access to filter values
    return(union_server)
  }
  
  # Return the sidebar component structure
  list(
    ui = sidebar_ui,
    server = sidebar_server,
    defaults = sidebar_union$defaults
  )
}
```

### 2. MainDisplayComponent.R

```r
#' @principle MP56 Connected Component Principle
#' @principle MP52 Unidirectional Data Flow
#' @principle MP54 UI-Server Correspondence
#' @principle P22 CSS Component Display Controls

#' Create main display component with unified content areas
#'
#' @param id The component ID 
#' @param app_data_connection Data connection
#' @param active_tab Reactive value tracking active tab
#'
#' @return A main display component with UI and server parts
#' @export
MainDisplayComponent <- function(id, app_data_connection = NULL, active_tab = reactiveVal("micro_tab"), translate = function(x) x) {
  # Load required display components
  source("update_scripts/global_scripts/10_rshinyapp_components/displays/MicroDisplayComponent.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/displays/MacroDisplayComponent.R")
  
  # Create a unified display using Union
  display_union <- Union(
    id,
    micro = MicroDisplayComponent(paste0(id, "_micro"), app_data_connection, NULL, translate),
    macro = MacroDisplayComponent(paste0(id, "_macro"), app_data_connection, NULL, translate),
    config = list(
      initial_visibility = list(
        micro = TRUE,
        macro = FALSE
      )
    )
  )
  
  # Create the main display UI
  main_ui <- function(id) {
    div(
      id = paste0(id, "_container"),
      class = "main-display-container",
      
      # Include the union display UI
      display_union$ui$display(id)
    )
  }
  
  # Main display server function
  main_server <- function(input, output, session) {
    # Initialize the union server
    union_server <- display_union$server(id, app_data_connection, session)
    
    # Control visibility based on active tab
    observe({
      current_tab <- active_tab()
      
      # Toggle display component visibility based on active tab
      if (current_tab == "micro_tab") {
        union_server$component_state$toggle_component("micro", TRUE)
        union_server$component_state$toggle_component("macro", FALSE)
      } else if (current_tab == "macro_tab") {
        union_server$component_state$toggle_component("micro", FALSE)
        union_server$component_state$toggle_component("macro", TRUE)
      }
    })
    
    # Return the union server for external access
    return(union_server)
  }
  
  # Return the main display component structure
  list(
    ui = main_ui,
    server = main_server,
    defaults = display_union$defaults
  )
}
```

# Union Component Implementations

## 1. MicroComponentsUnion Implementation

The MicroComponentsUnion combines the micro components (microCustomer, microDNADistribution, microTransactions) into a unified interface with second-level navigation and state persistence:

```r
# /update_scripts/global_scripts/10_rshinyapp_components/micro/MicroComponentsUnion.R

#' @principle MP56 Connected Component Principle
#' @principle R09 UI-Server-Defaults Triple Rule
#' @principle MP17 Modularity Principle
#' @principle MP54 UI-Server Correspondence

#' Create a union of micro-level components with state management
#'
#' @param id The component ID
#' @param app_data_connection Data connection
#' @param config Optional configuration parameters
#' @param translate Translation function
#'
#' @return A unified micro components interface
#' @export
MicroComponentsUnion <- function(id, app_data_connection = NULL, config = NULL, translate = function(x) x) {
  # Source the micro components
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/microCustomer/microCustomer.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/microDNADistribution/microDNADistribution.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/microTransactions/microTransactionsUI.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/microTransactions/microTransactionsServer.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/microTransactions/microTransactionsDefaults.R")
  
  # Create unified microTransactions component
  microTransactions <- list(
    ui = list(
      filter = function(id) microTransactionsUI_filter(id),
      display = function(id) microTransactionsUI_display(id)
    ),
    server = function(input, output, session) microTransactionsServer(input, output, session),
    defaults = function() microTransactionsDefaults()
  )
  
  # Get the micro component configuration from the passed config
  micro_config <- if (!is.null(config)) config else list()
  
  # Build component list dynamically based on what's in the config
  component_list <- list()
  initial_visibility <- list()
  
  # Component mapping
  component_map <- list(
    "customer_profile" = function(comp_id) {
      microCustomerComponent(comp_id, app_data_connection, micro_config$customer_profile, translate)
    },
    "dna" = function(comp_id) {
      microDNADistributionComponent(comp_id, app_data_connection, micro_config$dna, translate)
    },
    "sales" = function(comp_id) {
      microTransactions
    }
  )
  
  # Get the keys from micro component configuration or default to all components
  micro_components <- if (length(names(micro_config)) > 0) {
    names(micro_config)
  } else {
    # Fallback to default core components if no specific config
    c("customer_profile", "dna", "sales")
  }
  
  # Set first component as active by default
  first_comp <- if (length(micro_components) > 0) micro_components[1] else NULL
  
  # Create each component specified in the config
  for (comp_name in micro_components) {
    if (comp_name %in% names(component_map)) {
      # Create the component using its builder function
      component_id <- paste0(id, "_", comp_name)
      component_list[[comp_name]] <- component_map[[comp_name]](component_id)
      
      # Set initial visibility (first component visible, others hidden)
      initial_visibility[[comp_name]] <- (comp_name == first_comp)
    }
  }
  
  # Create union only if we have components
  if (length(component_list) > 0) {
    # Create the Union component with dynamically built component list
    micro_union <- do.call(
      Union,
      c(
        list(id = id),
        component_list,
        list(config = list(initial_visibility = initial_visibility))
      )
    )
  } else {
    # Create an empty Union if no components found
    warning("No micro components found in configuration - creating empty Union")
    micro_union <- Union(id, config = list(initial_visibility = list()))
  }
  
  # Define components with their display names and icons based on config
  # Create a mapping for the UI labels and icons
  # This will be overridden by titles in the config when available
  ui_config_map <- list(
    "customer_profile" = list(
      label = if (!is.null(micro_config$customer_profile$title)) 
                translate(micro_config$customer_profile$title) else translate("Customer Profiles"),
      icon = if (!is.null(micro_config$customer_profile$icon)) 
               micro_config$customer_profile$icon else "user"
    ),
    "dna" = list(
      label = if (!is.null(micro_config$dna$title)) 
                translate(micro_config$dna$title) else translate("DNA Distribution"),
      icon = if (!is.null(micro_config$dna$icon)) 
               micro_config$dna$icon else "dna"
    ),
    "sales" = list(
      label = if (!is.null(micro_config$sales$title)) 
                translate(micro_config$sales$title) else translate("Transactions"),
      icon = if (!is.null(micro_config$sales$icon)) 
               micro_config$sales$icon else "exchange-alt"
    )
  )
  
  # Dynamically build components_config based on what's in the component list
  components_config <- list()
  for (comp_name in names(component_list)) {
    if (comp_name %in% names(ui_config_map)) {
      components_config[[comp_name]] <- ui_config_map[[comp_name]]
    } else {
      # Default config for any component not in the map
      components_config[[comp_name]] <- list(
        label = translate(paste0(toupper(substring(comp_name, 1, 1)), 
                                substring(comp_name, 2))),
        icon = "cube"
      )
    }
  }
  
  # Create the micro UI with navbar
  micro_ui <- function(id) {
    ns <- NS(id)
    
    # Set the initial active component to the first one in the list
    first_comp <- if (length(names(components_config)) > 0) {
      names(components_config)[1]
    } else {
      NULL
    }
    
    div(
      class = "micro-container",
      
      # Only show navbar if we have more than one component
      if (length(names(components_config)) > 1) {
        div(
          class = "navbar-micro",
          
          # Create a button for each component from the config
          lapply(names(components_config), function(comp_name) {
            comp_config <- components_config[[comp_name]]
            
            # Get custom title and icon from micro config if available
            custom_title <- NULL
            custom_icon <- NULL
            
            if (!is.null(micro_config[[comp_name]])) {
              if (!is.null(micro_config[[comp_name]]$title)) {
                custom_title <- micro_config[[comp_name]]$title
              }
              
              if (!is.null(micro_config[[comp_name]]$icon)) {
                custom_icon <- micro_config[[comp_name]]$icon
              }
            }
            
            # Override with custom values if available
            if (!is.null(custom_title)) {
              comp_config$label <- translate(custom_title)
            }
            
            if (!is.null(custom_icon)) {
              comp_config$icon <- custom_icon
            }
            
            # Create a button with the proper icon and label
            actionButton(
              ns(paste0(comp_name, "_btn")),
              comp_config$label,
              icon = icon(comp_config$icon),
              class = paste0("btn-primary", if(comp_name == first_comp) " active" else "")
            )
          })
        )
      },
      
      # Component display area (or message if no components)
      if (is.null(micro_union$ui$display)) {
        div(
          class = "alert alert-warning",
          "No components configured for micro view"
        )
      } else {
        micro_union$ui$display(id)
      }
    )
  }
  
  # Create the micro server
  micro_server <- function(input, output, session) {
    ns <- session$ns
    
    # Initialize the union server
    union_server <- micro_union$server(id, app_data_connection, session)
    
    # Create a reactive to track the active component with persistent state
    # Initialize with value from session if available (for state persistence)
    active_component <- reactiveVal(
      if (!is.null(session$userData$micro_active_component)) {
        session$userData$micro_active_component
      } else {
        "customer" # Default initial value
      }
    )
    
    # Initialize button state based on active component
    session$onFlush(once = TRUE, function() {
      current_comp <- active_component()
      # Set initial button state
      shinyjs::removeClass(selector = ".navbar-micro .btn-primary", class = "active")
      shinyjs::addClass(id = paste0(current_comp, "_btn"), class = "active")
      
      # Set initial component visibility
      for (name in names(micro_union$components)) {
        union_server$component_state$toggle_component(name, name == current_comp)
      }
    })
    
    # Handle navbar buttons for each component
    for (comp_name in names(components_config)) {
      local({
        local_comp_name <- comp_name
        button_id <- paste0(local_comp_name, "_btn")
        
        observeEvent(input[[button_id]], {
          # Update active component
          active_component(local_comp_name)
          
          # Store in session for persistence when switching tabs
          session$userData$micro_active_component <- local_comp_name
          
          # Update button styling
          shinyjs::removeClass(selector = ".navbar-micro .btn-primary", class = "active")
          shinyjs::addClass(id = button_id, class = "active")
          
          # Update component visibility
          for (name in names(micro_union$components)) {
            union_server$component_state$toggle_component(name, name == local_comp_name)
          }
        })
      })
    }
    
    # Return the union server and active component for external access
    list(
      component_state = union_server$component_state,
      server_outputs = union_server$server_outputs,
      active_component = active_component
    )
  }
  
  # Create defaults function that merges component defaults
  micro_defaults <- function() {
    # Start with micro-level defaults
    defaults <- list(
      default_active = "customer",
      show_navbar = TRUE,
      navbar_position = "top"
    )
    
    # Add component defaults
    if (is.function(micro_union$defaults)) {
      component_defaults <- micro_union$defaults()
      defaults <- c(defaults, component_defaults)
    }
    
    return(defaults)
  }
  
  # Return the micro component
  list(
    ui = list(
      filter = function(id) div(), # Filters are handled separately in sidebar
      display = micro_ui
    ),
    server = micro_server,
    defaults = micro_defaults
  )
}
```

## 2. SidebarUnion Implementation

The SidebarUnion manages the application's filter components based on the active top-level tab:

```r
# /update_scripts/global_scripts/10_rshinyapp_components/sidebars/SidebarUnion.R

#' @principle MP56 Connected Component Principle
#' @principle MP52 Unidirectional Data Flow
#' @principle MP54 UI-Server Correspondence
#' @principle R09 UI-Server-Defaults Triple Rule

#' Create a unified sidebar with filter components based on application state
#'
#' @param id The component ID 
#' @param app_data_connection Data connection
#' @param active_tab Reactive value tracking active tab
#' @param translate Translation function
#'
#' @return A sidebar component following Union pattern
#' @export
SidebarUnion <- function(id, app_data_connection = NULL, active_tab = reactiveVal("micro_tab"), translate = function(x) x) {
  # Source required filter components
  source("update_scripts/global_scripts/10_rshinyapp_components/sidebars/sidebarCommon/sidebarCommonFilters.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/sidebars/sidebarMicro/sidebarMicroUI.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/sidebars/sidebarMacro/sidebarMacroUI.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/sidebars/sidebarTarget/sidebarTargetUI.R")
  
  # Create Union component for filters
  sidebar_union <- Union(
    id,
    common = sidebarCommonFilters(paste0(id, "_common"), app_data_connection, NULL, translate),
    micro = sidebarMicroUI(paste0(id, "_micro"), app_data_connection, NULL, translate),
    macro = sidebarMacroUI(paste0(id, "_macro"), app_data_connection, NULL, translate),
    target = sidebarTargetUI(paste0(id, "_target"), app_data_connection, NULL, translate),
    config = list(
      initial_visibility = list(
        common = TRUE,
        micro = active_tab() == "micro_tab",
        macro = active_tab() == "macro_tab",
        target = active_tab() == "target_tab"
      )
    )
  )
  
  # Create sidebar container UI function
  sidebar_ui <- function(id) {
    ns <- NS(id)
    
    bs4Dash::dashboardSidebar(
      id = ns("sidebar"),
      fixed = TRUE,
      skin = "light",
      status = "primary",
      elevation = 3,
      
      # Filters header
      div(
        class = "filters-header app-header",
        h3(
          class = "app-title",
          translate("Filters & Settings")
        )
      ),
      
      # Include the union filter UI
      sidebar_union$ui$filter(id)
    )
  }
  
  # Sidebar server function
  sidebar_server <- function(input, output, session) {
    ns <- session$ns
    
    # Initialize the union server
    union_server <- sidebar_union$server(id, app_data_connection, session)
    
    # Control visibility based on active tab and config
    observe({
      current_tab <- active_tab()
      
      # Extract tab name without "_tab" suffix
      current_component <- sub("_tab$", "", current_tab)
      
      # Toggle filter component visibility based on active tab
      union_server$component_state$toggle_component("common", TRUE) # Common always visible
      
      # Only toggle components that exist in config
      for (comp_name in c("micro", "macro", "target")) {
        # Only toggle if this component exists in our union
        if (comp_name %in% names(union_server$component_state$get_visibility())) {
          union_server$component_state$toggle_component(comp_name, comp_name == current_component)
        }
      }
    })
    
    # Collect and return filter values from all components
    filter_values <- reactive({
      # Start with empty list
      values <- list()
      
      # Get all available components in this union
      available_components <- names(union_server$server_outputs)
      
      # Only include values for components that exist and are visible
      for (comp_name in available_components) {
        if (union_server$component_state$is_visible(comp_name)) {
          values[[comp_name]] <- union_server$server_outputs[[comp_name]]
        } else {
          values[[comp_name]] <- NULL
        }
      }
      
      return(values)
    })
    
    # Return the union server and filter values for external access
    list(
      component_state = union_server$component_state,
      server_outputs = union_server$server_outputs,
      filter_values = filter_values
    )
  }
  
  # Create defaults function that combines all component defaults
  sidebar_defaults <- function() {
    # Begin with common defaults that apply to all components
    defaults <- list(
      sidebar_expanded = TRUE,
      sidebar_collapsed_width = "60px",
      sidebar_width = "300px"
    )
    
    # Add component-specific defaults if available
    if (is.function(sidebar_union$defaults)) {
      component_defaults <- sidebar_union$defaults()
      defaults <- c(defaults, component_defaults)
    }
    
    return(defaults)
  }
  
  # Return the sidebar component structure
  list(
    ui = sidebar_ui,
    server = sidebar_server,
    defaults = sidebar_defaults
  )
}
```

## 3. TopLevelUnion Implementation

The TopLevelUnion manages the application's main navigation tabs and their visibility based on configuration:

```r
# /update_scripts/global_scripts/10_rshinyapp_components/app_components/TopLevelUnion.R

#' @principle MP56 Connected Component Principle
#' @principle MP52 Unidirectional Data Flow
#' @principle MP54 UI-Server Correspondence
#' @principle R09 UI-Server-Defaults Triple Rule
#' @principle P73 Server-to-UI Data Flow Principle

#' Create main application tab union component
#'
#' @param id The component ID 
#' @param app_data_connection Data connection
#' @param active_tab Reactive value tracking active tab
#' @param config Configuration options (including which components are enabled)
#' @param translate Translation function
#'
#' @return A top-level navigation union component
#' @export
TopLevelUnion <- function(id, app_data_connection = NULL, active_tab = reactiveVal("micro_tab"), 
                          config = NULL, translate = function(x) x) {
  # Source required components
  source("update_scripts/global_scripts/10_rshinyapp_components/micro/MicroComponentsUnion.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/macro/macro_overview.R")
  source("update_scripts/global_scripts/10_rshinyapp_components/target/target_profiling.R")
  
  # Get the list of enabled components from config
  # IMPORTANT: Config MUST explicitly define which components to include
  # We don't use default values to ensure only specified components are loaded
  if (is.null(config) || is.null(config$components) || length(config$components) == 0) {
    warning("No components specified in configuration. Application will have no content.")
    enabled_components <- c()
  } else {
    enabled_components <- names(config$components)
  }
  
  # Create component instances based on what's explicitly enabled in config
  components <- list()
  
  # Component mapping - maps component name to its constructor function
  component_constructors <- list(
    micro = function(cid) MicroComponentsUnion(cid, app_data_connection, config$components$micro, translate),
    macro = function(cid) macro_overview(cid, app_data_connection, config$components$macro, translate),
    target = function(cid) target_profiling(cid, app_data_connection, config$components$target, translate)
  )
  
  # Only create components that are explicitly configured
  for (comp_name in enabled_components) {
    if (comp_name %in% names(component_constructors)) {
      components[[comp_name]] <- component_constructors[[comp_name]](paste0(id, "_", comp_name))
    } else {
      warning(paste("Unknown component type:", comp_name, "- skipping"))
    }
  }
  
  # Set initial visibility based on active tab
  initial_visibility <- list()
  for (comp_name in names(components)) {
    initial_visibility[[comp_name]] <- (paste0(comp_name, "_tab") == active_tab())
  }
  
  # Create union config
  union_config <- list(
    initial_visibility = initial_visibility
  )
  
  # Create the Union
  top_level_union <- Union(
    id,
    config = union_config,
    # Use do.call to dynamically pass all components
    # This allows for conditional component inclusion based on config
    # without having to manually list each component
    do.call(what = "list", args = components)
  )
  
  # Component UI configuration with titles from YAML config
  component_ui_config <- list(
    micro = list(
      label = if (!is.null(config$components$micro$title)) translate(config$components$micro$title) else translate("Micro Analysis"),
      icon = "user"
    ),
    macro = list(
      label = if (!is.null(config$components$macro$title)) translate(config$components$macro$title) else translate("Macro Analysis"),
      icon = "chart-bar"
    ),
    target = list(
      label = if (!is.null(config$components$target$title)) translate(config$components$target$title) else translate("Target Marketing"),
      icon = "bullseye"
    )
  )
  
  # Create the UI for top-level navigation
  nav_ui <- function(id) {
    ns <- NS(id)
    
    current_tab <- active_tab()
    
    div(
      class = "navbar-custom panel-header",
      
      # Create buttons dynamically based on enabled components only
      lapply(names(components), function(comp_name) {
        # Get custom title from config if available
        custom_title <- NULL
        custom_icon <- NULL
        
        if (!is.null(config) && !is.null(config$components[[comp_name]])) {
          custom_title <- config$components[[comp_name]]$title
          custom_icon <- config$components[[comp_name]]$icon
        }
        
        # Get UI config for this component (preferring config values if available)
        ui_config <- component_ui_config[[comp_name]]
        if (is.null(ui_config)) {
          ui_config <- list(
            label = translate(paste0(comp_name, " Analysis")),
            icon = "cube"
          )
        }
        
        # Override with custom values from config if available
        if (!is.null(custom_title)) {
          ui_config$label <- translate(custom_title)
        }
        
        if (!is.null(custom_icon)) {
          ui_config$icon <- custom_icon
        }
        
        # Set active class based on current tab
        is_active <- (current_tab == paste0(comp_name, "_tab"))
        button_class <- paste0("tab-button", if(is_active) " active" else "")
        
        actionButton(
          ns(paste0(comp_name, "_tab")),
          ui_config$label,
          icon = icon(ui_config$icon),
          class = button_class
        )
      })
    )
  }
  
  # Create the main display UI function
  display_ui <- function(id) {
    ns <- NS(id)
    
    div(
      id = ns("top_level_container"),
      class = "top-level-container",
      
      # Navigation buttons
      nav_ui(id),
      
      # Main content container
      div(
        id = ns("content_container"),
        class = "content-container",
        top_level_union$ui$display(id)
      )
    )
  }
  
  # Create the server function
  server_fn <- function(input, output, session) {
    ns <- session$ns
    
    # Initialize the union server
    union_server <- top_level_union$server(id, app_data_connection, session)
    
    # Get current tab state at startup (if any)
    current_active_tab <- active_tab()
    
    # Initialize with visible component based on active tab
    initial_active_comp <- sub("_tab$", "", current_active_tab)
    if (initial_active_comp %in% names(components)) {
      for (name in names(components)) {
        union_server$component_state$toggle_component(name, name == initial_active_comp)
      }
    }
    
    # Handle tab button clicks
    for (comp_name in names(components)) {
      local({
        local_comp_name <- comp_name
        local_tab_id <- paste0(local_comp_name, "_tab")
        
        observeEvent(input[[local_tab_id]], {
          # Update active tab reactive value
          active_tab(local_tab_id)
          
          # Update button styling
          shinyjs::removeClass(selector = ".tab-button", class = "active")
          shinyjs::addClass(id = local_tab_id, class = "active")
          
          # Update component visibility without disturbing internal state of each component
          for (name in names(components)) {
            union_server$component_state$toggle_component(name, name == local_comp_name)
          }
          
          # Trigger an event to notify the app that the tab has changed
          session$userData$last_tab_change <- Sys.time()
        })
      })
    }
    
    # Return server information
    list(
      component_state = union_server$component_state,
      server_outputs = union_server$server_outputs
    )
  }
  
  # Create defaults function 
  defaults_fn <- function() {
    # Start with top-level defaults
    defaults <- list(
      layout = "tabs",
      animation = "fade",
      transition_duration = 300
    )
    
    # Add component-specific defaults
    if (is.function(top_level_union$defaults)) {
      component_defaults <- top_level_union$defaults()
      defaults <- c(defaults, component_defaults)
    }
    
    return(defaults)
  }
  
  # Return the complete component
  list(
    ui = list(
      filter = function(id) div(), # Empty filter UI since filters are in sidebar
      display = display_ui
    ),
    server = server_fn,
    defaults = defaults_fn
  )
}
```

## Advantages of the New Design

1. **Preserves Existing Components**: Uses the current component structure without major changes
2. **Hierarchical Unions**: Union components at each navigation level (top-level tabs, micro components)
3. **Multi-Level State Management**: Each navigation level maintains its own independent state
4. **State Persistence**: Preserves second-level navigation state when switching between top-level tabs
5. **Clean Navigation Management**: Each Union manages its own level of navigation
6. **Centralized State Management**: Component visibility handled through Union state
7. **Consistent Structure**: All components follow the UI-Server-Defaults Triple Rule (R09)
8. **Better Organization**: Clear separation between navigation levels
9. **Reduced Code Duplication**: Eliminates redundant show/hide logic across the application
10. **Easy Extensibility**: New components can be added to any level with minimal changes
11. **Strictly Configuration-Driven**: Components are only loaded when explicitly defined in YAML configuration
12. **Dynamic UI Generation**: Navigation elements are created dynamically based on the configuration
13. **Customizable Labels and Icons**: Component titles and icons can be specified in YAML config
14. **Nested Configuration Support**: Works with nested YAML structures (components.micro.customer_profile.title)

## Component Interconnections and State Flow

The application uses a hierarchical structure of Union components to manage state and navigation:

1. **TopLevelUnion**: Manages the top-level navigation between main app tabs (Micro, Macro, Target)
2. **SidebarUnion**: Controls which filters are displayed based on the active top-level tab
3. **MicroComponentsUnion**: Manages second-level navigation within the Micro tab

### Two-Level State Management Flow

1. **Top Level Navigation State:**
   - The `active_tab` reactive value in app.R tracks the currently selected top-level tab
   - When a top-level tab button is clicked, the active_tab value is updated
   - This change triggers observers in both the TopLevelUnion and SidebarUnion components
   - The observers update component visibility using each Union's component_state manager
   - Only components relevant to the active top-level tab are shown

2. **Second Level Navigation State:**
   - Each second-level component (like MicroComponentsUnion) maintains its own internal active state
   - The `active_component` reactive value within MicroComponentsUnion tracks the currently active micro component
   - When a second-level navigation button is clicked, only that component's visibility is toggled to TRUE while others are set to FALSE
   - This creates independent navigation state at each level, preserving state when switching between top-level tabs

### Implementation Process

1. **Create Union Components**:
   - Create the MicroComponentsUnion.R file in the micro/ directory
   - Create the SidebarUnion.R file in the sidebars/ directory
   - Create the TopLevelUnion.R file in a new app_components/ directory

2. **Update App.R**:
   - Replace direct component references with Union component instances
   - Initialize the Union components with proper configuration
   - Connect active_tab reactive value to both Unions

3. **Testing Approach**:
   - Test each Union component individually with test scripts
   - Test hierarchical composition with main app.R
   - Verify that navigation and state management function correctly
   - Ensure all components follow the UI-Server-Defaults Triple Rule

### Final Component Structure

The finished implementation will have a clear hierarchical organization:

```
app.R
├── TopLevelUnion (manages top-level navigation)
│   ├── MicroComponentsUnion (manages micro components)
│   │   ├── microCustomerComponent
│   │   ├── microDNADistributionComponent
│   │   └── microTransactionsComponent
│   ├── macroComponent
│   └── targetComponent
└── SidebarUnion (manages filters)
    ├── CommonFiltersComponent
    ├── MicroFiltersComponent
    ├── MacroFiltersComponent
    └── TargetFiltersComponent
```

Each Union component follows the UI-Server-Defaults Triple Rule (R09) and implements proper state management through the component_state API provided by the Union pattern.

## Implementation Steps

1. Ensure the Union.R implementation properly supports the UI-Server-Defaults Triple Rule
2. Create MicroComponentsUnion.R to combine micro components
3. Create SidebarUnion.R to combine filter components
4. Create TopLevelUnion.R to combine main app tabs
5. Update app.R to use these Union components
6. Test the application thoroughly