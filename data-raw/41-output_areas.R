#################################################################################
# UK GEOGRAPHY * 41 - Output Areas (primary lookups table OA vs everything else #
#################################################################################

dmpkg.funs::load_pkgs(dmp = FALSE, 'data.table')

yl <- fread('./data-raw/csv/location_types.csv')
cols <- yl$location_type

y <- fread('./data-raw/csv/lookups/OA_LSOA_MSOA.csv')
for(cl in rev(setdiff(cols, c('OA', 'LSOA', 'MSOA', 'WPZ')))){

    # merge OA lookups     
    yx <- fread(paste0('./data-raw/csv/lookups/OA_', cl, '.csv'))
    y <- yx[y, on = 'OA']
    # y <- fread(paste0('./data-raw/csv/lookups/OA_', cl, '.csv'))[y, on = 'OA']
    
    # build '00' polygons
    dd_dissolve_oa()

    # simplify to 10:50
    dd_simplify_bnd()

    # create comparison maps (read "" flag in "location_types")
    dd_maps_pkg_ons()

}
setcolorder(y, c('OA', 'LSOA', 'MSOA'))
y[y == 'character(0)'] <- NA
dbm_do('geography_uk', 'w', 'output_areas', y)
write_fst_idx('output_areas', c('RGN', 'LAD'), y, geouk_path)




# clean env
rm(list = ls())
gc()
