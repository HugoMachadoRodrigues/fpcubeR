#' Add the county drought class to field-periods
#'
#' Joins the US Drought Monitor map that was valid on each date (the map whose week contains the
#' first day of the 5-day period) of the field's county.
#'
#' @param x A data frame with `field_id` and `date`, such as the output of [fpc_composites()].
#' @inheritParams fpc_download
#' @return `x` with the columns `usdm_class` (0 none, 1 D0, 2 D1, 3 D2, 4 D3, 5 D4: the
#'   highest category that covers at least half of the county), `usdm_d1_pct` (percent of the
#'   county in D1 or worse) and `dsci` (Drought Severity and Coverage Index, 0-500).
#' @export
#' @examples
#' d <- fpc_example_dir()
#' x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
#' x <- fpc_add_drought(x, dir = d)
#' table(x$usdm_class)
fpc_add_drought <- function(x, dir = NULL) {
  stopifnot(all(c("field_id", "date") %in% names(x)))
  dir <- resolve_dir(dir)
  f <- fpc_fields(fields = unique(x$field_id), columns = "county_fips", geometry = FALSE, dir = dir)
  u <- fpc_labels("usdm", dir = dir)
  u$valid_start <- as.Date(u$valid_start)
  u <- u[order(u$county_fips, u$valid_start), ]
  fips <- f$county_fips[match(x$field_id, f$field_id)]
  x$usdm_class <- NA_integer_
  x$usdm_d1_pct <- NA_real_
  x$dsci <- NA_real_
  d <- as.Date(x$date)
  for (cf in unique(stats::na.omit(fips))) {
    rows <- which(fips == cf)
    uc <- u[u$county_fips == cf, ]
    if (!nrow(uc)) next
    k <- findInterval(as.numeric(d[rows]), as.numeric(uc$valid_start))
    ok <- k > 0 & d[rows] <= as.Date(uc$valid_end[pmax(k, 1)])
    k[!ok] <- NA
    x$usdm_class[rows] <- as.integer(uc$dominant_class[k])
    x$usdm_d1_pct[rows] <- uc$D1[k]
    x$dsci[rows] <- uc$dsci[k]
  }
  x
}

#' Climatology and anomaly of a variable for each field
#'
#' `fpc_climatology()` computes, for each field and each 5-day period of the year, the mean of the
#' observed values in the reference years. `fpc_anomaly()` subtracts it from the values. Only
#' observed values enter the climatology: read the composites with `observed_only = TRUE`.
#'
#' Periods are numbered from 1 to 73 within each year (the 5-day calendar is anchored on
#' 1 January 2016 and runs continuously, so a period's position in the year shifts by one day in
#' leap years; period 74, when present, is merged into 73).
#'
#' @param x A data frame from [fpc_composites()] (wide format).
#' @param var Variable name.
#' @param ref_years Years that define the climatology. `NULL` uses every year in `x`.
#' @param min_years Minimum number of observed years for a period's climatology; fewer gives `NA`.
#' @return `fpc_climatology()`: a data frame with `field_id`, `period` (1-73), `clim` and `n_years`.
#'   `fpc_anomaly()`: `x` with the columns `period`, `clim` and `anomaly`.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' x <- fpc_composites(vars = "ndvi", dir = d)
#' a <- fpc_anomaly(x, "ndvi", ref_years = 2021:2022)
#' summary(a$anomaly[format(a$date, "%Y") == "2023"])
fpc_climatology <- function(x, var, ref_years = NULL, min_years = 2) {
  stopifnot(var %in% names(x))
  yr <- as.integer(format(as.Date(x$date), "%Y"))
  sel <- if (is.null(ref_years)) rep(TRUE, nrow(x)) else yr %in% ref_years
  d <- data.frame(field_id = x$field_id[sel], period = period_of_year(x$date[sel]), value = x[[var]][sel])
  d <- d[!is.na(d$value), ]
  if (!nrow(d)) return(data.frame(field_id = character(), period = integer(), clim = numeric(), n_years = integer()))
  key <- paste(d$field_id, d$period)
  clim <- tapply(d$value, key, mean)
  n <- tapply(d$value, key, length)
  parts <- strsplit(names(clim), " ", fixed = TRUE)
  out <- data.frame(field_id = vapply(parts, `[`, "", 1), period = as.integer(vapply(parts, `[`, "", 2)),
                    clim = as.numeric(clim), n_years = as.integer(n))
  out$clim[out$n_years < min_years] <- NA
  out <- out[order(out$field_id, out$period), ]
  rownames(out) <- NULL
  out
}

#' @rdname fpc_climatology
#' @export
fpc_anomaly <- function(x, var, ref_years = NULL, min_years = 2) {
  cl <- fpc_climatology(x, var, ref_years, min_years)
  x$period <- period_of_year(x$date)
  m <- match(paste(x$field_id, x$period), paste(cl$field_id, cl$period))
  x$clim <- cl$clim[m]
  x$anomaly <- x[[var]] - x$clim
  x
}

period_of_year <- function(date) {
  date <- as.Date(date)
  p <- as.integer((as.numeric(format(date, "%j")) - 1) %/% 5) + 1L
  pmin(p, 73L)
}

#' Summarise field-periods over fields
#'
#' Median (or another statistic) of a variable over the fields for each date, with the number of
#' fields that have a value. Useful for regional or statewide curves.
#'
#' @param x A data frame from [fpc_composites()] or [fpc_anomaly()].
#' @param var Variable to summarise.
#' @param by Optional grouping column of `x` besides `date` (e.g. `"tier"` after a merge with [fpc_fields()]).
#' @param fun Summary function, applied to the non-missing values.
#' @return A data frame with `date`, the grouping column, `value` and `n_fields`.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
#' head(fpc_summarise(x, "ndvi"))
fpc_summarise <- function(x, var, by = NULL, fun = stats::median) {
  stopifnot(var %in% names(x), is.null(by) || by %in% names(x))
  x <- x[!is.na(x[[var]]), ]
  g <- if (is.null(by)) list(date = x$date) else list(date = x$date, by = x[[by]])
  v <- stats::aggregate(x[[var]], g, fun)
  n <- stats::aggregate(x[[var]], g, length)
  names(v)[ncol(v)] <- "value"
  v$n_fields <- n$x
  if (!is.null(by)) names(v)[names(v) == "by"] <- by
  v[order(v$date), ]
}
