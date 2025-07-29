#!/usr/bin/env Rscript

#' Generate Index for Principles
#' 
#' This script generates INDEX.md from TAGS.yaml and principles files
#' 
#' @author Claude
#' @date 2025-06-28

library(yaml)
library(stringr)
library(dplyr)

# Get script directory
script_dir <- tryCatch({
  dirname(sys.frame(1)$ofile)
}, error = function(e) {
  if (interactive()) {
    dirname(rstudioapi::getActiveDocumentContext()$path)
  } else {
    getwd()
  }
})

principles_root <- normalizePath(file.path(script_dir, ".."))

# Load configuration files
tags_file <- file.path(principles_root, "TAGS.yaml")
relationships_file <- file.path(principles_root, "RELATIONSHIPS.yaml")
principles_dir <- file.path(principles_root, "principles")
index_file <- file.path(principles_root, "INDEX.md")

# Load tags
if (file.exists(tags_file)) {
  tags_config <- read_yaml(tags_file)
} else {
  stop("TAGS.yaml not found!")
}

# Load relationships
if (file.exists(relationships_file)) {
  relationships <- read_yaml(relationships_file)
} else {
  relationships <- list()
}

# Get all principle files
principle_files <- list.files(principles_dir, pattern = "^[MPR][0-9].*\\.md$", full.names = FALSE)

# Parse principle metadata
parse_principle <- function(filename) {
  filepath <- file.path(principles_dir, filename)
  if (!file.exists(filepath)) return(NULL)
  
  lines <- readLines(filepath, n = 20)
  
  # Extract metadata
  id <- str_extract(filename, "^[MPR][0-9]+")
  
  # Find title
  title_line <- grep("^title:", lines, value = TRUE)[1]
  title <- if (!is.na(title_line)) {
    gsub('^title:\\s*"?|"?$', '', title_line)
  } else {
    gsub("_", " ", str_remove(filename, "\\.md$"))
  }
  
  # Determine type
  type <- case_when(
    str_starts(id, "MP") ~ "Meta-Principle",
    str_starts(id, "P0") ~ "Principle",
    str_starts(id, "R") ~ "Rule",
    TRUE ~ "Unknown"
  )
  
  list(
    id = id,
    filename = filename,
    title = title,
    type = type,
    path = file.path("principles", filename)
  )
}

# Parse all principles
principles <- lapply(principle_files, parse_principle)
principles <- Filter(Negate(is.null), principles)

# Group by type
principles_by_type <- split(principles, sapply(principles, `[[`, "type"))

# Generate index content
generate_index <- function() {
  lines <- character()
  
  # Header
  lines <- c(lines, 
    "# Principles Index",
    "",
    paste("Generated:", Sys.Date()),
    paste("Total Principles:", length(principles)),
    "",
    "## Quick Links",
    "- [By Type](#by-type)",
    "- [By Topic](#by-topic)",
    "- [Search Tips](#search-tips)",
    ""
  )
  
  # By Type section
  lines <- c(lines, "## By Type", "")
  
  for (type_name in c("Meta-Principle", "Principle", "Rule")) {
    if (type_name %in% names(principles_by_type)) {
      type_principles <- principles_by_type[[type_name]]
      
      # Add type header
      lines <- c(lines, paste("###", paste0(type_name, "s"), paste0("(", length(type_principles), ")")), "")
      
      # Sort by ID
      type_principles <- type_principles[order(sapply(type_principles, `[[`, "id"))]
      
      # Add entries
      for (p in type_principles) {
        entry <- sprintf("- [%s - %s](%s)", p$id, p$title, p$path)
        lines <- c(lines, entry)
      }
      lines <- c(lines, "")
    }
  }
  
  # By Topic section
  lines <- c(lines, "## By Topic", "")
  
  for (tag_name in names(tags_config$tags)) {
    tag_info <- tags_config$tags[[tag_name]]
    
    lines <- c(lines, 
      paste("###", str_to_title(gsub("_", " ", tag_name))),
      paste0("*", tag_info$description, "*"),
      ""
    )
    
    # Find principles for this tag
    tag_principles <- tag_info$principles
    if (!is.null(tag_principles)) {
      for (p_ref in tag_principles) {
        # Find matching principle
        matching <- Filter(function(p) str_starts(p$filename, p_ref), principles)
        if (length(matching) > 0) {
          p <- matching[[1]]
          entry <- sprintf("- [%s - %s](%s)", p$id, p$title, p$path)
          lines <- c(lines, entry)
        }
      }
    }
    lines <- c(lines, "")
  }
  
  # Search Tips section
  lines <- c(lines,
    "## Search Tips",
    "",
    "### Finding Principles",
    "```bash",
    "# Search by ID",
    "grep -l 'R0092' principles/*.md",
    "",
    "# Search by topic", 
    "grep -l 'database' principles/*.md",
    "",
    "# Find related principles",
    "grep -l 'related_to:.*R0092' principles/*.md",
    "```",
    "",
    "### Using Tags",
    "```r",
    "# Load tags",
    "tags <- yaml::read_yaml('TAGS.yaml')",
    "",
    "# Get all database principles",
    "tags$tags$database$principles",
    "```",
    "",
    "### Quick Navigation",
    "- Use Ctrl+F (Cmd+F on Mac) to search this page",
    "- Click on any principle link to view details",
    "- Check RELATIONSHIPS.yaml for principle connections"
  )
  
  return(lines)
}

# Generate and write index
index_content <- generate_index()
writeLines(index_content, index_file)

cat("✅ INDEX.md generated successfully!\n")
cat(sprintf("   Total principles indexed: %d\n", length(principles)))
cat(sprintf("   Tags used: %d\n", length(tags_config$tags))) 