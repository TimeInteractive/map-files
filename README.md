Map Files from Time Interactives
=========

Common files for Javascript mapping with basic demographic data baked in

# Source
All shapefiles are downloaded from the "2010 Census Demographic Profile 1 — Shapefile Format" section of the Census Department's [TIGER/Line(R) Shapefiles Pre-joined with Demographic Data](http://www.census.gov/geo/maps-data/data/tiger-data.html) page.
+ [States](http://www2.census.gov/geo/tiger/TIGER2010DP1/State_2010Census_DP1.zip)
+ [Counties](http://www2.census.gov/geo/tiger/TIGER2010DP1/County_2010Census_DP1.zip)
+ [Congressional districts](http://www2.census.gov/geo/tiger/TIGER2010DP1/CD111_2010Census_DP1.zip)

# Conversions
The TopoJSON files are produced using the GDAL library's ```ogr2ogr``` function and the TopoJSON command-line tool, as elegantly described in [this StackOverflow response](http://stackoverflow.com/questions/14565963/topojson-for-congressional-districts) by Mike Bostock.

The large GeoJSON files produced in the intermedia stages of this conversion are preserved in the repo.

# Requirements

+ [GDAL](http://www.gdal.org/). Binaries are available for Windows and OSX. Linux machines can install with ```sudo apt-get install gdal-bin```
+ [TopoJSON](https://github.com/mbostock/topojson). Clone the respository or install using the [Bower package manager](https://github.com/bower/bower).

# Properties to preserve
The shapefiles from the demographic profiles page come with about [250 data points](https://docs.google.com/spreadsheet/pub?key=0AptyZVmKeGUidHA1WFRDekExb0tJS0RUeFRkdklqT0E&output=html),
most of which we don't need. By default, we'll hang on to these:
+ *DP0010001*: Total population
+ *DP0020001*: Median age, both sexes
+ *DP0040001*: Population 18+
+ *DP0110011*: White, not Hispanic
+ *DP0110012*: Black, not Hispanic
+ *DP0110013*: American Indian, not Hispanic
+ *DP0110014*: Asian, not Hispanic
+ *DP0110002*: Hispanic or Latino

The files also come with some basic political and geographic data points we need to preserve:
+ *GEOID10*: Geographic ID
+ *STUSPS10*: State name
+ *NAME10*: Name
+ *ALAND10*: Land area
+ *AWATER10*: Water area
+ *INTPTLAT10*: Latitude of the internal point
+ *INTPTLON10*: Longitude of the internal point

# Example commands: State files

    ogr2ogr -f GeoJSON geojson/states.json shp/State_2010Census_DP1.shp

