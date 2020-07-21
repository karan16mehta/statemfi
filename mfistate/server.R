#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(dplyr)

library(leaflet)

library(DT)

shinyServer(function(input, output) {
    # Import Data and clean it
    
    bb_data <- read.csv("states.csv", stringsAsFactors = FALSE )
    bb_data <- data.frame(bb_data)
    bb_data$latitude <-  as.numeric(bb_data$latitude)
    bb_data$longitude <-  as.numeric(bb_data$longitude)
    bb_data=filter(bb_data, latitude != "NA") # removing NA values
    
    # new column for the popup label
    
    bb_data <- mutate(bb_data, cntnt=paste0('<br><strong>State:</strong> ', ï..State,
                                            '<br><strong>No. of MFIs:</strong> ', No_of_MFIs,
                                            '<br><strong>GLP (Crore Rs.):</strong> ',GLP_Crore_Rs,
                                            '<br><strong>Active borrowers(lakhs):</strong> ',Active_borrowers.in_lakh
    )) 
    
    # create a color paletter for category type in the data file
    
    #  pal <- colorFactor(pal = c("#1b9e77", "#d95f02", "#7570b3"), domain = c("Charity", "Government", "Private"))
    
    # create the leaflet map  
    output$bbmap <- renderLeaflet({
        leaflet(bb_data) %>% 
            addCircles(lng = ~longitude, lat = ~latitude) %>% 
            addTiles() %>%
            addCircleMarkers(data = bb_data, lat =  ~latitude, lng =~longitude, 
                             radius = 10, popup = ~as.character(cntnt), 
                             color = '#1b9e77' ,
                             stroke = FALSE, fillOpacity = 0.8)%>%
            
            addEasyButton(easyButton(
                icon="fa-crosshairs", title="ME",
                onClick=JS("function(btn, map){ map.locate({setView: true}); }")))
    })
    
    #create a data object to display data
    
    output$data <-DT::renderDataTable(datatable(
        bb_data[,c(-2,-3,-5)],filter = 'top',
        colnames = c("State", "No. of MFIs", "GLP in Crore Rs.", "Active Borrowers in Lakhs")
    ))
    
    
})