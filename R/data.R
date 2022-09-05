#' @importFrom data.table data.table
NULL

#' Location Types
#'
#' A list of all the Geographies included in the package
#' (apart from the Output Areas and the Workplace Zones, which are listed in the corresponding datasets)
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{location_type}}{ An acronym for the Geography, used as its id }
#'   \item{\code{ons_id}}{ The id of the Geography used by ONS }
#'   \item{\code{prog_id}}{ A numeric id, used moslty as ordering }
#'   \item{\code{name}}{ The Name for the Geography }
#'   \item{\code{theme}}{ A general Name to regroup different Geographies }
#'   \item{\code{countries}}{ The Countries where the geography is present }
#'   \item{\code{count_ons}}{ The total number of Locations }
#'   \item{\code{count_pkg}}{ The number of Locations present in the `lookups` table }
#'   \item{\code{last_update}}{ The date the Geography has last been updated }
#'   \item{\code{needs_update}}{ A flag used by the script \code{02} }
#'   \item{\code{is_frozen}}{ A flag that indicates the Geography does not need a regular update }
#'   \item{\code{max_child}}{ The location type that nest exactly into the current geography }
#'   \item{\code{min_parent}}{ The location type that all the current geography nest exactly into }
#'   \item{\code{pref_filter}}{ The location type to use by default as parent when filtering out }
#'   \item{\code{pref_map}}{ The location type to use by default as parent when mapping }
#'   \item{\code{dts_id}}{ The id to include in the ONS geoportal api call to retrieve the latest lookups against its `max_child` }
#'   \item{\code{bnd_id}}{ The id to include in the ONS geoportal api call to retrieve the latest map }
#' }
#'
#' For further details, see \url{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(PRD_RGC)} and
#' \url{https://www.arcgis.com/sharing/rest/content/items/0d5d0ad97af04e18bc584e4fc3bc62de/data}
#'
'location_types'

#' Entities
#'
#' An alternative view of the geographies included in the package, as listed in \code{location_types}, partitioned by countries
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{location_type}}{ An acronym for the geography, used as its id }
#'   \item{\code{country}}{ The name of the country }
#'   \item{\code{prog_id}}{ The foreign key against the \code{location_type} table }
#'   \item{\code{ordering}}{ The order to use to list the countries }
#'   \item{\code{code}}{ The code assumed for the various countries }
#'   \item{\code{name}}{ The name assumed in the various countries  }
#'   \item{\code{ons}}{ The acronym used by ONS as location type }
#'   \item{\code{N_ons}}{ The number of locations counted by ONS for the current geography type }
#'   \item{\code{N_pkg}}{ The number of locations found in the package for the current geography type }
#' }
#'
#' For further details, see \url{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(PRD_RGC)}
#'
'entities'

#' Hierarchies
#'
#' A list of mappings between each geography and its possible parents.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{hierarchy_id}}{ The id for each hierarchy (used in the \code{lookups} table) }
#'   \item{\code{child_type}}{ The type of the geography requested as child   }
#'   \item{\code{child_id}}{ The location id for the lower level of the mapping  }
#'   \item{\code{parent_type}}{ The type of the geography requested as parent }
#'   \item{\code{parent_id}}{ The location id for the upper level of the mapping }
#'   \item{\code{countries}}{ The countries for which the mapping is valid }
#'   \item{\code{is_exact}}{ Shows if the children nest exactly into each parent }
#'   \item{\code{is_direct}}{ Shows if the mapping is a direct link }
#'   \item{\code{listing}}{ Indicates if the mapping is suitable to be used for select controls }
#'   \item{\code{filtering}}{ Indicates if the mapping is suitable to be used for filtering }
#'   \item{\code{mapping}}{ Indicates if the mapping is suitable to be used for maps }
#'   \item{\code{charting}}{ Indicates if the mapping is suitable to be used for plots }
#' }
#'
'hierarchies'

#' Postcodes
#'
#' A list of all the \emph{Postcode Units} (\code{PCU}}) in the UK (with an associated \emph{grid reference} and not associated with a \emph{non-geographical} Postcode Sector),
#' as of AUG-22 (1,731,665 active, 876,691 terminated), together with their geographic coordinates (CRS 4326, WGS84), 
#' and the corresponding Output Area and \emph{current} Postcode Sector.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{PCU}}{ Postcode Unit in 7-chars format (the column \code{PCD} in the \code{ONSPD} file):
#'                      - 2, 3 or 4 character \emph{outward code}, left aligned; 
#'                      - 3 character \emph{inward code}, right aligned;
#'                      - 3rd and 4th characters may be blank }
#'   \item{\code{is_active}}{ Flag that indicates if the corresponding unit postcode is currently active or terminated }
#'   \item{\code{usertype}}{ Shows whether the postcode is a small or large user: 0 = small; 1 = large }
#'   \item{\code{x_lon}}{ The longitude coordinate of the geometric centroid }
#'   \item{\code{y_lat}}{ The latitude coordinate of the geometric centroid }
#'   \item{\code{OA}}{ Output area ONS code}
#'   \item{\code{PCS}}{ Postcode Sector (only related to active postcodes units) }
#'   \item{\code{RGN}}{ Region ONS code (for England only; the other Regions assumed the following pseudo codes: 
#'                      NIE_RGN = Northern Ireland, SCO_RGN = Scotland, WLS_RGN = Wales) }
#'   \item{\code{CTRY}}{ Country 3-chars code: ENG = England, NIE = Northern Ireland, SCO = Scotland, WLS = Wales }
#' }
#'
#' For further details, see \url{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(PRD_ONSPD)} and
#' \url{https://en.wikipedia.org/wiki/Postcodes_in_the_United_Kingdom}
#'
'postcodes'


#' pc_linkage
#'
#' A mapping between Postcode Sectors/Districts, related to terminated Units (but each table contains all records).
#'
#' @format A list including two data.table, \code{PCS} and \code{PCD}, with the following columns for \code{PCS}:
#' \describe{
#'   \item{\code{PCS.old}}{ The actual Postcode Sector corresponding to the rule }
#'   \item{\code{PCS}}{ The current Postcode Sector  corresponding to its location }
#' }
#' and similarly for \code{PCD}.
#'
'pc_linkage'

#' output_areas
#'
#' This dataset contains both a complete list of the UK \emph{Output Areas}, the smallest statistical geographic area in the UK,
#' with some of its characteristics, and a mapping between them and all the other Geographies contained in the package
#' (apart from Workplace Zones, which have a similar dedicated mapping dataset), as deployed and maintaned by \emph{ONS}.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{OA}}{Output Area. Theme: Census. Countries: ENSW. Total units: 232,296. Last updated: Dec-11 (Frozen). Base Layer. Direct Parent: LSOA}
#'   \item{\code{LSOA}}{Lower Layer Super Output Area. Theme: Census. Countries: ENSW. Total units: 42,619. Last updated: Dec-11 (Frozen). Built From OA. Direct Parent: MSOA}
#'   \item{\code{MSOA}}{Middle Layer Super Output Area. Theme: Census. Countries: ESW. Total units: 9,370. Last updated: Dec-11 (Frozen). Built From LSOA. Direct Parent: LAD}
#'   \item{\code{LAD}}{Local Authority & District. Theme: Census. Countries: ENSW. Total units: 363. Last updated: Dec-21. Built From MSOA. Direct Parent: CTY}
#'   \item{\code{CTY}}{County & Unitary Authority. Theme: Census. Countries: E. Total units: 93. Last updated: May-21. Built From LAD. Direct Parent: RGN}
#'   \item{\code{RGN}}{Region. Theme: Census. Countries: E. Total units: 12. Last updated: Dec-20 (Frozen). Built From CTY. Direct Parent: CTRY}
#'   \item{\code{CTRY}}{Country. Theme: Census. Countries: ENSW. Total units: 4. Last updated: Apr-21 (Frozen). Built From RGN}
#'   \item{\code{WPZ}}{Workplace Zone. Theme: Census. Countries: ENSW. Total units: 60,709. Last updated: Jul-05 (Frozen). Base Layer. Direct Parent: MSOA}
#'   \item{\code{PCS}}{Postcode Sector. Theme: Postal. Countries: ENSW. Total units: 9,437. Last updated: Feb-22. Built From OA. Direct Parent: PCD}
#'   \item{\code{PCD}}{Postcode District. Theme: Postal. Countries: ENSW. Total units: 2,799. Last updated: Feb-22. Built From PCS. Direct Parent: PCT}
#'   \item{\code{PCT}}{Post Town. Theme: Postal. Countries: ENSW. Total units: 1,427. Last updated: Feb-22. Built From PCD. Direct Parent: PCA}
#'   \item{\code{PCA}}{Postcode Area. Theme: Postal. Countries: ENSW. Total units: 121. Last updated: Feb-22. Built From PCT}
#'   \item{\code{PCON}}{Westminster Parliamentary Constituency. Theme: Electoral. Countries: ENSW. Total units: 650. Last updated: Dec-20. Built From OA}
#'   \item{\code{WARD}}{Electoral Ward. Theme: Electoral. Countries: ENSW. Total units: 8,875. Last updated: Dec-21. Built From OA}
#'   \item{\code{TTWA}}{Travel To Work Area. Theme: Urban. Countries: ENSW. Total units: 228. Last updated: Dec-11 (Frozen). Built From LSOA}
#'   \item{\code{MTC}}{Major Town or City. Theme: Urban. Countries: EW. Total units: 113. Last updated: Dec-15 (Frozen). Built From OA}
#'   \item{\code{BUA}}{Built-up Area. Theme: Urban. Countries: EW. Total units: 5,795. Last updated: Dec-11 (Frozen). Built From OA}
#'   \item{\code{BUAS}}{Built-up Area Sub-division. Theme: Urban. Countries: EW. Total units: 1,824. Last updated: Dec-11 (Frozen). Built From OA}
#'   \item{\code{PAR}}{Civil Parish or Unparished; Community. Theme: Social. Countries: EWS. Total units: 12,415. Last updated: Dec-20. Built From OA}
#'   \item{\code{PFN}}{Police Neighborhood. Theme: Social. Countries: ENSW. Total units: 4,814. Last updated: Dec-21. Built From OA}
#'   \item{\code{PFA}}{Police Force Area. Theme: Social. Countries: ENSW. Total units: 45. Last updated: Dec-20. Built From PFN}
#'   \item{\code{FRA}}{Fire Rescue Authority. Theme: Social. Countries: ENSW. Total units: 48. Last updated: May-21. Built From OA}
#'   \item{\code{CSP}}{Community Safety Partnership. Theme: Social. Countries: EW. Total units: 314. Last updated: Dec-20. Built From OA}
#'   \item{\code{LPA}}{Local Planning Authority. Theme: Social. Countries: ENSW. Total units: 397. Last updated: May-21. Built From OA}
#'   \item{\code{RGD}}{Registration District. Theme: Social. Countries: EW. Total units: 173. Last updated: Dec-20. Built From OA}
#'   \item{\code{LRF}}{Local Resilience Forum. Theme: Social. Countries: EW. Total units: 42. Last updated: Dec-20. Built From OA}
#'   \item{\code{CCG}}{Clinical Commissioning Group. Theme: Health. Countries: ENSW. Total units: 106. Last updated: Apr-21. Built From LSOA. Direct Parent: STP}
#'   \item{\code{STP}}{Sustainability and Transformation Partnership. Theme: Health. Countries: E. Total units: 42. Last updated: Apr-21. Built From CCG. Direct Parent: NHSO}
#'   \item{\code{NHSR}}{NHS England Region. Theme: Health. Countries: E. Total units: 7. Last updated: Apr-21. Built From NHSO}
#'   \item{\code{CIS}}{Covid Infection Survey. Theme: Health. Countries: ENSW. Total units: 133. Last updated: Dec-20. Built From OA}
#' }
#'
#' For further details, see the \code{Lookups} section within \url{https://geoportal.statistics.gov.uk/}
#' 
'output_areas'

#' workplace_zones
#'
#' This dataset contains both a complete list of the UK \emph{Workplace Zones}, a similar statistical geographic area as OAs but based on workers commuting patterns,
#' with some of its characteristics, and a mapping between them and MSOA, so that there is a link to some higher level geographies.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{WPZ}}{ Workplace Zone }
#'   \item{\code{MSOA}}{ Middle LAyer Super Output Area (NA for N.Ireland) }
#'   \item{\code{LAD}}{ Local Authority }
#'   \item{\code{RGN}}{ Region (England only) }
#'   \item{\code{CTRY}}{ Country }
#' }
#'
#' For further details, see \url{https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=name&tags=all(LUP_WZ_MSOA_LAD)}
#'
'workplace_zones'

#' locations
#'
#' A list of all the areas included in the \code{output_areas} dataset, together with some geographic characteristics, 
#' like various types of coordinates, Perimeter, and Area.
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{location_id}}{ The identifier for the Location }
#'   \item{\code{name}}{ The name for the location  }
#'   \item{\code{type}}{ The type as referenced in the \code{location_types} table }
#'   \item{\code{parent}}{ The code of the location in which the current location is contained as immediate level in its most direct hierarchy}
#'   \item{\code{ordering}}{ The preferred order in reporting results }
#'   \item{\code{x_lon}}{ The longitude coordinate of the geometric centroid }
#'   \item{\code{y_lat}}{ The latitude coordinate of the geometric centroid }
#'   \item{\code{px_lon}}{ The longitude coordinate of the pole of inaccessibility }
#'   \item{\code{py_lat}}{ The latitude coordinate of the pole of inaccessibility }
#'   \item{\code{wx_lon}}{ The longitude coordinate of the population weighted centroid }
#'   \item{\code{wy_lat}}{ The latitude coordinate of the population weighted centroid }
#'   \item{\code{perimeter}}{ The perimeter }
#'   \item{\code{area}}{ The area }
#'   \item{\code{bb_xmin}}{ The minimum longitude coordinate of the bounding box surrounding the polygon representing the location }
#'   \item{\code{bb_ymin}}{ The minimum latitude coordinate of the bounding box surrounding the polygon representing the location }
#'   \item{\code{bb_xmax}}{ The maximum longitude coordinate of the bounding box surrounding the the polygon representing the location }
#'   \item{\code{bb_ymax}}{ The maximum latitude coordinate of the bounding box surrounding the the polygon representing the location }
#' }
#'
#' For further details, see the \code{Names and Codes} section within \url{https://geoportal.statistics.gov.uk/}
#'
'locations'

#' lookups
#'
#' A list of all the geographies included in the \code{output_areas} dataset (apart from the Output Areas themselves and the Workplace Zones),
#' with their various mapping as described in the \code{hierarchies} table
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{hierarchy_id}}{ The id of the hierarchy, as found in the \code{hierarchies} table }
#'   \item{\code{parent_id}}{ The code of a parent area }
#'   \item{\code{child_id}}{ The codes of the children areas }
#' }
#'
'lookups'

#' neighbours
#'
#' This dataset contains the *1st order neighbours* for all the \emph{areas} listed in the table in \code{locations}
#'
#' @format A data.table with the following columns:
#' \describe{
#'   \item{\code{location_type}}{ The type of the location as referenced in the \code{location_types} table }
#'   \item{\code{location_id}}{ The code of an area }
#'   \item{\code{neighbour_id}}{ The 1st order neighbours of an area }
#' }
#'
'neighbours'
