# Changelog

## fpcubeR (development version)

- New readers for the remaining parts of the release:
  - [`fpc_lineage()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_lineage.md):
    field identifiers across versions, with the version 1.0 parent and
    the status of every field.
  - [`fpc_validation()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_validation.md):
    the tables behind the validation of the paper, including the
    official land use and the ESA WorldCover cover of every field.
  - [`fpc_benchmark()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_benchmark.md):
    samples, results, predictions and run information of the three
    benchmark tasks; the task 1 samples get field identifiers and dates.
- The example data now include these tables for the nine example fields.

## fpcubeR 1.3.0

- First release, for version 1.3 of the Florida Pasture Cube.
- Download from Zenodo with checksum verification:
  [`fpc_download()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_download.md),
  [`fpc_files()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_files.md),
  [`fpc_verify()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_verify.md).
- Readers:
  [`fpc_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_fields.md),
  [`fpc_composites()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_composites.md)
  (observed values only by default),
  [`fpc_variables()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_variables.md),
  [`fpc_observations()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_observations.md),
  [`fpc_labels()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_labels.md).
- Analysis helpers:
  [`fpc_add_drought()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_add_drought.md),
  [`fpc_climatology()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_climatology.md),
  [`fpc_anomaly()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_climatology.md),
  [`fpc_summarise()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_summarise.md).
- Plots:
  [`fpc_plot_field()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_plot_field.md),
  [`fpc_map_fields()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_map_fields.md).
- A real nine-field example shipped with the package:
  [`fpc_example_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_example_dir.md).
