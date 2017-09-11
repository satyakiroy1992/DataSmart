library(shiny)
shinyUI(fluidPage(
  titlePanel("Word Cloud"),
  sidebarLayout(
    
    sidebarPanel( " ", textInput('dest1', label = 'Enter path of audio file'),
                                     actionButton("submitDir", "Submit"),width = 2
    )
    ,mainPanel(tabsetPanel(
              type="tabs",
              tabPanel("Word cloud",fluidRow(column(width=12, align="left",tags$h3 ("Word Cloud"),
                                                                        plotOutput("plot1")))),
              tabPanel("Frequency Plot", tags$h3 ("Frequency Of Words"), plotOutput("plot2")),
              tabPanel(title="Sentiment Analysis", fluidRow(column(width=6, align="left",tags$h3 ("Emotional Trajectory"),
                                                                   plotOutput("plot3")),
                                                            column(width=6, align="left",tags$h3 ("Emotions in the text"),
                                                                   plotOutput("plot4")))
            ))
  )))
)
