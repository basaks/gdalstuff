"""
This script takes a classification/cluster output (raster), and also the
features of the cluster in raster form to produce cluster interpretation plots.
"""

import click
from pathlib import Path
import pandas as pd
import rasterio as rio
import matplotlib.pylab as plt
import seaborn as sns


def __check_raster(tifs):
    for s in tifs:
        with rio.open(s) as f:
            if len(f.nodatavals) > 1:
                raise AttributeError('file {s} has more than one band. We '
                                     'currently support only single banded '
                                     'rasters.'.format(s=s))


total_length = None


def _read_file(s, skip_multiband):
    global total_length
    print('Reading file {}'.format(s))
    f = rio.open(s)
    if total_length is None:
        total_length = f.height * f.width
        print('File {} with size {}'.format(s, total_length))
    else:
        print('File {} with size {}'.format(s, f.height*f.width))
        if not skip_multiband:
            if total_length != f.height * f.width:
                raise AttributeError("file {} is not equal to the others".format(s))
        else:
            print("Warning: Skipped multiband raster {} as skip "
                  "opted".format(s))

    return rio.open(s).read(masked=True).flatten()


@click.command()
@click.option('-r', '--raster', required=True, help='Input raster')
@click.option('-f', '--features_dir', required=True,
              help='Dir with features that contributed to this '
                   'classification/clustering output')
@click.option('-s', '--skip_multiband', required=False, is_flag=True,
              help='Automatically skip multiband rasters')
def remove_outliers(raster, features_dir, skip_multiband):

    tifs = list(Path(features_dir).glob('*.tif'))

    p_data = [_read_file(s, skip_multiband) for s in tifs]

    data = {Path(s).stem: d for s, d in zip(tifs, p_data)}

    mask = pd.DataFrame.from_dict(data={k: v.mask for k, v in data.items()})
    df = pd.DataFrame.from_dict(data={k: v.data for k, v in data.items()})
    print('Original data with shape {}'.format(df.shape))
    df = df[~mask.any(axis=1)]

    print('After removing masked values: shape {}'.format(df.shape))

    classes = _read_file(raster, False)

    # sample now
    cols = df.columns
    df['class'] = classes
    dfs = df.sample(frac=0.1)

    for c in cols:
        plt.figure()
        sns.boxplot(x='class', y=c, data=dfs)
        plt.savefig(c + '.png')


if __name__ == '__main__':
    remove_outliers()
