# N0003.R
# GitHub Synchronization Utility Node
#
# This script implements a platform-agnostic utility for synchronizing
# global_scripts across company repositories using GitHub.
#
# Node utilities are designed to be atomic, reusable components that can be
# leveraged by multiple derivations and sequences.

#' Set up GitHub repository for global_scripts
#'
#' @param repo_name Name of the GitHub repository (e.g., "kiki830621/precision_marketing_global_scripts")
#' @param local_path Local path to initialize repository 
#' @param github_token GitHub personal access token
#' @param verbose Print detailed information
#'
#' @return TRUE if successful, FALSE otherwise
#'
setup_github_repo <- function(repo_name, 
                            local_path = "global_scripts_repo",
                            github_token = NULL,
                            verbose = TRUE) {
  if(verbose) message("Setting up GitHub repository for global_scripts...")
  
  # Check if git is installed
  git_check <- system("git --version", intern = TRUE, ignore.stderr = TRUE)
  if(length(git_check) == 0) {
    stop("Git is not installed or not available in PATH")
  }
  
  # Check if GitHub CLI is installed
  gh_check <- system("gh --version", intern = TRUE, ignore.stderr = TRUE)
  if(length(gh_check) == 0) {
    warning("GitHub CLI is not installed. Some operations may not be available.")
    has_gh_cli <- FALSE
  } else {
    has_gh_cli <- TRUE
  }
  
  # Create directory if it doesn't exist
  if(!dir.exists(local_path)) {
    dir.create(local_path, recursive = TRUE)
  }
  
  # Initialize git repository
  setwd(local_path)
  system("git init", intern = TRUE)
  
  # Create README file
  readme_content <- paste(
    "# Global Scripts\n\n",
    "This repository contains global scripts shared across all company projects.\n\n",
    "## Synchronization\n\n",
    "This repository serves as the central source of truth for global scripts.\n",
    "All company-specific repositories should use this as a submodule or subtree.\n\n",
    "## Structure\n\n",
    "The repository follows the folder structure defined in R41.\n"
  )
  writeLines(readme_content, "README.md")
  
  # Create initial commit
  system("git add README.md", intern = TRUE)
  system("git commit -m 'Initial commit: Setup global_scripts repository'", intern = TRUE)
  
  # Create repository on GitHub if GitHub CLI is available
  if(has_gh_cli) {
    if(!is.null(github_token)) {
      # Set GitHub token
      Sys.setenv(GITHUB_TOKEN = github_token)
    }
    
    # Create GitHub repository
    gh_create_cmd <- paste("gh repo create", repo_name, "--public --source=. --push")
    system(gh_create_cmd, intern = TRUE)
    
    if(verbose) message("GitHub repository created: ", repo_name)
  } else {
    # Provide instructions
    message("Please create a GitHub repository manually and push the local repository:")
    message("1. Create a new repository on GitHub: ", repo_name)
    message("2. Run the following commands in the local repository:")
    message("   git remote add origin git@github.com:", repo_name, ".git")
    message("   git push -u origin main")
  }
  
  return(TRUE)
}

#' Add global_scripts as a Git submodule to a repository
#'
#' @param repo_path Path to the repository to add the submodule to
#' @param submodule_url URL of the global_scripts repository
#' @param submodule_path Path within the repository to add the submodule
#' @param verbose Print detailed information
#'
#' @return TRUE if successful, FALSE otherwise
#'
add_global_scripts_submodule <- function(repo_path,
                                       submodule_url = "git@github.com:kiki830621/precision_marketing_global_scripts.git",
                                       submodule_path = "update_scripts/global_scripts",
                                       verbose = TRUE) {
  if(verbose) message("Adding global_scripts as a Git submodule to ", repo_path)
  
  # Check if the repository exists
  if(!dir.exists(repo_path)) {
    stop("Repository path does not exist: ", repo_path)
  }
  
  # Change to repository directory
  original_dir <- getwd()
  setwd(repo_path)
  on.exit(setwd(original_dir))
  
  tryCatch({
    # Add submodule
    submodule_cmd <- paste("git submodule add", submodule_url, submodule_path)
    system(submodule_cmd, intern = TRUE)
    
    # Commit the change
    system("git add .gitmodules", intern = TRUE)
    system(paste("git add", submodule_path), intern = TRUE)
    system("git commit -m 'Add global_scripts as a Git submodule'", intern = TRUE)
    
    if(verbose) message("Submodule added successfully to ", repo_path)
    
    return(TRUE)
  }, error = function(e) {
    message("Error adding submodule: ", e$message)
    return(FALSE)
  })
}

#' Update global_scripts submodule across all repositories
#'
#' @param repos List of repository paths to update
#' @param submodule_path Path to the submodule within each repository
#' @param verbose Print detailed information
#'
#' @return List of update results
#'
update_global_scripts_submodule <- function(repos,
                                         submodule_path = "update_scripts/global_scripts",
                                         verbose = TRUE) {
  if(verbose) message("Updating global_scripts submodule across all repositories...")
  
  results <- list()
  
  for(repo in repos) {
    if(verbose) message("Updating submodule in ", repo)
    
    # Check if repository exists
    if(!dir.exists(repo)) {
      results[[repo]] <- list(success = FALSE, message = "Repository path does not exist")
      next
    }
    
    # Change to repository directory
    original_dir <- getwd()
    setwd(repo)
    on.exit(setwd(original_dir))
    
    tryCatch({
      # Update submodule
      system("git submodule update --init --recursive", intern = TRUE)
      system("git submodule update --remote", intern = TRUE)
      
      # Commit the changes
      system(paste("git add", submodule_path), intern = TRUE)
      system("git commit -m 'Update global_scripts submodule'", intern = TRUE)
      
      results[[repo]] <- list(success = TRUE, message = "Submodule updated successfully")
    }, error = function(e) {
      results[[repo]] <- list(success = FALSE, message = paste("Error updating submodule:", e$message))
    })
  }
  
  if(verbose) {
    message("Submodule update summary:")
    for(repo in names(results)) {
      status <- if(results[[repo]]$success) "✅" else "❌"
      message(status, " ", repo, ": ", results[[repo]]$message)
    }
  }
  
  return(results)
}

#' Synchronize global_scripts using Git subtree instead of submodules
#'
#' @param repos List of repository paths to update
#' @param subtree_path Path to the subtree within each repository
#' @param remote_url URL of the global_scripts repository
#' @param remote_name Name of the remote
#' @param verbose Print detailed information
#'
#' @return List of update results
#'
sync_global_scripts_subtree <- function(repos,
                                      subtree_path = "update_scripts/global_scripts",
                                      remote_url = "git@github.com:kiki830621/precision_marketing_global_scripts.git",
                                      remote_name = "global-scripts-remote",
                                      verbose = TRUE) {
  if(verbose) message("Synchronizing global_scripts using Git subtree across all repositories...")
  
  results <- list()
  
  for(repo in repos) {
    if(verbose) message("Synchronizing subtree in ", repo)
    
    # Check if repository exists
    if(!dir.exists(repo)) {
      results[[repo]] <- list(success = FALSE, message = "Repository path does not exist")
      next
    }
    
    # Change to repository directory
    original_dir <- getwd()
    setwd(repo)
    on.exit(setwd(original_dir))
    
    tryCatch({
      # Check if remote exists, add if it doesn't
      remotes <- system("git remote", intern = TRUE)
      if(!remote_name %in% remotes) {
        system(paste("git remote add", remote_name, remote_url), intern = TRUE)
      }
      
      # Fetch from remote
      system(paste("git fetch", remote_name), intern = TRUE)
      
      # Check if subtree already exists
      if(dir.exists(subtree_path)) {
        # Pull changes using subtree
        system(paste("git subtree pull --prefix", subtree_path, remote_name, "main --squash"), intern = TRUE)
        results[[repo]] <- list(success = TRUE, message = "Subtree updated successfully")
      } else {
        # Add subtree
        system(paste("git subtree add --prefix", subtree_path, remote_name, "main --squash"), intern = TRUE)
        results[[repo]] <- list(success = TRUE, message = "Subtree added successfully")
      }
    }, error = function(e) {
      results[[repo]] <- list(success = FALSE, message = paste("Error with subtree operation:", e$message))
    })
  }
  
  if(verbose) {
    message("Subtree synchronization summary:")
    for(repo in names(results)) {
      status <- if(results[[repo]]$success) "✅" else "❌"
      message(status, " ", repo, ": ", results[[repo]]$message)
    }
  }
  
  return(results)
}

#' Create GitHub Actions workflow for automatic synchronization
#'
#' @param repo_path Path to the repository to add the workflow to
#' @param workflow_name Name of the workflow file
#' @param remote_url URL of the global_scripts repository
#' @param subtree_path Path to the subtree within the repository
#' @param schedule Cron schedule for when to run the workflow
#' @param verbose Print detailed information
#'
#' @return TRUE if successful, FALSE otherwise
#'
create_github_actions_workflow <- function(repo_path,
                                         workflow_name = "sync_global_scripts.yml",
                                         remote_url = "git@github.com:kiki830621/precision_marketing_global_scripts.git",
                                         subtree_path = "update_scripts/global_scripts",
                                         schedule = "0 0 * * *", # Daily at midnight
                                         verbose = TRUE) {
  if(verbose) message("Creating GitHub Actions workflow for automatic synchronization...")
  
  # Check if repository exists
  if(!dir.exists(repo_path)) {
    stop("Repository path does not exist: ", repo_path)
  }
  
  # Ensure workflows directory exists
  workflows_dir <- file.path(repo_path, ".github/workflows")
  if(!dir.exists(workflows_dir)) {
    dir.create(workflows_dir, recursive = TRUE)
  }
  
  # Create workflow file content
  workflow_content <- paste(
    "name: Sync Global Scripts\n\n",
    "on:\n",
    "  schedule:\n",
    "    - cron: '", schedule, "'\n",
    "  workflow_dispatch: # Allows manual triggering\n\n",
    "jobs:\n",
    "  sync-global-scripts:\n",
    "    runs-on: ubuntu-latest\n",
    "    steps:\n",
    "      - name: Checkout repository\n",
    "        uses: actions/checkout@v2\n",
    "        with:\n",
    "          fetch-depth: 0\n\n",
    "      - name: Configure Git\n",
    "        run: |\n",
    "          git config --global user.name 'GitHub Actions'\n",
    "          git config --global user.email 'actions@github.com'\n\n",
    "      - name: Add remote for global_scripts\n",
    "        run: git remote add global-scripts-remote ", remote_url, "\n\n",
    "      - name: Fetch from remote\n",
    "        run: git fetch global-scripts-remote\n\n",
    "      - name: Sync using Git subtree\n",
    "        run: |\n",
    "          if [ -d \"", subtree_path, "\" ]; then\n",
    "            git subtree pull --prefix ", subtree_path, " global-scripts-remote main --squash -m \"Update global_scripts via GitHub Actions\"\n",
    "          else\n",
    "            git subtree add --prefix ", subtree_path, " global-scripts-remote main --squash\n",
    "          fi\n\n",
    "      - name: Push changes\n",
    "        run: git push\n",
    sep = ""
  )
  
  # Write workflow file
  workflow_path <- file.path(workflows_dir, workflow_name)
  writeLines(workflow_content, workflow_path)
  
  # Add and commit the workflow file
  original_dir <- getwd()
  setwd(repo_path)
  on.exit(setwd(original_dir))
  
  tryCatch({
    system(paste("git add", file.path(".github/workflows", workflow_name)), intern = TRUE)
    system("git commit -m 'Add GitHub Actions workflow for global_scripts synchronization'", intern = TRUE)
    
    if(verbose) message("GitHub Actions workflow created successfully")
    
    return(TRUE)
  }, error = function(e) {
    message("Error creating GitHub Actions workflow: ", e$message)
    return(FALSE)
  })
}