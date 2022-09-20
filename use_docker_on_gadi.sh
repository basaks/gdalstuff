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

docker_image=/g/data/ge3/sudipta/jobs/docker/gdal_latest.sif
common_args="-t_srs EPSG:3577 -of COG -co BIGTIFF=YES -co COMPRESS=LZW"

function dockerised_crop_dale {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    type=$(gdalinfo $f  | grep Type | cut -d '=' -f 3 | cut -d ',' -f 1)
    echo $type
    if [ "$type" == "Float32" ]; then
      singularity exec \
            --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
            --bind /g/data/ge3/sudipta/jobs/cogs/csiro_30m/:/mount_dir/ \
            $docker_image \
            gdalwarp  \
            -r bilinear \
            -tr 80.0 80.0 \
            -dstnodata 'nan' \
            -ot Float32 \
            -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
            /mount_dir/${f##*/} /cogs/80m_albers/${basename%.*}.tif $common_args;
      echo ====== processed float32 raster ${f} ====== ;
      else echo not float;
        singularity exec \
            --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
            --bind /g/data/ge3/sudipta/jobs/cogs/csiro_30m/:/mount_dir/ \
            $docker_image \
            gdalwarp \
            -r nearest \
            -tr 80.0 80.0 \
            -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
            /mount_dir/${f##*/} /cogs/80m_albers/${basename%.*}.tif $common_args;
      echo ====== processed non float raster type "$type" ${f} ====== ;
    fi
}

function dockerised_crop_dale {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    type=$(gdalinfo $f  | grep Type | cut -d '=' -f 3 | cut -d ',' -f 1)
    echo $type
    if [ "$type" == "Float32" ]; then
      singularity exec \
            --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
            --bind /g/data/u46/users/dxr251/:/mount_dir/ \
            /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
            gdalwarp  \
            -r bilinear \
            -t_srs EPSG:3577 \
            -tr 30.0 30.0 \
            -dstnodata 'nan' \
            -ot Float32 \
            -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
            /mount_dir/be30-thematic/${f##*/} /cogs/be30-thematic-albers-cogs/${basename%.*}.tif \
            -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
      echo ====== processed float32 raster ${f} ====== ;
      else echo not float;
        singularity exec \
            --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
            --bind /g/data/u46/users/dxr251/:/mount_dir/ \
            /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
            gdalwarp \
            -r bilinear \
            -t_srs EPSG:3577 \
            -tr 30.0 30.0 \
            -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
            /mount_dir/be30-thematic/${f##*/} /cogs/be30-thematic-albers-cogs/${basename%.*}.tif \
            -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
      echo ====== processed non float raster type "$type" ${f} ====== ;
    fi
}


/g/data/ge3/covariates/national_albers_filled_new/albers_cropped/s2-dpca-85m_band1.tif - Nodata = None, not nan

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


function set_nodata_and_dtype {
    f=$1
    basename=${f##*/}
    echo will convert ${f##*/} to ${basename%.*}.tif
    singularity exec \
      --bind /g/data/ge3/sudipta/jobs/cogs/:/cogs/ \
      --bind /g/data/ge3/sudipta/jobs/cogs/mrvbf_test:/mount_dir/ \
      /g/data/ge3/sudipta/jobs/docker/gdal_latest.sif \
      gdalwarp \
      -t_srs EPSG:3577 \
      -tr 80.0 80.0 \
      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
      -r nearest \
      -ot Int16 \
      -srcnodata 255 \
      -dstnodata -9999 \
      /mount_dir/${f##*/} /cogs/80m_albers/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}
#"/g/data/ge3/covariates/national_albers_filled_new/albers_cropped/s2-dpca-85m.tif"


function set_nodata_and_dtype {
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
      -r nearest \
      -ot Int16 \
      -dstnodata -9999 \
      /mount_dir/${f##*/} /cogs/80m_albers/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo ====== processed ${f} ====== ;
}


function extract_data_type {
  f=$1
  type=$(gdalinfo $f  | grep Type | cut -d '=' -f 3 | cut -d ',' -f 1)
  echo $type
}

whitebox_tools -r=MaxElevationDeviation -v --dem= \
        -out_mag=$PWD/ \
        --out_scale=$PWD/${flt}_scale${scale}.flt \
        --min_scale=${min_scale} --max_scale=${max_scale} --step=${step}

whitebox_tools -r=MaxElevationDeviation \
  --dem=/g/data/ge3/sudipta/jobs/cogs/80m_albers/demh1sv1_0_80m_albers.tif \
  --o /DEVmax_mag.tif  --min_scale=1 --max_scale=1000 --step=5

function convert_csiro {
  f=$1
  basename=${f##*/}
  gdalwarp \
    -dstnodata 'nan' \
    -r bilinear \
    -t_srs EPSG:3577 \
    -tr 80.0 80.0 \
    -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
    -ot Float32 \
    ${f} 80m/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
}


function convert_csiro_byte {
  f=$1
  basename=${f##*/}
  gdalwarp \
    -r bilinear \
    -t_srs EPSG:3577 \
    -tr 30.0 30.0 \
    -r nearest \
    -ot Int16 \
    -dstnodata -9999 \
    -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
    ${f} 30m/${basename%.*}.tif -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
}



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


#
#[15/07 15:17] John Wilford
#built 2 new 30 geology class covariates  - /g/data/ge3/data/data_in_transit/Lithology_Surface_Geology30M.tif
# like 1
#
#[15/07 15:17] John Wilford
#/g/data/ge3/data/data_in_transit/Lithology_Surface_Geology_Major30M.tif
# like 1
#
#[15/07 15:17] John Wilford
#these won't have the correct number of pixel and will need to be clipped etc...
#
#[15/07 15:20] John Wilford
#nodata for Lithology_Surface_Geology30M.tif == 255 and Lithology_Surface_Geology_Major30M.tif == -128
#
#[15/07 15:21] John Wilford
#sorry about that I should have made them the same - how are we define the 8 bit datasets in terms of nodata value ?
#
#[15/07 16:39] John Wilford
#lots to get through ...let me know if you plan to work over the weekend...Im heading off now



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

# lots of iterations of of wa conductivity models using both NN and also traditional ml models
# some minor enhancements of landshark code + massively parallel prediction
# lots of cenozoic depth model predictions using aem-depth package and some minor enhancements on that package
# we are starting to write this cenozoic depth modelling paper
# started looking at 2 and half d modelling approach for cenozoic basin depth by combining both the 2d depth model
# (predictions) + Seb cenozoic depth interpretations + the drill holes
# continuing the 80m national covariates work - almost settled now


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

function ec_crop {
  f=$1
  echo  will convert ${f} into ec_crop/${f##*/}
  gdalwarp -te 627320 -3763932 774876 -3674850 ${f} ec_crop/${f##*/} -overwrite
}

function ec_crop_large {
  f=$1
  echo  will convert ${f} into ec_crop/${f##*/}
  gdalwarp -te 579575, -3876615, 979900, -3586467 ${f} ec_crop_large/${f##*/} -overwrite
}

# cat 1in10/cogs_first_rank_natuonal.txt | parallel ec_crop_large

function wa_crop {
  f=$1
  echo  will convert ${f} into wa_covariates/${f##*/}
  gdalwarp -te -1968200 -4004450 -215350 -1235420 ${f} wa_covariates/${f##*/} -overwrite
}
# -te -1968200 -4004450 -215350 -1235420


function wa_crop_small_long {
  f=$1
  echo  will convert ${f} into wa_covariates/${f##*/}
  gdalwarp -te -1158962 -3438568 -908932 -2321364 ${f} wa_crop_small_long/${f##*/} -overwrite
}



function wa_crop_does_not_work {
  f=$1
  echo  will convert ${f} into wa_covariates/${f##*/}
  gdalwarp -te -1404357 -3409574 -977054 -2226781 ${f} wa_crop_longer/${f##*/} -overwrite
}

function wa_crop_works {
  f=$1
  echo  will convert ${f} into wa_covariates/${f##*/}
  gdalwarp -te -1343345 -3409574 -977054 -2226781 ${f} wa_crop_selected/${f##*/} -overwrite
}


#df['POINT_X'] = df.geometry.x
#df['POINT_Y'] = df.geometry.y
# df1 = df[(df.POINT_X > -1404357) & (df.POINT_Y > -3409574) & (df.POINT_X < -977054) & (df.POINT_Y < -2226781)]

#(-1404357.6667447388,
# -3409574.679312084,
# -977054.7288055345,
# -2226781.4934713207)
#


#[Yesterday 10:43] Sudipta Basak
#[10:42] John Wilford
#-1158962 -908932.
#
#[10:42] John Wilford
#-2321364 -3438568      WA crop corner coordiantes



# WA files
#Upper Left  (-1668147.000,-3268289.000) (114d36'59.34"E, 29d 1'50.40"S)
#Lower Left  (-1668147.000,-3933119.000) (113d37'35.72"E, 34d55' 3.57"S)
#Upper Right ( -783670.000,-3268289.000) (123d47'38.46"E, 29d49'11.09"S)
#Lower Right ( -783670.000,-3933119.000) (123d19'18.55"E, 35d45'32.86"S)
#Center      (-1225908.500,-3600704.000) (118d49'54.63"E, 32d26'53.77"S)


gdalwarp $output.vrt $output.tif $cogs_big_albers \
	      -tr 80.0 80.0 \
	      -r bilinear \
	      -ot Float32 \
	      -dstnodata 'nan' \
	      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000
