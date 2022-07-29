#######################################
# UK GEOGRAPHY * 22 - Workplace Zones #
#######################################

# load packages 
pkgs <- c('dmpkg.funs', 'data.table', 'fst', 'leaflet', 'sp')
invisible(lapply(pkgs, require, char = TRUE))

# load output areas
oas <- read_fst(file.path(geouk_path, 'output_areas'), columns = c('MSOA', 'LAD', 'CTY', 'RGN', 'CTRY'), as.data.table = TRUE)
oas <- unique(oas)

### WPZ ==> MSOA (ESW) --------------------------
gb <- build_lookups_table('WPZ', 'MSOA', filter_country = c('ENG', 'SCO', 'WLS'))
gb <- gb[, 1:2]

# check WPZ. ENG: 50,868 [-32], SCO: 5,375 [-1], WLS: 2,710 [X] 
gb[, .N, substr(WPZ, 1, 3)]

# check MSOA. ENG: 6,791 [X], SCO: 1,279 [-1], WLS: 410 [X]
gb[, .N, MSOA][, .N, substr(MSOA, 1, 3)]

# find missing WPZ using terminated postcodes
wpz <- readRDS(file.path(bnduk_spath, 'WPZ'))
wpz.na <- subset(wpz, substr(wpz$id, 1, 1) %in% c('E', 'S'))
wpz.na <- subset(wpz.na, !wpz.na$id %in% gb$WPZ)
pc <- read_fst_idx(file.path(geouk_path, 'postcodes'), 0, c('PCU', 'WPZ', 'MSOA'))
wpz.na <- pc[WPZ %in% wpz.na$id][, .N, .(WPZ, MSOA)][order(-N)][, .SD[1], WPZ][, .(WPZ, MSOA)]

# bind all together
gb <- rbindlist(list( gb, wpz.na ))

# additional WPZ missing are checked by hand ('E33003414' Blackpool => E02002642, 'E33009058' Doncaster => E02001560)
# wpz.na <- subset(wpz.na, !wpz.na$id %in% gb$WPZ)
# msoa <- readRDS(file.path(bnduk_spath, 'MSOA'))
# msoa <- subset(msoa, substr(msoa$id, 1, 1) == 'E')
# leaflet() %>% 
#     addProviderTiles(providers$Stamen.Toner) %>% 
#     addPolygons(data = msoa, label = ~id) %>%
#     addPolygons(data = wpz.na, color = 'red', label = ~id)
gb <- rbindlist(list( gb, data.table( wpz.na$id, c('E02002642', 'E02001560') ) ), use.names = FALSE)

# additional MSOA missing ('S02002054' Edinburgh => S34001916)
# msoa <- readRDS(file.path(bnduk_spath, 'MSOA'))
# msoa.na <- subset(msoa, msoa$id %in% oas[CTRY == 'SCO' & !MSOA %in% unique(gb$MSOA), as.character(MSOA)])
# leaflet() %>%
#     addProviderTiles(providers$Stamen.Toner) %>%
#     addPolygons(data = wpz, label = ~id) %>%
#     addPolygons(data = msoa.na, color = 'red', label = ~id)
gb[WPZ == 'S34001916', MSOA := 'S02002054']

# attach higher geographies
gb <- oas[gb, on = 'MSOA']


### WPZ ==> LAD (N) -----------------------------
nie <- build_lookups_table('WPZ', 'LAD', filter_country = 'NIE', save_results = TRUE)
nie <- nie[, 1:2]

# check WPZ 1756 [-1]
nie[, .N, substr(WPZ, 1, 3)]

# check LAD 11 [X]
nie[, .N, LAD][, .N, substr(LAD, 1, 3)]

# find missing WPZ using terminated postcodes
wpz <- readRDS(file.path(bnduk_spath, 'WPZ'))
wpz.na <- subset(wpz, substr(wpz$id, 1, 1) == 'N')
wpz.na <- subset(wpz.na, !wpz.na$id %in% nie$WPZ)
pc <- read_fst_idx(file.path(geouk_path, 'postcodes'), 0, c('PCU', 'WPZ', 'LAD'))
wpz.na <- pc[WPZ %in% wpz.na$id][, .N, .(WPZ, LAD)][order(-N)][, .SD[1], WPZ][, .(WPZ, LAD)]

# bind all together
nie <- rbindlist(list( nie, wpz.na ))

# attach higher geographies
nie <- oas[nie, on = 'LAD']

# bind gb and nie together
setcolorder(gb, 'WPZ')
setcolorder(nie, names(gb))
uk <- rbindlist(list( gb, nie ))

# save
write_fst_idx('workplace_zones', c('RGN', 'LAD'), uk, geouk_path)

# clean and exit
rm(list = ls())
gc()
