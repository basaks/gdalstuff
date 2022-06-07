import numpy as np
import rasterio

dem = rasterio.open("demh1sv1_0_30m_albers.tif")  # dem already in correct projection + res + nan nodataval

kwrds = dem.profile
kwrds['dtype'] = rasterio.uint8
kwrds['nodata'] = 0

with rasterio.open('mask_30m_albers.tif.tif', 'w', **kwrds) as mask:
    for ji, window in dem.block_windows(1):
        out = np.isfinite(dem.read(window=window))  # because the dem had nodata value of `nan`
        mask.write(out.astype(rasterio.uint8), window=window)
