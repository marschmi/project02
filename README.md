Calculate and Plot the Log2-Fold Abundance Ratio
=========

##Objective
An odds-ratio is a good way to quantify and visualize how strong of an association a variable (in this case 16S tag-sequence abundance data) is between different exposures.  By exposure, I mean any categorical variable.  For example, it could be the experimentally-manipulated versus the control, or one treatment versus another or, as it is in this case, the surface of the lake versus the bottom of a lake during summer stratification.

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
       
       
###Functions  
_**Important note:** These functions require the summarySE function from the [R Cookbook](http://www.cookbook-r.com/Graphs/Plotting_means_and_error_bars_(ggplot2)/).  Here, I have added the function to a text file called "RCookbook_summarySE.R" that I source within the functions._ 

Please see the "Project_Description.Rmd" file or the "oddsratio_functions.R" for the description of the functions with a mock data set or the raw functions in a .R file, respectively.


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
