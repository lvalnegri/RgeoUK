###############################
# UK GEOGRAPHY * 26 - LOOKUPS #
###############################

# load packages 
pkg <- c('dmpkg.funs', 'data.table', 'fst')
invisible(lapply(pkg, require, character.only = TRUE))

# load data 
oas <- read_fst(file.path(geouk_path, 'output_areas'), as.data.table = TRUE)
hrc <- read_fst(file.path(geouk_path, 'hierarchies'), columns = c('hierarchy_id', 'child_type', 'parent_type'), as.data.table = TRUE)
hrc[!child_type %in% c('OA', 'WPZ')]

# loop over all hierarchies <> OA, WPZ
lkps <- data.table(hierarchy_id = integer(0), child_id = character(0), parent_id = character(0))
for(idx in 1:nrow(hrc)){
    message('Processing hierachy ', hrc[idx, 2], ' to ', hrc[idx, 3])
    y <- unique(oas[, .( get(hrc[idx, child_type]), get(hrc[idx, parent_type]) ) ] )
    lkps <- rbindlist(list( lkps, data.table( hrc[idx, 1], y ) ))
}

# clean NAs
lkps <- lkps[!is.na(child_id)]
lkps <- lkps[!is.na(parent_id)]

# recode all fields as factor, then save in fst format
message('Saving as fst...')
cols <- c('child_id', 'parent_id')
lkps[, (cols) := lapply(.SD, factor), .SDcols = cols]
write_fst_idx('lookups', c(''parent_id''), lkps, geouk_path)

# clean and exit
message('DONE!')
rm(list = ls())
gc()
