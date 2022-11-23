library(shiny)
library(tidyverse)

vancouver_climate <- read_csv("vancouver_climate.csv")

ui <- fluidPage( # Order of the following arguments matters! Goes top to bottom.
  titlePanel("Vancouver Historical Climate (1986 - 2021)"),
  h5("Welcome to my shiny application!"),
  br(),
  sidebarLayout( #help(sidebarLayout),
    sidebarPanel(
      sliderInput("yearInput", "Year", 1986, 2021,
                  value = c(1986,2021), pre = "Year"), #value indicated start values
  
    )
    ,
    mainPanel(
      plotOutput("rainfall_time"), # This is the place holder for out plot
      tableOutput("data_table")
    )
  ),
  a(href = "https://weather.com/en-CA/weather/today/l/584018bec07ce9573837c14fa59da031fa6fcdeb1c3c9e3b2b27cb79ce254b5a?Goto=Redirected",
    "Link to the original data set") #Could put this anywhere!
)






server <- function(input, output) {
  
  filtered_data <- 
    reactive({ 
      vancouver_climate %>% filter(year > input$yearInput[1] &
                       year < input$yearInput[2])
    }) #use the reactive function if the table changes!
  
  output$rainfall_time <- 
    renderPlot({
      filtered_data() %>% #Have to add round brackets as it's being treated as a function
        ggplot(aes(total_rain)) + geom_histogram()
    }) #Use the curly brackets to allow multiple lines of ggplot code!
  
  output$data_table <- 
    renderTable({
      filtered_data()
    }) #Remember the curly bracket if multiple lines!
}

shinyApp(ui = ui, server = server)















