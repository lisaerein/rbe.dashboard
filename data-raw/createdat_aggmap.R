
# this script loads all shape routes and raster layers and maps them on the same map

rm(list = ls())

# appdir <- c("Z:/consulting/Beyer_Kirsten/RBE/rbe_app_v1/rbe.golem")
appdir <- c("C:/Users/bcanales/mcw.edu/Relax & Breathe Easy - General/RBE_App/rbe.golem")

setwd(appdir)

library(leaflet)
library(terra)
library(sf)
library(usethis)

source("data-raw/color_palettes.R")

load(file = "data/park_meta.rda")

# load all raster and shape files ---------------------------------------------------

rasdirs <- c("KK River Trail"
              ,"Kozi Park"
              ,"La Crosse River Marsh"
              ,"Menomenee Valley"
              ,"Myrick Park"
              ,"Pulaski Park"
              ,"Riverside Park"
              ,"Washington Park"
 )

park_ids <- c("park_kkt"
              ,"park_kozi"
              ,"park_rmarsh"
              ,"park_menom"
              ,"park_myrick"
              ,"park_pulaski"
              ,"park_rhs"
              ,"park_wash"
)

rasts <- vector("list", length(rasdirs))
shps <- vector("list", length(rasdirs))
for (i in 1:length(rasdirs)){
      setwd(paste0(appdir, "/data-raw/", rasdirs[i]))

      fnsi <- list.files()
      shpsi <- fnsi[grepl("Route", fnsi) & grepl(".shp$", fnsi)]
      shps[[i]] <- read_sf(shpsi)

      subsi <- list.dirs(recursive = F)
      labsi <- sapply(subsi, function(x) strsplit(gsub("./", "", x), "_")[[1]][2])
      for (j in 1:length(subsi)){
            rasts[[i]][[j]] <- terra::rast(subsi[j])
      }
      names(rasts[[i]]) <- labsi
}
setwd(appdir)

# map routes and rasters for each park on same map -----------------------

# set up map:
aggmap <-
      leaflet()
      # addProviderTiles("OpenStreetMap"
      #                  # give the layer a name
      #                  ,group = "Map View"
      #                  ,options = providerTileOptions(opacity = 0.4)
      # )  %>%
      # addProviderTiles("Esri.WorldImagery"
      #                  ,group = "Satellite View"
      #                  ,options = providerTileOptions(opacity = 0.4)
      # )

# add all route shapefiles:
for (i in 1:length(rasdirs)){
      aggmap <- aggmap %>%
            addPolylines(group = "Walking Route"
                         ,data = shps[[i]]
                         ,opacity = 1
                         ,weight = 1
                         ,color = "black"
            )
}

# loop through parks and add all raster layers
for (i in 1:length(rasdirs)){
      aggmap <-
            aggmap  %>%
            addRasterImage(x = rasts[[i]][["temp"]]
                           ,colors = temp_pal
                           ,group = "Temperature"
            ) %>%
            addRasterImage(x = rasts[[i]][["hum"]]
                           ,colors = hum_pal
                           ,group = "Humidity"
            ) %>%
            addRasterImage(x = rasts[[i]][["pm25"]]
                           ,colors = pm25_pal
                           ,group = "PM2.5"
            ) %>%
            addRasterImage(x = rasts[[i]][["hr"]]
                           ,colors = hr_pal
                           ,group = "Heart Rate"
            ) %>%
            addRasterImage(x = rasts[[i]][["eda"]]
                           ,colors = eda_pal
                           ,group = "EDA"
            )
}

# add marker for each park ----------------------------------------



for (i in 1:length(park_ids)){

      park_meta_i <- subset(park_meta, parkid %in% park_ids[i])
      aggmap <- aggmap %>%
            addMarkers(lat= park_meta_i$walk_mid_lat
                       , lng = park_meta_i$walk_mid_lng
                       , label = park_meta_i$agg_caption
            )
}

# add legends and layer control - this is now done in the app
# aggmap <-
#       aggmap  %>%
#       addLayersControl(baseGroups = c("Map View", "Satellite View")
#                        ,overlayGroups = c("Walking Route"
#                                           , "Temperature"
#                                           , "Humidity"
#                                           , "PM2.5"
#                                           , "Heart Rate"
#                                           , "EDA"
#                                           )
#                        ,options = layersControlOptions(collapsed = FALSE)
#                        ) %>%
#       addLegend(values = temp_range
#                 # , pal = pal_temp
#                 , colors = temp_cols
#                 , group = "Temperature"
#                 , title = "Temperature"
#                 , opacity = 1
#                 , labels = temp_labs
#       ) %>%
#       addLegend(values = hum_range
#                 , colors = hum_cols
#                 , group = "Humidity"
#                 , title = "Humidity"
#                 , opacity = 1
#                 , labels = hum_labs
#       ) %>%
#       addLegend(values = eda_range
#                 , colors = eda_cols
#                 , group = "EDA"
#                 , title = "EDA Z-score"
#                 , opacity = 1
#                 , labels = eda_labs
#       ) %>%
#       addLegend(values = hr_range
#                 , colors = hr_cols
#                 , group = "Heart Rate"
#                 , title = "Heart Rate Z-score"
#                 , opacity = 1
#                 , labels = hr_labs
#       ) %>%
#       addLegend(values = pm25_range
#                 , colors = pm25_cols
#                 , group = "PM2.5"
#                 , title = "PM2.5"
#                 , opacity = 1
#                 , labels = pm25_labs
#       ) %>%
#       hideGroup("Heart Rate") %>%
#       hideGroup("EDA") %>%
#       hideGroup("Humidity") %>%
#       hideGroup("PM2.5")

# The 'view' will be controlled by reactive drop-down
# this will be updated via leaflet proxy so map does not need to
# be rendered each time

# for example, Riverside park:
aggmap  %>%
      setView(lat = park_meta[6, "walk_mid_lat"]
              , lng = park_meta[6, "walk_mid_lng"]
              , zoom = 17
              )

# save R data for app -----------------------------------------------------

usethis::use_data(aggmap
                  , internal = FALSE
                  , overwrite = TRUE
                  )
# golem::add_module(name = "aggmap")


