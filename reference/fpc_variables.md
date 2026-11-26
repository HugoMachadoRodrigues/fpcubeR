# Variables of the 5-day composites

Variables of the 5-day composites

## Usage

``` r
fpc_variables(dir = NULL)
```

## Arguments

- dir:

  Data folder. Defaults to
  [`fpc_dir()`](https://hugomachadorodrigues.github.io/fpcubeR/reference/fpc_dir.md).

## Value

A data frame with the name, group (optical, count, radar or weather),
units and description of every variable of the composites, read from the
metadata of the Parquet files.

## Examples

``` r
fpc_variables(dir = fpc_example_dir())
#>             name   group units
#> 1           blue optical     1
#> 2          green optical     1
#> 3            red optical     1
#> 4            nir optical     1
#> 5          swir1 optical     1
#> 6          swir2 optical     1
#> 7           ndvi optical     1
#> 8            evi optical     1
#> 9           ndmi optical     1
#> 10         mndwi optical     1
#> 11           nbr optical     1
#> 12       ndvi_sd optical     1
#> 13    water_frac optical     1
#> 14 n_optical_obs   count     1
#> 15    gap_filled   count      
#> 16   n_radar_obs   count     1
#> 17         vv_db   radar    dB
#> 18         vh_db   radar    dB
#> 19      vh_vv_db   radar    dB
#> 20       ppt_sum weather    mm
#> 21    tmean_mean weather  degC
#> 22     tmin_mean weather  degC
#> 23     tmax_mean weather  degC
#> 24   vpdmax_mean weather   hPa
#>                                                                                                             description
#> 1                        median over the period of the field-mean HLS v2.0 surface reflectance, blue (S30 B02, L30 B02)
#> 2                       median over the period of the field-mean HLS v2.0 surface reflectance, green (S30 B03, L30 B03)
#> 3                         median over the period of the field-mean HLS v2.0 surface reflectance, red (S30 B04, L30 B04)
#> 4               median over the period of the field-mean HLS v2.0 surface reflectance, near infrared (S30 B8A, L30 B05)
#> 5   median over the period of the field-mean HLS v2.0 surface reflectance, shortwave infrared 1.6 um (S30 B11, L30 B06)
#> 6   median over the period of the field-mean HLS v2.0 surface reflectance, shortwave infrared 2.2 um (S30 B12, L30 B07)
#> 7                                                            median over the period of the field-mean of per-pixel NDVI
#> 8                                         median over the period of the field-mean of per-pixel EVI, clipped to [-1, 1]
#> 9                              median over the period of the field-mean of per-pixel NDMI (nir - swir1) / (nir + swir1)
#> 10                        median over the period of the field-mean of per-pixel MNDWI (green - swir1) / (green + swir1)
#> 11                              median over the period of the field-mean of per-pixel NBR (nir - swir2) / (nir + swir2)
#> 12                                                median over the period of the within-field standard deviation of NDVI
#> 13                               median over the period of the fraction of clear field pixels flagged as water by Fmask
#> 14 number of HLS acquisition days in the period that passed the clear-sky, geometry, reflectance-range and haze screens
#> 15                  optical values linearly interpolated in time (no observation in the period, gap of at most 30 days)
#> 16                                                                      number of Sentinel-1 acquisitions in the period
#> 17                       Sentinel-1 RTC gamma0 VV, mean in linear power over the period's acquisitions, converted to dB
#> 18     Sentinel-1 RTC gamma0 VH, mean in linear power over the period's dual-polarisation acquisitions, converted to dB
#> 19                                                                                              VH minus VV backscatter
#> 20                                                                             PRISM precipitation, sum over the period
#> 21                                                                   PRISM mean daily temperature, mean over the period
#> 22                                                                PRISM minimum daily temperature, mean over the period
#> 23                                                                PRISM maximum daily temperature, mean over the period
#> 24                                                    PRISM maximum daily vapour pressure deficit, mean over the period
```
