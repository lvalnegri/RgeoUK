#' dd_build_oa_lkps
#' 
#' Build a lookup table with output areas as source map
#' 
#' @param y the map to compare to in \code{sf} format, it should contains the ids of the zones as first column
#' @param cx string of characters indicating countries, if it is known not all the UK is going to be checked
#' @param check_lsoa constrain target type zone to include LSOAs exactly
#' @param verbose indicate if each step should be commented
#'
#' @return a data.table with two columns
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom sf st_covered_by st_intersects st_drop_geometry st_area st_intersection
#' @importFrom dplyr filter select
#'
dd_build_oa_lkps_maps <- function(y, cx = NA, check_lsoa = FALSE, verbose = FALSE){

    yn <- names(y)[1]

    if(verbose) message(' * Reading OA boundaries...')
    yb <- readRDS(file.path(Rfuns::bnduk_path, 's00', 'OAgb')) |> dplyr::select(-RGN)
    if(!is.na(cx)) yb <- yb |> dplyr::filter(substr(OA, 1, 1) %in% strsplit(cx, '')[[1]])

    if(verbose) message(' * Calculating OAs in exact coverage...')
    yc <- as.numeric(sf::st_covered_by(yb, y))
    yc <- data.table( yb |> sf::st_drop_geometry(),  y[yc, yn] |> sf::st_drop_geometry() )

    if(verbose) message(' * Calculating intersections from remaining OAs (', formatC(yc[is.na(get(yn)), .N], big.mark = ','), ')...')
    ycn <- yc[, .I[is.na(get(yn))]]
    yct <- sf::st_intersects(yb[ycn,], y)
    yctx <- which(lapply(yct, length) == 1)
    yc[ycn[yctx], 2 := y[unlist(yct[yctx]),] |> sf::st_drop_geometry() |> dplyr::select(1)]
    yctx <- which(lapply(yct, length) > 1)

    if(verbose) message(' * Working out multiple intersections (', formatC(length(yctx), big.mark = ','), ')...')
    for(x in yctx){
        yx <- unlist(yct[x])
        yx <- yx[which.max(as.numeric(sf::st_area(sf::st_intersection(yb[ycn[x],], y[yx,]))))]
        yc[ycn[x], 2 := y[yx,] |> sf::st_drop_geometry() |> dplyr::select(1)]
    }

    if(check_lsoa){
        if(verbose) message(' * fixing LSOA overlapping...')
        setnames(yc, yn, 'X')
        yc <- fread('./data-raw/csv/lookups/OA_LSOA.csv')[yc, on = 'OA']
        yco <- unique(yc[, .(LSOA, X)])[, .N, LSOA][N > 1, as.character(LSOA)]
        for(x in yco) yc[LSOA == x, X := head(yc[LSOA == x, .N, X][order(-N)][, X], 1)] 
        yc[, LSOA := NULL]
        setnames(yc, 'X', yn)
    }

    yc

}


#' dd_dissolve_oa
#' 
#' Build a lookup table with output areas as source
#' 
#' @param y a data.table with two columns: the first OA, the second the ids of the areas to be dissolved into
#' @param wgs84 indicate if the output should be a projection suitable for the web
#' @param s an integer between 5 and 95 to indicate the percentage to simplify 
#' @param verbose indicate if each step should be commented
#'
#' @return an \code{sf} object
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @importFrom sf st_transform st_make_valid
#' @importFrom dplyr filter
#' @importFrom rmapshaper ms_dissolve ms_simplify
#'
#' @export
#'
dd_dissolve_oa <- function(y, wgs84 = TRUE, s = NA, verbose = FALSE){
    if(verbose) message('* Loading British boundaries...')
    yb <- readRDS(file.path(bnduk_path, 's00', 'OAgb')) |> merge(y)
    yn <- names(y)[which(names(y) != 'OA')]
    if(verbose) message('* Dissolving ', yn, ' by Regions...')
    y <- lapply(unique(yb$RGN), \(z) yb |> dplyr::filter(RGN == z) |> rmapshaper::ms_dissolve(yn))
    if(verbose) message('* Binding back Regions...')
    y <- do.call('rbind', y) |> rmapshaper::ms_dissolve(yn)
    if(wgs84){
        if(verbose) message('* Converting in WGS84...')
        y <- y |> sf::st_transform(4326)
    }
    if(!is.na(s)){
        if(s <= 5 | s > 95) s <- 10
        if(verbose) message('* Simplifying ', s, '%...')
        y <- y |> rmapshaper::ms_simplify(s/100)
    }
    if(verbose) message('* Ensure result is a valid polygons set...')
    y |> sf::st_make_valid()
}


#' dd_simplify_bnd
#' 
#' Simplifying boundaries by multiple percentages
#' 
#' @param x the \code{sf} polygons to simplify
#' @param nm the name to use for the output files
#' @param pct the percentage(s) to apply
#' @param out_path the folder where the resulting files will be saved
#' @param verbose indicate if each step should be commented
#'
#' @return none (multiple \code{sf} objects will be saved in \code{out_path})
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @importFrom rmapsaper ms_simplify
#'
dd_simplify_bnd <- function(x, nm, pct = seq(10, 50, 10), out_path = dmpkg.funs::bnduk_path, verbose = FALSE){
    for(s in pct){
        if(verbose) message(' Simplifying ', s, ' %...')
        y <- y |> ms_simplify(s/100)
        if(verbose) message(' * Saving...')
        saveRDS(y, file.path(out_path, paste0('s', s), nm))
    }
}

#' Build a lookup table child <=> parent using the postcodes table from the ONS geography database
#' This function should not be used with 'OA' as child because in the csv files from ONS there are 265 OAs missing (36 ENG, 229 SCO)
#' Always remember to check column 'pct_coverage' for values less than 100
#'
#' @param child the code for the lower level geography
#' @param parent the code for the higher level geography
#' @param is_active if TRUE, keep only live postcodes for the calculation
#' @param filter_country indicates if the calculation must be done on less than the UK
#' @param save_results if TRUE, the result dataset will also be saved
#' @param out_path if save_results is TRUE, the folder where to save the output file (which will be called "paste0(child, '_to_', parent))"
#' @param verbose indicate if each step should be commented
#'
#' @return a data.table with two columns, child and parent
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table fst dmpkg.funs add_Kcomma add_pct
#'
#' @export
#'
dd_build_lkps <- function(
                    child,
                    parent,
                    is_active = TRUE,
                    filter_country = NULL,
                    save_results = FALSE,
                    out_path = file.path(ext_path, 'uk', 'geography', 'lookups')
                 ){
    message('Processing ', child, 's to ', parent, 's...')
    message(' - Reading postcodes data...')
    cols <- c(child, parent)
    if(!is.null(filter_country)) cols <- c(cols, 'CTRY')
    if(is_active == 1){
        pc <- dmpkg.funs::read_fst_idx(file.path(dmpkg.funs::geouk_path, 'postcodes.full'), 1, cols = cols)
    } else {
        pc <- fst::read_fst(file.path(dmpkg.funs::geouk_path, 'postcodes.full'), columns = cols, as.data.table = TRUE)
    }
    if(!is.null(filter_country)) pc <- pc[CTRY %in% filter_country][, CTRY := NULL]
    message(' - Aggregating...')
    setnames(pc, c('child', 'parent'))
    y <- unique(pc[, .(child, parent)])[, .N, child][N == 1][, child]
    if(length(y) > 0) y1 <- unique(pc[child %in% y, .(child, parent, pct = 100)])
    y <- unique(pc[, .(child, parent)])[, .N, child][N > 1][!is.na(child), child]
    if(length(y) > 0){
        y2 <- pc[child %in% y][, .N, .(child, parent)][order(child, -N)]
        y2 <- y2[, pct := round(100 * N / sum(N), 2), child][, .SD[1], child][, .(child, parent, pct)]
    }
    if(!exists('y1')){
        y <- y2
        exact_cov <- 0
        partial_cov <- nrow(y2)
    } else if(!exists('y2')){
        y <- y1
        exact_cov <- nrow(y1)
        partial_cov <- 0
    } else {
        y <- rbindlist(list(y1, y2))
        exact_cov <- nrow(y1)
        partial_cov <- nrow(y2)
    }
    y <- y[order(child)]
    ov_par <- nrow(unique(y[pct < 100, .(parent)]))
    setnames(y, c(child, parent, 'pct_coverage'))
    if(save_results){
        message(' - Saving results to csv file...')
        if(substr(out_path, nchar(out_path), nchar(out_path)) != '/') out_path <- paste0(out_path, '/')
        fwrite(y, paste0(out_path, child, '_to_', parent, ifelse(is.null(filter_country), '', paste0('-', filter_country)), '.csv'))
    }
    message(
        'Done! Found ', dmpkg.funs::add_Kcomma(exact_cov), ' exact associations and ', dmpkg.funs::add_Kcomma(partial_cov), ' partial coverage (',
        dmpkg.funs::add_pct(exact_cov / nrow(y)), ' exact coverage)',
        ifelse(ov_par == 0, '.', paste0(', with ', dmpkg.funs::add_Kcomma(ov_par), ' ', parent, 's involved.'))
    )
    return(y)
}


#' dd_build_map_missing
#' 
#' Build a leaflet map of the missing zones for a given location types according to the official map, once the OA lookups have been created
#' 
#' @param x the acronym that distinguishes a location type
#'
#' @return none
#'
#' @author Luca Valnegri, \email{l.valnegri@datamaps.co.uk}
#'
#' @import data.table
#' @import leaflet 
#' @importFrom sf st_intersects st_transform
#' @importFrom rmapshaper ms_dissolve
#'
dd_build_map_missing <- function(x){
    oa <- readRDS(file.path(bnduk_path, 's10', 'OA'))
    yx <- fread(paste0('./data-raw/csv/lookups/OA_', x, '.csv'))
    yn <- fread(paste0('./data-raw/csv/locations/', x, '.csv'))
    yxb <- readRDS(paste0('./data-raw/shp/', x)) |> 
              subset(!get(x) %in% yx[, get(x)]) |> 
              sf::st_transform(4326) |> 
              merge(yn)
    if(nrow(yxb) > 0){
        oam <- oa[yxb |> sf::st_intersects(oa) |> unlist() |> unique(),]
        yc <- oa |> 
                merge(yx[get(x) %chin% yx[OA %chin% oam$OA, get(x)]]) |> 
                ms_dissolve(x) |> 
                merge(yn)
        grps <- c( 
                paste0(x, ' missing (red - ', dmpkg.funs::add_Kcomma(nrow(yxb)), ')'),
                paste0('Output Areas (black - ', dmpkg.funs::add_Kcomma(nrow(oam)), ')'),
                paste0(x, ' stored (blue - ', dmpkg.funs::add_Kcomma(nrow(yc)), ')')
        )
        ym <- leaflet() |> 
                  addTiles() |> 
                  addPolygons(
                      group = grps[1],
                      data = yxb,
                      color = 'red',
                      weight = 4,
                      opacity = 0.6,
                      fillOpacity = 0,
                      label = ~paste(get(x), '-', get(paste0(x, 'n'))),
                      highlightOptions = highlightOptions(weight = 8, color = 'darkred', opacity = 1, fillOpacity = 0.4)
                  ) |>
                  addPolygons(
                      group = grps[2],
                      data = oam,
                      color = 'black',
                      weight = 2,
                      opacity = 0.6,
                      fillOpacity = 0,
                      label = ~OA,
                      highlightOptions = highlightOptions(weight = 4, opacity = 1, fillOpacity = 0.4)
                  ) |>
                  addPolygons(
                      group = grps[3],
                      data = yc,
                      color = 'blue',
                      weight = 3,
                      opacity = 0.6,
                      fillOpacity = 0,
                      label = ~paste(get(x), '-', get(paste0(x, 'n'))), 
                      highlightOptions = highlightOptions(weight = 6, color = 'darkblue', opacity = 1)
                  ) |>
                  addLayersControl(overlayGroups = grps, options = layersControlOptions(collapsed = FALSE))
        htmlwidgets::saveWidget(ym, paste0('./data-raw/maps/', x, '_missing.html'), title = paste('Missing ', x, ' from Output Areas lookups'))
        system(paste0('rm -rf ./data-raw/maps/', x, '_missing_files'))
        message('Map saved as "./data-raw/maps/', x, '_missing.html"')
    } else {
        message('Good News! There are no ', x, ' missing')
    }
}
