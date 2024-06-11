library(shiny)

# Function to calculate Lucas number
lucas_number <- function(n) {
  if (n == 0) return(2)
  if (n == 1) return(1)
  a <- 2
  b <- 1
  for (i in 2:n) {
    c <- a + b
    a <- b
    b <- c
  }
  return(b)
}

# UI definition
ui <- fluidPage(
  tags$iframe(
    src = "www/ajax.html",
    width = "100%",
    height = "600px"
  )
)

# Server logic
server <- function(input, output, session) {
  # Endpoint to handle calculation request
  session$onFlushed(function() {
    addResourcePath("www", "www")
  }, once = TRUE)
  
  observe({
    req <- input$n
    session$sendCustomMessage("result", list(result = "waiting for input"))
  })
  
  # Handle POST request from AJAX
  shinyServer(function(input, output, session) {
    observe({
      query <- parseQueryString(session$clientData$url_search)
      if (!is.null(query$n)) {
        n <- as.numeric(query$n)
        if (!is.na(n)) {
          start_time <- Sys.time()
          result <- lucas_number(n)
          end_time <- Sys.time()
          process_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
          session$sendCustomMessage("result", list(result = result, process_time = process_time))
        }
      }
    })
  })
  
  observeEvent(input$calculate, {
    start_time <- Sys.time()
    n <- as.numeric(input$number)
    result <- lucas_number(n)
    end_time <- Sys.time()
    process_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    output$result <- renderText({
      paste("Lucas Number L", n, " = ", result, sep = "")
    })
    output$time <- renderText({
      paste("Time: ", round(process_time, 3), " sec", sep = "")
    })
  })
}

# Run the application
shinyApp(ui, server, options = list(port = 5000, host = "0.0.0.0"))
