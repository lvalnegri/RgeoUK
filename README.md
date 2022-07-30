## Datasets related to UK Geographies

*Last update: 21-10-2021*

Do not use this package in production at the moment as it is still a work in progress. I hope to work on it for a final version after the ONS Nov-21 Postcodes Directory update.

### Overview
This *R* package provides unified information about most geographical areas in the UK. All geographies, apart from *WPZ-Workplace Zone*, are built on top of the minimal *OA Output Area* (or *SA Small Area* as they are called in N.Ireland.) This means that some of the maps that you draw upon them are only a geographical approximation of the corresponding developed by the [ONS](https://geoportal.statistics.gov.uk/) (notice though that not all the boundaries found in the package are developed or shared by the *ONS*).


### Installation
The package is not on *CRAN* (it can't be due to its size). 

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

 - [Register of Geographic Codes (March 2022)](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_RGC))
 
 - [Code History Database (December 2021)](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_CHD))
 
 - [Hierarchical Representation of UK Statistical Geographies (December 2021)](https://geoportal.statistics.gov.uk/documents/ons::hierarchical-representation-of-uk-statistical-geographies-december-2021/about)

 - [ONS Postcode Directory (May 2022)](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_ONSPD))

 - [NHS Postcode Directory (May 2022)](https://geoportal.statistics.gov.uk/search?collection=Dataset&sort=-created&tags=all(PRD_NHSPD))

 - [A Beginners Guide to UK Geography (v.1, 2021)](https://geoportal.statistics.gov.uk/documents/ons::a-beginners-guide-to-uk-geography-2021-v1-0/about)


### Attributions

 - Contains OS data © Crown copyright and database rights [2022] 
 
 - Contains National Statistics data © Crown copyright and database rights [2022] 
 
 - Source: Office for National Statistics licensed under the [Open Government Licence v.3.0](http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)

 - Contains Parliamentary information licensed under the [Open Parliament Licence v3.0](https://www.parliament.uk/site-information/copyright/open-parliament-licence/)

 - Contains Royal Mail data © Royal Mail copyright and database rights [2022] 

 - (NI only) Contains or is based upon Land & Property Services (*LPS*) Intellectual Property subject to Crown copyright [[License](https://www.ons.gov.uk/file?uri=/methodology/geography/licences/lpsenduserlicenceoct11_tcm77-278044.doc)]
