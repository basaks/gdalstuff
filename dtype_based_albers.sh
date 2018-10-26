export COMMON_OPTIONS="-co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=YES"
# export GDAL_OPTS="-multi -co NUM_THREADS=ALL_CPUS -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 50000"
covar_file=/g/data/ge3/covariates/national/selected_covariates.txt

outdir=/g/data/ge3/covariates/national_filled/albers_cubic_85_kernel3
outdir2=/g/data/ge3/covariates/national_filled/albers_cubic_85_kernel3_final
# number of pixels to interpolate to
export extent=3
export rows=10
export cols=100
export partitions=10

# new no data
export NODATA=-9999

function project {
    outdir=$1
    f=$2
    echo =====================================================================;
    echo projecting ${f} into ${outdir}/${f##*/};
    dtype=`gdalinfo ${f} | grep Type= | grep Band | cut -d ',' -f 1 | cut -d '=' -f 3`
    echo $dtype
    if [ "$dtype" = "Float32" ]
    then
      echo got $dtype Float32;
      gdalwarp -overwrite -r cubic -t_srs EPSG:3577 -tr 85 85 $COMMON_OPTIONS ${f} ${outdir}/${f##*/};
    else
      echo got $dtype not Float32;
      gdalwarp -overwrite -r near -t_srs EPSG:3577 -tr 85 85 $COMMON_OPTIONS ${f} ${outdir}/${f##*/};
    fi
    rm $f
}

export -f project


while IFS='' read -r line || [[ -n "$line" ]]; do
    echo "while loop item  =================================";
    # fill $outdir $line
    ls $line;
    fill ${outdir} ${line} > /dev/null < /dev/null;
    echo converted $line;    
done < ${covar_file}
