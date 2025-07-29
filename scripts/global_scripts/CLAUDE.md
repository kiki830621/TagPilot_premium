# Claude Configuration and Guidelines

## README-First Policy

When working with this codebase, always check the relevant README files before making structural changes:

- Main README: `/update_scripts/global_scripts/README.md`
- Principles README: `/update_scripts/global_scripts/00_principles/README.md`

README files serve as the authoritative documentation for the project structure, principles organization, and coding standards.

## Code Revision Guidelines

When revising code in this project:

1. **Principle-Based Approach**: Every modification should follow at least one principle (MP/P/R)
2. **Documentation**: Explicitly state which principles each change follows
3. **Functional Programming**: Prefer functional approaches over imperative coding (MP47)
4. **Vectorization**: Use vectorized operations when working with data (MP30, R49, R50)
5. **File Organization**: Follow the one-function-one-file rule (R21) with proper naming (R69)

## Project Structure

The README files document:
- Directory organization
- File naming conventions
- Principles categorization (MP, P, R, M, S, D)
- Coding standards
- Module organization

## Working with Principles

When adding new principles:
1. Check the README first to identify the next available number for the appropriate type
2. Create the standalone principle file with proper naming
3. Update the principles README.md to include the new principle in the appropriate section
4. Add an entry in the "Recent Updates" section

## Recent Important Principles

1. **MP49**: Docker-Based Deployment
2. **MP50**: Debug Code Tracing
3. **MP51**: Test Data Design
4. **R75**: Test Script Initialization
5. **R76**: Module Data Connection
6. **R77**: Supplemental Description Notation
7. **SLN04**: Shiny Namespace Collision Resolution

## Functor-Module Correspondence (MP44)

Follow the Functor-Module Correspondence Principle (MP44) when implementing new functionality:

1. Identify the command functor (verb-object pair)
2. Create a module in the format: `M{number}_{verb}ing_{object}`
3. Structure the module with:
   - `{verb}_{object}.R` - Main implementation
   - `sc_{verb}_{object}.R` - Execution script
   - `{verb}_{object}_utils.R` - Utility functions
   - `README.md` - Documentation

Example: The "summarize database" command is implemented in `M01_summarizing_database`.

## UI-Server-Defaults Triple (R09)

Shiny components must follow the UI-Server-Defaults triple rule:

1. Each component must have:
   - UI component in a file named with the component function (e.g., `componentNameUI.R`)
   - Server component in a file named with the component function (e.g., `componentNameServer.R`)
   - Defaults component in a file named with the component function (e.g., `componentNameDefaults.R`)

2. Preferred folder-based organization:
   ```
   componentName/
   ├── componentNameUI.R
   ├── componentNameServer.R
   └── componentNameDefaults.R
   ```

## Key Principles to Follow

1. `R21`: One Function One File
2. `R45`: Initialization Imports Only
3. `R46`: Source Directories Not Individual Files
4. `R49`: Apply Functions Over For Loops
5. `R50`: data.table Vectorized Operations
6. `R67`: Functional Encapsulation
7. `R68`: Object Initialization
8. `R69`: Function File Naming
9. `R70`: N-Tuple Delimiter
10. `R72`: Component ID Consistency
11. `R76`: Module Data Connection
12. `R91`: Universal Data Access Pattern
13. `R92`: Universal DBI Approach
14. `MP28`: Avoid Self-Reference
15. `MP29`: No Fake Data
16. `MP30`: Vectorization Principle
17. `MP44`: Functor-Module Correspondence
18. `MP47`: Functional Programming
19. `MP48`: Universal Initialization
20. `MP52`: Unidirectional Data Flow

## Initialization Path

Always use the correct path for initialization:
```r
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_update_mode.R"))
```

Application mode initialization:
```r
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_app_mode.R"))
```

Global mode initialization:
```r
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_global_mode.R"))
```

Do not use deprecated paths:
```r
# DEPRECATED - Do not use
# source(file.path("update_scripts", "global_scripts", "000g_initialization_update_mode.R"))
```

## Testing

Set up proper test scripts following R75 (Test Script Initialization):

```r
# In your test script
options(shiny.launch.browser = TRUE)

# Initialize directory
current_dir <- getwd()
setwd(file.path(current_dir, "precision_marketing_app"))

# Initialize test environment
source(file.path("update_scripts", "global_scripts", "00_principles", "sc_initialization_app_mode.R"))

# Create test data following MP51
test_data <- create_test_data()

# Create and run test app
app <- create_test_app(test_data)
runApp(app, port = 8765) # Don't use launch.browser=TRUE here
```

## Common Mistakes to Avoid

1. Creating redundant index files (use README.md as the primary index)
2. Modifying initialization files directly (use utility files per R45)
3. Manually listing source files instead of sourcing directories (per R46)
4. Creating self-referential code structures (per MP28)
5. Generating fake data in production (per MP29)
6. Using loops instead of vectorized operations (per MP30, R49, R50)
7. Placing related functionality in separate modules (per MP44)
8. Using imperative programming when functional would be cleaner (per MP47)
9. Not properly initializing variables before use (per MP48 and R68)
10. Omitting the "fn_" prefix from function filenames (per R69)
11. Using inconsistent IDs across component parts (per R72)
12. Not separating UI-server-defaults components with delimiters (per R70)
13. Passing pre-filtered data to modules instead of connections (per R76)

## Functionalizing Code

Use the M48_functionalizing module to convert procedural code blocks to proper functions:

```r
source("update_scripts/global_scripts/00_principles/M48_functionalizing/M48_fn_functionalize.R")

# Convert a code block to a function
result <- functionalize(
  code_block = "# Your code here...",
  target_directory = "update_scripts/global_scripts/04_utils",
  function_name = "my_function"
)

# Use the convenient wrapper
run_functionalization(
  code_block = "# Your code here...",
  target_directory = "update_scripts/global_scripts/04_utils"
)
```

**Important scope considerations:**
- Use `<-` for local variables (function scope only)
- Use `<<-` for global variables (when modifying global state)
- Document global variables clearly in function documentation

## Temporary Code Management (MP37)

Follow MP37 (Comment Only for Temporary or Uncertain) when temporarily disabling code:

```r
# TEMP-DISABLED (2025-04-09): Authentication not working with new backend
# Will be fixed when backend team addresses issue #123 (expected by 2025-04-15)
# validate_auth(data)
```

Always include:
1. Standard prefix (TEMP-DISABLED, UNCERTAIN, EXPERIMENTAL, etc.)
2. Date when commented (YYYY-MM-DD)
3. Reason for commenting out
4. Expected resolution date or condition

## 🔄 AI Workflows Index

### WF001: Deployment Quickstart
- **Location**: `23_deployment/06_workflows/WF001_deployment_quickstart.md`
- **Purpose**: Quick deployment process for positioning app
- **Prerequisites**: App config ready, environment variables set

### WF002: Complete Deployment Workflow
- **Location**: `23_deployment/06_workflows/WF002_deployment_complete.md`
- **Purpose**: Full deployment workflow with all checks and documentation
- **Prerequisites**: Clean git status, all tests passing

When asked to deploy applications, refer to these WF-numbered workflow files for step-by-step guidance.

### Workflow Usage Pattern

1. User asks: "understand `/path/to/global_scripts/`"
2. AI reads this CLAUDE.md and discovers workflow locations
3. AI navigates to specific workflows based on task requirements
4. AI follows the structured workflows for consistent execution
