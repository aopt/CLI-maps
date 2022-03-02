::---------------------------------------------------------------------------
::
::   Mike Bostock
::   Command-Line Cartography, Part 2
::   A tour of d3-geo’s new command-line interface.
:: 
::   https://medium.com/@mbostock/command-line-cartography-part-2-c3a82c5c0f3
::
::---------------------------------------------------------------------------

:: local environment variables
setlocal 

:: split json by adding newlines for readability
call npm install -g ndjson-cli
call ndjson-split d.features < ca-albers.json  > ca-albers.ndjson

:: set the id of each feature
call ndjson-map "d.id = d.properties.GEOID.slice(2), d" < ca-albers.ndjson > ca-albers-id.ndjson

:: get API key from https://api.census.gov/data/key_signup.html
:: mine is as follows (please request your own key)
set key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

::curl 'http://api.census.gov/data/2014/acs5?get=B01003_001E&for=tract:*&in=state:06' -o cb_2014_06_tract_B01003.json
:: https, slightly different path, add key, and use double quotes
curl "https://api.census.gov/data/2014/acs/acs5?get=B01003_001E&for=tract:*&in=state:06&key=%key%" -o cb_2014_06_tract_B01003.json


::  1. remove the newlines (ndjson-cat)
::  2. separate the array into multiple lines (ndjson-split)
::  3. reformat each line as an object (ndjson-map)
call ndjson-cat cb_2014_06_tract_B01003.json | ndjson-split "d.slice(1)" | ndjson-map "{id: d[2] + d[3], B01003: +d[0]}" > cb_2014_06_tract_B01003.ndjson


:: Join the population data to the geometry using ndjson-join
call ndjson-join "d.id" ca-albers-id.ndjson cb_2014_06_tract_B01003.ndjson > ca-albers-join.ndjson

:: compute the population density
call ndjson-map "d[0].properties = {density: Math.floor(d[1].B01003 / d[0].properties.ALAND * 2589975.2356)}, d[0]" < ca-albers-join.ndjson > ca-albers-density.ndjson

:: convert back to json
:: call ndjson-reduce < ca-albers-density.ndjson | ndjson-map "{type: ""FeatureCollection"", features: d}" > ca-albers-density.json
:: or directly:
call ndjson-reduce "p.features.push(d), p" "{type: ""FeatureCollection"", features: []}"  < ca-albers-density.ndjson > ca-albers-density.json


:: install d3.6
call npm install -g d3@6

:: create map
call ndjson-map -r d3 "(d.properties.fill = d3.scaleSequential(d3.interpolateViridis).domain([0, 4000])(d.properties.density), d)"  < ca-albers-density.ndjson  > ca-albers-color.ndjson

:: create svg
call geo2svg -n --stroke none -p 1 -w 960 -h 960  < ca-albers-color.ndjson > ca-albers-color.svg

:: launch browser
ca-albers-color.svg
