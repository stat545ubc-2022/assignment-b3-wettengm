library(shiny)
library(tidyverse)
library(tidyquant)
library(ggplot2)
library(DT)

vancouver_climate <- read_csv("vancouver_climate.csv")
vancouver_climate$Year <- as.factor(vancouver_climate$year)

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
      tabsetPanel(
        tabPanel("Moving Average", plotOutput("rainfall_time")),
        tabPanel("Trend", plotOutput("rainfall_scatter")),
        tabPanel("Boxplot", plotOutput("rainfall_boxplot"))
      ),
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
        ggplot(aes(x = LOCAL_DATE, y = mean_temp)) + 
        geom_ma(ma_fun = SMA, n = 14, linetype = 1) +
        geom_ma(ma_fun = SMA, n = 365, linetype = 2) +
        labs(x = "Year", y = "Average Temperature (C)", title = "Average Daily Temperature")
    }) 
  
  output$rainfall_scatter <- 
    renderPlot({
      filtered_data() %>%
        group_by(year) %>% summarise(mean_temperature = round(mean(mean_temp), 2)) %>%
        ggplot(aes(x = year, y = mean_temperature)) + 
        geom_point() + 
        geom_smooth(method = lm)
    })
  
  output$rainfall_boxplot <- 
    renderPlot({
      filtered_data() %>% 
        ggplot(aes(x = Year, y = mean_temp)) + 
        geom_boxplot(position = "dodge")
    })
  
  output$data_table <- 
    renderTable({
      filtered_data()
    }) #Remember the curly bracket if multiple lines!
}

shinyApp(ui = ui, server = server)















