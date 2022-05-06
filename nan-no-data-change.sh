python gdal_calc.py -A input.tif --NoDataValue=-9999 --outfile=input.temp.tif --calc="-9999*numpy.isnan(A)+ (~numpy.isnan(A))*A" --allBands=A;




python gdal_calc.py -A input.tif \
  --NoDataValue=-340282346638528859811704183484516925440 \
  --outfile=input.temp.tif \
  --calc="-340282346638528859811704183484516925440*numpy.isnan(A)+ (~numpy.isnan(A))*A" --allBands=A \
  --co BIGTIFF=YES --co COMPRESS=LZW
