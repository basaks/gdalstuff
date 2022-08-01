set -e
module load gdal/3.5.0

cogs_big_albers="-t_srs EPSG:3577 -of COG -co BIGTIFF=YES -co COMPRESS=LZW"

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
  gdalbuildvrt --config GDAL_NUM_THREADS 16 -input_file_list "$output".txt "$output".vrt
  echo converting to $output.vrt to $output.tif using options "$cogs_big_albers"
  gdalwarp $output.vrt ./30m/$output.tif "$cogs_big_albers" \
        -tr 30.0 30.0 \
        -r nearest \
        -ot Int16 \
        -dstnodata -9999 \
        -te  -2000000.000 -4899990.000 2200020.000 -1050000.000

}


function average {
    i=$1
    p=$2
    gdal_calc.py -A 2021__P1Y_final_${p}_pc_$i.tif -B 2020__P1Y_final_${p}_pc_$i.tif \
      -C 2019__P1Y_final_${p}_pc_$i.tif --calc "(A+B+C)/3" --outfile=${p}_pc_${i}_2019_2020_2021_avg.tif
    gdalwarp ${p}_pc_${i}_2019_2020_2021_avg.tif  ${p}_pc_${i}_2019_2020_2021_avg_cogs.tif -r nearest -ot Int16 \
      -dstnodata -9999 -of COG -co BIGTIFF=YES -co COMPRESS=LZW;
    mv ${p}_pc_${i}_2019_2020_2021_avg_cogs.tif ${p}_pc_${i}_2019_2020_2021_avg.tif
  }
