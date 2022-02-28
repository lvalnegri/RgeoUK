#################################################
# UK GEOGRAPHY * 21- BUILD POLICE NEIGHBOURHOOD #
#################################################

dmpkg.funs::load_pkgs(dmp = FALSE, c('data.table', 'dplyr', 'fst', 'jsonlite', 'leaflet', 'rmapshaper', 'rvest', 'sf'))

sf_use_s2(FALSE)

pfo_path <- file.path(ext_path, 'uk', 'police_neighbourhood')
zfile <- file.path(pfo_path, 'KML.zip')
if(dir.exists(pfo_path)) system(paste('rm -r', pfo_path))
dir.create(pfo_path)

message('Processing PFA data...')
pfa <- fread('./data-raw/csv/locations/PFA.csv', na.strings = '')
pfa <- pfa[!is.na(PFAid)]

message('Reading PFN datasets...')
pfn <- rbindlist(
    lapply(
        1:nrow(pfa), 
        function(idx){
            message('Adding PFN from: ', pfa[idx, PFAn] )
            y <- fromJSON(paste0('https://data.police.uk/api/', pfa[idx, PFAid], '/neighbourhoods'))
            data.table(pfa[idx, PFA], y)
        }
    )
)
setnames(pfn, c('PFA', 'PFNid', 'PFNn'))

message('Cleaning PFN datasets...')
# delete duplicates: one of each of "Gravesham - Pelham" and "Gravesham - Central" c('E23000032_090', 'E23000032_099')  <================= CHECK BEFORE RUN 
pfn <- pfn[!(PFA == 'E23000032' & grepl('^Gravesham.*Pelham$|Gravesham.*Central$', PFNn) & !PFNid %in% c(169, 179))]

# delete parent areas                                                                                                   <================= CHECK BEFORE RUN 
pfn <- pfn[!(PFA == 'W15000003' & substr(PFNid, 1, 1) != 'W')]

# add Heathrow
pfn <- rbindlist(list( pfn, data.table( 'E23000001', 'SATST9', 'Heathrow NON Terminals') ), use.names = FALSE)

# create id and save
setorderv(pfn, c('PFA', 'PFNn', 'PFNid'))
pfn[, PFN := paste0(PFA, '_', stringr::str_pad(1:.N, 3, 'left', '0')), PFA]
fwrite(pfn, './data-raw/csv/locations/PFN.csv')
fwrite(pfn[, .(PFN, PFA)], paste0('./data-raw/csv/lookups/PFN_PFA.csv'))

message('Loading boundaries zip file...')
y <- read_html('https://data.police.uk/data/boundaries/') %>% 
        html_nodes('.neighbourhood_kmls a') %>% 
        html_attr('href') 
download.file(paste0('https://data.police.uk', y[1]), zfile)

message('Extracting KML files...')
unzip(zfile, exdir = pfo_path)

message('Fixing file names and location codes...')
fnames <- data.table(fname = dir(pfo_path, full.names = TRUE, recursive = TRUE))
fnames[, `:=`( PFAid = sub(".*/(.*)/.*", "\\1", fname), PFNid = sub(".*/(.*)\\.kml", "\\1", fname) )]
fnames <- pfa[, .(PFAid, PFA)][fnames, on = 'PFAid'][!is.na(PFA)]
fnames <- fnames[pfn[, .(PFA, PFNid, PFN)], on = c('PFA', 'PFNid')][order(PFN)]
fnames <- fnames[!is.na(PFAid)]

message('Converting KML files into one single `sf` feature...')
nbnd <- do.call('rbind', lapply(1:nrow(fnames), \(x) st_read(fnames[x]$fname, quiet = TRUE) %>% select(PFN = 1) %>% mutate(PFN = fnames[x]$PFN)))

message('Deleting `Z` coordinates...')
nbnd <- st_zm(nbnd) |> st_make_valid() |> st_transform(27700) |> st_cast('MULTIPOLYGON')

message('Fixing holes and duplication...')
yo <- nbnd |> st_covered_by()
yo <- unlist(yo[which(sapply(yo, length) > 1)])
if(!is.null(yo)){
    yo <- as.data.table(matrix(yo, ncol = 2, byrow = TRUE))
    if(anyDuplicated(yo)){
        yd <- yo[duplicated(yo)]
        for(idx in 1:nrow(yd)){
            message(' * polygons ',paste(yd[idx], collapse = ' and '), ' are duplicated')
        }
        yo <- yo[!(duplicated(yo, fromLast = TRUE) | duplicated(yo))]
    }
    if(nrow(yo)){
        for(idx in 1:nrow(yo)){
            yoa <- nbnd[paste(yo[idx]),] |> st_area() |> as.numeric()
            yx <- st_difference(
                    nbnd[yo[idx, get(names(yo)[which.max(yoa)])],], 
                    nbnd[yo[idx, get(names(yo)[which.min(yoa)])],]  
            ) |> select(PFN)
            st_geometry(nbnd)[yo[idx, get(names(yo)[which.max(yoa)])]] <- st_geometry(yx)
        }
    }
}

message('Saving first version...')
st_write(nbnd, './data-raw/shp/PFN.shp', append = FALSE)
saveRDS(merge(nbnd, pfn[, .(PFN, PFNn)]), './data-raw/shp/PFN')

message('Calculating OA lookups...')
bnd.oa <- readRDS(file.path(bnduk_path, 's00', 'OAgb'))
bnd.oa <- merge(bnd.oa, fread('./data-raw/csv/lookups/OA_RGN.csv'))
bnd.oa <- bnd.oa |> filter(RGN != 'SCO_RGN')
yc <- st_covered_by(bnd.oa, nbnd)
for(x in which(sapply(yc, length) > 1)) yc[[x]] <- yc[[x]][1]
yc <- as.numeric(yc)
yc <- data.table( bnd.oa |> st_drop_geometry(),  nbnd[yc, 'PFN'] |> st_drop_geometry() )
yc[, RGN := NULL]
message('   > recovering ', formatC(yc[is.na(PFN), .N], big.mark = ','), ' missing OA lookups...')
for(idx in 1:nrow(yc)){
    if(is.na(yc[idx, PFN])){
        yct <- unlist(st_intersects(bnd.oa[idx,], nbnd))
        yct <- yct[which.max(as.numeric(st_area(st_intersection(bnd.oa[idx,], nbnd[yct,]))))]
        yc[idx, PFN := nbnd[yct, 'PFN'] |> st_drop_geometry()]
    }
}
yc[grepl('char', PFN), PFN := NA]

# check (manually, visually) which PFN for missing OAs
ycn <- yc[is.na(PFN)][, .(OA)]
bnd.ycn <- bnd.oa |> filter(OA %in% ycn$OA)
bfr.ycn <- st_buffer( bnd.ycn, 10000 ) |> st_union()
leaflet() |> 
    addTiles() |> 
    addPolygons( 
        data = bnd.ycn |> st_transform(4326), 
        group = 'OA (red)', 
        color = 'red', 
        weight = 6, 
        label = ~OA
    ) |> 
    addPolygons( 
        data = bnd.pcn[unlist(st_intersects(bfr.ycn, bnd.pcn)),]|> st_transform(4326), 
        group = 'PFN (black)', 
        weight = 2, 
        fillOpacity = 0, 
        color = 'black',
        label = ~PFN
    ) |>
    addLayersControl(overlayGroups = c('OA (red)', 'PFN (black)'))

# ycn[, PFN := c(
#     'E23000033_035', 'E23000033_241', 'E23000033_187', 'E23000033_047', 'E23000033_047', 'E23000033_034',
#     '', '', '', '', '', '', '', '', 
# )]


message('Adding Scotland OA lookups...')
lkp <- fread('./data-raw/csv/lookups/WARD_PFN_LAD_SCO.csv')
lkpw <- fread('./data-raw/csv/lookups/OA_WARD.csv')
yc <- rbindlist(list( yc, lkpw[lkp[, .(WARD, PFN)], on = 'WARD'][, WARD := NULL] ))
fwrite(yc, './data-raw/csv/lookups/OA_PFN.csv')

message(' * Building PFN+PFA boundaries from OA lookups...')
y <- merge(bnd.oa, yc)
yn <- do.call( 'rbind', lapply( unique(y$RGN), \(x) y |> filter(RGN == x) |> ms_dissolve('PFN') ) ) |> st_transform(4326)
saveRDS(yn, file.path(bnduk_path, 's00', 'PFN'))
ya <- yn |> merge(pfn[, .(PFN, PFA)]) |> ms_dissolve('PFA')
saveRDS(ya, file.path(bnduk_path, 's00', 'PFA'))

message(' * Simplifying boundaries...')
for(s in seq(10, 50, 10)){
    message('   > ', s, '%')
    saveRDS(ms_simplify(yn, s/100), file.path(bnduk_path, paste0('s', s), 'PFN'))
    saveRDS(ms_simplify(ya, s/100), file.path(bnduk_path, paste0('s', s), 'PFA'))
}

message(' * Creating comparison maps...')
ym <- leaflet() |>
        addTiles() |>
        addPolygons(
            data = merge(yn |> ms_simplify(), pfn),
            group = 'package',
            color = 'black',
            fillOpacity = 0.2,
            label = ~PFNn
        ) |>
        addPolygons(
            data = merge(nbnd |> st_transform(4326) |> ms_simplify(), pfn), 
            group = 'original',
            color = 'red', 
            fillOpacity = 0.2,
            label = ~PFNn
        ) |>
        addLayersControl(overlayGroups = c('package', 'original'))
htmlwidgets::saveWidget(ym, paste0('./data-raw/maps/PFN.html'))
system(paste0('rm -r ./data-raw/maps/PFN_files'))

# clean and Exit --------------------------------
message('Clean and Exit...')
system(paste('rm -R', pfo_path))
rm(list = ls())
gc()
