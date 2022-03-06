@echo on
::---------------------------------------------------------------------------
::
::   Mike Bostock
::   Command-Line Cartography, Part 1
::   A tour of d3-geo’s new command-line interface.
:: 
::   https://medium.com/@mbostock/command-line-cartography-part-1-897aa8f8ca2c
::
::   Needs node.js. Install from: https://nodejs.org/en/download/
::
:: we translate UNIX command line to Windows CMD
::---------------------------------------------------------------------------



:: download shape file from Census Bureau (region 06 = California)
::
:: curl 'http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_06_tract_500k.zip' -o cb_2014_06_tract_500k.zip
:: use https instead, curl is part of windows
curl -O https://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_06_tract_500k.zip 


:: unzip -o cb_2014_06_tract_500k.zip
:: use tar instead (part of windows)
tar -xf cb_2014_06_tract_500k.zip


:: install node.js package
:: and extract geojson
call npm install -g shapefile
call shp2json cb_2014_06_tract_500k.shp -o ca.json

:: perform projection 
call npm install -g d3-geo-projection
call geoproject "d3.geoConicEqualArea().parallels([34, 40.5]).rotate([120, 0]).fitSize([960, 960], d)" < ca.json > ca-albers.json

:: create svg
call geo2svg -w 960 -h 960 < ca-albers.json > ca-albers.svg
start ca-albers.svg
