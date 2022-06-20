singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif \
  saga_cmd ta_morphometry 8 \
  -DEM  demh1sv1_0_800m_albers.tif -MRVBF demh1sv1_0_800m_albers_MRVBF.tif -MRRTF  demh1sv1_0_800m_albers_MRRTF.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS demh1sv1_0_800m_albers_MRVBF.sdat \
	-FILE demh1sv1_0_800m_albers_MRVBF.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS demh1sv1_0_80m_albers_MRRTF.sdat \
	-FILE demh1sv1_0_800m_albers_MRRTF.tif

singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd io_gdal 2  \
	-GRIDS demh1sv1_0_80m_albers_MRRTF.sdat \
	-FILE demh1sv1_0_800m_albers_MRRTF.tif

qsub -I -q normal -P ge3 -l storage=gdata/dg9+gdata/dz56+gdata/ge3+gdata/u46,walltime=48:00:00,mem=192Gb,ncpus=48,jobfs=10GB,wd
module load singularity
singularity exec /g/data/ge3/sudipta/jobs/docker/sagagis.sif  saga_cmd ta_morphometry 8 \
  -DEM demh1sv1_0_80m_albers.tif \
  -MRVBF demh1sv1_0_80m_albers_MRVBF.tif \
  -MRRTF demh1sv1_0_80m_albers_MRRTF.tif \
  - T_SLOPE 7.5