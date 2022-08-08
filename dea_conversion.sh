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
