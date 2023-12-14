
linebreaks <- function(n){HTML(strrep(br(), n))}

waiter_set_theme(html = spin_3()
                 , color = "dimgray"
                 , logo = ""
                 , image = ""
)

#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import leaflet
#' @import leafem
#' @import scales
#' @import stars
#' @import waiter
#' @noRd
app_ui <- function(request) {
  tagList(

    # Leave this function for adding external resources
    golem_add_external_resources(),

    # Your application UI logic
    fluidPage(

      theme = bs_theme(version = 5, bootswatch= "minty", font_scale = 1.25)
      ,autoWaiter()

      ####### TITLE - use RBE logo #######
      ,linebreaks(1)
      ,tags$figure(
            class = "centerFigure",
            tags$img(src = "www/rbe_logo.png"
                    ,width = 400
                    ,height = 200
                    ,alt = "Relax & Breath Easy study logo"
                    ,style = "display: block; margin-left: auto; margin-right: auto;"
                    )
      )

      #### SUBTITLE ####
      # ,h5("Relax & Breathe Easy is a research study to understand how parks and greenspaces affect individual and community health."
      #     , align = "center"
      #     )

      #### Main panel with tabs for different data displays ####
      ,hr()
      ,tabsetPanel(type = "tabs"
                    ,tabPanel("Combined Walk Map"
                              ,linebreaks(1)
                              ,HTML(paste("The <b>Combined Walk Map</b> includes data that was collected on different days, at different times, and by different people. Data was compiled (aggregated) into one map to look at overall trends."
                                          ,"<br><br>"
                                          ,"Participants walked around each park with devices that measured:"
                              )
                              ,"<br></br>"
                              )
                              ,fluidRow(column(HTML(paste("<b>Environmental Factors</b>"
                                                          ,"<br></br>"
                                                          ,"<ul>"
                                                          ,"<li>Temperature</li>"
                                                          ,"<li>Humidity</li>"
                                                          ,"<li>PM2.5 (Air Quality)</li>"
                                                          ,"</ul>"
                                                          ))
                                               , width  = 4
                                               )
                                       ,column(HTML(paste("<b>Stress Factors</b>"
                                                          ,"<br></br>"
                                                          ,"<ul>"
                                                          ,"<li>Heart Rate</li>"
                                                          ,"<ul>"
                                                          ,"<li><em>Heart rate is a measure that shows how fast the heart is beating.</em></li>"
                                                          ,"<li><em>The heart beats more quickly during times of stress, physical activity, excitement, etc.</em></li>"
                                                          ,"<li><em>The heart beats slower when resting and feeling more relaxed.</em></li>"
                                                          ,"</ul>"
                                                          ,"<li>Electrodermal Activity (EDA)</li>"
                                                          ,"<ul>"
                                                          ,"<li><em>EDA is a measure of electricity on your skin's surface due to sweat.</em></li>"
                                                          ,"<li><em>This can tell us more specifically if your increased heart rate is caused by a strong emotion such as excitement, fear, or stress.</em></li>"
                                                          ,"</ul>"
                                                          ,"</ul>"
                                                          ))
                                               , width = 8))
                              ,linebreaks(1)
                              ,HTML(paste("<b>Biodiversity</b> is a measure of variation in the types of life found in an ecosystem. Observations of targted groups of species (birds, mammals, etc.) were used to predict the expected biodiversity of all groups of species (plants, animals, fungi, protozoa, etc.) within each park. The predicted number of unique species is reported, where higher numbers would indicate more species and thus more biodiversity."))
                              ,linebreaks(2)
                              ,mod_aggmap_ui("tab1")
                              )
                    ,tabPanel("Individual Walk Map"
                              ,linebreaks(1)
                              ,HTML(paste("The <b>Individual Walk Map</b>'s environmental data is a snapshot of one selected walk at one time point (date and time listed on the route map). Stress variables include data from 1-4 people during the walk. Data was compiled (aggregated) into one map to look at overall trends."
                                          ,"<br><br>"
                                          ,"Participants walked around each park with devices that measured:"
                              )
                              ,"<br></br>"
                              )
                              ,fluidRow(column(HTML(paste("<b>Environmental Factors</b>"
                                                          ,"<br></br>"
                                                          ,"<ul>"
                                                          ,"<li>Temperature</li>"
                                                          ,"<li>Humidity</li>"
                                                          ,"<li>PM2.5 (Air Quality)</li>"
                                                          ,"</ul>"
                              ))
                              , width  = 4
                              )
                              ,column(HTML(paste("<b>Stress Factors</b>"
                                                 ,"<br></br>"
                                                 ,"<ul>"
                                                 ,"<li>Heart Rate</li>"
                                                 ,"<ul>"
                                                 ,"<li><em>Heart rate is a measure that shows how fast the heart is beating.</em></li>"
                                                 ,"<li><em>The heart beats more quickly during times of stress, physical activity, excitement, etc.</em></li>"
                                                 ,"<li><em>The heart beats slower when resting and feeling more relaxed.</em></li>"
                                                 ,"</ul>"
                                                 ,"<li>Electrodermal Activity (EDA)</li>"
                                                 ,"<ul>"
                                                 ,"<li><em>EDA is a measure of electricity on your skin's surface due to sweat.</em></li>"
                                                 ,"<li><em>This can tell us more specifically if your increased heart rate is caused by a strong emotion such as excitement, fear, or stress.</em></li>"
                                                 ,"</ul>"
                                                 ,"</ul>"
                                                 ))
                                      , width = 8))
                              ,linebreaks(2)
                              ,mod_walkmap_ui("tab2")
                              )
                   ,tabPanel("Vegetation Maps"
                              ,linebreaks(1)
                              ,HTML(paste("The <b>Vegetation Maps</b> show the normalized difference vegetation index (NDVI) for Milwaukee and La Crosse counties. The NDVI is a measure of greenness, or the health of plant life in an area, ranging from <b>-1</b> (<em>lack of vegetation</em>) to <b>1</b> (<em>healthy green vegetation</em>)."
                              )
                              )
                              ,linebreaks(2)
                              ,mod_ndvimap_ui("tab3")
                             )
                    ,tabPanel("Methods"
                              ,linebreaks(1)
                              ,HTML(paste("A total of 8 parks in Wisconsin (6 in Milwaukee and 2 in La Crosse) were surveyed during this study. Each park varies in biodiversity, greenspace, blue space, and other park features. Seventy-three (73) research participants were recruited from the project, with an emphasis on recruiting from communities that have historically been excluded from safe and easy access to greenspaces. Participants were asked to take a walk through a park while collecting individual and environmental health data."
                              ,"<br></br>"
                              ,"During the park walk, participants carried environmental monitoring devices (attached to a lightweight backpack) and a stress monitoring device (worn on the index finger of a participant)."
                              ,"<br></br>"
                              ,"<ul>"
                              ,"<li>Airbeam devices assessed air quality (PM2.5) throughout the walk.</li>"
                              ,"<li>A weather monitor assessed temperature, humidity, and other climate data.</li>"
                              ,"<li>GPS monitors to track their route.</li>"
                              ,"<li>An Emotibit device (biometric stress sensor) was worn on the index finger of study participants to assess their physiological stress levels such as heart rate and electrodermal activity (EDA).</li>"
                              ,"<ul>"
                              ,"<li>Heart rate is a measure that shows how fast the heart is beating. Examples of when the heart beats more quickly are during times of stress, physical activity, excitement, etc. The heart beats slower when resting and feeling more relaxed.</li>"
                              ,"<li>EDA is a measure of electricity on your skin's surface due to sweat. This can tell us more specifically if your increased heart rate is caused by a strong emotion such as excitement, fear, or stress.</li>"
                              ,"</ul>"
                              ,"</ul>"
                              )
                              )
                              ,linebreaks(1)
                              ,HTML(paste("Biodiversity is a measure of variation in the types of life found in an ecosystem. Observations of targted groups of species (birds, mammals, etc.) were used to predict the expected biodiversity of all groups of species (plants, animals, fungi, protozoa, etc.) within each park. The predicted number of unique species is reported, where higher numbers would indicate more species and thus more biodiversity."))
                              )
                   )
      )
    )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "rbe.golem"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()


  )


}
