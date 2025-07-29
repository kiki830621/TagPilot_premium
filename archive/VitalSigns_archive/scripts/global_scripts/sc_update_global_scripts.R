#' @file sc_update_global_scripts.R
#' @principle MP14 Change Tracking Principle
#' @principle R08 Global Scripts Synchronization Rule
#' @author Claude
#' @date 2025-04-14
#' @description Script to update and synchronize global scripts across all projects

# Check if we're in UPDATE_MODE
if (!exists("OPERATION_MODE") || OPERATION_MODE != "UPDATE_MODE") {
  warning("This script should be run in UPDATE_MODE. Setting mode now.")
  OPERATION_MODE <- "UPDATE_MODE"
  
  # Source initialization script if not already initialized
  if (!exists("INITIALIZATION_COMPLETED") || !INITIALIZATION_COMPLETED) {
    tryCatch({
      source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_update_mode.R"))
    }, error = function(e) {
      stop("Failed to initialize UPDATE_MODE: ", e$message)
    })
  }
}

# Make sure we have the required function
if (!exists("update_global_scripts") || !is.function(update_global_scripts)) {
  tryCatch({
    source(file.path("update_scripts", "global_scripts", "fn_update_global_scripts.R"))
  }, error = function(e) {
    stop("Failed to load update_global_scripts function: ", e$message)
  })
}

# Parse command line arguments if running in Rscript
auto_commit <- FALSE
verbose <- TRUE
create_missing <- FALSE

if (!interactive()) {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) > 0) {
    for (arg in args) {
      if (arg == "--auto-commit" || arg == "-a") {
        auto_commit <- TRUE
      } else if (arg == "--quiet" || arg == "-q") {
        verbose <- FALSE
      } else if (arg == "--create-missing" || arg == "-c") {
        create_missing <- TRUE
      } else if (arg == "--help" || arg == "-h") {
        cat("Usage: Rscript sc_update_global_scripts.R [options]\n")
        cat("\n")
        cat("Options:\n")
        cat("  --auto-commit, -a    Automatically commit any uncommitted changes\n")
        cat("  --quiet, -q          Suppress verbose output\n")
        cat("  --create-missing, -c Create missing global_scripts directories\n")
        cat("  --help, -h           Display this help message\n")
        cat("\n")
        cat("This script synchronizes all instances of global_scripts across company projects.\n")
        cat("It pulls the latest changes from the remote repository and ensures all instances\n")
        cat("are at the same version, following the Global Scripts Synchronization Rule (R08).\n")
        quit(status = 0)
      }
    }
  }
}

# Print header
cat("===============================================\n")
cat("Global Scripts Synchronization Tool\n")
cat("===============================================\n")
cat("Starting synchronization process...\n")
cat("\n")

# Run the update function
results <- update_global_scripts(
  auto_commit = auto_commit, 
  verbose = verbose, 
  create_missing = create_missing
)

# Summary
cat("\n")
cat("===============================================\n")
cat("Synchronization Summary\n")
cat("===============================================\n")

for (company in names(results)) {
  result <- results[[company]]
  if (is.list(result) && "status" %in% names(result)) {
    status <- result$status
    status_symbol <- switch(status,
                          "success" = "✅",
                          "error" = "❌",
                          "warning" = "⚠️",
                          "skipped" = "⏭️",
                          "❓")
    cat(status_symbol, " ", company, ": ", result$message, "\n", sep = "")
  } else {
    # Process complex results with multiple operations
    cat("🔄 ", company, ":\n", sep = "")
    
    for (operation in names(result)) {
      op_result <- result[[operation]]
      if (is.list(op_result) && "status" %in% names(op_result)) {
        status_symbol <- switch(op_result$status,
                              "success" = "✅",
                              "error" = "❌",
                              "warning" = "⚠️",
                              "skipped" = "⏭️",
                              "❓")
        cat("  ", status_symbol, " ", operation, ": ", 
            if(is.character(op_result$message) && length(op_result$message) == 1) op_result$message else "Completed", 
            "\n", sep = "")
      }
    }
  }
}

cat("\n")
cat("Synchronization completed.\n")

# Return results invisibly if in interactive mode
if (interactive()) {
  invisible(results)
}