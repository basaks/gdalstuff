#!/bin/bash
# takes input from a list of input geotifs
# use: ./gdal_fillnodata.sh list_of_geotifs.txt

outdir=/path/to/outdir

while IFS='' read -r line || [[ -n "$line" ]]; do
     echo filling $line and output ${outdir}/${line##*/};
     gdal_fillnodata.py -md 10 $line ${outdir}/${line##*/};
done < "$1"
