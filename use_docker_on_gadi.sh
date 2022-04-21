module load singularity
singularity pull --dir . docker://osgeo/gdal
singularity exec \
  --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
  /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
  gdalwarp -srcnodata -9999 -dstnodata 0 \
  /albers_cropped/dem_fill.tif /cogs/dem_fill.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW
