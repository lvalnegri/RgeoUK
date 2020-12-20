#' @importFrom data.table data.table
NULL

#' A list of all the currently active postcodes in the UK (1,718,610 as of NOV-2020), their coordinates in WGS84 CRS,
#' and the corresponding Output Area, based on a *best-fit* approach
#'
#' @format A data.table with 4 columns:
#' \describe{
#'   \item{\code{PCU}}{postcode unit in 7-chars format}
#'   \item{\code{OA}}{output area ONS code}
#'   \item{\code{x_lon}}{longitude}
#'   \item{\code{y_lat}}{latitude}
#' }
#'
#' For further details, see \url{http://}
#'
'postcodes'

#' Output Areas lookups for the UK geographies
#'
#' This dataset contains both a complete list of the UK \it{Output Areas}, the smallest statistical geographic area in the UK,
#' with some of its characteristics, and a mapping between them and some other geographies as deployed and maintaned by \it{ONS}.
#'
#' @format A data.table with 30 columns:
#' \describe{
#'   \item{\code{OA}}{Output Area}
#' }
#'
#' For further details, see \url{http://}
#'
'output_areas'

#' locations
#'
#' A list of all the geographies included in the \code{output_areas} mapping dataset (apart from the Output Areas themselves and the Workplace Zones)
#'
#' @format A data.table with ??? columns:
#' \describe{
#'   \item{\code{OA}}{Output Area}
#' }
#'
#' For further details, see \url{http://}
#'
'locations'

#' lookups
#'
#' A list of all the geographies included in the \code{output_areas} mapping dataset (apart from the Output Areas themselves and the Workplace Zones)
#'
#' @format A data.table with ??? column:
#' \describe{
#'   \item{\code{OA}}{Output Area}
#' }
#'
#' For further details, see \url{http://}
#'
'lookups'

#' hierarchies
#'
#' A list of all the geographies included in the \code{output_areas} mapping dataset (apart from the Output Areas themselves and the Workplace Zones)
#'
#' @format A data.table with ??? column:
#' \describe{
#'   \item{\code{OA}}{Output Area}
#' }
#'
#' For further details, see \url{http://}
#'
'hierarchies'

#' Workplace Zones
#'
#' This dataset contains both a complete list of the UK \it{Workplace Zones}, a similar statistical geographic area as OAs but based on workers commuting patterns,
#' with some of its characteristics, and a mapping between them and MSOA, so that there is a link to some higher level geographies.
#'
#' @format A data.table with ??? column:
#' \describe{
#'   \item{\code{WPZ}}{Workplace Zone}
#' }
#'
#' For further details, see \url{http://}
#'
'workplace_zones'
