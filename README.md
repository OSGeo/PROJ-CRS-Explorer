# crs-explorer
Browse on PROJ coordinate reference systems, fast and easy.

## Visit 
https://jjimenezshaw.github.io/crs-explorer/

Click on the map if you want to select only the systems that include that location. Select as well the type of CRS, and the authority of your interest. For EPSG systems you can click the code-link to visit their specs.

Selecting the checkboxes next to the "areas of use" will display a rectangle in the map.

## Why
Many people asked "Which coordinate (reference) system should I use in my project/country/state/location?" or "Really, there is a vertical one in my country?".

Well, instead of doing a research every time, just look what is available in [PROJ](https://proj.org).

PROJ includes an updated version of [EPSG](https://epsg.org) database, ESRI and some other authorities (looking for a deprecated ESRI CRS? visit [ESRI codes analyzer](https://github.com/jjimenezshaw/Esri-codes-analyzer)).

The behavior was inspired in https://cdn.proj.org (that shows the grid files from PROJ-data in a map) in combination with the option `--list-crs` of the program [projinfo](https://proj.org/apps/projinfo.html)


## Data generation
The static html page loads a json file generated from [PROJ](https://proj.org) with [pyproj](https://pyproj4.github.io/pyproj/stable/). 
To produce the `crslist.json` file you have to build pyproj with the desired version of PROJ. In my case, I did this:
 * export PROJ_DIR=~/proj_install_folder/
 * export PROJ_LIB=~/proj_install_folder/share/proj/
 * pip uninstall pyproj
 * pip install git+https://github.com/pyproj4/pyproj.git
 * python3 ./proj2json.py

## Thanks
 * [PROJ](https://proj.org)
 * [Leaflet](https://leafletjs.com/)
 * [OpenStreetMap](https://www.openstreetmap.org/) 