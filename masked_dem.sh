#!/bin/bash

#PBS -l ncpus=48
#PBS -l mem=192GB
#PBS -l jobfs=10GB
#PBS -q normal
#PBS -P ge3
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/dg9+gdata/dz56+gdata/ge3
#PBS -l wd
#PBS -j oe

module load gdal


dem=$PWD/dem_s_30m.tif
mask=$PWD/../maps/mask_30m_albers.tif
bn=$(basename $dem)
echo $bn
stemname=${bn%.tif}
echo $stemname
masked_dem_name=./${stemname}_masked.tif
output_dem_name=./${stemname}_masked_cog.tif
echo gdal_calc.py -A $dem -B $mask --outfile=${masked_dem_name} --calc="(B==1)*A-340282346638528859811704183484516925440*(B!=1)" --overwrite --NoDataValue=-340282346638528859811704183484516925440  --hideNoData
echo gdalwarp ${masked_dem_name} ${output_dem_name} -dstnodata 'nan' -of COG -co BIGTIFF=YES -co COMPRESS=LZW -te  -2000000.000 -4899990.000 2200020.000 -1050000.000


#COGANDEXTENT="-of COG -co BIGTIFF=YES -co COMPRESS=LZW -te  -2000000.000 -4899990.000 2200020.000 -1050000.000"
#"-2000000.000 -2899990.000 -1900000.000 -2099990.000"
#dem=$PWD/dem_s_30m.tif
#mask=$PWD/../maps/mask_30m_albers.tif
#bn=$(basename $dem)
#echo $bn
#stemname=${bn%.tif}
#echo $stemname
#masked_dem_name=./${stemname}_masked.tif
#output_dem_name=./${stemname}_masked_cog.tif
#echo gdal_calc.py -A $dem -B $mask --outfile=${masked_dem_name} --calc="(B==1)*A-340282346638528859811704183484516925440*(B!=1)" --overwrite --NoDataValue=-340282346638528859811704183484516925440  --hideNoData
#echo gdalwarp ${masked_dem_name} ${output_dem_name} -dstnodata 'nan' $COGANDEXTENT
