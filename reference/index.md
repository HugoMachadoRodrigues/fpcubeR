# Package index

## Get the data

Download the data set from Zenodo, set the data folder and check the
files.

- [`fpc_download()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_download.md)
  : Download the Florida Pasture Cube
- [`fpc_files()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_files.md)
  : List the files of the Florida Pasture Cube on Zenodo
- [`fpc_record`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_record.md)
  : Zenodo record of the Florida Pasture Cube data
- [`fpc_verify()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_verify.md)
  : Check the downloaded files against the release checksums
- [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md)
  [`fpc_set_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md)
  : Folder of the Florida Pasture Cube data
- [`fpc_example_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_example_dir.md)
  : Small example of the Florida Pasture Cube shipped with the package

## Read

Fields, 5-day composites, per-acquisition observations, labels and field
identifiers across versions.

- [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md)
  : Read the pasture fields
- [`fpc_composites()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_composites.md)
  : Read the 5-day composites
- [`fpc_variables()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_variables.md)
  : Variables of the 5-day composites
- [`fpc_observations()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_observations.md)
  : Read the per-acquisition observation tables
- [`fpc_labels()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_labels.md)
  : Read the labels
- [`fpc_lineage()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_lineage.md)
  : Field identifiers across versions

## Validation and benchmark

The tables behind the validation and the benchmark of the paper.

- [`fpc_validation()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_validation.md)
  : Read the validation tables
- [`fpc_benchmark()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_benchmark.md)
  : Read the benchmark samples and results

## Analyse

County drought class, field climatology and anomalies, summaries.

- [`fpc_add_drought()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_add_drought.md)
  : Add the county drought class to field-periods
- [`fpc_climatology()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_climatology.md)
  [`fpc_anomaly()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_climatology.md)
  : Climatology and anomaly of a variable for each field
- [`fpc_summarise()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_summarise.md)
  : Summarise field-periods over fields

## Plot

- [`fpc_plot_field()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_plot_field.md)
  : Plot the time series of a field
- [`fpc_map_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_map_fields.md)
  : Map fields
