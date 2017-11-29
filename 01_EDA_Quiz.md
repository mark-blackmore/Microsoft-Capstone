Exploratory Data Analysis for Quiz
================
Mark Blackmore
2017-11-29

-   [Read Pre-Processed Data](#read-pre-processed-data)
-   [Explore Target Varaible: Repayment Rate](#explore-target-varaible-repayment-rate)
-   [Session info](#session-info)

Read Pre-Processed Data
-----------------------

``` r
train <- readRDS("./data_processed/train")
test  <- readRDS("./data_processed/test")
```

Explore Target Varaible: Repayment Rate
---------------------------------------

``` r
# summary(train)
ggplot(data = train, aes(x = repayment_rate)) + geom_histogram(bins = 10) +
  ggtitle("Repyment Rate")
```

![](01_EDA_Quiz_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-1.png)

Median repayment rate by school ownership

``` r
train %>% group_by(school__ownership) %>% 
  summarise(med = median(repayment_rate)) %>% 
  arrange(med)
```

    ## # A tibble: 3 x 2
    ##    school__ownership      med
    ##                <chr>    <dbl>
    ## 1 Private for-profit 33.24211
    ## 2             Public 52.39247
    ## 3  Private nonprofit 67.49296

SAT score vs repayent rate

``` r
summary(train$admissions__sat_scores_average_overall)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##     720     973    1039    1058    1121    1505    6816

``` r
ggplot(data = train, aes(x = admissions__sat_scores_average_overall, 
                         y = repayment_rate)) + 
  geom_point() + geom_smooth()
```

    ## `geom_smooth()` using method = 'gam'

    ## Warning: Removed 6816 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 6816 rows containing missing values (geom_point).

![](01_EDA_Quiz_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-1.png)

Median family income vs repayent rate

``` r
summary(train$student__demographics_median_family_income)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
    ##       0   15192   20771   27979   34095  122446       8

``` r
ggplot(data = train, aes(x = student__demographics_median_family_income, 
                         y = repayment_rate)) + 
  geom_point() + geom_smooth()
```

    ## `geom_smooth()` using method = 'gam'

    ## Warning: Removed 8 rows containing non-finite values (stat_smooth).

    ## Warning: Removed 8 rows containing missing values (geom_point).

![](01_EDA_Quiz_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-5-1.png)

Region id vs repayment rate

``` r
train %>% group_by(school__region_id) %>% 
  summarise(med = median(repayment_rate)) %>%
  arrange(med)
```

    ## # A tibble: 11 x 2
    ##                                             school__region_id      med
    ##                                                         <chr>    <dbl>
    ##  1 Southeast (AL, AR, FL, GA, KY, LA, MS, NC, SC, TN, VA, WV) 34.97926
    ##  2                                 Southwest (AZ, NM, OK, TX) 35.72182
    ##  3            Outlying Areas (AS, FM, GU, MH, MP, PR, PW, VI) 39.84485
    ##  4                          Far West (AK, CA, HI, NV, OR, WA) 43.87456
    ##  5                           Great Lakes (IL, IN, MI, OH, WI) 45.35676
    ##  6                       Rocky Mountains (CO, ID, MT, UT, WY) 47.89084
    ##  7                          Mid East (DE, DC, MD, NJ, NY, PA) 54.06988
    ##  8                        Plains (IA, KS, MN, MO, NE, ND, SD) 54.13311
    ##  9                                                       <NA> 58.89437
    ## 10                       New England (CT, ME, MA, NH, RI, VT) 62.00245
    ## 11                                       U.S. Service Schools 90.75529

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
    ##  [1] bindrcpp_0.2        VIM_4.7.0           data.table_1.10.4-2
    ##  [4] colorspace_1.3-2    ranger_0.8.0        glmnet_2.0-13      
    ##  [7] foreach_1.4.3       Matrix_1.2-11       caret_6.0-77       
    ## [10] lattice_0.20-35     dplyr_0.7.4         purrr_0.2.3        
    ## [13] readr_1.1.1         tidyr_0.7.1         tibble_1.3.4       
    ## [16] ggplot2_2.2.1       tidyverse_1.1.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] nlme_3.1-131       pbkrtest_0.4-7     lubridate_1.6.0   
    ##  [4] dimRed_0.1.0       httr_1.3.1         rprojroot_1.2     
    ##  [7] tools_3.4.2        backports_1.1.1    R6_2.2.2          
    ## [10] rpart_4.1-11       mgcv_1.8-20        lazyeval_0.2.0    
    ## [13] nnet_7.3-12        withr_2.1.0        sp_1.2-5          
    ## [16] tidyselect_0.2.2   mnormt_1.5-5       compiler_3.4.2    
    ## [19] quantreg_5.34      rvest_0.3.2        SparseM_1.77      
    ## [22] xml2_1.1.1         labeling_0.3       scales_0.5.0      
    ## [25] sfsmisc_1.1-1      lmtest_0.9-35      DEoptimR_1.0-8    
    ## [28] psych_1.7.8        robustbase_0.92-8  stringr_1.2.0     
    ## [31] digest_0.6.12      foreign_0.8-69     minqa_1.2.4       
    ## [34] rmarkdown_1.6      pkgconfig_2.0.1    htmltools_0.3.6   
    ## [37] lme4_1.1-14        rlang_0.1.2        readxl_1.0.0      
    ## [40] ddalpha_1.3.1      bindr_0.1          zoo_1.8-0         
    ## [43] jsonlite_1.5       ModelMetrics_1.1.0 car_2.1-6         
    ## [46] magrittr_1.5       Rcpp_0.12.13       munsell_0.4.3     
    ## [49] stringi_1.1.5      yaml_2.1.14        MASS_7.3-47       
    ## [52] plyr_1.8.4         recipes_0.1.1      parallel_3.4.2    
    ## [55] forcats_0.2.0      haven_1.1.0        splines_3.4.2     
    ## [58] hms_0.3            knitr_1.17         boot_1.3-20       
    ## [61] reshape2_1.4.2     codetools_0.2-15   stats4_3.4.2      
    ## [64] CVST_0.2-1         glue_1.1.1         evaluate_0.10.1   
    ## [67] laeken_0.4.6       modelr_0.1.1       vcd_1.4-3         
    ## [70] nloptr_1.0.4       MatrixModels_0.4-1 cellranger_1.1.0  
    ## [73] gtable_0.2.0       kernlab_0.9-25     assertthat_0.2.0  
    ## [76] DRR_0.0.2          gower_0.1.2        prodlim_1.6.1     
    ## [79] broom_0.4.2        e1071_1.6-8        class_7.3-14      
    ## [82] survival_2.41-3    timeDate_3042.101  RcppRoll_0.2.2    
    ## [85] iterators_1.0.8    lava_1.5.1         ipred_0.9-6
