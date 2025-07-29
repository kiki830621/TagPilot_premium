# MP0042: Runnable-First Development

## Definition
Maintain a runnable application at all times. Stop revising when the application becomes unrunnable, and either fix the immediate issues or roll back to the last known good state. The fundamental invariant is that the application must always be in a runnable state before moving to the next revision.

## Explanation
Software in an unrunnable state has zero value, regardless of its theoretical improvements. This principle establishes that:

1. A working application with fewer features is more valuable than a non-working application with more features
2. The "runnable" state forms a checkpoint boundary that should never be crossed during development
3. When bugs accumulate and make the application unrunnable, progress must halt until runnability is restored

This principle functions as a safety mechanism to prevent "death marches" where developers continue to pile changes onto already broken code, making diagnosis and recovery increasingly difficult.

## Mathematical Foundation
The principle can be formalized as:

Let S be the set of all possible states of the application
Let R ⊂ S be the subset of runnable states
Let T: S → S be a transformation (revision)

The principle states that for any transformation T:
- If s ∈ R, then T(s) must also be in R
- If s ∈ R but T(s) ∉ R, then reject T and remain at s

This forms a strict invariant on the development process: ∀ revisions, application ∈ R

## Implementation Guidelines

### 1. Verify Runnability Before Committing

```bash
# Before committing changes, verify the application runs
./check_app.R  # Script that verifies app can start
./run_tests.sh # Run automated tests

# Only if both succeed
git commit -m "Implement feature X with runnable application"
```

### 2. Immediate Rollback When Unrunnable

When an application becomes unrunnable:

```bash
# Option 1: Fix immediately
git stash  # Save current changes
./check_app.R  # Verify app is runnable again

# Option 2: Rollback if fixes are complex
git reset --hard HEAD  # Discard changes completely
# or
git checkout -b broken-feature  # Save changes to separate branch
git checkout main  # Return to working state
```

### 3. Establish Clear Runnability Criteria

Define explicit criteria for what "runnable" means:

```r
# Example check_app.R script
verify_app <- function() {
  # 1. Syntax check
  tryCatch(parse("app.R"), error = function(e) stop("Syntax error: ", e$message))
  
  # 2. Startup check
  app <- shinyApp(ui = fluidPage(), server = function(input, output) {})
  testServer(app, {})
  
  # 3. Critical path check
  # ...
  
  return(TRUE)
}
```

## Benefits

1. **Continuous Delivery Readiness**: The application is always in a deliverable state
2. **Reduced Debugging Complexity**: Problems are identified at the point of introduction
3. **Psychological Safety**: Developers have confidence that the system will not collapse
4. **Incremental Progress**: Enforces truly incremental development rather than big-bang changes
5. **Team Coordination**: Prevents one developer's broken code from blocking others

## Anti-Patterns

### 1. "I'll Fix It Later" Syndrome

Avoid:
```r
# Bad: Knowingly committing broken code
# TODO: Fix this later, it breaks the app but I need to commit now
```

### 2. Accumulating Multiple Unrelated Changes

Avoid:
```bash
# Bad: Making multiple unrelated changes before testing runnability
git add file1.R file2.R file3.R # Modified several distinct features
git commit -m "Big feature update" # Without verifying each change separately
```

### 3. Missing Automated Runnability Checks

Avoid:
```bash
# Bad: Manual verification only
# "It worked on my machine" before commit
```

Instead:
```bash
# Good: Automated verification script
./check_app.R
```

## Relation to Version Control

This principle particularly values the ability to:

1. Create frequent commits of runnable states
2. Easily roll back to the last known good state
3. Branch to experiment without breaking the main application

## Implementation Example

A typical workflow implementation:

```bash
# Current state: Runnable application

# 1. Make changes for Feature X
vim app.R

# 2. Verify runnability
./check_app.R

# 3A. If runnable, commit
git commit -m "Add Feature X"

# 3B. If not runnable, either fix or rollback
# Fix option:
vim app.R # Make necessary fixes
./check_app.R # Verify fixes worked
git commit -m "Add Feature X"

# Rollback option:
git reset --hard HEAD
echo "Feature X implementation failed, returning to known good state"
```

## Related Principles

- MP0038: Incremental Single-Feature Release
- MP0037: Comment Only for Temporary or Uncertain Code
- MP0014: Change Tracking
- R58: Evolution Over Replacement
