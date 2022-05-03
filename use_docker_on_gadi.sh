module load singularity
singularity pull --dir . docker://osgeo/gdal

export SINGULARITY_ARGS=""

singularity exec \
  --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
  /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
  gdalwarp \
  -srcnodata -9999 -dstnodata 'nan' \
  -t_srs EPSG:3577 \
  -tr 30.0 30.0 \
  /cogs/demh1sv1_0.tif /cogs/demh1sv1_0_30m_albers.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW


singularity exec \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
  /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
  gdalwarp \
  -dstnodata 'nan' \
  -t_srs EPSG:3577 \
  -tr 30.0 30.0 \
  /cogs/demh1sv1_0.tif /cogs/demh1sv1_0_30m_albers.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW


singularity exec \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
  /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
  gdalwarp \
  -dstnodata 'nan' \
  -t_srs EPSG:3577 \
  -tr 80.0 80.0 \
  -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
  /cogs/demh1sv1_0.tif /cogs/demh1sv1_0_80m_albers.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW



function dockerised_crop {
    f=$1
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -dstnodata 'nan' \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      /albers_cropped/${f##*/} /cogs/majors_covs_80m/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
}

export -f dockerised_crop
cat /path/to/some/text/file_with_raster_paths.txt | parallel dockerised_crop

for f in `cat /g/data/ge3/john/MAJORS/CNN_test/2022_list.txt`;
  do singularity exec \
  --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
  --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
  /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
  gdalwarp \
  -dstnodata 'nan' \
  -t_srs EPSG:3577 \
  -tr 80.0 80.0 \
  -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
  /albers_cropped/${f##*/} /cogs/majors_covs_80m/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
done



#Upper Left  (-2000000.000,-1050000.000) (114d22'17.56"E,  8d43'40.51"S)
#Lower Left  (-2000000.000,-4899990.000) (108d 4'11.04"E, 43d 6'57.19"S)
#Upper Right ( 2200020.000,-1050000.000) (151d21'56.84"E,  8d27'28.29"S)
#Lower Right ( 2200020.000,-4899990.000) (158d15'34.58"E, 42d45'11.92"S)
#Center      (  100010.000,-2974995.000) (133d 1'26.39"E, 27d25'33.10"S)
#
#
#Upper Left  (-2134297.620,-1048240.533) (113d12'23.62"E,  8d31'59.23"S)
#Lower Left  (-2134297.620,-4964360.533) (106d21' 5.63"E, 43d27'45.94"S)
#Upper Right ( 2468112.380,-1048240.533) (153d40'49.48"E,  8d 2'22.61"S)
#Lower Right ( 2468112.380,-4964360.533) (161d31'39.81"E, 42d47'51.34"S)
#Center      (  166907.380,-3006300.533) (133d42'47.48"E, 27d41'54.64"S)
