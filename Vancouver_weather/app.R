library(shiny)
library(tidyverse)
library(tidyquant)
library(ggplot2)
library(DT)

vancouver_climate <- read_csv("vancouver_climate.csv")
vancouver_climate$Year <- as.factor(vancouver_climate$year)
vancouver_climate$Month <- as.factor(vancouver_climate$month)


ui <- fluidPage( # Order of the following arguments matters! Goes top to bottom.
  titlePanel("Vancouver Historical Climate (1986 - 2020)"),
  h5("Welcome to my shiny app! This application is exploring historical climate data for the City of Vancouver from 
     1986 through 2020. Feel free to download the .csv data used for the application here."),
  
  
  
  br(),
  sidebarLayout( #help(sidebarLayout),
    sidebarPanel(
      sliderInput("yearInput", "Year", 1986, 2020,
                  value = c(1986,2020), #value indicated start values
                  sep = "")
  
    )
    ,
    mainPanel(
      tabsetPanel(
        tabPanel("Moving Average", plotOutput("rainfall_time")),
        tabPanel("Monthly Distributions", plotOutput("rainfall_boxplot")),
        tabPanel("Boxplot", plotOutput("rainfall_box"))
      ),
      DTOutput("data_table")
    )
  ),
  a(href = "https://climate-change.canada.ca/climate-data/#/daily-climate-data",
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
  
  output$rainfall_boxplot <- 
    renderPlot({
      filtered_data() %>%
        group_by(year) %>% 
        group_by(month) %>%
        ggplot(aes(x = Month, y = mean_temp)) + 
        geom_boxplot(position = "dodge") +
        scale_x_discrete(labels=month.abb)   
    })
  
  output$rainfall_box <- 
    renderPlot({
      filtered_data() %>% 
        ggplot(aes(x = Year, y = mean_temp)) + 
        geom_boxplot(position = "dodge")
    })
  
  output$data_table <- 
    renderDT({
      filtered_data()
    }) #Remember the curly bracket if multiple lines!
}

shinyApp(ui = ui, server = server)















