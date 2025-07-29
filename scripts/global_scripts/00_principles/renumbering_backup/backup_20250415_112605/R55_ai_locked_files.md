# Rule 55: AI-Locked Files and Code Blocks

## Core Rule
Files containing `(lock)` in their filename and code blocks surrounded by `#lock on` and `#lock off` comments are explicitly protected from AI modification. These files and code sections can only be modified by human developers, even when AI tools are requested to make changes to them.

## Implementation Guidelines

### File Naming
1. **Lock Indicator Format**
   - Add `(lock)` immediately before the file extension
   - Example: `fn_get_default_db_paths(lock).R`

2. **When to Lock Files**
   - Critical configuration files
   - Files with complex business logic that require human understanding
   - Files with security implications
   - System initialization files
   - Database connection and path configuration files

### Code Block Locking
1. **Lock Indicator Formats**
   - Standard Lock (Allows additions)
     - Add `#lock on` at the beginning of a locked code block
     - Add `#lock off` at the end of a locked code block
     - Example:
     ```r
     #lock on
     # CONSTANTS
     YAML_PATH <- "app_config.yaml"
     API_KEY <- "xyz123"
     #lock off
     ```
   
   - Strict Lock (No modifications or additions)
     - Add `#LOCK ON` at the beginning of a strictly locked code block
     - Add `#LOCK OFF` at the end of a strictly locked code block
     - Example:
     ```r
     #LOCK ON
     # CRITICAL SECURITY CONSTANTS
     ENCRYPTION_KEY <- "abc123xyz789"
     #LOCK OFF
     ```

2. **When to Lock Code Blocks**
   - Critical constant definitions
   - Security-sensitive code segments
   - Complex algorithms that require human understanding
   - Configuration paths and parameters
   - Code that interfaces with external systems

### Usage Rules
1. **For Human Developers**
   - Only add the lock indicator to truly critical files and code blocks
   - Document the reason for locking in file header comments or before the lock block
   - Lock files and significant lock blocks should be reviewed by multiple team members before modification
   - Keep locked sections as small and specific as possible

2. **For AI Assistants**
   - MUST refuse to directly modify any file with `(lock)` in the filename
   - MUST NOT modify or delete existing code between `#lock on` and `#lock off` comments
   - MAY ADD new code/comments within standard locked blocks (`#lock on`/`#lock off`) without modifying existing content (SCD Type 2 approach)
   - MUST NOT modify, delete, OR ADD to code between strict lock markers (`#LOCK ON`/`#LOCK OFF`) under any circumstances
   - MAY suggest changes to locked files or code blocks, but these must be implemented by a human
   - MUST explain to users that the file or code block is locked when refusing modifications
   - SHOULD provide the exact code change suggestions that the human can implement

## Rationale
This rule provides several key protections:

1. **Prevents Critical Errors**: Protects system-critical files from unintended AI modifications
2. **Human Oversight**: Ensures human review of changes to sensitive components
3. **Explicit Intention**: Makes the protection status immediately visible in the filename
4. **Balanced Approach**: Allows AI to still provide suggestions without direct modification

## Example Usage

### Locked File Example
```r
# filename: fn_get_default_db_paths(lock).R
#
# LOCKED FILE - AI MODIFICATION RESTRICTED
# Reason: Critical database path configuration that requires human oversight
# Last modified by: John Smith (2025-04-05)
```

### AI Assistant Response Examples

#### Locked File Example
```
I notice you've asked me to modify fn_get_default_db_paths(lock).R. 
This file is locked as indicated by '(lock)' in the filename and cannot
be modified directly by AI assistants according to R55_ai_locked_files.md.

Here are the changes I would suggest:

[code suggestions here]

Please implement these changes manually after reviewing them.
```

#### Standard Locked Block Example (Modification Request)
```
I notice you've asked me to modify the YAML_PATH constant in the following code:

#lock on
# CONSTANTS
YAML_PATH <- "app_config.yaml"
#lock off

This code block is locked with standard locks. While I can add new content, 
I cannot modify or delete existing content according to R55_ai_locked_files.md.

Here are the changes I would suggest:

[code suggestions here]

Please implement these modifications manually after reviewing them.
```

#### Standard Locked Block Example (Addition Request)
```
I'll add the new constant to the standard locked block as requested:

#lock on
# CONSTANTS
YAML_PATH <- "app_config.yaml"
API_KEY <- "your_new_api_key"  # Added new constant
#lock off

I've added a new API_KEY constant within the standard locked block without 
modifying the existing YAML_PATH constant, following the SCD Type 2 approach 
allowed for #lock on/#lock off blocks.
```

#### Strict Locked Block Example
```
I notice you've asked me to modify the security key in the following code:

#LOCK ON
# CRITICAL SECURITY CONSTANTS
ENCRYPTION_KEY <- "abc123xyz789"
#LOCK OFF

This code block is strictly locked as indicated by the '#LOCK ON' and '#LOCK OFF' 
comments (all caps). I cannot modify, delete, or add to strictly locked blocks 
under any circumstances according to R55_ai_locked_files.md.

Here are the changes I would suggest:

[code suggestions here]

Please implement these changes manually after reviewing them.
```

## Exception Handling
If a locked file must be modified by AI in an emergency situation:

1. Temporarily rename the file to remove the `(lock)` indicator
2. Make the required changes 
3. Review the changes thoroughly
4. Rename the file back to include the `(lock)` indicator
5. Document the emergency exception in the change log

## Related Rules and Principles
- R54_data_storage_organization.md
- MP29_no_fake_data.md
- MP02_default_deny.md