import click
import geopandas as gpd
from scipy import quantile


@click.command()
@click.option('-i', '--input_shp', required=True, help='Input shapefile')
@click.option('-o', '--output_shp', required=True, help='Output shapefile')
@click.option('-p', '--property', required=True,
              help='The property based on which quantiles will be calculated')
@click.option('-q', '--quantiles', type=str, default="1, 99", required=False,
              help='Quantiles use for filtering. Has to be comma separated '
                   'list of two numbers in percentage, and not fraction. '
                   'Example "2, 98".')
def remove_outliers(input_shp, output_shp, property, quantiles):
    shp = gpd.read_file(input_shp)
    lq, uq = quantile(shp[property],
                      [float(q)/100 for q in quantiles.split(',')])

    shp_filetered = shp[(shp[property] > lq) & (shp[property] < uq)]

    shp_filetered.to_file(output_shp)


if __name__ == '__main__':
    remove_outliers()
