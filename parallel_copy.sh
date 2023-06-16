module load parallel
function copy {
    f=$1
    cp ${f} /g/data/ge3/sudipta/jobs/cogs/national_wavelets/${f##*/}
    echo ====== processed ${f} ====== ;
}

export -f copy
cat /path/to/some/text/file_with_raster_paths.txt | parallel copy


#  for loop with all file types stemname basebame
for f in `cat all_shapes.txt`; do echo $f; cp ${f%.shp}.* ; done



# cat lhc_covs_original.txt | parallel -u gdalwarp -overwrite -te -1.098049e+06 -3.045671e+06 -1.039609e+06 -3.008663e+06  {} ./{/.}_small.tif
#https://stackoverflow.com/questions/45843483/basename-in-gnu-parallel
#Dirname ({/}) and basename ({%}) and remove custom suffix ({^suffix})
#
#$ echo dir/file_1.txt.gz |
#    parallel --plus echo {//} {/} {%_1.txt.gz}
#
#Get basename, and remove last ({.}) or any ({:}) extension
#
#$ echo dir.d/file.txt.gz | parallel 'echo {.} {:} {/.} {/:}'
#
#This should do what you need:
# basename stemname
#ls RG*.txt | parallel "command.sh {.}-t.txt {.}-n.txt > {.}.out"