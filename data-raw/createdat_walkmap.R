
# this script creates the leaflet map for the individual walk data

rm(list = ls())

# appdir <- c("Z:/consulting/Beyer_Kirsten/RBE/rbe_app_v1/rbe.golem")
appdir <- c("C:/Users/bcanales/mcw.edu/Relax & Breathe Easy - General/RBE_App/rbe.golem")

setwd(appdir)

library(leaflet)
library(readxl)
library(sf)
library(leafem)
library(usethis)

# load walk data ----------------------------------------------------------

dat <- readxl::read_xlsx("data-raw/RBE_Website_WalkExamples_Clean_GPS_20231101.xlsx")
names(dat) <- tolower(names(dat))

load(file = "data/park_meta.rda")

# subset to desired walks -------------------------------------------------

walks <- unique(dat$walkid)

dat <- subset(dat, walkid %in% walks[2:9])
walks <- unique(dat$walkid)

# load color palettes ----------------------------------------------------

source("data-raw/color_palettes.R")

dat$temp_cols <- temp_pal(dat$temperature)
dat$hum_cols <- hum_pal(dat$humidity)
dat$hr_cols <- hr_pal(dat$hr_mcs)
dat$eda_cols <- eda_pal(dat$eda_mcs)
dat$pm25_cols <- pm25_pal(dat$pm25)


# base map ----------------------------------------------------------------

walkmap <-
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


# add measurement layers --------------------------------------------------

dat_sf = st_as_sf(dat
                  , coords = c("longitude", "latitude")
                  , crs = 4326
)

walkmap <-
      walkmap %>%
      addFeatures(data = dat_sf
                  ,color = ~temp_cols
                  ,radius = 1
                  ,opacity = 1
                  , group = "Temperature"
      ) %>%
      addFeatures(data = dat_sf
                  ,color = ~hum_cols
                  ,radius = 2
                  , group = "Humidity"
      ) %>%
      addFeatures(data = dat_sf
                  ,color = ~hr_cols
                  ,radius = 2
                  , group = "Heart Rate"
      ) %>%
      addFeatures(data = dat_sf
                  ,color = ~eda_cols
                  ,radius = 2
                  , group = "EDA"
      ) %>%
      addFeatures(data = dat_sf
                  ,color = ~pm25_cols
                  ,radius = 2
                  , group = "PM2.5"
      )

# add walking route -------------------------------------------------------

for (i in 1:length(walks)){

      dati <- subset(dat, walkid %in% walks[i])
      walkmap <- walkmap %>%
            addPolylines(data = dati
                         ,lat = ~latitude
                         , lng = ~longitude
                         , group = "Walking Route"
                         , weight = 1
                         , color = "black"
                         , opacity = 1
            )
}


# add marker to start of each walk ----------------------------------------



for (i in 1:length(walks)){

   park_meta_i <- subset(park_meta, walkid %in% walks[i])
   walkmap <- walkmap %>%
      addMarkers(lat= park_meta_i$walk_start_lat
              , lng = park_meta_i$walk_start_lng
              , label = park_meta_i$walk_caption
   )
}


# add legends and layer control -------------------------------------------

# walkmap <-
#       walkmap  %>%
#       addLayersControl(baseGroups = c("Map View", "Satellite View")
#                        ,overlayGroups = c("Walking Route"
#                                           , "Temperature"
#                                           , "Humidity"
#                                           , "PM2.5"
#                                           , "Heart Rate"
#                                           , "EDA"
#                        )
#                        ,options = layersControlOptions(collapsed = FALSE)
#       ) %>%
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

# view map ----------------------------------------------------------------

# The 'view' will be controlled by reactive drop-down
# this will be updated via leaflet proxy so map does not need to
# be rendered each time

# for example, Riverside park:
walkmap  %>%
      setView(lat = 43.06871902
              , lng = -87.89026452
              , zoom = 17
      )

# save R data for app -----------------------------------------------------

usethis::use_data(walkmap
                  , internal = FALSE
                  , overwrite = TRUE
                  )
# golem::add_module(name = "walkmap")



