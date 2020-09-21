#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(lubridate)
library(ggplot2)
library(leaflet)



nom<-read.csv("nom.csv",header = TRUE)
# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Trend in Covid-19 Hospitalization, Death rate and Mortality in France, by look-back period"),

    # Sidebar with a slider input for number of look-back days
    sidebarLayout(
        sidebarPanel(
            
            sliderInput("lookback",
                        "Number of look-back days in trend (from today):",
                        min = 1,
                        max = 62,
                        value = 14),
            selectInput("metric","Choose a tracking metric:",choices=c("Death rate","Hospitalization rate","Mortality")),
            selectInput("department","Choose a department, or leave as France for country wide:",choices=nom$nom),
            em("Definition of terms in map legend:"),
            em(tags$small(br(),"Average mortality is the average of the mortality rate during the lookback period")),
            em(tags$small(br(),"Average hospitalization is the average of the hospitalization rate during the lookback period")),
            em(tags$small(br(),"Average death is the average of the death rate rate during the lookback period")),
            em(tags$small(br()," ")),
            em("Definition of general terms:"),
            em(tags$small(br(),"Mortality rate is generally defined as total death to date per 100,000 population")),
            em(tags$small(br(),"Hospitalization rate generally is defined as number of daily new hospitalized patient")),
            em(tags$small(br(),"Death rate is generally defined as number of daily new death"))
            
        ),
            
        # Show a plot of the hospitalization or death rate
        mainPanel(
            plotOutput("Plot"),
            leafletOutput("map")
        )
    )
))
