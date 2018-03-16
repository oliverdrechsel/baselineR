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
    
    #####
    # read inputs and button clicks
    
    # clicks on spectrum plot need to get saved to be used later for table output, drawing in plot and calculate baseline regions
    # https://stackoverflow.com/questions/41106547/how-to-save-click-events-in-leaflet-shiny-map
    clickStore <- reactiveValues(coordinates_x = vector(),
                                 coordinates_y = vector())
    
    peakStore <- reactiveValues(peak = vector(),
                                area = vector())
    
    f.computeArea <- function(x){
        
        print(paste0("called: ", clickStore$coordinates_x[x], "___" , clickStore$coordinates_y[x]))
        print(paste0("called: ", clickStore$coordinates_x[x+1], "___" , clickStore$coordinates_y[x+1]))
        
        # compute a straight line between the start (x) and end (x+1) points and use this as a basis for AUC computation
        # maybe need to substract the correct y value at every x position between start and end to feed AUC formula
        return(NULL)
    }
    
    observeEvent(input$spectrum_click, {
        click <- input$spectrum_click
        
        # find nearest point on x axis in data
        df.tmp <- rawdata()[, 1:2]
        v.index <- which.min(abs(df.tmp[,1] - click$x))
        
        clickStore$coordinates_x <- c(clickStore$coordinates_x, df.tmp[v.index, 1])
        clickStore$coordinates_y <- c(clickStore$coordinates_y, df.tmp[v.index, 2])
    })
    
    # remove clicked points
    observeEvent(input$spectrum_dblclick, {
        # nearPoints() function does not work in my hands (just look at x dimension)
        # in the sake of time saving, using which()
        
        df.tmp <- data.frame("wavelength" = clickStore$coordinates_x,
                             "emission" = clickStore$coordinates_y)
        
        # find closest point on x dimension only
        v.index <- which.min( abs(clickStore$coordinates_x - input$spectrum_dblclick$x) )
        
        # delete the double clicked region
        clickStore$coordinates_x <- clickStore$coordinates_x[-v.index]
        clickStore$coordinates_y <- clickStore$coordinates_y[-v.index]
    })
    
    # compute peak areas on click
    observeEvent(input$compute_input, {
        # get index positions
        # check, if even number was given - otherwise there wouldn't be start-end pairs
        v.length <- length(clickStore$coordinates_x) 
        if (v.length %% 2 != 0){
            return(NULL)
        } else {
            
            # this needs to do several things
            # x values must apply to all spectra
            # extract y values
            # compute peak area for all spectra (and all peaks)
            # extract timing of spectra from input file
            # report decay kinetics
            v.starts <- seq(1, v.length / 2, by = 2) # start of peak is every first entry (end, every second)
            sapply(v.starts, f.computeArea)
            return(NULL) # for dev use NULL
        }
        
        
        
        
    })
    
    rawdata <- reactive({
        
        if (is.null(input$file_input)) { return(NULL) }
        
        tmp.data <- read.table(file=input$file_input$datapath, header=F, sep='\t', stringsAsFactors=FALSE, nrows = 1024)
        
        return(tmp.data)
        
    })  
    
    #####
    # render output
    
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
        
        # add connecting line at base of peaks
        p.baseline <- NULL
        p.baselineColour <- NULL
        if (length(clickStore$coordinates_x) %% 2 == 0 & length(clickStore$coordinates_x) != 0){
            df.lineplot <- data.frame("wavelength" = clickStore$coordinates_x,
                                  "emission" = clickStore$coordinates_y,
                                  "group" = as.character(
                                      rep(
                                          seq(1, length(clickStore$coordinates_x) / 2), 
                                          each = 2)))
            
            p.baseline <- geom_line(data = df.lineplot, aes(wavelength, emission, colour = group))
            p.baselineColour <- scale_colour_manual(values = rep("#22AA22", length(clickStore$coordinates_x) / 2), guide = FALSE)
        }
        
        # finally plot
        ggplot(df.plot, aes(wavelength, emission)) +
            geom_point() +
            p.vline +
            p.baseline +
            p.baselineColour
        
    })
    
    output$point_select <- renderTable({
        df.tmp <- data.frame("wavelength" = clickStore$coordinates_x,
                             "intensity" = clickStore$coordinates_y)
        
        df.tmp <- df.tmp[order(df.tmp$wavelength),]
    })
    
})

