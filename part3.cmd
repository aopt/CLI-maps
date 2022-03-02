::---------------------------------------------------------------------------
::
::   Mike Bostock
::   Command-Line Cartography, Part 3
::   A tour of d3-geo’s new command-line interface.
:: 
::   https://medium.com/@mbostock/command-line-cartography-part-3-1158e4c55a1e
::
::---------------------------------------------------------------------------

:: for simplification topojson is a better representation
:: "TopoJSON facilitates topology-preserving simplification"
call npm install -g topojson

:: convert to TopoJSON (should reduce the size)
call geo2topo -n tracts=ca-albers-density.ndjson > ca-tracts-topo.json

:: simplify (should reduce the size even further)
call toposimplify -p 1 -f  < ca-tracts-topo.json  > ca-simple-topo.json

:: further reduction in size
call topoquantize 1e5 < ca-simple-topo.json > ca-quantized-topo.json

:: create county map by merging to 3 digit ids
call topomerge -k "d.id.slice(0, 3)" counties=tracts < ca-quantized-topo.json > ca-merge-topo.json

:: only keep internal boundaries
call topomerge --mesh -f "a !== b" counties=counties < ca-merge-topo.json > ca-topo.json

:: show layers
call topo2geo -l < ca-topo.json    
:: check counties
call topo2geo counties=ca-check-geo.json < ca-topo.json  
call geo2svg -n -p 1 -w 960 -h 960  < ca-check-geo.json > ca-check.svg
call ca-check.svg