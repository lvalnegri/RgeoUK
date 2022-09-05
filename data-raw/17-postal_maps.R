###################################
# UK GEOGRAPHY * 17 - Postal Maps #
###################################

Rfuns::load_pkgs('data.table', 'leaflet')

message('\nBuilding and saving PCT boundaries...')
bnd.pcd <- readRDS(file.path(bnduk_path, 's00', 'PCD'))
bnd.pct <- bnd.pcd |>
                merge(pcdt[, .(PCD, PCT)]) |> 
                rmapshaper::ms_dissolve('PCT')
saveRDS(bnd.pct, file.path(bnduk_path, 's00', 'PCT'))
                
message('\nSimplifying boundaries...')
for(s in seq(10, 50, 10)){
    message(' - ', s, ' %...')
    bnd.pct |> 
        rmapshaper::ms_simplify(s/100) |> saveRDS(file.path(bnduk_path, paste0('s', s), 'PCT'))
}

message('\nBuildin maps for all Postal Types...')
bnd.pca <- readRDS(file.path(bnduk_path, 's10', 'PCA')) |> merge(pca)
bnd.pct <- readRDS(file.path(bnduk_path, 's10', 'PCT')) |> merge(pct)
bnd.pcd <- readRDS(file.path(bnduk_path, 's10', 'PCD'))
bnd.pcs <- readRDS(file.path(bnduk_path, 's10', 'PCS'))
grps = c(
    paste0('Areas (PCA - ', nrow(pca), ')'),
    paste0('Towns (PCT - ', formatC(nrow(pct), big.mark = ','), ')'),
    paste0('Districts (PCD - ', formatC(nrow(pcd), big.mark = ','), ')'),
    paste0('Sectors (PCS - ', formatC(nrow(bnd.pcs), big.mark = ','), ')')
)
ym <- leaflet() |>
        addTiles() |>
        addPolygons(
            data = bnd.pca,
            group = grps[1],
            color = 'black',
            fillOpacity = 0.1,
            label = ~name
        ) |>
        addPolygons(
            data = bnd.pct,
            group = grps[2],
            color = 'magenta',
            fillOpacity = 0.1,
            label = ~name
        ) |>
        addPolygons(
            data = bnd.pcd,
            group = grps[3],
            color = 'blue',
            fillOpacity = 0.1,
            label = ~PCD
        ) |>
        addPolygons(
            data = bnd.pcs,
            group = grps[4],
            color = 'red',
            fillOpacity = 0.1,
            label = ~PCS
        ) |>
        addLayersControl(overlayGroups = grps)

htmlwidgets::saveWidget(ym, paste0('./data-raw/maps/Postal.html'))
system(paste0('rm -r ./data-raw/maps/Postal_files'))

