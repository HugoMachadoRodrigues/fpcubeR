# Summarise field-periods over fields

Median (or another statistic) of a variable over the fields for each
date, with the number of fields that have a value. Useful for regional
or statewide curves.

## Usage

``` r
fpc_summarise(x, var, by = NULL, fun = stats::median)
```

## Arguments

- x:

  A data frame from
  [`fpc_composites()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_composites.md)
  or
  [`fpc_anomaly()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_climatology.md).

- var:

  Variable to summarise.

- by:

  Optional grouping column of `x` besides `date` (e.g. `"tier"` after a
  merge with
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md)).

- fun:

  Summary function, applied to the non-missing values.

## Value

A data frame with `date`, the grouping column, `value` and `n_fields`.

## Examples

``` r
d <- fpc_example_dir()
x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
head(fpc_summarise(x, "ndvi"))
#>         date     value n_fields
#> 1 2022-01-04 0.5778719        9
#> 2 2022-01-09 0.5635146        6
#> 3 2022-01-14 0.5827419        9
#> 4 2022-01-24 0.5318807        1
#> 5 2022-01-29 0.4648982        9
#> 6 2022-02-03 0.4274276        8
```
