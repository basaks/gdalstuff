module load singularity
singularity pull --dir . docker://osgeo/gdal
singularity exec --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ gdal_latest.sif gdalwarp /albers_cropped/dem_fill.tif /cogs/dem_fill.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW