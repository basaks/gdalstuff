#PBS -P ge3
#PBS -q normalbw
#PBS -l walltime=2:00:00,mem=256GB,ncpus=28,jobfs=100GB
#PBS -l wd
#PBS -j oe

module unload intel-cc
module unload intel-cc
module load python3/3.5.2 python3/3.5.2-matplotlib
module load hdf5/1.8.10 gdal/2.0.0 geos/3.5.0 proj/4.9.3 gcc/4.9.0
module load openmpi/1.8 parallel

workon class

export COMMON_OPTIONS="-co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=YES"
# export GDAL_OPTS="-multi -co NUM_THREADS=ALL_CPUS -wo NUM_THREADS=ALL_CPUS --config GDAL_CACHEMAX 50000"
covar_file=/g/data/ge3/covariates/national_filled/covar.txt

outdir=/g/data/ge3/covariates/national_filled

# number of pixels to interpolate to
export extent=5
export rows=10
export cols=200
export partitions=20

# new no data
export NODATA=-9999

# basename and filename manipulation
# https://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash
# bn=$(basename -- "$f")

# replace extensions
# out_file=albers_${bn%.tif}.filled.tif


function project {
    outdir=$1
    f=$2
    echo =====================================================================;
    echo projecting ${f} into ${outdir}/albers_${f##*/};
    gdalwarp -overwrite -r med -t_srs EPSG:3577 $COMMON_OPTIONS ${f} ${outdir}/albers_${f##*/};
}


function fill {
    outdir=$1
    f=$2
    echo =====================================================================;
    echo now filling no data vals ${outdir}/albers_${f##*/} with $extent $rows $cols $partitions;
    mpirun python fill_large_raster.py ${outdir}/albers_${f##*/} $extent $rows $cols $partitions;    
}

export -f project
export -f fill

cat ${covar_file} | parallel project ${outdir}

wait;

# look at the special /dev/null assignment to mpirun input
# from here: https://stackoverflow.com/a/43741729/3321542
while IFS='' read -r line || [[ -n "$line" ]]; do
    fill $outdir $line > /dev/null < /dev/null
done < ${covar_file}
