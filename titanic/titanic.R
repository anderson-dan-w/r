library(ggplot2)
library(tidyr)
library(dplyr)

train_fname = '/Users/danderson2/anderson-dan-w/rlang/titanic/data/train.csv'
test_fname = '/Users/danderson2/anderson-dan-w/rlang/titanic/data/test.csv'

train_all <- read_csv(train_fname)
test <- read_csv(test_fname)

names(train_all)
nrow(train_all)

## remove index, and mostly-null columns
train_all %>% sapply(function(x) sum(is.na(x)))
train_all %>% sapply(function(x) length(unique(x)))

train <- train_all %>% select(-PassengerId, -Cabin, -Ticket, -Name)
summary(train)

## deal with NAs
train$Age[is.na(train$Age)] <- mean(train$Age, na.rm=TRUE)
embarked_mode <- train %>%
    count(Embarked) %>%
    arrange(desc(n)) %>%
    head(1)
train$Embarked[is.na(train$Embarked)] <- embarked_mode[[1]]

## fit the model
model <- glm(data=train, Survived ~ ., family=binomial(link="logit"))
summary(model)

## check the model
anova(model, test="Chisq")

## BAD IDEA: don't test on training data, im just being lazy
results = predict(model, newdata=train, type="response")
results <- ifelse(results < 0.5, 0, 1)
missed <- mean(results != train$Survived, na.rm=T)
missed

## AUC
library(ROCR)
pr <- prediction(results, train$Survived)
perf <- performance(pr, measure="tpr", x.measure="fpr")
plot(perf)

auc = performance(pr, measure="auc")
auc_ <- auc@y.values[[1]]
auc_

