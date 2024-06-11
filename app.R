library(shiny)
library(jsonlite)
library(httpuv)

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

# Define UI
ui <- fluidPage(
  tags$iframe(
    src = "www/ajax.html",
    width = "100%",
    height = "600px"
  )
)

# Define server logic
server <- function(input, output, session) {
  # Serve static files from www directory
  addResourcePath("www", "www")
}

# Custom HTTP handler
customHandler <- function(req) {
  if (req$PATH_INFO == "/calculate" && req$REQUEST_METHOD == "POST") {
    body <- req$rook.input$read()
    params <- fromJSON(rawToChar(body))
    n <- as.numeric(params$n)
    
    start_time <- Sys.time()
    result <- lucas_number(n)
    end_time <- Sys.time()
    process_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    response <- toJSON(list(result = result, process_time = process_time * 1000))
    return(list(
      status = 200L,
      headers = list(
        'Content-Type' = 'application/json',
        'Access-Control-Allow-Origin' = '*'
      ),
      body = response
    ))
  } else {
    return(list(
      status = 404L,
      headers = list('Content-Type' = 'text/plain'),
      body = "Not Found"
    ))
  }
}

# Run the application
shinyApp(
  ui = ui, 
  server = server, 
  options = list(
    port = 5000, 
    host = "0.0.0.0",
    onStart = function() {
      # Start custom HTTP server
      httpuv::startServer("0.0.0.0", 5001, list(
        call = customHandler
      ))
    }
  )
)
