#' Plot the time series of a field
#'
#' One panel per variable. Observed optical values are points joined by a line; with
#' `show_gap_filled = TRUE` the gap-filled values are drawn as open circles. Rainfall is drawn as
#' bars. Lines are broken where observations are more than 30 days apart. Needs the `ggplot2`
#' package.
#'
#' @param field Field identifier.
#' @param vars Variables to plot.
#' @param show_gap_filled Draw the gap-filled optical values (read with `observed_only = FALSE`).
#' @param x Optional data frame from [fpc_composites()] (wide); if `NULL` the data are read.
#' @inheritParams fpc_composites
#' @return A `ggplot` object.
#' @export
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   d <- fpc_example_dir()
#'   id <- fpc_fields(tier = "A", dir = d, geometry = FALSE)$field_id[1]
#'   fpc_plot_field(id, years = 2021:2023, dir = d)
#' }
fpc_plot_field <- function(field, vars = c("ndvi", "vv_db", "ppt_sum"), years = NULL, from = NULL, to = NULL,
                           show_gap_filled = TRUE, x = NULL, dir = NULL) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("fpc_plot_field() needs the ggplot2 package.", call. = FALSE)
  stopifnot(length(field) == 1)
  if (is.null(x)) {
    x <- fpc_composites(field, vars = vars, years = years, from = from, to = to, observed_only = FALSE, dir = dir)
  } else {
    x <- x[x$field_id == field, ]
  }
  if (!nrow(x)) stop("No data for field ", field, ".", call. = FALSE)
  meta <- tryCatch(fpc_variables(dir), error = function(e) NULL)
  lab <- function(v) {
    if (is.null(meta) || !v %in% meta$name) return(v)
    u <- meta$units[meta$name == v]
    if (nzchar(u) && u != "1") sprintf("%s (%s)", v, u) else v
  }
  optical <- if (is.null(meta)) c("blue", "green", "red", "nir", "swir1", "swir2", "ndvi", "evi", "ndmi", "mndwi",
                                  "nbr", "ndvi_sd", "water_frac") else meta$name[meta$group == "optical"]
  long <- to_long(x, vars)
  long$panel <- factor(vapply(long$variable, lab, ""), levels = vapply(vars, lab, ""))
  long$kind <- ifelse(long$variable %in% optical & long$gap_filled, "gap-filled", "observed")
  obs <- long[long$kind == "observed" & !long$variable %in% "ppt_sum" & !is.na(long$value), ]
  # break the line where consecutive observations are more than 30 days apart
  obs <- obs[order(obs$variable, obs$date), ]
  brk <- c(TRUE, diff(as.numeric(obs$date)) > 30 | obs$variable[-1] != obs$variable[-nrow(obs)])
  obs$segment <- cumsum(brk)
  gap <- long[long$kind == "gap-filled" & !is.na(long$value), ]
  rain <- long[long$variable == "ppt_sum" & !is.na(long$value), ]
  p <- ggplot2::ggplot(mapping = ggplot2::aes(x = .data$date, y = .data$value))
  if (nrow(rain)) {
    p <- p + ggplot2::geom_col(data = rain, fill = "#2a7fbf", width = 4.5)
  }
  if (nrow(obs)) {
    p <- p + ggplot2::geom_line(data = obs, ggplot2::aes(group = .data$segment), colour = "#1b5e3b",
                                linewidth = 0.35) +
      ggplot2::geom_point(data = obs, colour = "#1b5e3b", size = 0.9)
  }
  if (show_gap_filled && nrow(gap)) {
    p <- p + ggplot2::geom_point(data = gap, shape = 21, colour = "#9a9a9a", fill = "white", size = 0.9)
  }
  p + ggplot2::facet_wrap(ggplot2::vars(.data$panel), ncol = 1, scales = "free_y", strip.position = "left") +
    ggplot2::labs(x = NULL, y = NULL, title = field,
                  subtitle = if (show_gap_filled) "filled: observed; open: gap-filled (not for causal use)" else NULL) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(strip.placement = "outside", panel.grid.minor = ggplot2::element_blank(),
                   plot.subtitle = ggplot2::element_text(colour = "grey40"))
}

#' Map fields
#'
#' Draws field polygons coloured by a column, for example the tier or a summary of the composites
#' joined to the fields. Needs the `ggplot2` package.
#'
#' @param fields An `sf` data frame from [fpc_fields()].
#' @param fill Column used for the colour.
#' @return A `ggplot` object.
#' @export
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   fpc_map_fields(fpc_fields(dir = fpc_example_dir()))
#' }
fpc_map_fields <- function(fields, fill = "tier") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("fpc_map_fields() needs the ggplot2 package.", call. = FALSE)
  stopifnot(inherits(fields, "sf"), fill %in% names(fields))
  p <- ggplot2::ggplot(fields) +
    ggplot2::geom_sf(ggplot2::aes(fill = .data[[fill]]), colour = "grey25", linewidth = 0.1) +
    ggplot2::theme_minimal(base_size = 10)
  if (fill == "tier") {
    p <- p + ggplot2::scale_fill_manual(values = c(A = "#2f7bd9", B = "#ef6a3a", C = "#1fae7a"), drop = TRUE)
  }
  p
}
