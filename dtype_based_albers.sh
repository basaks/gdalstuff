# export COMMON_OPTIONS="-co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=YES"
export COMMON_OPTIONS="-co COMPRESS=LZW -co BIGTIFF=IF_NEEDED -of COG -t_srs EPSG:3577"
# export GDAL_OPTS="-multi -co NUM_THREADS=ALL_CPUS -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 50000"
covar_file=selected_covariates.txt

outdir=/path/to/outdir

function project {
    outdir=$1
    f=$2
    basename=${f##*/}
    echo =====================================================================;
    echo projecting ${f} into ${outdir}/${f##*/};
    dtype=`gdalinfo ${f} | grep Type= | grep Band | cut -d ',' -f 1 | cut -d '=' -f 3`
    echo $dtype
    if [ "$dtype" = "Float32" ]
    then
      echo got $dtype Float32;
      gdalwarp -overwrite $COMMON_OPTIONS \
        -r bilinear \
        -tr 80.0 80.0 \
        -dstnodata 'nan' \
        -ot Float32 \
        -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
        $f  ${outdir}/${basename%.*}.tif
    else
      echo got $dtype not Float32;
      echo skipping $f from Float32
    fi
    if [ "$dtype" = "UInt16" ]
        then
          echo got $dtype Int16;
          gdalwarp -overwrite $COMMON_OPTIONS \
            -tr 80.0 80.0 \
            -r nearest \
            -ot Int16 \
            -dstnodata -9999 \
            -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
            $f  ${outdir}/${basename%.*}.tif
        else
          echo skipping $f from Int16
    fi
}

export -f project
