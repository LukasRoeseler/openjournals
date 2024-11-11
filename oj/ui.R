# Load Packages -----------------------------------------------------------

source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/packages.R")


# read databases
source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/read_data/read_scimago.R")
source("https://github.com/LukasRoeseler/openjournals/blob/main/read_data/read_topfactor.R")

# combine databases
source("https://raw.githubusercontent.com/LukasRoeseler/openjournals/refs/heads/main/combine_data.R")




# Define UI ---------------------------------------------------------------

fluidPage(

    # Application title
    titlePanel("Open Journal Data v0.1"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
)
