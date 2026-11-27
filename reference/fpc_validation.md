# Read the validation tables

Reads the tables behind the validation of the data set (Sect. 5 of the
paper). With `table = NULL`, lists them.

## Usage

``` r
fpc_validation(table = NULL, fields = NULL, dir = NULL)
```

## Arguments

- table:

  Table to read (see the table above). `NULL` lists the tables.

- fields:

  For the per-field tables, field identifiers or a data frame from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).
  `NULL` keeps all.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame (a list for `"summary"`). With `table = NULL`, a data frame
with the name, file and description of every table.

## Details

|  |  |
|----|----|
| `table` | content |
| `"fluccs_by_field"` | 30 m pixels of each field in each land-use group of the official FLUCCS maps of the five water management districts (2020-2023), pixels with no reference map, and the district |
| `"worldcover_by_field"` | share of each field in each ESA WorldCover 2021 class |
| `"coverage_by_year"` | median over fields of the days with a usable optical observation and of the days with a radar acquisition, by year |
| `"quality_by_stratum"` | by tier and field size: share of field-periods observed (dry season October-May, wet season June-September), interpolated and empty, median usable optical days per year, and fields with no optical observation |
| `"delineation_accounting"` | area (and number of units) at each step of the field delineation |
| `"summary"` | every number of the validation section, as a list |

The per-field tables get `field_id` as their first column. In
`coverage_by_year` the year column is named `year` (`day` in the file),
and the size classes of `quality_by_stratum` are written as plain text
(`"2-5 ha"`, `">=100 ha"`).

## Examples

``` r
d <- fpc_example_dir()
fpc_validation(dir = d)
#>                    table                       file
#> 1        fluccs_by_field        fluccs_by_field.csv
#> 2    worldcover_by_field    worldcover_by_field.csv
#> 3       coverage_by_year       coverage_by_year.csv
#> 4     quality_by_stratum     quality_by_stratum.csv
#> 5 delineation_accounting delineation_accounting.csv
#> 6                summary               summary.json
#>                                                                                  description
#> 1 30 m pixels of each field in each FLUCCS land-use group, and the water management district
#> 2                                      share of each field in each ESA WorldCover 2021 class
#> 3                  median over fields of the usable optical days and the radar days, by year
#> 4             observed, interpolated and empty shares and usable days by tier and field size
#> 5                                                 area at each step of the field delineation
#> 6                                            every number of the validation section (a list)
fpc_validation("worldcover_by_field", dir = d)
#>    field_id   fid bare       built   cropland grassland herbaceous_wetland
#> 1 FPC059432 59432    0 0.000000000 0.00000000 0.8293371        0.000000000
#> 2 FPC060780 60780    0 0.001878182 0.09590668 0.8273428        0.000000000
#> 3 FPC061123 61123    0 0.000000000 0.00000000 0.7844978        0.000000000
#> 4 FPC061831 61831    0 0.000000000 0.00000000 0.8237267        0.000000000
#> 5 FPC062581 62581    0 0.000695978 0.00000000 0.7203107        0.000000000
#> 6 FPC062877 62877    0 0.000000000 0.00000000 0.9260253        0.002825567
#> 7 FPC094408 94408    0 0.002653818 0.04903650 0.9471616        0.000000000
#> 8 FPC094588 94588    0 0.000000000 0.00000000 0.9887424        0.000000000
#> 9 FPC095347 95347    0 0.000000000 0.00000000 0.9971499        0.000000000
#>   mangrove shrub        tree water
#> 1        0     0 0.170662938     0
#> 2        0     0 0.074872327     0
#> 3        0     0 0.215502236     0
#> 4        0     0 0.176273288     0
#> 5        0     0 0.278993340     0
#> 6        0     0 0.071149163     0
#> 7        0     0 0.001148086     0
#> 8        0     0 0.011257614     0
#> 9        0     0 0.002850092     0
fpc_validation("quality_by_stratum", dir = d)
#>    tier      size n_fields observed_dry observed_wet interpolated      empty
#> 1     A    2-5 ha    18379    0.4992486    0.3403320    0.4246098 0.12978342
#> 2     A   5-20 ha    15853    0.5056958    0.3568979    0.4266429 0.11788761
#> 3     A 20-100 ha     6228    0.5090655    0.3810783    0.4263779 0.10775832
#> 4     A  >=100 ha     1516    0.5111382    0.4116836    0.4235679 0.09886453
#> 5     B    2-5 ha     5512    0.5229406    0.3474557    0.4210260 0.11526787
#> 6     B   5-20 ha     3283    0.5275726    0.3638480    0.4208494 0.10684278
#> 7     B 20-100 ha     1068    0.5250218    0.3838566    0.4208346 0.10179359
#> 8     B  >=100 ha      210    0.5361051    0.4214910    0.4112335 0.09134911
#> 9     C    2-5 ha     6427    0.4862175    0.3445757    0.4257987 0.13579465
#> 10    C   5-20 ha     3350    0.4919232    0.3555783    0.4291771 0.12492254
#> 11    C 20-100 ha      943    0.4943214    0.3668426    0.4278287 0.12088005
#> 12    C  >=100 ha       78    0.4819681    0.3709306    0.4333204 0.12219197
#>    usable_days_per_year_median no_optical_fields
#> 1                        35.90                47
#> 2                        36.40                 0
#> 3                        36.70                 0
#> 4                        36.80                 0
#> 5                        42.90                 6
#> 6                        43.00                 0
#> 7                        39.70                 0
#> 8                        43.80                 0
#> 9                        35.00                34
#> 10                       35.30                 0
#> 11                       35.50                 0
#> 12                       34.65                 0
```
