import geopandas as gpd
from scipy import quantile
input_shapefile = '/home/sudiptra/Documents/GA-cover2/geochem_sites.shp'
output_shapefile = '/home/sudiptra/Documents/GA-cover2/geochem_sites_filtered' \
                   '.shp'
property = 'Zr_ppm_imp'

quantiles = [1, 99]  # in percentage

shp = gpd.read_file(input_shapefile)
lq, uq = quantile(shp[property], [q/100 for q in quantiles])

shp_filetered = shp[(shp[property] > lq) & (shp[property] < uq)]

shp_filetered.to_file(output_shapefile)
