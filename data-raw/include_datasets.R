################################################################################################
# popipkg * Geography UK * Copy UK geographic datasets from PUBLIC repo to package DATA subdir #
################################################################################################

fnames <- c('output_areas', 'locations', 'location_types', 'lookups', 'hierarchies', 'workplace_zones')
for(fn in fnames){
    message('Processing <', fn, '>')
    message(' * reading...')
    assign(y, fst::read_fst(file.path(popiFun::geouk_path, fn), as.data.table = TRUE))
    message(' * saving csv...')
    data.table::fwrite(y, file.path('data-raw', paste0(fn, '.csv')))
    message(' * saving compressed rda...')
    save(list = y, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip')
}
message('Processing <postcodes>...')
message(' * reading...')
postcodes <- fst::read_fst(
                file.path(popiFun::geouk_path, 'postcodes'),
                columns = c('PCU', 'is_active', 'OA', 'x_lon', 'y_lat'),
                as.data.table = TRUE
)
message(' * saving csv...')
data.table::fwrite(postcodes, file.path('data-raw', 'postcodes.csv'))
message(' * saving compressed rda...')
save(list = 'postcodes', file = file.path('data', 'postcodes.rda'), version = 3, compress = 'gzip')
