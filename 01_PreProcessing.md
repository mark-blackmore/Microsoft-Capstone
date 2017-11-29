Data Pre-processing
================
Mark Blackmore
2017-11-29

-   [Read in the data](#read-in-the-data)
-   [Relevel factor variables](#relevel-factor-variables)
-   [Join Training Values and Training Labels](#join-training-values-and-training-labels)
-   [Write the processed train and test data to files](#write-the-processed-train-and-test-data-to-files)
-   [Session info](#session-info)

Read in the data
----------------

``` r
train_values <- read.csv("./data/train_values.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
train_labels <- read.csv("./data/train_labels.csv", header = TRUE)
test         <- read.csv("./data/test_values.csv",  header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
outformat    <- read.csv("./data/submission_format.csv", header = TRUE)
dim(outformat)  # Overwrite repayment_rates with predictions
```

    ## [1] 6391    2

Relevel factor variables
------------------------

Match levels in the test set with levels in the training set by re-leveling based on the entire data set.

``` r
totalData <- rbind(train_values, test)
for (f in 2:length(names(totalData))) {
  levels(train_values[, f]) <- levels(totalData[, f])
}
```

Join Training Values and Training Labels
----------------------------------------

Full Join of data by "row\_id"

``` r
trainall <- full_join(train_labels,train_values, by = "row_id")
```

Remove row\_id from train and test sets

``` r
train <- select(trainall,-row_id)
test  <- select(test, -row_id)
```

Write the processed train and test data to files
------------------------------------------------

``` r
saveRDS(train, "./data_processed/train")
saveRDS(test, "./data_processed/test")
```

------------------------------------------------------------------------

Session info
------------

``` r
sessionInfo()
```

    ## R version 3.4.2 (2017-09-28)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 15063)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] grid      stats     graphics  grDevices utils     datasets  methods  
    ## [8] base     
    ## 
    ## other attached packages:
    ##  [1] VIM_4.7.0           data.table_1.10.4-2 colorspace_1.3-2   
    ##  [4] ranger_0.8.0        glmnet_2.0-13       foreach_1.4.3      
    ##  [7] Matrix_1.2-11       caret_6.0-77        lattice_0.20-35    
    ## [10] dplyr_0.7.4         purrr_0.2.3         readr_1.1.1        
    ## [13] tidyr_0.7.1         tibble_1.3.4        ggplot2_2.2.1      
    ## [16] tidyverse_1.1.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] nlme_3.1-131       pbkrtest_0.4-7     lubridate_1.6.0   
    ##  [4] dimRed_0.1.0       httr_1.3.1         rprojroot_1.2     
    ##  [7] tools_3.4.2        backports_1.1.1    R6_2.2.2          
    ## [10] rpart_4.1-11       mgcv_1.8-20        lazyeval_0.2.0    
    ## [13] nnet_7.3-12        withr_2.1.0        sp_1.2-5          
    ## [16] tidyselect_0.2.2   mnormt_1.5-5       compiler_3.4.2    
    ## [19] quantreg_5.34      rvest_0.3.2        SparseM_1.77      
    ## [22] xml2_1.1.1         scales_0.5.0       sfsmisc_1.1-1     
    ## [25] lmtest_0.9-35      DEoptimR_1.0-8     psych_1.7.8       
    ## [28] robustbase_0.92-8  stringr_1.2.0      digest_0.6.12     
    ## [31] foreign_0.8-69     minqa_1.2.4        rmarkdown_1.6     
    ## [34] pkgconfig_2.0.1    htmltools_0.3.6    lme4_1.1-14       
    ## [37] rlang_0.1.2        readxl_1.0.0       ddalpha_1.3.1     
    ## [40] bindr_0.1          zoo_1.8-0          jsonlite_1.5      
    ## [43] ModelMetrics_1.1.0 car_2.1-6          magrittr_1.5      
    ## [46] Rcpp_0.12.13       munsell_0.4.3      stringi_1.1.5     
    ## [49] yaml_2.1.14        MASS_7.3-47        plyr_1.8.4        
    ## [52] recipes_0.1.1      parallel_3.4.2     forcats_0.2.0     
    ## [55] haven_1.1.0        splines_3.4.2      hms_0.3           
    ## [58] knitr_1.17         boot_1.3-20        reshape2_1.4.2    
    ## [61] codetools_0.2-15   stats4_3.4.2       CVST_0.2-1        
    ## [64] glue_1.1.1         evaluate_0.10.1    laeken_0.4.6      
    ## [67] modelr_0.1.1       vcd_1.4-3          nloptr_1.0.4      
    ## [70] MatrixModels_0.4-1 cellranger_1.1.0   gtable_0.2.0      
    ## [73] kernlab_0.9-25     assertthat_0.2.0   DRR_0.0.2         
    ## [76] gower_0.1.2        prodlim_1.6.1      broom_0.4.2       
    ## [79] e1071_1.6-8        class_7.3-14       survival_2.41-3   
    ## [82] timeDate_3042.101  RcppRoll_0.2.2     iterators_1.0.8   
    ## [85] bindrcpp_0.2       lava_1.5.1         ipred_0.9-6
