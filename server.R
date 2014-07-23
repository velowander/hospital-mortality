source("hospital-mortality.R")
import.tables()

shinyServer(
  function(input, output) {
    output$text1 <- renderText({
      rankhospital(input$selectState, input$selectOutcome)
    })
  }
)
