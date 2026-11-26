# Folder of the Florida Pasture Cube data

The functions of this package read the data from one folder that has the
layout of the release: `fields.parquet`,
`composites/composites_YYYY.parquet`, `labels/`,
`optical_observations/`, `radar_observations/` and so on.
[`fpc_download()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_download.md)
fills it.

## Usage

``` r
fpc_dir()

fpc_set_dir(path)
```

## Arguments

- path:

  Folder to use.

## Value

`fpc_dir()` returns the folder path; `fpc_set_dir()` returns the
previous one, invisibly.

## Details

The folder is, in this order, the one set with `fpc_set_dir()` in this
session, the environment variable `FPCUBE_DIR`, or a folder in the
user's data directory (`tools::R_user_dir("fpcubeR", "data")`).

## Examples

``` r
old <- fpc_set_dir(fpc_example_dir())
fpc_dir()
#> [1] "/home/runner/work/_temp/Library/fpcubeR/extdata/fpcube_example"
fpc_set_dir(old)
```
