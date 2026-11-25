test_that("files are grouped as fpc_download() expects", {
  g <- file_group(c("fields.parquet", "composites_2020.parquet", "labels.zip", "cube.zarr.zip", "x.bin",
                    "optical_observations.zip", "SHA256SUMS"))
  expect_equal(g, c("fields", "composites", "labels", "cube", "other", "optical", "docs"))
  expect_equal(target_path("/d", "composites_2020.parquet", "composites"), file.path("/d", "composites",
                                                                                      "composites_2020.parquet"))
})

test_that("unknown parts are refused before any network access", {
  expect_error(fpc_download("nope", dir = withr_tempdir()), "Unknown part")
})

test_that("the Zenodo record lists the release files", {
  skip_on_cran()
  skip_if_offline <- function() {
    ok <- tryCatch(curl::has_internet(), error = function(e) FALSE)
    if (!ok) skip("offline")
  }
  skip_if_offline()
  f <- tryCatch(fpc_files(), error = function(e) skip(conditionMessage(e)))
  expect_true(all(c("fields.parquet", "composites_2022.parquet", "labels.zip") %in% f$file))
  expect_true(all(nchar(f$md5) == 32))
})
