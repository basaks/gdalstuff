#!/usr/bin/env bash
#-----------------------------------------------------------------------------
#          Description
#
#          This script uses `gnu parallel`. 
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

function nt_qld_crop {
  outdir=$1;
  f=$2;
  gdalwarp -overwrite -te -1555680.000 -2666354.000 1596582.000 -1052892.000 ${f} ${outdir}/${f##*/};
}

export -f nt_qld_crop
cat first_rank_new.txt | parallel -u --dryrun nt_qld_crop first_rank_new_covs/ {}

function lake_eyre_crop_small {
    outdir=$1
    f=$2
    gdalwarp -overwrite -te 768473 -3748798 1150038 -3127563 ${f} ${outdir}/${f##*/};
}

function crop {
    f=$1
    gdalwarp -overwrite -te -141513 -3790978 1867833 -1874085 ${f} lake_eyre_covs/${f##*/};
}

tr -d '\r' < infile > outfile  # dos2unix dostounix windows

export -f crop

ls ${inputdir}/*.tif | parallel crop ${outdir}

# -te = xmin ymin xmax ymax]
# cov_file=./first_rank.txt
# cat $cov_file | parallel crop ${outdir}


# parallel copy large files
function pcopy { f=$1; echo copying $f ...; cp ${f} covs/${f##*/} ; }
export -f pcopy
cat /g/data/ge3/john/MAJORS/CNN_test/2022_list.txt | parallel pcopy