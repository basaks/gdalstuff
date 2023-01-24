# find all from directory recursively
find /g/data/ge3/sudipta/80m_albers/ -name \*tif > 80m_albers_2023_01_23.txt

parallel echo {1} 10 ::: `cat 80m_albers_2023_01_23.txt`