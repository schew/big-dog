library(shiny)
library(ggplot2)
library(robustbase)
library(xlsx)

# Define UI for application that plots random distributions 
shinyUI(navbarPage("Big Dog Analytics", id = "tabs",
  tabPanel("Data", value = "D",
	mainPanel(
		dataTableOutput(outputId="table")
	)  
  ),
  tabPanel("Marginal Distributions", value = "MD",
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
	selectInput(inputId = "col_names",
				label = "Select",
				colnames(data)), 
				
	selectInput(inputId = "show_type",
				label = "Select",
				list("Histogram" = "hist", 
				 "Kernel Density" = "kd", 
				 "Combined" = "comb")) 
  ),

  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("MarginalPlot")
  )  
  ),
  tabPanel("Outlier Analysis", value = "OA",
	sidebarPanel(
		sliderInput(inputId = "pval", label = "Rejection P-Value", min=0, max=10, value=5, step = 1)
	),
  mainPanel(
    plotOutput("Outliers")
  )
  ),
  tabPanel("Correlation Analysis", value = "CA",
	sidebarPanel(),
  mainPanel(
    plotOutput("Corr", click = "plot_click"
        ),
		verbatimTextOutput("click_info")
	)
   ),
  tabPanel("Mean Vector", value = "MV",
	sidebarPanel(),
  mainPanel(
    plotOutput("Mean_o")
  )
  )
))