# Calculate and Plot the Log2-Fold Abundance Ratio
Marian L. Schmidt  
December, 17, 2014  


###Objective
An odds-ratio is a good way to quantify and visualize how strong of an association a variable (in this case 16S tag-sequence abundance data) is between different exposures.  By exposure, I mean any categorical variable.  For example, it could be the experimentally-manipulated versus the control, or one treatment versus another or, as it is in the case of the example data, the surface of the lake versus the bottom of a lake during summer stratification.

The objective of the functions below is to three-fold:  
    **1.**  Create an abundance plot with standard errors.  
    **2.**  Calculate a log2-fold abundance ratio.  
    **3.**  Plot the log2-fold abundance ratio.  

###Input Data
The input data should be in the form of a data frame with **column names** that include: 

+ **Phylum:** Name of the Phylum of the organisms. 
+ **SeqAbundance:**  Sequence abundance for that sample.  
+ **PercentPhylum:** The percent abundance of the sequences in that sample.
+ One or more columns of categorical data. 
    + _**Note:**_ The categorical data must only include 2 factors.  
       
       

```r
data <- read.csv("InputData_ProdTop.csv", header = TRUE)
require(knitr)
kable(head(data[(1:3),]), format = "markdown")
```



|sample |Phylum              | SeqAbundance| PercentPhylum|trophicstate |filter |limnion |
|:------|:-------------------|------------:|-------------:|:------------|:------|:-------|
|BAKE1  |Alphaproteobacteria |          385|          3.74|Productive   |Free   |Top     |
|BAKE1  |Betaproteobacteria  |         2116|         20.53|Productive   |Free   |Top     |
|BAKE1  |Deltaproteobacteria |          345|          3.35|Productive   |Free   |Top     |

In the above dataframe "trophicstate", "filter" and "limnion" are all categories that include 2 factors.

###Functions  
_**Important note:** These functions require the summarySE function from the [R Cookbook](http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/).  Here, I have added the function to a text file called "RCookbook_summarySE.R" that I source within the functions._ 


+ **abundPlot:** Calculates the standard error and then plots the relative abundances based on a column in the input dataframe named "PercentPhylum". 
+ **log2fold_calc:**  Calculates the log2-fold abundance odds ratio with column named SeqAbundance based on factor of your choosing.  
    + **Input:** A dataframe and a category.  *Must use quotes around the category!
    + **Output:** A list containing 2 variables including: 
        1. *deleted_data:* Data frame of deleted data including Infs, -Infs, and NaN.  
        2. *ratio_data:* Data frame of log2-fold abundance ratio to beused in oddsratio_plot function.
+ **oddsratio_plot:**  Creates a graph with the log2fold_calc output function.  
    + **Input:**  The following 3 things:
          1. The ratio_data output from the log2fold_calc function. 
          2. First Legend Label.  
          3. Second Legend Label.  
    + **Output:** A pretty graph with the listed legend labels.


####  Before we go odds ratio-ing, let's make a plot of the relative abundances first!
##### We can use the abundPlot function

```r
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

abundPlot(data)
```

<img src="README_files/figure-html/abundPlot-1.png" title="" alt="" style="display: block; margin: auto;" />


####To Calculate and Plot the Log2-Fold Abundance Ratio
#####Calculate with log2fold_calc function
#####Plot with oddsratio_plot

```r
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
```



###Example Dataset Using the Functions

```r
freeprod <- log2fold_calc(data, "limnion")
freeprod_data <- freeprod$ratio_data
oddsratio_plot(freeprod_data, "Top", "Bottom")
```

<img src="README_files/figure-html/example data-1.png" title="" alt="" style="display: block; margin: auto;" />



