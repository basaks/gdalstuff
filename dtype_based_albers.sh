export COMMON_OPTIONS="-co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=YES"
# export GDAL_OPTS="-multi -co NUM_THREADS=ALL_CPUS -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 50000"
covar_file=selected_covariates.txt

outdir=/path/to/outdir

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
