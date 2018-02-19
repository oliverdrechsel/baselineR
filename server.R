#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#


# ToDo look through this page
# https://deanattali.com/blog/advanced-shiny-tips/
# http://enhancedatascience.com/2017/03/01/three-r-shiny-tricks-to-make-your-shiny-app-shines-33-buttons-to-delete-edit-and-compare-datatable-rows/

library("ggplot2")
library("shiny")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    # clicks on spectrum plot need to get saved to be used later for table output, drawing in plot and calculate baseline regions
    # https://stackoverflow.com/questions/41106547/how-to-save-click-events-in-leaflet-shiny-map
    clickStore <- reactiveValues(coordinates_x = vector(),
                                 coordinates_y = vector())
    
    observeEvent(input$spectrum_click, {
        click <- input$spectrum_click
        
        clickStore$coordinates_x <- c(clickStore$coordinates_x, click$x)
        clickStore$coordinates_y <- c(clickStore$coordinates_y, click$y)
    })
    
    observeEvent(input$spectrum_dblclick, {
        # nearPoints() function does not work in my hands
        # in the sake of time saving, using which()
        
        df.tmp <- data.frame("wavelength" = clickStore$coordinates_x,
                   "emission" = clickStore$coordinates_y)
        
        threshold <- 1
        v.index <- which(clickStore$coordinates_x >= input$spectrum_dblclick$x - threshold & 
                  clickStore$coordinates_x <= input$spectrum_dblclick$x + threshold)
        
        # delete the double clicked region
        clickStore$coordinates_x <- clickStore$coordinates_x[-v.index]
        clickStore$coordinates_y <- clickStore$coordinates_y[-v.index]
    })
    
    rawdata <- reactive({
        
        if (is.null(input$file_input)) { return(NULL) }
        
        tmp.data <- read.table(file=input$file_input$datapath, header=F, sep='\t', stringsAsFactors=FALSE, nrows = 1024)
        
        return(tmp.data)
        
    })  
    
    
    output$spectrum <- renderPlot({
        
        if (is.null(input$file_input)) {return(NULL)}
        
        # read the data (only the first column - wavelengths and second column - first spectrum without decay is needed)
        df.tmp <- rawdata()
        df.plot <- data.frame("wavelength" = df.tmp[,1],
                              "emission" = df.tmp[,2])
        
        # add all clicked events to the plot
        p.vline <- NULL
        if (length(clickStore$coordinates_x) > 0) {
            df.clicks <- data.frame(x = clickStore$coordinates_x)
            p.vline <- geom_vline(data = df.clicks, aes(xintercept = x))
        }
        
        # finally plot
        ggplot(df.plot, aes(wavelength, emission)) +
            geom_point() +
            p.vline
        
    })
    
    output$point_select <- renderDataTable({
        df.tmp <- data.frame("wavelength" = clickStore$coordinates_x,
                             "intensity" = clickStore$coordinates_y)
        
        df.tmp <- df.tmp[order(df.tmp$wavelength),]
    })
    
})

