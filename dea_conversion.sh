set -e
module load gdal/3.5.0 parallel

export cogs_big_albers="-t_srs EPSG:3577 -of COG -co BIGTIFF=YES -co COMPRESS=LZW"

function convert {
	dirname=ga_ls_tc_pc_cyear_3

	year=$1
	product=$2
	percent=$3
	pattern=$1--P1Y_final_$2_pc_$3.tif
	output=$1__P1Y_final_$2_pc_$3

	echo output=$output
	echo dirname=$dirname
	echo product=$product
	echo pattern=$pattern
	echo year=$year

	echo gather all required files into $output.txt
	find /g/data/jw04/ga/$dirname -name \*$pattern > $output.txt
	echo building $output.vrt
	gdalbuildvrt --config GDAL_NUM_THREADS 16 -input_file_list $output.txt $output.vrt
	echo converting to $output.vrt to $output.tif using options $cogs_big_albers
	gdalwarp $output.vrt $output.tif $cogs_big_albers \
	      -tr 80.0 80.0 \
	      -r nearest \
	      -ot Int16 \
	      -dstnodata -9999 \
	      -te  -2000000.000 -4899990.000 2200020.000 -1050000.000
}

export -f convert

parallel -j 18 convert ::: 2012 2013 2014 2015 2016 2017 2018 ::: wet bright green ::: 10 50 90



function average {
    i=$1
    p=$2
    f=${p}_pc_${i}_2019_2020_2021_avg
    echo running whitebox $1 $2
    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/fractional_cover_dea_data" \
      -i="2019__P1Y_final_${p}_pc_${i}.tif;2020__P1Y_final_${p}_pc_${i}.tif;2021__P1Y_final_${p}_pc_${i}.tif;" \
      -o=${f}.tif
    echo converting to cogs $1 $2
    gdalwarp ${f}.tif  ${f}_cogs.tif -r nearest -ot Int16 \
      -dstnodata -9999 -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo cleaning up $1 $2
    mv ${f}_cogs.tif ${f}.tif
  }


function average {
    i=$1
    p=$2
    f=${p}_pc_${i}_2012_2021_avg
    echo running whitebox $1 $2
    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/fractional_cover_dea_data" \
      -i="2012__P1Y_final_${p}_pc_${i}.tif;2013__P1Y_final_${p}_pc_${i}.tif;2014__P1Y_final_${p}_pc_${i}.tif;2015__P1Y_final_${p}_pc_${i}.tif;2016__P1Y_final_${p}_pc_${i}.tif;2017__P1Y_final_${p}_pc_${i}.tif;2018__P1Y_final_${p}_pc_${i}.tif;2019__P1Y_final_${p}_pc_${i}.tif;2020__P1Y_final_${p}_pc_${i}.tif;2021__P1Y_final_${p}_pc_${i}.tif;" \
      -o=${f}.tif
    echo converting to cogs $1 $2
    gdalwarp ${f}.tif  ${f}_cogs.tif -r nearest -ot Int16 \
      -dstnodata -9999 -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo cleaning up $1 $2
    mv ${f}_cogs.tif ${f}.tif
  }


function average {
    i=$1
    p=$2
    f=${p}_pc_${i}_2012_2021_avg
    echo running whitebox $1 $2
    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/brightness_greenness_wetness_percentiles_dea_data" \
      -i="2012__P1Y_final_${p}_pc_${i}.tif;2013__P1Y_final_${p}_pc_${i}.tif;2014__P1Y_final_${p}_pc_${i}.tif;2015__P1Y_final_${p}_pc_${i}.tif;2016__P1Y_final_${p}_pc_${i}.tif;2017__P1Y_final_${p}_pc_${i}.tif;2018__P1Y_final_${p}_pc_${i}.tif;2019__P1Y_final_${p}_pc_${i}.tif;2020__P1Y_final_${p}_pc_${i}.tif;2021__P1Y_final_${p}_pc_${i}.tif;" \
      -o=${f}.tif
    echo converting to cogs $1 $2
    gdalwarp ${f}.tif  ${f}_cogs.tif -r nearest -ot Int16 \
      -dstnodata -9999 -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo cleaning up $1 $2
    mv ${f}_cogs.tif ${f}.tif
  }

function average {
    i=$1
    f=final_${i}_2013_2021_avg
    echo running whitebox $1 average
    ls 2013__P1Y_final_${i}.tif
    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/mads_dea_data" \
      -i="2013__P1Y_final_${i}.tif;2014__P1Y_final_${i}.tif;2015__P1Y_final_${i}.tif;2016__P1Y_final_${i}.tif;2017__P1Y_final_${i}.tif;2018__P1Y_final_${i}.tif;2019__P1Y_final_${i}.tif;2020__P1Y_final_${i}.tif;2021__P1Y_final_${i}.tif;" \
      -o=${f}.tif
    echo converting to cogs $1 $2
    gdalwarp ${f}.tif  ${f}_cogs.tif -r bilinear -ot  Float32 \
      -dstnodata 'nan' -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo cleaning up $1 $2
    mv ${f}_cogs.tif ${f}.tif
  }


function split_and_average {
    i=$1
    f=final_${i}_2013_2021_avg
    output=final_${i}_2013_2021_avg
    echo running whitebox $1 average
    ls 2013__P1Y_final_${i}.tif


    for y in {2013..2021};
      do echo splitting $y ${i} file;
      gdalwarp ${y}__P1Y_final_${i}.tif ${y}__P1Y_final_${i}_1.tif -co BIGTIFF=NO\
              -te  -2000000.000 -4899990.000 -1000000.000 -1050000.000 -overwrite
      gdalwarp ${y}__P1Y_final_${i}.tif ${y}__P1Y_final_${i}_2.tif -co BIGTIFF=NO\
              -te  -1000000.000 -4899990.000 0.000 -1050000.000 -overwrite
      gdalwarp ${y}__P1Y_final_${i}.tif ${y}__P1Y_final_${i}_3.tif -co BIGTIFF=NO\
              -te  0.000 -4899990.000 1000000.00 -1050000.000 -overwrite
      gdalwarp ${y}__P1Y_final_${i}.tif ${y}__P1Y_final_${i}_4.tif -co BIGTIFF=NO\
              -te  1000000.00 -4899990.000 2200020.000 -1050000.000 -overwrite
    done

    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/mads_dea_data" \
          -i="2013__P1Y_final_${i}_1.tif;2014__P1Y_final_${i}_1.tif;2015__P1Y_final_${i}_1.tif;2016__P1Y_final_${i}_1.tif;2017__P1Y_final_${i}_1.tif;2018__P1Y_final_${i}_1.tif;2019__P1Y_final_${i}_1.tif;2020__P1Y_final_${i}_1.tif;2021__P1Y_final_${i}_1.tif;" \
          -o=${f}_1.tif

    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/mads_dea_data" \
              -i="2013__P1Y_final_${i}_2.tif;2014__P1Y_final_${i}_2.tif;2015__P1Y_final_${i}_2.tif;2016__P1Y_final_${i}_2.tif;2017__P1Y_final_${i}_2.tif;2018__P1Y_final_${i}_2.tif;2019__P1Y_final_${i}_2.tif;2020__P1Y_final_${i}_2.tif;2021__P1Y_final_${i}_2.tif;" \
              -o=${f}_2.tif

    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/mads_dea_data" \
              -i="2013__P1Y_final_${i}_3.tif;2014__P1Y_final_${i}_3.tif;2015__P1Y_final_${i}_3.tif;2016__P1Y_final_${i}_3.tif;2017__P1Y_final_${i}_3.tif;2018__P1Y_final_${i}_3.tif;2019__P1Y_final_${i}_3.tif;2020__P1Y_final_${i}_3.tif;2021__P1Y_final_${i}_3.tif;" \
              -o=${f}_3.tif

    whitebox_tools -r=AverageOverlay -v --wd="/g/data/ge3/sudipta/jobs/mads_dea_data" \
          -i="2013__P1Y_final_${i}_4.tif;2014__P1Y_final_${i}_4.tif;2015__P1Y_final_${i}_4.tif;2016__P1Y_final_${i}_4.tif;2017__P1Y_final_${i}_4.tif;2018__P1Y_final_${i}_4.tif;2019__P1Y_final_${i}_4.tif;2020__P1Y_final_${i}_4.tif;2021__P1Y_final_${i}_4.tif;" \
          -o=${f}_4.tif

    gdalbuildvrt --config GDAL_NUM_THREADS 16 $output.vrt ./*__P1Y_final_${i}_*.tif

    echo converting to cogs $1
    gdalwarp $output.vrt  ${f}.tif -r bilinear -ot  Float32 \
        -tr 80.0 80.0 \
        -te  -2000000.000 -4899990.000 2200020.000 -1050000.000 \
        -dstnodata 'nan' -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    echo cleaning up $1

    for y in {2013..2021};
      do echo $y;
      for n in {1..4};
      do
        echo removing ${y}__P1Y_final_${i}_${n}.tif
        rm ${y}__P1Y_final_${i}_${n}.tif
      done
    done
    echo removing $output.vrt
    rm $output.vrt
  }

