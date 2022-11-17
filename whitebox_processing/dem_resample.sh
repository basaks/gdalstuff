#!/bin/bash

#PBS -l ncpus=48
#PBS -l mem=1400GB
#PBS -l jobfs=10GB
#PBS -q hugemem
#PBS -P ge3
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/dg9+gdata/dz56+gdata/ge3
#PBS -l wd
#PBS -j oe



module load gdal parallel

parallel -u gdalwarp -r bilinear  -t_srs EPSG:3577 -tr {1} {1} -dstnodata -340282346638528859811704183484516925440 -ot Float32 -te  -2000000.000 -4899990.000 2200020.000 -1050000.000  /g/data/ge3/data/data_in_transit/DEM-S_27m.tif dem_s_{1}m_large_nodata.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW ::: 30 80
parallel -u gdalwarp -r bilinear  -t_srs EPSG:3577 -tr {1} {1} -dstnodata 'nan' -ot Float32 -te  -2000000.000 -4899990.000 2200020.000 -1050000.000  /g/data/ge3/data/data_in_transit/DEM-S_27m.tif dem_s_{1}m.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW ::: 30 80
