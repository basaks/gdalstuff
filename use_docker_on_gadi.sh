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
      -dstnodata -340282346638528859811704183484516925440 \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /albers_cropped/${f##*/} /cogs/majors_covs_80m_large_no_data/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}

function dockerised_crop_rad2016k_th_fixed {
    f=$1
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -srcnodata 340282346638528859811704183484516925440 \
      -dstnodata -340282346638528859811704183484516925440 \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /albers_cropped/${f##*/} /cogs/dale_fixed/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function dockerised_crop_dale {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/u46/users/dxr251/:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -dstnodata 'nan' \
      -t_srs EPSG:3577 \
      -tr 30.0 30.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /mount_dir/be30-thematic/${f##*/} /cogs/be30-thematic-albers-cogs/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function dockerised_mask_coversion_to_albers_cogs {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Byte \
      /mount_dir/${f##*/} /cogs/80m_albers/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function extract_data_type {
  f=$1
  type=gdalinfo $f  | grep Type | cut -d '=' -f 3 | cut -d ',' -f 1
  echo $type
}

whitebox_tools -r=MaxElevationDeviation -v --dem= \
        -out_mag=$PWD/ \
        --out_scale=$PWD/${flt}_scale${scale}.flt \
        --min_scale=${min_scale} --max_scale=${max_scale} --step=${step}

whitebox_tools -r=MaxElevationDeviation \
  --dem=/g/data/ge3/sudipta/jobs/cogs/80m_albers/demh1sv1_0_80m_albers.tif \
  --o /DEVmax_mag.tif  --min_scale=1 --max_scale=1000 --step=5

function dockerised_conversion_csiro_clim {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/data/data_in_transit/:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -dstnodata 'nan' \
      -r bilinear \
      -t_srs EPSG:3577 \
      -tr 30.0 30.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /mount_dir/${f##*/} /cogs/30m_rad_ratios/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}

function dockerised_conversion_gdal_calc {
    f=$1
    echo will convert ${f##*/} to mask_30m_albers.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/sudipta/jobs/cogs/30m_albers/:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdal_calc.py \
      --calc="(numpy.isfinite(A))" \
      --hideNoData \
      --NoDataValue=0 \
      --type Byte \
      -A /mount_dir/${f##*/} \
      --outfile /cogs/30m_albers/mask_30m_albers.tif \
      --format GTiff --co BIGTIFF=YES --co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function dockerised_conversion_from_large_no_data {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/data/data_in_transit/gamma/:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -dstnodata 'nan' \
      -r bilinear \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /mount_dir/${f##*/} /cogs/80m_rad_ratios/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function dockerised_crop_rad2016k_th_fixed {
    f=$1
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -srcnodata 340282346638528859811704183484516925440 \
      -dstnodata -340282346638528859811704183484516925440 \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /albers_cropped/${f##*/} /cogs/dale_fixed/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}

function dockerised_crop_water_fixed {
    f=$1
    if test -f majors_covs_80m_large_no_data/${f##*/}; then
        echo majors_covs_80m_large_no_data/${f##*/} exists.
        exit 0
    fi

    if test -f dale_fixed/${f##*/}; then
        echo dale_fixed/${f##*/} exists.
        exit 0
    fi
#    singularity exec \
#      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
#      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
#      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
#      gdalwarp \
#      -dstnodata -340282346638528859811704183484516925440 \ min(np.float32)
#                  -339999995214436424907732413799364296704    --- csiro covariates, min(np.float32)
#      -t_srs EPSG:3577 \
#      -tr 80.0 80.0 \
#      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
#      -ot Float32 \
#      /albers_cropped/${f##*/} /cogs/national_80m_large_no_data/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function dockerised_crop_dale_fixed {
    f=$1
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/covariates/national_albers_filled_new/albers_cropped/:/albers_cropped/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -srcnodata 340282346638528859811704183484516925440 \
      -dstnodata -340282346638528859811704183484516925440 \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -ot Float32 \
      /albers_cropped/${f##*/} /cogs/dale_fixed/${f##*/} -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}

#      -dstnodata -340282346638528859811704183484516925440 \


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
