##############################################
# UK GEOGRAPHY * 38 - Lookups from Postcodes #
##############################################

library(data.table)

# RGN
y <- dd_build_lkps('LAD', 'RGN')
yo <- fread('./data-raw/csv/lookups/OA_LAD.csv')
fwrite(y[yo, on = 'LAD'][, .(OA, RGN)], './data-raw/csv/lookups/OA_RGN.csv')

# STP
y <- dd_build_lkps('CCG', 'STP')
yo <- fread('./data-raw/csv/lookups/OA_CCG.csv')
fwrite(y[yo, on = 'CCG'][, .(OA, STP)], './data-raw/csv/lookups/OA_STP.csv')

# NHSR
y <- dd_build_lkps('STP', 'NHSR')
yo <- fread('./data-raw/csv/lookups/OA_STP.csv')
fwrite(y[yo, on = 'STP'][, .(OA, NHSR)], './data-raw/csv/lookups/OA_NHSR.csv')

# clean
rm(list = ls())
gc()
