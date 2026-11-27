# Read the benchmark samples and results

Reads the files of the three benchmark tasks of the paper: the samples
with their splits, the scores of every model, the predictions and the
run information. With `table = NULL`, lists the tables of the data
folder.

## Usage

``` r
fpc_benchmark(table = NULL, fields = NULL, dir = NULL)
```

## Arguments

- table:

  Table to read: a file name without extension, as listed by
  `fpc_benchmark()`.

- fields:

  For `task1_samples`, field identifiers or a data frame from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).
  `NULL` keeps all (12 million rows).

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame (a list for the `run_info` and `benchmark_text` files).
With `table = NULL`, a data frame with the name, task, file and
description of every table.

## Details

Task 1 forecasts the field NDVI 15 to 60 days ahead; task 2 detects the
fields that responded to an extreme event; task 3 forecasts the change
of the county drought class. In `task1_samples`, each row is a field, an
issue date and a horizon; the file stores them as positions in
`cube.zarr` (`f`, `t`, `h`), which are kept, and `field_id`,
`issue_date`, `horizon_days`, `target_start`, `target_end` are added
(this needs `fields.parquet`). The confusion matrices of task 3 have the
observed class in rows and the predicted class in columns.

## Examples

``` r
d <- fpc_example_dir()
fpc_benchmark(dir = d)
#>                                     table task
#> 1                          benchmark_text   NA
#> 2               task1_lightgbm_importance    1
#> 3                           task1_results    1
#> 4                          task1_run_info    1
#> 5                           task1_samples    1
#> 6                            task2_events    2
#> 7                           task2_results    2
#> 8                          task2_run_info    2
#> 9           task3_confusion_attention_mil    3
#> 10     task3_confusion_lightgbm_usdm_only    3
#> 11   task3_confusion_lightgbm_with_fields    3
#> 12               task3_confusion_momentum    3
#> 13      task3_confusion_ndvi_anomaly_rule    3
#> 14              task3_confusion_no_change    3
#> 15 task3_confusion_transition_climatology    3
#> 16              task3_field_evidence_gain    3
#> 17                      task3_predictions    3
#> 18                          task3_results    3
#> 19                         task3_run_info    3
#> 20                          task3_samples    3
#>                                          file
#> 1                         benchmark_text.json
#> 2               task1_lightgbm_importance.csv
#> 3                           task1_results.csv
#> 4                         task1_run_info.json
#> 5                       task1_samples.parquet
#> 6                            task2_events.csv
#> 7                           task2_results.csv
#> 8                         task2_run_info.json
#> 9           task3_confusion_attention_mil.csv
#> 10     task3_confusion_lightgbm_usdm_only.csv
#> 11   task3_confusion_lightgbm_with_fields.csv
#> 12               task3_confusion_momentum.csv
#> 13      task3_confusion_ndvi_anomaly_rule.csv
#> 14              task3_confusion_no_change.csv
#> 15 task3_confusion_transition_climatology.csv
#> 16              task3_field_evidence_gain.csv
#> 17                  task3_predictions.parquet
#> 18                          task3_results.csv
#> 19                        task3_run_info.json
#> 20                      task3_samples.parquet
#>                                                                      description
#> 1                                 every number of the benchmark section (a list)
#> 2                                                 gain of every LightGBM feature
#> 3  RMSE, MAE, bias, R2 and skill by split, horizon and model, with 95% intervals
#> 4                      code version, dates and sample counts of the run (a list)
#> 5    field, issue date and horizon of every NDVI forecast sample, with the split
#> 6  events with their kind, date, name and numbers of responding and other fields
#> 7                             AUROC, AUPRC and F1 by experiment, event and model
#> 8                                     code version and dates of the run (a list)
#> 9           confusion matrix of attention_mil (rows observed, columns predicted)
#> 10     confusion matrix of lightgbm_usdm_only (rows observed, columns predicted)
#> 11   confusion matrix of lightgbm_with_fields (rows observed, columns predicted)
#> 12               confusion matrix of momentum (rows observed, columns predicted)
#> 13      confusion matrix of ndvi_anomaly_rule (rows observed, columns predicted)
#> 14              confusion matrix of no_change (rows observed, columns predicted)
#> 15 confusion matrix of transition_climatology (rows observed, columns predicted)
#> 16                             AUROC gain from field evidence, with 95% interval
#> 17                               predictions of every model for the test samples
#> 18           macro F1, balanced accuracy and recall per class by split and model
#> 19                   code version, dates and dropped samples of the run (a list)
#> 20             county, week, target and split of every drought-transition sample
r <- fpc_benchmark("task1_results", dir = d)
r[r$split == "test" & r$horizon_days == 30, c("model", "rmse", "skill_vs_ref")]
#>         model       rmse skill_vs_ref
#> 5 persistence 0.10233533  -0.06090951
#> 6 climatology 0.09935425   0.00000000
#> 7    lightgbm 0.07424492   0.44158048
#> 8 transformer 0.07352084   0.45241940
head(fpc_benchmark("task1_samples", dir = d))
#>    field_id issue_date horizon_days target_start target_end split f  t h
#> 1 FPC059432 2016-03-01           45   2016-04-10 2016-04-14 train 0 12 9
#> 2 FPC060780 2016-03-01           45   2016-04-10 2016-04-14 train 1 12 9
#> 3 FPC061123 2016-03-01           45   2016-04-10 2016-04-14 train 2 12 9
#> 4 FPC062581 2016-03-01           45   2016-04-10 2016-04-14 train 4 12 9
#> 5 FPC062877 2016-03-01           45   2016-04-10 2016-04-14 train 5 12 9
#> 6 FPC094408 2016-03-01           45   2016-04-10 2016-04-14 train 6 12 9
```
