# V1 : ATP Match Prediction: Data Preparation, Feature Engineering and Modeling

## 1. Project overview

The objective of V1 is to predict the winner of ATP men's singles matches using historical match data and pre-match player information.

The project follows a data science workflow:

1. Store and organize historical tennis data in PostgreSQL.
2. Load the relational data into Python for exploratory data analysis.
3. Clean the dataset and investigate missing values and data quality.
4. Engineer features describing player strength, form, service performance, fatigue, experience, and head-to-head history.
5. Transform historical matches into a matchup dataset suitable for machine learning.
6. Compare classification algorithms and feature-selection strategies.
7. Tune XGBoost hyperparameters using chronological cross-validation.
8. Evaluate the selected model on a later test period.

The central principle is **pre-match prediction**: the model must not use information from the match it is trying to predict.

V1 is the main predictive baseline of the project. The Match Charting Project (MCP) was subsequently investigated as an experimental extension, documented separately.

## 2. Data source and PostgreSQL database

The project uses historical ATP match results and player reference data from Jeff Sackmann's tennis datasets:

- ATP match data:  https://github.com/Aneeshers/tennis-sackmann-archive/tree/main/atp
- Player reference data: `atp_players.csv`

The selected match dataset covers the period 2010–2026, with 2026 representing a partial season snapshot.

PostgreSQL is used to store and structure the data before analysis in Python. The database contains three principal tables:

- `players`: player identifiers and biographical information.
- `tournaments`: tournament metadata, including surface and tournament level.
- `matches`: historical match results, rankings, scores, durations, and available match statistics.

The SQL schema, imports, constraints, and database preparation are documented in [`sql/README.md`](../sql/README.md).

## 3. Exploratory data analysis and cleaning

After loading the database into Python with Pandas, exploratory data analysis is used to understand the dataset before modeling.

This stage includes inspecting data types and distributions, checking missing values, examining tournament surfaces and match dates, and identifying potential inconsistencies or duplicate records.

The initial working dataset contains approximately 46,964 matches. After removing walkovers and matches without a known surface, the final matchup dataset contains **46,618 observations and 115 columns**, including the date and target.

### `remove_WO(df)`

Removes matches marked as walkovers (`W/O`). These matches do not represent normally completed matches and should not be treated as ordinary match outcomes.

### `select_pre_match_columns(df)`

Selects the columns needed for historical feature engineering and matchup construction. This includes player characteristics, rankings, match metadata, and the features computed by the functions below.

The current-match outcome and its post-match statistics are not included as direct predictors of that same match.

## 4. Feature engineering

Historical statistics are computed chronologically. In most functions, match results from a given date are held in pending updates and incorporated into player histories after that date has been processed. This is intended to prevent matches played on the same day from using one another's outcomes when exact match times are unavailable.

### 4.1. Elo ratings — `create_elo_features(df)`

Elo estimates relative player strength from previous match results.

Each player starts with a rating of 1500, and ratings are updated using a K-factor of 32. The expected result depends on the difference between the two players' ratings, and ratings change according to the observed outcome.

Two ratings are computed:

- **Global Elo**, reflecting overall historical strength.
- **Surface Elo**, reflecting strength on the current match's surface.

These features provide a measure of player strength that evolves after every match rather than relying only on the latest ranking.

### 4.2. Recent form — `create_form_features(df)`

Computes historical win rates over the previous 5 and 10 matches, both globally and on the current surface.

Recent form can reveal changes in performance that are not yet fully reflected in a player's ranking or long-term rating. Surface-specific form also accounts for the fact that players can perform differently on hard courts, clay, and grass.

### 4.3. Head-to-head — `create_h2h_features(df)`

Counts previous wins in encounters between the two players.

The function records the prior wins of each competitor against the other, together with their total number of previous encounters. Only earlier encounters should contribute to the features.

Head-to-head history may capture matchup-specific patterns that are not reflected by a player's overall strength alone.

### 4.4. Fatigue and workload — `create_fatigue_features(df)`

Computes:

- Days since the previous match.
- Matches played during the previous 7 days.
- Matches played during the previous 14 days.
- Minutes accumulated earlier in the current tournament.

These features represent workload and recovery opportunities. A player who has played several long matches may approach the next round under different conditions from an opponent who has played less.

The current implementation updates tournament minutes as it processes match rows. This requires further auditing to ensure that minutes from an earlier match on the same date cannot enter another match's pre-match features.

### 4.5. Service performance — `create_service_features(df)`

Builds six historical service metrics:

- Ace rate.
- Double-fault rate.
- First-serve-in rate.
- First-serve win rate.
- Second-serve win rate.
- Overall service-points-won rate.

Each metric is calculated globally and over the previous 5 and 10 matches.

The rates are calculated from accumulated numerators and denominators rather than by averaging individual match percentages. This gives matches with more relevant observations an appropriately larger contribution.

These features are useful because serve quality, consistency, and the ability to win points behind the first and second serve can strongly affect tennis match outcomes.

**Limitation:** the current implementation replaces some missing raw service counts with zero during historical accumulation. This should be reviewed before production use so that unavailable statistics are not mistaken for genuine zero counts.

### 4.6. Historical win rates — `create_win_rate_features(df)`

Computes the overall historical win rate and the win rate on the current surface.

These features summarize a player's observed success over previous matches. They complement Elo and recent form by measuring historical outcomes directly.

### 4.7. Experience — `create_experience_features(df)`

Counts the number of previous matches played by each player, both overall and on the current surface.

Experience provides context for interpreting other statistics. For example, a rate based on a long history may be more informative than the same rate based on only a few previous matches.

## 5. Building the matchup dataset

### `create_matchup_dataset(df, random_state=0)`

This function orchestrates the data-preparation workflow:

1. Removes walkovers and matches without an identified surface.
2. Generates Elo, form, head-to-head, fatigue, service, win-rate, and experience features.
3. Selects the required columns.
4. Converts each historical match into a single matchup observation.

The result represents a match from the perspective of two competitors, called **player A** and **player B**.

### Why randomly assign players A and B?

The original source identifies the winner and loser. If the winner were always assigned to player A, the target would always equal 1, making the learning task trivial.

Instead, the function randomly assigns the two competitors to A and B:

- If the winner is assigned to A, `target = 1`.
- If the winner is assigned to B, `target = 0`.

A fixed random seed ensures reproducibility. The actual winner is not randomized; only the representation of the competitors is randomized.

This makes the target independent of a fixed winner/loser column position and requires the model to learn from player characteristics.

## 6. Relative matchup features

### `create_basic_features(df)`

Constructs differences between player A and player B, including:

- Ranking and ranking-points differences.
- Age and seed differences.
- Global and surface Elo differences.
- Recent-form differences.
- Head-to-head differences.
- Fatigue and workload differences.
- Service-rate differences.
- Win-rate and experience differences.

For example:

```python
rank_diff = rank_A - rank_B
elo_diff = elo_A - elo_B
form_5_diff = form_5_A - form_5_B
ace_pct_diff = ace_pct_A - ace_pct_B
```

Difference features express the relative advantage between competitors directly. A positive `elo_diff`, for example, means player A has a higher Elo rating, while a negative `rank_diff` means player A has a better numerical ranking.

Keeping both the individual measurements and the differences allows the model to learn from absolute characteristics as well as relative strengths.

The final dataset is constructed with:

```python
matchups = create_matchup_dataset(df, random_state=0)
matchups = create_basic_features(matchups)
```

The resulting dataset contains **46,618 matches and 115 columns** in the current snapshot. It includes the player identifiers, pre-match features, relative differences, match date, and target.

The `date` and `target` columns are used for splitting and evaluation, not as predictive inputs. The preprocessing step selects an explicit list of model features, excluding them.

## 7. Temporal train/test splitting

The first experiments used a chronological 80/20 split:

| Dataset | Observations | Purpose |
|---|---:|---|
| Train | 37,294 | Fit preprocessing and models |
| Test | 9,324 | Evaluate performance on later matches |

The target was nearly balanced in both subsets:

- Train: 18,682 examples with target 0 and 18,612 with target 1.
- Test: 4,671 examples with target 0 and 4,653 with target 1.

Later experiments used a three-way chronological split, approximately 60% train, 20% validation, and 20% test. This separates model fitting, configuration selection, and final evaluation.

A chronological split is more appropriate than a random split for this application because a tennis prediction system should be assessed on matches occurring after the matches used to train it.

For strict reproducibility, the splitting procedure should also ensure that matches from the same date do not cross partition boundaries when exact match times are unavailable.

## 8. Preprocessing

### `create_preprocessor(drop_features=None, feature_selector=None)`

The preprocessing pipeline distinguishes numerical and categorical features.

**Numerical features**

- Missing values are replaced using the median learned from the training data.
- `StandardScaler` standardizes numerical variables.
- An optional feature selector can be included in the numerical pipeline.

**Categorical features**

- Missing values are imputed using the most frequent category.
- `OneHotEncoder(handle_unknown="ignore")` converts player identifiers into indicator variables and handles players not encountered during fitting.

The transformations are fitted on training data and then applied to validation or test data. This prevents the imputation and scaling parameters from being learned using information from the evaluation sets.

## 9. Model comparison and feature selection

Several classification algorithms were evaluated, including:

- Logistic Regression.
- K-Nearest Neighbors (KNN).
- Random Forest.
- AdaBoost.
- XGBoost.

Accuracy, confusion matrices, classification reports, precision, recall, F1-score, and learning curves were used during experimentation.

Random Forest, AdaBoost, and XGBoost were among the strongest candidates. XGBoost was retained for further optimization because it provided a competitive baseline and allowed detailed control over tree complexity, learning rate, regularization, and sampling.

### Feature-selection experiments

Two feature-selection approaches were explored:

- `VarianceThreshold`, to remove features with no variation.
- `SelectKBest`, to retain the highest-scoring numerical features.

In one exploratory XGBoost experiment, the following validation accuracies were observed:

| Configuration | Accuracy |
|---|---:|
| All features | 64.1356% |
| VarianceThreshold | 64.1356% |
| SelectKBest — 20 features | 64.4144% |
| SelectKBest — 40 features | 63.8889% |
| SelectKBest — 60 features | 63.8782% |
| SelectKBest — 80 features | 64.2428% |
| SelectKBest — 100 features | 63.2239% |

SelectKBest with 20 features produced a slightly higher score in this experiment, but the results did not show a consistent improvement across different feature counts. VarianceThreshold did not change the accuracy.

The final tuned V1 model therefore retained the original feature set rather than adopting a reduced selection whose advantage had not been established robustly.

These exploratory results come from an earlier experiment and should not be compared directly with the final chronological evaluation results below.

## 10. XGBoost hyperparameter optimization

The XGBoost pipeline was tuned using `RandomizedSearchCV` with temporal cross-validation and accuracy as the scoring metric.

The search explored:

- Number of trees (`n_estimators`).
- Maximum tree depth (`max_depth`).
- Learning rate.
- Row subsampling (`subsample`).
- Feature subsampling (`colsample_bytree`).
- Minimum child weight.
- Split penalty (`gamma`).
- L2 regularization (`reg_lambda`).

The final search evaluated 200 candidate configurations over four chronological cross-validation folds, resulting in 800 model fits.

The best configuration was:

```python
XGBClassifier(
    random_state=0,
    eval_metric="logloss",
    n_jobs=1,
    tree_method="hist",
    colsample_bytree=0.9702386553170644,
    gamma=0.14207211639577388,
    learning_rate=0.006895350858996432,
    max_depth=5,
    min_child_weight=1,
    n_estimators=955,
    reg_lambda=23.49575409856029,
    subsample=0.7421052341237935
)
```

The estimator is used inside a pipeline containing the preprocessing steps, so imputation and scaling are fitted separately within each cross-validation training fold.

## 11. Final V1 results

The best XGBoost configuration was evaluated on the validation set during model selection and then refitted using train plus validation data before testing.

| Evaluation | Accuracy |
|---|---:|
| Best temporal cross-validation score | 68.3902% |
| Validation accuracy | 66.4522% |
| Final reported test accuracy | 65.8516% |

The test accuracy is the proportion of held-out matches for which the predicted winner matches the observed result.

The test score is close to the validation score, although below the cross-validation score. This suggests that performance on later matches is more challenging than on the training-period folds.

The test set was consulted during earlier iterative model comparisons, including MCP experiments. It should therefore not be considered a completely untouched final holdout, and the small observed performance differences between versions should not be interpreted as definitive statistical evidence.

## 12. Limitations and next steps

V1 establishes a reproducible baseline for ATP match prediction, but several improvements remain:

- Audit all feature calculations for strict pre-match temporal integrity, particularly same-day tournament-minute updates.
- Improve missing-statistic handling in service features.
- Persist the trained pipeline together with its parameters, data cutoff, and software dependencies.
- Create a prediction function that reproduces the same feature engineering for a future match.
- Add automated tests for data quality, feature generation, and leakage prevention.
- Investigate MCP-derived player-style features as a separate experimental extension. The current MCP experiments have not demonstrated a clear improvement over V1.

The next stage is to turn the notebook-based workflow into reusable Python modules and an automated prediction pipeline, while keeping the notebooks as documentation of the experiments and methodology.
