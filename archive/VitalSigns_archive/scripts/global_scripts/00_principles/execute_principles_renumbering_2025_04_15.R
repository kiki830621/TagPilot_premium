#' Execute Principles Renumbering Plan - April 15, 2025
#'
#' @description
#' This script implements the renumbering plan for meta principles as outlined in
#' records/2025_04_15_principles_renumbering_plan.md
#'
#' @author Claude
#' @date 2025-04-15

# Set working directory to the 00_principles directory
principles_dir <- "/Users/che/Library/CloudStorage/Dropbox/precision_marketing/precision_marketing_WISER/precision_marketing_app/update_scripts/global_scripts/00_principles"
setwd(principles_dir)

# Load the renumbering module
source("M00_renumbering_principles/M00_fn_renumber_principles.R")

# Create backup directory if it doesn't exist
backup_dir <- "renumbering_backup"
if (!dir.exists(backup_dir)) {
  dir.create(backup_dir)
}

# Backup the entire directory before starting
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
backup_cmd <- paste0("cp -r * ", backup_dir, "/backup_", timestamp)
system(backup_cmd)
cat("Created backup in:", paste0(backup_dir, "/backup_", timestamp), "\n")

# Define mapping table for meta principles as defined in the plan
cat("Loading renumbering mapping...\n")
mapping_table <- data.frame(
  old_id = c(
    "MP100", "MP107", "MP107", 
    "MP27", 
    "MP28", "MP28", 
    "MP40", 
    "MP41", 
    "MP99"
  ),
  new_id = c(
    "MP59", "MP60", "MP61", 
    "MP62", 
    "MP63", "MP64", 
    "MP65", 
    "MP66", 
    "MP67"
  ),
  name = c(
    "app_dynamics", "parsimony", "root_cause_resolution", 
    "specialized_natural_sql_language_v2", 
    "graph_theory_in_nsql", "nsql_set_theory_foundations", 
    "time_allocation_decomposition", 
    "type_dependent_operations", 
    "ui_separation"
  ),
  stringsAsFactors = FALSE
)
print(mapping_table)

cat("\nStarting meta principle renumbering...\n")

# Execute meta principle renumbering
mp_results <- M00_renumbering_principles$batch_renumber(mapping_table)

if (!is.null(mp_results$success) && !mp_results$success) {
  cat("Error in meta principle renumbering:\n")
  print(mp_results$error)
  if (!is.null(mp_results$details)) {
    print(mp_results$details)
  }
  cat("Renumbering aborted. Check the error messages.\n")
  quit(status = 1)
}

cat("Meta principle renumbering completed successfully.\n")
if (!is.null(mp_results$operations)) {
  cat("Operations performed:", mp_results$operations, "\n")
}

cat("\nVerifying system consistency...\n")

# Verify system consistency
issues <- M00_renumbering_principles$verify()
if (is.null(issues)) {
  cat("System is consistent!\n")
} else {
  cat("Issues found in system consistency check:\n")
  print(issues)
  cat("Consider addressing these issues manually.\n")
}

cat("\nRenumbering plan execution completed.\n")
cat("Additional manual steps may be needed to update references in code or other documents.\n")
cat("\nResults:\n")
system("ls -la MP*.md | sort")