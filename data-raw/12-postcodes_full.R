#############################################
# UK GEOGRAPHY * 11b - POSTCODES FULL TABLE #
#############################################

dmpkg.funs::load_pkgs(dmp = FALSE, c('data.table'))

y <- fread(
  file.path(ext_path, 'uk', 'geography', 'postcodes', 'ONSPD.csv'), 
    select = c(
       'pcd', 'lsoa11', 'msoa11', 'oslaua', 'oscty',
       'ttwa', 'osward', 'pcon', 'ced', 'parish', 'bua11', 'buasd11', 'wz11',
       'pfa', 'ccg', 'stp', 'nhser'
    ),
    col.names = c('PCU', 'LSOA', 'MSOA', 'LAD', 'CTY', 'TTWA', 'WARD', 'PCON', 'CED', 'PAR', 'BUA', 'BUAS', 'WPZ', 'PFA', 'CCG', 'STP', 'NHSR'),
    na.string = '',
    key = 'PCU'
)
yx <- fst::read_fst(file.path(geouk_path, 'postcodes'), as.data.table = T)
yn <- names(yx)
y <- y[yx, on = 'PCU']
setcolorder(y, yn)

setorderv(y, c('is_active', 'CTRY', 'RGN', 'PCS', 'OA', 'PCU'))
write_fst_idx('postcodes.full', c('is_active', 'PCS'), y, geouk_path)
