gdal_translate -of GTiff -co "BLOCKXSIZE=128" -co "BLOCKYSIZE=128" -co "TILED=YES" -co compress=LZW dem_fill.tif dem_fill_tiled.tif
