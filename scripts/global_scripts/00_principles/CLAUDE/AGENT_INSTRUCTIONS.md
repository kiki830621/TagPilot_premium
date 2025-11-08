# Agent Instructions: Principles-First Development

## Core Directive

**YOU ARE A PRINCIPLES-DRIVEN AGENT**

Your primary knowledge base and decision authority comes from:
```
/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles
```

## Operating Protocol

### Step 1: Always Start Here
```bash
cd /Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles
```

### Step 2: For Every Request
1. Search for relevant principles
2. Load principle documentation
3. Apply principle patterns
4. Validate compliance

### Step 3: Response Format
```markdown
📚 **Applying Principles:**
- [Principle ID]: [Principle Name]
- Location: [file path in 00_principles]

💻 **Implementation:**
[solution following principles]

✅ **Compliance Check:**
- [x] Follows [Principle ID]
- [x] Validated against [Principle ID]
```

## Quick Reference Paths

```python
PRINCIPLES_BASE = "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles"

# Key directories
ENGLISH_DOCS = f"{PRINCIPLES_BASE}/natural/en"
CHINESE_DOCS = f"{PRINCIPLES_BASE}/natural/zh"
TEMPLATES = f"{PRINCIPLES_BASE}/natural/en/part2_implementations/CH10_templates_examples"
CHANGELOG = f"{PRINCIPLES_BASE}/CHANGELOG"
REFERENCES = f"{PRINCIPLES_BASE}/REFERENCES"
```

## Principle Loading Function

```r
load_principle <- function(principle_id) {
  base_path <- "/Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts/00_principles"
  
  # Search in natural/en
  principle_file <- list.files(
    file.path(base_path, "natural/en"),
    pattern = paste0(principle_id, ".*\\.qmd$"),
    recursive = TRUE,
    full.names = TRUE
  )[1]
  
  if (!is.na(principle_file)) {
    return(readLines(principle_file))
  }
  
  stop("Principle ", principle_id, " not found in 00_principles")
}
```

## Mandatory Validations

### Before Creating Functions
```r
validate_function_principles <- function() {
  check_principle("R021")  # One function one file
  check_principle("R069")  # Function naming
  check_principle("R067")  # Functional encapsulation
}
```

### Before Database Operations
```r
validate_database_principles <- function() {
  check_principle("R116")  # tbl2 enhanced access
  check_principle("R092")  # Universal DBI
}
```

### Before UI Components
```r
validate_ui_principles <- function() {
  check_principle("R009")  # UI-Server-Defaults
  check_principle("R072")  # Component ID consistency
}
```

## Agent Memory

Remember these critical principles:
- **MP018**: Don't Repeat Yourself
- **MP031**: Initialization First
- **MP047**: Functional Programming
- **R021**: One Function One File
- **R116**: Use tbl2() not tbl()
- **D01**: DNA Analysis Flow

## Enforcement Level

**STRICT** - No code generation without principle validation

---

*This agent configuration ensures all development follows the established principles in 00_principles*