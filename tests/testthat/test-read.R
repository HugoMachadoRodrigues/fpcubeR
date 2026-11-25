d <- fpc_example_dir()

test_that("fields are read with geometry, filters and the right CRS", {
  f <- fpc_fields(dir = d)
  expect_s3_class(f, "sf")
  expect_equal(nrow(f), 9)
  expect_equal(sf::st_crs(f)$epsg, 5070L)
  expect_setequal(unique(f$tier), c("A", "B", "C"))
  expect_true(all(sf::st_is_valid(f)))
  expect_equal(nrow(fpc_fields(tier = "a", dir = d)), 3)
  expect_equal(nrow(fpc_fields(county = "hardee county", dir = d, geometry = FALSE)), 6)
  g <- fpc_fields(fields = f$field_id[1:2], columns = "area_ha", geometry = FALSE, dir = d)
  expect_false(inherits(g, "sf"))
  expect_equal(names(g), c("field_id", "fid", "tier", "county", "area_ha"))
  expect_error(fpc_fields(columns = "nope", dir = d), "Unknown column")
})

test_that("no parcel identifier or owner field is in the example", {
  f <- fpc_fields(dir = d, geometry = FALSE)
  expect_false(any(grepl("parcel_id|owner|pidx|address", names(f), ignore.case = TRUE)))
})

test_that("variables come from the Parquet metadata", {
  v <- fpc_variables(d)
  expect_true(all(c("ndvi", "vv_db", "ppt_sum", "n_optical_obs", "gap_filled") %in% v$name))
  expect_equal(v$group[v$name == "ndvi"], "optical")
  expect_equal(v$units[v$name == "ppt_sum"], "mm")
})

test_that("composites: filters, observed-only masking and long format", {
  f <- fpc_fields(dir = d, geometry = FALSE)
  x <- fpc_composites(f, vars = c("ndvi", "vv_db"), years = 2022, dir = d, observed_only = FALSE)
  expect_equal(nrow(x), 9 * 73)
  expect_true(all(format(x$date, "%Y") == "2022"))
  expect_s3_class(x$date, "Date")
  expect_false(is.unsorted(paste(x$field_id, x$date)))
  # gap-filled optical values exist and are removed by default
  expect_true(any(x$gap_filled & !is.na(x$ndvi)))
  y <- fpc_composites(f, vars = c("ndvi", "vv_db"), years = 2022, dir = d)
  expect_true(all(is.na(y$ndvi[y$n_optical_obs == 0])))
  expect_equal(y$ndvi[y$n_optical_obs > 0], x$ndvi[x$n_optical_obs > 0])
  expect_equal(y$vv_db, x$vv_db)                            # radar untouched
  z <- fpc_composites(f$field_id[1], vars = "ndvi", from = "2022-03-01", to = "2022-03-31", dir = d)
  expect_true(all(z$date >= as.Date("2022-03-01") & z$date <= as.Date("2022-03-31")))
  expect_equal(nrow(z), 6)
  w <- fpc_composites(f$field_id[1:2], vars = "ndvi", years = 2021:2022, dir = d)
  expect_equal(range(format(w$date, "%Y")), c("2021", "2022"))
  l <- fpc_composites(f$field_id[1], vars = c("ndvi", "vv_db"), years = 2022, long = TRUE, dir = d)
  expect_equal(nrow(l), 73 * 2)
  expect_setequal(unique(l$variable), c("ndvi", "vv_db"))
  expect_error(fpc_composites(vars = "nope", dir = d), "Unknown variable")
  expect_error(fpc_composites(years = 2016, dir = d), "not in")
})

test_that("from/to without years selects the years", {
  x <- fpc_composites(vars = "ndvi", from = "2023-12-01", dir = d)
  expect_true(all(x$date >= as.Date("2023-12-01")))
  expect_true(nrow(x) > 0)
})

test_that("observations: optical usable records and radar", {
  f <- fpc_fields(dir = d, geometry = FALSE)
  o <- fpc_observations("optical", fields = f$field_id[1:2], years = 2022, dir = d)
  expect_true(all(o$qa_use))
  expect_setequal(unique(o$field_id), f$field_id[1:2])
  all_o <- fpc_observations("optical", years = 2022, usable_only = FALSE, dir = d)
  expect_gte(nrow(all_o), nrow(fpc_observations("optical", years = 2022, dir = d)))
  r <- fpc_observations("radar", years = 2022, from = "2022-06-01", to = "2022-06-30", dir = d)
  expect_true(all(c("vv_db", "relative_orbit", "platform") %in% names(r)))
  expect_true(all(as.Date(r$date) >= as.Date("2022-06-01") & as.Date(r$date) <= as.Date("2022-06-30")))
  expect_equal(attr(r$date, "tzone"), "UTC")
  expect_false(anyNA(r$field_id))
})

test_that("labels", {
  expect_true(all(c("county_fips", "valid_start", "dominant_class") %in% names(fpc_labels("usdm", d))))
  expect_true("condition_index" %in% names(fpc_labels("nass", d)))
  lf <- fpc_labels("landfalls", d)
  expect_equal(attr(lf$time, "tzone"), "UTC")
  ian <- lf[lf$name == "IAN" & format(lf$time, "%Y") == "2022", ]
  expect_true(nrow(ian) >= 1)
})

test_that("missing data give helpful errors", {
  tmp <- withr_tempdir()
  expect_error(fpc_fields(dir = tmp), "fpc_download")
  expect_error(fpc_composites(dir = tmp), "fpc_download")
  expect_error(fpc_fields(dir = file.path(tmp, "absent")), "fpc_download")
})

test_that("data folder option", {
  old <- fpc_set_dir(d)
  on.exit(fpc_set_dir(old))
  expect_equal(fpc_dir(), normalizePath(d))
  expect_equal(nrow(fpc_fields(geometry = FALSE)), 9)
})
