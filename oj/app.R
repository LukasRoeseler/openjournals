# Load Packages -----------------------------------------------------------

# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/packages.R")


# # read databases
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_scimago.R")
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_topfactor.R")
# 
# # combine databases
# source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/combine_data.R")




# Define UI ---------------------------------------------------------------

ui <- fluidPage(

    navbarPage("Open Journal Data v0.1"
               
               , tabPanel("Database",

        # Show a plot of the generated distribution
        mainPanel(
            dataTableOutput("ojtable")
        )
               )
        , tabPanel("Summary"
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
    
    p <- ggplot(oj, aes(x = Total)) + geom_histogram() +
      theme_classic()
    
    plotly::ggplotly(p)
  })
  
  
  
  
  output$about <- renderText({
    print(versioninfo)
  })
}


shinyApp(ui = ui, server = server)