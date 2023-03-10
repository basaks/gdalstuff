from pathlib import Path
from joblib import Parallel, delayed
from subprocess import run

# base_dir = "/g/data/ge3/sudipta/80m_albers/"
base_dir = "/home/sudipta/repos/uncover-ml/configs/data/"

out_base_dir = "/g/data/ge3/sudipta/80m_albers_test/"

covariate_file = "/some_covs.csv"

import csv
import glob
import shutil
mapping = {}


with open(covariate_file, 'r') as f:
    reader = csv.reader(f)
    tifs = list(reader)
    tifs = [f[0].strip() for f in tifs if (len(f) > 0 and f[0].strip() and f[0].strip()[0] != '#')]


with open('/home/sudipta/Downloads/cov_rename.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
    for row in spamreader:
        print(row[0], row[1])
        mapping[row[0]] = row[1]


paths = Path(base_dir).rglob('*.tif')


def pprocess(path):
    # print(path.name, path.parent)
    print(path.parent.as_posix())
    print(path.parent.as_posix().split(base_dir)[1])
    sub_dir = path.parent.as_posix().split(base_dir)[1]
    Path(out_base_dir).joinpath(sub_dir).mkdir(parents=True, exist_ok=True)
    try:
        out_file = Path(out_base_dir).joinpath(sub_dir, mapping[path.name])
        # run(f"gdalwarp -tr 800 800 {path.as_posix()} {out_file.as_posix()}", shell=True)
        # shutil.copy2(src=path.as_posix(), dst=out_file)
        print(f"copied {path} in {out_file}")
    except Exception as e:
        print(f"Problem: ========================>>> {e}")


def cov_file_covert():
    with open(f'converted_{Path(covariate_file).name}', 'w', newline='') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for t in tifs:
            try:
                path = Path(t)
                sub_dir = path.parent.as_posix().split(base_dir)[1]
                out_file = Path(out_base_dir).joinpath(sub_dir, mapping[path.name])
                print(f"will map {path.parent.as_posix()} into {out_file.as_posix()}")
                spamwriter.writerow([out_file.as_posix()])
            except Exception as e:
                print(f"Problem with {t}: {e}")

# Parallel(n_jobs=20)(delayed(pprocess)(path) for path in paths)
cov_file_covert()
