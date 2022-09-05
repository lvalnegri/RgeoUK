#################################
# UK GEOGRAPHY * 11 - POSTCODES #
#################################

Rfuns::load_pkgs('data.table', 'qs', 'rmapshaper', 'sf')
setDTthreads(12)

ons_id <- '8e0d123a946240288c3c84cf9f9cba28'
down <- FALSE

pc_path <- file.path(ext_path, 'uk', 'geography', 'postcodes')

if(down){
    message('\nDownloading ONSPD zip file...\n')
    tmpf <- tempfile()
    download.file(paste0('https://www.arcgis.com/sharing/rest/content/items/', ons_id, '/data'), destfile = tmpf)
    fname <- unzip(tmpf, list = TRUE)
    fname <- fname[order(fname$Length, decreasing = TRUE), 'Name'][1]
    
    message('Extracting csv file...')
    unzip(tmpf, files = fname, exdir = pc_path, junkpaths = TRUE)
    unlink(tmpf)
    system(paste0('mv ', pc_path, '/', basename(fname), ' ',  pc_path, '/ONSPD.csv'))
}

message('Loading ONSPD data...')
pc <- fread(
        file.path(pc_path, 'ONSPD.csv'), 
        select = c('pcd', 'osgrdind', 'doterm', 'usertype', 'long', 'lat', 'oa11', 'oa21', 'rgn', 'ctry', 'wz11'),
        col.names = c('PCU', 'osgrdind', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA', 'OA21', 'RGN', 'CTRY', 'WPZ'),
        na.string = '',
        key = 'PCU'
)

message('Building lookalike tables as Table 1 and 3 in User Guide:')
message(' + Total dataset')
rbind(pc[, .N, CTRY][order(CTRY)], pc[, .(CTRY = '==TOTAL==', .N)])
pc <- pc[!(CTRY %in% c('L93000001', 'M83000003'))]
message('Total UK')
print(pc[, .N])
message(' + By user type (0-Small / 1-Large users)')
print(pc[, .N, usertype][order(usertype)])
message(' + By country and user type')
print(dcast(pc[, .N, .(usertype, CTRY)], CTRY~usertype))
message(' + By grid, country and user type, with count and percentage')
print(
    dcast(
        pc[, (Nct =.N),  .(usertype, CTRY)
           ][pc[, .N, .(osgrdind, usertype, CTRY)], on = c('usertype', 'CTRY')
             ][, pct := round(100 * N /V1, 2)][, V1 := NULL], 
        osgrdind~CTRY+usertype, 
        value.var = c('N', 'pct'), 
        fill = 0
    )
)

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
pcg <- pc[, .(PCU, x_lon, y_lat, is_active, PCS, OA, RGN, CTRY, WPZ)]
pcg <- st_as_sf(pcg, coords = c('x_lon', 'y_lat'), crs = 4326)
qsave(pcg, file.path(geouk_path, 'postcodes.geo'), nthreads = 12)
message('Reprojecting using OSGB36 / British National Grid, epsg 27700...')
pcg <- pcg |> st_transform(27700)

message('Attach a postcode sector to missing OA...')
bnd.oa <- qread(file.path(bnduk_path, 's00', 'OAgb'), nthreads = 12)
oas <- fread('./data-raw/csv/lookups/OA_LSOA_MSOA.csv', select = 'OA')
noa <- oas[!OA %in% unique(pc[is_active == 1, OA])][order(OA)]
pcgn <- pcg |> dplyr::filter(is_active == 1)
y <- st_nearest_feature(bnd.oa |> subset(OA %in% noa$OA), pcgn)
noa <- data.table(noa, pcgn[y,] |> subset(select = PCS) |> st_drop_geometry())
fwrite(noa[order(OA)], './data-raw/csv/lookups/missing_OAs.csv')

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

message('\nReworking PCU-PCS for entire postcodes...')
y <- rbindlist(list( pc[is_active == 1, .(PCU, PCS)], ypk[, .(OA, PCS)][pc[is_active == 0, .(PCU, OA)], on = 'OA'][, .(PCU, PCS)]))
pc <- y[pc[, PCS := NULL], on = 'PCU']

message('\nSaving a linkage between PCS/D old and new for terminated PCU...')
pcsa <- unique(ypk[, .(PCS.old = PCS, PCS)])
pcst <- pc[is_active == 0, .(PCU, PCS, PCS.old = gsub(' .*', '', substr(PCU, 1, 5)))
            ][!PCS.old %in% pcsa$PCS][, .N, .(PCS.old, PCS)][order(PCS.old, -N)]
pcst <- pcst[pcst[, .I[which.max(N)], PCS.old]$V1][, N := NULL]
fwrite(rbindlist(list( pcsa, pcst ))[order(PCS.old)], './data-raw/csv/lookups/PCS_linkage.csv')
pcda <- unique(ypk[, .(PCD.old = PCD, PCD)])
pcdt <- ypk[, .(OA, PCD)
           ][pc[is_active == 0, .(PCU, OA)], on = 'OA'
             ][, PCD.old := gsub(' .*', '', substr(PCU, 1, 4))
               ][!PCD.old %in% pcda$PCD][, .N, .(PCD.old, PCD)][order(PCD.old, -N)]
pcdt <- pcdt[pcdt[, .I[which.max(N)], PCD.old]$V1][, N := NULL]
fwrite(rbindlist(list( pcda, pcdt ))[order(PCD.old)], './data-raw/csv/lookups/PCD_linkage.csv')

message('Recoding char columns as factors...')
setcolorder(pc, c('PCU', 'is_active', 'usertype', 'x_lon', 'y_lat', 'OA', 'PCS', 'RGN', 'CTRY', 'WPZ'))
cols <- c('OA', 'PCS', 'RGN', 'CTRY', 'WPZ')
pc[, (cols) := lapply(.SD, factor), .SDcols = cols]

message('Saving postcodes in fst format and into database...')
setorderv(pc, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'))
write_fst_idx('postcodes', c('is_active', 'PCS'), pc, geouk_path)
dd_dbm_do('geography_uk', 'w', 'postcodes', pc)

message('Saving postcodes as zipped csv...')
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

message('Processing FULL postcodes dataset...')
message(' - Reading csv file...')
y <- fread(
    file.path(pc_path, 'ONSPD.csv'), 
    select = c(
       'pcd', 'lsoa11', 'msoa11', 'oslaua', 'oscty', 'parish',
       'pcon', 'osward', 'ced', 'ttwa', 'bua11', 'buasd11', 'pfa', 'ccg', 'stp', 'nhser'
    ),
    col.names = c(
        'PCU', 'LSOA', 'MSOA', 'LAD', 'CTY', 'PAR',
        'PCON', 'WARD', 'CED', 'TTWA', 'BUA', 'BUAS', 'PFA', 'CCG', 'STP', 'NHSR'
    ),
    na.string = '',
    key = 'PCU'
)
y <- y[pc, on = 'PCU']
setcolorder(y, names(pc))

message(' - Saving as fst...')
setorderv(y, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'))
write_fst_idx('postcodes.full', c('is_active', 'PCS'), y, geouk_path)

message('DONE! Cleaning...')
rm(list = ls())
gc()
.rs.restartR()
