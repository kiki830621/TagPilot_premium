---
id: "MP45"
title: "Automatic Data Availability Detection Metaprinciple"
type: "meta-principle"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
derives_from:
  - "MP02": "Default Deny"
  - "MP10": "Information Flow Transparency"
influences:
  - "P70": "Complete Input Display"
---

# Automatic Data Availability Detection Metaprinciple

## Core Principle

**Application components must automatically detect and adapt to data availability based on actual data in the system, rather than relying on manual configuration or static mappings. The existence, completeness, and validity of data should be intrinsically determined through systematic inspection at runtime.**

## Conceptual Framework

The Automatic Data Availability Detection Metaprinciple establishes a fundamental approach to data-dependent features that:

1. **Eliminates Manual Configuration**: Removes the need for manual specification of data availability
2. **Ensures Truth in Presentation**: Guarantees that UI reflects actual data state
3. **Adapts Dynamically**: Responds to changes in data state without intervention
4. **Maintains Transparency**: Clearly communicates availability status to users
5. **Implements Self-Discovery**: Enables components to discover their own data dependencies

This meta-principle removes the disconnect between configured data availability and actual data availability, creating a system that inherently knows what data it has and can use.

## Implementation Requirements

### 1. Runtime Data Inspection

1. **Systematic Probing**: Components must implement systematic data inspection to determine availability:
   ```r
   checkDataAvailability <- function(data_source, dimension) {
     tryCatch({
       # Attempt to retrieve data
       data <- getDataFromSource(data_source, dimension)
       # Verify data meets minimum requirements
       return(!is.null(data) && nrow(data) > 0)
     }, error = function(e) {
       logDataAvailabilityFailure(data_source, dimension, e)
       return(FALSE)
     })
   }
   ```

2. **Comprehensive Checking**: Availability checks must cover:
   - Database existence
   - Table/collection existence
   - Data completeness for critical dimensions
   - Schema validity
   - Access permissions

3. **Deep Inspection**: For complex data dependencies, implement deep inspection:
   ```r
   deepInspectAvailability <- function(data_source, required_dimensions) {
     availability <- list()
     
     # Inspect each dimension individually
     for (dim in required_dimensions) {
       availability[[dim]] <- checkDimensionData(data_source, dim)
     }
     
     # Inspect cross-dimensional requirements
     for (dim_pair in getCriticalDimensionPairs()) {
       dim1 <- dim_pair[1]
       dim2 <- dim_pair[2]
       if (availability[[dim1]] && availability[[dim2]]) {
         availability[[paste0(dim1, "_x_", dim2)]] <- 
           checkCrossDimensionalData(data_source, dim1, dim2)
       }
     }
     
     return(availability)
   }
   ```

### 2. Centralized Availability Registry

1. **Global Availability State**: Maintain a centralized availability registry:
   ```r
   initializeAvailabilityRegistry <- function() {
     # Initialize empty registry
     registry <- reactiveVal(list())
     
     # Set up automatic refresh mechanism
     autoInvalidate <- reactiveTimer(300000) # 5-minute refresh
     
     observeEvent(autoInvalidate(), {
       refreshAvailabilityRegistry(registry)
     })
     
     return(registry)
   }
   ```

2. **Standard Registration Pattern**: Use consistent registration pattern:
   ```r
   registerDataAvailability <- function(registry, domain, dimension, is_available) {
     current <- registry()
     if (is.null(current[[domain]])) {
       current[[domain]] <- list()
     }
     current[[domain]][[dimension]] <- is_available
     registry(current)
   }
   ```

3. **Hierarchical Availability**: Implement cascading availability:
   ```r
   isAvailable <- function(registry, domain, dimension = NULL) {
     current <- registry()
     
     # If no specific dimension requested, check if domain has any available dimensions
     if (is.null(dimension)) {
       return(!is.null(current[[domain]]) && 
              any(unlist(current[[domain]], recursive = TRUE)))
     }
     
     # Check specific dimension
     return(!is.null(current[[domain]]) && 
            !is.null(current[[domain]][[dimension]]) && 
            current[[domain]][[dimension]])
   }
   ```

### 3. Initialization-Time Discovery

1. **Bootstrap Discovery Process**: Implement discovery during initialization:
   ```r
   discoverDataAvailability <- function() {
     registry <- initializeAvailabilityRegistry()
     
     # Discover database availability
     databases <- discoverDatabases()
     for (db in databases) {
       registerDataAvailability(registry, "database", db$name, db$available)
       
       if (db$available) {
         # Discover tables in available databases
         tables <- discoverTables(db$name)
         for (table in tables) {
           registerDataAvailability(registry, "table", 
                                   paste0(db$name, ".", table$name), 
                                   table$available)
         }
       }
     }
     
     # Discover dimension availability
     dimensions <- c("channel", "category", "region", "time")
     for (dim in dimensions) {
       available <- checkDimensionAvailability(dim)
       registerDataAvailability(registry, "dimension", dim, available)
       
       # Discover values within dimensions
       if (available) {
         values <- getDimensionValues(dim)
         for (val in values) {
           registerDataAvailability(registry, dim, val$id, val$has_data)
         }
       }
     }
     
     return(registry)
   }
   ```

2. **Dependency Chain Resolution**: Build and resolve the data dependency chain:
   ```r
   resolveDependencyChain <- function(registry) {
     # Define component dependencies
     dependencies <- list(
       micro_channel_selection = list(domain = "channel", dimensions = c("amazon", "officialwebsite")),
       micro_category_selection = list(domain = "category", 
                                      dimensions = c("000", "001", "002", "003")),
       # ... other component dependencies
     )
     
     # Resolve dependencies
     resolved <- list()
     for (component_id in names(dependencies)) {
       dep <- dependencies[[component_id]]
       component_availability <- list()
       
       # Check availability of each dimension value
       for (dim in dep$dimensions) {
         component_availability[[dim]] <- isAvailable(registry, dep$domain, dim)
       }
       
       resolved[[component_id]] <- component_availability
     }
     
     return(resolved)
   }
   ```

### 4. Reactive Updating

1. **Data Change Observers**: Implement reactivity to data changes:
   ```r
   observeDataChanges <- function(registry) {
     # Watch for database changes
     observe({
       # Check for new tables or structure changes
       db_changes <- detectDatabaseChanges()
       
       if (length(db_changes) > 0) {
         for (change in db_changes) {
           refreshAvailabilityForDomain(registry, change$domain, change$dimension)
         }
       }
     })
     
     # Watch for data imports
     observeEvent(input$import_data, {
       # After import, refresh affected domains
       affected_domains <- getAffectedDomains(input$import_source)
       for (domain in affected_domains) {
         refreshAvailabilityForDomain(registry, domain)
       }
     })
   }
   ```

2. **Invalidation Events**: Define standard invalidation events:
   ```r
   invalidateAvailability <- function(registry, domain, dimension = NULL) {
     # Get current state
     current <- registry()
     
     # If dimension is specified, invalidate only that dimension
     if (!is.null(dimension)) {
       if (!is.null(current[[domain]]) && !is.null(current[[domain]][[dimension]])) {
         current[[domain]][[dimension]] <- NULL
       }
     } else {
       # Invalidate entire domain
       current[[domain]] <- NULL
     }
     
     # Update registry
     registry(current)
     
     # Trigger refresh for invalidated entries
     refreshAvailabilityForDomain(registry, domain, dimension)
   }
   ```

3. **Automatic Recovery**: Implement recovery from data changes:
   ```r
   enableAutoRecovery <- function(registry) {
     observe({
       # Monitor for data restoration events
       restoration_events <- detectDataRestorationEvents()
       
       for (event in restoration_events) {
         # Recheck availability for restored data
         is_available <- checkDataAvailability(
           event$data_source, 
           event$dimension
         )
         
         # Update registry
         registerDataAvailability(
           registry, 
           event$domain, 
           event$dimension, 
           is_available
         )
       }
     })
   }
   ```

### 5. UI Integration

1. **Component-Level Adaptation**: Implement UI that adapts to availability:
   ```r
   renderAdaptiveControl <- function(input_id, label, domain, values, registry) {
     renderUI({
       # Check availability of each value
       available_values <- list()
       disabled_states <- list()
       
       for (name in names(values)) {
         value <- values[[name]]
         is_available <- isAvailable(registry, domain, value)
         available_values[[name]] <- value
         disabled_states[[value]] <- !is_available
       }
       
       # Render with availability indicators
       radioButtons(
         input_id,
         label,
         choices = available_values,
         selected = getFirstAvailable(available_values, disabled_states),
         choiceNames = lapply(names(available_values), function(name) {
           value <- available_values[[name]]
           if (disabled_states[[value]]) {
             div(
               style = "color: #aaa; cursor: not-allowed;",
               paste0(name, " (No Data)")
             )
           } else {
             name
           }
         }),
         choiceValues = unname(available_values)
       )
     })
   }
   ```

2. **Availability Indicators**: Implement consistent indicators:
   ```r
   createAvailabilityIndicator <- function(domain, dimension, registry) {
     renderUI({
       is_available <- isAvailable(registry, domain, dimension)
       
       if (is_available) {
         tags$span(
           class = "data-available",
           icon("check-circle"), 
           "Data Available"
         )
       } else {
         tags$span(
           class = "data-unavailable",
           icon("exclamation-triangle"), 
           "Data Unavailable"
         )
       }
     })
   }
   ```

## Self-Discovery vs. Registration

The metaprinciple defines two complementary approaches:

### 1. Absolute Self-Discovery

Components implement full self-discovery, determining availability without central configuration:

```r
# Channel selection with self-discovery
channelSelectionUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4("Select Channel"),
    uiOutput(ns("channel_options")),
    uiOutput(ns("availability_status"))
  )
}

channelSelectionServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Self-discover available channels
    channels <- reactive({
      discoverChannels()
    })
    
    # Render dynamic channel options
    output$channel_options <- renderUI({
      all_channels <- channels()
      
      radioButtons(
        session$ns("channel"),
        "Marketing Channel:",
        choices = getChannelChoices(all_channels),
        selected = getFirstAvailableChannel(all_channels)
      )
    })
    
    # Show availability status
    output$availability_status <- renderUI({
      current_selection <- input$channel
      current_availability <- channels()[[current_selection]]$available
      
      if (current_availability) {
        tags$div(class = "availability-indicator available", "Data Available")
      } else {
        tags$div(class = "availability-indicator unavailable", "Data Unavailable")
      }
    })
    
    # Return reactive values
    return(reactive({
      list(
        channel = input$channel,
        available = !is.null(channels()[[input$channel]]) && 
                   channels()[[input$channel]]$available
      )
    }))
  })
}
```

### 2. Registry-Based Discovery

Components retrieve availability from central registry for consistency:

```r
# Channel selection with registry
channelSelectionWithRegistryUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h4("Select Channel"),
    uiOutput(ns("channel_options"))
  )
}

channelSelectionWithRegistryServer <- function(id, availability_registry) {
  moduleServer(id, function(input, output, session) {
    # Get all channels (configured and unconfigured)
    all_channels <- reactive({
      getConfiguredChannels()
    })
    
    # Render channel options based on registry availability
    output$channel_options <- renderUI({
      channels <- all_channels()
      
      # Create choice names with availability indicators
      choice_names <- lapply(names(channels), function(name) {
        channel_id <- channels[[name]]
        is_available <- isAvailable(availability_registry, "channel", channel_id)
        
        if (!is_available) {
          tags$div(
            tags$span(name),
            tags$span(class = "unavailable-tag", "(No Data Available)")
          )
        } else {
          name
        }
      })
      
      # Create radio buttons with disabled unavailable options
      radioButtons(
        session$ns("channel"),
        "Marketing Channel:",
        choiceNames = choice_names,
        choiceValues = unname(channels),
        selected = getFirstAvailable(channels, availability_registry, "channel")
      )
    })
    
    # Return selection with availability
    return(reactive({
      current <- input$channel
      available <- isAvailable(availability_registry, "channel", current)
      
      list(
        channel = current,
        available = available
      )
    }))
  })
}
```

## Examples

### Example 1: Marketing Channel Availability Detection

```r
detectMarketingChannelAvailability <- function() {
  # Define all potential marketing channels
  channels <- c("amazon", "officialwebsite", "retail", "wholesale")
  availability <- list()
  
  # Check each channel for data availability
  for (channel in channels) {
    # Attempt to get sample data to verify channel has data
    tryCatch({
      # Try to get data for this channel
      query <- paste0("SELECT COUNT(*) as count FROM sales WHERE channel = '", channel, "'")
      result <- DBI::dbGetQuery(app_data_conn, query)
      
      # Channel has data if count > 0
      availability[[channel]] <- result$count[1] > 0
      
      # Log result
      message("Channel ", channel, " availability: ", availability[[channel]])
    }, error = function(e) {
      message("Error checking channel ", channel, " availability: ", e$message)
      availability[[channel]] <- FALSE
    })
  }
  
  return(availability)
}
```

### Example 2: Time-Range Availability Detection

```r
detectTimeRangeAvailability <- function(source_table) {
  # Check data range availability
  available_ranges <- list()
  
  tryCatch({
    # Get min and max dates
    query <- paste0("SELECT MIN(date) as min_date, MAX(date) as max_date FROM ", source_table)
    result <- DBI::dbGetQuery(app_data_conn, query)
    
    if (!is.null(result) && nrow(result) > 0 && !is.na(result$min_date[1])) {
      min_date <- result$min_date[1]
      max_date <- result$max_date[1]
      
      # Define availability ranges
      available_ranges$full <- list(
        start = min_date,
        end = max_date,
        available = TRUE
      )
      
      # Define standard ranges and check if they're within available data
      standard_ranges <- list(
        "last_7_days" = list(
          start = Sys.Date() - 7,
          end = Sys.Date()
        ),
        "last_30_days" = list(
          start = Sys.Date() - 30,
          end = Sys.Date()
        ),
        "last_90_days" = list(
          start = Sys.Date() - 90,
          end = Sys.Date()
        ),
        "last_year" = list(
          start = Sys.Date() - 365,
          end = Sys.Date()
        )
      )
      
      # Check which standard ranges have data
      for (range_name in names(standard_ranges)) {
        range <- standard_ranges[[range_name]]
        # Range is available if it overlaps with available data
        range_available <- !(range$end < min_date || range$start > max_date)
        available_ranges[[range_name]] <- list(
          start = range$start,
          end = range$end,
          available = range_available
        )
      }
    } else {
      # No date data available
      available_ranges$full <- list(
        start = NULL,
        end = NULL,
        available = FALSE
      )
    }
  }, error = function(e) {
    message("Error detecting time range availability: ", e$message)
    available_ranges$full <- list(
      start = NULL,
      end = NULL,
      available = FALSE
    )
  })
  
  return(available_ranges)
}
```

### Example 3: Integration with Filter UI

```r
# UI with automatic availability
automaticFilterUI <- function(id, filter_config) {
  ns <- NS(id)
  
  # Discover availability during initialization
  availability <- discoverDataAvailability()
  
  # Render filters based on discovered availability
  div(
    class = "automatic-filters",
    
    # Channel selection with availability indicators
    renderAdaptiveControl(
      ns("channel"),
      "Marketing Channel",
      "channel",
      filter_config$channels,
      availability
    ),
    
    # Category selection with availability indicators
    renderAdaptiveControl(
      ns("category"),
      "Product Category",
      "category",
      filter_config$categories,
      availability
    ),
    
    # Date range with availability indicators
    dateRangeInput(
      ns("date_range"),
      "Date Range",
      start = getAvailableStartDate(availability),
      end = getAvailableEndDate(availability),
      min = getMinAvailableDate(availability),
      max = getMaxAvailableDate(availability)
    )
  )
}
```

## Relation to Other Principles

### Relation to Default Deny (MP02)

This principle extends MP02 by:
1. **Data Skepticism**: Assuming data is unavailable until proven available
2. **Verification First**: Requiring verification before enabling features
3. **Defensive Processing**: Protecting against attempts to use unavailable data

### Relation to Information Flow Transparency (MP10)

This principle implements MP10 by:
1. **Data Traceability**: Making data presence and absence explicit
2. **Flow Monitoring**: Tracking data through system components
3. **Transparent Communication**: Clearly communicating data state to users

### Relation to Complete Input Display (P70)

This principle supports P70 by:
1. **Availability State Source**: Providing the source of truth for availability state
2. **Dynamic Adaptation**: Enabling adaptation to changing data state
3. **Unified Visibility**: Creating a consistent system-wide view of data state

## Benefits

1. **Reduced Configuration**: Eliminates need for manual data availability configuration
2. **Truth-Based UI**: Ensures UI reflects actual system state
3. **Self-Healing**: System adapts automatically when data becomes available
4. **Consistent Presentation**: All components share same availability understanding
5. **Resilience**: Recovers gracefully from data changes
6. **Transparency**: Clearly communicates data limitations
7. **Reduced Errors**: Prevents attempts to use unavailable data

## Conclusion

The Automatic Data Availability Detection Metaprinciple establishes that systems should intrinsically determine what data is available rather than relying on manual configuration. By implementing systematic inspection and self-discovery, applications can adapt dynamically to the actual state of their data while maintaining a transparent and consistent experience for users.

This approach eliminates the disconnect between configured and actual data availability, creating more resilient, self-aware systems that accurately represent their capabilities to users.