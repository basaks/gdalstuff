# go inside the whitebox installation
from itertools import product
from pathlib import Path
from whitebox_tools import WhiteboxTools

wbt = WhiteboxTools()

wbt.set_whitebox_dir("/g/data/ge3/sudipta/whitebox-tools/target/release/")
working_dir = Path("/g/data/ge3/sudipta/jobs/brightness_greenness_wetness_percentiles_dea_data/")
wbt.set_working_dir(working_dir.as_posix())

types = ["pv", "npv", "bs"]
fractions = ["10", "50", "90"]

pattern = "_{t}_pc_{f}.tif"

for t in types:
    for f in fractions:
        print(t, f)
        tifs = [p.name for p in working_dir.glob('*' + pattern.format(t=t, f=f))]
        print(tifs)
        wbt.average_overlay(
            inputs=';'.join(tifs),
            output=working_dir.joinpath('average', '1987_2021_average' + pattern.format(t=t, f=f))
        )
