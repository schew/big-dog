library(shiny)
library(ggplot2)
library(robustbase)
library(xlsx)

DataScrubbing <- function(file_name) 
{
  # This function takes an excel spreadsheet with the first row as labels. It will cut off all rows beyond 100  
  # for the columns with both continuous/Discrete and categorical data and returns 
  # a data set with the first column as the header 
  
  file_name <- paste(file_name,".xlsx",sep="") # add excel extenstion 
  library(xlsx) # import excel library for reading 
  df <- read.xlsx(file_name,1,header=FALSE,stringsAsFactors = FALSE)
  columns <- df[1,]; # store the column names for future reference 
  df <- df[2:dim(df)[1],] # remove the first row 
  row_names <- df[,1]; 
  names(df) <- columns 
  
  # cut rows beyond 100 
  if (dim(df)[2]>100)
  {
  df <- df[,1:100] # chop dataframe down 
  }
  
  
  dataTypes <- vector(mode="character", length=dim(df)[2])  # define a vector to hold each columns data type 
  # we loop through each column and determine its type 
  for (i in 1:dim(df)[2])
  {
    # first task is to scrub the data 
    df[,i] <- gsub(" ", "", df[,i]) # remove spaces 
    df[,i] <- tolower(df[,i])
    # check to make sure there are no na n/a and we missed this as continuous data 
    na_indi <- which(df[,i] =="na" | df[,i]=="n/a")
    if (length(na_indi) > 0 ) # we found some Nas 
    {
      df[na_indi,i] <- NA
    }
    
    na_indi <- sum(is.na(df[,i])) # get initial count of na indices 
    
    # check if it is numeric by converting to it 
    test <- df[,i] # holder variable 
    test <- as.numeric(test) 
    na_indi2 <- sum(is.na(test))
    
    if (na_indi2>na_indi) #must be characters 
    {
      dataTypes[i] <- "character"
      
    } else 
    { 
        dataTypes[i] <- "double"
        df[,i] <- test
        
    }
  }
  
  # we now look to convert to factors 

  for (i in 1:(dim(df)[2]))
  {
    if (dataTypes[i] == "character")
    {
      dataTypes[i] = "factor"
      df[,i] <- as.factor(df[,i])
      if (nlevels(df[,i]) > 6) # bad column and we delete 
      {
        # df[,i] <- NULL # remove column 
        dataTypes[i] <- 0 # mark to remove data type
      }
      
    }
  }
  r_indi <- which(dataTypes == 0)
  df[,r_indi] <- NULL 
  dataTypes <- dataTypes[-r_indi] 
  df <- cbind(row_names,df)
  return(list(dataTypes,df))
}

input <- DataScrubbing("Census_Demographics_2010")

input_data <- input[[2]]

row_names <- input_data[,1]

input_data[,1] <- NULL

data <- input_data

# Define UI for application that plots random distributions 
shinyUI(navbarPage("Big Dog Analytics", id = "tabs",
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