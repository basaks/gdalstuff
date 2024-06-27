# set values less than -9999 to -9999
# follow up by assigning nodata to -9999

gdal_calc.py -A Rad_ratio_K_Th.tif --overwrite --NoDataValue=-9999 --outfile=Rad_ratio_K_Th_temp.tif --calc="-9999*(A<-9999)+A*(A>=-9999)"


# gdal calc + parallel in directory
ls -d * -1 | parallel -u --progress gdal_calc.py -A {}/lgbm/quantiles_lgbm_quantilelgbm_prediction.tif -B {}/lgbm/quantiles_lgbm_quantilelgbm_variance.tif --outfile={}/lgbm/{}_quantiles_lgbm_normalised_quantiles.tif --calc="\"4*numpy.sqrt(B)/A\"" --co BIGTIFF=YES --overwrite --co NUM_THREADS=4

# 
# gdalwarp -dstnodata -9999 Potassium_2016_tmp.tif Potassium_2016_NoData.tif
# rm Potassium_2016_temp.tif
