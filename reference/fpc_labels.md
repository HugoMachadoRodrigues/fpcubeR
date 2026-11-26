# Read the labels

|  |  |
|----|----|
| `which` | content |
| `"usdm"` | US Drought Monitor, county-week: percent of the county area in each category (cumulative D0-D4), dominant class and DSCI |
| `"nass"` | NASS pasture condition for Florida, state-week: percent very poor to excellent and condition index |
| `"tracks"` | hurricane tracks (HURDAT2 and NHC working best tracks) of storms within 3 degrees of Florida |
| `"landfalls"` | Florida landfalls; those of storms not yet in HURDAT2 are derived from the track |

## Usage

``` r
fpc_labels(which = c("usdm", "nass", "tracks", "landfalls"), dir = NULL)
```

## Arguments

- which:

  Label table to read.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame.

## Examples

``` r
head(fpc_labels("nass", dir = fpc_example_dir()))
#>   week_ending very_poor poor fair good excellent condition_index
#> 1  2016-01-03         2   11   35   46         6            3.43
#> 2  2016-01-10         2   14   34   45         5            3.37
#> 3  2016-01-17         2   16   34   43         5            3.33
#> 4  2016-01-24         3   16   35   42         4            3.28
#> 5  2016-01-31         4   18   38   36         4            3.18
#> 6  2016-02-07         3   20   41   32         4            3.14
```
