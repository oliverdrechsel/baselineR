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
shinyServer(function(input, output, session) {
    
    rawdata <- reactive({
        
        print("execute ...")
        
        if (is.null(input$infile)) { return(NULL) }
        
        print("execute read data")
        
        print(input$action_input)
        
        tmp.data <- read.table(file=input$file_input$datapath, header=F, sep='\t', stringsAsFactors=FALSE, nrows = 1024)
        
        return(tmp.data)
        
    })  
    
    
    output$spectrum <- renderPlot({
        
        print("in plotting")
        
        if (is.null(rawdata())) {return(NULL)}
        
        df.tmp <- rawdata()
        df.plot <- data.frame("wavelength" = df.tmp[,1],
                              "measurement" = df.tmp[,2])
        
        ggplot(df.plot, aes(wavelength, measurement)) +
            geom_point()
        
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

