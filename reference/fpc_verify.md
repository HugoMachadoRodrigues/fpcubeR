# Check the downloaded files against the release checksums

Compares the SHA-256 checksum of every file of the data folder that is
listed in `SHA256SUMS` (download it with `fpc_download("docs")`). Needs
the `digest` package.

## Usage

``` r
fpc_verify(dir = NULL)
```

## Arguments

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame with the file, whether it is present and whether its
checksum matches.

## Examples

``` r
if (FALSE) { # \dontrun{
fpc_download(c("docs", "fields", "composites"))
v <- fpc_verify()
v[v$present & !v$ok, ]   # files whose checksum does not match
} # }
```
