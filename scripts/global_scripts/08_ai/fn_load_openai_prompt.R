#' loadOpenAIPrompt  ----------------------------------------------------------
#' 載入集中式 OpenAI prompt 設定
#'
#' 從 YAML 檔案載入指定的 AI prompt 配置，包含 model, system_prompt, 和 user_prompt_template。
#' 支援 system_prompt 參照解析（例如：{system_prompts.product_strategist.content}）。
#' 支援巢狀路徑存取（例如："position_analysis.strategy_quadrant_analysis"）。
#'
#' @param prompt_name Character. prompt 名稱，支援點分隔的巢狀路徑（如 "position_analysis.strategy_quadrant_analysis"）
#' @param yaml_path Character. YAML 檔案路徑，預設為 global_data 中的 list_openai_prompt.yaml
#'
#' @return List 含 model, system_prompt, user_prompt_template
#' @export
#' @importFrom yaml read_yaml
#' @examples
#' # 載入策略四象限分析的 prompt (MP031: Separation of Concerns, MP032: DRY)
#' prompt_config <- load_openai_prompt("position_analysis.strategy_quadrant_analysis")
#'
#' # 使用載入的 prompt 設定 (MP051: Explicit Parameter Specification)
#' messages <- list(
#'   list(role = "system", content = prompt_config$system_prompt),
#'   list(role = "user", content = gsub("{strategy_data}", strategy_txt,
#'                                     prompt_config$user_prompt_template))
#' )
load_openai_prompt <- function(prompt_name,
                              yaml_path = NULL) {

  # ---- 路徑解析 (SO_R002: Function file prefix) ----------------------------
  if (is.null(yaml_path)) {
    yaml_path <- file.path("scripts", "global_scripts", "global_data",
                          "parameters", "scd_type1", "list_openai_prompt.yaml")
  }

  if (!file.exists(yaml_path)) {
    stop("OpenAI prompt YAML not found: ", yaml_path)
  }

  # ---- 載入 YAML (MP032: DRY Principle) ----------------------------------
  prompts <- yaml::read_yaml(yaml_path, eval.expr = FALSE)

  # ---- 處理巢狀路徑存取 (MP051: Explicit Parameter Specification) ----------
  if (grepl("\\.", prompt_name)) {
    # 支援點分隔的巢狀路徑，例如："position_analysis.strategy_quadrant_analysis"
    path_parts <- strsplit(prompt_name, "\\.")[[1]]
    prompt_config <- prompts

    for (i in seq_along(path_parts)) {
      part <- path_parts[i]
      if (is.list(prompt_config) && part %in% names(prompt_config)) {
        prompt_config <- prompt_config[[part]]
      } else {
        # 提供清楚的錯誤訊息，顯示可用的選項
        if (i == 1) {
          available_options <- paste(names(prompts), collapse = ", ")
          stop("Top-level section '", part, "' not found. Available sections: ",
               available_options)
        } else {
          parent_path <- paste(path_parts[1:(i-1)], collapse = ".")
          available_options <- paste(names(prompt_config), collapse = ", ")
          stop("Key '", part, "' not found in '", parent_path,
               "'. Available options: ", available_options)
        }
      }
    }
  } else {
    # 簡單的頂層存取
    if (!prompt_name %in% names(prompts)) {
      available_prompts <- paste(names(prompts), collapse = ", ")
      stop("Prompt '", prompt_name, "' not found in YAML. Available prompts: ",
           available_prompts)
    }
    prompt_config <- prompts[[prompt_name]]
  }

  # ---- 解析 system_prompt 參照 (MP032: DRY - reuse common prompts) --------
  if (!is.null(prompt_config$system_prompt) &&
      grepl("\\{.*\\}", prompt_config$system_prompt)) {

    # 解析參照格式：{system_prompts.product_strategist.content}
    ref_pattern <- "\\{(.+)\\}"
    ref_match <- regmatches(prompt_config$system_prompt,
                           regexpr(ref_pattern, prompt_config$system_prompt))

    if (length(ref_match) > 0) {
      ref_path <- gsub("[{}]", "", ref_match)
      path_parts <- strsplit(ref_path, "\\.")[[1]]

      # 遞迴解析參照路徑 (MP031: Separation of Concerns)
      resolved_value <- prompts
      for (part in path_parts) {
        if (is.list(resolved_value) && part %in% names(resolved_value)) {
          resolved_value <- resolved_value[[part]]
        } else {
          warning("Cannot resolve system_prompt reference: ", ref_path)
          resolved_value <- prompt_config$system_prompt  # 保持原值
          break
        }
      }
      prompt_config$system_prompt <- resolved_value
    }
  }

  # ---- 驗證必要欄位 (MP051: Explicit Parameter Specification) -------------
  required_fields <- c("model", "system_prompt", "user_prompt_template")
  missing_fields <- setdiff(required_fields, names(prompt_config))

  if (length(missing_fields) > 0) {
    stop("Missing required fields in prompt '", prompt_name, "': ",
         paste(missing_fields, collapse = ", "))
  }

  return(prompt_config)
}