#This file contains 3 functions:
#1. abundPlot
#2. log2fold_calc
#3. oddsratio_plot

abundPlot <- function(dataframe){ #uses PercentPhylum column to make an abundance plot
  source("RCookbook_summarySE.R")
  require(ggplot2)
  sum_stats <- summarySE(dataframe, measurevar = "PercentPhylum", groupvars = "Phylum") #sum_stats is a data frame for the relative abundance figure
  sum_stats$Phylum <- factor(sum_stats$Phylum, levels = sum_stats$Phylum[order(sum_stats$PercentPhylum)])  #Order by the SeqAbundance
  abund <- subset(sum_stats,PercentPhylum > 0.1)
  abundPlot <- ggplot(abund, aes(y=PercentPhylum, x=Phylum))  +
    geom_bar(stat="identity", position=position_dodge(),  fill = "darkorchid3", colour = "black") +
    theme_bw() + ggtitle("Phyla Above 0.1% in All Samples") +
    xlab("Phylum") + ylab("Mean Relative Abundance (%)") +
    geom_errorbar(aes(ymin = PercentPhylum -se, ymax = PercentPhylum +se), width = 0.25) + coord_flip() +
    theme(axis.title.x = element_text(face="bold", size=16),
          axis.text.x = element_text(angle=0, colour = "black", size=14),
          axis.text.y = element_text(colour = "black", size=14),
          axis.title.y = element_text(face="bold", size=16),
          plot.title = element_text(face="bold", size = 20),
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size = 12),
          legend.position="none")
  return(abundPlot)
}



#This function takes one dataframe and a category to make a log2-fold abundance ratio dataframe
#Must put category in quotes!
log2fold_calc <- function(dataframe, category){  #must have SeqAbundance and Phylum columns, category column must only have 2 categories. 
  source("RCookbook_summarySE.R")
  stats <- summarySE(dataframe, measurevar = "SeqAbundance", groupvars = c(category, "Phylum"))
  colnames(stats)[which(names(stats) == "SeqAbundance")] <- "Mean_SeqAbundance"  #Change column name to represent what value really is
  erp <- split(stats, stats[,category])  ### make 2 data frames and split the 2  
  dataframe1 <- erp[[2]]
  dataframe2 <- erp[[1]]  
  #Make a new data frame with the log2-fold ratio
  data_ratio <- log2(dataframe1$Mean_SeqAbund/dataframe2$Mean_SeqAbund) #creates a vector with log2 values
  data_ratio <- data.frame(dataframe2$Phylum, data_ratio) #combine the Phylum names with it
  names(data_ratio)[1:2]<-c("Phylum", "Ratio") #Rename the column names to better represent
  #Help to position labels on graph:  http://learnr.wordpress.com/2009/06/01/ggplot2-positioning-of-barplot-category-labels/
  data_ratio$colour <- ifelse(data_ratio$Ratio < 0, "firebrick1","steelblue") #Adds a column with 2 colors for easy plotting
  data_ratio$hjust <- ifelse(data_ratio$Ratio > 0, 1.3, -0.3) # This is where the labels on the Y axis of the plot will be placed
  #Now we have to delete Phyla from our data frame that are Inf, -Inf, or NaN
  sub_data <- subset(data_ratio, data_ratio$Ratio != "Inf" & data_ratio$Ratio != "-Inf" & data_ratio$Ratio != "NaN")
  sub_data$Phylum <- factor(sub_data$Phylum, levels = sub_data$Phylum[order(sub_data$Ratio)])
  deleted_phy <- subset(data_ratio, data_ratio$Ratio == "Inf" | data_ratio$Ratio == "-Inf" | data_ratio$Ratio == "NaN")
  return(list(deleted_data = deleted_phy, ratio_data = sub_data))
}



#The following function will create a plot out of the "ratio_data" output from the log2fold_calc function above.
#Must put legend names in quotes!
oddsratio_plot <- function(dataframe, legend_label1, legend_label2){
  require(ggplot2)
  plot <- ggplot(dataframe, aes(y=Ratio, x = Phylum, label = Phylum, hjust=hjust, fill = colour)) + 
    geom_bar(stat="identity", position=position_dodge(), colour = "black") +
    geom_text(aes(y=0, fill = colour)) + theme_bw() + ylim(min(dataframe$Ratio),max(dataframe$Ratio)) +
    coord_flip() + ggtitle("Odds Ratio Plot") + 
    labs(y = "Log2-Fold Abundance Ratio", x = "") + scale_x_discrete(breaks = NULL) +
    scale_fill_manual(name  ="", breaks=c("steelblue", "firebrick1"), 
                      labels=c(legend_label1, legend_label2),
                      values = c("magenta4", "darkorange")) +
    theme(axis.title.x = element_text(face="bold", size=16),
          axis.text.x = element_text(angle=0, colour = "black", size=14),
          axis.text.y = element_text(colour = "black", size=12),
          axis.title.y = element_text(face="bold", size=16),
          plot.title = element_text(face="bold", size = 16),
          legend.title = element_text(size=12, face="bold"),
          legend.text = element_text(size = 12),
          legend.justification=c(1,0), legend.position="right"); 
  return(plot)
}