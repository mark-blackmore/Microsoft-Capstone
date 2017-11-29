#' ---
#' title: "Exploratory Data Analysis for Quiz"
#' author: "Mark Blackmore"
#' date: "`r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#' ---
#' 
#+ startup, echo = FALSE 
rm(list = ls())
suppressPackageStartupMessages({
  library(tidyverse)
  library(caret)
  library(glmnet)
  library(ranger)
  library(VIM)
})  

#' ## Read Pre-Processed Data 
train <- readRDS("./data_processed/train")
test  <- readRDS("./data_processed/test")

#' 
#' ## Explore Target Varaible: Repayment Rate
#+ messages = FALSE
# summary(train)
ggplot(data = train, aes(x = repayment_rate)) + geom_histogram(bins = 10) +
  ggtitle("Repyment Rate")

#' Median repayment rate by school ownership
train %>% group_by(school__ownership) %>% 
  summarise(med = median(repayment_rate)) %>% 
  arrange(med)

#' SAT score vs repayent rate  
summary(train$admissions__sat_scores_average_overall)
ggplot(data = train, aes(x = admissions__sat_scores_average_overall, 
                         y = repayment_rate)) + 
  geom_point() + geom_smooth()

#' Median family income vs repayent rate  
summary(train$student__demographics_median_family_income)
ggplot(data = train, aes(x = student__demographics_median_family_income, 
                         y = repayment_rate)) + 
  geom_point() + geom_smooth()

#' Region id vs repayment rate  
train %>% group_by(school__region_id) %>% 
  summarise(med = median(repayment_rate)) %>%
  arrange(med)

#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()