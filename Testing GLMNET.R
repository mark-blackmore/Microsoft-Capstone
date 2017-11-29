#' ---
#' title: "Testing GLMNET, etc"
#' author: "Mark Blackmore"
#' date: "`r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#' ---
#'
#'#' ## Testing GLMNET, Etc.
#+ startup, echo = FALSE 
rm(list = ls())
suppressPackageStartupMessages({
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)
library(caret)
library(glmnet)
library(ranger)
})  
  
set.seed(1010)

#' ## Read in the data
train_values <- read.csv("./data/train_values.csv", header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
train_labels <- read.csv("./data/train_labels.csv", header = TRUE)
test         <- read.csv("./data/test_values.csv",  header = TRUE, stringsAsFactors = FALSE, na.strings = c("NA", ""))
outformat    <- read.csv("./data/submission_format.csv", header = TRUE)
dim(outformat)  # Overwrite repayment_rates with predictions

# Relevel factor variables
totalData <- rbind(train_values, test)
for (f in 2:length(names(totalData))) {
  levels(train_values[, f]) <- levels(totalData[, f])
}

# Full Join of data by "row_id"       
trainall <- full_join(train_labels,train_values, by = "row_id")

# Remove row_id from train and test sets
train <- select(trainall,-row_id)
test  <- select(test, -row_id)

########################################################################################
# # # All Predictors,  FIRST SUBMISSION # COPIED TO CAPSTON
# # Automated Selection, Using Zach Meyer suggestions for baseline
# modNet = train(repayment_rate~., data = train, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 10, length = 1000)),
#             trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE),
#             na.action = na.pass)
# modNet
# plot(modNet)
# getTrainPerf(modNet)  # Submitted as L1out
# modNetout <- predict(modNet, test, na.action = na.pass)
# varImp(modNet)

########################################################################################
# Remove Admissions, Academics, Completion
## Slightly worse than prior experiments
# subTrain <- select(train, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))
# subTest <- select(test, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))

# modSub = train(repayment_rate~., data = subTrain, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.000001, 1, length = 1000)),
#             trControl = trainControl(method = "cv", number = 5, verboseIter = TRUE),
#             na.action = na.pass)
# modSub
# plot(modSub)
# getTrainPerf(modSub)
# modNetout <- predict(modSub, subTest, na.action = na.pass)
#######################################################################################
# Variables with near zero variance
# nzv <- nearZeroVar(train_imp, names = TRUE, freqCut = 2, uniqueCut = 20) # shows names
#
# Impose stronger filter on near zero variance; Zach Meyer criteria
# modRed = train(repayment_rate~., data = train, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 10, length = 1000)),
#             trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE,
#                 preProcOptions = list(freqCut = 2, uniqueCut = 20)),
#             na.action = na.pass)
# modRed
# plot(modRed)
# getTrainPerf(modRed)
# varImp(modRed)
# modRedout <- predict(modRed, test, na.action = na.pass)
#######################################################################################
# # Simple Ranger Experiment Using a Reduced Data Set: COPIED TO CAPSTON
# library(ranger)
# subTrain <- select(train, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))
# subTest <- select(test, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))
# 
# set.seed(1010)
# modelrangerRed <- train(repayment_rate~.,
#                      data = subTrain, method = "ranger",
#                      preProcess = c("medianImpute"), 
#                      tuneLength = 3,
#                      na.action = na.pass,
#                      trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelrangerRed
# plot(modelrangerRed)
# modelrangerRedout <- predict(modelrangerRed, subTest, na.action = na.pass)
# getTrainPerf(modelrangerRed)

########################################################################################


