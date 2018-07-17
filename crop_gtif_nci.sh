#!/usr/bin/env bash
#-----------------------------------------------------------------------------
#          Description
#
#          This script uses `gnu parallel`. 
#          It calls the scrip `crop_gtif.py` to do the real work in parallel.
#          Change `inputdir`, `outdir`, and `extents` as required.
#          For help with `extents`, see `help` in `gdalwarp`.
#          
# Dependencies:
#     gdal
#     gnu parallel
#-----------------------------------------------------------------------------

#PBS -P ge3
#PBS -q express
#PBS -l walltime=01:00:00,mem=32GB,ncpus=16,jobfs=100GB
#PBS -l wd
#PBS -j oe

module load parallel
module load gdal

inputdir=/g/data/ge3/covariates/national/TISA_4
outdir=/g/data/ge3/covariates/national/TISA_4_1
mkdir -p ${outdir}

function crop {
    outdir=$1
    f=$2
    gdalwarp -overwrite -te 131.580261 -24.565301 144.473705 -13.786752 ${f} ${outdir}/${f##*/};
}

export -f crop

ls ${inputdir}/*.tif | parallel crop ${outdir}

# -te = xmin ymin xmax ymax]
