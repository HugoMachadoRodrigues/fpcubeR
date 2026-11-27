#' Field identifiers across versions
#'
#' Reads `lineage.parquet`, which links every field of this version to the field of version 1.0 it
#' comes from. Fields were split into connected parts in version 1.1 and tier C was added in
#' version 1.3, so an identifier of version 1.0 may now be the same field, a reshaped one, one of
#' several parts, or no longer used.
#'
#' | `status` | meaning |
#' |---|---|
#' | `"unchanged"` | same pixels and same identifier as in version 1.0 |
#' | `"reshaped"` | the largest part of a version 1.0 field, which keeps its identifier |
#' | `"new"` | a further part of a version 1.0 field, or a tier C field (no parent); identifier above the version 1.0 maximum |
#' | `"removed"` | an identifier of version 1.0 that is no longer used |
#'
#' @param fields Field identifiers of this version (`"FPC000123"`), or a data frame from
#'   [fpc_fields()]. `NULL` keeps all.
#' @param parents Field identifiers of version 1.0: keeps the rows that come from them, including
#'   `removed` ones. `NULL` keeps all.
#' @param status Statuses to keep (see the table). `NULL` keeps all.
#' @inheritParams fpc_download
#' @return A data frame, one row per identifier: `field_id` (`NA` for removed identifiers), `fid`,
#'   `status`, `parent_field_id` and `parent_fid` (the version 1.0 field; `NA` for fields without
#'   one), `n_pixels` (30 m pixels in this version) and `obs_version` (the version whose
#'   observations the field's series use).
#' @export
#' @examples
#' d <- fpc_example_dir()
#' fpc_lineage(dir = d)
#' # a version 1.0 field split in two in version 1.1
#' fpc_lineage(parents = "FPC057124", dir = d)
fpc_lineage <- function(fields = NULL, parents = NULL, status = NULL, dir = NULL) {
  dir <- resolve_dir(dir)
  states <- c("unchanged", "reshaped", "new", "removed")
  bad <- setdiff(status, states)
  if (length(bad)) stop("Unknown status(es): ", paste(bad, collapse = ", "), call. = FALSE)
  x <- as.data.frame(arrow::read_parquet(need_file(file.path(dir, "lineage.parquet"), "lineage")))
  x$fid <- as.integer(x$fid)
  x$parent_fid <- as.integer(x$parent_fid)
  x$parent_fid[x$parent_fid == 0L] <- NA_integer_
  x$n_pixels <- as.integer(x$n_pixels)
  x$field_id <- ifelse(x$status == "removed", NA_character_, fpc_id(x$fid))
  x$parent_field_id <- ifelse(is.na(x$parent_fid), NA_character_, fpc_id(x$parent_fid))
  if (!is.null(fields)) x <- x[x$field_id %in% field_ids(fields), , drop = FALSE]
  if (!is.null(parents)) x <- x[x$parent_field_id %in% field_ids(parents), , drop = FALSE]
  if (!is.null(status)) x <- x[x$status %in% status, , drop = FALSE]
  x <- x[order(x$fid), c("field_id", "fid", "status", "parent_field_id", "parent_fid", "n_pixels", "obs_version")]
  rownames(x) <- NULL
  x
}

fpc_id <- function(fid) sprintf("FPC%06d", as.integer(fid))

#' Read the validation tables
#'
#' Reads the tables behind the validation of the data set (Sect. 5 of the paper). With
#' `table = NULL`, lists them.
#'
#' | `table` | content |
#' |---|---|
#' | `"fluccs_by_field"` | 30 m pixels of each field in each land-use group of the official FLUCCS maps of the five water management districts (2020-2023), pixels with no reference map, and the district |
#' | `"worldcover_by_field"` | share of each field in each ESA WorldCover 2021 class |
#' | `"coverage_by_year"` | median over fields of the days with a usable optical observation and of the days with a radar acquisition, by year |
#' | `"quality_by_stratum"` | by tier and field size: share of field-periods observed (dry season October-May, wet season June-September), interpolated and empty, median usable optical days per year, and fields with no optical observation |
#' | `"delineation_accounting"` | area (and number of units) at each step of the field delineation |
#' | `"summary"` | every number of the validation section, as a list |
#'
#' The per-field tables get `field_id` as their first column. In `coverage_by_year` the year
#' column is named `year` (`day` in the file), and the size classes of `quality_by_stratum` are
#' written as plain text (`"2-5 ha"`, `">=100 ha"`).
#'
#' @param table Table to read (see the table above). `NULL` lists the tables.
#' @param fields For the per-field tables, field identifiers or a data frame from [fpc_fields()].
#'   `NULL` keeps all.
#' @inheritParams fpc_download
#' @return A data frame (a list for `"summary"`). With `table = NULL`, a data frame with the name,
#'   file and description of every table.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' fpc_validation(dir = d)
#' fpc_validation("worldcover_by_field", dir = d)
#' fpc_validation("quality_by_stratum", dir = d)
fpc_validation <- function(table = NULL, fields = NULL, dir = NULL) {
  dir <- resolve_dir(dir)
  sub <- file.path(dir, "validation")
  tabs <- data.frame(
    table = c("fluccs_by_field", "worldcover_by_field", "coverage_by_year", "quality_by_stratum",
              "delineation_accounting", "summary"),
    file = c("fluccs_by_field.csv", "worldcover_by_field.csv", "coverage_by_year.csv", "quality_by_stratum.csv",
             "delineation_accounting.csv", "summary.json"),
    description = c(
      "30 m pixels of each field in each FLUCCS land-use group, and the water management district",
      "share of each field in each ESA WorldCover 2021 class",
      "median over fields of the usable optical days and the radar days, by year",
      "observed, interpolated and empty shares and usable days by tier and field size",
      "area at each step of the field delineation",
      "every number of the validation section (a list)"
    ),
    stringsAsFactors = FALSE
  )
  if (!dir.exists(sub)) need_file(sub, "validation")
  if (is.null(table)) return(tabs)
  if (length(table) != 1 || !table %in% tabs$table) {
    stop("Unknown validation table: ", paste(table, collapse = ", "), ". See fpc_validation().", call. = FALSE)
  }
  per_field <- table %in% c("fluccs_by_field", "worldcover_by_field")
  if (!is.null(fields) && !per_field) stop("`fields` applies only to the per-field tables.", call. = FALSE)
  x <- read_release_file(need_file(file.path(sub, tabs$file[tabs$table == table]), "validation"))
  if (per_field) {
    x$fid <- as.integer(x$fid)
    x$field_id <- fpc_id(x$fid)
    x <- x[, c("field_id", "fid", setdiff(names(x), c("field_id", "fid")))]
    if (!is.null(fields)) x <- x[x$field_id %in% field_ids(fields), , drop = FALSE]
    x <- x[order(x$fid), , drop = FALSE]
    rownames(x) <- NULL
  }
  if (table == "coverage_by_year") names(x)[names(x) == "day"] <- "year"
  if (table == "quality_by_stratum") x$size <- sub("$\\geq$", ">=", gsub("--", "-", x$size), fixed = TRUE)
  x
}

#' Read the benchmark samples and results
#'
#' Reads the files of the three benchmark tasks of the paper: the samples with their splits, the
#' scores of every model, the predictions and the run information. With `table = NULL`, lists the
#' tables of the data folder.
#'
#' Task 1 forecasts the field NDVI 15 to 60 days ahead; task 2 detects the fields that responded to
#' an extreme event; task 3 forecasts the change of the county drought class. In `task1_samples`,
#' each row is a field, an issue date and a horizon; the file stores them as positions in
#' `cube.zarr` (`f`, `t`, `h`), which are kept, and `field_id`, `issue_date`, `horizon_days`,
#' `target_start`, `target_end` are added (this needs `fields.parquet`). The confusion matrices
#' of task 3 have the observed class in rows and the predicted class in columns.
#'
#' @param table Table to read: a file name without extension, as listed by `fpc_benchmark()`.
#' @param fields For `task1_samples`, field identifiers or a data frame from [fpc_fields()]. `NULL`
#'   keeps all (12 million rows).
#' @inheritParams fpc_download
#' @return A data frame (a list for the `run_info` and `benchmark_text` files). With
#'   `table = NULL`, a data frame with the name, task, file and description of every table.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' fpc_benchmark(dir = d)
#' r <- fpc_benchmark("task1_results", dir = d)
#' r[r$split == "test" & r$horizon_days == 30, c("model", "rmse", "skill_vs_ref")]
#' head(fpc_benchmark("task1_samples", dir = d))
fpc_benchmark <- function(table = NULL, fields = NULL, dir = NULL) {
  dir <- resolve_dir(dir)
  sub <- file.path(dir, "benchmark")
  if (!dir.exists(sub)) need_file(sub, "benchmark")
  files <- sort(list.files(sub, pattern = "\\.(csv|parquet|json)$"))
  tabs <- data.frame(table = tools::file_path_sans_ext(files), file = files, stringsAsFactors = FALSE)
  tabs$task <- suppressWarnings(as.integer(sub("^task([0-9]).*", "\\1", tabs$table)))
  tabs$description <- vapply(tabs$table, benchmark_description, "", USE.NAMES = FALSE)
  tabs <- tabs[, c("table", "task", "file", "description")]
  if (is.null(table)) return(tabs)
  if (length(table) != 1 || !table %in% tabs$table) {
    stop("Unknown benchmark table: ", paste(table, collapse = ", "), ". See fpc_benchmark().", call. = FALSE)
  }
  if (!is.null(fields) && table != "task1_samples") {
    stop("`fields` applies only to task1_samples.", call. = FALSE)
  }
  path <- file.path(sub, tabs$file[tabs$table == table])
  if (table == "task1_samples") return(task1_samples(path, fields, dir))
  x <- read_release_file(path)
  if (grepl("^task3_confusion_", table)) names(x)[1] <- "observed"
  if (table == "task1_lightgbm_importance") names(x) <- c("feature", "gain")
  if (table == "task2_events") x$date <- as.Date(x$date)
  x
}

benchmark_description <- function(table) {
  d <- c(
    task1_samples = "field, issue date and horizon of every NDVI forecast sample, with the split",
    task1_results = "RMSE, MAE, bias, R2 and skill by split, horizon and model, with 95% intervals",
    task1_lightgbm_importance = "gain of every LightGBM feature",
    task1_run_info = "code version, dates and sample counts of the run (a list)",
    task2_events = "events with their kind, date, name and numbers of responding and other fields",
    task2_results = "AUROC, AUPRC and F1 by experiment, event and model",
    task2_run_info = "code version and dates of the run (a list)",
    task3_samples = "county, week, target and split of every drought-transition sample",
    task3_predictions = "predictions of every model for the test samples",
    task3_results = "macro F1, balanced accuracy and recall per class by split and model",
    task3_field_evidence_gain = "AUROC gain from field evidence, with 95% interval",
    task3_run_info = "code version, dates and dropped samples of the run (a list)",
    benchmark_text = "every number of the benchmark section (a list)"
  )
  if (table %in% names(d)) return(d[[table]])
  if (grepl("^task3_confusion_", table)) {
    return(paste("confusion matrix of", sub("^task3_confusion_", "", table), "(rows observed, columns predicted)"))
  }
  ""
}

# the composites are 5-day periods anchored on 1 January 2016; t is the period index of cube.zarr
period_start <- function(t) as.Date("2016-01-01") + 5L * as.integer(t)

task1_samples <- function(path, fields, dir) {
  lut <- fpc_fields(columns = character(0), geometry = FALSE, dir = dir)
  q <- arrow::open_dataset(path)
  if (!is.null(fields)) {
    f <- match(field_ids(fields), lut$field_id) - 1L
    q <- dplyr::filter(q, .data$f %in% !!f[!is.na(f)])
  }
  x <- as.data.frame(dplyr::collect(q))
  for (k in c("f", "t", "h")) x[[k]] <- as.integer(x[[k]])
  if (length(x$f) && max(x$f) >= nrow(lut)) {
    stop("task1_samples does not match fields.parquet in ", dir, ".", call. = FALSE)
  }
  out <- data.frame(field_id = lut$field_id[x$f + 1L], issue_date = period_start(x$t), horizon_days = 5L * x$h,
                    stringsAsFactors = FALSE)
  out$target_start <- period_start(x$t + x$h - 1L)
  out$target_end <- out$target_start + 4L
  out$split <- as.character(x$split)
  cbind(out, x[, c("f", "t", "h")])
}

read_release_file <- function(path) {
  switch(tools::file_ext(path),
    parquet = {
      x <- as.data.frame(arrow::read_parquet(path))
      for (k in names(x)) if (is.factor(x[[k]])) x[[k]] <- as.character(x[[k]])
      utc(x)
    },
    csv = utils::read.csv(path, check.names = FALSE, stringsAsFactors = FALSE),
    json = jsonlite::fromJSON(path)
  )
}
