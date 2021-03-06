library(shiny)
shinyUI(fluidPage(
  titlePanel("Text Mining App"),
  sidebarLayout(
    sidebarPanel( " ",
                  textInput('dest1', label = 'Enter full path with filename for document'),
                  textInput('servername', label = 'Enter external url for downloading documents'),
                  actionButton("submitserverName", "Submit"),
                  tags$div(
                    
                    tags$hr()
                  ),
                  textInput('dest2', label = 'Enter directory name for downloaded documents'),
                  textInput('username', label = 'Enter email username '),
                  passwordInput('password', label = 'Enter password '),
                  textInput('label', label = 'Label : '),
                  actionButton("submitmail", "Submit")
    ),
    mainPanel(
      # "Document Analysis", 
      #         h1('Word cloud'), 
      #         plotOutput("plot1"),
      #         tags$div(
      #           
      #           tags$hr()
      #         ),
      #         h1('Frequency Plot'), 
      #         plotOutput("plot2")
      #         # h1('Cluster plots'), 
      #         # plotOutput("plot3")
              
              tabsetPanel(
                tabPanel("Word Cloud", plotOutput("plot1")),
                tabPanel("Frequency Plot", plotOutput("plot2"))
              )
    )
  )))
