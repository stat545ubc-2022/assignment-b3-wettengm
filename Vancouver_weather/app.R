library(shiny)
library(tidyverse)
library(tidyquant)
library(ggplot2)
library(DT)
library(shinythemes)


vancouver_climate <- read_csv("vancouver_climate.csv")
# Creating a factor variable for month and year as some of the plots need it instead of the continuous version.
# Still keeping continuous variables.
vancouver_climate$Year <- as.factor(vancouver_climate$year)
vancouver_climate$Month <- as.factor(vancouver_climate$month)
vancouver_climate <- rename(vancouver_climate, "Date" = LOCAL_DATE)
vancouver_climate <- rename(vancouver_climate, "Temperature" = mean_temp)
vancouver_climate <- rename(vancouver_climate, "Rainfall" = total_rain)
vancouver_climate <- rename(vancouver_climate, "Snowfall" = total_snow)
vancouver_climate <- vancouver_climate[ , c(1,2,3,4,5,9,10,11,12)]



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ui <- navbarPage("Vancouver Historical Climate (1986 - 2020)", theme = shinytheme("flatly"),
  tabPanel("Temperature",
           h4("Welcome to my shiny app! This application is exploring historical climate data for the City of Vancouver from 
     1986 through 2020. The data was downloaded from the",
              tags$a(href = "https://climate-change.canada.ca/climate-data/#/daily-climate-data",
                     "Canadian Centre for Climate Services.")
           ),
           
           br(),
           # Allowing the user to select input years for the plots. 
           # Can subset for different years to see differences in trends for various time periods. 
           sidebarLayout( #help(sidebarLayout),
             sidebarPanel(
               img(src = "Vancouver.jpg", height = 205, width = 410),
               br(),
               
               sliderInput("yearInput", "Year", 1986, 2020,
                           value = c(1986,2020), #value indicated start values
                           sep = "")
             ),
             # The tabs panel helps separate the plots for easier navigation. 
             # This will be especially useful when I add in other variables for assignment b04 to keep the app organized. 
             mainPanel(
               h4("Temperature"),
               tabsetPanel(
                 tabPanel("Moving Average", plotOutput("temperature_time")),
                 tabPanel("Yearly Patterns", plotOutput("yearly_temperature")),
                 tabPanel("Monthly Distributions", plotOutput("temperature_boxplot")),
                        )
                      )
                    )
    ),
  
  tabPanel("Rainfall",
           # Allowing the user to select input years for the plots. 
           # Can subset for different years to see differences in trends for various time periods. 
           sidebarLayout( #help(sidebarLayout),
             sidebarPanel(
               img(src = "Vancouver.jpg", height = 205, width = 410),
               br(),
               
               sliderInput("yearInput2", "Year", 1986, 2020,
                           value = c(1986,2020), #value indicated start values
                           sep = "")
             ),
             # The tabs panel helps separate the plots for easier navigation. 
             # This will be especially useful when I add in other variables for assignment b04 to keep the app organized. 
             mainPanel(
               h4("Rainfall"),
               tabsetPanel(
                 tabPanel("Moving Average", plotOutput("rainfall_time")),
                 tabPanel("Yearly Patterns", plotOutput("yearly_rainfall")),
                 tabPanel("Monthly Distributions", plotOutput("rainfall_boxplot")),
               )
             )
           )
  ),
  
  tabPanel("Data",
           sidebarLayout(
             sidebarPanel(
               img(src = "Vancouver.jpg", height = 205, width = 410),
               br(),
               
               sliderInput("yearInput1", "Year", 1986, 2020,
                           value = c(1986,2020), #value indicated start values
                           sep = ""),
               tags$div("Download the filtered data here:"),
               downloadButton("downloadData1", "Download Data"),
               tags$div("Download the complete data file here:"),
               downloadButton("downloadData", "Download Data")
             ),
             mainPanel(
               DTOutput("data_table1")  
                    )
                  )
                )
  
  
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

server <- function(input, output) {
  
# This data file is for the temperature plots
  filtered_data <- 
    reactive({ 
      vancouver_climate %>% filter(year >= input$yearInput[1] &
                       year <= input$yearInput[2])
    }) 
  
# This data file is for the rainfall plots
  filtered_data2 <- 
    reactive({ 
      vancouver_climate %>% filter(year >= input$yearInput2[1] &
                                     year <= input$yearInput2[2])
    }) 
  
# This data file is for the final data table
  filtered_data1 <- 
    reactive({ 
      vancouver_climate %>% filter(year >= input$yearInput1[1] &
                                     year <= input$yearInput1[2])
    })
  # This download button is for the yearly filtered data
  output$downloadData1 <- downloadHandler(
    filename = function() {
      paste("Vancouver_Climate", ".csv", sep="")
    },
    content = function(file) {
      write.csv(filtered_data1(), file)
    }
  )
  # This download button is for the raw data file
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("Vancouver_Climate", ".csv", sep="")
    },
    content = function(file) {
      write.csv(vancouver_climate, file)
    }
  )
  
  
  

  # Time series plot with moving averages visualizes the seasonality of environmental variables but also potential long-term trends.
  output$temperature_time <- 
    renderPlot({
      filtered_data() %>% 
        ggplot(aes(x = Date, y = Temperature)) + 
        geom_ma(ma_fun = SMA, n = 30, linetype = 1, aes(color = 'Monthly')) +
        geom_ma(ma_fun = SMA, n = 365, linetype = 1, aes(color = 'Yearly')) +
        labs(x = "Year" , y = "Temperature (C)", title = "Average Air Temperature") +
        scale_color_manual(name = 'Moving average',
                           breaks = c('Monthly', 'Yearly'),
                           values = c('Monthly'='black', 'Yearly'='red')
                           )
    }) 
  output$rainfall_time <- 
    renderPlot({
      filtered_data2() %>% 
        ggplot(aes(x = Date, y = Rainfall)) + 
        geom_ma(ma_fun = SMA, n = 30, linetype = 1, aes(color = 'Monthly')) +
        geom_ma(ma_fun = SMA, n = 365, linetype = 1, aes(color = 'Yearly')) +
        labs(x = "Year" , y = "Rainfall (mm)", title = "Average Rainfall") +
        scale_color_manual(name = 'Moving average',
                           breaks = c('Monthly', 'Yearly'),
                           values = c('Monthly'='black', 'Yearly'='red')
        )
    })
  
  # Monthly average separated by year is a way to distinguish environmental variable patterns/differences between years (treating them as independent). 
  output$yearly_temperature <-
    renderPlot({
      filtered_data() %>%
        group_by(Year, Month) %>%
        summarise(Mean_temp = mean(Temperature)) %>%
        ggplot(aes(x=Month, y=Mean_temp, group = Year, colour = Year)) + 
        geom_line() + 
        scale_x_discrete(labels=month.abb) +
        labs(y= "Temperature (C)", x = "Month", title = "Yearly Temperature Patterns")
      
    })
  output$yearly_rainfall <-
    renderPlot({
      filtered_data2() %>%
        group_by(Year, Month) %>%
        summarise(Mean_rain = mean(Rainfall)) %>%
        ggplot(aes(x=Month, y=Mean_rain, group = Year, colour = Year)) + 
        geom_line() + 
        scale_x_discrete(labels=month.abb) +
        labs(y= "Rainfall (mm)", x = "Month", title = "Yearly Rainfall Patterns")
      
    })
  
  # side-by-side box plots differentiates the pattern and distribution between the months of the year.
  # Helpful to see if certain months are prone to more extreme temperature and rainfall patterns. 
  output$temperature_boxplot <- 
    renderPlot({
      filtered_data() %>%
        group_by(Year, Month) %>% 
        summarise(mean_temp = mean(Temperature)) %>%
        ggplot(aes(x = Month, y = mean_temp)) + 
        geom_boxplot(position = "dodge") +
        scale_x_discrete(labels=month.abb) +
        labs(x = "Month", y = "Temperature (C)", title = "Mean Monthly Temperature Distributions")
    })
  output$rainfall_boxplot <- 
    renderPlot({
      filtered_data2() %>%
        group_by(Year, Month) %>% 
        summarise(sum_rain = sum(Rainfall)) %>%
        ggplot(aes(x = Month, y = sum_rain)) + 
        geom_boxplot(position = "dodge") +
        scale_x_discrete(labels=month.abb) +
        labs(x = "Month", y = "Rainfall (mm)", title = "Monthly Total Rainfall Distributions")
    })
  
  # The data should be easily accessible and having a snippet shows the user how the data is formatted for easier interpretation of plots. 
  # Providing the data table also is being more transparent with analysis process.
  output$data_table1 <- 
    renderDT({
      filtered_data1()
    }) 
}

shinyApp(ui = ui, server = server)















