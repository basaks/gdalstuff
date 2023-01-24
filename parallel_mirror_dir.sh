# all files in one directory is processed into another outdir
function thumbnail {
  FILE=$1
  outdir=/g/data/ge3/sudipta/80m_albers_thumbnails/
  basename=${FILE##*/}
  basedir=$(basename $(dirname $FILE))
  mkdir -p $outdir/${basedir}/
  echo saving $FILE thumbnail in $outdir/${basedir}/$basename
  gdalwarp -tr 4000 4000 $FILE $outdir/${basedir}/$basename -overwrite
}

parallel -u -j 10 thumbnail {} ::: `cat 80m_albers_2023_01_23.txt`
