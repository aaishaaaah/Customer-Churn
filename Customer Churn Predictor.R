###set up environment###
library(ggplot2)
library(tidyverse)
library(caret)
library(pROC)
library(randomForest)
library(rpart)
library(rpart.plot)
library(corrplot)
library(dplyr)

###load and inspect data###
str(data)
summary(data)
head(data)
head

###clean data###
colSums(is.na(data)) # identify missing values
data<- na.omit(data) # remove

data<- data %>% # convert char -> factor
  mutate(across(where(is.character), as.factor))

data$TotalCharges <- as.numeric(data$TotalCharges)

###split into train/test data###
SplitData <- function(data, splits){
  
  df <- as.data.frame(data)                 # Convert the data object to a data frame object
  
  n.obs <- nrow(df)                             # Number of observations
  
  # Shuffle and separate indices
  
  shuffled_ind <- sample(1:n.obs)
  
  split_ind <- c(round(splits[1]*n.obs), 
                 round(splits[1]*n.obs) + round(splits[2]*n.obs))
  
  train_ind <- shuffled_ind[1:split_ind[1]]
  val_ind <- shuffled_ind[(split_ind[1] + 1):split_ind[2]]
  if (splits[3]!=0){
    test_ind <- shuffled_ind[(split_ind[2] + 1):n.obs]
    list("train" = df[train_ind, ], 
         "validation" = df[val_ind, ], 
         "test" = df[test_ind, ])  
  } else {
    list("train" = df[train_ind, ], 
         "validation" = df[val_ind, ])  
  }
}

set.seed(2026)
split <- c(0.7, 0.3, 0)
datasplits <- SplitData(data= data, splits = split)
str(datasplits)

train.data <- datasplits[[1]]
test.data <- datasplits[[2]]

###logsitic regression model###
#model without TotalCharges(=MonthlyChargesxtenure)
logreg <- glm(Churn ~ tenure + MonthlyCharges + Contract + 
                PaperlessBilling + PaymentMethod + InternetService + 
                StreamingTV + StreamingMovies + Dependents + Partner,
              data = train.data, 
              family = "binomial")

#interpret results 
summary(logreg)

exp(coef(logreg)) #odds ratio

exp(cbind(OR = coef(logreg), confint(logreg))) #confidence intervals

#predictions 
test.data$churn_prob <- predict(logreg, test.data, type = "response")

test.data$churn_pred <- ifelse(test.data$churn_prob > 0.5, "Yes", "No") #convert to binary predictions

confusionMatrix(as.factor(test.data$churn_pred), 
                as.factor(test.data$Churn))

#evaluate model accuracy 
roc_curve <- roc(test.data$Churn, test.data$churn_prob)
plot(roc_curve, col = "blue", main = paste("AUC =", round(auc(roc_curve), 3)))
abline(a = 0, b = 1, lty = 2)
optimal <- coords(roc_curve, "best", ret = "threshold")
print(paste("Optimal threshold:", round(optimal$threshold, 3)))

#churn rate
churn_rate <- mean(data$Churn == "Yes")  

print(paste("Overall churn rate:", round(churn_rate * 100, 2), "%"))

table(data$Churn)

###visualisations###
#odds ratio
library(broom)

odds_data <- tidy(logreg, conf.int = TRUE) %>%
  filter(term != "(Intercept)") %>%
  mutate(
    odds_ratio = exp(estimate),
    term = str_replace_all(term, "_", " "),
    term = str_replace(term, "Yes", " (Yes)"),
    # Color code by risk direction
    risk = ifelse(odds_ratio > 1, "Higher Risk", "Lower Risk")
  )

ggplot(odds_data, aes(x = odds_ratio, y = reorder(term, odds_ratio))) +
  geom_vline(xintercept = 1, linetype = "dashed", color = "red", linewidth = 1) +
  geom_point(aes(color = risk), size = 3) +
  geom_errorbarh(aes(xmin = exp(conf.low), xmax = exp(conf.high), color = risk), 
                 height = 0.2, linewidth = 0.8) +
  scale_x_log10() +
  scale_color_manual(values = c("Higher Risk" = "#D62728", "Lower Risk" = "#2CA02C")) +
  labs(
    title = "What Drives Customer Churn?",
    subtitle = "Odds Ratios with 95% Confidence Intervals",
    x = "Odds Ratio (log scale) | >1 = Higher Churn Risk, <1 = Lower Risk",
    y = ""
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 10)
  )

#churn distribution 
ggplot(data, aes(x = Churn, fill = Churn)) +
  geom_bar() +
  geom_text(stat = 'count', aes(label = scales::percent(..count../nrow(data))), 
            vjust = -0.5, size = 5) +
  scale_fill_manual(values = c("No" = "#2CA02C", "Yes" = "#D62728")) +
  labs(
    title = "Customer Churn Distribution",
    subtitle = paste("Overall Churn Rate:", round(mean(data$Churn == "Yes") * 100, 1), "%"),
    x = "Churn Status",
    y = "Number of Customers"
  ) +
  theme_minimal()
