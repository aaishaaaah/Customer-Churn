# Telco Customer Churn Analysis

This project analyzes customer churn for a telecommunications company using logistic regression. The goal is to identify key factors of churn and provide recommendations.

**Dataset:** [Telco Customer Churn dataset from Kaggle](https://www.kaggle.com/datasets/blastchar/telco-customer-churn)  
**Sample Size:** 7,043 customers
**Churn Rate:** 26.58%

## Key Findings

### Top Risk Factors (Increase Churn)

| Feature | Odds Ratio | Impact |
|---------|------------|--------|
| Fiber optic internet | 4.50x | Customers with fiber optic are **4.5x more likely** to churn |
| Streaming movies | 1.65x | 65% higher churn risk |
| Streaming TV | 1.60x | 60% higher churn risk |
| Electronic check payment | 1.44x | 44% higher churn risk |
| Paperless billing | 1.31x | 31% higher churn risk |

### Top Protective Factors (Reduce Churn)

| Feature | Odds Ratio | Impact |
|---------|------------|--------|
| 2-year contract | 0.19x | **81% lower** churn risk |
| 1-year contract | 0.43x | **57% lower** churn risk |
| No internet service | 0.33x | 67% lower churn risk |
| Has dependents | 0.83x | 17% lower churn risk |
| Longer tenure | 0.97x | 3% lower risk per additional month |

## Model Performance

| Metric | Value |
|--------|-------|
| Model Type | Logistic Regression |
| AUC-ROC | 0.852 |
| Accuracy | 80.85% |
| Sensitivity | 89.66% |
| Specificity | 54.78% |

## Business Recommendations

1. **Convert month-to-month customers** to annual contracts (81-57% churn reduction)
2. **Investigate fiber optic service issues** — currently 4.5x churn risk
3. **Incentivize autopay** to replace electronic checks (44% higher churn)
4. **Bundle streaming services** with contract incentives


