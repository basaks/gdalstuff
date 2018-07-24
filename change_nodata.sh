# set values less than -9999 to -9999
# follow up by assigning nodata to -9999

gdal_calc.py -A Rad_ratio_K_Th.tif --overwrite --NoDataValue=-9999 --outfile=Rad_ratio_K_Th_temp.tif --calc="-9999*(A<-9999)+A*(A>=-9999)"

# 
# gdalwarp -dstnodata -9999 Potassium_2016_tmp.tif Potassium_2016_NoData.tif
# rm Potassium_2016_temp.tif
