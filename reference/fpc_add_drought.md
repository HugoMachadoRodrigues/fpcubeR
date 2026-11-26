# Add the county drought class to field-periods

Joins the US Drought Monitor map that was valid on each date (the map
whose week contains the first day of the 5-day period) of the field's
county.

## Usage

``` r
fpc_add_drought(x, dir = NULL)
```

## Arguments

- x:

  A data frame with `field_id` and `date`, such as the output of
  [`fpc_composites()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_composites.md).

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

`x` with the columns `usdm_class` (0 none, 1 D0, 2 D1, 3 D2, 4 D3, 5 D4:
the highest category that covers at least half of the county),
`usdm_d1_pct` (percent of the county in D1 or worse) and `dsci` (Drought
Severity and Coverage Index, 0-500).

## Examples

``` r
d <- fpc_example_dir()
x <- fpc_composites(vars = "ndvi", years = 2022, dir = d)
x <- fpc_add_drought(x, dir = d)
table(x$usdm_class)
#> 
#>   0   1   2 
#> 460  68 129 
```
