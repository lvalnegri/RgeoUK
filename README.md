## Datasets related to UK Geographies

Do not use this package at the moment as it is still a work in progress.

*Last update: 21-01-2021*

### Overview
This *R* package provides unified information about various geographical aresa in the UK. All geographies, apart from *WPZ-Workplace Zone*, are built on top of the minimal *OA Output Area*, or *SA Small Area* as it is called in N.Ireland. This means that some of the maps that you draw upon them are only an approximation of the corresponding developed by the [ONS]().


### Installation
The package is not on *CRAN*. 

You can instead install this package from *github* as:
```
# install.packages("devtools")
devtools::install_github('lvalnegri/dmpkg.geouk')
```

Notice that because of the mass of information contained the package file is actually quite big (110Mb), and it'll take a while for download and installation.


### List of Datasets

The following datasets are available both in *CSV* format, in the `data-raw` directory, and as *data.tables* in *RData* format in the `data` directory, ready to be called after installation:

 - **entities**
 
 - **location_types**
 
 - **hierarchies** 
 
 - **postcodes**
 
 - **output_areas**
 
 - **locations** 
 
 - **lookups**
 
 - **workplace_zones**
 
 - **neighbours** 


### Resources

 - [Register of Geographic Codes](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_RGC))
 
 - [Code History Database](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_CHD))
 
 - [Hierarchical Representation of UK Statistical Geographies]()

 - [ONS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD))

 - [NHS Postcode Directory](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_NHSPD))

 - 


### Attributions

 - Contains OS data © Crown copyright and database rights [2020] 
 
 - Contains National Statistics data © Crown copyright and database rights [2020] 
 
 - Source: Office for National Statistics licensed under the [Open Government Licence v.3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

 - Contains Parliamentary information licensed under the [Open Parliament Licence v3.0](https://www.parliament.uk/site-information/copyright/open-parliament-licence/)

 - Contains Royal Mail data © Royal Mail copyright and database rights [2020] 

 - (NI only) Contains or is based upon Land & Property Services (*LPS*) Intellectual Property subject to Crown copyright [[License](https://www.ons.gov.uk/file?uri=/methodology/geography/licences/lpsenduserlicenceoct11_tcm77-278044.doc)]
