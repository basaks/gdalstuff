gdalwarp -t_srs EPSG:3577 -wo NUM_THREADS=ALL_CPUS -wo SOURCE_EXTRA=1000 -co COMPRESS=LZW k_15v5.tif k_15v5_del.tif -overwrite
