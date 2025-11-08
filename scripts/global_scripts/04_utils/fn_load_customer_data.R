#' Load and Combine Customer Data Efficiently
#'
#' Following P071, P074, and R092 principles
load_customer_data <- function(conn, platform_filter = NULL, customer_filter = NULL, 
                              value_threshold = NULL, limit = NULL, use_cache = TRUE) {
  # Create a cache environment if it doesn't exist
  if (!exists("customer_data_cache", envir = .GlobalEnv) && use_cache) {
    assign("customer_data_cache", new.env(), envir = .GlobalEnv)
  }
  
  # Generate cache key based on all parameters
  cache_key <- paste0(
    "platform_", ifelse(is.null(platform_filter), "all", platform_filter),
    "_customers_", ifelse(is.null(customer_filter), "all", paste0(length(customer_filter), "filtered")),
    "_value_", ifelse(is.null(value_threshold), "all", value_threshold),
    "_limit_", ifelse(is.null(limit), "none", limit)
  )
  
  # Check if we have a valid connection
  if (is.null(conn) || !DBI::dbIsValid(conn)) {
    stop("Invalid database connection")
  }
  
  # Check if result is in cache
  if (use_cache && exists("customer_data_cache", envir = .GlobalEnv) && 
      exists(cache_key, envir = get("customer_data_cache", envir = .GlobalEnv))) {
    message("Using cached customer data for ", cache_key)
    return(get(cache_key, envir = get("customer_data_cache", envir = .GlobalEnv)))
  }
  
  # Construct query with filters (implementing P74: Reactive Data Filtering)
  profile_query <- "SELECT * FROM df_customer_profile"
  dna_query <- "SELECT * FROM df_dna_by_customer"
  
  # Build WHERE clauses
  profile_where <- NULL
  dna_where <- NULL
  
  # Platform filter - Following R38 Platform Numbering Convention
  if (!is.null(platform_filter)) {
    # Source detect_data_availability.R if load_platform_dictionary is not available
    if (!exists("load_platform_dictionary")) {
      tryCatch({
        message("Sourcing detect_data_availability.R for platform dictionary functions")
        source(file.path("update_scripts", "global_scripts", "utils", "detect_data_availability.R"))
      }, error = function(e) {
        warning("Could not source detect_data_availability.R: ", e$message)
      })
    }
    
    # Force (re)loading of platform dictionary to ensure we have it
    platform_dict_local <- NULL
    tryCatch({
      # Load using the proper path variables following MP46 Neighborhood Principle
      # First, determine the proper path using ROOT_DIR, APP_DIR, or GLOBAL_DIR if available
      if (exists("GLOBAL_DIR")) {
        dict_path <- file.path(GLOBAL_DIR, "global_data", "parameters", "platform_dictionary.xlsx")
      } else if (exists("APP_DIR")) {
        dict_path <- file.path(APP_DIR, "update_scripts", "global_scripts", "global_data", "parameters", "platform_dictionary.xlsx")
      } else if (exists("ROOT_DIR")) {
        dict_path <- file.path(ROOT_DIR, "precision_marketing_app", "update_scripts", "global_scripts", "global_data", "parameters", "platform_dictionary.xlsx")
      } else {
        # Fallback to relative path
        dict_path <- file.path("update_scripts", "global_scripts", "global_data", "parameters", "platform_dictionary.xlsx")
      }
      message("Looking for platform dictionary at: ", dict_path)
      if (file.exists(dict_path)) {
        message("Loading platform dictionary from path: ", dict_path)
        if (!requireNamespace("readxl", quietly = TRUE)) {
          install.packages("readxl")
        }
        platform_dict_local <- readxl::read_excel(dict_path)
        message("Successfully loaded platform dictionary with ", nrow(platform_dict_local), " entries")
        # Print the platform dictionary content for debugging
        print(platform_dict_local)
      } else if (exists("load_platform_dictionary")) {
        message("Using load_platform_dictionary function")
        platform_dict_local <- load_platform_dictionary()
      }
    }, error = function(e) {
      warning("Error loading platform dictionary: ", e$message)
    })
    
    # Create platform mapping (recreate every time to ensure freshness)
    platform_dict_mapping <- list()
    
    if (!is.null(platform_dict_local) && nrow(platform_dict_local) > 0) {
      message("Creating platform mapping from dictionary with ", nrow(platform_dict_local), " entries")
      
      # Add mappings for names (normalize by removing spaces and converting to lowercase)
      for (i in 1:nrow(platform_dict_local)) {
        if (!is.na(platform_dict_local$platform_name_english[i])) {
          name_key <- tolower(gsub(" ", "", platform_dict_local$platform_name_english[i]))
          platform_dict_mapping[[name_key]] <- platform_dict_local$platform_number[i]
          message("Added mapping: ", name_key, " -> ", platform_dict_local$platform_number[i])
        }
      }
      
      # Add mappings for code aliases if available
      if ("code_alias" %in% colnames(platform_dict_local)) {
        for (i in 1:nrow(platform_dict_local)) {
          if (!is.na(platform_dict_local$code_alias[i])) {
            alias_key <- tolower(platform_dict_local$code_alias[i])
            platform_dict_mapping[[alias_key]] <- platform_dict_local$platform_number[i]
            message("Added alias mapping: ", alias_key, " -> ", platform_dict_local$platform_number[i])
          }
        }
      }
      
      # Store in global environment for reuse
      assign("platform_dict_mapping", platform_dict_mapping, envir = .GlobalEnv)
    } else {
      # Fallback to hardcoded mapping if platform dictionary cannot be loaded
      warning("Platform dictionary could not be loaded. Using fallback mappings.")
      platform_dict_mapping[["amazon"]] <- 1
      platform_dict_mapping[["amz"]] <- 1
      platform_dict_mapping[["officialwebsite"]] <- 2
      platform_dict_mapping[["web"]] <- 2
      platform_dict_mapping[["retailstore"]] <- 3
      platform_dict_mapping[["ret"]] <- 3
      platform_dict_mapping[["distributor"]] <- 4
      platform_dict_mapping[["dst"]] <- 4
      platform_dict_mapping[["socialmedia"]] <- 5
      platform_dict_mapping[["soc"]] <- 5
      platform_dict_mapping[["ebay"]] <- 6
      platform_dict_mapping[["eby"]] <- 6
      platform_dict_mapping[["cyberbiz"]] <- 7
      platform_dict_mapping[["cbz"]] <- 7
      platform_dict_mapping[["multiplatform"]] <- 9
      platform_dict_mapping[["mpt"]] <- 9
      
      # Store in global environment
      assign("platform_dict_mapping", platform_dict_mapping, envir = .GlobalEnv)
    }
    
    # Determine the numeric platform ID
    platform_id <- NULL
    
    # If already numeric, use as is
    if (is.numeric(platform_filter) || grepl("^[0-9]+$", platform_filter)) {
      platform_id <- platform_filter
      message("Platform filter is already numeric: ", platform_id)
    } 
    # Try to lookup in our mapping
    else {
      platform_key <- tolower(platform_filter)
      if (platform_key %in% names(platform_dict_mapping)) {
        platform_id <- platform_dict_mapping[[platform_key]]
        message("Mapped platform '", platform_filter, "' to ID: ", platform_id)
      } else {
        warning("Could not find mapping for platform: ", platform_filter)
      }
    }
    
    # Add the WHERE condition if we found a valid ID
    if (!is.null(platform_id)) {
      # Make sure platform_id is numeric (R55: Platform ID Reference Rule)
      if (!is.numeric(platform_id) && grepl("^[0-9]+$", platform_id)) {
        # If it's a string of digits, convert to numeric explicitly
        platform_id <- as.numeric(platform_id)
        message("Converted string numeric ID to numeric: ", platform_id)
      }
      
      if (is.numeric(platform_id)) {
        # Use the numeric ID directly in SQL query (no quotes)
        profile_where <- c(profile_where, paste0("platform_id = ", platform_id))
        dna_where <- c(dna_where, paste0("platform = ", platform_id))
        message("Added platform filter with numeric ID: ", platform_id)
      } else {
        warning("Platform ID is not numeric after mapping: '", platform_id, 
                "'. This violates R55 Platform ID Reference Rule. Using empty result.")
        profile_where <- c(profile_where, "1 = 0") # Condition that always evaluates to FALSE
        dna_where <- c(dna_where, "1 = 0")
      }
    } else {
      # If no mapping found, log warning and add a condition that will return no results
      warning("No valid platform ID could be determined for '", platform_filter, "'. Using empty result.")
      profile_where <- c(profile_where, "1 = 0") # Condition that always evaluates to FALSE
      dna_where <- c(dna_where, "1 = 0")
    }
  }
  
  # Customer ID filter (using SQL IN clause for efficiency)
  if (!is.null(customer_filter) && length(customer_filter) > 0) {
    customer_list <- paste0("'", customer_filter, "'", collapse = ",")
    profile_where <- c(profile_where, paste0("customer_id IN (", customer_list, ")"))
    dna_where <- c(dna_where, paste0("customer_id IN (", customer_list, ")"))
  }
  
  # Value threshold filter
  if (!is.null(value_threshold) && !is.na(value_threshold) && value_threshold > 0) {
    dna_where <- c(dna_where, paste0("m_value >= ", value_threshold))
  }
  
  # Combine WHERE clauses if any exist
  if (length(profile_where) > 0) {
    profile_query <- paste0(profile_query, " WHERE ", paste(profile_where, collapse = " AND "))
  }
  
  if (length(dna_where) > 0) {
    dna_query <- paste0(dna_query, " WHERE ", paste(dna_where, collapse = " AND "))
  }
  
  # Add ORDER BY to ensure consistent ordering
  profile_query <- paste0(profile_query, " ORDER BY customer_id")
  dna_query <- paste0(dna_query, " ORDER BY customer_id")
  
  # Add LIMIT if specified
  if (!is.null(limit) && !is.na(limit) && limit > 0) {
    profile_query <- paste0(profile_query, " LIMIT ", limit)
    dna_query <- paste0(dna_query, " LIMIT ", limit)
  }
  
  # Log queries if in debug mode
  if (exists("debug_mode") && debug_mode) {
    message("Profile query: ", profile_query)
    message("DNA query: ", dna_query)
  }
  
  # Load data
  tryCatch({
    profile_data <- DBI::dbGetQuery(conn, profile_query)
    dna_data <- DBI::dbGetQuery(conn, dna_query)
    
    # Check if we got any data
    if (nrow(profile_data) == 0 || nrow(dna_data) == 0) {
      message("No customer data found with the current filters")
      return(data.frame())
    }
    
    # Combine data efficiently using P71 (Row-Aligned Tables)
    combined_data <- combine_aligned_tables(
      profile_data, 
      dna_data, 
      key_column = "customer_id", 
      verify = TRUE,
      fallback_to_join = TRUE,
      handle_duplicates = "suffix"
    )
    
    # Cache the result if caching is enabled
    if (use_cache && exists("customer_data_cache", envir = .GlobalEnv)) {
      assign(cache_key, combined_data, envir = get("customer_data_cache", envir = .GlobalEnv))
    }
    
    return(combined_data)
  }, error = function(e) {
    message("Error loading customer data: ", e$message)
    return(data.frame())
  })
}
