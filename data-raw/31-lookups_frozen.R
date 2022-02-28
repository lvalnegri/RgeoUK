#############################################################
# UK GEOGRAPHY * 40 - Lookups SMALL AREAS: OA > LSOA > MSOA #
#############################################################

dmpkg.funs::load_pkgs(dmp = FALSE, 'data.table')

message('Processing [OA=>LSOA] for England...')
y <- fread( file.path(lkps_path, 'OA11_LSOA11_MSOA11_LAD11_EW_LUv2.csv'), select = c(1:2, 4), col.names = c('OA', 'LSOA', 'MSOA') )

message('Processing [OA=>LSOA] for Scotland...')
y <- rbindlist(list( y, fread(file.path(lkps_path, '00462936.csv'), select = 1:3) ), use.names = FALSE )

message('Processing [OA=>LSOA] for N.Ireland...')
yni <- data.table( readODS::read_ods( file.path(lkps_path, 'Geographic_Data_(statistical_geographies).ods'), sheet = 1, skip = 4)[1:2] )
yni[, MSOA := paste0('96', substring(SOA, 3))]
y <- rbindlist(list( y, yni ), use.names = FALSE)

message('Saving dataset...')
fwrite(y[order(OA)], './data-raw/csv/lookups/OA_LSOA_MSOA.csv')

message('DONE! Cleaning...')
rm(list = ls())
gc()
