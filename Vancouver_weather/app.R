library(shiny)
library(tidyverse)
library(tidyquant)
library(ggplot2)
library(DT)


vancouver_climate <- read_csv("vancouver_climate.csv")
# Creating a factor variable for month and year as some of the plots need it instead of the continuous version.
# Still keeping continuous variables.
vancouver_climate$Year <- as.factor(vancouver_climate$year)
vancouver_climate$Month <- as.factor(vancouver_climate$month)


ui <- fluidPage( # Order of the following arguments matters. Goes top to bottom.
  titlePanel("Vancouver Historical Climate (1986 - 2020)"),
  
  tags$div(
    "Welcome to my shiny app! This application is exploring historical climate data for the City of Vancouver from 
     1986 through 2020. The data was downloaded from the",
    tags$a(href = "https://climate-change.canada.ca/climate-data/#/daily-climate-data",
           "Canadian Centre for Climate Services.")
  ),

  br(),
  # Allowing the user to select input years for the plots. 
  # Can subset for different years to see differences in trends for various time periods. 
  sidebarLayout( #help(sidebarLayout),
    sidebarPanel(
      sliderInput("yearInput", "Year", 1986, 2020,
                  value = c(1986,2020), #value indicated start values
                  sep = "")
  
    )
    ,
    # The tabs pannel helps seperate the plots for easier navigation. 
    # This will be especially useful when I add in other variables for assignment b04 to keep the app organized. 
    mainPanel(
      tabsetPanel(
        tabPanel("Moving Average", plotOutput("rainfall_time")),
        tabPanel("Yearly Patterns", plotOutput("yearly_temperature")),
        tabPanel("Monthly Distributions", plotOutput("rainfall_boxplot")),
      ),
      DTOutput("data_table")
    )
  )
)






server <- function(input, output) {
  
  filtered_data <- 
    reactive({ 
      vancouver_climate %>% filter(year >= input$yearInput[1] &
                       year <= input$yearInput[2])
    }) #use the reactive function if the table changes!
  # Time series plot with moving averages visualizes the seasonality in temperature but also potential long-term trends.
  output$rainfall_time <- 
    renderPlot({
      filtered_data() %>% #Have to add round brackets as it's being treated as a function
        ggplot(aes(x = LOCAL_DATE, y = mean_temp)) + 
        geom_ma(ma_fun = SMA, n = 30, linetype = 1, aes(color = 'Monthly')) +
        geom_ma(ma_fun = SMA, n = 365, linetype = 1, aes(color = 'Yearly')) +
        labs(x = "Year" , y = "Temperature (C)", title = "Average Air Temperature") +
        scale_color_manual(name = 'Moving average',
                           breaks = c('Monthly', 'Yearly'),
                           values = c('Monthly'='blue', 'Yearly'='red')
                           )
    }) 
  
  # Monthly average temperature separated by year is a way to distinguish temperature patterns/differences between years (treating them as independent). 
  output$yearly_temperature <-
    renderPlot({
      filtered_data() %>%
        group_by(Year, Month) %>%
        summarise(Mean_temp = mean(mean_temp)) %>%
        ggplot(aes(x=Month, y=Mean_temp, group = Year, colour = Year)) + 
        geom_line() + 
        scale_x_discrete(labels=month.abb) +
        labs(y= "Temperature (C)", x = "Month")
    })
  
  # side-by-side box plots differentiates the pattern and distribution between the months of the year.
  # Helpful to see if certain months are prone to more extreme temperature patterns. 
  output$rainfall_boxplot <- 
    renderPlot({
      filtered_data() %>%
        group_by(Year) %>% 
        group_by(Month) %>%
        ggplot(aes(x = Month, y = mean_temp)) + 
        geom_boxplot(position = "dodge") +
        scale_x_discrete(labels=month.abb) +
        labs(x = "Month", y = "Temperature (C)", title = "Monthly Temperature Distribution")
    })
  
  # The data should be easily accessible and having a snippet shows the user how the data is formatted for easier interpretation of plots. 
  # Providing the data table also is being more transparent with analysis process.
  output$data_table <- 
    renderDT({
      filtered_data()
    }) #Remember the curly bracket if multiple lines!
}

shinyApp(ui = ui, server = server)















