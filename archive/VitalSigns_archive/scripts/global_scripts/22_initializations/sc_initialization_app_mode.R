#LOCK FILE

# 檢查是否已經初始化，避免重複載入
if (exists("INITIALIZATION_COMPLETED") && INITIALIZATION_COMPLETED) {
  message("Initialization already completed. Skipping.")
}


# Performance Acceleration System - P106: Performance Acceleration Principle
# Simple acceleration level setting:
#   0 = Disabled (no optimizations)
#   1 = Basic optimizations (minimal overhead, compatible with all browsers)
#   2 = Enhanced optimizations (balanced performance/compatibility)
#   3 = Maximum optimizations (highest performance, may affect some features)
ACCELERATION_LEVEL <- 0 # Default: Enhanced optimizations

# Simplified approach - enabled if level > 0
is_enabled <- ACCELERATION_LEVEL > 0
message("Performance Acceleration level: ", ACCELERATION_LEVEL, 
        " (", if(is_enabled) "enabled" else "disabled", ")")

# Create acceleration configuration with opt-in strategies
acceleration_config <- list(
  enabled = is_enabled,
  level = ACCELERATION_LEVEL,
  strategies = list(
    ui = list(
      debounce_inputs = TRUE,
      lazy_rendering = ACCELERATION_LEVEL >= 2,
      minimize_updates = ACCELERATION_LEVEL >= 1,
      use_compressed_css = ACCELERATION_LEVEL >= 2,
      batch_ui_updates = ACCELERATION_LEVEL >= 1
    ),
    data = list(
      use_caching = ACCELERATION_LEVEL >= 1,
      sampling_threshold = if(ACCELERATION_LEVEL >= 3) 100000 else Inf,
      compress_large_data = ACCELERATION_LEVEL >= 2,
      prioritize_visible_data = ACCELERATION_LEVEL >= 1,
      use_query_optimization = ACCELERATION_LEVEL >= 2
    ),
    reactive = list(
      isolate_expensive_chains = ACCELERATION_LEVEL >= 2,
      throttle_update_frequency = ACCELERATION_LEVEL >= 1,
      batch_updates = ACCELERATION_LEVEL >= 1,
      debounce_reactives = function(ms) if(ACCELERATION_LEVEL >= 2) ms else 0
    )
  )
)

# Create the function to check if acceleration is enabled
is_acceleration_enabled <- function(category, feature = NULL) {
  # First check if acceleration is enabled at all (level > 0)
  if (!exists("ACCELERATION_LEVEL") || ACCELERATION_LEVEL <= 0) {
    return(FALSE)
  }
  
  # Also check if acceleration_config exists
  if (!exists("acceleration_config")) {
    return(FALSE)
  }
  
  # If just checking category, return general enabled status
  if (is.null(feature)) {
    return(TRUE)
  }
  
  # Check for specific feature
  if (!is.null(acceleration_config$strategies[[category]][[feature]])) {
    if (is.function(acceleration_config$strategies[[category]][[feature]])) {
      # For function-based settings, assume enabled but let function decide details
      return(TRUE)
    } else {
      return(acceleration_config$strategies[[category]][[feature]])
    }
  }
  
  return(FALSE)
}

# Create function to get optimization parameter
get_acceleration_param <- function(category, feature, default = NULL) {
  # First check if acceleration is enabled at all (level > 0)
  if (!exists("ACCELERATION_LEVEL") || ACCELERATION_LEVEL <= 0) {
    return(default)
  }
  
  # Also check if acceleration_config exists
  if (!exists("acceleration_config")) {
    return(default)
  }
  
  if (is.null(acceleration_config$strategies[[category]][[feature]])) {
    return(default)
  }
  
  param <- acceleration_config$strategies[[category]][[feature]]
  if (is.function(param)) {
    return(param(default)) # Call the function with default as parameter
  } else {
    return(param)
  }
}

# Initialize cache environment for data acceleration
.cache_env <- new.env(parent = emptyenv())

# Create optimized versions of common functions
debounced_reactive <- function(expr, ms = 300) {
  if (is_acceleration_enabled("reactive", "debounce_reactives")) {
    ms <- get_acceleration_param("reactive", "debounce_reactives", ms)
    return(shinyjs::debounce(reactive(expr), ms))
  } else {
    return(reactive(expr))
  }
}

load_data_optimized <- function(query, connection, max_rows = NULL) {
  # Check if data caching is enabled
  if (is_acceleration_enabled("data", "use_caching")) {
    # Generate cache key based on query
    cache_key <- digest::digest(list(query = query, max_rows = max_rows))
    
    # Check if data exists in cache
    if (exists(cache_key, envir = .cache_env)) {
      message("Using cached data for query")
      return(get(cache_key, envir = .cache_env))
    }
  }
  
  # Apply query optimization if enabled
  optimized_query <- query
  if (is_acceleration_enabled("data", "use_query_optimization")) {
    # Add LIMIT clause for large queries if not present
    if (!grepl("LIMIT\\s+\\d+", query, ignore.case = TRUE) && !is.null(max_rows)) {
      if (grepl(";\\s*$", query)) {
        # Remove trailing semicolon
        optimized_query <- sub(";\\s*$", "", query)
      }
      optimized_query <- paste0(optimized_query, " LIMIT ", max_rows, ";")
      message("Query optimized with LIMIT clause")
    }
  }
  
  # Load data from connection
  tryCatch({
    full_data <- DBI::dbGetQuery(connection, optimized_query)
    
    # Apply sampling for large datasets if enabled
    if (is_acceleration_enabled("data", "sampling_threshold") && 
        !is.null(max_rows) && 
        nrow(full_data) > get_acceleration_param("data", "sampling_threshold", Inf)) {
      
      message("Sampling data: ", min(max_rows, nrow(full_data)), " rows of ", nrow(full_data))
      sampled_data <- full_data[sample(nrow(full_data), min(max_rows, nrow(full_data))), ]
      
      # Store in cache if caching enabled
      if (is_acceleration_enabled("data", "use_caching")) {
        assign(cache_key, sampled_data, envir = .cache_env)
      }
      
      return(sampled_data)
    }
    
    # Store original data in cache if caching enabled
    if (is_acceleration_enabled("data", "use_caching")) {
      assign(cache_key, full_data, envir = .cache_env)
    }
    
    return(full_data)
  }, error = function(e) {
    message("Error executing query: ", e$message)
    return(data.frame())
  })
}

# Export acceleration functions to global environment
assign("acceleration_config", acceleration_config, envir = .GlobalEnv)
assign("is_acceleration_enabled", is_acceleration_enabled, envir = .GlobalEnv)
assign("get_acceleration_param", get_acceleration_param, envir = .GlobalEnv)
assign("debounced_reactive", debounced_reactive, envir = .GlobalEnv)
assign("load_data_optimized", load_data_optimized, envir = .GlobalEnv)

# Reset initialization flags if needed for re-initialization
if(exists("INITIALIZATION_COMPLETED")) {
  rm(INITIALIZATION_COMPLETED, envir = .GlobalEnv)
}



# 設定初始化標誌
INITIALIZATION_IN_PROGRESS <- TRUE

# 設定是否顯示詳細載入信息
if(!exists("VERBOSE_INITIALIZATION")) {
  VERBOSE_INITIALIZATION <- FALSE # 默認為不詳細顯示
}


# !! CENTRALIZED PACKAGE MANAGEMENT - FOLLOWING R95 !!
# First load the library2 utility (required by initialize_packages)
source(file.path("update_scripts", "global_scripts", "04_utils", "fn_source_with_verbose.R"))
source_with_verbose(file.path("update_scripts", "global_scripts", "04_utils", "fn_library2.R"))

# Load the centralized package initialization function
source_with_verbose(file.path("update_scripts", "global_scripts", "04_utils", "fn_initialize_packages.R"))

# Initialize all required packages using the centralized function
# This follows R95 (Import Requirements Rule) by loading all packages through initialization
initialize_packages(
  mode = OPERATION_MODE,  # Uses the current operation mode
  verbose = VERBOSE_INITIALIZATION,
  force_update = FALSE    # Don't force updates in production
)

# Setup global future plan with mirai backend
# This provides better performance for async operations throughout the app
if ("future" %in% unlist(AVAILABLE_PACKAGES) && "future.mirai" %in% unlist(AVAILABLE_PACKAGES)) {
  ## 1. 依容器 vCPU 自動設定 worker 數
  n <- future::availableCores()   # shinyapps.io 自動給 1/2/4
  
  # Set up mirai backend
  tryCatch({
    future::plan(future.mirai::mirai_multisession, workers = n)
    message("Global future plan set: mirai_multisession with ", n, " workers")
    
    # Set a global flag to prevent components from overriding
    assign(".global_future_plan_set", TRUE, envir = .GlobalEnv)
  }, error = function(e) {
    # Fallback to standard multisession if mirai fails
    warning("Failed to set mirai backend: ", e$message)
    future::plan(future::multisession, workers = n)
    message("Fallback: Using standard multisession with ", n, " workers")
  })
} else {
  message("Future packages not available, async operations will be limited")
}

# 載入 bslib 命名空間並確保其所有功能可用
if ("bslib" %in% unlist(AVAILABLE_PACKAGES)) {
  page_navbar <- bslib::page_navbar
  bs_theme <- bslib::bs_theme
  layout_column_wrap <- bslib::layout_column_wrap
  layout_columns <- bslib::layout_columns
  nav_panel <- bslib::nav_panel
  card <- bslib::card
  card_body <- bslib::card_body
  value_box <- bslib::value_box
  navbar_options <- bslib::navbar_options
  page_sidebar <- bslib::page_sidebar
  sidebar <- bslib::sidebar
  bs_icon <- function(name) { 
    shiny::icon(name)
  }
}

dashboardPage <- bs4Dash::bs4DashPage

##################################################
# 2. 載入全域腳本 (Global Scripts) - APP 模式下僅載入穩定的公開接口
##################################################

# 設定全域腳本所在的資料夾路徑 (存放於 "update_scripts/global_scripts")
Func_dir <- file.path("update_scripts", "global_scripts")

# 定義有序的目錄列表，按照載入順序排列 - APP 模式下僅載入必要目錄
ordered_directories <- c(
  "02_db_utils",             # 資料庫連接工具
  "04_utils",                # 通用工具函數
  "03_config",               # 配置文件  
  "10_rshinyapp_components", # Shiny 應用組件
  "11_rshinyapp_utils"       # Shiny 工具函數
)

# 跟踪已加載的文件，以避免重複加載
loaded_files <- c()
failed_files <- c()

# 加載 library2 函數
source_with_verbose(file.path("update_scripts", "global_scripts", "04_utils", "fn_get_r_files_recursive.R"))



# 已知問題文件列表 - 這些文件有已知問題，暫時跳過
known_issue_files <- c(
  # "macroTrend.R" - 已修復路徑問題
  # "fn_deploy_shiny_app.R" - 已透過排除模式處理
)

# 定義增強的載入函數
safe_source_file <- function(file_path) {
  tryCatch({
    # 檢查是否為已知問題文件
    filename <- basename(file_path)
    if (filename %in% known_issue_files) {
      message(paste("Skipping known issue file:", filename))
      return(FALSE)
    }
    
    # 檢查文件是否存在且可讀取
    if (!file.exists(file_path)) {
      warning(paste("File does not exist:", file_path))
      return(FALSE)
    }
    
    if (!file.access(file_path, 4) == 0) {
      warning(paste("File is not readable:", file_path))
      return(FALSE)
    }
    
    # 嘗試載入文件
    result <- source_with_verbose(file_path)
    return(result)
    
  }, error = function(e) {
    warning(paste("Error loading file:", file_path, "- Error:", e$message))
    return(FALSE)
  }, warning = function(w) {
    message(paste("Warning loading file:", file_path, "- Warning:", w$message))
    return(FALSE)
  })
}

# 依序載入每個目錄中的腳本 - 增強版本
for (dir_name in ordered_directories) {
  dir_path <- file.path(Func_dir, dir_name)
  
  # 檢查目錄是否存在
  if (dir.exists(dir_path)) {
    # 獲取目錄及其子目錄中所有以 fn_、ui_、server_、defaults_ 開頭的 .R 文件
    # 以及具有 UI、Server 或 Defaults 後綴的組件文件
    # （如 sidebarHybridUI.R, microCustomerServer.R, sidebarHybridDefaults.R 等）
    # APP 模式下僅載入正式發布的公開接口
    r_files <- get_r_files_recursive(dir_path)
    
    # 如果目錄不為空，輸出載入信息
    if (length(r_files) > 0) {
      message(paste("Loading", dir_name, "components (found", length(r_files), "files)..."))
      
      # 排序文件以確保按照名稱順序載入
      r_files <- sort(r_files)
      
      # 統計載入結果
      successful_files <- 0
      skipped_files <- 0
      
      # 依序載入每個文件
      for (file in r_files) {
        # 只載入未載入過的文件
        if (!file %in% loaded_files) {
          success <- safe_source_file(file)
          if (success) {
            loaded_files <- c(loaded_files, file)
            successful_files <- successful_files + 1
          } else {
            failed_files <- c(failed_files, file)
            skipped_files <- skipped_files + 1
          }
        }
      }
      
      # 輸出載入結果摘要
      if (skipped_files > 0) {
        message(paste("Completed", dir_name, "- Loaded:", successful_files, "files, Skipped:", skipped_files, "files"))
      } else {
        message(paste("Successfully loaded all", successful_files, "files from", dir_name))
      }
    }
  } else {
    warning(paste("Directory does not exist:", dir_path))
  }
}

# 輸出最終載入結果摘要
separator <- paste(rep("=", 50), collapse = "")
message(separator)
message("INITIALIZATION LOADING SUMMARY")
message(separator)
message(paste("Total files successfully loaded:", length(loaded_files)))
if (length(failed_files) > 0) {
  message(paste("Total files failed/skipped:", length(failed_files)))
  message("Failed files:")
  for (failed_file in failed_files) {
    message(paste("  -", basename(failed_file)))
  }
} else {
  message("All files loaded successfully!")
}
message(separator)

load_app_configs()

vec_product_line_id <<- df_product_line$product_line_id
vec_product_line_id_noall <<- vec_product_line_id[-1]

#lock on
# Load app configuration and brand-specific parameters
# Following P17 (Config-Driven Customization) and R04 (App YAML Configuration)
#load_app_config()
#lock off

#load_app_config

# # First ensure the config loading function exists
# if(file.exists(YAML_CONFIG_FUNCTION_PATH)) {
#   source_with_verbose(YAML_CONFIG_FUNCTION_PATH)
#   
#   # Check if config is already loaded from calling script
#   if (exists("config") && is.list(config) && length(config) > 0) {
#     message("Using pre-loaded configuration from calling script")
#     # Create a copy to prevent side effects
#     app_config <- load_app_config(config = config, verbose = VERBOSE_INITIALIZATION)
#     
#     # Ensure required company configuration exists for P17 compliance
#     if (!exists("company", where = app_config) || !is.list(app_config$company)) {
#       app_config$company <- list()
#       message("Warning: Company configuration section missing. Creating empty structure.")
#     }
#     
#     # Set a flag to explicitly load sidebar components
#     # This is needed to ensure components are available regardless of initialization path
#     FORCE_LOAD_SIDEBAR_COMPONENTS <- TRUE
#     
#     # Ensure marketing channels configuration exists
#     if (!exists("marketing_channels", where = app_config$company)) {
#       app_config$company$marketing_channels <- list(
#         "Amazon" = "amazon",
#         "Official Website" = "officialwebsite"
#       )
#       message("Warning: marketing_channels configuration missing. Using defaults.")
#     }
#     
#     # Ensure default channel is set
#     if (!exists("default_channel", where = app_config$company)) {
#       app_config$company$default_channel <- names(app_config$company$marketing_channels)[1]
#       message("Warning: default_channel configuration missing. Using first channel.")
#     }
#   } else {
#     # Fall back to loading configuration directly from YAML
#     app_config <- load_app_config(config_path = YAML_CONFIG_PATH, verbose = VERBOSE_INITIALIZATION)
#     message("App configuration loaded from YAML file: ", YAML_CONFIG_PATH)
#     
#     # Assign to global config for other scripts to use
#     config <- app_config
#     
#     # Ensure required company configuration exists
#     if (!exists("company", where = config)) {
#       config$company <- list(
#         marketing_channels = list(
#           "Amazon" = "amazon",
#           "Official Website" = "officialwebsite"
#         ),
#         default_channel = "amazon"
#       )
#       message("Warning: Company configuration missing in YAML. Using defaults.")
#     }
#   }
#   
#   # Validate critical configuration sections
#   validate_config <- function(cfg) {
#     valid <- TRUE
#     if (!exists("brand", where = cfg) || !is.list(cfg$brand)) {
#       message("Warning: Brand configuration missing in app_config.")
#       valid <- FALSE
#     }
#     return(valid)
#   }
#   
#   if (!validate_config(app_config)) {
#     message("Config validation failed. Some features may not work correctly.")
#   }
#   
#   # Following P18 (Parameter Organization Structure): Load parameters from Excel files
#   tryCatch({
#     # Define the parameter loading function with fallback mechanism
#     load_parameter_file <- function(filename, company = NULL) {
#       # Try company-specific location first
#       if (!is.null(company) && company != "default" && company != "") {
#         company_path <- file.path(APP_DIR, "app_data", "parameters", company, filename)
#         if (file.exists(company_path)) {
#           message("Loading company-specific parameter: ", company_path)
#           return(list(
#             data = readxl::read_excel(company_path),
#             path = company_path,
#             source = "company"
#           ))
#         }
#       }
#       
#       # Try regular app_data/parameters location
#       app_path <- file.path(APP_DIR, "app_data", "parameters", filename)
#       if (file.exists(app_path)) {
#         message("Loading application parameter: ", app_path)
#         return(list(
#           data = readxl::read_excel(app_path),
#           path = app_path,
#           source = "app"
#         ))
#       }
#       
#       # Fall back to global location
#       global_path <- file.path(GLOBAL_DIR, "global_data", "parameters", filename)
#       if (file.exists(global_path)) {
#         message("Loading global parameter: ", global_path)
#         return(list(
#           data = readxl::read_excel(global_path),
#           path = global_path,
#           source = "global"
#         ))
#       }
#       
#       # None exists, return NULL
#       message("Parameter file not found: ", filename)
#       return(NULL)
#     }
#     
#     # Determine company name from config
#     company <- if (!is.null(app_config$brand$name)) {
#       app_config$brand$name
#     } else {
#       "default"
#     }
#     
#     # Initialize parameters section if it doesn't exist
#     if (is.null(app_config$parameters)) {
#       app_config$parameters <- list()
#     }
#     if (is.null(config$parameters)) {
#       config$parameters <- list()
#     }
#     
#     # Define essential parameter files to load
#     essential_files <- c("platform.xlsx", "product_line.xlsx", "ui_terminology_dictionary.xlsx")
#     
#     # Load essential parameter files with fallback
#     for (file_name in essential_files) {
#       result <- load_parameter_file(file_name, company)
#       if (!is.null(result)) {
#         base_name <- tools::file_path_sans_ext(basename(file_name))
#         
#         # Store in config
#         app_config$parameters[[base_name]] <- result$data
#         config$parameters[[base_name]] <- result$data
#         
#         # Also store source information
#         app_config$parameters[[paste0(base_name, "_source")]] <- result$source
#         config$parameters[[paste0(base_name, "_source")]] <- result$source
#       }
#     }
#     
#     # Also scan for any additional files in the company folder
#     company_folder <- file.path(APP_DIR, "app_data", "parameters", company)
#     if (dir.exists(company_folder)) {
#       additional_files <- list.files(company_folder, pattern = "\\.xlsx$", full.names = TRUE)
#       additional_files <- additional_files[!basename(additional_files) %in% essential_files]
#       
#       if (length(additional_files) > 0) {
#         message("Loading ", length(additional_files), " additional company parameter files")
#         
#         for (file_path in additional_files) {
#           file_name <- tools::file_path_sans_ext(basename(file_path))
#           
#           tryCatch({
#             # Load Excel file
#             data <- readxl::read_excel(file_path)
#             
#             # Store in config
#             app_config$parameters[[file_name]] <- data
#             config$parameters[[file_name]] <- data
#             
#             # Also store source information
#             app_config$parameters[[paste0(file_name, "_source")]] <- "company"
#             config$parameters[[paste0(file_name, "_source")]] <- "company"
#             
#             message("Successfully loaded additional parameter file: ", file_name)
#           }, error = function(e) {
#             message("Error loading additional parameter file ", file_name, ": ", e$message)
#           })
#         }
#       }
#     }
#     
#     # Scan app_data/parameters for non-essential files
#     app_folder <- file.path(APP_DIR, "app_data", "parameters")
#     if (dir.exists(app_folder)) {
#       app_files <- list.files(app_folder, pattern = "\\.xlsx$", full.names = TRUE)
#       app_files <- app_files[!basename(app_files) %in% essential_files]
#       
#       if (length(app_files) > 0) {
#         message("Loading ", length(app_files), " additional application parameter files")
#         
#         for (file_path in app_files) {
#           file_name <- tools::file_path_sans_ext(basename(file_path))
#           
#           # Skip if already loaded from company folder
#           if (!is.null(app_config$parameters[[file_name]])) {
#             next
#           }
#           
#           tryCatch({
#             # Load Excel file
#             data <- readxl::read_excel(file_path)
#             
#             # Store in config
#             app_config$parameters[[file_name]] <- data
#             config$parameters[[file_name]] <- data
#             
#             # Also store source information
#             app_config$parameters[[paste0(file_name, "_source")]] <- "app"
#             config$parameters[[paste0(file_name, "_source")]] <- "app"
#             
#             message("Successfully loaded additional parameter file: ", file_name)
#           }, error = function(e) {
#             message("Error loading additional parameter file ", file_name, ": ", e$message)
#           })
#         }
#       }
#     }
#     
#     # Process all loaded parameter files, starting with essential ones
#     for (param_name in names(app_config$parameters)) {
#       # Skip source information entries
#       if (endsWith(param_name, "_source")) {
#         next
#       }
#       
#       data <- app_config$parameters[[param_name]]
#       
#       # Process specific parameter types
#       if (param_name == "platform") {
#         # Check if the expected columns exist
#         if ("marketing_channel" %in% colnames(data) && "marketing_channel_id" %in% colnames(data)) {
#           # Use specific marketing channel columns if they exist
#           channels <- setNames(
#             as.list(data$marketing_channel_id),
#             data$marketing_channel
#           )
#           message("Loaded marketing channels from dedicated columns in platform parameter")
#         } else if ("platform_name_english" %in% colnames(data)) {
#           # Use platform names as marketing channels if marketing_channel columns don't exist
#           # Create channel ID by converting to lowercase and removing spaces
#           channel_ids <- tolower(gsub(" ", "", data$platform_name_english))
#           channels <- setNames(
#             as.list(channel_ids),
#             data$platform_name_english
#           )
#           message("Created marketing channels from platform names in platform parameter")
#         } else {
#           message("Cannot create marketing channels from platform parameter: required columns missing")
#           # Skip without updating channels
#           next
#         }
#         
#         # Filter out rows with include=0 if the column exists
#         if ("include" %in% colnames(data)) {
#           include_rows <- is.na(data$include) | data$include != 0
#           if (sum(include_rows) < length(include_rows)) {
#             channels <- channels[include_rows]
#             message("Filtered out excluded marketing channels based on include column")
#           }
#         }
#         
#         # Only update if we have channels
#         if (length(channels) > 0) {
#           # Update config
#           app_config$company$marketing_channels <- channels
#           config$company$marketing_channels <- channels
#           app_config$company$default_channel <- names(channels)[1]
#           config$company$default_channel <- names(channels)[1]
#           
#           message(paste("Set", length(channels), "marketing channels:", paste(names(channels), collapse=", ")))
#         } else {
#           message("No valid marketing channels found in platform parameter")
#         }
#       } else if (param_name == "product_line") {
#         # Process product line parameter
#         if ("product_line_name_english" %in% colnames(data)) {
#           # Create product line data with IDs
#           product_line_data <- data
#           if (!"product_line_id" %in% colnames(product_line_data)) {
#             product_line_data$product_line_id <- sprintf("%03d", 0:(nrow(product_line_data)-1))
#           }
#           
#           # Create dictionary
#           language <- if (!is.null(app_config$brand$language)) app_config$brand$language else "en_US.UTF-8"
#           lang_column <- paste0("product_line_name_", language)
#           
#           # If language-specific column doesn't exist, fall back to English
#           if (!lang_column %in% colnames(product_line_data)) {
#             lang_column <- "product_line_name_english"
#           }
#           
#           product_line_dict <- as.list(setNames(
#             product_line_data$product_line_id, 
#             product_line_data[[lang_column]]
#           ))
#           
#           # Store in global environment and config
#           assign("product_line_dtah", product_line_data, envir = .GlobalEnv)
#           assign("product_line_dictionary", product_line_dict, envir = .GlobalEnv)
#           assign("product_line_id_vec", unlist(product_line_dict), envir = .GlobalEnv)
#           assign("vec_product_line_id_noall", unlist(product_line_dict)[-1], envir = .GlobalEnv)
#           
#           message(paste("Set", length(product_line_dict), "product categories:", paste(names(product_line_dict), collapse=", ")))
#         } else {
#           message("Cannot process product_line parameter: required columns missing")
#         }
#       } else if (param_name == "ui_terminology_dictionary") {
#         # Process UI terminology dictionary
#         if (all(c("category", "term_key", "term_english") %in% names(data))) {
#           # Use structured terminology dictionary format
#           language <- if (!is.null(app_config$brand$language)) app_config$brand$language else "en_US.UTF-8"
#           lang_column <- paste0("term_", sub("^([a-z]+)_.*$", "\\1", tolower(language)))
#           
#           # If language column doesn't exist, fall back to English
#           if (!lang_column %in% names(data)) {
#             lang_column <- "term_english"
#           }
#           
#           ui_terms <- data %>%
#             dplyr::group_by(category) %>%
#             dplyr::summarize(
#               terms = list(setNames(term_key, .data[[lang_column]]))
#             ) %>%
#             dplyr::pull(terms, category)
#           assign("ui_terms", ui_terms, envir = .GlobalEnv)
#           message("Created UI terminology dictionary with categories")
#         } else if (all(c("English", "en_US.UTF-8") %in% names(data)) ||
#                    any(grepl("^en_.*\\.UTF-8$", names(data), ignore.case = TRUE)) ||
#                    any(grepl("^zh_.*\\.UTF-8$", names(data), ignore.case = TRUE))) {
#           # Use simple key-value terminology dictionary format
#           available_columns <- names(data)
#           message(paste("Dictionary columns:", paste(available_columns, collapse = ", ")))
#           
#           language <- if (!is.null(app_config$brand$language)) app_config$brand$language else "en_US.UTF-8"
#           language_column <- NULL
#           english_column <- NULL
#           
#           # Find the language column that matches the configured language
#           for (col in available_columns) {
#             if (tolower(col) == tolower(language)) {
#               language_column <- col
#               message(paste("Direct language match found:", col))
#               break
#             }
#           }
#           
#           # If no direct match, try to match by language code
#           if (is.null(language_column)) {
#             lang_code <- sub("^([a-z]+)_.*$", "\\1", tolower(language))
#             message(paste("Trying to match by language code:", lang_code))
#             for (col in available_columns) {
#               col_lang_code <- sub("^([a-z]+)_.*$", "\\1", tolower(col))
#               if (col_lang_code == lang_code) {
#                 language_column <- col
#                 message(paste("Matched language by code:", lang_code, "->", col))
#                 break
#               }
#             }
#           }
#           
#           # Determine the source column (English)
#           if ("en_US.UTF-8" %in% available_columns) {
#             english_column <- "en_US.UTF-8"
#           } else if ("English" %in% available_columns) {
#             english_column <- "English"
#           } else {
#             english_column <- available_columns[1]
#           }
#           message(paste("Using", english_column, "as source column"))
#           
#           # Create the translation dictionary if we have a language column
#           if (!is.null(language_column)) {
#             ui_dictionary <- setNames(data[[language_column]], data[[english_column]])
#             ui_dictionary <- ui_dictionary[!is.na(names(ui_dictionary)) & !is.na(ui_dictionary)]
#             
#             if (VERBOSE_INITIALIZATION && length(ui_dictionary) > 0) {
#               sample_keys <- head(names(ui_dictionary), 3)
#               for (key in sample_keys) {
#                 message(paste("Sample translation:", key, "->", ui_dictionary[[key]]))
#               }
#             }
#             
#             assign("ui_dictionary", as.list(ui_dictionary), envir = .GlobalEnv)
#             
#             # Create translation function
#             translate <- function(text, default_lang = "English") {
#               if (is.null(text)) return(text)
#               if (length(text) > 1) {
#                 return(sapply(text, translate, default_lang = default_lang))
#               }
#               if (!exists("ui_dictionary") || !is.list(ui_dictionary) || length(ui_dictionary) == 0) {
#                 if (VERBOSE_INITIALIZATION) message(paste("Dictionary unavailable for translation of:", text))
#                 return(text)
#               }
#               tryCatch({
#                 result <- ui_dictionary[[text]]
#                 if (is.null(result)) {
#                   text_lower <- tolower(text)
#                   for (key in names(ui_dictionary)) {
#                     if (tolower(key) == text_lower) {
#                       result <- ui_dictionary[[key]]
#                       break
#                     }
#                   }
#                 }
#                 if (is.null(result)) {
#                   if (!exists("missing_translations")) {
#                     assign("missing_translations", character(0), envir = .GlobalEnv)
#                   }
#                   if (!(text %in% missing_translations)) {
#                     missing_translations <<- c(missing_translations, text)
#                     if (VERBOSE_INITIALIZATION) message(paste("Missing translation for:", text))
#                   }
#                   return(text)
#                 }
#                 return(result)
#               }, error = function(e) {
#                 message(paste("Error in translation:", e$message, "for text:", text))
#                 return(text)
#               })
#             }
#             
#             assign("translate", translate, envir = .GlobalEnv)
#             message(paste("Created translation function with", length(ui_dictionary), "terms"))
#             
#             # Check available locales
#             check_locale_availability <- function() {
#               tryCatch({
#                 system_locales <- system("locale -a", intern = TRUE)
#                 expected_locales <- c("en_US.UTF-8", "zh_TW.UTF-8")
#                 missing_locales <- expected_locales[!expected_locales %in% system_locales]
#                 if (length(missing_locales) > 0) {
#                   warning("Some configured locales are not available on the system: ", 
#                           paste(missing_locales, collapse = ", "))
#                 }
#                 available_locales <- expected_locales[expected_locales %in% system_locales]
#                 if (length(available_locales) == 0) {
#                   warning("None of the expected locales are available on the system.")
#                   if (VERBOSE_INITIALIZATION) {
#                     message("Available locales: ", paste(head(system_locales, 10), collapse = ", "),
#                             if (length(system_locales) > 10) "..." else "")
#                   }
#                 }
#                 return(available_locales)
#               }, error = function(e) {
#                 warning("Error checking locales: ", e$message)
#                 return(c("en_US.UTF-8", "zh_TW.UTF-8"))
#               })
#             }
#             
#             available_locales <- check_locale_availability()
#             assign("available_locales", available_locales, envir = .GlobalEnv)
#             message("Available locales: ", paste(available_locales, collapse = ", "))
#           }
#         }
#       } else {
#         # Generic dictionary creation for other parameter files
#         english_col <- grep("english$|en$", names(data), value = TRUE)[1]
#         lang_col <- grep(paste0(language, "$"), names(data), value = TRUE)[1]
#         id_col <- grep("^id$|_id$", names(data), value = TRUE)[1]
#         
#         if (!is.na(english_col) && !is.na(lang_col) && !is.na(id_col)) {
#           dict_name <- paste0(param_name, "_dictionary")
#           dict_value <- as.list(setNames(data[[id_col]], data[[lang_col]]))
#           assign(dict_name, dict_value, envir = .GlobalEnv)
#           
#           vec_name <- paste0(param_name, "_vec")
#           assign(vec_name, unlist(dict_value), envir = .GlobalEnv)
#           
#           message(paste("Created dictionary for parameter:", param_name))
#         }
#       }
#     }
#   }, error = function(e) {
#     message("Error loading parameter files: ", e$message)
#     message("Using YAML configuration only.")
#   })
# } else {
#   message("Error: Configuration loading function not found at: ", YAML_CONFIG_FUNCTION_PATH)
#   message("Application may not function correctly without configuration.")
#   
#   # Create minimal emergency config to prevent crashes
#   app_config <- list(
#     brand = list(name = "Default", language = "en_US.UTF-8"),
#     company = list(
#       marketing_channels = list(
#         "Default Channel" = "default"
#       ),
#       default_channel = "default"
#     )
#   )
#   config <- app_config
# }

# Source application-specific components following R56 (Folder-Based Sourcing)
message("Sourcing application-specific components...")

# Define folder-based sourcing function per R56
# This function sources all R files in a directory and its subdirectories
# that match a specific pattern, organized by aspect type
source_component_directory <- function(dir_path, pattern = "\\.R$", 
                                     recursive = TRUE, verbose = VERBOSE_INITIALIZATION) {
  # Ensure directory exists
  if (!dir.exists(dir_path)) {
    message("Component directory not found: ", dir_path, ". Will be created if needed.")
    return(invisible(FALSE))
  }
  
  # Get all matching files
  files <- list.files(
    path = dir_path,
    pattern = pattern,
    full.names = TRUE,
    recursive = recursive
  )
  
  # If no files found, return FALSE
  if (length(files) == 0) {
    if (verbose) message("No components matching '", pattern, "' found in ", dir_path)
    return(invisible(FALSE))
  }
  
  # Sort files to ensure consistent order
  files <- sort(files)
  
  # Source each file and track results
  success_count <- 0
  if (verbose) message("Found ", length(files), " components matching '", pattern, "' in ", dir_path)
  
  for (file in files) {
    if (!(file %in% loaded_files)) {
      success <- source_with_verbose(file, verbose)
      if (success) {
        loaded_files <<- c(loaded_files, file)
        success_count <- success_count + 1
      } else {
        failed_files <<- c(failed_files, file)
      }
    } else if (verbose) {
      message("Skipping already loaded: ", file)
    }
  }
  
  if (verbose) message("Successfully loaded ", success_count, " of ", length(files), " components")
  return(invisible(success_count > 0))
}

# Check if components directory exists and create it if needed
components_dir <- file.path(APP_DIR, "components")
if (!dir.exists(components_dir)) {
  message("Creating components directory: ", components_dir)
  dir.create(components_dir, recursive = TRUE)
}

# Source components by aspect type following P55 (N-tuple Independent Loading)
ui_count <- 0
server_count <- 0
filters_count <- 0
defaults_count <- 0

# Source the enhanced source_directory function with aspect_order parameter
source_with_verbose(file.path("update_scripts", "global_scripts", "00_principles", "fn_source_directory.R"))

# Use source_directory with aspect_order=TRUE if available
# 使用 tryCatch 來防止可能的類型轉換錯誤
tryCatch({
  if (exists("source_directory") && is.function(source_directory) && 
      "aspect_order" %in% names(formals(source_directory))) {
    
    message("Using enhanced aspect-ordered sourcing following P55 (N-tuple Independent Loading)")
    
    # 1. First load UI components
    ui_files <- source_directory(components_dir, pattern = "UI\\.R$", 
                                aspect_order = TRUE, 
                                verbose = isTRUE(VERBOSE_INITIALIZATION))
    ui_count <- length(ui_files)
    
    # 2. Then load Server components
    server_files <- source_directory(components_dir, pattern = "Server\\.R$", 
                                    aspect_order = TRUE, 
                                    verbose = isTRUE(VERBOSE_INITIALIZATION))
    server_count <- length(server_files)
    
    # 3. Then load Filters components
    filters_files <- source_directory(components_dir, pattern = "Filters\\.R$", 
                                     aspect_order = TRUE, 
                                     verbose = isTRUE(VERBOSE_INITIALIZATION))
    filters_count <- length(filters_files)
    
    # 4. Finally load Defaults components
    defaults_files <- source_directory(components_dir, pattern = "Defaults\\.R$", 
                                      aspect_order = TRUE, 
                                      verbose = isTRUE(VERBOSE_INITIALIZATION))
    defaults_count <- length(defaults_files)
  } else {
    message("Enhanced source_directory function not available, falling back to legacy loading")
    ui_count <- 0
    server_count <- 0
    filters_count <- 0
    defaults_count <- 0
  }
}, error = function(e) {
  message("Error in component sourcing: ", e$message)
  message("Falling back to legacy component loading")
  ui_count <- 0
  server_count <- 0
  filters_count <- 0
  defaults_count <- 0
})

# Fall back to legacy component sourcing if needed
if (ui_count == 0 && server_count == 0) {
  message("Using legacy component sourcing")
  
  # 1. First load UI components
  if (source_component_directory(components_dir, pattern = "UI\\.R$")) {
    ui_count <- length(grep("UI\\.R$", loaded_files))
  }
  
  # 2. Then load Server components
  if (source_component_directory(components_dir, pattern = "Server\\.R$")) {
    server_count <- length(grep("Server\\.R$", loaded_files))
  }
  
  # 3. Then load Filters components
  if (source_component_directory(components_dir, pattern = "Filters\\.R$")) {
    filters_count <- length(grep("Filters\\.R$", loaded_files))
  }
  
  # 4. Finally load Defaults components
  if (source_component_directory(components_dir, pattern = "Defaults\\.R$")) {
    defaults_count <- length(grep("Defaults\\.R$", loaded_files))
  }
}

message("Component sourcing completed: ", 
        ui_count, " UI, ", 
        server_count, " Server, ", 
        filters_count, " Filters, ",
        defaults_count, " Defaults components")

# =======================================================================
# App-specific initialization
# =======================================================================

# Print some diagnostic information
# message("Language setting from config: ", config$brand$language)
# if (exists("available_locales")) {
#   message("Available locales: ", paste(available_locales, collapse = ", "))
# }
# if (exists("ui_dictionary")) {
#   message("Translation dictionary loaded with ", length(ui_dictionary), " entries")
# } else {
#   message("Warning: No translation dictionary loaded")
# }
# 
# # Create fallback translation function if it doesn't exist (should never happen if initialization worked)
# if (!exists("translate")) {
#   translate <- function(text) { text }
#   message("Warning: Translation function not available, using default text")
# }
# 
# # Get channels from config parameters
# if (is.null(config) || !is.list(config) || is.null(config$parameters$platform)) {
#   stop("Configuration not loaded or missing required parameters. Cannot initialize marketing channels.")
# }
# 
# tryCatch({
#   # Check if platform data exists and has required columns
#   if (!is.data.frame(config$parameters$platform) || 
#       !"platform_name_english" %in% colnames(config$parameters$platform)) {
#     stop("Missing required platform configuration in config$parameters$platform")
#   }
#   
#   # Create a data frame with valid names only
#   platform_df <- config$parameters$platform
#   valid_rows <- which(nzchar(platform_df$platform_name_english))
#   
#   if (length(valid_rows) == 0) {
#     stop("No valid platform names found in configuration")
#   }
#   
#   # Extract valid names and create IDs
#   valid_names <- platform_df$platform_name_english[valid_rows]
#   valid_ids <- tolower(gsub(" ", "", valid_names))
#   
#   # Create a named vector
#   marketing_channels <- setNames(valid_ids, valid_names)
#   
#   message("Successfully configured ", length(marketing_channels), 
#           " marketing channels: ", paste(names(marketing_channels), collapse=", "))
# }, error = function(e) {
#   stop("Error creating marketing channels: ", e$message, 
#        "\nApplication cannot start without proper configuration.")
# })
# 
# # Get product categories from config parameters
# if (is.null(config) || !is.list(config) || is.null(config$parameters$product_line)) {
#   stop("Configuration not loaded or missing required parameters. Cannot initialize product categories.")
# }
# 
# tryCatch({
#   # Check if product line data exists and has required columns
#   if (!is.data.frame(config$parameters$product_line) || 
#       !"product_line_name_english" %in% colnames(config$parameters$product_line)) {
#     stop("Missing required product line configuration in config$parameters$product_line")
#   }
#   
#   # Create a data frame with valid names only
#   product_df <- config$parameters$product_line
#   valid_rows <- which(nzchar(product_df$product_line_name_english))
#   
#   if (length(valid_rows) == 0) {
#     stop("No valid product line names found in configuration")
#   }
#   
#   # Extract valid names and create IDs
#   valid_names <- product_df$product_line_name_english[valid_rows]
#   category_ids <- sprintf("%03d", 0:(length(valid_names)-1))
#   
#   # Create a named vector
#   product_categories <- setNames(category_ids, valid_names)
#   
#   message("Successfully configured ", length(product_categories), 
#           " product categories: ", paste(names(product_categories), collapse=", "))
# }, error = function(e) {
#   stop("Error creating product categories: ", e$message, 
#        "\nApplication cannot start without proper configuration.")
# })

## initialization of translate

translation_package$initialize_translation_system(
  language = "en",
  translation_dict = NULL
)

# 標記初始化完成
INITIALIZATION_COMPLETED <- TRUE

# 顯示載入統計
message(paste("APP_MODE initialization completed. Successfully loaded", 
             length(loaded_files), "files with recursive sourcing."))
message("NOTICE: Only stable public interfaces are loaded in APP_MODE.")

# 如果有失敗的文件，顯示這些文件
if (length(failed_files) > 0) {
  message(paste("WARNING:", length(failed_files), "files failed to load."))
  if (VERBOSE_INITIALIZATION) {
    message("Failed files:")
    for (file in failed_files) {
      message(paste(" -", file))
    }
  } else {
    message("Set VERBOSE_INITIALIZATION <- TRUE for detailed loading information.")
  }
}

# 設置 APP 模式特有的安全限制
# 防止後續腳本嘗試修改全局環境或加載不安全的庫
locked_environment <- TRUE
allow_file_write <- FALSE

# Verify initialization completed (MP31 verification step)
if (!exists("INITIALIZATION_COMPLETED") || !INITIALIZATION_COMPLETED) {
  stop("Initialization failed. Cannot proceed with application startup.")
}

# 顯示 APP 模式啟動完成的消息
message("APP_MODE is ready. Production environment initialized with enhanced recursive component loading.")
message("Component loading now follows R56 (Folder-Based Sourcing) and P55 (N-tuple Independent Loading).")

