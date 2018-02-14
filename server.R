#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library("ggplot2")
library("shiny")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    rawdata <- reactive({
        
        if (is.null(input$infile)) {
            
            return(NULL)
            
        } else {
            
            tmp.data <- read.table(file=input$file_input$datapath, header=T, sep='\t', stringsAsFactors=FALSE)
            
        }
        
        
    })  
    
    
    output$spectrum <- renderPlot({
        df.test <- data.frame(x = rnorm(n = 200, mean = 2, sd = 10))
        ggplot(data = df.test, aes(x)) +
            geom_histogram()
    })
    # output$distPlot <- renderPlot({
    # 
    # # generate bins based on input$bins from ui.R
    # x    <- faithful[, 2] 
    # bins <- seq(min(x), max(x), length.out = input$bins + 1)
    # 
    # # draw the histogram with the specified number of bins
    # hist(x, breaks = bins, col = 'darkgray', border = 'white')
    
})

