# P55: N-tuple Independent Loading

## Definition
Components in an n-tuple pattern should be loaded and handled independently, treated as distinct entities each serving a specific purpose rather than as a single combined unit.

## Explanation
The n-tuple pattern (like the UI-Server-Defaults-Filters pattern) divides functionality into distinct aspects. While these aspects are conceptually related, they should be loaded, managed, and executed independently. This approach offers several advantages:

1. **Aspect-Oriented Loading**: Components are loaded by aspect (all UIs together, all Servers together, etc.), which aligns with the execution flow of the application
2. **Selective Loading**: Only necessary aspects can be loaded when needed (e.g., loading only UI/Server components in a view-only mode)
3. **Independent Testing**: Each aspect can be tested independently of others
4. **Clearer Dependency Flow**: Dependencies between aspects become explicit rather than implicit
5. **Parallel Processing**: Aspects can be executed in parallel when appropriate
6. **Substitutability**: Individual aspects can be replaced or modified without affecting others

## Implementation

### Component Loading
- Group loading by aspect, not by component
- Load UI aspects first, followed by server logic, and then supporting aspects (defaults, filters)
- Structure your code to reflect the execution flow of each aspect type

### Example
```r
# GOOD: Loading by aspect type
# Load all UI components
source("components/sidebar/sidebarUI.R")
source("components/sidebar/marketingChannel/marketingChannelUI.R")
source("components/sidebar/productCategory/productCategoryUI.R")

# Load all Server components
source("components/sidebar/sidebarServer.R")
source("components/sidebar/marketingChannel/marketingChannelServer.R")
source("components/sidebar/productCategory/productCategoryServer.R")

# Load all Filters components
source("components/sidebar/marketingChannel/marketingChannelFilters.R")
source("components/sidebar/productCategory/productCategoryFilters.R")

# BAD: Loading all aspects of a component together
source("components/sidebar/marketingChannel/marketingChannelUI.R")
source("components/sidebar/marketingChannel/marketingChannelServer.R")
source("components/sidebar/marketingChannel/marketingChannelFilters.R")
source("components/sidebar/marketingChannel/marketingChannelDefaults.R")
```

### Function Organization
Use namespacing or naming conventions to organize functions by aspect:

```r
# UI functions follow UI patterns and return UI elements
marketingChannelUI <- function(id) { ... }
productCategoryUI <- function(id) { ... }

# Server functions follow server patterns and handle reactivity
marketingChannelServer <- function(id) { ... }
productCategoryServer <- function(id) { ... }

# Filter functions follow data processing patterns
marketingChannelFilters <- function(selection) { ... }
productCategoryFilters <- function(selection) { ... }
```

## Related Principles
- P21: Component N-tuple Pattern
- P20: Sidebar Filtering Only
- R54: Component Folder Organization
- MP17: Separation of Concerns