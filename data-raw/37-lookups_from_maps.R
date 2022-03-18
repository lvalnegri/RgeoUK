#########################################
# UK GEOGRAPHY * 37 - lookups from maps #
#########################################
# https://opendata.arcgis.com/api/v3/datasets/<bnd_id>_0/downloads/data?format=shp&spatialRefId=27700
# https://geoportal.statistics.gov.uk/search?q=<ons_id>&sort=-modified&tags=bdy_<ons_id>
# BGC Generalised (20m) - clipped to the coastline (Mean High Water mark); 

Sys.setenv(RSTUDIO_PANDOC="/usr/lib/rstudio-server/bin/pandoc")

dmpkg.funs::load_pkgs(dmp = FALSE, 'data.table', 'dplyr', 'leaflet', 'rmapshaper', 'sf')
sdir <- './data-raw/shp/'

ln <- fread('./data-raw/csv/location_types.csv', 
            na.strings = '', 
            select = c('location_type', 'name', 'countries', 'ons_id', 'bnd_id', 'is_frozen', 'needs_update', 'max_child')
)
ln <- ln[!is.na(bnd_id) & is_frozen == 'N' & needs_update == 'Y']

tmpd <- tempdir()
for(idx in 1:nrow(ln)){

    yt <- ln[idx, location_type]
    message('\nProcessing ', yt, ' (', ln[idx, name], ')')
    
    message(' * Downloading and unzipping shapefile...')
    tmpf <- tempfile()
    download.file(paste0('https://opendata.arcgis.com/api/v3/datasets/', ln[idx, bnd_id], '_0/downloads/data?format=shp&spatialRefId=27700'), destfile = tmpf)
    unzip(tmpf, exdir = sdir)
    fnames <- unzip(tmpf, list = TRUE)$Name
    for(fn in fnames) 
        file.rename(file.path(sdir, fn), file.path(sdir, paste0(yt, substr(fn, nchar(fn) - 3, nchar(fn)))))
    unlink(tmpf)
    
    message(' * Reading and cleaning boundaries...')
    y <- st_read(sdir, yt)
    y <- y |> 
          select(names(y)[grepl(paste0('^', toupper(ln[idx, ons_id]), '.*CD$|NM$'), toupper(names(y)))]) |>
          rename(!!yt := 1, !!paste0(yt, 'n') := 2)
    saveRDS(y, paste0(sdir, yt))
    yn <- y |> st_drop_geometry()
    fwrite(yn, paste0('./data-raw/csv/locations/', yt, '.csv'))
    
    message(' * Calculating OA lookups...')
    yc <- dd_build_oa_lkps_maps(y, ln[idx, countries], (ln[idx, max_child] != 'OA'), TRUE)
    # yc <- as.numeric(st_covered_by(bnd.oa, y))
    # yc <- data.table( bnd.oa |> st_drop_geometry(),  y[yc, yt] |> st_drop_geometry() )
    # yc[, RGN := NULL]
    # 
    # message('   > recovering ', formatC(yc[is.na(get(yt)), .N], big.mark = ','), ' missing OA lookups...')
    # for(idy in 1:nrow(yc)){
    #     if(is.na(yc[idy, 2])){
    #         yct <- unlist(st_intersects(bnd.oa[idy,], y))
    #         yct <- yct[which.max(as.numeric(st_area(st_intersection(bnd.oa[idy,], y[yct,]))))]
    #         yc[idy, 2 := y[yct, yt] |> st_drop_geometry()]
    #     }
    # }
    # 
    # if(ln[idx, max_child] != 'OA'){
    #     lsoa <- fread('./data-raw/csv/lookups/OA_LSOA_MSOA.csv', select = c('OA', 'LSOA'))
    #     message('   > fixing LSOA overlapping...')
    #     setnames(yc, yt, 'X')
    #     yc <- lsoa[yc, on = 'OA']
    #     yco <- unique(yc[, .(LSOA, X)])[, .N, LSOA][N > 1, as.character(LSOA)]
    #     for(x in yco) yc[LSOA == x, X := head(yc[LSOA == x, .N, X][order(-N)][, X], 1)] 
    #     yc[, LSOA := NULL]
    #     setnames(yc, 'X', yt)
    # }
    
    message(' * Dissolving boundaries...')
    y <- dd_dissolve_oa(yc, verbose = TRUE)
    # y <- merge(bnd.oa, yc)
    # bt <- NULL
    # for(rgn in sort(unique(y$RGN))) bt <- rbind(bt, y |> filter(RGN == rgn) |> ms_dissolve(yt) )
    # y <- bt |> ms_dissolve(yt) |> st_transform(4326)
    
    message(' * Saving lookups and boundaries...')
    saveRDS(y, file.path(bnduk_path, 's00', yt))
    fwrite(yc, paste0('./data-raw/csv/lookups/OA_', yt, '.csv'))
    
    message(' * Simplifying boundaries...')
    for(s in seq(10, 50, 10)){
        bt <- ms_simplify(y, s/100)
        saveRDS(bt, file.path(bnduk_path, paste0('s', s), yt))
    }
    
    message(' * Creating comparison map...')
    ym <- leaflet() |>
            addTiles() |>
            addPolygons(
                data = merge(bt, yn),
                group = 'package',
                color = 'black',
                fillOpacity = 0.2,
                label = ~get(paste0(yt, 'n'))
            ) |>
            addPolygons(
                data = readRDS(paste0(sdir, yt)) %>% st_transform(4326) |> ms_simplify(), 
                group = 'original',
                color = 'red', 
                fillOpacity = 0.2,
                label = ~get(paste0(yt, 'n'))
            ) |>
            addLayersControl(overlayGroups = c('package', 'original'))
    htmlwidgets::saveWidget(ym, paste0('./data-raw/maps/', yt, '.html'))
    system(paste0('rm -r ./data-raw/maps/', yt, '_files'))
    
    message('\n======================================================')
    
}
unlink(tmpd)
system("rm ./data-raw/shp/*.cpg")
system("rm ./data-raw/shp/*.xml")

rm(list = ls())
gc()
