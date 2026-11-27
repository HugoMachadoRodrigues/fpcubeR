"""Builds inst/extdata/fpcube_example from a local copy of the Florida Pasture Cube v1.3 release.

Nine fields (three per tier, in Hardee, DeSoto and Highlands counties), their composites for 2021-2023, optical
and radar observations for 2022, the labels of their counties, and their rows of the lineage, validation and
benchmark tables. The lineage also keeps one Hardee field split off a version 1.0 field, that parent, and one
removed identifier, so that every status appears; the summary tables of validation and benchmark are copied whole.
  python data-raw/make_example.py /path/to/release/v1.3
"""
import os
import shutil
import sys

import geopandas as gpd
import pandas as pd
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

# lineage: the nine fields, a Hardee field split off a version 1.0 field with its parent, and a removed identifier
lin = pq.read_table(f"{R}/lineage.parquet").to_pandas()
hardee = set(f.fid[f.county == "Hardee"])
split = lin[(lin.status == "new") & (lin.parent_fid > 0) & lin.fid.isin(hardee)].sort_values("fid").iloc[[0]]
removed = lin[lin.status == "removed"].sort_values("fid").iloc[[0]]
keep = set(sel.fid) | set(split.fid) | set(split.parent_fid) | set(removed.fid)
pq.write_table(pa.Table.from_pandas(lin[lin.fid.isin(keep)].sort_values("fid"), preserve_index=False),
               f"{E}/lineage.parquet", compression="zstd")

# validation: per-field tables for the nine fields, the others whole
os.makedirs(f"{E}/validation", exist_ok=True)
for n in ("fluccs_by_field", "worldcover_by_field"):
    v = pd.read_csv(f"{R}/validation/{n}.csv")
    v[v.fid.isin(sel.fid)].to_csv(f"{E}/validation/{n}.csv", index=False)
for n in ("coverage_by_year.csv", "quality_by_stratum.csv", "delineation_accounting.csv", "summary.json"):
    shutil.copy(f"{R}/validation/{n}", f"{E}/validation/{n}")

# benchmark: task 1 samples of the nine fields (f re-indexed to the rows of the example fields.parquet), task 3
# samples and predictions of their counties, the other files whole
os.makedirs(f"{E}/benchmark", exist_ok=True)
full = pq.read_table(f"{R}/fields.parquet", columns=["field_id"]).to_pandas()
pos = {int(i): k for k, i in enumerate(full.index[full.field_id.isin(sel.field_id)])}
assert list(full.field_id[list(pos)]) == list(sel.field_id)
t1 = pq.read_table(f"{R}/benchmark/task1_samples.parquet").to_pandas()
t1 = t1[t1.f.isin(pos)].assign(f=lambda x: x.f.map(pos)).reset_index(drop=True)
pq.write_table(pa.Table.from_pandas(t1, preserve_index=False), f"{E}/benchmark/task1_samples.parquet",
               compression="zstd")
for n in ("task3_samples", "task3_predictions"):
    t = pq.read_table(f"{R}/benchmark/{n}.parquet").to_pandas()
    t = t[t.county_fips.isin(set(sel.county_fips))]
    pq.write_table(pa.Table.from_pandas(t, preserve_index=False), f"{E}/benchmark/{n}.parquet", compression="zstd")
for p in sorted(os.listdir(f"{R}/benchmark")):
    if p.endswith((".csv", ".json")):
        shutil.copy(f"{R}/benchmark/{p}", f"{E}/benchmark/{p}")
