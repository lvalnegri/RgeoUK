#####################################
# UK GEOGRAPHY * 31 - download csvs #
#####################################

library(data.table)

# OA > LSOA > MSOA
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/65664b00231444edb3f6f83c9d40591f_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/OA11_LSOA11_MSOA11-EW.csv'
)
download.file(
    'https://www.nrscotland.gov.uk/files//geography/2011-census/OA_DZ_IZ_2011.xlsx',
    destfile = './data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.xlsx'
)
fwrite(
    readxl::read_xlsx( './data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.xlsx', sheet = 1),
    './data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.csv'
)
fwrite(
    readxl::read_xlsx( './data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.xlsx', sheet = 2),
    './data-raw/csv/ons/LSOA11-SCO.csv'
)
fwrite(
    readxl::read_xlsx( './data-raw/csv/ons/OA11_LSOA11_MSOA11-SCO.xlsx', sheet = 3),
    './data-raw/csv/ons/MSOA11-SCO.csv'
)
download.file(
    'http://www.ninis2.nisra.gov.uk/Download/People%20and%20Places/Geographic%20Data%20(statistical%20geographies).ods',
    destfile = './data-raw/csv/ons/OA11_LSOA11_MSOA11-NIE.ods'
)
fwrite(
    readODS::read_ods( './data-raw/csv/ons/OA11_LSOA11_MSOA11-NIE.ods', sheet = 'SA', skip = 4)[1:2],
    './data-raw/csv/ons/OA11_LSOA11-NIE.csv'
)
fwrite(
    readODS::read_ods('./data-raw/csv/ons/OA11_LSOA11_MSOA11-NIE.ods', sheet = 'SOA', skip = 4)[1:2],
    './data-raw/csv/ons/LSOA11-NIE.csv'
)

# MSOA NAMES for EW
download.file(
    'https://houseofcommonslibrary.github.io/msoanames/MSOA-Names-Latest.csv',
    destfile = './data-raw/csv/ons/MSOA_names.csv'
)

# LAD > CTY (ENG)
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/1e5367cba9074514ae9012f5627a3241_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/LAD11_CTY11-ENG.csv'
)

# OA > TTWA
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/50ce6db9e3a24f16b3f63f07e6a069f0_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/LSOA11_TTWA11-UK.csv'
)

# OA > MTC
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/94b013d7e17c40b0aa6482a7e1fa702f_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/OA11_MTC15-EW.csv'
)

# OA > BUAS > BUA
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/edaf7c4b5e6e401d987c30c4de6b63e6_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/OA11_BUAS11_BUA11-EW.csv'
)

# WPZ > MSOA
download.file(
    'https://opendata.arcgis.com/api/v3/datasets/fde83309b6c14456846ca8fdece44a26_0/downloads/data?format=csv&spatialRefId=4326',
    destfile = './data-raw/csv/ons/WPZ11_MSOA11-EWS.csv'
)
download.file(
    'https://www.nisra.gov.uk/sites/nisra.gov.uk/files/publications/WPZ_SA_lookup_0.xls',
    destfile = './data-raw/csv/ons/OA11_WPZ11-NIE.xls'
)
y <- data.table(readxl::read_xls('./data-raw/csv/ons/OA11_WPZ11-NIE.xls', 'WPZ to SA', skip = 2))
y[, Notes := NULL]
y <- melt(y, id.vars= 1, na.rm = TRUE)[, variable := NULL]
setnames(y, c('WPZ', 'OA'))
fwrite(y,  './data-raw/csv/ons/WPZ11_OA11-NIE.csv')

# END
rm(list = ls())
gc()
