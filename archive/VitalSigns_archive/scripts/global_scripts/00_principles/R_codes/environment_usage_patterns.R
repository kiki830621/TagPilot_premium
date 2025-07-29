# Environment Usage Patterns in R
# This file demonstrates the principle "Create a new env if we want R to do something separately"
# with consistent naming conventions and object-oriented properties

#------------------------------------------------------------------------------
# 1. Basic Environment Creation and Naming Convention
#------------------------------------------------------------------------------

# Create a new environment with consistent naming (.SuffixEnv)
.ConfigEnv <- new.env(parent = emptyenv())
.CacheEnv <- new.env(parent = globalenv())
.LoggingEnv <- new.env(parent = globalenv())

# Note: Environment names should:
# - Begin with a period (.) to indicate semi-private status
# - Use CamelCase for the descriptive part
# - End with "Env" suffix to clearly identify as an environment
# - Examples: .InitEnv, .ConfigEnv, .CacheEnv, .TempEnv

#------------------------------------------------------------------------------
# 2. Parent Environment Inheritance
#------------------------------------------------------------------------------

# Environment with empty parent (no inheritance)
.IsolatedEnv <- new.env(parent = emptyenv())
.IsolatedEnv$x <- 10
# Objects in .IsolatedEnv cannot access variables from other environments

# Environment with global parent (inherits from global)
.SharedEnv <- new.env(parent = globalenv())
global_var <- "visible to SharedEnv"
.SharedEnv$local_var <- "only in SharedEnv"
# .SharedEnv can access global_var but not vice versa

# Custom parent environment
.ParentEnv <- new.env(parent = emptyenv())
.ParentEnv$parent_var <- "parent value"

.ChildEnv <- new.env(parent = .ParentEnv)
# .ChildEnv can access parent_var from .ParentEnv

# Environment hierarchy demonstration
.AppEnv <- new.env(parent = emptyenv())
.ModuleEnv <- new.env(parent = .AppEnv)
.ComponentEnv <- new.env(parent = .ModuleEnv)

# This creates a searchpath: .ComponentEnv -> .ModuleEnv -> .AppEnv -> emptyenv()

#------------------------------------------------------------------------------
# 3. Object-Oriented Properties of Environments
#------------------------------------------------------------------------------

# Environment as namespace
.UserEnv <- new.env(parent = emptyenv())

# Method definition within environment
.UserEnv$create_user <- function(name, role) {
  user <- list(
    name = name,
    role = role,
    created_at = Sys.time()
  )
  # Store in the environment itself
  assign(name, user, envir = .UserEnv)
  invisible(user)
}

.UserEnv$get_user <- function(name) {
  if (exists(name, envir = .UserEnv, inherits = FALSE)) {
    return(get(name, envir = .UserEnv))
  } else {
    return(NULL)
  }
}

.UserEnv$list_users <- function() {
  users <- ls(envir = .UserEnv)
  # Filter out the methods
  users <- users[!users %in% c("create_user", "get_user", "list_users", "delete_user")]
  return(users)
}

.UserEnv$delete_user <- function(name) {
  if (exists(name, envir = .UserEnv)) {
    rm(list = name, envir = .UserEnv)
    return(TRUE)
  }
  return(FALSE)
}

# Usage example (commented)
# .UserEnv$create_user("john_doe", "admin")
# .UserEnv$create_user("jane_smith", "user")
# users <- .UserEnv$list_users()
# john <- .UserEnv$get_user("john_doe")
# .UserEnv$delete_user("jane_smith")

#------------------------------------------------------------------------------
# 4. Practical Application: Initialization Environment
#------------------------------------------------------------------------------

# Create initialization environment
.InitEnv <- new.env(parent = emptyenv())

# Add tracking capabilities
.InitEnv$init_log <- list()
.InitEnv$start_time <- Sys.time()

# Store functions in the environment
.InitEnv$track <- function(component, status) {
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  .InitEnv$init_log[[length(.InitEnv$init_log) + 1]] <- list(
    component = component,
    status = status,
    timestamp = timestamp
  )
}

.InitEnv$get_log <- function() {
  return(.InitEnv$init_log)
}

.InitEnv$print_summary <- function() {
  if (length(.InitEnv$init_log) == 0) {
    cat("No initialization events recorded\n")
    return(invisible(NULL))
  }
  
  cat("Initialization Summary:\n")
  cat("========================\n")
  cat("Started at:", format(.InitEnv$start_time, "%Y-%m-%d %H:%M:%S"), "\n")
  cat("Total components:", length(.InitEnv$init_log), "\n\n")
  
  # Count successful vs failed initializations
  statuses <- sapply(.InitEnv$init_log, function(x) x$status)
  success_count <- sum(statuses == "success")
  failure_count <- sum(statuses == "failure")
  
  cat("Successful:", success_count, "\n")
  cat("Failed:", failure_count, "\n\n")
  
  if (failure_count > 0) {
    cat("Failed components:\n")
    for (item in .InitEnv$init_log) {
      if (item$status == "failure") {
        cat("- ", item$component, " at ", item$timestamp, "\n")
      }
    }
  }
}

# Example usage (commented)
# .InitEnv$track("database_connection", "success")
# .InitEnv$track("config_loader", "success")
# .InitEnv$track("external_api", "failure")
# .InitEnv$print_summary()

#------------------------------------------------------------------------------
# 5. Environment for Cached Computations
#------------------------------------------------------------------------------

.CacheEnv <- new.env(parent = emptyenv())
.CacheEnv$cache <- list()
.CacheEnv$hits <- 0
.CacheEnv$misses <- 0

# Memoization function that caches results in the environment
.CacheEnv$memoize <- function(func) {
  force(func) # Force evaluation of func
  
  function(...) {
    # Create a unique key for the arguments
    args <- list(...)
    key <- digest::digest(args)
    
    # Check if result is cached
    if (exists(key, envir = .CacheEnv$cache, inherits = FALSE)) {
      .CacheEnv$hits <- .CacheEnv$hits + 1
      return(.CacheEnv$cache[[key]])
    }
    
    # Compute result and cache it
    .CacheEnv$misses <- .CacheEnv$misses + 1
    result <- func(...)
    .CacheEnv$cache[[key]] <- result
    return(result)
  }
}

.CacheEnv$clear <- function() {
  .CacheEnv$cache <- list()
  .CacheEnv$hits <- 0
  .CacheEnv$misses <- 0
  invisible(NULL)
}

.CacheEnv$stats <- function() {
  total <- .CacheEnv$hits + .CacheEnv$misses
  hit_rate <- if (total > 0) .CacheEnv$hits / total else 0
  
  list(
    cache_size = length(.CacheEnv$cache),
    hits = .CacheEnv$hits,
    misses = .CacheEnv$misses,
    hit_rate = hit_rate
  )
}

# Example usage (commented)
# # Define a slow function
# slow_func <- function(x) {
#   Sys.sleep(1)  # Simulate slow computation
#   return(x^2)
# }
#
# # Create memoized version
# fast_func <- .CacheEnv$memoize(slow_func)
#
# # First call is slow (cache miss)
# system.time(fast_func(10))
#
# # Second call is fast (cache hit)
# system.time(fast_func(10))
#
# # Check cache statistics
# .CacheEnv$stats()

#------------------------------------------------------------------------------
# 6. Application: Module-Specific Environments
#------------------------------------------------------------------------------

# Create environment for a specific Shiny module
.AnalyticsModuleEnv <- new.env(parent = globalenv())

# State variables
.AnalyticsModuleEnv$state <- list(
  current_view = "summary",
  filters = list(),
  last_refresh = NULL
)

# Module-specific constants
.AnalyticsModuleEnv$constants <- list(
  available_views = c("summary", "detailed", "chart"),
  refresh_interval = 300,  # 5 minutes
  max_items = 1000
)

# Helper functions
.AnalyticsModuleEnv$needs_refresh <- function() {
  if (is.null(.AnalyticsModuleEnv$state$last_refresh)) return(TRUE)
  
  time_diff <- difftime(Sys.time(), 
                       .AnalyticsModuleEnv$state$last_refresh, 
                       units = "secs")
  return(time_diff > .AnalyticsModuleEnv$constants$refresh_interval)
}

.AnalyticsModuleEnv$update_view <- function(view_name) {
  if (view_name %in% .AnalyticsModuleEnv$constants$available_views) {
    .AnalyticsModuleEnv$state$current_view <- view_name
    return(TRUE)
  }
  return(FALSE)
}

.AnalyticsModuleEnv$add_filter <- function(name, value) {
  .AnalyticsModuleEnv$state$filters[[name]] <- value
  invisible(.AnalyticsModuleEnv$state$filters)
}

.AnalyticsModuleEnv$reset <- function() {
  .AnalyticsModuleEnv$state$current_view <- "summary"
  .AnalyticsModuleEnv$state$filters <- list()
  .AnalyticsModuleEnv$state$last_refresh <- NULL
  invisible(NULL)
}

#------------------------------------------------------------------------------
# 7. Benefits of Separate Environments
#------------------------------------------------------------------------------

# 1. Namespace isolation: prevents naming conflicts
# 2. State encapsulation: keeps related data and functions together
# 3. Memory management: environments can be garbage collected when no longer needed
# 4. Information hiding: dot-prefix convention indicates "private" scope
# 5. Inheritance: environment parent chains provide access control
# 6. Object-oriented programming: methods can access and modify environment data
# 7. Module patterns: support for module-style encapsulation
# 8. Thread safety: separate environments can prevent race conditions