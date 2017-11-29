#' ---
#' title: "Capstone Project"
#' author: "Mark Blackmore"
#' date: "`r format(Sys.Date())`"
#' output: 
#'   github_document:
#'     toc: true
#' ---
#' 
#' ## Capstone Project
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
# EDA for Quiz
summary(train)
summary(train$repayment_rate)
sd(train$repayment_rate)
hist(train$repayment_rate)
ggplot(data = train, aes(x = repayment_rate)) + geom_histogram(bins = 10)

# Median repayment rate by school ownership
summary(train$school__ownership)
train %>% group_by(school__ownership) %>% summarise(med = median(repayment_rate)) %>% arrange(med)

# SAT score vs repayent rate
summary(train$admissions__sat_scores_average_overall)
ggplot(data = train, aes(x = admissions__sat_scores_average_overall, y = repayment_rate)) + 
  geom_point() + geom_smooth()

# Median family income vs repayent rate
summary(train$student__demographics_median_family_income)
ggplot(data = train, aes(x = student__demographics_median_family_income, y = repayment_rate)) + 
  geom_point() + geom_smooth()

# Region id vs repayment rate
summary(train$school__region_id)
train %>% group_by(school__region_id) %>% summarise(med = median(repayment_rate)) %>% arrange(med)

#######################################################################################
# EDA for Modeling

# Missing Data?
missingTrain <- apply(train, 2, function(x) sum(is.na(x)/length(x)))
hist(missingTrain)

# Carnegie Basic vs. Repayment Rate
train %>% group_by(school__carnegie_basic) %>% summarise(med = median(repayment_rate)) %>% arrange(med)
ggplot(data = train, aes(x = school__carnegie_basic, y = repayment_rate)) + geom_boxplot() 

# Report Year vs. Repayment Rate
train %>% group_by(report_year) %>% summarise(med = median(repayment_rate)) %>% arrange(med)
ggplot(data = train, aes(x = report_year, y = repayment_rate)) + geom_boxplot()

# EDA - Relevant
ggplot(data = train, aes(x = aid__loan_principal, y = repayment_rate)) + geom_point() + geom_smooth() 
ggplot(data = train, aes(x = aid__pell_grant_rate, y = repayment_rate)) + geom_point() + geom_smooth() 

# More EDA - Noise
ggplot(data = train, aes(x = admissions__admission_rate_overall, y = repayment_rate)) + geom_point() 
ggplot(data = train, aes(x = aid__cumulative_debt_number, y = repayment_rate)) + geom_point() + geom_smooth() 
ggplot(data = train, aes(x = aid__federal_loan_rate, y = repayment_rate)) + geom_point() + geom_smooth()
ggplot(data = train, aes(x = admissions__admission_rate_overall, y = repayment_rate)) + geom_point() 

########################################################################################
# Simple Predictive Modeling
## WILL NOT PREDICT
# mod<- lm(repayment_rate ~ student__demographics_median_family_income + 
#            admissions__sat_scores_average_overall +
#            school__ownership + school__region_id, data = train)
# summary(mod)
# modelError <- sqrt(mean(mod$residuals^2))
# modout <- predict(mod, test, na.action = na.pass)

########################################################################################
# Simple Linear Model: using caret
## Works!  
# formSimple <- repayment_rate ~ school__region_id +
#   student__demographics_median_family_income + 
#   aid__pell_grant_rate + school__ownership +  admissions__sat_scores_average_overall
#   
# modSimple = train(formSimple, data = train, method = "lm", preProcess = c("nzv", "medianImpute", "center", "scale"), 
#                   na.action = na.pass)
# modSimple
# modSimpleout <- predict(modSimple, test, na.action = na.pass)
#######################################################################################
# All Predictors, Automated Selection
## Works! 
# modFull = train(repayment_rate~., data = train, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             na.action = na.pass)
# modFull
# plot(modFull)
# modFullout <- predict(modFull, test, na.action = na.pass)

#######################################################################################
# Implement Cross Validation on Previous Model
## Works!
# modFullcv = train(repayment_rate~., data = train, method = "glmnet", 
#             preProcess = c("nzv", "medianImpute", "center", "scale"), 
#             na.action = na.pass, trControl = trainControl(
#             method = "cv", number = 10, verboseIter = TRUE))
# 
# modFullcv
# plot(modFullcv)
# modFullcvout <- predict(modFullcv, test, na.action = na.pass)

#######################################################################################
# Implement Previous Model while Tuning Hyperparameters
## Works! 8.1
# modFullcv_tune = train(repayment_rate~., data = train, method = "glmnet",
#                          preProcess = c("nzv","medianImpute", "center", "scale"),
#                          na.action = na.pass,
#                          tuneGrid = expand.grid(alpha = seq(0.1,0.55, length = 10),
#                                                 lambda = seq(0.03, 0.05, length = 10)),
#                          trControl = trainControl(
#                            method = "cv", number = 10, repeats = 10, verboseIter = TRUE))
# 
# modFullcv_tune
# plot(modFullcv_tune)
# modFullcv_tuneout <- predict(modFullcv_tune, test, na.action = na.pass)

#######################################################################################
# Implement dummyVars, without nzv, automated selection
## NOT RUN
# dmy <- dummyVars("~.", data = train, fullRank = TRUE)
# trsf <- data.frame(predict(dmy, newdata = train))
# testtrsf <- data.frame(predict(dmy, newdata = test))
# 
# set.seed(1010)
# modFulldv = train(repayment_rate~., data = trsf, method = "glmnet", 
#                 preProcess = c("medianImpute", "center", "scale"), 
#                 na.action = na.pass)
# modFulldv
# plot(modFulldv)
# modFullout <- predict(modFulldv, test, na.action = na.pass)
# set.seed(1010)
# modFulldvcv = train(repayment_rate~., data = trsf, method = "glmnet", 
#                   preProcess = c("medianImpute", "center", "scale"), 
#                   na.action = na.pass, trControl = trainControl(
#                     method = "cv", number = 10, repeats = 500, verboseIter = TRUE))
# 
# modFulldvcv
# plot(modFulldvcv)
# 
# set.seed(1010)
# modFulldvcv_tune = train(repayment_rate~., data = trsf, method = "glmnet", 
#                     preProcess = c("medianImpute", "center", "scale"), 
#                     na.action = na.pass, 
#                     tuneGrid = expand.grid(alpha = seq(0.6,0.8, length = 100), 
#                       lambda = seq(0.03, 0.05, length = 10)),
#                     trControl = trainControl(
#                       method = "cv", number = 10, repeats = 100, verboseIter = TRUE))
# 
# modFulldvcv_tune
# plot(modFulldvcv_tune)

#######################################################################################
# # Subset Predictors, Removing "Academics" - no relationship
# subTrain <- select(train, -row_id, -starts_with("academics"))
# modsub = train(repayment_rate~., data = subTrain, method = "glmnet", 
#                preProcess = c("medianImpute", "center", "scale"), 
#                na.action = na.pass, trControl = trainControl(
#                  method = "cv", number = 10, repeats = 10, verboseIter = TRUE))
# 
# modsub  # WORSE
#######################################################################################
# Remove Admissions
# subTrain2 <- select(subTrain, starts_with("admissions"))
# summary(subTrain2)
# subTrain2 <- select(subTrain, -starts_with("admissions"))
# 
# modsub2 = train(repayment_rate~., data = subTrain2, method = "glmnet", 
#                preProcess = c("nzv", "medianImpute", "center", "scale"), 
#                na.action = na.pass)
# modsub2
######################################################################################
# # All Predictors,  FIRST SUBMISSION
# Automated Selection, Using Zach Meyer suggestions for baseline
# modNet = train(repayment_rate~., data = train, method = "glmnet",
#                preProcess = c("nzv", "medianImpute", "center", "scale"),
#                tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 1, length = 1000)),
#                trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE),
#                na.action = na.pass)
# modNet
# plot(modNet)
# getTrainPerf(modNet)  # Submitted as L1out
# modNetout <- predict(modNet, test, na.action = na.pass)
# varImp(modNet)

#######################################################################################
# # Ranger model SECOND SUBMISSION
# library(ranger)
# set.seed(1010)
# modelranger <- train(repayment_rate~.,
#   data = train, method = "ranger",
#   preProcess = c("medianImpute"), 
#   tuneGrid = data.frame(mtry = seq(180, 270, length = 10)),
#   na.action = na.pass,
#   trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelranger
# plot(modelranger)
# modelrangerout <- predict(modelranger, test, na.action = na.pass)
# getTrainPerf(modelranger)
#######################################################################################
# Simple Ranger Experiment Using a Reduced Data Set
# VERY LITTLE DIFFERNECE FROM FULL MODEL
# library(ranger)
# subTrain <- select(train, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))
# subTest <- select(test, -starts_with("admissions"), -starts_with("academics"),-starts_with("completion"))
# 
# set.seed(1010)
# modelrangerRed <- train(repayment_rate~.,
#                         data = subTrain, method = "ranger",
#                         preProcess = c("medianImpute"), 
#                         tuneLength = 3,
#                         na.action = na.pass,
#                         trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelrangerRed
# plot(modelrangerRed)
# modelrangerRedout <- predict(modelrangerRed, subTest, na.action = na.pass)
# getTrainPerf(modelrangerRed)

#######################################################################################
# FIRST SUBMISSION
# Glmnet Model on full data set; alpha = 1, lambda = 0.02
# L1out <- outformat
# L1out$repayment_rate <- modNetout
# head(L1out)
# write.csv(L1out, file = "L1out.csv", row.names = FALSE)
#######################################################################################
# SECOND SUBMISSION
# Regression tree using ranger; mtry = 240
# rtout <- outformat
# rtout$repayment_rate <- modelrangerout
# head(rtout)
# write.csv(rtout, file = "rtout.csv", row.names = FALSE)

#######################################################################################
# Experiment: delete nzv, run glmnet; Result: RMSE = 8.2 vs 8.1 on full data set
##
# Variables with near zero variance
# nzvName <- nearZeroVar(train[,-1], names = TRUE, freqCut = 2, uniqueCut = 20) # shows names
# nzvInd  <- nearZeroVar(train[,-1], names = FALSE, freqCut = 2, uniqueCut = 20)
# nzvInd  # train features only
# trainRed <- train[,-(nzvInd+1)]  # shift to make room for target varaibe column
# testRed  <- test[,-nzvInd]        # test features for prediction
#
# modNetRed = train(repayment_rate~., data = trainRed, method = "glmnet",
#                preProcess = c("nzv", "medianImpute", "center", "scale"),
#                tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 1, length = 1000)),
#                trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE),
#                na.action = na.pass)
# modNetRed
# plot(modNetRed)
# getTrainPerf(modNetRed)  
# modNetout <- predict(modNetRed, testRed, na.action = na.pass)
# varImp(modNetRed)
#
# Almost the same model on vey reduced data set
# modelrangerRed2 <- train(repayment_rate~.,
#                         data = trainRed, method = "ranger",
#                         preProcess = c("medianImpute"),
#                         tuneLength = 3,
#                         na.action = na.pass,
#                         trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelrangerRed2
# plot(modelrangerRed2)
# modelrangerRedout2 <- predict(modelrangerRed2, testRed, na.action = na.pass)
# getTrainPerf(modelrangerRed2)
#######################################################################################
# Experiment: Remove items with high levels of missing values
##
# # Find proportions of missing values on remainimg dat
# miss <- apply(trainRed, 2, function(x) sum(is.na(x)/length(x)))
# hist(miss)
# missInd <- which(miss > 0.5)
# 
# trainRedMiss <- trainRed[,-(missInd+1)]
# testRedMiss  <- testRed[,-missInd]
# 
# modelrangerRed3 <- train(repayment_rate~.,
#                         data = trainRedMiss, method = "ranger",
#                         preProcess = c("medianImpute"),
#                         tuneLength = 3,
#                         na.action = na.pass) #,
#                         #trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelrangerRed3
# plot(modelrangerRed3)
# getTrainPerf(modelrangerRed3)
# modelrangerRedout3 <- predict(modelrangerRed3, testRedMiss, na.action = na.pass)
# 
# ##
# missInd2 <- which(miss > 0.3)
# 
# trainRedMiss2 <- trainRed[,-(missInd2+1)]
# testRedMiss2  <- testRed[,-missInd2]
# 
# modelrangerRed4 <- train(repayment_rate~.,
#                          data = trainRedMiss2, method = "ranger",
#                          preProcess = c("medianImpute"),
#                          tuneLength = 3,
#                          na.action = na.pass) #,
# #trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))
# 
# modelrangerRed4
# plot(modelrangerRed4)
# getTrainPerf(modelrangerRed4)
# modelrangerRedout4 <- predict(modelrangerRed4, testRedMiss2, na.action = na.pass)
#######################################################################################
# # Experiment: Results RMSE 8.11 - on par with full data set
# ## Sum the academics columns as a new variable; Run a Lasso
# trainSumAca <- mutate(train, sumAca = sum(starts_with("academics")))
# dim(trainSumAca)
# ## Drop the original academics colums
# trainSumAca <- select(trainSumAca, -starts_with("academics"))
# dim(trainSumAca)
# aggr(trainSumAca)
# ## Run a Lasso
# modSumAca = train(repayment_rate~., data = trainSumAca, method = "glmnet",
#             preProcess = c("nzv", "medianImpute", "center", "scale"),
#             tuneGrid = expand.grid(alpha = 0:1, lambda = seq(.0001, 10, length = 1000)),
#             trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE,
#                 preProcOptions = list(freqCut = 2, uniqueCut = 20)),
#             na.action = na.pass)
# modSumAca
# plot(modSumAca)
# getTrainPerf(modSumAca)
# varImp(modSumAca)
# # modSumAcaOut <- predict(trainSumAca, FIX = xform test, na.action = na.pass)
######################################################################################
# Experiment: RMSE of 7.11
## Sum the academics columns as a new variable; Run a Ranger
trainSumAca <- train %>% mutate(sumAca = sum(starts_with("academics")))
dim(trainSumAca)
testSumAca <- mutate(test, sumAca = sum(starts_with("academics")))
dim(testSumAca)

## Drop the original academics colums
trainSumAca <- select(trainSumAca, -starts_with("academics"))
testSumAca <- select(testSumAca, -starts_with("academics"))

## Run ranger on transformed data
modelranger <- train(repayment_rate~.,
                     data = trainSumAca, method = "rpart",
                     preProcess = c("medianImpute"),
                     #tuneGrid = data.frame(mtry = seq(180, 270, length = 10)),
                     tuneLength = 3,
                     na.action = na.pass)
#trControl = trainControl(method = "cv", number = 10, verboseIter = TRUE))

modelranger
plot(modelranger)
getTrainPerf(modelranger)
#######################################################################################
# Add dummy variables
# library(VIM)
# aggr(trainRed)

#' -------------
#'  
#' ## Session info
#+ show-sessionInfo
sessionInfo()