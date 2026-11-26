# Climatology and anomaly of a variable for each field

`fpc_climatology()` computes, for each field and each 5-day period of
the year, the mean of the observed values in the reference years.
`fpc_anomaly()` subtracts it from the values. Only observed values enter
the climatology: read the composites with `observed_only = TRUE`.

## Usage

``` r
fpc_climatology(x, var, ref_years = NULL, min_years = 2)

fpc_anomaly(x, var, ref_years = NULL, min_years = 2)
```

## Arguments

- x:

  A data frame from
  [`fpc_composites()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_composites.md)
  (wide format).

- var:

  Variable name.

- ref_years:

  Years that define the climatology. `NULL` uses every year in `x`.

- min_years:

  Minimum number of observed years for a period's climatology; fewer
  gives `NA`.

## Value

`fpc_climatology()`: a data frame with `field_id`, `period` (1-73),
`clim` and `n_years`. `fpc_anomaly()`: `x` with the columns `period`,
`clim` and `anomaly`.

## Details

Periods are numbered from 1 to 73 within each year (the 5-day calendar
is anchored on 1 January 2016 and runs continuously, so a period's
position in the year shifts by one day in leap years; period 74, when
present, is merged into 73).

## Examples

``` r
d <- fpc_example_dir()
x <- fpc_composites(vars = "ndvi", dir = d)
a <- fpc_anomaly(x, "ndvi", ref_years = 2021:2022)
summary(a$anomaly[format(a$date, "%Y") == "2023"])
#>      Min.   1st Qu.    Median      Mean   3rd Qu.      Max.       NAs 
#> -0.169143 -0.052251 -0.008422 -0.007676  0.030984  0.198953       568 
```
