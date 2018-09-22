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
export PATH=$HOME/.local/bin:$PATH
export PYTHONPATH=$HOME/.local/lib/python3.5/site-packages:$PYTHONPATH
export VIRTUALENVWRAPPER_PYTHON=/apps/python3/3.5.2/bin/python3
export LC_ALL=en_AU.UTF-8
export LANG=en_AU.UTF-8
source $HOME/.local/bin/virtualenvwrapper.sh
export WORKON_HOME=/g/data/ge3/john/venvs/
export UNCOVER=$HOME/uncover-ml
workon class

export COMMON_OPTIONS="-co BLOCKXSIZE=128 -co BLOCKYSIZE=128 -co TILED=YES -co COMPRESS=LZW -co BIGTIFF=NO"

covar_file=/g/data/ge3/covariates/national_albers/covar.txt

outdir=/g/data/ge3/covariates/national_albers/albers_tifs

# number of pixels to interpolate to
extent=3

function fill {
    outdir=$1
    f=$3
    extent=$2
    echo =====================================================================;
    echo projecting $f into ${outdir}/${f##*/};
    gdalwarp -overwrite -t_srs EPSG:3577 $COMMON_OPTIONS $f ${outdir}/${f##*/};
    echo fill nodata in ${outdir}/${f##*/} and write to ${outdir}/filled_${f##*/} with extent $extent;
    python gdal_fillnodata.py $COMMON_OPTIONS -md $extent ${outdir}/${f##*/} ${outdir}/filled_${f##*/};
    echo thumbnail ${outdir}/filled_${f##*/} ${outdir}/filled_th_${f##*/};
    gdalwarp -overwrite $COMMON_OPTIONS -tr 900 900 ${outdir}/filled_${f##*/} ${outdir}/filled_th_${f##*/};
}

export -f fill

cat ${covar_file} | parallel -j 28 fill ${outdir} $extent
