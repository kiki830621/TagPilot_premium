# Rule 55: Default Selection Conventions

## Core Rule
Default selections in dropdown menus, filters, and selection controls must follow consistent conventions based on the selection type and context, with special treatment for "ALL" options.

## Implementation Guidelines

### ALL Category as Default
1. In filtering contexts where an "ALL" option exists, it MUST be the default selection
   - Product category filters
   - Time period filters with an "ALL" option
   - Platform or channel selection
   - Any multi-entity filtering context

2. Implementation Pattern
   ```r
   # Correct implementation using first product (ALL) as default
   pickerInput(
     inputId = "filter_id",
     label = "Filter Label",
     choices = category_dictionary,  # First entry is ALL with ID "000"
     selected = category_dictionary[[1]]  # Select first product (ALL)
   )
   ```

### Context-Specific Default Selection
1. **Fixed Time Periods**: Default to the most recent complete period
   - Current month in month selection
   - Most recent quarter in quarter selection
   - Current year in year selection

2. **Relative Time Periods**: Default to the shortest sensible period
   - "Last 7 days" in a relative time selector
   - "Last month" in a relative period selector

3. **Location Selectors**: Default to user's current location or headquarters
   - Based on user profile location if available
   - Based on company HQ location otherwise

4. **Sorting Controls**: Default to primary business-relevant order
   - Most recent first for time-based lists
   - Highest value first for financial measures
   - Alphabetical for categorical names

### Implementation Strategy
1. **Configuration-Driven Defaults**
   ```r
   # Default from configuration
   default_period <- config$defaults$time_period
   
   # Fallback to sensible default if not configured
   if (is.null(default_period)) {
     default_period <- "last_7_days"
   }
   ```

2. **User Preference Override**
   ```r
   # Use user's saved preference if available
   if (!is.null(user_preferences$time_period)) {
     default_period <- user_preferences$time_period
   }
   ```

3. **Context-Aware Defaults**
   ```r
   # Adjust default based on available data
   if (has_data_for_current_month()) {
     default_period <- "current_month"
   } else {
     default_period <- "previous_month"
   }
   ```

## Default Persistence Rules
1. **Session Persistence**: Selection changes within a session should persist
2. **Cross-Session Defaults**: Return to global defaults on new sessions
3. **User-Specific Defaults**: Store user preferences in profile
4. **URL Parameter Override**: Allow URL parameters to override defaults

## ID Conventions for Special Values
1. **ALL Category**: Use `"000"` or `"all"`
2. **None/Empty Selection**: Use `NA`, `NULL`, or `""`
3. **Custom/Other**: Use `"999"` or `"other"`

## Related Rules and Principles
- MP0034 (Special Treatment of "ALL" Category)
- MP0011 (Sensible Defaults)
- P0017 (Config-Driven Customization)
