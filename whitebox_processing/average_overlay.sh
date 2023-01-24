#!/bin/bash

#PBS -l ncpus=48
#PBS -l mem=1470GB
#PBS -l jobfs=10GB
#PBS -q hugemem
#PBS -P ge3
#PBS -l walltime=24:00:00
#PBS -l storage=gdata/dg9+gdata/dz56+gdata/ge3
#PBS -l wd
#PBS -j oe

module load gdal/3.5.0 parallel python3/3.10.4
source /g/data/ge3/sudipta/venvs/land3p9n/bin/activate

export PYTHONPATH=/g/data/ge3/sudipta/whitebox-tools:/apps/gdal/3.5.0/lib/python3.10/site-packages/:/apps/python3/3.10.4/lib/python3.10/site-packages/

python ./average_wbt.py
