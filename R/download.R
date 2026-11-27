#' Zenodo record of the Florida Pasture Cube data
#'
#' The record identifier of the version 1.3 data set on Zenodo (DOI 10.5281/zenodo.24542431).
#' [fpc_files()] and [fpc_download()] use it by default.
#'
#' @format A character string.
#' @export
#' @examples
#' fpc_record
#' paste0("https://zenodo.org/records/", fpc_record)
fpc_record <- "24542431"

#' List the files of the Florida Pasture Cube on Zenodo
#'
#' @param record Zenodo record identifier. Defaults to [fpc_record].
#' @return A data frame with the file name, the group it belongs to (as used by [fpc_download()]),
#'   its size in MB, its MD5 checksum and its download URL.
#' @export
#' @examples
#' \dontrun{
#' fpc_files()
#' }
fpc_files <- function(record = fpc_record) {
  url <- sprintf("https://zenodo.org/api/records/%s", record)
  h <- curl::new_handle()
  curl::handle_setheaders(h, Accept = "application/json")
  res <- curl::curl_fetch_memory(url, handle = h)
  if (res$status_code != 200) {
    stop("Zenodo returned HTTP ", res$status_code, " for record ", record, ".", call. = FALSE)
  }
  rec <- jsonlite::fromJSON(rawToChar(res$content), simplifyVector = FALSE)
  files <- rec$files
  out <- data.frame(
    file = vapply(files, function(f) f$key, ""),
    size_mb = vapply(files, function(f) f$size / 1e6, 0),
    md5 = vapply(files, function(f) sub("^md5:", "", f$checksum), ""),
    url = vapply(files, function(f) f$links$self, ""),
    stringsAsFactors = FALSE
  )
  out$group <- file_group(out$file)
  out[order(out$group, out$file), c("file", "group", "size_mb", "md5", "url")]
}

file_group <- function(file) {
  g <- c(
    "fields.parquet" = "fields", "lineage.parquet" = "lineage", "labels.zip" = "labels",
    "optical_observations.zip" = "optical", "radar_observations.zip" = "radar",
    "validation.zip" = "validation", "benchmark.zip" = "benchmark", "stac.zip" = "stac",
    "cube.zarr.zip" = "cube", "DATASHEET.md" = "docs", "SHA256SUMS" = "docs", "DEPOSIT_SHA256SUMS" = "docs"
  )
  out <- unname(g[file])
  out[grepl("^composites_[0-9]{4}\\.parquet$", file)] <- "composites"
  out[is.na(out)] <- "other"
  out
}

#' Download the Florida Pasture Cube
#'
#' Downloads the chosen parts of the data set from Zenodo into the data folder, checks the MD5
#' checksum of every file, and unpacks the zipped folders so that the folder has the layout of the
#' release. Files that are already there with the right checksum are not downloaded again.
#'
#' | `what` | content | size |
#' |---|---|---|
#' | `"fields"` | `fields.parquet`: one row per field, geometry and static attributes | 27 MB |
#' | `"composites"` | `composites/composites_YYYY.parquet`: 5-day composites, one file per year | about 200 MB per year |
#' | `"labels"` | `labels/`: US Drought Monitor, NASS pasture condition, hurricane tracks and landfalls | < 1 MB |
#' | `"lineage"` | `lineage.parquet`: field identifiers across versions | 1 MB |
#' | `"optical"` | `optical_observations/`: one row per field and HLS granule | 4 GB |
#' | `"radar"` | `radar_observations/`: one row per field and Sentinel-1 acquisition | 1 GB |
#' | `"validation"` | `validation/`: the tables behind the validation of the paper (see [fpc_validation()]) | 8 MB |
#' | `"benchmark"` | `benchmark/`: samples, results and predictions of the benchmark (see [fpc_benchmark()]) | 27 MB |
#' | `"stac"` | `stac/`: SpatioTemporal Asset Catalog of the release | < 1 MB |
#' | `"cube"` | `cube.zarr.zip`: the same composites as a Zarr store (for Python) | 2.5 GB |
#' | `"docs"` | `DATASHEET.md` and checksums | small |
#'
#' @param what Parts to download (see the table). Defaults to the fields, the composites and the labels.
#' @param years Years of the composites to download (2016 to 2026). `NULL` downloads all.
#' @param dir Data folder. Defaults to [fpc_dir()].
#' @param record Zenodo record identifier. Defaults to [fpc_record].
#' @param overwrite Download again even if the file is present with the right checksum.
#' @param quiet Suppress progress messages.
#' @return The data folder, invisibly.
#' @export
#' @examples
#' \dontrun{
#' fpc_download()                                     # fields, all composites, labels
#' fpc_download(c("fields", "composites"), years = 2022:2023)
#' }
fpc_download <- function(what = c("fields", "composites", "labels"), years = NULL, dir = NULL,
                         record = fpc_record, overwrite = FALSE, quiet = FALSE) {
  groups <- c("fields", "composites", "labels", "lineage", "optical", "radar", "validation", "benchmark",
              "stac", "cube", "docs")
  bad <- setdiff(what, groups)
  if (length(bad)) stop("Unknown part(s): ", paste(bad, collapse = ", "), call. = FALSE)
  dir <- if (is.null(dir)) fpc_dir() else normalizePath(dir, mustWork = FALSE)
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  files <- fpc_files(record)
  files <- files[files$group %in% what, ]
  if (!is.null(years)) {
    yr <- suppressWarnings(as.integer(sub("^composites_([0-9]{4})\\.parquet$", "\\1", files$file)))
    files <- files[files$group != "composites" | yr %in% years, ]
  }
  if (!nrow(files)) stop("Nothing to download for these parts and years.", call. = FALSE)
  if (!quiet) message(sprintf("Downloading %d file(s), %.0f MB, to %s", nrow(files), sum(files$size_mb), dir))
  for (i in seq_len(nrow(files))) {
    f <- files[i, ]
    dest <- target_path(dir, f$file, f$group)
    done <- marker_path(dir, f$file)
    if (!overwrite && file.exists(done) && identical(readLines(done, warn = FALSE), f$md5)) {
      if (!quiet) message("  present: ", f$file)
      next
    }
    dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    tmp <- paste0(dest, ".part")
    if (!quiet) message(sprintf("  %s (%.0f MB)", f$file, f$size_mb))
    curl::curl_download(f$url, tmp, quiet = TRUE, handle = curl::new_handle(failonerror = TRUE))
    got <- unname(tools::md5sum(tmp))
    if (!identical(got, f$md5)) {
      unlink(tmp)
      stop("Checksum mismatch for ", f$file, "; try again.", call. = FALSE)
    }
    if (grepl("\\.zip$", f$file) && f$group != "cube") {
      utils::unzip(tmp, exdir = dir)
      unlink(tmp)
    } else {
      file.rename(tmp, dest)
    }
    dir.create(dirname(done), recursive = TRUE, showWarnings = FALSE)
    writeLines(f$md5, done)
  }
  invisible(dir)
}

target_path <- function(dir, file, group) {
  if (group == "composites") return(file.path(dir, "composites", file))
  file.path(dir, file)
}

marker_path <- function(dir, file) file.path(dir, ".fpcubeR", paste0(file, ".md5"))

#' Check the downloaded files against the release checksums
#'
#' Compares the SHA-256 checksum of every file of the data folder that is listed in `SHA256SUMS`
#' (download it with `fpc_download("docs")`). Needs the `digest` package.
#'
#' @inheritParams fpc_download
#' @return A data frame with the file, whether it is present and whether its checksum matches.
#' @export
#' @examples
#' \dontrun{
#' fpc_download(c("docs", "fields", "composites"))
#' v <- fpc_verify()
#' v[v$present & !v$ok, ]   # files whose checksum does not match
#' }
fpc_verify <- function(dir = NULL) {
  if (!requireNamespace("digest", quietly = TRUE)) stop("fpc_verify() needs the digest package.", call. = FALSE)
  dir <- resolve_dir(dir)
  sums <- need_file(file.path(dir, "SHA256SUMS"), "docs")
  x <- utils::read.table(sums, col.names = c("sha256", "file"), colClasses = "character")
  x <- x[!grepl("^cube\\.zarr/", x$file), ]
  path <- file.path(dir, x$file)
  x$present <- file.exists(path)
  x$ok <- NA
  x$ok[x$present] <- vapply(path[x$present], function(p) digest::digest(p, "sha256", file = TRUE), "") ==
    x$sha256[x$present]
  rownames(x) <- NULL
  x[, c("file", "present", "ok")]
}
