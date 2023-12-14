
load(file = "data/park_meta.rda")
load(file = "data/aggmap.rda")

load(file = "data/temp_bins.rda")
load(file = "data/temp_cols.rda")
load(file = "data/temp_labs.rda")
load(file = "data/temp_pal.rda")

load(file = "data/eda_bins.rda")
load(file = "data/eda_cols.rda")
load(file = "data/eda_labs.rda")
load(file = "data/eda_pal.rda")

load(file = "data/hr_bins.rda")
load(file = "data/hr_cols.rda")
load(file = "data/hr_labs.rda")
load(file = "data/hr_pal.rda")

load(file = "data/hum_bins.rda")
load(file = "data/hum_cols.rda")
load(file = "data/hum_labs.rda")
load(file = "data/hum_pal.rda")

load(file = "data/pm25_bins.rda")
load(file = "data/pm25_cols.rda")
load(file = "data/pm25_labs.rda")
load(file = "data/pm25_pal.rda")

# palettes <- list.files("data/", full.names = T)
# palettes <- palettes[grepl(paste(paste0("^data/", c("eda_", "hr_", "temp_", "hum_", "pm25_")), collapse = "|"), palettes)]
# for (p in 1:length(palettes)) { load(file = palettes[p]) }

#' aggdata_map UI Function
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
mod_aggmap_ui <- function(id){
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
                                ,label = "Select Park:"
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
                  ,mainPanel(leafletOutput(ns("aggmap_out"))
                             ,width = 8
                             )
            )

      )
}

#' aggdata_map Server Functions
#'
#' @noRd
mod_aggmap_server <- function(id){
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
                                     , label = "Select Park:"
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

            output$aggmap_out <- renderLeaflet({
                  aggmap %>%
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
                        addLegend(values = c(40, 105)
                                  , pal = temp_pal
                                  , labFormat = labelFormat(suffix = "F")
                                  , group = "Temperature"
                                  , title = "Temperature"
                                  , opacity = 1
                        ) %>%
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
                  leafletProxy("aggmap_out", session) %>%
                        setView(lat= startlat()
                                , lng = startlng()
                                , zoom = startzoom()
                        )
            })

      })
}

## To be copied in the UI
# mod_aggmap_ui("aggdata_map_1")

## To be copied in the server
# mod_aggmap_server("aggdata_map_1")
