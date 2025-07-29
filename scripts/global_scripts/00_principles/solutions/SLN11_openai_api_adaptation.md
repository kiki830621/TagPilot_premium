# SLN11: OpenAI API Adaptation Solution

## Problem Statement
OpenAI frequently updates their API with new models and parameter changes. The o4-mini model introduced a breaking change where `max_tokens` parameter is no longer supported and must be replaced with `max_completion_tokens`.

## Symptoms
- HTTP 400 Bad Request errors when calling OpenAI API
- Error message: "Unsupported parameter: 'max_tokens' is not supported with this model. Use 'max_completion_tokens' instead."
- Error message: "Unsupported value: 'temperature' does not support X with this model. Only the default (1) value is supported."

## Solution

### 1. Parameter Updates for New Models

For models like o4-mini, o3-mini, and potentially future models:
- Use `max_completion_tokens` instead of `max_tokens`
- This parameter specifically limits the AI response tokens, not the total request tokens
- Temperature parameter may be restricted - o4-mini only supports temperature = 1 (or omit it to use default)
- o4-mini may require higher token limits - if `finish_reason` is "length", increase `max_completion_tokens`

### 2. API Key Management

Store API key in `app_configs$OPENAI_API_KEY` for centralized access:
```r
gpt_key <- if (exists("app_configs") && !is.null(app_configs$OPENAI_API_KEY)) {
  app_configs$OPENAI_API_KEY
} else {
  NULL
}
```

### 3. Error Handling Best Practices

Always implement detailed error logging for API calls:
```r
if (httr2::resp_status(resp) != 200) {
  error_json <- tryCatch(
    httr2::resp_body_json(resp),
    error = function(e) NULL
  )
  warning("OpenAI API error - Status: ", httr2::resp_status(resp), 
          if (!is.null(error_json$error$message)) 
            paste0(", Message: ", error_json$error$message) else "")
}
```

### 4. Model-Specific Request Format

Example for o4-mini model:
```r
httr2::req_body_json(list(
  model = "o4-mini",
  messages = list(
    list(role = "system", content = "System prompt"),
    list(role = "user", content = "User prompt")
  ),
  # temperature = 1,  # o4-mini only supports default value 1, so we omit it
  max_completion_tokens = 500  # NOT max_tokens
))
```

Note: o4-mini has specific restrictions:
- `temperature` must be 1 (the default) or omitted entirely
- Use `max_completion_tokens` instead of `max_tokens`

### 5. Testing API Compatibility

Before implementing, test with simple curl or httr request:
```r
library(httr)
resp <- POST(
  "https://api.openai.com/v1/chat/completions",
  add_headers(
    Authorization = sprintf("Bearer %s", api_key),
    `Content-Type` = "application/json"
  ),
  body = list(
    model = "o4-mini",
    messages = list(list(role = "user", content = "Test"))
  ),
  encode = "json"
)
```

## Implementation Checklist

- [ ] Update all `max_tokens` to `max_completion_tokens` for new models
- [ ] Add model version detection if supporting multiple models
- [ ] Implement comprehensive error handling with detailed logging
- [ ] Test with minimal request before full implementation
- [ ] Document model-specific requirements in code comments

## Related Principles
- MP81: Explicit Parameter Specification
- R116: Enhanced Data Access Pattern
- MP88: Immediate Feedback (for error messages)

## Version History
- 2025-01-28: Initial documentation for o4-mini API adaptation
- 2025-01-28: Added temperature restriction (o4-mini only supports temperature = 1)
- 2025-01-28: Added token limit issue - o4-mini may need higher max_completion_tokens (1000+)