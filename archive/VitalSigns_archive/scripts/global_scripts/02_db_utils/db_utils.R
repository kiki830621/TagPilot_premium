# Database Utilities Module
# This file sources individual database utility functions in accordance with 
# R21 (One Function One File) and R45 (Initialization Imports Only)

#' @title Database Utilities Module
#' @description Loads database utility functions following file naming conventions
#' @details Sources individual function files with fn_ prefix

# Get current directory - simpler method
# This will always work when running from source()
current_dir <- tryCatch({
  # First try using scriptPath
  script_path <- NULL
  if (exists("scriptPath")) {
    script_path <- scriptPath
  } else if (exists("ofile", sys.frame(1))) {
    script_path <- sys.frame(1)$ofile
  }
  
  if (!is.null(script_path) && script_path != "" && file.exists(script_path)) {
    message("Script path found: ", script_path)
    dirname(script_path)
  } else {
    stop("Script path not found, using fallback method")
  }
}, error = function(e) {
  # Fallback to a simple approach using current working directory
  current_wd <- getwd()
  
  # Find path to db_utils directory
  if (grepl("precision_marketing_app", current_wd)) {
    app_dir <- sub("(.*precision_marketing_app).*", "\\1", current_wd)
    file.path(app_dir, "update_scripts", "global_scripts", "02_db_utils")
  } else {
    # Hard-coded path as last resort
    message("Using manual directory resolution - this might not work everywhere")
    file.path(current_wd, "update_scripts", "global_scripts", "02_db_utils")
  }
})

# Verify the directory exists
if (!dir.exists(current_dir)) {
  message("Warning: Directory does not exist: ", current_dir)
  message("Current working directory: ", getwd())
  
  # Try to find the db_utils directory by scanning through paths
  potential_paths <- c(
    file.path(getwd(), "update_scripts", "global_scripts", "02_db_utils"),
    file.path(dirname(getwd()), "update_scripts", "global_scripts", "02_db_utils"),
    file.path(dirname(dirname(getwd())), "update_scripts", "global_scripts", "02_db_utils")
  )
  
  for (path in potential_paths) {
    if (dir.exists(path)) {
      message("Found alternative db_utils directory: ", path)
      current_dir <- path
      break
    }
  }
}

message("Using directory: ", current_dir)

# List of function files to source
function_files <- c(
  # Core database connection functions
  "fn_dbConnect_from_list.R",
  "fn_dbConnectTwoDatabases.R",
  "fn_dbAttachDatabase.R",
  "fn_dbDisconnect_all.R", 
  "fn_get_default_db_paths.R",
  "fn_set_db_paths.R",
  "fn_dbCopyTable.R",
  "fn_dbCopyorReadTemp.R", 
  "fn_dbDeletedb.R",
  "fn_dbOverwrite.R",
  
  # Enhanced data access functions (R116)
  "fn_tbl2.R",                   # Enhanced tbl function (R116)
  "fn_nrow2.R",                  # Safe nrow implementation (R116)
  "fn_universal_data_accessor.R" # Universal data access (R91, R114, R116)
)

# Source each file with enhanced error handling
for(file in function_files) {
  file_path <- file.path(current_dir, file)
  if(file.exists(file_path)) {
    tryCatch({
      source(file_path)
      message("Sourced: ", file)
      
      # Handle function name aliasing for backward compatibility
      # Strip 'fn_' prefix to create compatibility aliases
      if(grepl("^fn_", file)) {
        original_name <- sub("^fn_(.+)\\.R$", "\\1", file)
        function_name <- sub("^fn_(.+)\\.R$", "fn_\\1", file)
        
        # If the function exists with fn_ prefix but not without it
        if(exists(function_name, mode = "function") && !exists(original_name, mode = "function")) {
          # Create an alias for backward compatibility
          assign(original_name, get(function_name), envir = .GlobalEnv)
          message("Created alias: ", original_name, " -> ", function_name)
        }
      }
    }, error = function(e) {
      warning("Error sourcing ", file, ": ", e$message)
    })
  } else {
    message("File not found: ", file_path)
    
    # Try to locate the file in the application
    possible_locations <- c(
      file.path(current_dir, "functions", file),
      file.path(dirname(current_dir), "02_db_utils", file),
      file.path(dirname(current_dir), "02_db_utils", "functions", file)
    )
    
    for(alt_path in possible_locations) {
      if(file.exists(alt_path)) {
        message("Found at alternative location: ", alt_path)
        tryCatch({
          source(alt_path)
          message("Sourced from alternative location: ", alt_path)
          break
        }, error = function(e) {
          warning("Error sourcing from alternative location: ", e$message)
        })
      }
    }
  }
}

# Handle special case for dbConnect_from_list
if(!exists("fn_dbConnect_from_list", mode = "function") && exists("dbConnect_from_list", mode = "function")) {
  # Create fn_dbConnect_from_list as an alias to dbConnect_from_list for transition
  fn_dbConnect_from_list <- dbConnect_from_list
  message("Created fn_dbConnect_from_list as alias to existing dbConnect_from_list")
}

# Initialize database paths if needed
if(exists("fn_get_default_db_paths", mode = "function") && !exists("db_path_list")) {
  db_path_list <- fn_get_default_db_paths()
  message("Initialized db_path_list using fn_get_default_db_paths()")
} else if(exists("get_default_db_paths", mode = "function") && !exists("db_path_list")) {
  # Fallback to non-prefixed function if available
  db_path_list <- get_default_db_paths()
  message("Initialized db_path_list using get_default_db_paths()")
}

message("Database utilities module loaded")