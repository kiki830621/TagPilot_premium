library(shiny)
library(bs4Dash)

shinyApp(
    ui = dashboardPage(
      freshTheme = create_theme(
        bs4dash_vars(
          navbar_light_color = "#bec5cb",
          navbar_light_active_color = "#FFF",
          navbar_light_hover_color = "#FFF"
        ),
        bs4dash_yiq(
          contrasted_threshold = 10,
          text_dark = "#FFF",
          text_light = "#272c30"
        ),
        bs4dash_layout(
          main_bg = "#353c42"
        ),
        bs4dash_sidebar_light(
          bg = "#272c30",
          color = "#bec5cb",
          hover_color = "#FFF",
          submenu_bg = "#272c30",
          submenu_color = "#FFF",
          submenu_hover_color = "#FFF"
        ),
        bs4dash_status(
          primary = "#5E81AC", danger = "#BF616A", light = "#272c30"
        ),
        bs4dash_color(
          gray_900 = "#FFF", white = "#272c30"
        )
      ),
      options = NULL,
      header = dashboardHeader(
        title = dashboardBrand(
          title = "My dashboard",
          color = "primary",
          href = "https://adminlte.io/themes/v3",
          image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png"
        )
      ),
      sidebar = dashboardSidebar(),
      body = dashboardBody(
        box(status = "danger"),
        box(status = "primary"),
        box(status = "orange")
      ),
      controlbar = dashboardControlbar(),
      title = "DashboardPage"
    ),
    server = function(input, output) { }
  )