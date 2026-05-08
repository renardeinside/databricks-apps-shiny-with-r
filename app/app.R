library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Sample R Shiny App on Databricks"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Dataset:", choices = c("mtcars", "iris")),
      conditionalPanel(
        condition = "input.dataset == 'mtcars'",
        selectInput("x_var_mtcars", "X Variable:", choices = names(mtcars), selected = "cyl")
      ),
      conditionalPanel(
        condition = "input.dataset == 'iris'",
        selectInput("x_var_iris", "X Variable:", choices = names(iris), selected = "Species")
      )
    ),
    mainPanel(
      plotOutput("barPlot"),
      tableOutput("dataTable")
    )
  )
)

server <- function(input, output) {
  data_reactive <- reactive({
    get(input$dataset)
  })

  x_var <- reactive({
    if (input$dataset == "mtcars") input$x_var_mtcars else input$x_var_iris
  })

  output$barPlot <- renderPlot({
    df <- data_reactive()
    xv <- x_var()
    ggplot(df, aes(x = factor(.data[[xv]]))) +
      geom_bar(fill = "#2c3e50") +
      labs(x = xv, y = "Count", title = paste("Bar chart of", xv)) +
      theme_minimal()
  })

  output$dataTable <- renderTable({
    head(data_reactive(), 10)
  })
}

port <- as.integer(Sys.getenv("DATABRICKS_APP_PORT", "8080"))
shinyApp(ui, server, options = list(host = "0.0.0.0", port = port))
