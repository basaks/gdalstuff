python gdal_calc.py -A input.tif --NoDataValue=-9999 --outfile=input.temp.tif --calc="-9999*numpy.isnan(A)+ (~numpy.isnan(A))*A" --allBands=A;


python gdal_calc.py -A variance.tif --outfile=sigma.tif --calc="numpy.sqrt(A)" --allBands=A;




function apply_gdal_calc {
    f=$1
    echo ${f}  befixed/${f##*/}.tif;
    gdal_calc.py -A ${f} \
      --NoDataValue=-340282346638528859811704183484516925440 \
      --outfile=dale_fixed/${f##*/}.tif \
      --calc="-340282346638528859811704183484516925440*numpy.isnan(A)+ (~numpy.isnan(A))*A" --allBands=A \
      --co BIGTIFF=YES --co COMPRESS=LZW \
      -- type Float32 \
      --hideNoData;
    echo finished converting  ${f##*/}.tif;
}

