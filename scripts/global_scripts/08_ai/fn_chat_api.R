#LOCK FILE
#
# fn_chat_api.R
#
# Following principles:
# - R21: One Function One File
# - R69: Function File Naming (fn_ prefix)
# - MP47: Functional Programming
# - MP81: Explicit Parameter Specification
#
# Function to interact with OpenAI Chat API
# -----------------------------------------------------------------------------

#' Call OpenAI Chat API
#' @param messages List. List of message objects with 'role' and 'content' fields.
#' @param api_key Character string. OpenAI API key (defaults to OPENAI_API_KEY env var).
#' @param model Character string. Model to use (defaults to "gpt-4o-mini").
#' @param api_url Character string. API endpoint URL.
#' @param timeout_sec Numeric. Request timeout in seconds (defaults to 60).
#' @return Character string. The model's response content.
#' @examples
#' sys <- list(role = "system", content = "You are a helpful assistant.")
#' usr <- list(role = "user", content = "Hello!")
#' response <- fn_chat_api(list(sys, usr))
fn_chat_api <- function(messages,
                       api_key = Sys.getenv("OPENAI_API_KEY"),
                       model = "gpt-4o-mini",
                       api_url = "https://api.openai.com/v1/chat/completions",
                       timeout_sec = 60) {
  
  # Check for API key
  if (!nzchar(api_key)) {
    stop("🔑 OPENAI_API_KEY is missing. Please set it in environment variables or pass it directly.")
  }
  
  # Validate API key format
  if (!grepl("^sk-", api_key)) {
    warning("OpenAI API key format appears incorrect. Should start with 'sk-'")
  }
  
  # Check if httr2 is available
  if (!requireNamespace("httr2", quietly = TRUE)) {
    stop("Package 'httr2' is required for API calls. Please install it.")
  }
  
  # Check if jsonlite is available for JSON handling
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package 'jsonlite' is required for JSON handling. Please install it.")
  }
  
  # Prepare request body - different models need different parameters
  body <- list(
    model = model,
    messages = messages
  )
  
  # Add model-specific parameters
  if (grepl("^o3", model)) {
    # o3 models might not support temperature/max_tokens or have different limits
    # Add only supported parameters for o3
    body$max_completion_tokens <- 4000  # o3 uses max_completion_tokens instead
  } else if (grepl("^o1", model)) {
    # o1 models don't support temperature and max_tokens
    # They use max_completion_tokens instead
    body$max_completion_tokens <- 2000
  } else {
    # Traditional models (gpt-4, gpt-3.5, etc.)
    body$temperature <- 0.3
    body$max_tokens <- 1024
  }
  
  # Create and perform request
  req <- httr2::request(api_url) |>
    httr2::req_auth_bearer_token(api_key) |>
    httr2::req_headers(`Content-Type` = "application/json") |>
    httr2::req_body_json(body) |>
    httr2::req_timeout(timeout_sec)
  
  # Execute request
  resp <- httr2::req_perform(req)
  
  # Handle errors with detailed information
  if (httr2::resp_status(resp) >= 400) {
    err_text <- httr2::resp_body_string(resp)
    status_code <- httr2::resp_status(resp)
    
    # Try to parse JSON error for more details
    tryCatch({
      err_json <- jsonlite::fromJSON(err_text)
      if (!is.null(err_json$error$message)) {
        err_msg <- err_json$error$message
      } else {
        err_msg <- err_text
      }
    }, error = function(e) {
      err_msg <- err_text
    })
    
    stop(sprintf("Chat API error %s for model '%s':\n%s", status_code, model, err_msg))
  }
  
  # Extract response content
  content <- httr2::resp_body_json(resp)
  response_text <- content$choices[[1]]$message$content
  
  # Return trimmed response
  return(trimws(response_text))
}