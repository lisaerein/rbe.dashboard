
# Create maps with NDVI (Normalized Difference Vegetation Index) base layer

rm(list = ls())

library(leaflet)
library(leafem)
library(sf)
library(raster)
library(usethis)
library(here)

# appdir <- c("Z:/consulting/Beyer_Kirsten/RBE/rbe_app_v1/rbe.golem")
# appdir <- c("C:/Users/bcanales/mcw.edu/Relax & Breathe Easy - General/RBE_App/rbe.golem")
appdir <- here::here()
setwd(appdir)

load(file = "data/park_meta.rda")

# pal_ndvi <- choose_palette()
pal_ndvi_n <- colorNumeric(palette = c("lightgray", "#0C4400")
                           ,domain = c(-1,1)
)
previewColors(pal_ndvi_n, values = seq(-1,1, 0.1))

pal_ndvi = grDevices::colorRampPalette(c("lightgray", "#0C4400"))

pal_ndvi2 = grDevices::colorRampPalette(c("#730000", "gold3", "#0C4400"))

pal_ndvi_n2 <- colorNumeric(palette = c("#730000", "gold3", "#0C4400")
                            ,domain = c(-1,1)
)
previewColors(pal_ndvi_n2, values = seq(-1,1, 0.1))

leaflet() %>% addLegend(pal = pal_ndvi_n2
                        , values =  c(-1, 1)
                        , opacity = 1
                        , title = "NDVI"
)

# load shape files for each park ------------------------------------------

rasdirs <- c("La Crosse River Marsh"
             ,"Myrick Park"
             ,"KK River Trail"
             ,"Kozi Park"
             ,"Menomenee Valley"
             ,"Pulaski Park"
             ,"Riverside Park"
             ,"Washington Park"
)

park_ids <- c("park_rmarsh"
              ,"park_myrick"
              ,"park_kkt"
              ,"park_kozi"
              ,"park_menom"
              ,"park_pulaski"
              ,"park_rhs"
              ,"park_wash"
)

shps <- vector("list", length(rasdirs))
rts <- vector("list", length(rasdirs))
for (i in 1:length(rasdirs)){
      setwd(paste0(appdir, "/data-raw/", rasdirs[i]))

      fnsi <- list.files()
      shpsi <- fnsi[!grepl("Route", fnsi) & grepl(".shp$", fnsi)]
      shps[[i]] <- read_sf(shpsi)

      rtsi <- fnsi[grepl("Route", fnsi) & grepl(".shp$", fnsi)]
      rts[[i]] <- read_sf(rtsi)
}

setwd(appdir)

# load NVDI raster --------------------------------------------------------

mke_ndvi_raster <- raster("data-raw/ndvi_mkeco.tif")
lax_ndvi_raster <- raster("data-raw/ndvi_laxco.tif")

mke_ndvi_raster <- readAll(mke_ndvi_raster)
lax_ndvi_raster <- readAll(lax_ndvi_raster)

ndvimap_mke <- leaflet(leafletOptions(minZoom = 11, preferCanvas = TRUE))
ndvimap_lax <- leaflet(leafletOptions(minZoom = 11, preferCanvas = TRUE))

# start <- Sys.time()
# ndvimap_lax2 <-
# leaflet(leafletOptions(minZoom = 11, preferCanvas = TRUE)) %>%
# addGeoRaster(x = lax_ndvi_raster
#            ,resolution =  300
#            ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
#            ,autozoom = T
#            ,opacity = 1
#            ,method = "near"
# )
# addGeotiff(file = "Z:/consulting/Beyer_Kirsten/RBE/app_data/ndvi_laxco.tif"
#            ,resolution =  300
#            ,colorOptions = colorOptions(palette = pal_ndvi, na.color = "transparent")
#            ,autozoom = T
#            ,method="near"
#            )
# end <- Sys.time()
# (dur <- end-start)
# ndvimap_lax2

# ndvimap_mke2 <-
# leaflet() %>%
# addGeoRaster(x = mke_ndvi_raster
#              ,resolution =  300
#              ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
#              ,autozoom = T
#              ,method="near"
# )
# addGeotiff(file = "Z:/consulting/Beyer_Kirsten/RBE/app_data/ndvi_mkeco.tif"
#            ,resolution =  300
#            ,colorOptions = colorOptions(palette = pal_ndvi, na.color = "transparent")
#            ,autozoom = T
#            ,method = "near"
#            ) %>%




# add park shapefiles -----------------------------------------------------

for (i in 3:length(rasdirs)){
      ndvimap_mke <- ndvimap_mke %>%
            addPolygons(group = park_meta[park_meta$parkid %in% park_ids[i], "park_name"]
                        ,data = shps[[i]]
                        ,opacity = 1
                        ,fillColor = "transparent"
                        # ,fillOpacity = 0.2
                        ,weight = 1.5
                        ,color = "black"
                        ,popup = park_meta[park_meta$parkid %in% park_ids[i], "park_name"]
            )

}

for (i in 1:2){
      ndvimap_lax <- ndvimap_lax %>%
            addPolygons(group = park_meta[park_meta$parkid %in% park_ids[i], "park_name"]
                        ,data = shps[[i]]
                        ,opacity = 1
                        ,fillColor = "transparent"
                        # ,fillOpacity = 0.2
                        ,weight = 1.5
                        ,color = "black"
                        ,popup = park_meta[park_meta$parkid %in% park_ids[i], "park_name"]
            )

}

ndvimap_mke <-
      ndvimap_mke %>%
      addLayersControl(overlayGroups = c("Riverside Park"
                                         ,"Kinnickinnic River Trail"
                                         ,"Kosciuszko Park"
                                         ,"Pulaski Park"
                                         ,"Three Bridges Park"
                                         ,"Washington Park"
      )
      ,options = layersControlOptions(collapsed = FALSE)
      ,position = "bottomright"
      ) %>%
      setView(lat = park_meta[park_meta$parkid %in% "park_menom", "walk_start_lat"]
              ,lng = park_meta[park_meta$parkid %in% "park_kozi", "walk_start_lng"]
              ,zoom = 12
      ) %>%
      addLegend(pal = pal_ndvi_n2
                , values =  c(-1, 1)
                , opacity = 1
                , title = "NDVI"
      )

ndvimap_lax <-
      ndvimap_lax %>%
      addLayersControl(overlayGroups = c("La Crosse River Marsh"
                                         ,"Myrick Park"
      )
      ,options = layersControlOptions(collapsed = FALSE)
      ,position = "bottomright"
      ) %>%
      setView(lat = park_meta[park_meta$parkid %in% "park_rmarsh", "walk_start_lat"]
              ,lng = park_meta[park_meta$parkid %in% "park_rmarsh", "walk_start_lng"]
              ,zoom = 13
      ) %>%
      addLegend(pal = pal_ndvi_n2
                , values =  c(-1, 1)
                , opacity = 1
                , title = "NDVI"
      )

ndvimap_mke2 <-
      ndvimap_mke %>%
      addGeoRaster(x = mke_ndvi_raster
                   ,resolution =  200
                   ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
                   ,autozoom = FALSE
                   ,method = "near"
      )

ndvimap_lax2 <-
      ndvimap_lax %>%
      addGeoRaster(x = lax_ndvi_raster
                   ,resolution =  200
                   ,colorOptions = colorOptions(palette = pal_ndvi2, na.color = "transparent")
                   ,autozoom = FALSE
                   ,method = "near"
      )

# save R data for app -----------------------------------------------------

usethis::use_data(ndvimap_mke
                  , internal = FALSE
                  , overwrite = TRUE
)
usethis::use_data(ndvimap_lax
                  , internal = FALSE
                  , overwrite = TRUE
)
usethis::use_data(pal_ndvi
                  , internal = FALSE
                  , overwrite = TRUE
)
usethis::use_data(pal_ndvi2
                  , internal = FALSE
                  , overwrite = TRUE
)
usethis::use_data(pal_ndvi_n2
                  , internal = FALSE
                  , overwrite = TRUE
)

# these take a long time to save:
usethis::use_data(mke_ndvi_raster
                  , internal = FALSE
                  , overwrite = TRUE
)
usethis::use_data(lax_ndvi_raster
                  , internal = FALSE
                  , overwrite = TRUE
)

# golem::add_module(name = "ndvimap")
