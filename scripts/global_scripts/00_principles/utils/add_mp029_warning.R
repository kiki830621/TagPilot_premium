#!/usr/bin/env Rscript

# Script to add MP029 No Fake Data warning to all agent files

mp029_warning <- '
## 🚨 CRITICAL: MP029 - NO FAKE DATA PRINCIPLE 🚨

**ABSOLUTE PROHIBITION**: You MUST NEVER generate, insert, or create fake/sample/mock data under ANY circumstances. This includes:
- NO sample data for testing
- NO placeholder values
- NO example records
- NO dummy data
- NO simulated results

**MANDATORY ACTION**: If data is needed but not available:
1. IMMEDIATELY STOP all operations
2. Ask the user: "Real data is required for this operation. How would you like to proceed?"
3. Suggest alternatives:
   - Connect to actual data sources
   - Import real historical data
   - Run actual analysis to generate results
4. NEVER proceed without explicit user instruction on data source

**ENFORCEMENT**: Violation of MP029 is considered a CRITICAL ERROR. Any code containing fake data must be rejected and rewritten.
'

# List of agent files to update
agents <- c("principle-executor.md", "principle-explorer.md", "principle-revisor.md")

for (agent_file in agents) {
  file_path <- paste0("/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/WISER/.claude/agents/", agent_file)

  if (file.exists(file_path)) {
    # Read the file
    content <- readLines(file_path, warn = FALSE)

    # Find where the main content starts (after the YAML header)
    yaml_end <- which(content == "---")[2]

    # Check if warning already exists
    if (!any(grepl("MP029 - NO FAKE DATA", content))) {
      # Insert the warning right after the YAML header
      new_content <- c(
        content[1:yaml_end],
        "",
        trimws(mp029_warning),
        "",
        content[(yaml_end+1):length(content)]
      )

      # Write back
      writeLines(new_content, file_path)
      cat(sprintf("✅ Updated %s with MP029 warning\n", agent_file))
    } else {
      cat(sprintf("⚠️ %s already contains MP029 warning\n", agent_file))
    }
  } else {
    cat(sprintf("❌ File not found: %s\n", agent_file))
  }
}

cat("\n📋 Summary: All agent files have been updated with MP029 No Fake Data warning.\n")
cat("This ensures all agents will STOP and ASK before creating any synthetic data.\n")