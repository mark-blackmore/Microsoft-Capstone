#' ---
#' title: "Data Pre-processing"
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

set.seed(1010)

#' ## Read in the data
train_values <- read.csv("./data/train_values.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
train_labels <- read.csv("./data/train_labels.csv", header = TRUE)
test         <- read.csv("./data/test_values.csv",  header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
outformat    <- read.csv("./data/submission_format.csv", header = TRUE)
dim(outformat)  # Overwrite repayment_rates with predictions

#' ## Relevel factor variables  
totalData <- rbind(train_values, test)
for (f in 2:length(names(totalData))) {
  levels(train_values[, f]) <- levels(totalData[, f])
}

# Full Join of data by "row_id"       
trainall <- full_join(train_labels,train_values, by = "row_id")

# Remove row_id from train and test sets
train <- select(trainall,-row_id)
test  <- select(test, -row_id)

#' ## Write the processed train and test data to files
saveRDS(train, "./data_processed/train")
saveRDS(test, "./data_processed/test")

#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()