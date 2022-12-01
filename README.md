# Assignment B03 - Shiny App

## Assignment information

For assignment B03 I chose option B - creating my own shiny app. I selected historical climate data for Vancouver, BC as my primary data set to include in my application.  

For assignment B04, I decided to chose option C where I will be adding and editing my shiny app from assignment B03. The features I added to my shiny app from assignment B03 include:
1. Aesthetics: Images of Vancouver and different theme 
2. Navigation tabs
3. Plots for rainfall variable
4. Download data buttons 

## Accessing the app

Assignment B03: [V1.0.0](https://wettengm.shinyapps.io/Vancouver_weather/) <br />
Assignment B04: [V1.1.0](https://wettengm.shinyapps.io/Vancouver_weather_v2/)

## Description

My shiny app focuses on visualizing climate data for Vancouver; spanning from 1986 through 2020. I have chosen air temperature and rainfall as the variables to explore in this app. The plots include a monthly and yearly moving average, year specific temperature and rainfall patterns, and monthly specific distributions. The input years for the plots can be changed using the slider bar on the left had side of the app and a snippet of the data table appears below the plots. 

## Data source

The data was downloaded from [Canadian Centre for Climate Services](https://climate-change.canada.ca/climate-data/#/daily-climate-data). The vancouver_climate.csv file in the repository is the cleaned version of the raw data. I chose three site locations in the Vancouver metro area (Downtown, North Vancouver and Richmond) and averaged the three stations together. This produces a better representation of climate patterns for the city as it helps deal with measurement errors if they occur at a particular station. Additionally it is an appropriate way of dealing with missing data as the climate has very little variation between the three locations. For example, if there was missing entries for one station, the average of the other two was used.

## Repository navigation 

The Vancouver_weather folder includes the files necessary for running the app. This includes:
- **rsconnect\:** folder containing necessary files for running and deploying app
- **vancouver_climate.csv:** Final cleaned data set
- **app.R:** R file containing code for the shiny app

