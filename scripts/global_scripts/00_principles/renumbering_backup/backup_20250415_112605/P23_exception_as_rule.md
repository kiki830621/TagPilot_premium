# P23: Exception-Driven Rule Evolution

## Context
When software systems encounter errors or exceptions, the traditional approach is to fix the immediate issue. However, this approach leads to ad hoc solutions that don't systematically prevent similar errors from occurring elsewhere in the codebase.

## Principle
**When an error or exception occurs, create an explicit rule that prevents the entire class of errors, rather than merely fixing the specific instance.**

## Rationale
1. **Systematic Prevention**: Addressing only specific instances of errors leaves the system vulnerable to similar errors occurring elsewhere.

2. **Knowledge Accumulation**: Rules derived from exceptions form a growing body of defensive knowledge that improves the overall robustness of the system.

3. **Future-Proofing**: Exception-derived rules protect against errors that haven't yet occurred but share the same pattern.

4. **Documentation Value**: Rules explicitly document past issues and their resolution patterns, preserving institutional knowledge.

5. **Consistent Handling**: Rules ensure that similar exceptions are handled consistently throughout the codebase.

## Implementation
When an error occurs:

1. **Analyze Root Cause**: Determine the fundamental cause of the error, beyond the specific instance.

2. **Identify Pattern**: Recognize the error pattern that could potentially appear elsewhere.

3. **Formulate Rule**: Create a formal rule (like SLN patterns) that addresses the entire class of errors.

4. **Apply Systematically**: Implement the rule across the entire codebase, not just at the error site.

5. **Document Connection**: Explicitly link the rule back to the original error to preserve context.

## Examples

### Example 1: Type Errors
When encountering "Error in !tab_filters : invalid argument type", don't just fix the immediate issue. Instead, create SLN01 (Handling Non-Logical Data Types) that addresses all places where type mismatches could occur in logical operations.

### Example 2: Configuration Errors
Instead of handling a missing configuration value with a local default, create a rule for systematic configuration validation and fallback patterns throughout the application.

### Example 3: Null Reference Errors
Rather than adding a null check at the point of failure, establish a consistent null-handling strategy (like the "Maybe" pattern or null object pattern) for all similar operations.

## Related Principles
- SLN01: Handling Non-Logical Data Types in Logical Contexts
- MP40: Deterministic Codebase Transformations
- R58: Evolution Over Replacement

## Applications
This principle should be applied whenever:
- An error occurs that could happen elsewhere in the codebase
- Multiple similar bugs are found across different parts of the application
- Code reviews repeatedly identify the same category of issues

By transforming exceptions into rules, the system evolves toward greater robustness with each error encountered, creating a positive feedback loop of quality improvement.