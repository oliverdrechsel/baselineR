#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Define a Baseline of Spectra"),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
       fileInput("infile",
                 "upload csv file",
                 accept = "csv"
                 )
    ),
    
    # Show a plot of the uploaded csv file
    mainPanel(
       plotOutput("spectrum")
    )
  )
))
