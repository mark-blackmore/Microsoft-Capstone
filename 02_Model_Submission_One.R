#' ---
#' title: "Modeling: Submission One"
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

#' ## GLMNET Model, All Predictors
#' All Predictors,  FIRST SUBMISSION
#' Automated Selection, Using Zach Meyer suggestions for baseline
modNet = train(repayment_rate~., data = train, method = "glmnet",
                preProcess = c("nzv", "medianImpute", "center", "scale"),
                tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 1, length = 1000)),
                trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE),
                na.action = na.pass)
 modNet
 plot(modNet)
 getTrainPerf(modNet)  # Submitted as L1out
 modNetout <- predict(modNet, test, na.action = na.pass)
 varImp(modNet)

#' Create Submission
# L1out <- outformat
# L1out$repayment_rate <- modNetout
# head(L1out)
# write.csv(L1out, file = "L1out.csv", row.names = FALSE)







#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()