# find all from directory recursively
find /g/data/ge3/sudipta/80m_albers/ -name \*tif > 80m_albers_2023_01_23.txt

parallel echo {1} 10 ::: `cat 80m_albers_2023_01_23.txt`


# from covs.txt which are normalised - find basenane and then find each file in a nested dir
for f in  `cat ../covs.txt`; do bn=$(basename $f); echo $bn; find /g/data/ge3/sudipta/80m_albers/ -name ${bn} >> selected_covs_national.txt; done