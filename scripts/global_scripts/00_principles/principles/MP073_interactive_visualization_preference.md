---
id: "MP073"
title: "Interactive Visualization Preference"
type: "meta-principle"
date_created: "2025-04-17"
date_modified: "2025-04-17"
author: "Claude"
derives_from:
  - "MP001": "Primitive Terms and Definitions"
  - "MP012": "Company-Centered Design"
influences:
  - "P006": "Data Visualization"
related_to:
  - "MP060": "Parsimony"
  - "MP067": "UI Separation"
---

# Interactive Visualization Preference Meta-Principle

## Summary

This meta-principle establishes `plotly` as the preferred library for interactive data visualizations and `leaflet` as the preferred library for maps in Shiny applications. It prioritizes consistent interactivity, cross-platform compatibility, and a unified development approach to enhance user experience and developer productivity.

## Motivation

Interactive visualizations provide significant advantages over static plots in data exploration and analysis applications. By standardizing on a single primary visualization library, we:

1. Ensure consistent user experience across the application
2. Reduce cognitive load for both developers and users 
3. Enable more efficient code reuse and maintenance
4. Create a coherent visual language throughout the application

## Core Principles

1. **Plotly shall be the preferred visualization library for all interactive data visualizations in Shiny applications.**

2. **Leaflet shall be the preferred visualization library for all maps and geospatial visualizations in Shiny applications.**

## Implementation Guidelines

### 1. Library Selection Hierarchy

When implementing visualizations in Shiny applications, follow this order of preference:

1. **Plotly (Primary)**: For all interactive plots that support drill-downs, tooltips, zooming, panning, or other interactive features (except maps)
2. **Leaflet (Primary for Maps)**: Always use leaflet for maps and geospatial data visualizations
3. **ggplot2 (Secondary)**: For static visualizations or when preparing base plots to be converted to plotly
4. **Specialized Libraries (Tertiary)**: Libraries like networkD3 (for network graphs) or other specialized visualization tools only when plotly and leaflet don't provide adequate functionality

### 2. Conversion Pattern

When working with ggplot2 visualizations:

```r
# Preferred pattern for creating interactive visualizations
create_interactive_chart <- function(data, x_col, y_col) {
  # First create ggplot2 object
  g <- ggplot(data, aes(x = !!sym(x_col), y = !!sym(y_col))) +
    geom_point() +
    theme_minimal()
    
  # Then convert to plotly 
  p <- ggplotly(g) %>%
    layout(
      # Configure consistent plotly options
      hovermode = "closest",
      hoverlabel = list(
        bgcolor = "white",
        font = list(family = "Arial")
      )
    )
    
  return(p)
}
```

### 3. Common Configuration

Maintain consistent configuration across all plotly visualizations:

- **Layout**: Use consistent margins, font sizes, and color schemes
- **Interactivity**: Provide consistent tooltip formats and interactive behaviors
- **Responsive Design**: Ensure all plots resize properly on different devices

### 4. Function Parameters

All visualization functions should include:

```r
visualize_data <- function(
  data,
  ...,
  title = NULL,
  subtitle = NULL,
  interactive = TRUE,  # Always default to TRUE
  plotly_config = list()  # Allow customization while maintaining defaults
) {
  # Function implementation
}
```

### 5. Performance Considerations

- Apply data aggregation before visualization when working with large datasets
- Use reactive expressions to prevent unnecessary recreation of plots
- Consider `plotly::partial_bundle()` for production deployment to reduce file size

## Exceptions

Exceptions to using plotly are permitted in the following scenarios:

1. **Special Visualization Types**: When plotly doesn't support the required visualization type
2. **Performance Constraints**: For extremely large datasets where interactive rendering creates performance issues
3. **Print-Specific Outputs**: For visualizations specifically designed for print or static export
4. **Highly Specialized Requirements**: When specific interactions not supported by plotly are essential

All exceptions must be documented with a clear justification comment.

## Example Implementation

```r
#' @title Create Customer Journey Visualization
#' @description Creates an interactive visualization of the customer journey
#' @param data Data frame with customer journey data
#' @param date_col Column name containing dates
#' @param event_col Column name containing event types
#' @param customer_col Column name containing customer identifiers
#' @param interactive Whether to return an interactive plotly object (default: TRUE)
#' @return A plotly or ggplot2 object based on the interactive parameter
#' @examples
#' journey_data <- data.frame(
#'   date = as.Date(c("2025-01-01", "2025-01-15", "2025-02-01")),
#'   event = c("view", "signup", "purchase"),
#'   customer_id = c(1, 1, 1)
#' )
#' visualize_customer_journey(journey_data)
visualize_customer_journey <- function(
  data,
  date_col = "date",
  event_col = "event", 
  customer_col = "customer_id",
  interactive = TRUE
) {
  # Input validation
  required_cols <- c(date_col, event_col, customer_col)
  if (!all(required_cols %in% names(data))) {
    stop("Missing required columns: ", 
         paste(setdiff(required_cols, names(data)), collapse = ", "))
  }
  
  # Create base visualization with ggplot2
  g <- ggplot(data, aes(x = !!sym(date_col), y = !!sym(customer_col), color = !!sym(event_col))) +
    geom_point(size = 3) +
    geom_path(aes(group = !!sym(customer_col))) +
    theme_minimal() +
    labs(
      title = "Customer Journey Visualization",
      x = "Date",
      y = "Customer",
      color = "Event Type"
    )
  
  # Convert to interactive plotly if requested
  if (interactive) {
    p <- ggplotly(g) %>%
      layout(
        hovermode = "closest",
        hoverlabel = list(
          bgcolor = "white",
          font = list(family = "Arial")
        )
      ) %>%
      config(
        displayModeBar = TRUE,
        modeBarButtonsToRemove = c(
          "sendDataToCloud", "autoScale2d", "resetScale2d",
          "hoverClosestCartesian", "hoverCompareCartesian"
        )
      )
    return(p)
  } else {
    # Document the exception reason when returning non-interactive
    # Example: "# Returning static plot for print export requirements"
    return(g)
  }
}
```

## Relationship to Other Principles

This meta-principle:

1. **Derives from**:
   - MP001 (Primitive Terms and Definitions) in establishing clear terminology
   - MP012 (Company-Centered Design) in standardizing for user/developer experience

2. **Influences**:
   - P006 (Data Visualization) by providing specific guidance on visualization library selection

3. **Related to**:
   - MP060 (Parsimony) in reducing unnecessary complexity in library choices
   - MP067 (UI Separation) in defining standard UI components

## Conclusion

By establishing plotly as our preferred visualization library, we ensure consistent interactive experiences throughout our applications. This standardization improves development efficiency, creates a coherent visual language, and enhances user experience through interactive data exploration.