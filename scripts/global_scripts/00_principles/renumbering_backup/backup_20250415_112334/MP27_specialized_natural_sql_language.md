---
id: "MP27"
title: "Specialized Natural SQL Language (SNSQL) Meta-Principle"
type: "meta-principle"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "MP24": "Natural SQL Language"
  - "MP25": "AI Communication Meta-Language"
influences:
  - "R28": "Archiving Standard"
  - "R10": "Package Consistency Naming"
---

# Specialized Natural SQL Language (SNSQL) Meta-Principle

## Core Principle

Specialized Natural SQL Language (SNSQL) extends the Natural SQL Language (NSQL) with project-specific commands, domain operations, and idiomatic workflows that enable contextual interactions with the system. SNSQL provides intuitive, English-like syntax for project-specific operations that would otherwise require multiple technical steps.

## Conceptual Framework

SNSQL builds on the foundation of NSQL (MP24) by adding specialized vocabulary and operations that:

1. **Encapsulate Project Idioms**: Express project-specific conventions and patterns through simple commands
2. **Standardize Technical Workflows**: Create consistent language for common development tasks
3. **Embed Institutional Knowledge**: Capture team practices and conventions in executable form
4. **Bridge Technical Domains**: Connect disparate systems through unified command language

This meta-principle recognizes that projects develop their own "idioms" - specialized patterns and conventions that, while specific to the project context, benefit from standardized expression.

## Project-Specific Idioms

### 1. Source Control Idioms

SNSQL expresses project-specific source control patterns:

```
archive file "/path/to/file.R" to "global_scripts/99_archive" with message "Deprecated due to function consolidation"
```

This translates to multiple technical steps following project conventions:
1. Create the archive directory if needed
2. Copy the file to the archive location
3. Add deprecation notice to the file
4. Create a backward compatibility shim
5. Commit the changes with the specified message

### 2. Code Organization Idioms

SNSQL provides commands for project-specific code organization patterns:

```
consolidate function "readYamlConfig" into "load_app_config" with backward compatibility
```

This encapsulates the entire function consolidation workflow according to project standards, including:
1. Identifying redundant functionality
2. Creating archive copies following naming conventions
3. Implementing shim wrappers with proper deprecation notices
4. Updating documentation according to project templates
5. Maintaining backward compatibility per project requirements

### 3. Script Naming Idioms

SNSQL formalizes project-specific script naming conventions:

```
create update script "import_transaction_data" for "global_scripts/01_db" following numbered prefix convention
```

This produces standardized script names following project conventions:
1. Applies the correct numbered prefix (e.g., "301g_")
2. Uses the standardized function prefix (e.g., "fn_")
3. Follows capitalization and separator conventions
4. Places the file in the appropriate directory structure
5. Creates a template with standard header sections

Similarly, for module-specific scripts:

```
create module script "customer_profile_analysis" in "M15_customer_analytics" with UI, Server, and Defaults files
```

This generates a complete set of files following project naming conventions:
1. Creates UI file with proper prefix ("ui_" or "UI" suffix)
2. Creates Server file with proper prefix ("server_" or "Server" suffix)
3. Creates Defaults file with proper prefix ("defaults_" or "Defaults" suffix)
4. Adds standard header and template content to each file
5. Updates module mapping if necessary

### 4. Development Workflow Idioms

SNSQL includes commands for development workflow patterns specific to the project:

```
add translation support for locale "fr_FR.UTF-8" to terminology dictionary
```

This would implement all the necessary changes to support a new locale, following established project patterns for internationalization.

## Implementation Guidelines

### 1. SNSQL Command Structure

All SNSQL commands should follow a consistent structure:

```
<action verb> <target> [<preposition> <parameter>]* [<conjunction> <modifier>]*
```

Examples:
- `archive file "/path/to/file.R" to "destination" with message "reason"`
- `consolidate function "name" into "target" with backward compatibility`
- `add locale "en_US.UTF-8" to terminology dictionary`

### 2. Project Context Sensitivity

SNSQL commands are inherently project-specific and should:

1. **Follow Project Conventions**: Implement operations according to established project patterns
2. **Use Project Vocabulary**: Employ terms that are meaningful within the project context
3. **Respect Project Structure**: Operate within the project's organization and architecture
4. **Implement Project Principles**: Automatically follow relevant project principles
5. **Address Project Needs**: Focus on operations that are valuable in the project context

### 3. Command Documentation

Each SNSQL command should be documented with:

1. **Syntax**: Formal definition of the command structure
2. **Purpose**: What the command accomplishes in project context
3. **Steps**: Technical steps it encapsulates
4. **Project Context**: How the command relates to project conventions
5. **Examples**: Clear usage examples specific to the project

## Integration with NSQL

SNSQL integrates with the base NSQL language through:

### 1. Extension Mechanism

SNSQL commands are defined as extensions to the core NSQL grammar:

```ebnf
snsql_command ::= archiving_command | consolidation_command | translation_command | ...
archiving_command ::= "archive" target "to" destination ["with" message]
```

### 2. Project-Specific Vocabulary

SNSQL adds project-specific vocabulary to the NSQL dictionary:

| Word Class | Examples | Usage |
|------------|----------|-------|
| Action Verbs | archive, consolidate, migrate, derive, import, cleanse, standardize, transform, analyze, copy | Primary command actions |
| Technical Nouns | function, file, module, locale, derivation, data.frame, dna | Command targets |
| Project Terms | backward compatibility, deprecation, external_raw_data, processed_data | Command modifiers |

### 3. Context-Sensitive Grammar

SNSQL commands are context-sensitive, meaning their interpretation depends on:

1. **Project Scope**: Commands relevant to the specific project
2. **System State**: Available operations based on current state
3. **User Role**: Commands available to different user types
4. **Operation Mode**: Different modes (development, production) enable different commands

## Benefits

1. **Knowledge Encapsulation**: Captures project-specific knowledge in accessible commands
2. **Consistency**: Ensures operations follow established project standards
3. **Efficiency**: Reduces multi-step technical processes to simple commands
4. **Onboarding**: Simplifies learning curve for project-specific operations
5. **Self-Documentation**: Expresses project conventions through clear language
6. **Quality Assurance**: Built-in adherence to project principles and best practices

## Limitations and Considerations

### 1. Project Specificity

SNSQL commands are inherently limited to specific project contexts:

1. **Limited Transferability**: Commands may not apply across different projects
2. **Context Dependence**: Proper interpretation requires project knowledge
3. **Maintenance Burden**: Project-specific commands require ongoing maintenance
4. **Learning Curve**: New team members must learn project-specific language

### 2. Evolution Management

As project idioms evolve:

1. **Command Versioning**: Maintain backward compatibility for commands
2. **Deprecation Process**: Follow a structured process for retiring commands
3. **Documentation Updates**: Keep command documentation synchronized with implementations
4. **Extension Mechanism**: Provide a clear process for adding new commands

### 3. Implementation Complexity

While SNSQL presents simple interfaces, implementations may be complex:

1. **Technical Debt**: Avoid accumulating hidden complexity in command implementations
2. **Testing Strategy**: Develop comprehensive testing for command functionality
3. **Error Handling**: Provide clear, helpful error messages for command failures
4. **Performance Considerations**: Optimize command execution for common cases

## Examples

### Example 1: Archiving a Deprecated Function Following Project Conventions

```
# SNSQL command
archive function "readYamlConfig" in "11_rshinyapp_utils" to "99_archive/11_rshinyapp_utils_archive" with message "Consolidated with load_app_config" and create shim

# Equivalent technical steps following project conventions
mkdir -p global_scripts/99_archive/11_rshinyapp_utils_archive
cp global_scripts/11_rshinyapp_utils/fn_read_yaml_config.R global_scripts/99_archive/11_rshinyapp_utils_archive/
echo "# DEPRECATED: This function has been archived..." > global_scripts/11_rshinyapp_utils/fn_read_yaml_config.R
# ... additional technical steps following project patterns
git add global_scripts/99_archive global_scripts/11_rshinyapp_utils
git commit -m "Consolidated readYamlConfig with load_app_config"
```

### Example 2: Adding Locale Support Following Project Standards

```
# SNSQL command
add locale "fr_FR.UTF-8" to terminology dictionary with default translations

# Equivalent technical steps following project standards
# 1. Check if locale exists in system using project's verification approach
locale -a | grep fr_FR
# 2. Update UI terminology dictionary according to project schema
# 3. Add column for new locale following project naming conventions
# 4. Generate placeholder translations using project templates
# 5. Update translation function following project patterns
# ... additional technical steps
```

### Example 3: Creating Script with Project Naming Conventions

```
# SNSQL command
create update script "process_transaction_history" for "global_scripts/01_db" following numbered prefix convention

# Equivalent technical steps following project conventions
# 1. Determine the next available number in the 01_db directory (e.g., 301)
# 2. Apply the global script "g" suffix to the number
# 3. Generate the full filename with proper prefixes: "301g_process_transaction_history.R"
# 4. Create file with standardized header (author, date, purpose, etc.)
# 5. Add template sections (dependencies, main function, initialization code)
# 6. Place in correct directory with proper permissions
# ... additional technical steps
```

### Example 4: Refactoring Component Structure Following Project Patterns

```
# SNSQL command
refactor component "customerProfile" to follow hybrid sidebar pattern

# Equivalent technical steps following project conventions
# 1. Analyze existing component structure
# 2. Create UI, Server and Defaults files following project naming conventions
# 3. Extract code from existing files following project organization patterns
# 4. Implement hybrid sidebar structure according to project standards
# 5. Update imports and references according to project dependency rules
# ... additional technical steps
```

### Example 5: Data Derivation Flow for DNA Analysis

```
# SNSQL command
derive D01_dna_analysis as:
  D01_00 import external_raw_data.amazon_sales to raw_data.df_amazon_sales;
  D01_01 cleanse raw_data.df_amazon_sales to cleansed_data.df_amazon_sales;
  D01_02 standardize cleansed_data.df_amazon_sales to processed_data.df_amazon_sales;
  D01_03 transform processed_data.df_amazon_sales to processed_data.df_amazon_sales_by_customer_id;
  D01_04 analyze dna of processed_data.df_amazon_sales_by_customer_id to processed_data.df_amazon_sales_by_customer_id___dna;
  D01_05 copy processed_data.df_amazon_sales_by_customer_id___dna to app_data.processed_data.df_amazon_sales_by_customer_id

# Equivalent technical steps following project conventions
# 1. Create derivation document with appropriate header and sections
# 2. Document each step with input/output specifications
# 3. Generate appropriate transformation code for each step
# 4. Establish data lineage tracking according to project standards
# 5. Create appropriate directory structure for interim data storage
# 6. Implement validation checks between transformation steps
# ... additional technical steps
```

## Relationship to Other Principles

### Relation to Natural SQL Language (MP24)

SNSQL extends MP24 by:
1. **Project Specialization**: Adding project-specific vocabulary and commands
2. **Idiom Formalization**: Expressing project conventions in structured language
3. **Workflow Automation**: Encoding project-specific workflows as commands

### Relation to AI Communication Meta-Language (MP25)

SNSQL complements MP25 by:
1. **Concrete Instructions**: Providing specific, executable commands for AI interactions
2. **Project Knowledge Encoding**: Capturing project-specific knowledge in language
3. **Interface Standardization**: Creating a consistent interface for project operations

### Relation to Archiving Standard (R28)

SNSQL implements R28 through:
1. **Standard Implementation**: Providing commands that follow project archiving standards
2. **Process Automation**: Ensuring archiving follows project-specific processes
3. **Integrated Workflow**: Connecting archiving to related operations per project conventions

## Conclusion

The Specialized Natural SQL Language (SNSQL) meta-principle extends NSQL with project-specific commands and idiomatic operations, creating an intuitive interface for operations that follow project conventions. By encapsulating project knowledge in accessible language constructs, SNSQL improves efficiency, consistency, and knowledge transfer within the project context.

SNSQL recognizes that projects develop their own "idioms" - specialized patterns and workflows that, while specific to the project context, benefit from standardized expression. Through this meta-principle, these idioms are formalized and integrated into the project's language framework, making project-specific knowledge more accessible and operations more consistent.