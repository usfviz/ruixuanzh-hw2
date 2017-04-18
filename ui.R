library(shiny)
library(googleVis)

shinyUI(fluidPage(
  sidebarLayout(
    
    sidebarPanel(
      h4("Ruixuan Zhang Gapminder Motion Chart")
    ),
    
    mainPanel(
      htmlOutput("bubble")
    )
  )
 )
)