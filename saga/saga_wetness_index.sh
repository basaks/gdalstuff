#!/bin/bash

#PBS -l ncpus=48
#PBS -l mem=192GB
#PBS -l jobfs=10GB
#PBS -q normal
#PBS -P ge3
#PBS -l walltime=48:00:00
#PBS -l storage=gdata/dg9+gdata/dz56+gdata/ge3+gdata/u46
#PBS -l wd
#PBS -j oe


module load singularity

export OMP_NUM_THREADS=$PBS_NCPUS

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif saga_cmd ta_hydrology 15 \
  -DEM /g/data/ge3/sudipta/jobs/30m_albers/dem_s_80m_large_nodata.tif \
  -AREA area.tif -SLOPE slope.tif -AREA_MOD area_mod.tif -TWI twi.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS ./area.sdat \
	-FILE ./area.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS ./slope.sdat \
	-FILE ./slope.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS ./twi.sdat \
	-FILE ./twi.tif
