#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic

      mod_aggmap_server("tab1")
      mod_walkmap_server("tab2")
      mod_ndvimap_server("tab3")
}
