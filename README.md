# zembo-demo: Battery Lifecycle and Maintenance Analysis

## Overview

This project analyzes battery lifecycle and maintenance data to provide insights and recommendations for improving battery performance and service quality. The analysis focuses on predicting battery cycle life and identifying factors that influence it, as well as detecting potential faults or anomalies for proactive maintenance.

## Data Sources & Files

* **CSV Files:** Battery data, swap-in and swap-out data are loaded from CSV files in GCP bucket used to populate the big query database
  * Notebook with code for populating the db: `Populate_Bigquery.ipynb`
  * BigQuery SQL Scripts:
    * `merge_swap_data.sql`: create a new table with merged swap_in and swap_out data
    * `raw_data_quality_checks.sql`  & `data_validity.sql`: data quality check logic 
* **BigQuery:** All further analysis is done by loading data from a BigQuery table.
  * EDA: `Analysis_eda.ipynb`
  * Predictive modelling: `Predictive_modeling.ipynb`   

## Approach

1.  **Data Loading and Preprocessing:**
    * Data is loaded from BigQuery using SQL queries to select relevant columns.
    * Data types are inferred and coerced, with error handling for missing or invalid values.
    * The devId column is forced to a string datatype.
2.  **Exploratory Data Analysis (EDA):**
    * Visualizations are created to understand data distributions and relationships between variables.
    * Key metrics like cycle count, SOC, and temperature are analyzed.
    * Battery swap data is analyzed to understand charge added during swaps.
3.  **Predictive Modeling (Cycle Life Prediction):**
    * A LightGBM regression model is trained to predict the number of battery cycles.
    * Features like temperature, SOC, and voltage are used as predictors.
    * Model performance is evaluated using Mean Squared Error (MSE) and R-squared.
    * Training and Validation errors are plotted to monitor for overfitting.
    * Feature importances are plotted.
4.  **Anomaly Detection (Maintenance):**
    * Outlier detection is performed on cell voltages to identify potential faults.
    * Alarm frequency is analyzed to identify common issues.
5.  **Recommendations:**
    * Insights from the analysis are used to provide recommendations for:
        * Increasing battery cycle life (e.g., thermal management, SOC monitoring).
        * Improving battery maintenance (e.g., proactive fault detection).

## Code Structure

* **`load_data_from_bigquery_sql`:** Loads data from BigQuery using SQL.
* **`preprocess_data`:** Preprocesses the DataFrame.
* **`prepare_features_and_target`:** Prepares features and target variable.
* **`train_lightgbm_model`:** Trains the LightGBM model and plots training metrics and feature importance.
* **`evaluate_model`:** Evaluates the model's performance.
* **`visualize_results`:** Visualizes model predictions.
* **`save_model`:** saves the model to local or google drive.
* **`apply_smote`:** Applies SMOTE to the training data.
* **`main`:** Orchestrates the entire process.

## Libraries

* `pandas`
* `google-cloud-bigquery`
* `lightgbm`
* `scikit-learn`
* `matplotlib`
* `seaborn`
* `joblib`
* `imblearn`

## How to Run

1.  Install the required libraries: `pip install pandas google-cloud-bigquery lightgbm scikit-learn seaborn matplotlib joblib imblearn`
2.  Authenticate with Google Cloud Platform (GCP).
3.  Replace placeholder values for project ID, dataset ID, and table ID in the `main` function.
4.  Run the `main` function.

## Results

* Model performance metrics (MSE, R-squared).
* Visualizations of model predictions and feature importances.
* Recommendations for battery lifecycle improvement and maintenance.
