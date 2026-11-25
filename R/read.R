#' Read the pasture fields
#'
#' Reads `fields.parquet`: one row per field with its geometry (EPSG:5070, CONUS Albers), tier,
#' county, area, CDL pasture fraction per year, quality flags and soil, terrain and wetland
#' attributes. See `DATASHEET.md` for every column.
#'
#' Tiers: A, fields on parcels coded as grazing land; B, fields on other parcels that were mapped
#' as pasture in nearly every year; C, open pasture from the official land-use maps that the
#' Cropland Data Layer maps as woody or wetland. For a conservative set of grazing fields use tier A.
#'
#' @param tier Tiers to keep (`"A"`, `"B"`, `"C"`). `NULL` keeps all.
#' @param county County names to keep, e.g. `"Hardee"` (case-insensitive, with or without
#'   "County"). `NULL` keeps all.
#' @param fields Field identifiers to keep (`"FPC000123"`). `NULL` keeps all.
#' @param columns Columns to read besides `field_id`, `fid`, `tier` and `county`. `NULL` reads all.
#' @param geometry Return an `sf` object with the field polygons (`TRUE`) or a plain data frame.
#' @inheritParams fpc_download
#' @return An `sf` data frame (or a data frame), one row per field.
#' @export
#' @examples
#' f <- fpc_fields(tier = "A", dir = fpc_example_dir())
#' f[, c("field_id", "tier", "county", "area_ha")]
fpc_fields <- function(tier = NULL, county = NULL, fields = NULL, columns = NULL, geometry = TRUE, dir = NULL) {
  dir <- resolve_dir(dir)
  path <- need_file(file.path(dir, "fields.parquet"), "fields")
  ds <- arrow::open_dataset(path)
  keep <- unique(c("field_id", "fid", "tier", "county", columns, if (geometry) "geometry"))
  if (is.null(columns)) keep <- names(ds)
  if (!geometry) keep <- setdiff(keep, "geometry")
  miss <- setdiff(keep, names(ds))
  if (length(miss)) stop("Unknown column(s): ", paste(miss, collapse = ", "), call. = FALSE)
  q <- dplyr::select(ds, dplyr::all_of(keep))
  if (!is.null(tier)) q <- dplyr::filter(q, .data$tier %in% !!toupper(tier))
  if (!is.null(fields)) q <- dplyr::filter(q, .data$field_id %in% !!fields)
  x <- as.data.frame(dplyr::collect(q))
  if (!is.null(county)) {
    norm <- function(s) tolower(trimws(sub("\\s+county$", "", s, ignore.case = TRUE)))
    x <- x[norm(x$county) %in% norm(county), , drop = FALSE]
  }
  x <- x[order(x$field_id), , drop = FALSE]
  rownames(x) <- NULL
  if (geometry) {
    wkb <- structure(lapply(x$geometry, as.raw), class = "WKB")
    x$geometry <- NULL
    x <- sf::st_sf(x, geometry = sf::st_as_sfc(wkb, crs = 5070))
  }
  x
}

#' Variables of the 5-day composites
#'
#' @inheritParams fpc_download
#' @return A data frame with the name, group (optical, count, radar or weather), units and
#'   description of every variable of the composites, read from the metadata of the Parquet files.
#' @export
#' @examples
#' fpc_variables(dir = fpc_example_dir())
fpc_variables <- function(dir = NULL) {
  meta <- composites_meta(resolve_dir(dir))
  v <- meta$variables
  data.frame(
    name = vapply(v, function(z) z$name, ""), group = vapply(v, function(z) z$group, ""),
    units = vapply(v, function(z) z$units, ""), description = vapply(v, function(z) z$description, ""),
    stringsAsFactors = FALSE
  )
}

composite_files <- function(dir, years = NULL) {
  files <- list.files(file.path(dir, "composites"), pattern = "^composites_[0-9]{4}\\.parquet$", full.names = TRUE)
  if (!length(files)) {
    stop("No composites in ", file.path(dir, "composites"), ". Download them with fpc_download(\"composites\").",
         call. = FALSE)
  }
  yr <- as.integer(sub("^composites_([0-9]{4})\\.parquet$", "\\1", basename(files)))
  if (!is.null(years)) {
    miss <- setdiff(years, yr)
    if (length(miss)) {
      stop("Composites of ", paste(miss, collapse = ", "), " are not in ", dir, ". Download them with ",
           "fpc_download(\"composites\", years = ...).", call. = FALSE)
    }
    files <- files[yr %in% years]
  }
  files
}

composites_meta <- function(dir) {
  f <- composite_files(dir)[1]
  md <- arrow::read_parquet(f, as_data_frame = FALSE)$metadata
  jsonlite::fromJSON(md$fpcube, simplifyVector = FALSE)
}

#' Read the 5-day composites
#'
#' Reads the field x 5-day composites of HLS reflectance and indices, Sentinel-1 backscatter and
#' PRISM weather. `date` is the first day of each 5-day period.
#'
#' Optical gaps of up to 30 days are filled in the release by linear interpolation between the
#' observations on either side (`gap_filled = TRUE`, `n_optical_obs = 0`). Because an interpolated
#' value depends on the next observation, it must not be used as an input of a forecast or any
#' analysis that has to be causal. With `observed_only = TRUE` (the default) these optical values
#' are set to `NA`; radar and weather values are kept.
#'
#' @param fields Field identifiers (`"FPC000123"`), or a data frame from [fpc_fields()]. `NULL`
#'   reads all fields (large: about 4.6 million rows per year).
#' @param vars Variables to read (see [fpc_variables()]). `NULL` reads all.
#'   `n_optical_obs`, `gap_filled` and `n_radar_obs` are always included.
#' @param years Years to read. `NULL` reads every year that is in the data folder.
#' @param from,to First and last date (`Date` or `"YYYY-MM-DD"`) of the periods to keep.
#' @param observed_only Set gap-filled optical values to `NA` (see Details).
#' @param long Return one row per field, date and variable (`variable`, `value`) instead of one
#'   column per variable.
#' @inheritParams fpc_download
#' @return A data frame with `field_id`, `fid`, `date` and the variables.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' f <- fpc_fields(tier = "A", dir = d, geometry = FALSE)
#' x <- fpc_composites(f, vars = c("ndvi", "vv_db", "ppt_sum"), years = 2022, dir = d)
#' head(x)
fpc_composites <- function(fields = NULL, vars = NULL, years = NULL, from = NULL, to = NULL,
                           observed_only = TRUE, long = FALSE, dir = NULL) {
  dir <- resolve_dir(dir)
  if (is.null(years) && (!is.null(from) || !is.null(to))) {
    all_years <- as.integer(sub("^composites_([0-9]{4})\\.parquet$", "\\1",
                                basename(composite_files(dir))))
    lo <- if (is.null(from)) min(all_years) else as.integer(format(as.Date(from), "%Y"))
    hi <- if (is.null(to)) max(all_years) else as.integer(format(as.Date(to), "%Y"))
    years <- all_years[all_years >= lo & all_years <= hi]
  }
  files <- composite_files(dir, years)
  ds <- arrow::open_dataset(files)
  meta <- composites_meta(dir)
  allv <- vapply(meta$variables, function(z) z$name, "")
  optical <- allv[vapply(meta$variables, function(z) z$group == "optical", TRUE)]
  if (is.null(vars)) vars <- allv
  bad <- setdiff(vars, allv)
  if (length(bad)) stop("Unknown variable(s): ", paste(bad, collapse = ", "), call. = FALSE)
  keep <- unique(c("field_id", "fid", "date", vars, "n_optical_obs", "gap_filled", "n_radar_obs"))
  q <- dplyr::select(ds, dplyr::all_of(keep))
  ids <- field_ids(fields)
  if (!is.null(ids)) q <- dplyr::filter(q, .data$field_id %in% !!ids)
  if (!is.null(from)) q <- dplyr::filter(q, .data$date >= !!as.Date(from))
  if (!is.null(to)) q <- dplyr::filter(q, .data$date <= !!as.Date(to))
  x <- as.data.frame(dplyr::collect(q))
  x <- x[order(x$field_id, x$date), , drop = FALSE]
  rownames(x) <- NULL
  if (observed_only) {
    gf <- x$n_optical_obs == 0
    for (v in intersect(vars, optical)) x[[v]][gf] <- NA
  }
  if (long) x <- to_long(x, setdiff(vars, c("n_optical_obs", "gap_filled", "n_radar_obs")))
  x
}

field_ids <- function(fields) {
  if (is.null(fields)) return(NULL)
  if (is.data.frame(fields)) return(as.character(fields$field_id))
  as.character(fields)
}

to_long <- function(x, vars) {
  idc <- c("field_id", "fid", "date", "n_optical_obs", "gap_filled", "n_radar_obs")
  out <- lapply(vars, function(v) {
    d <- x[, idc]
    d$variable <- v
    d$value <- as.numeric(x[[v]])
    d
  })
  out <- do.call(rbind, out)
  out <- out[order(out$field_id, out$date, match(out$variable, vars)), ]
  rownames(out) <- NULL
  out
}

#' Read the per-acquisition observation tables
#'
#' One row per field and acquisition: for optical data, every HLS granule with the clear-pixel
#' count, field-mean reflectance and indices, the geometric shift and the quality flags; for radar,
#' every Sentinel-1 acquisition with linear and dB backscatter, platform and relative orbit.
#'
#' @param type `"optical"` or `"radar"`.
#' @param usable_only For optical data, keep only the records that enter the composites
#'   (`qa_use`: clear, geometric shift of at most one pixel, reflectance in range, no haze).
#' @inheritParams fpc_composites
#' @return A data frame. `fid` links to [fpc_fields()]; `field_id` is added.
#' @export
#' @examples
#' d <- fpc_example_dir()
#' o <- fpc_observations("optical", years = 2022, dir = d)
#' head(o[, c("field_id", "date", "sensor", "ndvi", "n_clear_px")])
fpc_observations <- function(type = c("optical", "radar"), fields = NULL, years = NULL, from = NULL,
                             to = NULL, usable_only = TRUE, dir = NULL) {
  type <- match.arg(type)
  dir <- resolve_dir(dir)
  sub <- file.path(dir, paste0(type, "_observations"))
  files <- list.files(sub, pattern = "^[0-9]{4}\\.parquet$", full.names = TRUE)
  if (!length(files)) stop("No ", type, " observations in ", dir, ". Download them with fpc_download(\"", type,
                           "\").", call. = FALSE)
  yr <- as.integer(sub("\\.parquet$", "", basename(files)))
  if (!is.null(from)) years <- intersect(if (is.null(years)) yr else years, yr[yr >= as.integer(format(as.Date(from), "%Y"))])
  if (!is.null(to)) years <- intersect(if (is.null(years)) yr else years, yr[yr <= as.integer(format(as.Date(to), "%Y"))])
  if (!is.null(years)) files <- files[yr %in% years]
  if (!length(files)) stop("No ", type, " observations for these years in ", dir, ".", call. = FALSE)
  lut <- fpc_fields(fields = field_ids(fields), columns = character(0), geometry = FALSE, dir = dir)
  out <- lapply(files, function(f) {
    q <- arrow::open_dataset(f)
    if (!is.null(fields)) q <- dplyr::filter(q, .data$fid %in% !!as.integer(lut$fid))
    if (type == "optical" && usable_only) q <- dplyr::filter(q, .data$qa_use)
    if (!is.null(from)) q <- dplyr::filter(q, .data$date >= !!as.POSIXct(as.Date(from), tz = "UTC"))
    if (!is.null(to)) q <- dplyr::filter(q, .data$date < !!as.POSIXct(as.Date(to) + 1, tz = "UTC"))
    x <- as.data.frame(dplyr::collect(q))
    x$fid <- as.integer(x$fid)
    x
  })
  x <- do.call(rbind, out)
  for (k in names(x)) if (is.factor(x[[k]])) x[[k]] <- as.character(x[[k]])
  x <- utc(x)
  x$field_id <- lut$field_id[match(x$fid, lut$fid)]
  x <- x[order(x$field_id, x$date), c("field_id", setdiff(names(x), "field_id"))]
  rownames(x) <- NULL
  x
}

#' Read the labels
#'
#' | `which` | content |
#' |---|---|
#' | `"usdm"` | US Drought Monitor, county-week: percent of the county area in each category (cumulative D0-D4), dominant class and DSCI |
#' | `"nass"` | NASS pasture condition for Florida, state-week: percent very poor to excellent and condition index |
#' | `"tracks"` | hurricane tracks (HURDAT2 and NHC working best tracks) of storms within 3 degrees of Florida |
#' | `"landfalls"` | Florida landfalls; those of storms not yet in HURDAT2 are derived from the track |
#'
#' @param which Label table to read.
#' @inheritParams fpc_download
#' @return A data frame.
#' @export
#' @examples
#' head(fpc_labels("nass", dir = fpc_example_dir()))
fpc_labels <- function(which = c("usdm", "nass", "tracks", "landfalls"), dir = NULL) {
  which <- match.arg(which)
  dir <- resolve_dir(dir)
  file <- c(usdm = "usdm_county_weekly.parquet", nass = "nass_fl_pasture_condition_weekly.parquet",
            tracks = "hurricane_tracks_florida.parquet", landfalls = "hurricane_landfalls.parquet")[[which]]
  x <- as.data.frame(arrow::read_parquet(need_file(file.path(dir, "labels", file), "labels")))
  for (k in names(x)) if (is.factor(x[[k]])) x[[k]] <- as.character(x[[k]])
  utc(x)
}

# the release stores times in UTC without a time zone: show them as UTC
utc <- function(x) {
  for (k in names(x)) if (inherits(x[[k]], "POSIXct")) attr(x[[k]], "tzone") <- "UTC"
  x
}
