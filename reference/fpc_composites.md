# Read the 5-day composites

Reads the field x 5-day composites of HLS reflectance and indices,
Sentinel-1 backscatter and PRISM weather. `date` is the first day of
each 5-day period.

## Usage

``` r
fpc_composites(
  fields = NULL,
  vars = NULL,
  years = NULL,
  from = NULL,
  to = NULL,
  observed_only = TRUE,
  long = FALSE,
  dir = NULL
)
```

## Arguments

- fields:

  Field identifiers (`"FPC000123"`), or a data frame from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).
  `NULL` reads all fields (large: about 4.6 million rows per year).

- vars:

  Variables to read (see
  [`fpc_variables()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_variables.md)).
  `NULL` reads all. `n_optical_obs`, `gap_filled` and `n_radar_obs` are
  always included.

- years:

  Years to read. `NULL` reads every year that is in the data folder.

- from, to:

  First and last date (`Date` or `"YYYY-MM-DD"`) of the periods to keep.

- observed_only:

  Set gap-filled optical values to `NA` (see Details).

- long:

  Return one row per field, date and variable (`variable`, `value`)
  instead of one column per variable.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame with `field_id`, `fid`, `date` and the variables.

## Details

Optical gaps of up to 30 days are filled in the release by linear
interpolation between the observations on either side
(`gap_filled = TRUE`, `n_optical_obs = 0`). Because an interpolated
value depends on the next observation, it must not be used as an input
of a forecast or any analysis that has to be causal. With
`observed_only = TRUE` (the default) these optical values are set to
`NA`; radar and weather values are kept.

## Examples

``` r
d <- fpc_example_dir()
f <- fpc_fields(tier = "A", dir = d, geometry = FALSE)
x <- fpc_composites(f, vars = c("ndvi", "vv_db", "ppt_sum"), years = 2022, dir = d)
head(x)
#>    field_id   fid       date      ndvi     vv_db   ppt_sum n_optical_obs
#> 1 FPC060780 60780 2022-01-04 0.6175229 -12.54846  0.000000             2
#> 2 FPC060780 60780 2022-01-09        NA -11.51988  0.000000             0
#> 3 FPC060780 60780 2022-01-14 0.5940678 -11.15577 13.588799             2
#> 4 FPC060780 60780 2022-01-19        NA -11.90813  0.678800             0
#> 5 FPC060780 60780 2022-01-24        NA -12.44414  9.876699             0
#> 6 FPC060780 60780 2022-01-29 0.4648982       NaN  0.000000             2
#>   gap_filled n_radar_obs
#> 1      FALSE           1
#> 2       TRUE           1
#> 3      FALSE           1
#> 4       TRUE           1
#> 5       TRUE           1
#> 6      FALSE           0
```
