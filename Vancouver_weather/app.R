library(shiny)
library(tidyverse)

bcl <- read_csv("bcl-data.csv")

ui <- fluidPage( # Order of the following arguments matters! Goes top to bottom.
  titlePanel("BC Liquor Store Data"),
  h5("Welcome to my shiny app!"),
  br(),
  sidebarLayout( #help(sidebarLayout),
    sidebarPanel(
      sliderInput("priceInput", "Price", 0, 100,
                  value = c(25,40), pre = "$"), #value indicated start values
      radioButtons("typeInput", "Type",
                   choices = c("BEER", "REFRESHMENT",
                               "SPIRITS", "WINE")) 
    )
    ,
    mainPanel(
      plotOutput("alcohol_hist"), # This is the place holder for out plot
      tableOutput("data_table")
    )
  ),
  a(href = "https://weather.com/en-CA/weather/today/l/584018bec07ce9573837c14fa59da031fa6fcdeb1c3c9e3b2b27cb79ce254b5a?Goto=Redirected",
    "Link to the original data set") #Could put this anywhere!
)






server <- function(input, output) {
  
  filtered_data <- 
    reactive({ 
      bcl %>% filter(Price > input$priceInput[1] &
                       Price < input$priceInput[2] &
                       Type == input$typeInput)
    }) #use the reactive function if the table changes!
  
  output$alcohol_hist <- 
    renderPlot({
      filtered_data() %>% #Have to add round brackets as it's being treated as a function
        ggplot(aes(Alcohol_Content)) + geom_histogram()
    }) #Use the curly brackets to allow multiple lines of ggplot code!
  
  output$data_table <- 
    renderTable({
      filtered_data()
    }) #Remember the curly bracket if multiple lines!
}

shinyApp(ui = ui, server = server)















