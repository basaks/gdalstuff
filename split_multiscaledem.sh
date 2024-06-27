# from nan nodata to real no data + other stuff

# first multiply by 10_000_000
gdal_calc.py --hideNoData -A demh1sv1_0_80m_albers.tif --outfile=demh1sv1_0_80m_albers_x10.tif --calc="10000000*A*(~numpy.isnan(A))-340282346638528859811704183484516925440*numpy.isnan(A)" --overwrite --debug --NoDataValue=-340282346638528859811704183484516925440
gdalwarp demh1sv1_0_80m_albers_x10.tif demh1sv1_0_80m_albers_x10_int32.tif -co BIGTIFF=NO -co COMPRESS=LZW -ot Int32 -overwrite
parallel -j 3 -u --link maxeledev ::: 1 2 3 ::: 3 100 800 ::: 99 795 1800 ::: 1 5 10 ::: demh1sv1_0_80m_albers_x10_int32


# stemname=${f%.tif};


maxeledev(){
    echo "Calculate maxeledev for dem: $5 with params min_scale:$2, max_scale:$3, step: $4"
    scale=$1
    min_scale=$2
    max_scale=$3
    step=$4
    dem=$5

    whitebox_tools -r=MaxElevationDeviation -v --dem=$PWD/${dem}.tif \
        --out_mag=$PWD/${dem}_mag_${scale}_min_scale_${min_scale}_max_scale_${max_scale}_step_${step}.tif \
        --out_scale=$PWD/${dem}_scale_${scale}_min_scale_${min_scale}_max_scale_${max_scale}_step_${step}.tif \
        --min_scale=${min_scale} --max_scale=${max_scale} --step=${step}

    # remove the unused _scale file
    rm $PWD/${dem}_scale_${scale}_min_scale_${min_scale}_max_scale_${max_scale}_step_${step}.tif
}

min_scales=(3 100 800)
max_scales=(99 795 1800)
steps=(1 5 10)

parallel -j 3 -u --link maxeledev ::: 1 2 3 ::: 3 100 800 ::: 99 795 1800 ::: 1 5 10 ::: demh1sv1_0_80m_albers_X10m

export -f maxeledev

function split_and_calc {
    dem=$1
    dem_basename=${dem##*/}

    echo splitting $dem;

     gdalwarp $dem  ${dem_basename}_1.tif -co BIGTIFF=NO\
            -dstnodata -340282346638528859811704183484516925440 \
            -te  -2000000.000 -4899990.000 -500000.000 -1050000.000 -overwrite
     gdalwarp $dem ${dem_basename}_2.tif -co BIGTIFF=NO\
            -dstnodata -340282346638528859811704183484516925440 \
            -te  -1000000.000 -4899990.000 500000.000 -1050000.000 -overwrite
     gdalwarp $dem ${dem_basename}_3.tif -co BIGTIFF=NO\
            -dstnodata -340282346638528859811704183484516925440 \
            -te  0.000 -4899990.000 1500000.00 -1050000.000 -overwrite
     gdalwarp $dem ${dem_basename}_4.tif -co BIGTIFF=NO\
            -dstnodata -340282346638528859811704183484516925440 \
            -te  1000000.00 -4899990.000 2200020.000 -1050000.000 -overwrite

    for i in {1..4}
      do echo $i
      parallel --jobs 3 -m maxeledev ::: \
           1 ${min_scales[0]} ${max_scales[0]} ${steps[0]} ${dem_basename}_${i} \
           2 ${min_scales[1]} ${max_scales[1]} ${steps[1]} ${dem_basename}_${i} \
           3 ${min_scales[2]} ${max_scales[2]} ${steps[2]} ${dem_basename}_${i}
    done
  }

export -f split_and_calc

function stitch_them_up {
    dem=$1
    dem_basename=${dem##*/}
    #    output="max_dev_elevation_3_99_1"

    echo splitting $dem;

    for i in {1..3}
        do echo $i
        gdalwarp ${dem_basename}_1_mag_${i}.tif  ${dem_basename}_1_mag_${i}_orig.tif -co BIGTIFF=NO\
                    -dstnodata -340282346638528859811704183484516925440 \
                    -te  -2000000.000 -4899990.000 -1000000.000 -1050000.000 -overwrite
        gdalwarp ${dem_basename}_2_mag_${i}.tif  ${dem_basename}_2_mag_${i}_orig.tif -co BIGTIFF=NO\
              -dstnodata -340282346638528859811704183484516925440 \
              -te  -1000000.000 -4899990.000 0.000 -1050000.000 -overwrite
        gdalwarp ${dem_basename}_3_mag_${i}.tif  ${dem_basename}_3_mag_${i}_orig.tif -co BIGTIFF=NO\
              -dstnodata -340282346638528859811704183484516925440 \
              -te  0.000 -4899990.000 1000000.00 -1050000.000 -overwrite
        gdalwarp ${dem_basename}_4_mag_${i}.tif  ${dem_basename}_4_mag_${i}_orig.tif -co BIGTIFF=NO\
              -dstnodata -340282346638528859811704183484516925440 \
              -te  1000000.00 -4899990.000 2200020.000 -1050000.000 -overwrite

    done
    gdalbuildvrt --config GDAL_NUM_THREADS 16 $output.vrt ${dem_basename}_1_mag_{i}_orig.tif

  }

