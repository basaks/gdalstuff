parallel -u qdel {} ::: `nqstat -P ge3 | grep 648 | cut -b 1-8`

for f in `ls *.tif -1`; do echo $f; nf=`echo $f | cut -b 49-`; echo moving $f to cnn_hw4_7_classes_more_covs_$nf; mv $f cnn_hw4_7_classes_more_covs_$nf; done