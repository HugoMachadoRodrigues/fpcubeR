# Read the pasture fields

Reads `fields.parquet`: one row per field with its geometry (EPSG:5070,
CONUS Albers), tier, county, area, CDL pasture fraction per year,
quality flags and soil, terrain and wetland attributes. See
`DATASHEET.md` for every column.

## Usage

``` r
fpc_fields(
  tier = NULL,
  county = NULL,
  fields = NULL,
  columns = NULL,
  geometry = TRUE,
  dir = NULL
)
```

## Arguments

- tier:

  Tiers to keep (`"A"`, `"B"`, `"C"`). `NULL` keeps all.

- county:

  County names to keep, e.g. `"Hardee"` (case-insensitive, with or
  without "County"). `NULL` keeps all.

- fields:

  Field identifiers to keep (`"FPC000123"`). `NULL` keeps all.

- columns:

  Columns to read besides `field_id`, `fid`, `tier` and `county`. `NULL`
  reads all.

- geometry:

  Return an `sf` object with the field polygons (`TRUE`) or a plain data
  frame.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

An `sf` data frame (or a data frame), one row per field.

## Details

Tiers: A, fields on parcels coded as grazing land; B, fields on other
parcels that were mapped as pasture in nearly every year; C, open
pasture from the official land-use maps that the Cropland Data Layer
maps as woody or wetland. For a conservative set of grazing fields use
tier A.

## Examples

``` r
f <- fpc_fields(tier = "A", dir = fpc_example_dir())
f[, c("field_id", "tier", "county", "area_ha")]
#> Simple feature collection with 3 features and 4 fields
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 1386915 ymin: 595965 xmax: 1391565 ymax: 605895
#> Projected CRS: NAD83 / Conus Albers
#>    field_id tier county area_ha                       geometry
#> 1 FPC060780    A Hardee   16.65 POLYGON ((1387455 605895, 1...
#> 2 FPC061123    A Hardee   10.53 POLYGON ((1391325 604905, 1...
#> 3 FPC062877    A Hardee  115.74 POLYGON ((1390095 597435, 1...
```
