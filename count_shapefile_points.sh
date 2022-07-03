ogrinfo shape.shp -dialect SQLite -sql "SELECT count(geometry) AS n_vertices FROM shape"
