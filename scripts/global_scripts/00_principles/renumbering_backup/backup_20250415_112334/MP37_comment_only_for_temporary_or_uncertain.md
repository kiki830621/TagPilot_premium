# MP37: Comment Only for Temporary or Uncertain Code

## Definition
When code is uncertain, temporarily disabled, or intended to be hidden, use comments exclusively rather than conditional execution, feature flags, or structural modifications. This preserves code integrity while making temporary status explicit.

## When to Apply

This principle should ONLY be applied to:

1. **Truly Temporary Code**: Code that has a clear expiration date or trigger for removal/replacement
2. **Experimental Features**: Functionality being tested but not ready for production
3. **Placeholders**: Empty or minimal implementations waiting for proper development
4. **Disabled Functionality**: Code temporarily commented out due to bugs or pending dependencies
5. **Uncertain Behavior**: Code whose correctness or performance is in question

This principle should NOT be applied to:

1. Regular features that are simply new or in-progress
2. Stable code that is part of the normal application flow
3. Completed features that are working as expected
4. Documentation comments explaining how code works

## Explanation

Comments provide a clear, non-executable way to temporarily exclude or mark code without adding complexity through additional logic constructs. This principle:

1. Distinguishes clearly between production code and temporary/uncertain code
2. Prevents temporary workarounds from becoming permanent through "forgotten" conditional flags
3. Makes experimental or uncertain features easier to identify during code review
4. Simplifies debugging by eliminating hidden runtime behaviors
5. Reduces technical debt from accumulated conditional logic

## Implementation Guidelines

### 1. Code Uncertainty or Experiments

When working with code whose behavior or correctness is uncertain:

```r
# UNCERTAIN (2025-04-06): This implementation may cause performance issues with large datasets
# Consider refactoring with data.table for better efficiency by next sprint
sales_summary <- aggregate(amount ~ date, data = sales_data, FUN = sum)

# Alternative implementation:
# sales_summary <- data.table(sales_data)[, .(total = sum(amount)), by = date]
```

### 2. Temporary Disabling

When temporarily disabling functionality:

```r
# TEMP-DISABLED (2025-04-06): Disabling API validation until backend is updated
# Will be re-enabled after the new API spec is implemented (expected by 2025-04-20)
# validate_api_responses(data)
```

### 3. Feature Hiding

When hiding features temporarily:

```r
# HIDDEN-FEATURE (2025-04-06): Advanced filtering UI hidden until UX testing complete
# Will be enabled after user testing confirms approach (scheduled for 2025-04-15)
# uiOutput("advanced_filters")
```

### 4. Debugging Alternates

When providing alternative implementations for debugging:

```r
process_data(input_data)
# DEBUG-ALTERNATIVE (2025-04-06): For testing with small batches during development
# To be removed before production deployment
# process_data(input_data[1:100, ])
```

### 5. Placeholders for Future Implementation

When providing minimal implementations waiting for actual functionality:

```r
# TEMP-PLACEHOLDER (2025-04-06): Static data for UI mockup
# Will be replaced with database query when backend is ready (expected 2025-04-30)
user_data <- data.frame(
  id = 1:5,
  name = c("User A", "User B", "User C", "User D", "User E"),
  status = sample(c("Active", "Inactive"), 5, replace = TRUE)
)
```

## Anti-Patterns

### 1. Runtime Conditionals for Temporary States

Avoid:
```r
# Bad: Using conditional logic for temporary feature hiding
if (ENABLE_ADVANCED_FILTERS) {  # Global flag that might be forgotten
  uiOutput("advanced_filters")
}
```

Instead:
```r
# HIDDEN-FEATURE (2025-04-06): Advanced filtering UI hidden until UX testing complete
# Will be enabled after user testing confirms approach (scheduled for 2025-04-15)
# uiOutput("advanced_filters")
```

### 2. Commented Code Without Explanation

Avoid:
```r
# Bad: No explanation for why code is commented
# data <- transform_data(raw_data)
data <- raw_data
```

Instead:
```r
# TEMP-DISABLED (2025-04-06): Data transformation skipped due to performance issues
# Will re-enable once optimized transformation function is implemented (by 2025-04-25)
# data <- transform_data(raw_data)
data <- raw_data
```

### 3. Mixed Commenting and Conditional Logic

Avoid:
```r
# Bad: Mixed approach creates confusion
# if (DEBUG_MODE) {
  # Debug-only data processing
# }
```

Instead:
```r
# DEBUG-ONLY (2025-04-06): Special processing for debugging session
# To be removed after testing phase completes (by 2025-04-20)
# debug_data <- process_debug_data(input_data)
# log_debug_results(debug_data)
```

### 4. Missing Timeframe or Conditions for Resolution

Avoid:
```r
# Bad: No indication of when this should be fixed
# TEMP-DISABLED: API validation not working
# validate_api_responses(data)
```

Instead:
```r
# TEMP-DISABLED (2025-04-06): API validation failing with new backend version
# Will be fixed when backend team addresses issue #123 (expected by 2025-04-12)
# validate_api_responses(data)
```

## Comment Format Conventions

1. **Prefix**: Always start with a standardized prefix in ALL CAPS, followed by a colon:
   - UNCERTAIN: For code whose behavior or correctness is questioned
   - TEMP-DISABLED: For temporarily disabled functionality 
   - HIDDEN-FEATURE: For UI/features intentionally hidden
   - DEBUG-ONLY: For code only used during debugging
   - EXPERIMENTAL: For experimental implementations
   - TEMP-PLACEHOLDER: For minimal implementations awaiting real functionality

2. **Date**: Include the date when the comment was added (YYYY-MM-DD)

3. **Rationale**: Always explain why the code is commented

4. **Resolution Plan**: State when or under what conditions the code should be uncommented, with specific dates or milestones when possible

## Benefits

1. **Clarity**: Makes temporary nature of changes obvious
2. **Simplicity**: Avoids accumulation of conditional logic 
3. **Searchability**: Standard prefixes make finding temporary code easy
4. **Accountability**: Dates and explanations create clear timeline for resolution
5. **Code Review**: Makes uncertain/temporary code more visible during reviews

## Application with MP38

When following MP38 (Incremental Single-Feature Release), MP37 comments help:

1. Clearly mark which parts of a single-feature release are temporary
2. Document when placeholder implementations will be replaced
3. Create traceable history of what parts of a feature need future attention
4. Distinguish between completed parts of a feature and those still in development

## Related Principles

- MP16: Modularity
- MP17: Separation of Concerns
- MP18: Don't Repeat Yourself
- MP30: Vectorization Principle 
- MP38: Incremental Single-Feature Release
- R48: Switch Over If-Else