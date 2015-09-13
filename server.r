library(shiny)
library(ggplot2)
library(robustbase)
library(reshape)
library(xlsx)
library(grid)
library(fastcluster)

shinyServer(function(input, output) {
	ranges <- reactiveValues(y = NULL)
	show_outliers <- reactiveValues(Names = NULL, Distances = NULL)
	
  Marginals <- function(data,name,type){
    #print(name)
	
	
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

	mahalanobis_dist <- mahalanobis(data,colMeans(data),cov(data), ,tol=1e-20)
	
	cutoff <- qchisq(1 - cutoff_in / 100, dim(data)[2], ncp = 0, lower.tail = TRUE, log.p = FALSE)
	
	outlier <- mahalanobis_dist > cutoff
	
	df_outliers <<- data.frame(x = c(1:dim(data)[1]), y = log(sqrt(mahalanobis_dist)), z = outlier)
	
	
	show_outliers$Names <<- row_names[df_outliers[,3]]
	show_outliers$Distances <<- mahalanobis_dist[df_outliers[,3]]
	
	
	p <- ggplot(df_outliers,aes(x = x,y = y))
	
	p <- p + geom_point(aes(colour = z)) + geom_abline(intercept = log(sqrt(cutoff)), slope = 0,linetype="dashed",colour = "red") + labs(x = "Observation Number",y = "log(Mahalanobis Distances)", title = paste("Outlier Plot")) + scale_colour_manual(name="Type", values = c("FALSE" = "blue","TRUE" = "#FF0080"), breaks=c("TRUE", "FALSE"), labels=c("Outlier", "Inlier"))	
	
	p <- p + theme(plot.title = element_text(vjust=2), text = element_text(size=20))
	
	return(list(df_outliers,p))
  }
  
  Scree_Plot <- function(data){
	result <- prcomp(data, center = TRUE, scale = TRUE)
	retained_variance <- cumsum(unlist(result[1])^2) /  max(cumsum(unlist(result[1])^2))
	
	df <- data.frame(x = c(1:dim(data)[2]), y = retained_variance)
	
	p <- ggplot(df, aes(x = x,y = y)) + xlab('Retained Dimensions') + ylab('Explained Variance') + ggtitle('Scree Plot')
	p <- p + geom_point() + geom_line() + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x=element_text(angle=45))	
  }
  
  Correlation <- function(data){
	data_t <- data[,order(colnames(data))]
	result <- cor(data_t)

	temp <- result
	temp[lower.tri(temp)] <- NA
	temp <- melt(temp)
	temp <- na.omit(temp)
	
	p <- ggplot(temp, aes(X2, X1, fill = value)) + geom_tile(alpha = 0.5, colour = "white") + scale_fill_gradient2(low = "steelblue", high = "red", mid = "violet", midpoint = 0, limit = c(-1,1), name = "Pearson\ncorrelation\n")
	base_size <- 14
	
	p <- p + theme_grey(base_size = base_size) + labs(x = "", y = "") + scale_x_discrete(expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) + ggtitle("Correlation Heatmap")
	
	p <- p + theme(axis.ticks = element_blank(), plot.title = element_text(vjust=2), axis.text.x = element_text(angle=90, vjust = 0.6), axis.text.y = element_text(), text = element_text(size=20), legend.text=element_text(size=20), legend.title = element_text(size = 20)) + guides(fill = guide_colorbar(barwidth = 2, barheight = 10, title.position = "top", title.vjust = 10)) 
	
	#+ geom_text(aes(X2, X1, label = round(value,2)), color = "black", size = 10)

  }
  
  Mean_Vectors <- function(data, type){
	 num_vars <- dim(data)[2]
	
	 output_mean <<- vector()
	 output_se <<- vector()
	 for (i in c(1:num_vars)){
		name <- colnames(data)[i]
		
		output_mean[i] <<- mean(data[,i],na.rm = TRUE)	
		output_se[i] <<- sd(data[,i],na.rm = TRUE) / sqrt(length(data[,3][!is.na(data[,3])]))
	 }

	 index <<- output_mean < 100
	 names_to_use <- colnames(data)
	 
	 df <- data.frame(names = names_to_use[index], means = output_mean[index])
	 
	 keep_data <- data[,index]
	 keep_data <- melt(keep_data)
	 
	 if (type == "Scatter"){
		p <- ggplot(df, aes(x = names, y = means))
		 p <- p + geom_point() + ylab("Mean") + xlab("") + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x=element_text(angle=90, vjust = 0.6)) + ggtitle('Column Means') + coord_cartesian(ylim = ranges$y)
	 } else if(type == "Scatter with error bars"){
		limits <- aes(ymax = output_mean[index] + output_se[index], ymin=output_mean[index] - output_se[index])
		 p <- ggplot(df, aes(x = names, y = means))
		 p <- p + geom_point() + geom_errorbar(limits, width=0.3) + ylab("Mean") + xlab("") + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x=element_text(angle=90, vjust = 0.6)) + ggtitle('Column Means') + coord_cartesian(ylim = ranges$y)
	 } else if(type == "Violin Plot"){
		p <- ggplot(keep_data,aes(x = variable, y = value)) + geom_violin() + ylab("Mean") + xlab("") + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x=element_text(angle=90, vjust = 0.6)) + ggtitle('Column Means') + coord_cartesian(ylim = ranges$y)
	 } else{
		p <- ggplot(keep_data,aes(x = variable, y = value)) + geom_boxplot() + ylab("Mean") + xlab("") + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x=element_text(angle=90, vjust = 0.6)) + ggtitle('Column Means') + coord_cartesian(ylim = ranges$y)
	 }
  }
  
  Clustering <- function(data,num){
	clust <- hclust(dist(data), method = "complete")

	memb <- cutree(clust, k = num)
	
	fit <- prcomp(data, center=TRUE, scale = TRUE)
	
	df <- data.frame(x = fit$x[,1], y = fit$x[,2], z = memb)
	
	p <- ggplot(df,aes(x = x,y = y, colour = factor(z)))
	
	p <- p + geom_point(size = 5) + xlab('First Principal Component') + ylab('Second Principle Component') + theme(plot.title = element_text(vjust=2), text = element_text(size=20), axis.text.x = element_text(vjust = 2)) + scale_colour_discrete(name = "Clusters")	
   }
  
  output$MarginalPlot <- renderPlot({
    p <- Marginals(data,input$col_names,input$show_type)
    print(p)
  })
  
  output$Outliers <- renderPlot({
	result <- Outliers(data,input$pval)
	p <- result[2]
	outlier_data <<- result[[1]]
	#assign("outlier_data", result[[1]], envir = .GlobalEnv) 
	print(p)
  })
  
  output$Corr <- renderPlot({
	p <- Correlation(data)
	print(p)
  })
  
  output$Mean_o <- renderPlot({
	p <- Mean_Vectors(data,input$mean_type)
	print(p)
  })
  
  output$Clust <- renderPlot({
	p <- Clustering(data,input$num_clust)
	print(p)
  })
  
  output$Scree <- renderPlot({
	p <- Scree_Plot(data)
	print(p)
  })
  
  output$outlier_info <- renderDataTable({
	#paste0("x=", input$plot_click$x, "\ny=", input$plot_click$y)
	
    data.frame(Outlier_Names = show_outliers$Names, Distances = show_outliers$Distances)
	#nearPoints(df_outliers[,c(1:2)], input$plot_brush)#, xval = "x", yval = "y")
    # nearPoints() also works with hover and dblclick events
  })
  
  output$table <- renderDataTable({
	 result <- cbind(row_names,data)
	 result
  })
  
  observeEvent(input$plot1_dblclick, {
    brush <- input$plot1_brush
    if (!is.null(brush)) {
      ranges$y <- c(brush$ymin, brush$ymax)

    } else {
      ranges$y <- NULL
    }
  })
  
  
})