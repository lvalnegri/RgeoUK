#######################################
# UK GEOGRAPHY * 39 - Lookups, Others #
#######################################

library(data.table)

# CTY
y <- fread('./data-raw/csv/ons/LAD11_CTY11-ENG.csv', select = c('LAD21CD', 'CTY21CD', 'CTY21NM'), col.names = c('LAD', 'CTY', 'CTYn'))
yn <- fread('./data-raw/csv/locations/LAD.csv', col.names = c('CTY', 'CTYn'))
yn <- rbind( yn[substr(CTY, 1, 3) == 'E06'], unique(y[, .(CTY, CTYn)]))

fwrite(y, './data-raw/csv/locations/CTY.csv')

fwrite(y, './data-raw/csv/lookups/OA_CTY.csv')

