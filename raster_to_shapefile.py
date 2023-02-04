import geopandas as gpd
import numpy as np
import pandas as pd
import rasterio as rio

shapefile = gpd.read_file("/home/sudipta/Documents/nci/ceno/Ceno_range.shp")

with rio.Env():
    with rio.open('/home/sudipta/Documents/nci/ceno/Ceno_Range.tif') as src:
        crs = src.crs

        # create 1D coordinate arrays (coordinates of the pixel center)
        xmin, ymax = np.around(src.xy(0.00, 0.00), 9)  # src.xy(0, 0)
        xmax, ymin = np.around(src.xy(src.height-1, src.width-1), 9)  # src.xy(src.width-1, src.height-1)
        x = np.linspace(xmin, xmax, src.width)
        y = np.linspace(ymax, ymin, src.height)  # max -> min so coords are top -> bottom



        # create 2D arrays
        xs, ys = np.meshgrid(x, y)
        zs = src.read(1)

        # Apply NoData mask
        mask = src.read_masks(1) > 0
        xs, ys, zs = xs[mask], ys[mask], zs[mask]

data = {"X": pd.Series(xs.ravel()),
        "Y": pd.Series(ys.ravel()),
        "Z": pd.Series(zs.ravel())}

df = pd.DataFrame(data=data)
geometry = gpd.points_from_xy(df.X, df.Y)
gdf = gpd.GeoDataFrame(df, crs=crs, geometry=geometry)
import IPython; IPython.embed(); import sys; sys.exit()
print(gdf.head())
