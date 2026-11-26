# Small example of the Florida Pasture Cube shipped with the package

Nine fields (three of each tier) with their composites for 2021-2023,
optical and radar observations for 2022 and the labels of their
counties, in the layout of the release. Use it to try the functions
without downloading anything.

## Usage

``` r
fpc_example_dir()
```

## Value

Path to the example folder.

## Examples

``` r
fpc_fields(dir = fpc_example_dir(), geometry = FALSE)
#>    field_id   fid tier    county county_fips dor_use_code
#> 1 FPC059432 59432    B    Hardee       12049          066
#> 2 FPC060780 60780    A    Hardee       12049          061
#> 3 FPC061123 61123    A    Hardee       12049          063
#> 4 FPC061831 61831    B    Hardee       12049          099
#> 5 FPC062581 62581    B    Hardee       12049          073
#> 6 FPC062877 62877    A    Hardee       12049          061
#> 7 FPC094408 94408    C Highlands       12055          063
#> 8 FPC094588 94588    C    DeSoto       12027          063
#> 9 FPC095347 95347    C    DeSoto       12027          063
#>                ag_exempt area_ha perimeter_m compactness n_pixels
#> 1 Agricultural Exemption    8.28        1920  0.28225246       92
#> 2 Agricultural Exemption   16.65        4980  0.08436560      185
#> 3 Agricultural Exemption   10.53        4080  0.07949099      117
#> 4          Not Ag Exempt   34.83        5820  0.12921632      387
#> 5          Not Ag Exempt   20.97        3780  0.18442708      233
#> 6 Agricultural Exemption  115.74        9060  0.17718908     1286
#> 7 Agricultural Exemption   15.48        2160  0.41693977      172
#> 8 Agricultural Exemption   14.94        4620  0.08795824      166
#> 9 Agricultural Exemption   49.95        7320  0.11714485      555
#>   n_interior_pixels pasture_years_mean       lon      lat n_parts
#> 1                37           9.750000 -81.90513 27.61870       1
#> 2                38           8.540541 -81.96169 27.59301       1
#> 3                15           8.478632 -81.92275 27.57707       1
#> 4               211           9.720930 -81.92777 27.54859       1
#> 5               112           9.609442 -81.91245 27.52673       1
#> 6              1000           9.870140 -81.95217 27.50924       1
#> 7               106           5.052326 -81.01060 27.23417       1
#> 8                44           3.132530 -82.00472 27.32838       1
#> 9               326           1.209009 -81.73952 27.11312       1
#>   largest_part_frac flag_few_interior flag_landuse_change pasture_frac_2016
#> 1                 1             FALSE               FALSE        0.98913043
#> 2                 1             FALSE               FALSE        0.75675676
#> 3                 1             FALSE               FALSE        0.81196581
#> 4                 1             FALSE               FALSE        0.97932817
#> 5                 1             FALSE               FALSE        1.00000000
#> 6                 1             FALSE               FALSE        1.00000000
#> 7                 1             FALSE               FALSE        0.00000000
#> 8                 1             FALSE               FALSE        0.00000000
#> 9                 1             FALSE               FALSE        0.03243243
#>   pasture_frac_2017 pasture_frac_2018 pasture_frac_2019 pasture_frac_2020
#> 1        0.94565217        0.93478261        0.97826087        0.97826087
#> 2        0.28648649        0.87567568        0.94594595        0.92972973
#> 3        0.96581197        0.83760684        0.80341880        0.96581197
#> 4        0.99483204        0.95865633        0.95090439        0.95348837
#> 5        0.99141631        0.97424893        0.97424893        0.98283262
#> 6        0.97900467        0.99377916        0.98833593        0.98911353
#> 7        0.00000000        0.33720930        0.54651163        0.58139535
#> 8        0.00000000        0.00000000        0.06626506        0.04216867
#> 9        0.03243243        0.01441441        0.01981982        0.04864865
#>   pasture_frac_2021 pasture_frac_2022 pasture_frac_2023 pasture_frac_2024
#> 1        0.97826087         1.0000000         0.9782609         0.9673913
#> 2        0.95135135         0.9837838         0.9513514         0.8756757
#> 3        0.93162393         0.9401709         0.8803419         0.5641026
#> 4        0.98449612         0.9922481         0.9896641         0.9379845
#> 5        0.95708155         0.9699571         0.9613734         0.8540773
#> 6        0.99688958         0.9976672         0.9976672         0.9416796
#> 7        0.45348837         0.5755814         0.5813953         0.9825581
#> 8        0.52409639         0.4337349         0.4337349         0.8915663
#> 9        0.07747748         0.1027027         0.1531532         0.3333333
#>   pasture_frac_2025   mukey mukey_frac aws0_100_mm soc0_100_gm2
#> 1         1.0000000 1384380  0.8864734    81.24872     3793.629
#> 2         0.9837838 1384395  0.9093093    49.08997     9976.912
#> 3         0.7777778 1384389  0.8319088    98.25402    10604.547
#> 4         0.9793282 1384389  0.8231410   109.87343    14047.333
#> 5         0.9442060 1384389  0.6390081   101.15668    12323.459
#> 6         0.9860031 1384389  0.8104372    98.78473    11341.999
#> 7         0.9941860 1413510  0.5885013    84.37616    12405.389
#> 8         0.7409639 1386930  0.5401606    98.49447    11984.377
#> 9         0.3945946 1386914  0.3781782    87.92517     8797.442
#>            drainage_class flooding_frequency hydrologic_group
#> 1 Somewhat poorly drained               None                A
#> 2          Poorly drained               None              A/D
#> 3          Poorly drained               None              B/D
#> 4          Poorly drained               None              B/D
#> 5          Poorly drained               None              B/D
#> 6          Poorly drained               None              B/D
#> 7          Poorly drained               None              A/D
#> 8          Poorly drained               None              A/D
#> 9          Poorly drained               None              B/D
#>   water_table_min_cm musym                                      muname
#> 1                 76     1 Adamsville fine sand, 0 to 2 percent slopes
#> 2                 31    17          Smyrna sand, 0 to 2 percent slopes
#> 3                 30    10     Pomona fine sand, 0 to 2 percent slopes
#> 4                 30    10     Pomona fine sand, 0 to 2 percent slopes
#> 5                 30    10     Pomona fine sand, 0 to 2 percent slopes
#> 6                 30    10     Pomona fine sand, 0 to 2 percent slopes
#> 7                 31    10     Myakka fine sand, 0 to 2 percent slopes
#> 8                 31    36     Smyrna fine sand, 0 to 2 percent slopes
#> 9                 31    20  Immokalee fine sand, 0 to 2 percent slopes
#>   drainage_code flooding_code elev_mean_m elev_min_m elev_max_m slope_mean_deg
#> 1             5             0   32.561255  31.684290  34.033043    0.357055176
#> 2             6             0   35.927510  34.720406  37.911572    0.387302296
#> 3             6             0   30.218901  27.949900  31.317070    1.309822321
#> 4             6             0   32.021863  30.330250  34.650505    0.333766731
#> 5             6             0   31.319281  30.472370  31.671747    0.242054077
#> 6             6             0   27.700911  26.184513  28.516953    0.160286988
#> 7             6             0    8.740878   8.740001   8.770724    0.002796588
#> 8             6             0   22.216885  21.728712  22.925043    0.179206729
#> 9             6             0   16.930090  16.368925  17.340025    0.099960631
#>   hand_mean_m  twi_mean hand_min_m wetland_frac wetland_frac_500m ccap_year
#> 1   8.0297442 10.201372 3.48403358 2.470518e-07        0.29961236      2016
#> 2   0.9626154  9.955003 0.00000000 1.081093e-02        0.10137434      2016
#> 3   0.6225764  8.179420 0.00003000 1.709544e-02        0.41727205      2016
#> 4   1.1661365 10.011442 0.00007000 4.651235e-02        0.45389100      2016
#> 5   0.8724991 10.301663 0.23665376 4.721118e-02        0.22998029      2016
#> 6   1.7260204 10.482968 0.00000000 5.444106e-03        0.40822181      2016
#> 7   0.5854164 11.597189 0.00012000 1.453483e-01        0.15386015      2016
#> 8   1.2259987 10.591613 0.73746572 3.734931e-01        0.09164173      2016
#> 9   1.0317036 10.616532 0.08910324 9.675675e-01        0.72426756      2016
#>   n_optical_periods n_radar_periods flag_no_optical flag_no_observations
#> 1               353             271           FALSE                FALSE
#> 2               354             547           FALSE                FALSE
#> 3               376             547           FALSE                FALSE
#> 4               359             547           FALSE                FALSE
#> 5               367             547           FALSE                FALSE
#> 6               355             547           FALSE                FALSE
#> 7               477             273           FALSE                FALSE
#> 8               351             547           FALSE                FALSE
#> 9               359             271           FALSE                FALSE
#>   __index_level_0__
#> 1             35036
#> 2             35960
#> 3             36171
#> 4             36551
#> 5             37028
#> 6             37273
#> 7             60594
#> 8             60774
#> 9             61533
```
