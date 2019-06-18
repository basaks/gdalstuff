from joblib import Parallel, delayed
import rasterio as rio
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.preprocessing import scale
import matplotlib.pylab as plt
import seaborn as sns


tifs = list(Path('/home/sudiptra/Documents/GA-cover2/').glob('*.tif'))

# select 10
selected = np.random.choice(tifs, 10)

for s in selected:
    with rio.open(s) as f:
        if len(f.nodatavals) > 1:
            raise AttributeError('file {s} has more than one band. We '
                                 'currently support only single banded '
                                 'rasters.'.format(s=s))


def _read_file(s):
    return rio.open(s).read(masked=True).flatten()


p_data = Parallel(n_jobs=-1)(delayed(_read_file)(s) for s in selected)
data = {Path(s).stem: d for s, d in zip(selected, p_data)}

mask = pd.DataFrame.from_dict(data={k: v.mask for k, v in data.items()})
df = pd.DataFrame.from_dict(data={k: v.data for k, v in data.items()})
print('Original data with shape {}'.format(df.shape))
df = df[~mask.any(axis=1)]

print('After removing masked values: shape {}'.format(df.shape))

# sample now
dfs = df.sample(frac=0.01)
cols = dfs.columns

# compute covariance matrix
df_data = scale(dfs)
cov_mat = np.cov(df_data, rowvar=False)

f, ax = plt.subplots(figsize =(9, 8))
corrmat = pd.DataFrame(df_data, columns=cols).corr()
sns.heatmap(corrmat, ax=ax, cmap="YlGnBu", linewidths=0.1)
plt.savefig('{}.png'.format('results/Correlation-Matrix'))

f, ax = plt.subplots(figsize=(9, 8))
sns.heatmap(cov_mat, ax=ax, cmap="YlGnBu", linewidths=0.1)
plt.savefig('{}.png'.format('results/Covariance-Matrix'))

f, ax = plt.subplots(figsize=(9, 8))
cg = sns.clustermap(corrmat, cmap="YlGnBu", linewidths=0.1)
plt.setp(cg.ax_heatmap.yaxis.get_majorticklabels(), rotation=0)
plt.savefig('{}.png'.format('results/Correlation-Clustermap'))
