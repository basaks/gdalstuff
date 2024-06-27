gdaltindex clipper.shp clipper.tif  # create clipper.shp from clipper.tif which is the small raster
gdalwarp -cutline clipper.shp -crop_to_cutline large.tif clipped.tif
