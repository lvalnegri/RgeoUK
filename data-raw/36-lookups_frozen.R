##################################################
# UK GEOGRAPHY * 36 - Lookups+Names FROZEN TYPES #
##################################################

library('data.table')

# OA > LSOA > MSOA: EWSN

## lookups
y1 <- fread(
        './data-raw/csv/ons/OA11_LSOA11_MSOA11-EW.csv', 
        select = c('OA11CD', 'LSOA11CD', 'MSOA11CD'), 
        col.names = c('OA', 'LSOA', 'MSOA') 
)
y2 <- fread('./data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.csv')
y3 <- fread('./data-raw/csv/ons/OA11_LSOA11-NIE.csv')
y3[, MSOA := paste0('96', substring(SOA, 3))]
y <- rbindlist(list( y1, y2, y3 ), use.names = FALSE)
y <- y[order(OA)]
fwrite(y[, .(OA, LSOA)], './data-raw/csv/lookups/OA_LSOA.csv')
fwrite(y[, .(OA, MSOA)], './data-raw/csv/lookups/OA_MSOA.csv')

## locations
y1 <- fread('./data-raw/csv/ons/OA11_LSOA11_MSOA11-EW.csv', select = c('LSOA11CD', 'LSOA11NM'), col.names = c('LSOA', 'LSOAn') )
y2 <- fread('./data-raw/csv/ons/LSOA11-SCO.csv')
y3 <- fread('./data-raw/csv/ons/LSOA11-NIE.csv')
y <- rbindlist(list( y1, y2, y3 ), use.names = FALSE)
fwrite(y[order(LSOA)], './data-raw/csv/locations/LSOA.csv')

y1 <- fread( './data-raw/csv/ons/MSOA_names.csv', select = c('msoa11cd', 'msoa11hclnm'), col.names = c('MSOA', 'MSOAn') )
y2 <- fread('./data-raw/csv/ons/MSOA11-SCO.csv')
y <- rbindlist(list( y1, y2, y3 ), use.names = FALSE)
y[substr(MSOA, 1, 2) == '95', MSOA := paste0('96', substring(MSOA, 3))]
fwrite(y[order(MSOA)], './data-raw/csv/locations/MSOA.csv')

## OA > CTRY
y <- fread('./data-raw/csv/lookups/OA_LSOA.csv')
ctry <- data.table( 'ct' = c('E', 'W', 'S', 'N'), 'CTRY' = c('ENG', 'WLS', 'SCO', 'NIE') )
y <- y[, .(OA, ct = substr(OA, 1, 1))][ctry, on = 'ct'][, ct := NULL][]
fwrite(y, './data-raw/csv/lookups/OA_CTRY.csv')
fwrite(
  data.table( 
      'CTRY' = c('ENG', 'WLS', 'SCO', 'NIE'), 
      'CTRYn' = c('England', 'Wales', 'Scotland', 'N.Ireland') 
  ), 
  './data-raw/csv/locations/CTRY.csv'
)

## OA > TTWA: EWSN
y <- na.omit(fread('./data-raw/csv/ons/LSOA11_TTWA11-UK.csv', na.strings = ''))
fwrite(unique(y[, .(TTWA = TTWA11CD, TTWAn = TTWA11NM)][order(TTWA)]), './data-raw/csv/locations/TTWA.csv')
yo <- fread('./data-raw/csv/lookups/OA_LSOA.csv')
fwrite(y[, .(LSOA = LSOA11CD, TTWA = TTWA11CD)][yo, on = 'LSOA'][, .(OA, TTWA)][order(OA)], './data-raw/csv/lookups/OA_TTWA.csv')

## OA > MTC: EW
y <- fread('./data-raw/csv/ons/OA11_MTC15-EW.csv', na.strings = '')
fwrite(y[, .(OA = OA11CD, MTC = TCITY15CD)][!is.na(MTC)][order(OA)], './data-raw/csv/lookups/OA_MTC.csv')
fwrite(unique(y[, .(MTC = TCITY15CD, MTCn = TCITY15NM)][!is.na(MTC)][order(MTC)]), './data-raw/csv/locations/MTC.csv')

## OA > BUAS > BUA: EW
y <- fread('./data-raw/csv/ons/OA11_BUAS11_BUA11-EW.csv', na.strings = '')
fwrite(y[, .(OA = OA11CD, BUAS = BUASD11CD)][!is.na(BUAS)][order(BUAS)], './data-raw/csv/lookups/OA_BUAS.csv')
fwrite(y[, .(OA = OA11CD, BUA = BUA11CD)][!is.na(BUA)][order(BUA)], './data-raw/csv/lookups/OA_BUA.csv')
fwrite(unique(y[, .(BUAS = BUASD11CD, BUASn = BUASD11NM)])[!is.na(BUAS)][order(BUAS)], './data-raw/csv/locations/BUAS.csv')
fwrite(unique(y[, .(BUA = BUA11CD, BUAn = BUA11NM)])[!is.na(BUA)][order(BUA)], './data-raw/csv/locations/BUA.csv')

## WPZ > MSOA: EWSN
y <- fread('./data-raw/csv/ons/WPZ11_MSOA11-EWS.csv', na.strings = '')
fwrite(y[, .(WPZ = WZ11CD, MSOA = MSOA11CD)][order(WPZ)], './data-raw/csv/lookups/WPZ_MSOA.csv')

message('DONE! Cleaning...')
rm(list = ls())
gc()
