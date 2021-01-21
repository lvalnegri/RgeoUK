#########################################################################################################
# dmpkg.geouk * Geography Data UK * Copy UK geographic datasets from PUBLIC repo to package DATA subdir #
#########################################################################################################

fnames <- c('entities', 'hierarchies', 'location_types', 'output_areas', 'workplace_zones', 'locations', 'lookups')
for(fn in fnames){
    message('Processing <', fn, '>')
    message(' * reading...')
    assign(fn, fst::read_fst(file.path(dmpkg.funs::geouk_path, fn), as.data.table = TRUE))
    message(' * saving csv...')
    data.table::fwrite(get(fn), file.path('data-raw', paste0(fn, '.csv')))
    message(' * saving compressed rda...')
    save(list = fn, file = file.path('data', paste0(fn, '.rda')), version = 3, compress = 'gzip')
}

message('Processing <postcodes>...')
message(' * reading...')
postcodes <- fst::read_fst(
                file.path(dmpkg.funs::geouk_path, 'postcodes'),
                columns = c('PCU', 'is_active', 'OA', 'x_lon', 'y_lat'),
                as.data.table = TRUE
)
message(' * saving csv...')
data.table::fwrite(postcodes, file.path('data-raw', 'postcodes.csv'))
message(' * saving compressed rda...')
save(list = 'postcodes', file = file.path('data', 'postcodes.rda'), version = 3, compress = 'gzip')

message('Processing <neighbours>...')
message(' * reading...')
load('data/location_types.rda')
neighbours <- data.table::rbindlist(lapply(
    location_types$location_type,
    function(x) {
        if(file.exists(file.path(dmpkg.funs::geouk_path, 'neighbours', x)))
            fst::read_fst(file.path(dmpkg.funs::geouk_path, 'neighbours', x), as.data.table = TRUE)
    }
))
message(' * saving csv...')
data.table::fwrite(neighbours, file.path('data-raw', 'neighbours.csv'))
message(' * saving compressed rda...')
save(list = 'neighbours', file = 'data/neighbours.rda', version = 3, compress = 'gzip')

rm(list = c(fnames, 'fn', 'fnames', 'postcodes', 'neighbours'))
