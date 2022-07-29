## Datasets related to UK Geographies

*Last update: 21-07-2022*

Do not use this package in production at the moment as it is still a work in progress. 

With a much longer delay than expected, I've been back to work on it, hoping for a final version by the end of August 2022, after the ONS AUG-22 Postcodes Directory update.

### Overview
This *R* package provides unified information about most geographical areas in the UK. All geographies, apart from *WPZ-Workplace Zone*, are built on top of the minimal *OA Output Area* (or *SA Small Area* as they are called in N.Ireland.). This means that some of the maps that you draw upon them are only a geographical approximation of the corresponding developed by the [ONS](https://geoportal.statistics.gov.uk/) (notice though that not all the boundaries found in the package are developed or shared by the *ONS*).


### Installation
The package is not on *CRAN* (it can't be due to its size). 

You can instead install this package from *github* as:
```
# install.packages("devtools")
devtools::install_github('lvalnegri/RgeoUK')
```

Notice that because of the mass of information contained the package file is actually quite big (110Mb), and it'll take a while for download and installation.

You can also installed my other package [RbndUK](https://github.com/lvalnegri/RbndUK) containing the digital vector in `sf` format of all the geographies included here.


### List of Datasets

The package contains the following datasets in `data.table` format:

 - **entities**
 
 - **location_types**
 
 - **hierarchies** 
 
 - **postcodes**
 
 - **output_areas**
 
 - **locations** 
 
 - **lookups**
 
 - **workplace_zones**
 
 - **neighbours** 
 
 The above datasets are also available in *CSV* format in the `data-raw/csv` folder, and can be downloaded directly from the repository. 
 
 In the `data-raw` folder you can also find:
 - in the `maps` subfolder, the comparison maps with the official boundaries and the ones built upon the *Output Areas* (for the geographies with no exact matching)
 - in the `shp` subfolder, the original boundaries in *shapefile* format as distributed by the official channels
 

### Resources

 - [Register of Geographic Codes](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_RGC))
 
 - [Code History Database](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_CHD))
 
 - [Hierarchical Representation of UK Statistical Geographies]()

 - [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD))

 - [NHS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_NHSPD))


### Attributions

 - Contains OS data © Crown copyright and database rights [2022] 
 
 - Contains National Statistics data © Crown copyright and database rights [2022] 
 
 - Source: Office for National Statistics licensed under the [Open Government Licence v.3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

 - Contains Parliamentary information licensed under the [Open Parliament Licence v3.0](https://www.parliament.uk/site-information/copyright/open-parliament-licence/)

 - Contains Royal Mail data © Royal Mail copyright and database rights [2022] 

 - (NI only) Contains or is based upon Land & Property Services (*LPS*) Intellectual Property subject to Crown copyright [[License](https://www.ons.gov.uk/file?uri=/methodology/geography/licences/lpsenduserlicenceoct11_tcm77-278044.doc)]
