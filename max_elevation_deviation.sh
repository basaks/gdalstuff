export dem=/g/data/ge3/sudipta/jobs/cogs/80m_albers/demh1sv1_0_80m_albers.tif
export workdir=/g/data/ge3/sudipta/jobs/max_ele_dev
export prefix="maxelevationdeviation"

maxeledev(){
    echo "Calculate maxeledev for : $5 with params min_scale:$2, max_scale:$3, step: $4"
    scale=$1
    min_scale=$2
    max_scale=$3
    step=$4
    prefix=$5

    whitebox_tools -r=MaxElevationDeviation -v --dem=${dem} \
        -out_mag=${workdir}/${prefix}_mag${scale}.tif \
        --out_scale=${workdir}/${prefix}_scale${scale}.tif \
        --min_scale=${min_scale} --max_scale=${max_scale} --step=${step}

    # remove the unused _scale file
    rm ${workdir}/${prefix}_scale${scale}.*
}

# Define the arrays
min_scales=(3 100 800)
max_scales=(99 795 1800)
steps=(1 5 10)


export -f maxeledev

#parallel --jobs 3 -m maxeledev ::: \
#  0 ${min_scales[0]} ${max_scales[0]} ${steps[0]} ${prefix} \
#  1 ${min_scales[1]} ${max_scales[1]} ${steps[1]} ${prefix} \
#  2 ${min_scales[2]} ${max_scales[2]} ${steps[2]} ${prefix}

for ((i=0;i<3;i++)); do
    maxeledev ${i} ${min_scales[$i]} ${max_scales[$i]} ${steps[$i]} ${prefix}
done

whitebox_tools -r=MultiscaleTopographicPositionImage -v \
    --local=${workdir}/${prefix}_mag0.tif \
    --meso=${workdir}/${prefix}_mag1.tif \
    --broad=${workdir}/${prefix}_mag2.tif \
    --output=${workdir}/multiscale.tif


# MultiscaleRoughness from here
export dem=/g/data/ge3/sudipta/jobs/cogs/80m_albers/demh1sv1_0_80m_albers.tif
export workdir=/g/data/ge3/sudipta/jobs/max_ele_dev
whitebox_tools -r=MultiscaleRoughness -v --dem=${dem} \
  --out_mag=${workdir}/roughness_mag.tif \
  --out_scale=${workdir}/roughness_scale.tif \
  --min_scale=1 --max_scale=1000 --step=5


#PBS -P ge3
#PBS -N multiscale
#PBS -q hugemem
#PBS -l walltime=48:00:00,mem=2950GB,ncpus=48,jobfs=10GB
#PBS -l storage=gdata/dg9+gdata/dz56+gdata/ge3+gdata/u46
#PBS -l wd
#PBS -j oe
#PBS -M john.wilford@ga.gov.au