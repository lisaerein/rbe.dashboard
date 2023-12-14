
load(file = "data/park_meta.rda")
load(file = "data/walkmap.rda")

#' walkmap UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import bslib
#' @import leaflet
#' @import leafem
#' @import scales
#' @import waiter
mod_walkmap_ui <- function(id){
  ns <- NS(id)
  tagList(
        ####### TITLE #######
        sidebarLayout(
              sidebarPanel(selectInput(inputId = ns("cityin")
                                       ,label = "Select City:"
                                       ,choices = list(`Milwaukee`   = "city_mke"
                                                       ,`La Crosse`  = "city_lax"
                                       )
                                       ,selected = "Milwaukee"
              )
              ,radioButtons(inputId = ns("parkin")
                            ,label = "Select Walk:"
                            ,choices = list(`Riverside Park` = "park_rhs"
                                            ,`Kinnickinnic River Trail` = "park_kkt"
                                            ,`Kosciuszko Park` = "park_kozi"
                                            ,`Three Bridges Park` = "park_menom"
                                            ,`Pulaski Park` = "park_pulaski"
                                            ,`Washington Park` = "park_wash"
                            )
                            # ,selected = "Riverside Park"
              )
              ,width = 4 # widths must add to 12 or less (12 fills page)
              )
              ,mainPanel(leafletOutput(ns("walkmap_out"))
                         ,width = 8
              )
        )

  )
}

#' walkmap Server Functions
#'
#' @noRd
mod_walkmap_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    observe({
          if (input$cityin == "city_mke"){
                parks <- list(`Riverside Park` = "park_rhs"
                              ,`Kinnickinnic River Trail` = "park_kkt"
                              ,`Kosciuszko Park` = "park_kozi"
                              ,`Three Bridges Park` = "park_menom"
                              ,`Pulaski Park` = "park_pulaski"
                              ,`Washington Park` = "park_wash"
                )
          }
          if (input$cityin == "city_lax"){
                parks <- list(`La Crosse River Marsh` = "park_rmarsh"
                              ,`Myrick Park`= "park_myrick"
                )
          }

          updateRadioButtons(session
                             , "parkin"
                             , label = "Select Walk:"
                             , choices = parks
          )
    })

    startlat <- reactive({
          park_meta[park_meta$parkid == input$parkin, "walk_mid_lat"]
    })
    startlng <- reactive({
          park_meta[park_meta$parkid == input$parkin, "walk_mid_lng"]
    })
    startzoom <- reactive({
          park_meta[park_meta$parkid == input$parkin, "walk_zoom"]
    })

    output$walkmap_out <- renderLeaflet({
          walkmap <-
                walkmap  %>%
                setView(lat= park_meta[park_meta$parkid == "park_rhs", "walk_mid_lat"]
                        , lng = park_meta[park_meta$parkid == "park_rhs", "walk_mid_lng"]
                        , zoom = park_meta[park_meta$parkid == "park_rhs", "walk_zoom"]
                ) %>%
                addProviderTiles("OpenStreetMap"
                                 ,group = "Map View"
                                 ,options = providerTileOptions(opacity = 0.7)
                )  %>%
                addProviderTiles("Esri.WorldImagery"
                                 ,group = "Satellite View"
                                 ,options = providerTileOptions(opacity = 1.0)
                ) %>%
                addLayersControl(baseGroups = c("Map View", "Satellite View")
                                 ,overlayGroups = c("Walking Route"
                                                    , "Temperature"
                                                    , "Humidity"
                                                    , "PM2.5"
                                                    , "Heart Rate"
                                                    , "EDA"
                                 )
                                 ,options = layersControlOptions(collapsed = FALSE)
                ) %>%
                # addLegend(values = temp_range
                #           , colors = temp_cols
                #           , group = "Temperature"
                #           , title = "Temperature"
                #           , opacity = 1
                #           , labels = temp_labs
                # ) %>%
                addLegend(values = c(40, 105)
                          , pal = temp_pal
                          , labFormat = labelFormat(suffix = "F")
                          , group = "Temperature"
                          , title = "Temperature"
                          , opacity = 1
                ) %>%
                # addLegend(values = hum_range
                #           , colors = hum_cols
                #           , group = "Humidity"
                #           , title = "Humidity"
                #           , opacity = 1
                #           , labels = hum_labs
                # ) %>%
                addLegend(values = c(0, 100)
                          , pal = hum_pal
                          , labFormat = labelFormat(suffix = "%")
                          , group = "Humidity"
                          , title = "Humidity"
                          , opacity = 1
                ) %>%
                addLegend(values = eda_range
                          , colors = eda_cols
                          , group = "EDA"
                          , title = "EDA Z-score"
                          , opacity = 1
                          , labels = eda_labs
                ) %>%
                addLegend(values = hr_range
                          , colors = hr_cols
                          , group = "Heart Rate"
                          , title = "Heart Rate Z-score"
                          , opacity = 1
                          , labels = hr_labs
                ) %>%
                addLegend(values = pm25_range
                          , colors = pm25_cols
                          , group = "PM2.5"
                          , title = "PM2.5"
                          , opacity = 1
                          , labels = pm25_labs
                ) %>%
                hideGroup("Heart Rate") %>%
                hideGroup("EDA") %>%
                hideGroup("Humidity") %>%
                hideGroup("PM2.5")
    })
    observe({
          leafletProxy("walkmap_out", session) %>%
                setView(lat= startlat()
                        , lng = startlng()
                        , zoom = startzoom()
                )
    })

  })
}

## To be copied in the UI
# mod_walkmap_ui("walkmap_1")

## To be copied in the server
# mod_walkmap_server("walkmap_1")
