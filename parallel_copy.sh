module load parallel
function copy {
    f=$1
    cp ${f} /g/data/ge3/sudipta/jobs/cogs/national_wavelets/${f##*/}
    echo ====== processed ${f} ====== ;
}

export -f copy
cat /path/to/some/text/file_with_raster_paths.txt | parallel copy
