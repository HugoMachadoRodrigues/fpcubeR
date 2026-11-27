# Download the Florida Pasture Cube

Downloads the chosen parts of the data set from Zenodo into the data
folder, checks the MD5 checksum of every file, and unpacks the zipped
folders so that the folder has the layout of the release. Files that are
already there with the right checksum are not downloaded again.

## Usage

``` r
fpc_download(
  what = c("fields", "composites", "labels"),
  years = NULL,
  dir = NULL,
  record = fpc_record,
  overwrite = FALSE,
  quiet = FALSE
)
```

## Arguments

- what:

  Parts to download (see the table). Defaults to the fields, the
  composites and the labels.

- years:

  Years of the composites to download (2016 to 2026). `NULL` downloads
  all.

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

- record:

  Zenodo record identifier. Defaults to
  [fpc_record](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_record.md).

- overwrite:

  Download again even if the file is present with the right checksum.

- quiet:

  Suppress progress messages.

## Value

The data folder, invisibly.

## Details

|  |  |  |
|----|----|----|
| `what` | content | size |
| `"fields"` | `fields.parquet`: one row per field, geometry and static attributes | 27 MB |
| `"composites"` | `composites/composites_YYYY.parquet`: 5-day composites, one file per year | about 200 MB per year |
| `"labels"` | `labels/`: US Drought Monitor, NASS pasture condition, hurricane tracks and landfalls | \< 1 MB |
| `"lineage"` | `lineage.parquet`: field identifiers across versions | 1 MB |
| `"optical"` | `optical_observations/`: one row per field and HLS granule | 4 GB |
| `"radar"` | `radar_observations/`: one row per field and Sentinel-1 acquisition | 1 GB |
| `"validation"` | `validation/`: the tables behind the validation of the paper (see [`fpc_validation()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_validation.md)) | 8 MB |
| `"benchmark"` | `benchmark/`: samples, results and predictions of the benchmark (see [`fpc_benchmark()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_benchmark.md)) | 27 MB |
| `"stac"` | `stac/`: SpatioTemporal Asset Catalog of the release | \< 1 MB |
| `"cube"` | `cube.zarr.zip`: the same composites as a Zarr store (for Python) | 2.5 GB |
| `"docs"` | `DATASHEET.md` and checksums | small |

## Examples

``` r
if (FALSE) { # \dontrun{
fpc_download()                                     # fields, all composites, labels
fpc_download(c("fields", "composites"), years = 2022:2023)
} # }
```
