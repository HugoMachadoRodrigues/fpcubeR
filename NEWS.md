# fpcubeR (development version)

* New readers for the remaining parts of the release:
  * `fpc_lineage()`: field identifiers across versions, with the version 1.0 parent and the status of every
    field.
  * `fpc_validation()`: the tables behind the validation of the paper, including the official land use and
    the ESA WorldCover cover of every field.
  * `fpc_benchmark()`: samples, results, predictions and run information of the three benchmark tasks; the
    task 1 samples get field identifiers and dates.
* The example data now include these tables for the nine example fields.

# fpcubeR 1.3.0

* First release, for version 1.3 of the Florida Pasture Cube.
* Download from Zenodo with checksum verification: `fpc_download()`, `fpc_files()`, `fpc_verify()`.
* Readers: `fpc_fields()`, `fpc_composites()` (observed values only by default), `fpc_variables()`,
  `fpc_observations()`, `fpc_labels()`.
* Analysis helpers: `fpc_add_drought()`, `fpc_climatology()`, `fpc_anomaly()`, `fpc_summarise()`.
* Plots: `fpc_plot_field()`, `fpc_map_fields()`.
* A real nine-field example shipped with the package: `fpc_example_dir()`.
