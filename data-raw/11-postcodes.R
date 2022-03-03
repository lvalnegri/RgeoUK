#################################
# UK GEOGRAPHY * 11 - POSTCODES #
#################################

dmpkg.funs::load_pkgs(dmp = FALSE, c('data.table', 'dplyr', 'rmapshaper', 'sf'))

ons_id <- '3cee8796c4aa408581c55361a5ddc967'

pc_path <- file.path(ext_path, 'uk', 'geography', 'postcodes')

message('\nLoading OA boundaries...\n')
bnd.oa <- readRDS(file.path(bnduk_path, 's00', 'OAgb'))

message('\nDownloading ONSPD zip file...\n')
tmpf <- tempfile()
download.file(paste0('https://www.arcgis.com/sharing/rest/content/items/', ons_id, '/data'), destfile = tmpf)
fname <- unzip(tmpf, list = TRUE)
fname <- fname[order(fname$Length, decreasing = TRUE), 'Name'][1]

message('Extracting csv file...')
unzip(tmpf, files = fname, exdir = pc_path, junkpaths = TRUE)
unlink(tmpf)
system(paste0('mv ', pc_path, '/', basename(fname), ' ',  pc_path, '/ONSPD.csv'))

message('Loading ONSPD data...')
pc <- fread(
    file.path(pc_path, 'ONSPD.csv'), 
        select = c('pcd', 'osgrdind', 'doterm', 'usertype', 'long', 'lat', 'oa11', 'rgn', 'ctry'),
        col.names = c('PCU', 'osgrdind', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA', 'RGN', 'CTRY'),
    na.string = '',
    key = 'PCU'
)

message('Building lookalike tables as Table 1 in User Guide:')
message(' + Total dataset...')
print(pc[, .N, CTRY][order(CTRY)])
message(' + Total UK...')
print(pc[!(CTRY %in% c('L93000001', 'M83000003')), .N])
message(' + By user type: 0-Small / 1-Large users for the whole dataset...')
print(pc[, .N, usertype][order(usertype)])
message(' + By user type: 0-Small / 1-Large users, Total UK ...')
print(pc[!(CTRY %in% c('L93000001', 'M83000003')), .N, usertype])

message('Deleting postcodes without grid reference (osgrdind == 9, deletes also GI/IM), then reorder by OA and PCU...')
pc <- pc[osgrdind < 9][, osgrdind := NULL][order(OA, PCU)]
message(' + Countries by usertypes (Table 3)...')
print(dcast(pc, CTRY~usertype))

message('Recoding "is_active" as binary 0/1 (Table 4)...')
pc[, is_active := ifelse(is.na(is_active), 1, 0)]
message(' + Countries by active vs. terminated...')
print(dcast(pc, CTRY~is_active))

message('Setting "is_active" = 1 for all postcodes in output areas that only include inactive pc...')
pc[!OA %in% unique(pc[is_active == 1, OA]), is_active := 1]
print(dcast(pc, CTRY~is_active))

message('Set PCD AB1/AB2/AB3 as terminated...')
pc[substr(PCU, 1, 4) %in% paste0('AB', 1:3, ' '), is_active := 0]

message('Calculate PC Sectors codes from postcodes...')
pc[is_active == 1, PCS := substr(PCU, 1, 5) ]

message('Deleting records associated witn non-geographic PC Sectors...')
message(' - Number of OAs before deletion: ', unique(pc[is_active == 1, .(OA)])[,.N])
ng <- read.csv('./data-raw/csv/locations/pcs_non_geo.csv')
pc <- pc[!PCS %in% ng$PCS]
message(' - Number of OAs after deletion: ', unique(pc[is_active == 1, .(OA)])[,.N])

message('Fixing CTRY and RGN...')
pc[, CTRY := substr(CTRY, 1, 1)]
ctry <- data.table( 'old' = c('E', 'W', 'S', 'N'), 'CTRY' = c('ENG', 'WLS', 'SCO', 'NIE') )
pc <- ctry[pc, on = c(old = 'CTRY')][, old := NULL]
pc[substr(RGN, 1, 1) != 'E', RGN := paste0(CTRY, '_RGN')]

message('Saving a geographic WGS84 version...')
pcg <- pc[, .(PCU, x_lon, y_lat, is_active, PCS, OA, RGN, CTRY)]
pcg <- st_as_sf(pcg, coords = c('x_lon', 'y_lat'), crs = 4326)
saveRDS(pcg, file.path(geouk_path, 'postcodes.geo'))
pcg <- pcg |> st_transform(27700)

message('Attach a postcode sector to missing OA...')
oas <- fread('./data-raw/csv/lookups/OA_LSOA_MSOA.csv', select = 'OA')
noa <- oas[!OA %in% unique(pc[is_active == 1, OA])][order(OA)]
pcgn <- pcg |> filter(is_active == 1)
y <- st_nearest_feature(bnd.oa |> filter(OA %in% noa$OA), pcgn)
noa <- cbind(noa, pcgn[y,] |> select(PCS) |> st_drop_geometry() |> as.data.table())
fwrite(noa, './data-raw/csv/lookups/missing_OAs.csv')

message('\nBuilding OA-PCS lookups...')
ypi <- pc[is_active == 1, .N, .(OA, PCS, RGN)][order(OA, -N)]
yp <- ypi[ypi[, .I[which.max(N)], OA]$V1][, N := NULL]
ypn <- unique(pc[is_active == 1 & !PCS %chin% unique(yp$PCS), .(OA, PCS)])
for(xp in unique(ypn$PCS)){
    for(xo in ypi[PCS == xp][order(-N)][, OA]){
        xop <- yp[OA == xo, PCS]
        xpo <- yp[PCS == xop]
        if(nrow(xpo) > 1){
            yp[OA == xo, PCS := xp]
            break
        }
    }
}
yp <- rbindlist(list( yp, unique(yp[PCS %chin% noa$PCS, .(PCS, RGN)])[noa, on = 'PCS'][, .(OA, PCS, RGN)] ))[order(OA)]
ypk <- yp[, .(OA, PCS)]
ypk[, PCD := gsub(' .*', '', substr(PCS, 1, 4)) ]
ypk[, PCA := sub('[0-9]', '', substr(PCS, 1, gregexpr("[[:digit:]]", PCS)[[1]][1] - 1) ) ]
fwrite(ypk[, .(OA, PCS)], './data-raw/csv/lookups/OA_PCS.csv')
fwrite(ypk[, .(OA, PCD)], './data-raw/csv/lookups/OA_PCD.csv')
fwrite(ypk[, .(OA, PCA)], './data-raw/csv/lookups/OA_PCA.csv')
fwrite(pc[is_active & !PCS %chin% unique(ypk$PCS)], './data-raw/csv/lookups/missing_PCS.csv')

message('Adding correct order to PC Districts and save as csv file...')
pcd <- unique(ypk[, .(PCD)])[order(PCD)]
pcd[, `:=`( 
    PCDa = regmatches(pcd$PCD, regexpr('[a-zA-Z]+', pcd$PCD)), 
    PCDn = as.numeric(regmatches(pcd$PCD, regexpr('[0-9]+', pcd$PCD))) 
)]
pcd <- pcd[order(PCDa, PCDn)][, ordering := 1:.N][, .(PCD, ordering)]
fwrite(pcd, file.path('./data-raw/csv/locations/PCD.csv'))

message('Adding correct order to PC Sectors and save as csv file...')
pcs <- unique(ypk[, .(PCD, PCS)])[order(PCS)]
pcs <- pcs[pcd, on = 'PCD']
pcs <- pcs[order(ordering, PCS)][, ordering := 1:.N][, .(PCS, ordering)]
fwrite(pcs, file.path('./data-raw/csv/locations/PCS.csv'))

message('\nBuilding PCS boundaries...')
bnd.oa <- bnd.oa |> merge(yp)
bnd.pcs <- do.call('rbind', lapply(unique(bnd.oa$RGN), \(x) bnd.oa |> filter(RGN == x) |> ms_dissolve('PCS'))) |> 
                ms_dissolve('PCS') |> 
                st_transform(4326) |>
                st_make_valid()
saveRDS(bnd.pcs, file.path(bnduk_path, 's00', 'PCS'))

message('\nBuilding and saving PCD-PCA boundaries...')
bnd.pcd <- bnd.pcs |> merge(unique(ypk[, .(PCS, PCD)])) |> ms_dissolve('PCD')
saveRDS(bnd.pcd, file.path(bnduk_path, 's00', 'PCD'))
bnd.pca <- bnd.pcd |> merge(unique(ypk[, .(PCD, PCA)])) |> ms_dissolve('PCA')
saveRDS(bnd.pca, file.path(bnduk_path, 's00', 'PCA'))

message('\nSimplifying boundaries...')
for(s in seq(10, 50, 10)){
    message(' - ', s, ' %...')
    message('   * PCS')
    bnd.pcs |> ms_simplify(s/100) |> saveRDS(file.path(bnduk_path, paste0('s', s), 'PCS'))
    message('   * PCD')
    bnd.pcd |> ms_simplify(s/100) |> saveRDS(file.path(bnduk_path, paste0('s', s), 'PCD'))
    message('   * PCA')
    bnd.pca |> ms_simplify(s/100) |> saveRDS(file.path(bnduk_path, paste0('s', s), 'PCA'))
}

message('\nReworking PCU-PCS for entire postcodes...')
y <- rbindlist(list( pc[is_active == 1, .(PCU, PCS)], ypk[, .(OA, PCS)][pc[is_active == 0, .(PCU, OA)], on = 'OA'][, .(PCU, PCS)]))
pc <- y[pc[, PCS := NULL], on = 'PCU']

message('Recoding char columns as factors...')
setcolorder(pc, c('PCU', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA', 'PCS', 'RGN', 'CTRY'))
cols <- c('OA', 'PCS', 'RGN', 'CTRY')
pc[, (cols) := lapply(.SD, factor), .SDcols = cols]

message('Saving postcodes with various indices...')
setorderv(pc, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'))
write_fst_idx('postcodes', c('is_active', 'PCS'), pc, geouk_path)
fwrite(pc, './data-raw/postcodes.csv')
zip('./data-raw/csv/locations/postcodes.zip', './data-raw/postcodes.csv')
file.remove('./data-raw/postcodes.csv')

message('Saving a lookalike Table 2 User Guide (remember that now postcodes without grid have been deleted)...')
pc <- ypk[pc[, PCS := NULL], on = 'OA']
pca <- rbindlist(list(
    pc[, .(
        PCD = uniqueN(PCD), 
        PCS = uniqueN(PCS), 
        live = sum(is_active), 
        terminated = sum(!is_active), 
        total = .N
    ), PCA][order(PCA)],
    pc[, .(
        PCA = 'TOTAL UK', 
        PCD = uniqueN(PCD), 
        PCS = uniqueN(PCS), 
        live = sum(is_active), 
        terminated = sum(!is_active), 
        total = .N
    )]        
))
fwrite(pca, './data-raw/csv/locations/pca_totals.csv')

message('DONE! Cleaning...')
rm(list = ls())
gc()
.rs.restartR()
