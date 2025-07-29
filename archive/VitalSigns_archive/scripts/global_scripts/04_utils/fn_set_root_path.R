# Set Root Path for Precision Marketing Projects
# This script sets up the appropriate root paths for all scripts

# Source the root path configuration
# Try to find and source the fn_root_path_config.R file from a known location
root_config_paths <- c(
  file.path("update_scripts", "global_scripts", "00_principles", "fn_root_path_config.R"),
  file.path("update_scripts", "global_scripts", "03_config", "fn_root_path_config.R")
)

# Try each potential path
config_found <- FALSE
for (config_path in root_config_paths) {
  if (file.exists(config_path)) {
    source(config_path)
    config_found <- TRUE
    message("Successfully loaded root path config from: ", config_path)
    break
  }
}

# If config not found, try a relative path as fallback
if (!config_found) {
  # Get the current script directory 
  # (this is more reliable than sys.frame(1)$ofile which doesn't work when sourced)
  current_script_dir <- getwd()
  possible_paths <- c(
    file.path(current_script_dir, "..", "03_config", "fn_root_path_config.R"),
    file.path(current_script_dir, "..", "00_principles", "fn_root_path_config.R")
  )
  
  for (path in possible_paths) {
    if (file.exists(path)) {
      source(path)
      config_found <- TRUE
      message("Found root path config using relative path: ", path)
      break
    }
  }
}

# If still not found, notify the user
if (!config_found) {
  stop("Could not find fn_root_path_config.R. Please ensure the file exists in one of the expected locations.")
}

# Function to set up all paths needed for the project
setup_project_paths <- function(company_name) {
  # Get the company path
  company_path <- get_company_path(company_name)
  
  # Define all the standard paths
  paths <- list(
    root_path = ROOT_PATH,
    company_path = company_path,
    app_path = file.path(company_path, "precision_marketing_app"),
    data_path = file.path(company_path, "precision_marketing_app", "data"),
    scripts_path = file.path(company_path, "precision_marketing_app", "update_scripts"),
    global_scripts_path = file.path(company_path, "precision_marketing_app", "update_scripts", "global_scripts")
  )
  
  # Create a function to check and create directories if they don't exist
  check_and_create_dir <- function(path) {
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE)
      message("Created directory: ", path)
    }
    return(path)
  }
  
  # Check and create all directories
  lapply(paths, check_and_create_dir)
  
  # Return all paths
  return(paths)
}

# Usage example:
# paths <- setup_project_paths("WISER")
# data_dir <- paths$data_path