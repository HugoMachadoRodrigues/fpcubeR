"""Builds inst/extdata/fpcube_example from a local copy of the Florida Pasture Cube v1.3 release.

Nine fields (three per tier, in Hardee, DeSoto and Highlands counties), their composites for 2021-2023, optical
and radar observations for 2022 and the labels of their counties.
  python data-raw/make_example.py /path/to/release/v1.3
"""
import os
import sys

import geopandas as gpd
import pyarrow as pa
import pyarrow.dataset as ds
import pyarrow.parquet as pq

R, E = sys.argv[1], os.path.join(os.path.dirname(__file__), "..", "inst", "extdata", "fpcube_example")
IDS = ["FPC059432", "FPC060780", "FPC061123", "FPC061831", "FPC062581", "FPC062877", "FPC094408", "FPC094588",
       "FPC095347"]
f = gpd.read_parquet(f"{R}/fields.parquet")
sel = f[f.field_id.isin(IDS)].sort_values("field_id")
os.makedirs(E, exist_ok=True)
sel.to_parquet(f"{E}/fields.parquet")
os.makedirs(f"{E}/composites", exist_ok=True)
for y in (2021, 2022, 2023):
    t = pq.read_table(f"{R}/composites/composites_{y}.parquet", filters=[("field_id", "in", IDS)])
    pq.write_table(t, f"{E}/composites/composites_{y}.parquet", compression="zstd")
for k in ("optical", "radar"):
    os.makedirs(f"{E}/{k}_observations", exist_ok=True)
    t = ds.dataset(f"{R}/{k}_observations/2022.parquet").to_table(filter=ds.field("fid").isin([int(x) for x in sel.fid]))
    pq.write_table(t, f"{E}/{k}_observations/2022.parquet", compression="zstd")
os.makedirs(f"{E}/labels", exist_ok=True)
u = pq.read_table(f"{R}/labels/usdm_county_weekly.parquet").to_pandas()
u = u[u.county_fips.isin(set(sel.county_fips))]
pq.write_table(pa.Table.from_pandas(u, preserve_index=False), f"{E}/labels/usdm_county_weekly.parquet",
               compression="zstd")
for n in ("nass_fl_pasture_condition_weekly", "hurricane_tracks_florida", "hurricane_landfalls"):
    pq.write_table(pq.read_table(f"{R}/labels/{n}.parquet"), f"{E}/labels/{n}.parquet", compression="zstd")
