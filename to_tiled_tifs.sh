gdal_translate -of GTiff -co "BLOCKXSIZE=128" -co "BLOCKYSIZE=128" -co "TILED=YES" -co compress=LZW dem_fill.tif dem_fill_tiled.tif

# sampling and compressing
gdalwarp -r near -tr 1000 1000 -co "BLOCKXSIZE=512" -co "BLOCKYSIZE=512" -co "TILED=YES" -wo NUM_THREADS=ALL_CPUS -wo SOURCE_EXTRA=1000 -co COMPRESS=LZW dem_fill_aspect.tif dem_fill_aspect_resampled.tif -overwrite
