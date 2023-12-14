
load(file = "data/ndvimap_mke.rda")
load(file = "data/ndvimap_lax.rda")
load(file = "data/mke_ndvi_raster.rda")
load(file = "data/lax_ndvi_raster.rda")
load(file = "data/pal_ndvi2.rda")

#' ndvimap UI Function
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
#' @import stars
#' @import waiter
mod_ndvimap_ui <- function(id){
  ns <- NS(id)
  tagList(
        fluidRow(column(h5("Milwaukee, WI")
                        ,leafletOutput(ns("ndvimap_mke_out"))
                        ,width  = 6
                        # ,style = "border:1px solid grey; margin:5px"
                        )
                 ,column(h5("La Crosse, WI")
                         ,leafletOutput(ns("ndvimap_lax_out"))
                         ,width = 6
                         ,offset = 0.5
                         # ,style = "border:1px solid grey; margin:5px"
                         )
                 )
  )
}

#' ndvimap Server Functions
#'
#' @noRd
mod_ndvimap_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

      output$ndvimap_mke_out <- renderLeaflet({
            ndvimap_mke <-
                  ndvimap_mke %>%
                  addGeoRaster(x = mke_ndvi_raster
                               ,resolution = 200
                               ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
                               ,autozoom = FALSE
                               ,method = "near"
                  )
            ndvimap_mke
            })
      output$ndvimap_lax_out <- renderLeaflet({
            ndvimap_lax <-
                  ndvimap_lax %>%
                  addGeoRaster(x = lax_ndvi_raster
                             ,resolution = 200
                             ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
                             ,autozoom = FALSE
                             ,method = "near"
                  )
            ndvimap_lax
            })
  })
}

## To be copied in the UI
# mod_ndvimap_ui("ndvimap_1")

## To be copied in the server
# mod_ndvimap_server("ndvimap_1")
