# set values less than -9999 to -9999
# follow up by assigning nodata to -9999

gdal_calc.py -A Potassium_2016.tif --outfile=Potassium_2016_temp.tif --calc="-9999*(A<-9999)+A*(A>=-9999)"

# stragely sometimes the last two steps are not required
gdalwarp -dstnodata -9999 Potassium_2016_tmp.tif Potassium_2016_NoData.tif
rm Potassium_2016_temp.tif
