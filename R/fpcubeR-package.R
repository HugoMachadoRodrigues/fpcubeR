#' fpcubeR: read the Florida Pasture Cube
#'
#' The Florida Pasture Cube describes 62,847 persistent pasture fields in Florida every 5 days
#' from January 2016 to October 2026 with HLS optical reflectance and indices, Sentinel-1
#' backscatter and PRISM weather, together with soil, terrain and wetland attributes and drought,
#' pasture condition and hurricane labels.
#'
#' * Get the data: [fpc_download()], [fpc_files()], [fpc_dir()], [fpc_verify()].
#' * Read it: [fpc_fields()], [fpc_composites()], [fpc_variables()], [fpc_observations()],
#'   [fpc_labels()].
#' * Analyse it: [fpc_add_drought()], [fpc_climatology()], [fpc_anomaly()], [fpc_summarise()].
#' * Plot it: [fpc_plot_field()], [fpc_map_fields()].
#' * Try it without downloading: [fpc_example_dir()].
#'
#' Data: CC BY 4.0, DOI 10.5281/zenodo.24542431. Cite the data set when you use it.
#'
#' @keywords internal
#' @importFrom rlang .data
"_PACKAGE"
