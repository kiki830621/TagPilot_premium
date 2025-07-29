---
id: "R08"
title: "Global Scripts Synchronization"
type: "rule"
date_created: "2025-04-02"
author: "Claude"
implements:
  - "MP14": "Change Tracking Principle"
related_to:
  - "P08": "Deployment Patterns"
  - "R06": "Temporary File Handling"
---

# Global Scripts Synchronization Rule

This rule implements the Change Tracking Principle (MP14) by establishing specific requirements for synchronizing changes to the global_scripts repository.

## Core Requirement

All changes to the global_scripts repository must be committed, pulled, and pushed immediately after completion to ensure continuous synchronization across all environments.

## Synchronization Protocol

### 1. Immediate Synchronization Requirement

When working with files in the global_scripts repository:

1. **Commit Immediately**: After making changes to any file in global_scripts, commit those changes immediately
2. **Pull Before Pushing**: Always pull from the remote repository before pushing to avoid conflicts
3. **Push Without Delay**: Push committed changes to the remote repository immediately after committing

### 2. Commit Workflow

Follow this workflow for all global_scripts changes:

```bash
# 1. Navigate to the global_scripts directory
cd /path/to/global_scripts

# 2. Check current status
git status

# 3. Add changed files
git add [changed files]  # Use specific files rather than git add . when possible

# 4. Commit with descriptive message
git commit -m "Descriptive message about changes"

# 5. Pull latest changes from remote
git pull

# 6. Resolve any conflicts if they occur
# (If conflicts occur, resolve them, then commit the resolution)

# 7. Push changes to remote
git push
```

### 3. Commit Message Requirements

All commit messages must:

1. **Be Descriptive**: Clearly explain what was changed
2. **Reference Principles**: Reference relevant principles (MP/P/R) when applicable
3. **Explain Purpose**: Explain the purpose of the change
4. **Include Context**: Provide context for why the change was needed

Example format:
```
[MP/P/R Reference] Brief description of change

Detailed explanation of what was changed and why.
Additional context or considerations if needed.
```

### 4. Conflict Resolution

If conflicts occur during pull:

1. **Review Carefully**: Examine both versions of the conflicting changes
2. **Preserve Intent**: Ensure the resolution preserves the intent of both changes
3. **Test Thoroughly**: Test the resolution to ensure it works correctly
4. **Document Resolution**: Include details of the conflict resolution in the commit message

## Exception Handling

### 1. Permissible Exceptions

Exceptions to immediate synchronization are permitted only in the following circumstances:

1. **Network Unavailability**: When remote repository is inaccessible due to network issues
2. **Related Changes in Progress**: When multiple related files must be modified together for functionality
3. **Emergency Hotfixes**: When immediate changes are needed to restore system functionality

### 2. Exception Documentation

When an exception occurs:

1. **Document Reason**: Record why immediate synchronization was not possible
2. **Set Time Limit**: Establish a definite time by which synchronization will occur
3. **Notify Team**: Inform team members about unsynchronized changes
4. **Synchronize ASAP**: Complete synchronization at earliest opportunity

### 3. Exception Recovery

After an exception:

1. **Commit with Context**: Include context about the delayed synchronization in commit message
2. **Pull with Extra Care**: Be especially careful when pulling to avoid losing local changes
3. **Test Thoroughly**: Test more extensively after delayed synchronization

## Implementation Guidelines

### 1. Git Configuration

Configure git locally to streamline this workflow:

```bash
# Set up git identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set up pull to use rebase by default
git config --global pull.rebase true

# Set up aliases for common operations
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.br branch
git config --global alias.sync '!git pull && git push'
```

### 2. Pre-commit Checks

Before committing, always verify:

1. **Intended Changes Only**: Only intended files are staged for commit
2. **No Sensitive Data**: No credentials, API keys, or sensitive information is included
3. **No Temporary Files**: No temporary or log files are being committed
4. **No Broken Code**: Code is in a functional state

### 3. Tools and Integrations

Use tools to simplify compliance with this rule:

1. **Git Hooks**: Set up pre-commit and pre-push hooks for automated checks
2. **IDE Integration**: Configure your IDE to highlight uncommitted changes
3. **Reminder Scripts**: Implement reminder scripts to check for uncommitted changes

## Benefits of Immediate Synchronization

1. **Minimal Conflicts**: Frequent synchronization reduces merge conflicts
2. **Current Codebase**: Team always works with the most recent code
3. **Disaster Recovery**: Critical code is backed up in multiple locations
4. **Transparency**: Changes are visible to all team members immediately
5. **Reduced Integration Issues**: Smaller, frequent changes integrate more smoothly

## Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| Forgetting to push after commit | Use `git sync` alias or set up a post-commit hook |
| Committing incomplete changes | Use `git stash` for work in progress |
| Pushing changes that break functionality | Test before committing and pushing |
| Merge conflicts during pull | Pull frequently to minimize conflict size |
| Large changes that can't be committed at once | Break into smaller, logical commits |

## Relationship to Other Rules and Principles

This rule directly implements:

1. **Change Tracking Principle (MP14)**: Ensures changes are tracked and recoverable
2. **Deployment Patterns (P08)**: Affects how changed code is deployed to environments
3. **Temporary File Handling (R06)**: Ensures temporary files are handled correctly in version control

## Example Application

### Single File Update

When updating a function in `/global_scripts/02_db_utils/fn_dbConnect.R`:

```bash
# Make changes to fn_dbConnect.R

# Synchronize changes
cd /path/to/global_scripts
git status
git add 02_db_utils/fn_dbConnect.R
git commit -m "[MP14] Update connection timeout handling in database connector

Increased default timeout from 30s to 60s to accommodate slower network conditions.
Relates to issue #42 reported by customer service team."
git pull
git push
```

### Multiple Related File Updates

When updating both a function and its documentation:

```bash
# Make changes to multiple files

# Synchronize changes
cd /path/to/global_scripts
git status
git add 02_db_utils/fn_dbConnect.R 02_db_utils/README.md
git commit -m "[MP14, R02] Update database connector and documentation

- Increased timeout parameter default from 30s to 60s
- Added documentation for new retry parameter
- Updated examples in README

These changes address the connection stability issues in satellite offices."
git pull
git push
```

## Conclusion

By requiring immediate synchronization of changes to the global_scripts repository, this rule ensures that the system maintains a current, consistent, and recoverable codebase at all times. This implementation of the Change Tracking Principle (MP14) reduces conflicts, improves collaboration, and ensures that critical code is always backed up across multiple environments.
