
# this script creates a lookup file of 'meta-data' on each park

rm(list = ls())

# appdir <- c("Z:/consulting/Beyer_Kirsten/RBE/rbe_app_v1/rbe.golem")
appdir <- c("C:/Users/bcanales/mcw.edu/Relax & Breathe Easy - General/RBE_App/rbe.golem")

setwd(appdir)

library(readxl)
library(stringr)
library(htmltools)
library(usethis)

dat <-  read_excel("data-raw/RBE_Website_WalkExamples_Clean_GPS_20231101.xlsx")

names(dat) <- tolower(names(dat))

walks <- unique(dat$walkid)

walk_mid_lat <- rep(NA, length(walks))
walk_mid_lng <- rep(NA, length(walks))

walk_start_lat <- rep(NA, length(walks))
walk_start_lng <- rep(NA, length(walks))

walk_start_time <- rep(NA, length(walks))
walk_start <- rep(NA, length(walks))
walk_end   <- rep(NA, length(walks))
walk_date       <- rep(NA, length(walks))
walk_duration   <- rep(NA, length(walks))

for (i in 1:length(walks)){
 dati <- subset(dat, walkid %in% walks[i])

 dati <- dati[order(dati$datetime),]

 lat_start <- dati$latitude

 lat_max <- max(dati$latitude)
 lat_min <- min(dati$latitude)
 lat_mid <- lat_min + ((lat_max-lat_min)/2)

 lng_max <- max(dati$longitude)
 lng_min <- min(dati$longitude)
 lng_mid <- lng_min + ((lng_max-lng_min)/2)

 walk_mid_lat[i] <- lat_mid
 walk_mid_lng[i] <- lng_mid

 walk_start_lat[i] <- dati$latitude[1]
 walk_start_lng[i] <- dati$longitude[1]

 walk_date[i] <- format(dati$date[1], format = "%B %e, %Y")

 start_hour <- lubridate::hour(dati$datetime[1])
 start_min  <- lubridate::minute(dati$datetime[1])
 start_ampm <- "AM"
 if (start_hour >= 12) {
       start_ampm <- "PM"
       if (start_hour >= 13) start_hour <- start_hour - 12
 }
 walk_start_time[i] <- paste0(start_hour
                              , ":"
                              , stringr::str_pad(start_min, width = 2, pad = "0")
                              , " "
                              , start_ampm
                              )
 walk_start[i] <- as.character(dati$datetime[1])
 walk_end[i] <- as.character(dati$datetime[nrow(dati)])

 dur <- difftime(dati$datetime[nrow(dati)], dati$datetime[1], units = "mins")
 walk_duration[i] <- paste(round(as.numeric(dur)), "minutes")

}

# walk_start <- as.POSIXct(as.numeric(walk_start), origin='1970-01-01')
# walk_end <- as.POSIXct(as.numeric(walk_end), origin='1970-01-01')

park_meta <- data.frame("walkid" = walks
                        ,walk_mid_lat
                        ,walk_mid_lng
                        ,walk_zoom = 16
                        ,walk_start_lat
                        ,walk_start_lng
                        ,walk_start
                        ,walk_end
                        ,walk_start_time
                        ,walk_date
                        ,walk_duration
                        )

park_meta$parkid <- NA
park_meta$parkid[grepl("^KKRiver", park_meta$walkid)] <- "park_kkt"
park_meta$parkid[grepl("^Kozi", park_meta$walkid)] <- "park_kozi"
park_meta$parkid[grepl("^Riverside", park_meta$walkid)] <- "park_rhs"
park_meta$parkid[grepl("^Menom", park_meta$walkid)] <- "park_menom"
park_meta$parkid[grepl("^Pulaski", park_meta$walkid)] <- "park_pulaski"
park_meta$parkid[grepl("^Washington", park_meta$walkid)] <- "park_wash"
park_meta$parkid[grepl("^LaCrosseRiver", park_meta$walkid)] <- "park_rmarsh"
park_meta$parkid[grepl("^Myrick", park_meta$walkid)] <- "park_myrick"

park_meta$park_name <- NA
park_meta$park_name[park_meta$parkid %in% "park_kkt"    ] <- "Kinnickinnic River Trail"
park_meta$park_name[park_meta$parkid %in% "park_rhs"    ] <- "Riverside Park"
park_meta$park_name[park_meta$parkid %in% "park_kozi"   ] <- "Kosciuszko Park"
park_meta$park_name[park_meta$parkid %in% "park_pulaski"] <- "Pulaski Park"
park_meta$park_name[park_meta$parkid %in% "park_menom"  ] <- "Three Bridges Park"
park_meta$park_name[park_meta$parkid %in% "park_wash"   ] <- "Washington Park"
park_meta$park_name[park_meta$parkid %in% "park_myrick" ] <- "Myrick Park"
park_meta$park_name[park_meta$parkid %in% "park_rmarsh" ] <- "La Crosse River Marsh"

park_meta$walk_sched_start <- NA
park_meta$walk_sched_start[park_meta$walkid %in% "KKRiverTrail_20220922_0830"      ] <- "8:30 AM"
park_meta$walk_sched_start[park_meta$walkid %in% "KKRiverTrail_20221021_0830"      ] <- "8:30 AM"
park_meta$walk_sched_start[park_meta$walkid %in% "KoziPark_20220923_1600"          ] <- "4:00 PM"
park_meta$walk_sched_start[park_meta$walkid %in% "LaCrosseRiverMarsh_20221025_1700"] <- "5:00 PM"
park_meta$walk_sched_start[park_meta$walkid %in% "MenomeneeValley_20220917_0930"   ] <- "9:30 AM"
park_meta$walk_sched_start[park_meta$walkid %in% "MyrickPark_20221103_1700"        ] <- "5:00 PM"
park_meta$walk_sched_start[park_meta$walkid %in% "PulaskiPark_20220922_1630"       ] <- "4:30 PM"
park_meta$walk_sched_start[park_meta$walkid %in% "RiversidePark_20221008_1400"     ] <- "2:00 PM"
park_meta$walk_sched_start[park_meta$walkid %in% "WashingtonPark_20220906_1630"    ] <- "4:30 PM"

park_meta$walk_caption <- paste0("<strong>"
                                 ,park_meta$park_name
                                 ,"</strong>"
                                 ," <br>"
                                 ,"Walk on "
                                 , park_meta$walk_date
                                 ,"<br>Start time: "
                                 ,park_meta$walk_sched_start
                                 # ,"<br>"
                                 # ,"Duration: "
                                 # ,park_meta$walk_duration
                                 ) %>% lapply(htmltools::HTML)


park_meta$nwalks <- NA
park_meta$nwalks[park_meta$parkid %in% "park_kkt"    ] <- 8
park_meta$nwalks[park_meta$parkid %in% "park_rhs"    ] <- 13
park_meta$nwalks[park_meta$parkid %in% "park_kozi"   ] <- 9
park_meta$nwalks[park_meta$parkid %in% "park_pulaski"] <- 5
park_meta$nwalks[park_meta$parkid %in% "park_menom"  ] <- 8
park_meta$nwalks[park_meta$parkid %in% "park_wash"   ] <- 5
park_meta$nwalks[park_meta$parkid %in% "park_myrick" ] <- 9
park_meta$nwalks[park_meta$parkid %in% "park_rmarsh" ] <- 8

park_meta$bi_all <- NA
park_meta$bi_all[park_meta$parkid %in% "park_kkt"    ] <- 77.5
park_meta$bi_all[park_meta$parkid %in% "park_rhs"    ] <- 82.9
park_meta$bi_all[park_meta$parkid %in% "park_kozi"   ] <- 88.8
park_meta$bi_all[park_meta$parkid %in% "park_pulaski"] <- 79.2
park_meta$bi_all[park_meta$parkid %in% "park_menom"  ] <- 73.5
park_meta$bi_all[park_meta$parkid %in% "park_wash"   ] <- 77.7
park_meta$bi_all[park_meta$parkid %in% "park_myrick" ] <- 116.4
park_meta$bi_all[park_meta$parkid %in% "park_rmarsh" ] <- 117.4

park_meta$bi_animal <- NA
park_meta$bi_animal[park_meta$parkid %in% "park_kkt"    ] <- 63
park_meta$bi_animal[park_meta$parkid %in% "park_rhs"    ] <- 66
park_meta$bi_animal[park_meta$parkid %in% "park_kozi"   ] <- 62.4
park_meta$bi_animal[park_meta$parkid %in% "park_pulaski"] <- 65.5
park_meta$bi_animal[park_meta$parkid %in% "park_menom"  ] <- 59.2
park_meta$bi_animal[park_meta$parkid %in% "park_wash"   ] <- 65.6
park_meta$bi_animal[park_meta$parkid %in% "park_myrick" ] <- 91.5
park_meta$bi_animal[park_meta$parkid %in% "park_rmarsh" ] <- 92.6

park_meta$bi_plant <- NA
park_meta$bi_plant[park_meta$parkid %in% "park_kkt"    ] <- 50.1
park_meta$bi_plant[park_meta$parkid %in% "park_rhs"    ] <- 46.3
park_meta$bi_plant[park_meta$parkid %in% "park_kozi"   ] <- 44.7
park_meta$bi_plant[park_meta$parkid %in% "park_pulaski"] <- 48.4
park_meta$bi_plant[park_meta$parkid %in% "park_menom"  ] <- 45.1
park_meta$bi_plant[park_meta$parkid %in% "park_wash"   ] <- 44.2
park_meta$bi_plant[park_meta$parkid %in% "park_myrick" ] <- 100.7
park_meta$bi_plant[park_meta$parkid %in% "park_rmarsh" ] <- 97.6

park_meta$agg_caption <- paste0("<strong>"
                                ,park_meta$park_name
                                # ,"Biodiversity Index 1: X"
                                ,"</strong>"
                                ,"<br>"
                                ,"<strong>"
                                ,"Overall Biodiversity Index: "
                                ,"</strong>"
                                ,park_meta$bi_all
                                ,"<br>"
                                # ,"Biodiversity Index 2: X"
                                ,"<strong>"
                                ,"Animal Biodiversity Index: "
                                ,"</strong>"
                                ,park_meta$bi_animal
                                ,"<br>"
                                ,"<strong>"
                                ,"Plant Biodiversity Index: "
                                ,"</strong>"
                                ,park_meta$bi_plant
                                ,"<br>"
                                ,"Aggregated data from"
                                ,"<br>"
                                ,park_meta$nwalks
                                ," total walks"
                                ) %>% lapply(htmltools::HTML)

park_meta <- subset(park_meta[c(2:9),])

park_meta$walk_zoom[park_meta$parkid %in% "park_kkt"] <- 15
park_meta$walk_zoom[park_meta$parkid %in% "park_menom"] <- 15

# save R data for app -----------------------------------------------------

usethis::use_data(park_meta
                  , internal = FALSE
                  , overwrite = TRUE
)
