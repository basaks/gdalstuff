#PBS -P ge3
#PBS -q normalbw
#PBS -l walltime=10:00:00,mem=256GB,ncpus=28,jobfs=100GB
#PBS -l wd
#PBS -j oe

module unload intel-cc
module unload intel-cc
module load python3/3.5.2 python3/3.5.2-matplotlib
module gdal/2.0.0 geos/3.5.0 gcc/4.9.0
module load parallel

export COMMON_OPTIONS="-co BLOCKXSIZE=128 -co BLOCKYSIZE=128 -co TILED=YES -co COMPRESS=LZW"
covar_file=/g/data/ge3/covariates/national_albers/albers_tifs.txt
outdir=/g/data/ge3/covariates/national_albers/albers_tifs_filled

# number of pixels to interpolate
extent=3

# while IFS='' read -r line || [[ -n "$line" ]]; do
#      echo converting $line and output ${outdir}/filled_${line##*/} ${outdir}/filled_th_${line##*/};
# done < /g/data/ge3/covariates/national_albers/albers_tifs.txt

function fill {
    outdir=$1
    f=$3
    extent=$2
    echo fill nodata in $f and output ${outdir}/filled_${f##*/} and thumbnail ${outdir}/filled_th_${f##*/} with extent: $extent;
    python gdal_fillnodata.py $COMMON_OPTIONS -md $extent $f ${outdir}/filled_${f##*/};
    echo now creating thumbnail ${outdir}/filled_th_${f##*/};
    gdalwarp -overwrite $COMMON_OPTIONS -tr 850 850 ${outdir}/filled_${f##*/} ${outdir}/filled_th_${f##*/};
}

export -f fill

cat ${covar_file} | parallel -j 6 fill ${outdir} $extent
