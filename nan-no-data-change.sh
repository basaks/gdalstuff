python gdal_calc.py -A input.tif --NoDataValue=-9999 --outfile=input.temp.tif --calc="-9999*numpy.isnan(A)+ (~numpy.isnan(A))*A" --allBands=A;
