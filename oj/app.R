# Load Packages -----------------------------------------------------------
### Install packages

# load packages
library(bslib)
library(shiny)
library(DT)
library(ggplot2)
library(psych)
library(devtools)
library(sjrdata)
library(ggplot2)
library(ggpubr)
library(openxlsx)
library(RCurl)
library(markdown)
library(shinylive)
library(httpuv)


# Open Data ---------------------------------------------------------------
oj <- read.csv("2025-04-11_ojdb.csv")


# Style -------------------------------------------------------------------

custom_css <- ("
.tab-pane {
  padding: 0px 20px;
}
.tab-pane-narrow {
  width: 100%;
  max-width: 30cm;
}
 .navbar-default .navbar-brand {color:black;}
        .navbar-default .navbar-brand:hover {color:black;}
        .navbar { background-color:#EAEAEA;}
        .navbar-default .navbar-nav > li > a {color: dark grey;}
        .navbar-default .navbar-nav > .active > a,
        .navbar-default .navbar-nav > .active > a:focus,
        .navbar-default .navbar-nav > .active > a:hover {color:black;background-color:#fc2d2d;}
        .navbar-default .navbar-nav > li > a:hover {color:black;background-color:#A6A6A6;text-decoration}
        .page-like {
            background-color: white;
            padding: 20px;
            margin: 20px auto;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            max-width: 800px;
        }
")

custom_theme <- bslib::bs_theme(
  version = 5,
  bg = "#e3eeff", # white: #FFFFFF
  fg = "#382f2f",
  primary = "#094bb5",
  secondary = "#095fe8",
  base_font = "Calibri"
)


# Define UI ---------------------------------------------------------------

ui <- shiny::tagList(
  shinyjs::useShinyjs(),
  tags$head(tags$style(HTML(custom_css))),
  tags$script(HTML("
      $(document).on('shiny:inputchanged', function(event) {
    if (event.name === 'navbar') {
        var tabsWithoutSidebar = ['Dataset', 'References-Checker [alpha]', 'References', 'FAQ', 'About'];  // Tabs where sidebar should be disabled
      if (tabsWithoutSidebar.includes(event.value)) {
        $('#sidebar .shiny-input-container').not('#success_criterion').addClass('disabled');
        $('#sidebar-note').show();
      } else {
        $('#sidebar .shiny-input-container').removeClass('disabled');
        $('#sidebar-note').hide();
      }
    }
  });

  $(document).on('shiny:connected', function(event) {
    $('<style type=\"text/css\"> .shiny-input-container.disabled * { pointer-events: none; opacity: 0.5; } </style>').appendTo('head');
  });
  ")),
  fluidPage(

    navbarPage("Open Journal Data v0.2"
               
               , tabPanel("Database",

        # Show a plot of the generated distribution
        mainPanel(
            dataTableOutput("ojtable")
        )
               )
        , tabPanel("Plot"
                   , selectInput("x", "Variable X", choices = names(oj), selected = "sjr")
                   , selectInput("y", "Variable Y", choices = names(oj), selected = "top_factor")
                   , shiny::includeMarkdown("summary.md")
                   , plotly::plotlyOutput("topfactors")
                   )
        , tabPanel("About"
                   , shiny::includeMarkdown("about.md")
                   )
        
    )
    
)
)




# Server ------------------------------------------------------------------



# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  output$ojtable <- DT::renderDataTable({
    
    DT::datatable(oj[, c("title", "issn", "sjr", "h_index", "total_docs_3years", "country", "publisher", "top_factor", "Author.guideline.url")]
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
      theme_classic() + 
      xlab(paste(input$x)) + ylab(paste(input$y)) +
      theme_bw()
    
    plotly::ggplotly(p)
  })
  
  
  
  
  output$about <- renderText({
    print(versioninfo)
  })
}


shinyApp(ui = ui, server = server)
