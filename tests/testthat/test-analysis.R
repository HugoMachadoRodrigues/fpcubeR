d <- fpc_example_dir()

test_that("period of year runs from 1 to 73", {
  p <- period_of_year(as.Date(c("2022-01-01", "2022-01-05", "2022-01-06", "2022-12-31", "2024-12-31")))
  expect_equal(p, c(1L, 1L, 2L, 73L, 73L))
})

test_that("climatology and anomaly use observed values of the reference years", {
  x <- fpc_composites(vars = "ndvi", dir = d)
  cl <- fpc_climatology(x, "ndvi", ref_years = 2021:2022, min_years = 1)
  expect_true(all(cl$n_years >= 1 & cl$n_years <= 2))
  expect_true(all(cl$period %in% 1:73))
  # hand check for one field and period
  one <- cl[!is.na(cl$clim), ][1, ]
  xx <- x[x$field_id == one$field_id & period_of_year(x$date) == one$period &
            format(x$date, "%Y") %in% c("2021", "2022") & !is.na(x$ndvi), ]
  expect_equal(one$clim, mean(xx$ndvi))
  a <- fpc_anomaly(x, "ndvi", ref_years = 2021:2022, min_years = 1)
  ok <- !is.na(a$anomaly)
  expect_equal(a$anomaly[ok], a$ndvi[ok] - a$clim[ok])
  cl2 <- fpc_climatology(x, "ndvi", ref_years = 2021:2022, min_years = 2)
  expect_true(all(is.na(cl2$clim[cl2$n_years < 2])))
})

test_that("drought class is joined by county and week", {
  x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
  y <- fpc_add_drought(x, dir = d)
  expect_true(all(c("usdm_class", "usdm_d1_pct", "dsci") %in% names(y)))
  expect_false(anyNA(y$usdm_class))
  expect_true(all(y$usdm_class %in% 0:5))
  # check one row by hand
  f <- fpc_fields(fields = y$field_id[100], columns = "county_fips", geometry = FALSE, dir = d)
  u <- fpc_labels("usdm", d)
  u <- u[u$county_fips == f$county_fips & as.Date(u$valid_start) <= y$date[100] &
           as.Date(u$valid_end) >= y$date[100], ]
  expect_equal(y$usdm_class[100], as.integer(u$dominant_class))
})

test_that("summaries over fields", {
  x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
  s <- fpc_summarise(x, "ndvi")
  expect_true(all(s$n_fields >= 1 & s$n_fields <= 9))
  f <- fpc_fields(dir = d, geometry = FALSE)
  x$tier <- f$tier[match(x$field_id, f$field_id)]
  st <- fpc_summarise(x, "ndvi", by = "tier")
  expect_setequal(unique(st$tier), c("A", "B", "C"))
})

test_that("plots build", {
  skip_if_not_installed("ggplot2")
  id <- fpc_fields(dir = d, geometry = FALSE)$field_id[1]
  p <- fpc_plot_field(id, years = 2022, dir = d)
  expect_s3_class(p, "ggplot")
  expect_silent(ggplot2::ggplot_build(p))
  m <- fpc_map_fields(fpc_fields(dir = d))
  expect_s3_class(m, "ggplot")
})
