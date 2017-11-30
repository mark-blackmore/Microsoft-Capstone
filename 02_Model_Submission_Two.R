#' ---
#' title: "Modeling: Submission Two"
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

#' ## Ranger model
set.seed(1010)
modelranger <- train(repayment_rate~.,
  data = train, method = "ranger",
  preProcess = c("medianImpute"),
  #tuneGrid = data.frame(mtry = seq(180, 270, length = 10)),
  na.action = na.pass,
  trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))

modelranger
plot(modelranger)

getTrainPerf(modelranger)
# modelrangerout <- predict(modelranger, test, na.action = na.pass)
