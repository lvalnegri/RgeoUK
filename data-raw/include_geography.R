###################################################################
# popiFun * Copy datasets from PUBLIC repo to package DATA subdir #
###################################################################

# datasets related to UK geography
fnames <- c('output_areas', 'locations', 'lookups', 'hierarchies', 'workplace_zones')
for(fn in fnames){
    message('Processing <', fn, '>')
    message(' * reading...')
    assign(fn, fst::read_fst(file.path(popiFun::geouk_path, fn), as.data.table = TRUE))
    message(' * saving csv...')
    data.table::fwrite(get(fn), file.path('data-raw', paste0(fn, '.csv')))
    message(' * saving compressed rda...')
    save(list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip')
}
message('Processing <postcodes>...')
message(' * reading...')
postcodes <- popiFun::read_fst_idx(file.path(popiFun::geouk_path, 'postcodes'), 1, c('PCU', 'OA', 'x_lon', 'y_lat'))
message(' * saving csv...')
data.table::fwrite(postcodes, file.path('data-raw', 'postcodes.csv'))
message(' * saving compressed rda...')
save(list = 'postcodes', file = file.path('data', 'postcodes.rda'), version = 3, compress = 'gzip')
