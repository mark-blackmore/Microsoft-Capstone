#' ---
#' title: "Exploratory Data Analysis for Modeling"
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

#' ## Missing Data
missingTrain <- apply(train, 2, function(x) sum(is.na(x)/length(x)))
hist(missingTrain, main = "Missing Values", xlab = "Proportion Missing")

#' Missing Values fraction by column
missCol <- apply(train, 2, function(x) sum(is.na(x)/length(x)))  
missRow <- apply(train, 1, function(x) sum(is.na(x)/length(x))) 

#' Distribution of Missing Values
hist(missCol, main = "Missing Values by Column", xlab = "Proportion Missing")
hist(missRow, main = "Missing Values by Row", xlab = "Proportion Missing")

#' ## Look for Potential Explanatory Variables
#' Carnegie Basic vs. Repayment Rate
train %>% group_by(school__carnegie_basic) %>% 
  summarise(med = median(repayment_rate)) %>% arrange(med)

ggplot(data = train, aes(x = school__carnegie_basic, 
                         y = repayment_rate)) + geom_boxplot()

#' Report Year vs. Repayment Rate
train %>% group_by(report_year) %>% 
  summarise(med = median(repayment_rate)) %>% arrange(med)

ggplot(data = train, aes(x = report_year, 
                         y = repayment_rate)) + geom_boxplot()

#' EDA - Relevant
ggplot(data = train, aes(x = aid__loan_principal, 
                         y = repayment_rate)) + geom_point() + geom_smooth() 

ggplot(data = train, aes(x = aid__pell_grant_rate, 
                         y = repayment_rate)) + geom_point() + geom_smooth() 

#' More EDA - Noise
ggplot(data = train, aes(x = admissions__admission_rate_overall, 
                         y = repayment_rate)) + geom_point() 

ggplot(data = train, aes(x = aid__cumulative_debt_number, 
                         y = repayment_rate)) + geom_point() + geom_smooth()

ggplot(data = train, aes(x = aid__federal_loan_rate, 
                         y = repayment_rate)) + geom_point() + geom_smooth()

ggplot(data = train, aes(x = admissions__admission_rate_overall, 
                         y = repayment_rate)) + geom_point() 

#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()