# Field identifiers across versions

Reads `lineage.parquet`, which links every field of this version to the
field of version 1.0 it comes from. Fields were split into connected
parts in version 1.1 and tier C was added in version 1.3, so an
identifier of version 1.0 may now be the same field, a reshaped one, one
of several parts, or no longer used.

## Usage

``` r
fpc_lineage(fields = NULL, parents = NULL, status = NULL, dir = NULL)
```

## Arguments

- fields:

  Field identifiers of this version (`"FPC000123"`), or a data frame
  from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).
  `NULL` keeps all.

- parents:

  Field identifiers of version 1.0: keeps the rows that come from them,
  including `removed` ones. `NULL` keeps all.

- status:

  Statuses to keep (see the table). `NULL` keeps all.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame, one row per identifier: `field_id` (`NA` for removed
identifiers), `fid`, `status`, `parent_field_id` and `parent_fid` (the
version 1.0 field; `NA` for fields without one), `n_pixels` (30 m pixels
in this version) and `obs_version` (the version whose observations the
field's series use).

## Details

|  |  |
|----|----|
| `status` | meaning |
| `"unchanged"` | same pixels and same identifier as in version 1.0 |
| `"reshaped"` | the largest part of a version 1.0 field, which keeps its identifier |
| `"new"` | a further part of a version 1.0 field, or a tier C field (no parent); identifier above the version 1.0 maximum |
| `"removed"` | an identifier of version 1.0 that is no longer used |

## Examples

``` r
d <- fpc_example_dir()
fpc_lineage(dir = d)
#>     field_id   fid    status parent_field_id parent_fid n_pixels obs_version
#> 1       <NA>     3   removed       FPC000003          3        0        <NA>
#> 2  FPC057124 57124  reshaped       FPC057124      57124      395        v1.1
#> 3  FPC059432 59432 unchanged       FPC059432      59432       92        v1.0
#> 4  FPC060780 60780  reshaped       FPC060780      60780      185        v1.1
#> 5  FPC061123 61123 unchanged       FPC061123      61123      117        v1.0
#> 6  FPC061831 61831 unchanged       FPC061831      61831      387        v1.0
#> 7  FPC062581 62581  reshaped       FPC062581      62581      233        v1.1
#> 8  FPC062877 62877  reshaped       FPC062877      62877     1286        v1.1
#> 9  FPC083554 83554       new       FPC057124      57124      223        v1.1
#> 10 FPC094408 94408       new            <NA>         NA      172        v1.3
#> 11 FPC094588 94588       new            <NA>         NA      166        v1.3
#> 12 FPC095347 95347       new            <NA>         NA      555        v1.3
# a version 1.0 field split in two in version 1.1
fpc_lineage(parents = "FPC057124", dir = d)
#>    field_id   fid   status parent_field_id parent_fid n_pixels obs_version
#> 1 FPC057124 57124 reshaped       FPC057124      57124      395        v1.1
#> 2 FPC083554 83554      new       FPC057124      57124      223        v1.1
```
