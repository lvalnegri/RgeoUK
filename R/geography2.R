#' dd_add_geocodes
#' 
#' Add geographical area codes to a dataset, starting from a postcode column
#'
#' @param dt a data.table
#' @param clean_pc if the postcode column needs to be cleaned beforehand
#' @param pcn if clean_pc is TRUE, this is the column name to consider
#' @param oa_only Add only the Output Area column, disregarding all the other options
#' @param census Add geographies related to the "Census" hierarchy: 'LSOA', 'MSOA', 'LAD'
#' @param admin Add geographies related to the "Admin" hierarchy: 'LAD', 'CTY', 'RGN', 'CTRY'
#' @param postal Add geographies related to the "Postal" hierarchy: 'PCS', 'PCD', 'PCT', 'PCA'
#' @param electoral Add geographies related to the "Electoral" hierarchy: 'PCON', 'WARD', 'CED'
#' @param health Add geographies related to the "NHS" hierarchy: 'CCG', 'NHSO', 'NHSR'
#' @param urban Add geographies related to the "NHS" hierarchy: 'CCG', 'NHSO', 'NHSR'
#' @param social Add geographies related to the "NHS" hierarchy: 'CCG', 'NHSO', 'NHSR'
#' @param crime Add geographies related to the "Police" hierarchy: 'CSP', 'PFA'
#' @param cols_in Insert here isolated columns to add to the output dataset
#' @param cols_out The columns you don't want to be included in the output Note that you can not exclude neither OA nor WPZ.
#'
#' @return a data.table with possibly cleaned postcode, OA and WPZ columns, plus all other specified
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom fst read_fst
#'
#' @export
#'
dd_add_geocodes <- function(dt,
                        clean_pc = TRUE, pcn = 'PCU',
                        oa_only = FALSE, add_oa = TRUE, add_wpz = FALSE, 
                        census = TRUE, admin = TRUE, postal = TRUE, electoral = FALSE, 
                            health = FALSE, urban = FALSE, social = FALSE, crime = FALSE,
                        cols_in = NULL, cols_out = NULL
                ){
    dt <- copy(dt)
    cname <- names(dt)[1:which(grepl(pcn, names(dt)))]
    if(clean_pc) dd_clean_pcu(dt, pcn)
    if(add_oa){
        cols <- 'OA'
        if(add_wpz) cols <- c(cols, 'WPZ')
        y <- read_fst( file.path(geouk_path, 'postcodes'), columns = c('PCU', cols), as.data.table = TRUE )
        setnames(dt, pcn, 'PCU')
        dt <- y[dt, on = 'PCU']
        setnames(dt, 'PCU', pcn)
    }
    cols <- 'OA'
    if(!oa_only){
        cols_all <- RgeoUK::location_types$location_type
        for(th in tolower(unique(RgeoUK::location_types$theme)))
            if(get(th)) cols <- c(cols, RgeoUK::location_types[theme == th, location_type])
        if(!is.null(cols_in)) cols <- c(cols, cols_in)
        if(!is.null(cols_out)) cols <- setdiff(cols, setdiff(cols_out, 'OA'))
        cols <- unique(intersect(cols, cols_all))
        y <- read_fst( file.path(geouk_path, 'output_areas'), columns = cols, as.data.table = TRUE )
        dt <- y[dt, on = 'OA']
    }
    setcolorder(dt, c(cname, cols, 'WPZ'))
    droplevels(dt)
}


#' check_area_ids
#' 
#' Check if one or more strings are valid location ids, returning the correct common area type
#'
#' @param ids a vector containing location ids of one unspecified location type
#' @param give_warning if there should be any explanation for the outcome
#'
#' @return a list with five components:
#' the valid ids, the invalid ids, the area type, the suffix name for the indexed location files, the parent id
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table fst
#'
#' @export
#'
check_area_ids <- function(ids, give_warning = FALSE){
    ids <- unique(toupper(ids))
    lcn <- read_fst(file.path(geouk_path, 'locations'), as.data.table = TRUE)
    tpe <- NULL
    inv <- NULL
    for(id in ids){
        y <- lcn[location_id == id, as.character(type)]
        if(length(y) == 0){ inv <- c(inv, id) } else { tpe <- c(tpe, y) }
    }
    tpe <- unique(tpe)
    inv <- inv
    ids <- setdiff(ids, inv)
    if(length(tpe) == 0){
        if(give_warning) message('Sorry, there is no valid code to process.')
        return( list('ids' = NULL, 'inv' = inv, 'type' = tpe, 'fname' = NULL) )
    }
    if(length(tpe) > 1){
        if(give_warning) message('Sorry, the codes refer to more than one location type: ', paste(tpe, collapse = ', '), '.')
        return( list('ids' = ids, 'inv' = inv, 'type' = NULL, 'fname' = NULL) )
    }
    linv <- length(inv)
    if(linv > 0 & give_warning)
        warning('The code', ifelse(linv == 1, ' ', 's '), paste(inv, collapse = ', '), ifelse(linv == 1, ' is', ' are'), ' invalid.')

    fname <- switch(tpe,
        'MSOA' = '_msls', # 1st
        'LSOA' = '_msls', # 2nd
        'LAD' = '_ldwd',  # 1st
        'WARD' = '_ldwd', # 2nd
        'PAR' =  '_ldpr', # 2nd
        'PCON' = '_pcoa', # 1st
        'PFN' = '_pfan',  # 2nd
        'PCS' = '_pcds',  # 2nd
        'PCD' = '_pcds',  # 1st
        'PCT' = '_pcat'   # 2nd
    )

    list('ids' = ids, 'inv' = inv, 'type' = tpe, 'fname' = fname)  # parent id + type still missing

}


#' get_area_code
#' 
#' Return all entries in the locations list including or exactly with the specified string
#'
#' @param x the string to look for
#' @param tpe the location type, for speed. If `NA` the search is done on all the records
#' @param exact if FALSE uses a regex search
#'
#' @return a data.table with two or three columns, depending on the tpe parameter
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table fst
#'
#' @export
#'
get_area_code <- function(x, tpe = NA, exact = FALSE){
    if(is.na(tpe)){
        lcn <- read_fst(file.path(geouk_path, 'locations'), columns = c('type', 'location_id', 'name'), as.data.table = TRUE)
    } else {
        lcn <- read_fst_idx(file.path(geouk_path, 'locations'), tpe, c('location_id', 'name'))
    }
    if(exact){
        lcn[toupper(x) == toupper(name)][order(name)]
    } else {
        lcn[grepl(toupper(x), toupper(name))][order(name)]
    }
}


#' crop_uk
#' 
#' Clip (crop) a SpatialPolygonsDataframe against the UK extent (with or without Northern Scotland Islands)
#'
#' @param bnd the SpatialPolygonsDataframe to be clipped
#' @param crop_islands if the extent should exlude the northern Scotland isles
#'
#' @return a SpatialPolygonsDataframe
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom raster crop
#'
#' @export
#'
crop_uk <- function(bnd, crop_islands = TRUE){
    uk <- readRDS(file.path(bnduk_path, 'rds', 's00', ifelse(crop_islands, 'UKni', 'UK')))
    crop(bnd, uk)
}




#' Calculates points in polygons using default UK polygons, returning an augmented data.table
#'
#' @param x a data.table with at least 3 columns, one for the id, the other two for the geographic coordinates
#' @param areatype the reference area to operate on for the point in polygon process
#' @param ... Additional parameters to pass to the <do_pip> function, and/or the <basemap> function if "output" is <map>
#'
#' @return a data.table
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#'
#' @export
#'
do_pip_uk <- function(x, areatype = 'OA', ...){
    y <- readRDS(file.path(bnduk_path, 'rds', 's00', areatype))
    do_pip(x, y, pname = areatype, ...)
}
