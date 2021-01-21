#' @importFrom data.table data.table
NULL

#' Location Types
#'
#' A list of all the Geographies included in the package
#' (apart from the Output Areas and the Workplace Zones, which are listed in the corresponding datasets)
#'
#' @format A data.table with the following ??? columns:
#' \describe{
#'   \item{\code{location_type}}{An acronym for the geography, used as its id}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'location_types'

#' Entities
#'
#' An alternative view of the geographies included in the package, as listed in \code{location_types}, partitioned by countries
#'
#' @format A data.table with the following ??? column:
#' \describe{
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'entities'

#' Hierarchies
#'
#' A list of possible mapping between each geography and its possible parents
#'
#' @format A data.table with the following ??? column:
#' \describe{
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'hierarchies'

#' Postcodes
#'
#' A list of all the postcode units in the UK, as of NOV-2020 (1,718,610 active, terminated)
#' their coordinates in WGS84 CRS,
#' and the corresponding Output Area, based on a *best-fit* approach
#'
#' @format A data.table with the following four columns:
#' \describe{
#'   \item{\code{PCU}}{unit postcode in 7-chars format}
#'   \item{\code{is_active}}{flag that indicates if the corresponding unit postcode is currently active or terminated}
#'   \item{\code{OA}}{output area ONS code}
#'   \item{\code{x_lon}}{longitude}
#'   \item{\code{y_lat}}{latitude}
#' }
#'
#' For further details, see \url{http://}
#'
'postcodes'

#' Output Areas
#'
#' This dataset contains both a complete list of the UK \emph{Output Areas}, the smallest statistical geographic area in the UK,
#' with some of its characteristics, and a mapping between them and all the other Geographies contained in the package
#' (apart from Workplace Zones, which have a similar dedicated mapping dataset), as deployed and maintaned by \emph{ONS}.
#'
#' @format A data.table with the following 30 columns:
#' \describe{
#'   \item{\code{OA}}{Output Area}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'output_areas'

#' Workplace Zones
#'
#' This dataset contains both a complete list of the UK \emph{Workplace Zones}, a similar statistical geographic area as OAs but based on workers commuting patterns,
#' with some of its characteristics, and a mapping between them and MSOA, so that there is a link to some higher level geographies.
#'
#' @format A data.table with the following six column:
#' \describe{
#'   \item{\code{WPZ}}{Workplace Zone}
#'   \item{\code{MSOA}}{Middle LAyer Super Output Area (NA for N.Ireland)}
#'   \item{\code{LAD}}{Local Authority}
#'   \item{\code{CTY}}{County (England only)}
#'   \item{\code{RGN}}{Region (England only)}
#'   \item{\code{CTRY}}{Country}
#' }
#'
#' For further details, see \url{http://}
#'
'workplace_zones'

#' locations
#'
#' A list of all the areas included in the \code{output_areas} mapping dataset
#' (apart from the Output Areas themselves and the Workplace Zones)
#' together with some of , like coordinates, Perimeter, and Area
#'
#' @format A data.table with the following ??? columns:
#' \describe{
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'locations'

#' lookups
#'
#' A list of all the geographies included in the \code{output_areas} mapping dataset (apart from the Output Areas themselves and the Workplace Zones)
#'
#' @format A data.table with the following ??? column:
#' \describe{
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#'   \item{\code{}}{}
#' }
#'
#' For further details, see \url{http://}
#'
'lookups'

#' neighbours
#'
#' This dataset contains the 1st order neighbours for all location areas
#'
#' @format A data.table with the following two columns:
#' \describe{
#'   \item{\code{location_id}}{The code of an area}
#'   \item{\code{neighbour_id}}{The 1st order neighbours of an area}
#' }
#'
#' For further details, see \url{http://}
#'
'neighbours'
