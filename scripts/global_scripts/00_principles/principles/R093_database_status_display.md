---
id: "R0093"
title: "Database Status Display"
type: "rule"
date_created: "2025-06-28"
date_modified: "2025-06-28"
author: "Claude"
implements:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
  - "MP0019": "Documentation First"
related_to:
  - "R0092": "Universal DBI Approach"
  - "P0076": "Error Handling Patterns"
  - "P0077": "Performance Optimization"
---

# Database Status Display

## Core Requirement

All Shiny applications that use database connections must provide a visual indicator showing the current database connection status, including the type of database (PostgreSQL, SQLite, etc.), connection state, and environment (production, development, etc.).

## Implementation Pattern

### 1. Connection Information Storage

When establishing a database connection, store metadata as an attribute:

```r
get_con <- function() {
  con <- dbConnect(...)
  
  # Store connection info
  db_info <- list(
    type = "PostgreSQL",  # or "SQLite", "MariaDB", etc.
    host = Sys.getenv("PGHOST"),
    port = Sys.getenv("PGPORT"),
    dbname = Sys.getenv("PGDATABASE"),
    icon = "🐘",  # Visual indicator
    color = "#336791",  # Brand color
    status = "Production"  # or "Development", "Testing"
  )
  attr(con, "db_info") <- db_info
  
  return(con)
}
```

### 2. Information Retrieval Function

Provide a standardized function to retrieve connection information:

```r
get_db_info <- function(con = NULL) {
  if (is.null(con)) {
    return(list(
      type = "Not Connected",
      icon = "❌",
      color = "#DC3545",
      status = "Disconnected"
    ))
  }
  
  db_info <- attr(con, "db_info")
  if (!is.null(db_info)) {
    return(db_info)
  }
  
  # Fallback: detect type from connection class
  if (inherits(con, "PqConnection")) {
    return(list(
      type = "PostgreSQL",
      icon = "🐘",
      color = "#336791",
      status = "Unknown"
    ))
  } else if (inherits(con, "SQLiteConnection")) {
    return(list(
      type = "SQLite",
      icon = "📁",
      color = "#FF8C00",
      status = "Local"
    ))
  }
  
  return(list(
    type = "Unknown",
    icon = "❓",
    color = "#6C757D",
    status = "Unknown"
  ))
}
```

### 3. UI Display Implementation

#### For bs4Dash Applications

```r
# In UI
header = bs4DashNavbar(
  ...,
  rightUi = tagList(
    uiOutput("db_status"),
    uiOutput("user_menu")
  )
)

# In Server
output$db_status <- renderUI({
  div(
    style = sprintf("color: %s; padding: 8px; margin-right: 15px; background: rgba(255,255,255,0.1); border-radius: 5px;", db_info$color),
    span(db_info$icon, style = "margin-right: 5px;"),
    span(db_info$type, style = "font-weight: bold; margin-right: 5px;"),
    span(sprintf("(%s)", db_info$status), style = "font-size: 0.9em; opacity: 0.8;")
  )
})
```

#### For Standard Shiny Applications

```r
# In UI
tags$head(
  tags$style(HTML("
    #db_status_bar { 
      position: fixed; 
      top: 10px; 
      right: 10px; 
      z-index: 1000;
      padding: 8px 15px;
      border-radius: 5px;
      background: rgba(255,255,255,0.95);
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
  "))
),
div(id = "db_status_bar", uiOutput("db_status"))
```

## Visual Standards

### Database Type Icons and Colors

| Database | Icon | Color | Status Text |
|----------|------|--------|-------------|
| PostgreSQL | 🐘 | #336791 | Production/Cloud |
| SQLite | 📁 | #FF8C00 | Local/Test |
| MariaDB/MySQL | 🐬 | #003545 | Production |
| DuckDB | 🦆 | #FFA500 | Analytics |
| Not Connected | ❌ | #DC3545 | Disconnected |
| Unknown | ❓ | #6C757D | Unknown |

### Display Positions

1. **bs4Dash/AdminLTE**: Header navigation bar (right side)
2. **Standard Shiny**: Fixed position (top-right corner)
3. **Sidebar Apps**: Top of sidebar below app title

## Implementation Benefits

1. **Developer Awareness**: Immediately see which database is being used
2. **Production Safety**: Avoid accidental operations on production database
3. **Debugging**: Quick identification of connection issues
4. **User Confidence**: Users can see the system is properly connected

## Error Handling

The status display should gracefully handle:
- Failed connections (show disconnected state)
- Missing environment variables (show local/test mode)
- Connection timeouts (update status dynamically)

## Examples

### Example 1: PostgreSQL with Fallback to SQLite

```r
get_con <- function() {
  tryCatch({
    # Try PostgreSQL
    con <- dbConnect(
      RPostgres::Postgres(),
      host = Sys.getenv("PGHOST"),
      ...
    )
    
    db_info <- list(
      type = "PostgreSQL",
      icon = "🐘",
      color = "#336791",
      status = "Production"
    )
    attr(con, "db_info") <- db_info
    
    return(con)
  }, error = function(e) {
    # Fallback to SQLite
    con <- dbConnect(RSQLite::SQLite(), "local_test.db")
    
    db_info <- list(
      type = "SQLite",
      icon = "📁",
      color = "#FF8C00",
      status = "Local Test"
    )
    attr(con, "db_info") <- db_info
    
    return(con)
  })
}
```

### Example 2: Dynamic Status Updates

```r
# Reactive status that updates on connection changes
db_status_reactive <- reactive({
  invalidateLater(5000)  # Check every 5 seconds
  
  if (DBI::dbIsValid(con_global)) {
    get_db_info(con_global)
  } else {
    list(
      type = "Connection Lost",
      icon = "⚠️",
      color = "#FFC107",
      status = "Reconnecting..."
    )
  }
})
```

## Testing

When implementing database status display:

1. Test with valid connections
2. Test with invalid/missing credentials
3. Test connection switching (if supported)
4. Verify visual consistency across browsers
5. Check responsive design on mobile devices

## Related Principles

This rule extends:
- **R0092 (Universal DBI Approach)**: By providing visibility into the connection being used
- **MP0016 (Modularity)**: By separating status display from connection logic
- **MP0017 (Separation of Concerns)**: By isolating UI concerns from data access

## Migration Guide

To add database status display to existing applications:

1. Update `get_con()` to add `db_info` attribute
2. Add `get_db_info()` function
3. Add UI output element
4. Add server render logic
5. Test with different connection scenarios 