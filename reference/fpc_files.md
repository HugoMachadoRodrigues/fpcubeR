# List the files of the Florida Pasture Cube on Zenodo

List the files of the Florida Pasture Cube on Zenodo

## Usage

``` r
fpc_files(record = fpc_record)
```

## Arguments

- record:

  Zenodo record identifier. Defaults to
  [fpc_record](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_record.md).

## Value

A data frame with the file name, the group it belongs to (as used by
[`fpc_download()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_download.md)),
its size in MB, its MD5 checksum and its download URL.

## Examples

``` r
if (FALSE) { # \dontrun{
fpc_files()
} # }
```
