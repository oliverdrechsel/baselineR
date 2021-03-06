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
       fileInput("file_input",
                 "upload csv file",
                 accept = "csv"
                 ),
       "Usage:\n",
       "- load csv files of spectra\n",
       "- select wavelengths from plot by single click\n",
       "- remove wavelengths from table by double click\n",
       actionButton("compute_input", "compute peak area")
    ),
    
    # Show a plot of the uploaded csv file
    mainPanel(
       plotOutput("spectrum",
                  click = "spectrum_click",
                  dblclick = "spectrum_dblclick"),
       # list the points that have been clicked
       # dataTableOutput("point_select")
       tableOutput("point_select")
    )
  )
))
