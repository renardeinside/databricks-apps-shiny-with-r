library(shiny)
library(httr2)
library(jsonlite)
library(ggplot2)
library(plotly)
library(shinycssloaders)

options(spinner.color = "#FF3621")

query_databricks <- function(token, statement, warehouse_id, host) {
  resp <- request(paste0("https://", host, "/api/2.0/sql/statements/")) |>
    req_auth_bearer_token(token) |>
    req_body_json(list(
      warehouse_id = warehouse_id,
      statement = statement,
      wait_timeout = "30s",
      disposition = "INLINE"
    )) |>
    req_perform()

  result <- resp_body_json(resp)

  if (!is.null(result$status) && result$status$state == "FAILED") {
    stop(result$status$error$message %||% "Query failed")
  }

  cols <- result$manifest$schema$columns
  col_names <- vapply(cols, \(c) c$name, character(1))
  data_arrays <- result$result$data_array

  df <- as.data.frame(
    do.call(rbind, data_arrays),
    stringsAsFactors = FALSE
  )
  names(df) <- col_names
  df
}

get_current_user <- function(token, host) {
  resp <- request(paste0("https://", host, "/api/2.0/preview/scim/v2/Me")) |>
    req_auth_bearer_token(token) |>
    req_perform()

  user <- resp_body_json(resp)
  user$displayName %||% user$userName %||% "Unknown user"
}

ui <- fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=DM+Mono:wght@400;500&family=DM+Sans:wght@400;500;700&display=swap"
    ),
    tags$style(HTML("
      body {
        font-family: 'DM Sans', sans-serif;
        background-color: #F9F7F4;
        margin: 0;
      }
      .container-fluid {
        padding: 0;
      }
      .title-bar {
        background-color: #1B3139;
        color: #FFFFFF;
        padding: 16px 24px;
        font-size: 22px;
        font-weight: 700;
        margin-bottom: 24px;
      }
      .content-area {
        padding: 0 24px;
      }
      .data-table {
        max-height: 50vh;
        overflow-y: auto;
        border: 1px solid #E0DEDA;
        border-radius: 8px;
        background: #FFFFFF;
        padding: 8px;
      }
      .data-table table {
        font-family: 'DM Mono', monospace;
        font-size: 12px;
        width: 100%;
      }
      .data-table th {
        position: sticky;
        top: 0;
        background: #1B3139;
        color: #FFFFFF;
        padding: 8px 12px;
        font-weight: 500;
      }
      .data-table td {
        padding: 6px 12px;
        border-bottom: 1px solid #F0EDEA;
      }
      .chart-container {
        background: #FFFFFF;
        border: 1px solid #E0DEDA;
        border-radius: 8px;
        padding: 16px;
      }
      .user-badge {
        position: fixed;
        bottom: 16px;
        right: 16px;
        background-color: #1B3139;
        color: #FFFFFF;
        font-family: 'DM Sans', sans-serif;
        font-size: 13px;
        padding: 8px 16px;
        border-radius: 20px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        z-index: 9999;
      }
    "))
  ),

  div(class = "title-bar", "NYC Taxi Trips \u2014 Databricks SQL"),

  div(class = "content-area", fluidRow(
    column(6,
      div(class = "data-table",
        withSpinner(tableOutput("trips_table"), type = 6)
      )
    ),
    column(6,
      div(class = "chart-container",
        withSpinner(plotly::plotlyOutput("trip_chart", height = "50vh"), type = 6)
      )
    )
  )),

  uiOutput("user_badge")
)

server <- function(input, output, session) {
  token <- session$request$HTTP_X_FORWARDED_ACCESS_TOKEN
  warehouse_id <- Sys.getenv("SQL_WAREHOUSE_ID")
  host <- Sys.getenv("DATABRICKS_HOST")

  trips <- reactive({
    req(token)
    query_databricks(
      token = token,
      statement = "SELECT * FROM samples.nyctaxi.trips LIMIT 100",
      warehouse_id = warehouse_id,
      host = host
    )
  })

  output$trips_table <- renderTable({
    trips()
  })

  output$trip_chart <- plotly::renderPlotly({
    df <- trips()
    df$trip_distance <- as.numeric(df$trip_distance)

    p <- ggplot(df, aes(x = trip_distance)) +
      geom_histogram(binwidth = 1, fill = "#FF3621", color = "#FFFFFF", linewidth = 0.3) +
      labs(
        title = "Trip Distance Distribution",
        x = "Distance (miles)",
        y = "Count"
      ) +
      theme_minimal(base_family = "DM Mono") +
      theme(
        plot.title = element_text(family = "DM Sans", face = "bold", size = 16),
        panel.grid.minor = element_blank()
      )

    ggplotly(p) |> layout(font = list(family = "DM Mono"))
  })

  output$user_badge <- renderUI({
    req(token)
    username <- tryCatch(
      get_current_user(token, host),
      error = function(e) NULL
    )
    if (!is.null(username)) {
      div(class = "user-badge", paste("\U0001F464", username))
    }
  })
}

port <- as.integer(Sys.getenv("DATABRICKS_APP_PORT", "8080"))
shinyApp(ui, server, options = list(host = "0.0.0.0", port = port))
