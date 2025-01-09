# Load Packages -----------------------------------------------------------

source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/packages.R")


# read databases
source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_scimago.R")
source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_topfactor.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_fred.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_i4rreproductions.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_nordiclist.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_retractions.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_rwhjc.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_vhb.R")

# combine databases
source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/combine_data.R")




# Define UI ---------------------------------------------------------------

ui <- fluidPage(

    navbarPage("Open Journal Data v0.1"
               
               , tabPanel("Database",

        # Show a plot of the generated distribution
        mainPanel(
            dataTableOutput("ojtable")
        )
               )
        , tabPanel("Plot"
                   , selectInput("x", "Variable 1", choices = names(oj), selected = "sjr")
                   , selectInput("y", "Variable 2", choices = names(oj), selected = "Total")
                   , shiny::includeMarkdown("summary.md")
                   , plotly::plotlyOutput("topfactors")
                   )
        , tabPanel("About"
                   , shiny::includeMarkdown("about.md")
                   )
        
    )
    
)




# Server ------------------------------------------------------------------



# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$ojtable <- DT::renderDataTable({
    
    DT::datatable(oj[, c("title", "issn", "sjr", "h_index", "total_docs_3years", "country", "publisher", "Total", "Author.guideline.url")]
              , rownames = FALSE
              , class = 'cell-border stripe'
              , callback = DT::JS("
var tips = ['Journal name', 'ISSN', 'Scimago Journal Rank',
            'Hirsch Index', 'Number of Publications within the last three years'
            , 'Country', 'Publisher', 'TOP Factor', 'Link to author guidelines'],
    header = table.columns().header();
for (var i = 0; i < tips.length; i++) {
  $(header[i]).attr('title', tips[i]);
}
")
              )
    
  })
  
  
  
  
  output$topfactors <- plotly::renderPlotly({
    
    oj$x <- oj[, input$x]
    oj$y <- oj[, input$y]
    
    p <- ggplot(oj, aes(x = x, y = y)) + geom_point() +
      theme_classic()
    
    plotly::ggplotly(p)
  })
  
  
  
  
  output$about <- renderText({
    print(versioninfo)
  })
}


shinyApp(ui = ui, server = server)