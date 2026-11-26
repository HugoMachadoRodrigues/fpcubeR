# Read the per-acquisition observation tables

One row per field and acquisition: for optical data, every HLS granule
with the clear-pixel count, field-mean reflectance and indices, the
geometric shift and the quality flags; for radar, every Sentinel-1
acquisition with linear and dB backscatter, platform and relative orbit.

## Usage

``` r
fpc_observations(
  type = c("optical", "radar"),
  fields = NULL,
  years = NULL,
  from = NULL,
  to = NULL,
  usable_only = TRUE,
  dir = NULL
)
```

## Arguments

- type:

  `"optical"` or `"radar"`.

- fields:

  Field identifiers (`"FPC000123"`), or a data frame from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).
  `NULL` reads all fields (large: about 4.6 million rows per year).

- years:

  Years to read. `NULL` reads every year that is in the data folder.

- from, to:

  First and last date (`Date` or `"YYYY-MM-DD"`) of the periods to keep.

- usable_only:

  For optical data, keep only the records that enter the composites
  (`qa_use`: clear, geometric shift of at most one pixel, reflectance in
  range, no haze).

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame. `fid` links to
[`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md);
`field_id` is added.

## Examples

``` r
d <- fpc_example_dir()
o <- fpc_observations("optical", years = 2022, dir = d)
head(o[, c("field_id", "date", "sensor", "ndvi", "n_clear_px")])
#>    field_id                date sensor      ndvi n_clear_px
#> 1 FPC059432 2022-01-03 16:15:45    S30 0.5895447         62
#> 2 FPC059432 2022-01-07 15:56:04    L30 0.5713150         62
#> 3 FPC059432 2022-01-08 16:15:39    S30 0.5633226         62
#> 4 FPC059432 2022-01-15 15:56:02    L30 0.5702903         62
#> 5 FPC059432 2022-01-18 16:15:38    S30 0.5806054         62
#> 6 FPC059432 2022-01-31 15:55:57    L30 0.3914838         62
```
