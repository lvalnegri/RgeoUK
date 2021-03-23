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
#'   \item{\code{prog_id}}{}
#'   \item{\code{pd_id}}{}
#'   \item{\code{ordering}}{}
#'   \item{\code{name}}{}
#'   \item{\code{theme}}{}
#'   \item{\code{countries}}{}
#'   \item{\code{count_ons}}{}
#'   \item{\code{count_pd}}{}
#'   \item{\code{count_pkg}}{}
#'   \item{\code{last_update}}{}
#'   \item{\code{is_frozen}}{}
#'   \item{\code{max_child}}{}
#'   \item{\code{exact_coverage}}{}
#'   \item{\code{min_parent}}{}
#'   \item{\code{pref_filter}}{}
#'   \item{\code{pref_map}}{}
#'   \item{\code{locations}}{}
#'   \item{\code{lookups}}{}
#'   \item{\code{boundaries}}{}
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
#'   \item{\code{location_type}}{An acronym for the geography, used as its id}
#'   \item{\code{country}}{}
#'   \item{\code{prog_id}}{}
#'   \item{\code{ordering}}{}
#'   \item{\code{code}}{}
#'   \item{\code{name}}{}
#'   \item{\code{ons}}{}
#'   \item{\code{N_ons}}{}
#'   \item{\code{N_onspd}}{}
#'   \item{\code{N_package}}{}
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
#'   \item{\code{hierarchy_id}}{}
#'   \item{\code{child_type}}{}
#'   \item{\code{child_id}}{}
#'   \item{\code{parent_type}}{}
#'   \item{\code{parent_id}}{}
#'   \item{\code{countries}}{}
#'   \item{\code{is_exact}}{}
#'   \item{\code{is_direct}}{}
#'   \item{\code{listing}}{}
#'   \item{\code{filtering}}{}
#'   \item{\code{mapping}}{}
#'   \item{\code{charting}}{}
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
#'   \item{\code{OA}}{Output Area. Theme: Census. Countries: ENSW. Total units: 232,296. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: LSOA}
#'   \item{\code{LSOA}}{Lower Layer Super Output Area. Theme: Census. Countries: ENSW. Total units: 42,619. Last updated: Jul-05 (Frozen). Built From OA. Direct Parent: MSOA}
#'   \item{\code{MSOA}}{Middle Layer Super Output Area. Theme: Census. Countries: ESW. Total units: 9,370. Last updated: Jul-05 (Frozen). Built From LSOA. Direct Parent: LAD}
#'   \item{\code{LAD}}{Local Authority & District. Theme: Census. Countries: ENSW. Total units: 379. Last updated: Dec-20. Built From MSOA. Direct Parent: CTY}
#'   \item{\code{CTY}}{County. Theme: Census. Countries: E. Total units: 93. Last updated: Jan-00. Built From LAD. Direct Parent: RGN}
#'   \item{\code{RGN}}{Region. Theme: Census. Countries: E. Total units: 12. Last updated: Jan-00 (Frozen). Built From CTY. Direct Parent: CTRY}
#'   \item{\code{CTRY}}{Country. Theme: Census. Countries: ENSW. Total units: 4. Last updated: Jan-00 (Frozen). Built From RGN. Direct Parent: 0}
#'   \item{\code{WPZ}}{Workplace Zone. Theme: Census. Countries: ENSW. Total units: 60,709. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: MSOA}
#'   \item{\code{PCS}}{Postcode Sector. Theme: Postal. Countries: ENSW. Total units: 9,538. Last updated: Nov-20. Built From OA. Direct Parent: PCD}
#'   \item{\code{PCD}}{Postcode District. Theme: Postal. Countries: ENSW. Total units: 2,815. Last updated: Nov-20. Built From PCS. Direct Parent: PCT}
#'   \item{\code{PCT}}{Post Town. Theme: Postal. Countries: ENSW. Total units: 1,430. Last updated: Nov-20. Built From PCD. Direct Parent: PCA}
#'   \item{\code{PCA}}{Postcode Area. Theme: Postal. Countries: ENSW. Total units: 121. Last updated: Nov-20. Built From PCT. Direct Parent: 0}
#'   \item{\code{PCON}}{Westminster Parliamentary Constituency. Theme: Electoral. Countries: ENSW. Total units: 650. Last updated: Jan-00. Base Layer. Direct Parent: 0}
#'   \item{\code{WARD}}{Electoral Ward. Theme: Electoral. Countries: ENSW. Total units: 8,875. Last updated: Dec-20. Base Layer. Direct Parent: 0}
#'   \item{\code{CED}}{County Electoral Division. Theme: Electoral. Countries: E. Total units: 1,719. Last updated: Jan-00 (Frozen). Base Layer. Direct Parent: 0}
#'   \item{\code{TTWA}}{Travel To Work Area. Theme: Urban. Countries: ENSW. Total units: 228. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: 0}
#'   \item{\code{MTC}}{Major Town or City. Theme: Urban. Countries: EW. Total units: 113. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: 0}
#'   \item{\code{BUA}}{Built-up Area. Theme: Urban. Countries: EW. Total units: 5,795. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: 0}
#'   \item{\code{BUAS}}{Built-up Area Sub-division. Theme: Urban. Countries: EW. Total units: 1,824. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: 0}
#'   \item{\code{PAR}}{Civil Parish or Unparished; Community. Theme: Social. Countries: EWS. Total units: 12,415. Last updated: Dec-20. Base Layer. Direct Parent: 0}
#'   \item{\code{PFN}}{Police Neighborhood. Theme: Social. Countries: ENSW. Total units: 4,814. Last updated: Nov-20. Base Layer. Direct Parent: 0}
#'   \item{\code{PFA}}{Police Force Area. Theme: Social. Countries: ENSW. Total units: 45. Last updated: Dec-19. Base Layer. Direct Parent: 0}
#'   \item{\code{FRA}}{Fire Rescue Authority. Theme: Social. Countries: ENSW. Total units: 48. Last updated: Dec-19. Base Layer. Direct Parent: 0}
#'   \item{\code{CSP}}{Community Safety Partnership. Theme: Social. Countries: EW. Total units: 314. Last updated: Dec-19. Base Layer. Direct Parent: 0}
#'   \item{\code{LPA}}{Local Planning Authority. Theme: Social. Countries: ENSW. Total units: 397. Last updated: Apr-20. Base Layer. Direct Parent: 0}
#'   \item{\code{RGD}}{Registration District. Theme: Social. Countries: EW. Total units: 173. Last updated: Apr-19. Base Layer. Direct Parent: 0}
#'   \item{\code{LRF}}{Local Resilience Forum. Theme: Social. Countries: EW. Total units: 42. Last updated: Dec-19. Base Layer. Direct Parent: 0}
#'   \item{\code{CCG}}{Clinical Commissioning Group. Theme: Health. Countries: ENSW. Total units: 181. Last updated: Jan-00. Built From LSOA. Direct Parent: STP}
#'   \item{\code{STP}}{Sustainability and Transformation Partnership. Theme: Health. Countries: E. Total units: 42. Last updated: Jan-00. Built From CCG. Direct Parent: NHSO}
#'   \item{\code{NHSO}}{NHS England Local Office. Theme: Health. Countries: E. Total units: 14. Last updated: Jan-00. Built From STP. Direct Parent: NHSR}
#'   \item{\code{NHSR}}{NHS England Region. Theme: Health. Countries: E. Total units: 7. Last updated: Jan-00. Built From NHSO. Direct Parent: 0}
#'   \item{\code{CIS}}{Covid Infection Survey. Theme: Health. Countries: ENSW. Total units: 133. Last updated: Jan-21. Built From OA. Direct Parent: 0}
#'   \item{\code{x_lon}}{}
#'   \item{\code{y_lat}}{}
#'   \item{\code{wx_lon}}{}
#'   \item{\code{wy_lat}}{}
#'   \item{\code{perimeter}}{}
#'   \item{\code{area}}{}
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
#'   \item{\code{type}}{}
#'   \item{\code{location_id}}{}
#'   \item{\code{name}}{}
#'   \item{\code{x_lon}}{}
#'   \item{\code{y_lat}}{}
#'   \item{\code{wx_lon}}{}
#'   \item{\code{wy_lat}}{}
#'   \item{\code{perimeter}}{}
#'   \item{\code{area}}{}
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
