
# this script defines color palettes for RBE app measurements

# rm(list=ls())

# appdir <- c("Z:/consulting/Beyer_Kirsten/RBE/rbe_app_v1/rbe.golem")
appdir <- c("C:/Users/bcanales/mcw.edu/Relax & Breathe Easy - General/RBE_App/rbe.golem")

setwd(appdir)

library(leaflet)
library(usethis)

# temperature -------------------------------------------------------------

temp_cols <- c('#ffffd4','#fee391','#fec44f','#fe9929','#d95f0e','#993404')

temp_bins <- c(40, 50, 60, 70, 80, 90, Inf)
temp_range <- c(48, 104)
temp_labs <- c("40-50F", "50-60F", "60-70F", "70-80F", "80-90F", "90F+")

temp_pal <- colorBin(palette = temp_cols
                            , domain = temp_range
                            , bins = temp_bins
                            , na.color = NA
                            , reverse = FALSE
                            )
# previewColors(temp_pal, values = 48:104)
# leaflet() %>% addLegend(pal = temp_pal, values =  c(48, 104), opacity = 1)

temp_pal <- colorNumeric(palette = "YlOrRd"
                        , domain = c(40,105)
                        , na.color = NA
                        , reverse = FALSE
)
# previewColors(temp_pal, values = min(temp_range):max(temp_range))
# leaflet() %>% addLegend(pal = temp_pal, values =  c(40, 105), opacity = 1, labFormat = labelFormat(suffix = "F"))

# PM2.5 -------------------------------------------------------------------

pm25_cols <- c("darkgreen", "yellow", "orange", "red", "purple", "brown")

pm25_range <- c(0,84)
pm25_bins <- c(0, 12.0, 35.5, 55.5, 140.5, 210.5, Inf)
pm25_labs <- c("Good (0-12)"
               ,"Moderate (12.1-35.4)"
               ,"Unhealthy for Sensitive Groups (35.5-55.4)"
               ,"Unhealthy (55.5-140.4)"
               ,"Very Unhealthy (140.5-210.4)"
               ,"Hazardous (210.4+)"
               )

pm25_pal <- colorBin(palette = pm25_cols
                    , domain = pm25_range
                    , bins = pm25_bins
                    , na.color = NA
                    , reverse = FALSE
                    )
# previewColors(pm25_pal, values = 0:84)
# leaflet() %>% addLegend(pal = pm25_pal, values = c(0,84), opacity = 1)

# Humidity ----------------------------------------------------------------

hum_cols <- c("#c6dbef", "#4292c6", "#08306b")

hum_range <- c(12, 77)
hum_bins <- c(0, 20, 60, 100)
hum_labs <- c("Uncomfortably dry (0-20)"
              ,"Comfort range (20-60)"
              ,"Uncomfortably wet (60-100)"
              )
hum_pal <- colorBin(palette = hum_cols
                    , domain = hum_range
                    , bins = hum_bins
                    , na.color = NA
                    , reverse = FALSE
                    )
hum_pal <- colorNumeric(palette = "Blues"
                    , domain = c(0,100)
                    , na.color = NA
                    , reverse = FALSE
)
# previewColors(hum_pal, values = min(hum_range):max(hum_range))
# leaflet() %>% addLegend(pal = hum_pal, values =  c(0, 100), opacity = 1, labFormat = labelFormat(suffix = "%"))

# EDA Z-score -------------------------------------------------------------

eda_cols <- c('#efedf5','#dadaeb','#bcbddc','#9e9ac8','#807dba','#6a51a3','#54278f','#3f007d')

eda_range <- c(-4, 21)
eda_bins <- c(-4, -3, -2, -1, 0, 1, 2, 3, Inf)
eda_labs <- c("<-3", "-3, -2", "-2, -1", "-1, 0", "0, 1", "1, 2", "2, 3", "3+")

eda_pal <- colorBin(palette = eda_cols
                   , domain = eda_range
                   , bins = eda_bins
                   , na.color = NA
                   , reverse = FALSE
 )
 # previewColors(eda_pal, values = -4:3)

# HR Z-score --------------------------------------------------------------

hr_cols <- c('#f1eef6','#d4b9da','#c994c7','#df65b0','#dd1c77','#980043')

hr_range <- c(-5, 5)
hr_bins <- c(-Inf,-2:3, Inf)
hr_labs <- c("<-2", "-2, -1", "-1, 0", "0, 1", "1, 2", "2+")

hr_pal <- colorBin(palette = hr_cols
                    , domain = hr_range
                    , bins = hr_bins
                    , na.color = NA
                    , reverse = FALSE
)
# previewColors(hr_pal, values = -5:5)

# save data ---------------------------------------------------------------

usethis::use_data(eda_bins, eda_cols, eda_labs, eda_pal
                  ,hr_bins, hr_cols, hr_labs, hr_pal
                  ,temp_bins, temp_cols, temp_labs, temp_pal
                  ,hum_bins, hum_cols, hum_labs, hum_pal
                  ,pm25_bins, pm25_cols, pm25_labs, pm25_pal
                  , overwrite = TRUE
                  )
