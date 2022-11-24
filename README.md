# Assignment B03 - Shiny App

## Assignment information

I chose option B - creating my own shiny app. I selected historical climate data for Vancouver, BC as my primary data set to include in my application.   

## Data source

The data was downloaded from [Canadian Centre for Climate Services](https://climate-change.canada.ca/climate-data/#/daily-climate-data). The vancouver_climate.csv file in the repository is the cleaned version of the raw data.  

## Description

My shiny app focuses on visualizing climate data for Vancouver; spanning from 1986 through 2020. I have chosen air temperature as the primary variable to explore in this app. The plots include a monthly and yearly moving average, year specific temperature patterns, and month specific temperature distributions. The input years for the plots can be changed using the slider bar on the left had side of the app and a snippet of the data table appears below the plots. 


### Accessing the app

The app can be accessed via the link: https://wettengm.shinyapps.io/Vancouver_weather/


## Repository navigation 

The Vancouver_weather folder includes the files necessary for running the app. This includes:
- **rsconnect\:** folder containing necessary files for running and deploying app
- **vancouver_climate.csv:** Final cleaned data set
- **app.R:** R file containing code for the shiny app

