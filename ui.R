usState <<- readRDS("us_state.rds")
outcomes <<- c("heart attack", "heart failure", "pneumonia")

shinyUI(pageWithSidebar(
  headerPanel("USA hospital recommendations"),
  sidebarPanel(tabsetPanel(
    tabPanel("Application",
             selectInput("selectState", "State", choices = usState ),
             selectInput("selectOutcome", "Outcome (Treatment Type)", choices = outcomes )
    ),
    tabPanel("Instructions",
             helpText("Select your U.S. state and Outcome (medical treatment) to see the recommended hospital"),
             helpText("Data: Hospital Compare, http://hospitalcompare.hhs.gov/" )
  )
  ),
  mainPanel(
    h3('Hospital with lowest 30 day post treatment mortality'),
    textOutput('text1')
  )
) )