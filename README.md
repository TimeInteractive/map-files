Map Files from Time Interactives
=========

Make topoJSON files from SHP files with baked-in demographic data

## Why?

Many interactive maps need data on population or other Census measures for each state or county. It's annoying to load this in a separate file and then match it to the geographic units based on FIPS code.

## So you solved the problem all by yourself?

Heavens no. We [asked a question](https://groups.google.com/forum/#!topic/d3-js/a6VdcMv0VmU) and @mbostock [created a beautiful example](http://bl.ocks.org/mbostock/6320825) in about five minutes. This script takes a slightly different tack, however, because it's hard to find SHP files that have exactly the variables you want baked in already, and those that do often don't have borders clips to land boundaries. So this script makes regular topojson files and then enriches them with Census data.

## Yeah yeah, how do I use it:

	npm install
	./make.sh

You will be prompted to choose a type of geography (state, county, etc), and whether to pre-project it using the Albers USA projection.

You will then get a long list of variables that you can choose to attach to each locality in the topojson file. Enter the numbers corresponding to the variables that you want baked into your file. 

From there, the Node script called `add_census.js` picks up the topojson file and adds all the properties you requested, outputting a file prefixed with "rich_" in the `topojson` directory.

For example, I just made myself a pre-projected county file and chose to add data for the name, population, median age, and number of people over 65. When I peak inside `./topojson/rich_counties.preprojected.topo.json`, I see this as the first entry in the geometries array:

        {
          "type": "Polygon",
          "arcs": [
            [
              0,
              1,
              2,
              3,
              4
            ]
          ],
          "id": "01001",
          "properties": {
            "st": "01",
            "name": "Autauga County, Alabama",
            "state": "Alabama",
            "abbr": "AL",
            "fips": "01001",
            "population": 54907,
            "men": 26793,
            "women": 28114
          }
        }

## Sources
All shapefiles are downloaded from the Census Department's [TIGER/Line(R) Cartographic Boundary Shapefiles](https://www.census.gov/geo/maps-data/data/tiger-cart-boundary.html) page.
+ [States](http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_state_20m.zip)
+ [Counties](http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_county_500k.zip)
+ [Congressional districts](http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_cd114_500k.zip)

The Census data comes from table DP05 from the American Community Survey's 2013 5-year estimates. (The 1-year or 3-year samples tends to have too small a sample size for small counties.)

# License
Copyright (c) 2015, Time Magazine
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.