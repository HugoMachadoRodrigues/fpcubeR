# Map fields

Draws field polygons coloured by a column, for example the tier or a
summary of the composites joined to the fields. Needs the `ggplot2`
package.

## Usage

``` r
fpc_map_fields(fields, fill = "tier")
```

## Arguments

- fields:

  An `sf` data frame from
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md).

- fill:

  Column used for the colour.

## Value

A `ggplot` object.

## Examples

``` r
if (requireNamespace("ggplot2", quietly = TRUE)) {
  fpc_map_fields(fpc_fields(dir = fpc_example_dir()))
}
```
