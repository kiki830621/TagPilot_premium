---
id: "P70"
title: "Complete Input Display Principle"
type: "principle"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "MP12": "Company-Centered Design"
  - "MP17": "Separation of Concerns"
related_to:
  - "P22": "CSS Over Conditional Controls"
  - "MP45": "Automatic Data Availability Detection"
---

# Complete Input Display Principle

## Core Principle

**Input controls should display all possible options to provide users with a complete view of the domain, while using visual indicators and state management to communicate availability, rather than hiding unavailable options.**

## Implementation Guidelines

### 1. Display All Domain Options

1. **Full Domain Visibility**: Input controls (radioButtons, checkboxes, select inputs) should display the complete set of domain options, regardless of current availability.

2. **Consistent Presentation**: The set of options should remain consistent across application states to maintain user orientation within the application.

3. **Complete Mental Model**: Displaying all options helps users construct a complete mental model of the application's capabilities, even when some functionality is unavailable.

### 2. Availability Communication

1. **Disable Unavailable Options**: Instead of removing options, indicate unavailability by disabling the option (`disabled=TRUE`) while keeping it visible.

2. **Visual Indicators**: Use consistent visual styling (grayed-out text, distinct background) to indicate unavailable options.

3. **Explanatory Tooltips**: Provide tooltips that explain why an option is unavailable and what conditions would make it available.

### 3. Implementation Patterns

#### RadioButtons Pattern

```r
# Complete options always displayed
radioButtons(
  "marketing_channel",
  "Select Channel:",
  choices = all_channels,
  selected = default_channel
)

# In server code - update disabled state, not choices
observe({
  unavailable_channels <- getUnavailableChannels()
  updateRadioButtons(
    session,
    "marketing_channel",
    choiceNames = lapply(names(all_channels), function(name) {
      if (all_channels[name] %in% unavailable_channels) {
        div(
          style = "color: #999; cursor: not-allowed;",
          HTML(paste(name, "<span class='unavailable-tag'>(Data Unavailable)</span>"))
        )
      } else {
        name
      }
    }),
    choiceValues = unname(all_channels),
    disabled = lapply(unname(all_channels), function(channel) {
      channel %in% unavailable_channels
    })
  )
})
```

#### SelectInput Pattern

```r
# Complete options always displayed
selectInput(
  "product_category",
  "Select Category:",
  choices = all_categories,
  selected = default_category
)

# In server code - update disabled state
observe({
  unavailable_categories <- getUnavailableCategories()
  
  # Create list with disabled attribute for each option
  options_list <- lapply(names(all_categories), function(name) {
    if (all_categories[name] %in% unavailable_categories) {
      list(
        name = paste0(name, " (No Data)"),
        value = all_categories[name],
        disabled = TRUE
      )
    } else {
      list(
        name = name,
        value = all_categories[name],
        disabled = FALSE
      )
    }
  })
  
  updateSelectInput(
    session,
    "product_category",
    choices = options_list
  )
})
```

### 4. Data Availability Management

1. **Centralized Availability State**: Maintain a centralized data availability state that tracks which options have data.

2. **Dynamic Updates**: When data becomes available or unavailable, update the disabled state rather than changing the option set.

3. **Default Selection**: Automatically select an available option if the current selection becomes unavailable.

## Use Cases

### 1. Marketing Channel Selection

Data for certain marketing channels may be unavailable due to:
- Data loading failures
- Integration issues
- Missing permissions

**Solution**: Display all configured marketing channels, but visually indicate and disable those without available data.

### 2. Time Period Selection

Data for certain time periods may be unavailable due to:
- Data not yet collected
- Archiving of old data
- Processing delays

**Solution**: Show the complete date range, but disable unavailable periods with visual indicators.

### 3. Product Category Selection

Data for certain product categories may be unavailable due to:
- New categories without historical data
- Categories not relevant to current filter selections
- Data quality issues

**Solution**: Display all product categories but disable those that cannot be selected with the current filters.

## Benefits

1. **Consistent UX**: Users see a consistent interface regardless of data availability
2. **Transparent Limitations**: System constraints are clearly communicated rather than hidden
3. **Educational Context**: Users gain understanding of the application's full capabilities
4. **Reduced Confusion**: Prevents user disorientation when options appear/disappear
5. **Better Error States**: More elegant handling of data availability issues

## Implementation in App Config

Add data availability settings to the application configuration:

```yaml
# Data availability configuration
data_availability:
  channels:
    amazon: true
    officialwebsite: false  # Data currently unavailable
  categories:
    "000": true  # All Products
    "001": true  # Kitchen
    "002": false # Home - Data unavailable
    "003": true  # Electronics
```

## Relation to Other Principles

### Relation to CSS Over Conditional Controls (P22)

This principle extends P22 by:
1. **UI Consistency**: Ensuring UI structure remains consistent
2. **State Separation**: Separating availability state from display structure
3. **Visual Communication**: Using visual styling rather than structural changes

### Relation to Company-Centered Design (MP12)

This principle implements MP12 by:
1. **Complete Information**: Providing a complete view of the business domain
2. **System Transparency**: Making system limitations transparent to users
3. **Domain Education**: Educating users about the full scope of operations

### Relation to Separation of Concerns (MP17)

This principle implements MP17 by:
1. **Separating Display from Availability**: Decoupling what is shown from what is available
2. **State Management**: Handling availability as a separate concern from UI structure
3. **Visual Communication**: Using styling as a separate layer to communicate state

### Relation to Automatic Data Availability Detection (MP45)

This principle works with MP45 by:
1. **Using Detected State**: Displaying availability state determined by MP45
2. **Consistent Communication**: Providing consistent UI patterns for availability info
3. **Dynamic Adaptation**: Responding to availability changes detected by MP45

## Conclusion

The Complete Input Display Principle prioritizes transparency and consistency by showing all domain options while clearly communicating availability. This approach provides users with a complete and stable mental model of the application while still effectively communicating limitations when they exist.