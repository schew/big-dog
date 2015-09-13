library(shiny)
library(ggplot2)
library(robustbase)
library(reshape)

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {

  # Expression that generates a plot of the distribution. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #
  Marginals <- function(data,name,type){	
	if (type == "hist"){
		p <- ggplot(data, aes_q(x = as.name(name))) + geom_histogram(fill = "deepskyblue2", alpha = 0.2, color = "white") + title("Marginal Distribution") + ylab('Counts')
	} else if (type == "kd"){
		p <- ggplot(data, aes_q(x = as.name(name))) + geom_density(fill = "blue" , alpha = 0.2) + title("Marginal Distribution") + ylab('Density')
	}
	else{
		 p <- ggplot(data, aes_q(x = as.name(name))) + geom_histogram(aes(y = ..density..), fill = "deepskyblue2", color = "white", alpha = 0.2) + geom_density(fill = "blue" , alpha = 0.2) + title("Marginal Distribution") + ylab('Density')
	}
	
	p <- p + theme(text = element_text(size=20))
			 
  }
  
  Outliers <- function(data,cutoff_in){
  
	num_cols <- dim(data)[1]

	mahalanobis_dist <- mahalanobis(data,colMeans(data),cov(data))
	
	cutoff <- qchisq(1 - cutoff_in / 100, 4, ncp = 0, lower.tail = TRUE, log.p = FALSE)
	
	outlier <- mahalanobis_dist > cutoff
	
	df_outliers <- data.frame(x = c(1:dim(data)[1]), y = log(sqrt(mahalanobis_dist)), z = outlier)
	
	p <- ggplot(df_outliers,aes(x = x,y = y))
	
	p <- p + geom_point(aes(colour = z)) + geom_abline(intercept = log(sqrt(cutoff)), slope = 0,linetype="dashed",colour = "red") + labs(x = "Observation Number",y = "log(Mahalanobis Distances)", title = paste("Outlier Plot")) + scale_colour_manual(name="Type", values = c("FALSE" = "blue","TRUE" = "#FF0080"), breaks=c("TRUE", "FALSE"), labels=c("Outlier", "Inlier"))	
	
	p <- p + theme(text = element_text(size=20))
  }
  
  Correlation <- function(data){
	data_t <- data[,order(colnames(data))]
	result <- cor(data_t)

	temp <- result
	temp[lower.tri(temp)] <- NA
	temp <- melt(temp)
	temp <- na.omit(temp)
	
	p <- ggplot(temp, aes(X2, X1, fill = value)) + geom_tile(alpha = 0.8, colour = "white") + scale_fill_gradient2(low = "steelblue", high = "red", midpoint = 0, limit = c(-1,1))
	base_size <- 14
	
	p <- p + theme_grey(base_size = base_size) + labs(x = "", y = "") + scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) + theme(axis.ticks = element_blank(),legend.text = element_text(size = base_size)) + ggtitle("Coefficient of Determination Heatmap")
	
	p <- p + theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1), text = element_text(size=20), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank())
  }
  
  output$MarginalPlot <- renderPlot({
    p <- Marginals(data,input$col_names,input$show_type)
    print(p)
  })
  
  output$Outliers <- renderPlot({
	p <- Outliers(data,input$pval)
	print(p)
  })
  
  output$Corr <- renderPlot({
	p <- Correlation(data)
	print(p)
  })
})