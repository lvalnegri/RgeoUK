###############################################
# Index of UK Places and NAmes - Prepare Data #
###############################################

# load packages
dmpkg.funs::load_pkgs(c('data.table', 'fst', 'leaflet', 'rgdal'))

# set  constants
app_path <- file.path(pub_path, 'shiny_apps', 'uk_places_names')

# NEW VERSION 
# https://www.arcgis.com/sharing/rest/content/items/e8e725daf8944af6a336a9d183114697/data

# download and filter dataset for LOCality only
dts <- fread(
        'https://opendata.arcgis.com/datasets/22c111c7a7884e2da582dfbb62a78489_0.csv',
        select = c('placeid', 'place15cd', 'place15nm', 'descnm', 'long', 'lat'),
        col.names = c('place_id', 'code', 'name', 'desc', 'x_lon', 'y_lat')
)
dts <- dts[desc == 'LOC'][, desc := NULL]

# add postcode and OA

# order by region/, create index file, save to disk as binary fst

write.fst(dts, file.path(app_path, 'dataset'))
