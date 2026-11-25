#' Folder of the Florida Pasture Cube data
#'
#' The functions of this package read the data from one folder that has the layout of the release:
#' `fields.parquet`, `composites/composites_YYYY.parquet`, `labels/`, `optical_observations/`,
#' `radar_observations/` and so on. [fpc_download()] fills it.
#'
#' The folder is, in this order, the one set with `fpc_set_dir()` in this session, the environment
#' variable `FPCUBE_DIR`, or a folder in the user's data directory
#' (`tools::R_user_dir("fpcubeR", "data")`).
#'
#' @param path Folder to use.
#' @return `fpc_dir()` returns the folder path; `fpc_set_dir()` returns the previous one, invisibly.
#' @export
#' @examples
#' old <- fpc_set_dir(fpc_example_dir())
#' fpc_dir()
#' fpc_set_dir(old)
fpc_dir <- function() {
  d <- getOption("fpcubeR.dir")
  if (is.null(d) || !nzchar(d)) d <- Sys.getenv("FPCUBE_DIR")
  if (!nzchar(d)) d <- tools::R_user_dir("fpcubeR", "data")
  normalizePath(d, mustWork = FALSE)
}

#' @rdname fpc_dir
#' @export
fpc_set_dir <- function(path) {
  old <- getOption("fpcubeR.dir")
  options(fpcubeR.dir = if (is.null(path)) NULL else normalizePath(path, mustWork = FALSE))
  invisible(old)
}

#' Small example of the Florida Pasture Cube shipped with the package
#'
#' Nine fields (three of each tier) with their composites for 2021-2023, optical and radar
#' observations for 2022 and the labels of their counties, in the layout of the release. Use it to
#' try the functions without downloading anything.
#'
#' @return Path to the example folder.
#' @export
#' @examples
#' fpc_fields(dir = fpc_example_dir(), geometry = FALSE)
fpc_example_dir <- function() {
  system.file("extdata", "fpcube_example", package = "fpcubeR", mustWork = TRUE)
}

resolve_dir <- function(dir) {
  dir <- if (is.null(dir)) fpc_dir() else normalizePath(dir, mustWork = FALSE)
  if (!dir.exists(dir)) {
    stop("No Florida Pasture Cube data in ", dir, ". Run fpc_download() first, or set the folder with ",
         "fpc_set_dir().", call. = FALSE)
  }
  dir
}

need_file <- function(path, what) {
  if (!file.exists(path)) {
    stop("Missing ", basename(path), " in ", dirname(path), ". Download it with fpc_download(\"", what, "\").",
         call. = FALSE)
  }
  path
}
