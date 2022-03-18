###########################################################
# UK GEOGRAPHY * 01 - Create database and tables in MySQL #
###########################################################

library(dmpkg.funs)

dbn <- 'geography_uk'

dd_create_db(dbn)

# LOCATION_TYPES ------------
x = "
    location_type CHAR(4) NOT NULL,
    ons_id CHAR(6) NULL,
    prog_id TINYINT UNSIGNED NOT NULL,
    name CHAR(50) NOT NULL,
    theme CHAR(15) NOT NULL,
    countries CHAR(4) NOT NULL,
    has_total_cover TINYINT UNSIGNED NOT NULL,
    has_dup TINYINT UNSIGNED NOT NULL,
    count_ons MEDIUMINT UNSIGNED NOT NULL,
    count_pkg MEDIUMINT UNSIGNED NOT NULL,
    max_child CHAR(4) NULL,
    min_parent CHAR(4) NULL,
    pref_filter CHAR(4) NULL, 
    pref_map CHAR(4) NULL,
    last_update CHAR(6) NOT NULL,
    has_comp_map TINYINT UNSIGNED NOT NULL,
    needs_update CHAR(3) NOT NULL,
    is_frozen TINYINT UNSIGNED NOT NULL,
    dts_id CHAR(32) NULL,
    bnd_id CHAR(32) NULL,
    PRIMARY KEY (location_type),
    UNIQUE INDEX (prog_id),
    INDEX (has_total_cover),
    INDEX (has_dup),
    INDEX (has_comp_map),
    INDEX (needs_update),
    INDEX (is_frozen)
"
dd_create_dbtable('location_types', dbn, x)

# ENTITIES ------------
x = "
    location_type CHAR(4) NOT NULL,
    countries CHAR(15) NOT NULL,
    prog_id TINYINT UNSIGNED NOT NULL,
    ordering TINYINT UNSIGNED NOT NULL,
    code CHAR(4) NULL,
    name CHAR(50) NULL,
    ons CHAR(5) NULL,
    N_ons MEDIUMINT UNSIGNED NOT NULL,
    N_pkg MEDIUMINT UNSIGNED NOT NULL,
    PRIMARY KEY (prog_id, ordering)
"
dd_create_dbtable('entities', dbn, x)

# HIERARCHIES ---------------
x = "
    hierarchy_id SMALLINT(4) UNSIGNED NOT NULL,
    child_type CHAR(4) NOT NULL,
    child_id TINYINT(2) UNSIGNED NOT NULL,
    parent_type CHAR(4) NOT NULL,
    parent_id TINYINT(2) UNSIGNED NOT NULL,
    countries CHAR(4) NOT NULL,
    is_exact TINYINT(1) UNSIGNED NOT NULL,
    is_direct TINYINT(1) UNSIGNED NOT NULL,
    listing TINYINT(1) UNSIGNED NOT NULL,
    charting TINYINT(1) UNSIGNED NOT NULL,
    filtering TINYINT(1) UNSIGNED NOT NULL,
    mapping TINYINT(1) UNSIGNED NOT NULL,
    PRIMARY KEY (hierarchy_id),
    INDEX (child_type),
    INDEX (child_id),
    INDEX (parent_type),
    INDEX (parent_id),
    INDEX (countries),
    INDEX (is_exact),
    INDEX (listing),
    INDEX (charting),
    INDEX (filtering),
    INDEX (mapping)
"
dd_create_dbtable('hierarchies', dbn, x)

# POSTCODES -----------------
x <- "
    PCU CHAR(7) NOT NULL COMMENT 'postcode in 7-chars format: 4-chars outcode + 3-chars incode',
    is_active TINYINT(1) UNSIGNED NOT NULL,
    usertype TINYINT(1) UNSIGNED NOT NULL COMMENT '0- small user, 1- large user (large means addresses receiving more than 25 items per day)',
    x_lon DECIMAL(7,6) NOT NULL COMMENT 'longitude of the geometric centroid of the postcode',
    y_lat DECIMAL(8,6) UNSIGNED NOT NULL COMMENT 'latitude of the geometric centroid of the postcode',
    OA CHAR(9) NOT NULL COMMENT 'Output Area (E00, W00, S00, N00)',
    RGN CHAR(9) NULL DEFAULT NULL COMMENT 'Region (E12; England Only)',
    CTRY CHAR(1) NOT NULL COMMENT 'Country (E92, W92, S92, N92)',
    PCS CHAR(5) NULL DEFAULT NULL COMMENT 'PostCode Sector: outcode plus 1st digit incode',
    WPZ CHAR(9) NOT NULL COMMENT 'Workplace Zone (E33, N19, S34, W35)',
    PRIMARY KEY (PCU),
    INDEX (is_active),
    INDEX (usertype),
    INDEX (OA),
    INDEX (PCS),
    INDEX (WPZ),
    INDEX (RGN),
    INDEX (CTRY),
    INDEX (WPZ)
"
dd_create_dbtable('postcodes', dbn, x)

# OUTPUT AREAS --------------
x <- "
    OA CHAR(9) NOT NULL COMMENT 'Output Area [Census]',
    LSOA CHAR(9) NOT NULL COMMENT 'Lower Layer Super Output Area (E01, W01, S01, N01) [Census]',
    MSOA CHAR(9) NULL DEFAULT NULL COMMENT 'Middle Layer Super Output Area (E02, W02, S02; England, Wales and Scotland Only; NIE, pseudo similar to LSOA) [Census]',
    PAR CHAR(9) NULL DEFAULT NULL COMMENT 'Civil Parish (E04, W04; England and Wales Only; Partial Coverage England Only) [Admin]',
    LAD CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Local Authority District (UA-E06/W06, LAD-E07, MD-E08, LB-E09, CA-S12, DCA-N09) [Admin]',
    CTY CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'County (C-E10, MC-E11, IOL-E13, plus LAD-E060=>E069; England Only; pseudo: WLS_CTY, SCO_CTY, NIE_CTY) [Admin]',
    RGN CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Region (E12; England Only; pseudo: WLS_RGN, SCO_RGN, NIE_RGN) [Admin]',
    CTRY CHAR(3) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Country (E92 = ENG, W92 = WLS, S92 = SCO, N92 = NIE) [Admin]',
    PCS CHAR(5) NOT NULL COMMENT 'PostCode Sector: outcode plus 1st digit incode [Postal]',
    PCD CHAR(4) NOT NULL COMMENT 'PostCode District: same as outcode [Postal]',
    PCT CHAR(7) NOT NULL COMMENT 'Post Town (does not link up to PCA!) [Postal]',
    PCA CHAR(2) NOT NULL COMMENT 'PostCode Area: letters only in outcode [Postal]',
    PCON CHAR(9) NOT NULL COMMENT 'Westminster Parliamentary Constituency (E14, W07, S14, N06) [Electoral]',
    PDT CHAR(5) NULL DEFAULT NULL COMMENT 'Polling Districts (England only; Partial Coverage; source is Ordnance Survey, not ONS) [Electoral]',
    WARD CHAR(9) NOT NULL COMMENT 'Electoral Ward (E05, W05, S13, N08) [Electoral]',
    CED CHAR(9) NOT NULL COMMENT 'County Electoral division (E14, W07, S14, N06) [Electoral]',
    TTWA CHAR(9) NOT NULL COMMENT 'Travel To Work Area (E30, W22, S22, N12, K01 for overlapping zones) [Urban]',
    MTC CHAR(9) NULL DEFAULT NULL COMMENT 'Major Town or Centre (J01; England and Wales Only; Partial Coverage) [Urban]',
    BUA CHAR(9) NULL DEFAULT NULL COMMENT 'Built-up Area (E34, W37, K05 for overlapping zones; England and Wales Only; Partial Coverage) [Urban]',
    BUAS CHAR(9) NULL DEFAULT NULL COMMENT 'Built-up Subdivision (E35, W38, K06 for overlapping zones; England and Wales Only; Partial Coverage) [Urban]',
    PFN SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Police Force Neighborhood (not ONS, see data.police.uk and www.police.uk/pu/your-area/) [Crime]',
    PFA CHAR(9) NOT NULL COMMENT 'Police Force Area (E23, W15, S32, N24) [Crime]',
    CSP CHAR(9) NULL DEFAULT NULL COMMENT 'Community Safety Partnership (E22, W14; England and Wales Only) [Crime]',
    FRA CHAR(9) NULL DEFAULT NULL COMMENT 'Fire Rescue Authority (E31, W25; England and Wales Only) [Social]',
    LPA CHAR(9) NOT NULL COMMENT 'Local Planning Authority (E60, W43, S44, N13) [Social]',
    RGD CHAR(9) NULL DEFAULT NULL COMMENT 'Registration District (E28, W20; England and Wales Only) [Social]',
    LRF CHAR(9) NULL DEFAULT NULL COMMENT 'Local Resilience Forum (E48, W41; England and Wales Only) [Social]',
    CCG CHAR(9) NOT NULL COMMENT 'Clinical Commissioning Group (E38, W11, S03, ZC) [Health]',
    STP CHAR(9) NULL DEFAULT NULL COMMENT 'Sustainability and Transformation Partnership (E54; England Only) [Health]',
    NHSR CHAR(9) NULL DEFAULT NULL COMMENT 'NHS Region (E40; England Only) [Health]',
    CIS CHAR(9) NOT NULL COMMENT 'Covid Infection Survey (J06 for all UK) [Health]',
    PRIMARY KEY (OA),
    INDEX LSOA (LSOA),
    INDEX MSOA (MSOA),
    INDEX PAR (PAR),
    INDEX LAD (LAD),
    INDEX CTY (CTY),
    INDEX RGN (RGN),
    INDEX CTRY (CTRY),
    INDEX PCS (PCS),
    INDEX PCD (PCD),
    INDEX PCT (PCT),
    INDEX PCA (PCA),
    INDEX PCON (PCON),
    INDEX PDT (PDT),
    INDEX WARD (WARD),
    INDEX CED (CED),
    INDEX TTWA (TTWA),
    INDEX MTC (MTC),
    INDEX BUA (BUA),
    INDEX BUAS (BUAS),
    INDEX PFN (PFN),
    INDEX PFA (PFA),
    INDEX CSP (CSP),
    INDEX FRA (FRA),
    INDEX LPA (LPA),
    INDEX RGD (RGD),
    INDEX LRF (LRF),
    INDEX CCG (CCG),
    INDEX STP (STP),
    INDEX NHSR (NHSR),
    INDEX CIS (CIS)
"
dd_create_dbtable('output_areas', dbn, x)

# WORKPLACE ZONES -----------
x <- "
    WPZ CHAR(9) NOT NULL COMMENT 'Workplace Zone (E33, N19, S34, W35)',
    MSOA CHAR(9) NULL DEFAULT NULL COMMENT 'Middle Layer Super Output Area (E02, W02, S02; England, Wales and Scotland Only; NIE, pseudo similar to LSOA)',
    LAD CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Local Authority District (UA-E06/W06, LAD-E07, MD-E08, LB-E09, CA-S12, DCA-N09)',
    CTY CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'County (C-E10, MC-E11, IOL-E13, plus LAD-E060=>E069; England Only; pseudo: WLS_CTY, SCO_CTY, NIE_CTY)',
    RGN CHAR(9) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Region (E12; England Only; pseudo: WLS_RGN, SCO_RGN, NIE_RGN)',
    CTRY CHAR(3) NOT NULL COLLATE 'utf8_unicode_ci' COMMENT 'Country (E92 = ENG, W92 = WLS, S92 = SCO, N92 = NIE)',
    PRIMARY KEY (WPZ),
    INDEX MSOA (MSOA),
    INDEX LAD (LAD),
    INDEX CTY (CTY),
    INDEX RGN (RGN),
    INDEX CTRY (CTRY)
"
dd_create_dbtable('workplace_zones', dbn, x)

# LOCATIONS -----------------
x <- "
    location_type CHAR(4) NOT NULL COMMENT 'foreign key to location_types.location_type',
    location_id CHAR(9) NOT NULL COMMENT 'see output_areas for column equal to location_types.location_type',
    name CHAR(75) NOT NULL,
    x_lon DECIMAL(8,6) NULL DEFAULT NULL COMMENT 'longitude for the Geometric Centroid',
    y_lat DECIMAL(8,6) UNSIGNED NULL DEFAULT NULL COMMENT 'latitude for the Geometric Centroid',
    px_lon DECIMAL(8,6) NULL DEFAULT NULL COMMENT 'longitude for the Pole of inaccessibility',
    py_lat DECIMAL(8,6) UNSIGNED NULL DEFAULT NULL COMMENT 'latitude for the Pole of inaccessibility',
    wx_lon DECIMAL(8,6) NULL DEFAULT NULL COMMENT 'longitude for the Population Weigthed centroid',
    wy_lat DECIMAL(8,6) UNSIGNED NULL DEFAULT NULL COMMENT 'latitude for the Population Weigthed centroid',
    perimeter MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL,
    area INT(10) UNSIGNED NULL DEFAULT NULL,
    PRIMARY KEY (location_id),
    INDEX (location_type)
"
dd_create_dbtable('locations', dbn, x)

# LOOKUPS -------------------
x = "
    hierarchy_id SMALLINT(4) UNSIGNED NOT NULL COMMENT 'foreign key to hierarchies.hierarchy_id',
    child_id CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    parent_id CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    INDEX (hierarchy_id),
    INDEX (child_id),
    INDEX (parent_id)
"
dd_create_dbtable('lookups', dbn, x)

# NEIGHBOURS ----------------
x = "
    location_type CHAR(4) NOT NULL COMMENT 'foreign key to location_types.location_type',
    location_id CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    neighbour_id CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    distance MEDIUMINT(7) UNSIGNED NOT NULL COMMENT 'Vincenty (ellipsoid) great circle distance, see http://www.movable-type.co.uk/scripts/latlong-vincenty.html',
    INDEX (location_type),
    INDEX (location_id),
    INDEX (neighbour_id)
"
dd_create_dbtable('neighbours', dbn, x)

# DISTANCES -----------------
x = "
    location_type CHAR(4) NOT NULL COMMENT 'foreign key to location_types.location_type',
    location_ida CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    location_idb CHAR(9) NOT NULL COMMENT 'foreign key to locations.location_id',
    distance MEDIUMINT(7) UNSIGNED NOT NULL COMMENT 'Vincenty (ellipsoid) great circle distance, see http://www.movable-type.co.uk/scripts/latlong-vincenty.html',
    INDEX (location_type),
    INDEX (location_ida),
    INDEX (location_idb)
"
dd_create_dbtable('distances', dbn, x)

rm(list = ls())
gc()
