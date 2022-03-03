##################################
# UK GEOGRAPHY * 15 - Post Towns #
##################################

dmpkg.funs::load_pkgs(dmp = FALSE, c('data.table', 'fst', 'htmltab', 'rvest'))

message('Downloading Postcode Areas (PCA)...')
url_pref <- 'https://www.postcodes-uk.com/'
pca <- read_html(paste0(url_pref, 'postcode-areas')) %>%
    html_nodes('.postcode_areas_list a') %>% 
    html_text() %>% 
    matrix(byrow = TRUE, ncol = 2) %>% 
    as.data.table() %>% 
    setnames(c('PCA', 'name'))
pca[, `:=`(PCA = trimws(gsub('postcode area', '', PCA)), name = trimws(gsub('postcode area', '', name)))]
fwrite(pca, './data-raw/csv/locations/PCA.csv')

message('\nDownloading Post Towns (PCT)...')
url_pref <- 'https://www.postcodes-uk.com/'
pcdt <- list()
for(idx in 1:nrow(pca)){
    message(' - Processing postcode area ', idx, ' out of ', nrow(pca))
    pcdt <- rbindlist(list(
        pcdt,
        read_html(paste0(url_pref, pca[idx, PCA], '-postcode-area')) %>%
            html_nodes('.postcode_district_list a') %>% 
            html_text() %>% 
            matrix(byrow = TRUE, ncol = 2) %>% 
            as.data.table()
    ))
    Sys.sleep(1)
}
setnames(pcdt, c('PCD', 'PCT'))
pcdt[, `:=`(PCD = trimws(gsub('postcode', '', PCD)), PCT = trimws(gsub('postcode', '', PCT)))]
pcdt <- pcdt[PCT != '']
fwrite(pcdt, './data-raw/csv/lookups/PCDT.csv')

message('\nDownloading missed Post Towns from Wikipedia...')
pcd <- fread('./data-raw/csv/locations/PCD.csv')
# pcdt <- fread('./data-raw/csv/PCDT.csv')
pcdt <- pcdt[pcd, on = 'PCD']
url_pref <- 'http://en.wikipedia.org/wiki'
miss <- unique(pcdt[is.na(PCT), gsub('[0-9]', '', PCD)])
pctw <- data.table(PCD = character(0), PCT = character(0))
for(idx in 1:length(miss)){
    message(' - Processing postcode area ', idx, ' out of ', length(miss))
    y <- data.table(htmltab(
            paste0(file.path(url_pref, miss[idx]), '_postcode_area'), 
            '//*[@id="mw-content-text"]/div/table[2]'
    ))
    y <- y[!grepl('non-geo', Coverage)]
    if(ncol(y) == 4) y <- y[!grepl('non-geo', `Local authority area(s)`)]
    pctw <- rbindlist(list(pctw, y[, 1:2]), use.names = FALSE)
    Sys.sleep(1)
}

message('\nDone! Cleaning results...')

# clean names
pctw[, PCT := paste0( substr(PCT, 1, 1), tolower(substring(PCT, 2)) ) ]

# retain only records with missing PCT names in joint table PCDT
pctw <- pctw[ PCD %in% pcdt[is.na(PCT), PCD]]

# update first table with missing post town names
pcdt[is.na(PCT), PCT := pctw[.SD[['PCD']], .(PCT), on = 'PCD'] ]

# add PCA to duplicate post town names
pcdt[, PCA := gsub('[0-9]', '', substr(PCD, 1, 2))]
pcdt[PCT %in% pcdt[, .N, .(PCT, PCA)][, .N, PCT][N>1, PCT], PCT := paste0(PCT, ' (', PCA, ')')]

# manual table for last update for some districts
# pctw <- data.table(
#     'PCD' = c(paste0('KA', 7:10), paste0('KA', 13:15), paste0('KA', 19:30)),
#     'PCT' = c(
#         'Ayr', 'Ayr', 'Prestwick', 'Troon', 'Kilwinning', 'Beith', 'Beith', 'Maybole', 'Stevenston', 'Saltcoats', 'Ardrossan', 
#         'West Kilbride', 'Dalry', 'Kilbirnie', 'Girvan', 'Isle Of Arran', 'Isle Of Cumbrae', 'Largs', 'Largs'
#     )
# )
# pcdt[is.na(PCT), PCT := pctw[.SD[['PCD']], .(PCT), on = 'PCD'] ]

message('\nCreating IDs and Saving tables as csv...')

# create post town primary key and save table  --------------------------------------------------------------------------------
pct <- unique(pcdt[!is.na(PCT), .(name = PCT)])[order(name)][, .( PCT = paste0('PCT', formatC(1:.N, width = 4, format = 'd', flag = '0')), name)]
fwrite(pct, './data-raw/csv/locations/PCT.csv')

# substitute post towns names with new ids in pcd -------------------------------------------------------------------------------
pcdt <- pct[pcdt, on = c(name = 'PCT')][!is.na(PCT)][, name := NULL]
setcolorder(pcdt, c('PCD', 'ordering', 'PCT'))
fwrite(pcdt[, .(PCD, PCT, ordering)], './data-raw/csv/lookups/PCD_PCT.csv')
fwrite(pcdt[fread('./data-raw/csv/lookups/OA_PCD.csv'), on = 'PCD'][, .(OA, PCT)], './data-raw/csv/lookups/OA_PCT.csv')
if(nrow(pcdt[is.na(PCT)])) 
    warning('CHECK pcd.csv! Not all Post Towns have been found. There still are ', nrow(pcd[is.na(PCT)]), ' missing' )

message('\nBuilding and saving PCT boundaries...')
bnd.pcd <- readRDS(file.path(bnduk_path, 's00', 'PCD'))
bnd.pct <- bnd.pcd |>
                merge(pcdt[, .(PCD, PCT)]) |> 
                rmapshaper::ms_dissolve('PCT')
saveRDS(bnd.pct, file.path(bnduk_path, 's00', 'PCT'))
                
message('\nSimplifying boundaries...')
for(s in seq(10, 50, 10)){
    message(' - ', s, ' %...')
    bnd.pct |> rmapshaper::ms_simplify(s/100) |> saveRDS(file.path(bnduk_path, paste0('s', s), 'PCT'))
}

message('\nBuildin maps for all Postal Types...')
bnd.pca <- readRDS(file.path(bnduk_path, 's10', 'PCA')) |> merge(pca)
bnd.pct <- readRDS(file.path(bnduk_path, 's10', 'PCT')) |> merge(pct)
bnd.pcd <- readRDS(file.path(bnduk_path, 's10', 'PCD'))
bnd.pcs <- readRDS(file.path(bnduk_path, 's10', 'PCS'))
grps = c(
    paste0('Areas (PCA - ', nrow(pca), ')'),
    paste0('Towns (PCT - ', formatC(nrow(pct), big.mark = ','), ')'),
    paste0('Districts (PCD - ', formatC(nrow(pcd), big.mark = ','), ')'),
    paste0('Sectors (PCS - ', formatC(nrow(bnd.pcs), big.mark = ','), ')')
)
ym <- leaflet() |>
        addTiles() |>
        addPolygons(
            data = bnd.pca,
            group = grps[1],
            color = 'black',
            fillOpacity = 0.1,
            label = ~name
        ) |>
        addPolygons(
            data = bnd.pct,
            group = grps[2],
            color = 'magenta',
            fillOpacity = 0.1,
            label = ~name
        ) |>
        addPolygons(
            data = bnd.pcd,
            group = grps[3],
            color = 'blue',
            fillOpacity = 0.1,
            label = ~PCD
        ) |>
        addPolygons(
            data = bnd.pcs,
            group = grps[4],
            color = 'red',
            fillOpacity = 0.1,
            label = ~PCS
        ) |>
        addLayersControl(overlayGroups = grps)

htmlwidgets::saveWidget(ym, paste0('./data-raw/maps/Postal.html'))
system(paste0('rm -r ./data-raw/maps/Postal_files'))

message('\nDownloading villages...')
villages <- data.table('PCD' = character(0), village = character(0))
url_pref <- 'https://www.postcodes-uk.com/'
for(idx in 1:nrow(pcd)){
    message(' - Processing district ', pcd[idx, PCD], ' (', idx, ' out of ', nrow(pcd), ')')
    pcd_vlg <- tryCatch(
        read_html(paste0(url_pref, pcd[idx, PCD], '-postcode-district')) %>%
            html_nodes('.places-list a') %>% 
            html_text()
        , error = function(err) character(0)
    )
    if(length(pcd_vlg) > 0){
        villages <- rbindlist(list(villages, data.table( pcd[idx, PCD], pcd_vlg ) ), use.names = FALSE )
        message('   => Added ', length(pcd_vlg), ' villages (total villages so far: ', nrow(villages), ')')
    }
    Sys.sleep(stats::runif(1, 0.5, 4))
}

message('\nDone!\nAdding PCD with no villages, then saving table as csv...')
y <- pcdt[!(PCD %in% unique(villages$PCD)), .(PCD, PCT)]
y <- pct[y, on = 'PCT'][!is.na(name), .(PCD, village = name)]
villages <- rbindlist( list(villages, y) )
fwrite(villages[order(PCD, village)], './data-raw/csv/locations/villages.csv')

message('\nDONE! Cleaning...')
rm(list = ls())
gc()
