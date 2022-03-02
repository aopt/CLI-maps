::---------------------------------------------------------------------------
::
::   Mike Bostock
::   Command-Line Cartography, Part 3
::   A tour of d3-geo’s new command-line interface.
:: 
::   https://medium.com/@mbostock/command-line-cartography-part-4-82d0d26df0cf
::
::---------------------------------------------------------------------------


:: create map 
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3 "z = d3.scaleSequential(d3.interpolateViridis).domain([0, 4000]), d.features.forEach(f => f.properties.fill = z(f.properties.density)), d"  |^
ndjson-split "d.features"  | geo2svg -n --stroke none -p 1 -w 960 -h 960 > ca-tracts-color.svg
start ca-tracts-color.svg

:: sqrt transform
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3 "z = d3.scaleSequential(d3.interpolateViridis).domain([0, 100]), d.features.forEach(f => f.properties.fill = z(Math.sqrt(f.properties.density))), d" |^
ndjson-split "d.features" | geo2svg -n --stroke none -p 1 -w 960 -h 960 > ca-tracts-sqrt.svg
start ca-tracts-sqrt.svg

:: log transform
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3 "z = d3.scaleLog().domain(d3.extent(d.features.filter(f => f.properties.density), f => f.properties.density)).interpolate(() => d3.interpolateViridis), d.features.forEach(f => f.properties.fill = z(f.properties.density)), d" |^
ndjson-split "d.features" | geo2svg -n --stroke none -p 1 -w 960 -h 960  > ca-tracts-log.svg
start ca-tracts-log.svg

:: color quantiles
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3 "z = d3.scaleQuantile().domain(d.features.map(f => f.properties.density)).range(d3.quantize(d3.interpolateViridis, 256)), d.features.forEach(f => f.properties.fill = z(f.properties.density)), d"  |^
ndjson-split "d.features" | geo2svg -n --stroke none -p 1 -w 960 -h 960 > ca-tracts-quantile.svg
start ca-tracts-quantile.svg

:: other colors
:: call npm install -g d3-scale-chromatic  (not needed, also change the map command a bit)
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3  "z = d3.scaleThreshold().domain([1, 10, 50, 200, 500, 1000, 2000, 4000]).range(d3.schemeOrRd[9]), d.features.forEach(f => f.properties.fill = z(f.properties.density)), d" |^
ndjson-split "d.features" | geo2svg -n --stroke none -p 1 -w 960 -h 960 > ca-tracts-threshold.svg
start ca-tracts-threshold.svg


:: combine with county borders
call topo2geo tracts=- < ca-topo.json |^
ndjson-map -r d3 "z = d3.scaleThreshold().domain([1, 10, 50, 200, 500, 1000, 2000, 4000]).range(d3.schemeOrRd[9]), d.features.forEach(f => f.properties.fill = z(f.properties.density)), d" |^
ndjson-split "d.features" > geo.json
call topo2geo counties=- < ca-topo.json | ndjson-map "d.properties = {""stroke"": ""#000"", ""stroke-opacity"": 0.3}, d" >> geo.json
call geo2svg -n --stroke none -p 1 -w 960 -h 960 < geo1.json > ca.svg
start ca.svg