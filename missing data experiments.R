#' ---
#' title: "Missing Data Experiments"
#' author: "Mark Blackmore"
#' date: "`r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#' ---
#'
#' ## Test with Missing Data, Linear Combos, etc
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

#' ## How Much Missing Data
#' Missing Values as fraction of total
sum(is.na(train_values))/(dim(train_values)[1]*dim(train_values)[2]) 

#' Missing Values fraction by column
missCol <- apply(train_values, 2, function(x) sum(is.na(x)/length(x)))  
missRow <- apply(train_values, 1, function(x) sum(is.na(x)/length(x))) 

#' Distribution of Missing Values
hist(missCol, main = "Missing Data by Column")
hist(missRow, main = "Missing Data by Row")
missIndCol <- which(missCol > 0.8); length(missIndCol)  #Number of predictors > 90% missing
missIndRow <- which(missRow > 0.8); length(missIndRow)  #Number of predictors > 50% missing

#' Reduce the data for missing features and cases
train_values <- train_values[-missIndRow, -missIndCol]
test <- test[,-missIndCol]

#' Examine data
str(train_values[,1:30])
str(train_values[,31:70])
str(train_values[,71:100])
str(train_values[,101:130])
str(train_values[,131:170])
str(train_values[,171:200])
str(train_values[,201:230])
str(train_values[,231:270])
str(train_values[,271:300])
str(train_values[,301:330])
str(train_values[,331:370])  # Starting to see factors
str(train_values[,371:400])
str(train_values[,401:415])

#' ## Create Factor Variables
# A MUCH BETTER WAY TO DO THIS:
# df <- df %>% mutate_if(is.character,as.factor)
#' Train_values: Coerce character features to factors
train_values$report_year <- as.factor(train_values$report_year)
train_values$school__carnegie_basic <- as.factor(train_values$school__carnegie_basic)
train_values$school__carnegie_size_setting <- as.factor(train_values$school__carnegie_size_setting)
train_values$school__carnegie_undergrad <- as.factor(train_values$school__carnegie_undergrad)
train_values$school__degrees_awarded_highest <- as.factor(train_values$school__degrees_awarded_highest)
train_values$school__degrees_awarded_predominant <- as.factor(train_values$school__degrees_awarded_predominant)
train_values$school__institutional_characteristics_level <- as.factor(train_values$school__institutional_characteristics_level)
train_values$school__locale <- as.factor(train_values$school__locale)
train_values$school__main_campus <- as.factor(train_values$school__main_campus)
train_values$school__men_only <- as.factor(train_values$school__men_only)
train_values$school__minority_serving_aanipi <- as.factor(train_values$school__minority_serving_aanipi)
train_values$school__minority_serving_annh <- as.factor(train_values$school__minority_serving_annh)
train_values$school__minority_serving_hispanic <- as.factor(train_values$school__minority_serving_hispanic)
train_values$school__minority_serving_historically_black <- as.factor(train_values$school__minority_serving_historically_black)
train_values$school__minority_serving_nant <- as.factor(train_values$school__minority_serving_nant)
train_values$school__minority_serving_predominantly_black <- as.factor(train_values$school__minority_serving_predominantly_black)
train_values$school__minority_serving_tribal <- as.factor(train_values$school__minority_serving_tribal)
train_values$school__online_only <- as.factor(train_values$school__online_only)
train_values$school__ownership <- as.factor(train_values$school__ownership)
train_values$school__region_id <- as.factor(train_values$school__region_id)
train_values$school__religious_affiliation <- as.factor(train_values$school__religious_affiliation)
train_values$school__state <- as.factor(train_values$school__state)
train_values$school__women_only <- as.factor(train_values$school__women_only)

#' Test: Coerce character features to factors
test$report_year <- as.factor(test$report_year)
test$school__carnegie_basic <- as.factor(test$school__carnegie_basic)
test$school__carnegie_size_setting <- as.factor(test$school__carnegie_size_setting)
test$school__carnegie_undergrad <- as.factor(test$school__carnegie_undergrad)
test$school__degrees_awarded_highest <- as.factor(test$school__degrees_awarded_highest)
test$school__degrees_awarded_predominant <- as.factor(test$school__degrees_awarded_predominant)
test$school__institutional_characteristics_level <- as.factor(test$school__institutional_characteristics_level)
test$school__locale <- as.factor(test$school__locale)
test$school__main_campus <- as.factor(test$school__main_campus)
test$school__men_only <- as.factor(test$school__men_only)
test$school__minority_serving_aanipi <- as.factor(test$school__minority_serving_aanipi)
test$school__minority_serving_annh <- as.factor(test$school__minority_serving_annh)
test$school__minority_serving_hispanic <- as.factor(test$school__minority_serving_hispanic)
test$school__minority_serving_historically_black <- as.factor(test$school__minority_serving_historically_black)
test$school__minority_serving_nant <- as.factor(test$school__minority_serving_nant)
test$school__minority_serving_predominantly_black <- as.factor(test$school__minority_serving_predominantly_black)
test$school__minority_serving_tribal <- as.factor(test$school__minority_serving_tribal)
test$school__online_only <- as.factor(test$school__online_only)
test$school__ownership <- as.factor(test$school__ownership)
test$school__region_id <- as.factor(test$school__region_id)
test$school__religious_affiliation <- as.factor(test$school__religious_affiliation)
test$school__state <- as.factor(test$school__state)
test$school__women_only <- as.factor(test$school__women_only)

# Collapse the academic variables
#train_values <- mutate(train_values, sumAca = sum(starts_with("academics")))
train_values <- select(train_values, -starts_with("academics"))
#test <- mutate(test, sumAca = sum(starts_with("academics")))
test <- select(test, -starts_with("academics"))

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
# How Much Missing Data
## Missing Values as fraction of total
sum(is.na(train))/(dim(train)[1]*dim(train)[2]) 

# Missing Values fraction by column
missCol <- apply(train, 2, function(x) sum(is.na(x)/length(x)))  
missRow <- apply(train, 1, function(x) sum(is.na(x)/length(x))) 

# Distribution of Missing Values
hist(missCol, main = "Missing Data by Column")
hist(missRow, main = "Missing Data by Row")
missIndCol <- which(missCol > 0.8); length(missIndCol)  #Number of predictors > 80% missing
missIndRow <- which(missRow > 0.8); length(missIndRow)  #Number of predictors > 80% missing

train <- train[-missIndRow,]
sum(is.na(train))/(dim(train)[1]*dim(train)[2]) 
#######################################################################################
# CURRENT EXPERIMENT
# Results: RMSE 7.18
modelranger <- train(repayment_rate~.,
  data = train, method = "ranger",
  preProcess = c("medianImpute"),
  #tuneGrid = data.frame(mtry = seq(180, 270, length = 10)),
  tuneLength = 3,
  na.action = na.pass,
  trControl = trainControl(method = "cv", number = 5, verboseIter = TRUE))

modelranger
plot(modelranger)
getTrainPerf(modelranger)
modelrangerout <- predict(modelranger, test, na.action = na.pass)

#######################################################################################
# # Near Zero Variance and Overlap with Missing Data
# nzvName <- nearZeroVar(train[,-1], names = TRUE, freqCut = 2, uniqueCut = 20)
# nzvInd  <- nearZeroVar(train[,-1], names = FALSE, freqCut = 2, uniqueCut = 20)
# length(nzvInd)/dim(train)[2]
# 
# # Experiment with preProcess
# preProcValues <- preProcess(train, method = "medianImpute")
# trainProc  <- predict(preProcValues, train)
# sum(is.na(trainProc))/(dim(trainProc)[1]*dim(trainProc)[2]) # NA's left
# 
# nzvIndProc  <- nearZeroVar(trainProc[,-1], names = FALSE, freqCut = 2, uniqueCut = 20)
# length(nzvIndProc)/dim(trainProc)[2]
# 
# # Need to preProcess first
# findLinearCombos(trainProc)
########################################################################################
# # Remove Near Zero Variance Featres using Zach Meyer criteria
# nzvInd1  <- nearZeroVar(train[,-1], names = FALSE, freqCut = 2, uniqueCut = 20)
# trainNzv1 <- train[,-(nzvInd1+1)]
# 
# # Impute Missing Values
# preProcValues1 <- preProcess(trainNzv1, method = "medianImpute")
# trainProc1  <- predict(preProcValues1, trainNzv1)
# sum(is.na(trainProc1))/(dim(train)[1]*dim(train)[2])
# dim(trainProc1)
# 
# nzvInd2  <- nearZeroVar(trainProc1[,-1], names = FALSE, freqCut = 2, uniqueCut = 20)
# trainNzv2 <- trainProc1[,-(nzvInd2+1)]
# dim(trainNzv2)
# 
# sum(is.na(trainNzv2))/(dim(train)[1]*dim(train)[2])
#######################################################################################
# Experiment: Result RMSE 8.245 vs 8.1 on full model  
## Delete Features with > 50% NA, Cases with > 80% NA.  Run Lasso Regression
# 
# trainMiss <- train[-missIndRow,-missIndCol]
# 
# modMiss = train(repayment_rate~., data = trainMiss, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 10, length = 1000)),
#             trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE,
#                 preProcOptions = list(freqCut = 2, uniqueCut = 20)),
#             na.action = na.pass)
# modMiss
# plot(modMiss)
# getTrainPerf(modMiss)
# varImp(modMiss)
# modRedout <- predict(modMiss, test, na.action = na.pass)
#######################################################################################
# Experiment: Results = 7.8 RMSE vs 7 on full model
## Delete Features with > 50% NA, Cases with > 80% NA.  Run Regression Tree
# library(ranger)
# set.seed(1010)
# 
# # Remove high levels of missing data
# trainMiss <- train[-missIndRow,-missIndCol]

# Make a smaller train set
# inTrainMissSmall <- createDataPartition(y=trainMiss$repayment_rate, p=0.5, list = FALSE)
# trainMissSmall <- trainMiss[inTrainMissSmall,]
# 
# modelranger <- train(repayment_rate~.,
#   data = trainMissSmall, method = "ranger",
#   preProcess = c("medianImpute"),
#   #tuneGrid = data.frame(mtry = seq(180, 270, length = 10)),
#   tuneLength = 3,
#   na.action = na.pass)
#   #trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
#   
# modelranger
# plot(modelranger)
# getTrainPerf(modelranger)
# modelrangerout <- predict(modelranger, test, na.action = na.pass)

#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()

