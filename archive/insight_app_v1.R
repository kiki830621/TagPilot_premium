# ============================================================================
#  Modularized Shiny App                                                     #
#  ───────────────────────────────────────────────────────────────────────── #
#  This single file contains 4 logical parts. Save each part as **its own** #
#  *.R* file in the same folder and keep the folder on the Shiny search‑path.#
#                                                                            #
#  1. module_login.R   – Login + Register                                    #
#  2. module_upload.R  – Data upload / preview                               #
#  3. module_score.R   – Attribute generation & scoring                      #
#  4. app.R            – Main app that wires everything together             #
#                                                                            #
#  After copying the chunks to their files, run `source("app.R")` (or run   #
#  app.R inside RStudio) to launch.                                          #
# ============================================================================



################################################################################
# 4⃣  app.R – Main wrapper -----------------------------------------------------
################################################################################
# ── Packages -----------------------------------------------------------------
library(shiny)
library(shinyjs)
library(DBI)
library(RSQLite)
library(bcrypt)
library(readxl)
library(jsonlite)
library(httr)
library(DT)
library(dplyr)
library(GGally)
library(tidyverse)
library(stringr)
library(bslib)

library(dotenv)
library(plotly)
library(DT)
library(DBI)
library(duckdb)
library(httr2)
library(future)
library(furrr)
library(markdown) 
library(stringr)
library(shinycssloaders) # withSpinner()
plan(multisession, workers = parallel::detectCores() - 1)  # Windows 也適用
options(future.rng.onMisuse = "ignore")  # 關閉隨機種子警告

dotenv::load_dot_env(file = ".env")

# -----------------------------------------------------------------------------
show <- shinyjs::show
hide <- shinyjs::hide

# ── DB helper shared by all modules ---------------------------------------
get_con <- function() {
  db <- dbConnect(RSQLite::SQLite(), "users.sqlite")
  dbExecute(db, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT UNIQUE, hash TEXT, role TEXT DEFAULT 'user', login_count INTEGER DEFAULT 0)")
  dbExecute(db, "CREATE TABLE IF NOT EXISTS rawdata (id INTEGER PRIMARY KEY, user_id INTEGER, uploaded_at TEXT, json TEXT)")
  dbExecute(db, "CREATE TABLE IF NOT EXISTS processed_data (id INTEGER PRIMARY KEY, user_id INTEGER, processed_at TEXT, json TEXT)")
  db
}

# ── Theme ---------------------------------------------------------------
app_theme <- bslib::bs_theme(preset = "cerulean")

# ── Source modules -------------------------------------------------------
source("module_login.R")
source("module_upload.R")
source("module_score.R")
source("module_wo_b.R")
icons_path <- if (dir.exists("www/icons")) "www/icons" else "www"
addResourcePath("icons", icons_path)  # <img src="icons/icon.png">

icon_bar <- div(id = "icon_bar", img(src = "icons/icon.png", height = "60px", id = "icon_main"), uiOutput("partner_icons"))

# … (module_wo_b.R 以及您已有的其他分析模組)…

# ── UI ------------------------------------------------------------------
ui <- fluidPage(
  theme = app_theme,
  useShinyjs(),
  # Icon bar – stays here so modules do not duplicate it
  tags$head(tags$style("#icon_bar { display:flex; gap:12px; align-items:center; margin-bottom:16px; } #icon_bar img { max-height:60px; }")),
  div(id = "icon_bar", img(src = "icons/icon.png", height = "60px", id = "icon_main")),
  
  # Login module ---------------------------------------------------------
  loginModuleUI("login"),
  
  # Main wizard pages – will be toggled on login -------------------------
  hidden(div(id = "wizard_pages",
             # Step 1
             uploadModuleUI("upload"),
             # Step 2
             scoreModuleUI("score"),
             # Step 3 (your existing positioning / analysis UI) …
  ))
)

# ── Server ---------------------------------------------------------------
server <- function(input, output, session) {
  con <- get_con()
  onStop(function() dbDisconnect(con))
  
  # ---- LOGIN -----------------------------------------------------------
  login    <- loginModuleServer("login", con)
  
  # ---- Wizard visibility ----------------------------------------------
  observe({
    if (login$logged_in()) {
      shinyjs::show("wizard_pages")
    } else {
      shinyjs::hide("wizard_pages")
    }
  })
  
  # ---- STEP 1: Upload --------------------------------------------------
  upload   <- uploadModuleServer("upload",  con, login$user_info)
  
  # move when user clicks "下一步" in upload module
  observeEvent(upload$proceed_step(), {
    shinyjs::hide("upload-step1_box")   # hide Step1 UI (namespaced id!)
    shinyjs::show("score-step2_box")    # show Step2 UI
  })
  
  # ---- STEP 2: Scoring -------------------------------------------------
  score    <- scoreModuleServer("score", con, login$user_info, upload$data)
  
  observeEvent(score$proceed_step(), {
    shinyjs::hide("score-step2_box")
    # show your Step 3 positioning UI …
  })
  
  # ---- LOGOUT ----------------------------------------------------------
  observeEvent(input$logout, {
    login$logout()
    shinyjs::hide("wizard_pages")
  })
}

# ── Run -----------------------------------------------------------------
shinyApp(ui, server)
