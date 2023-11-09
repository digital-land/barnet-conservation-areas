.SECONDARY:

DOCS=docs/index.html

IMAGES=\
	docs/img/MonkenHadley.png\
	docs/img/238231WoodStreetnoarticle4.png\
	docs/img/WatlingEstate.png\
	docs/img/MossHallCrescent.png\
	docs/img/GlenhillClose.png\
	docs/img/CollegefarmConservationArea.png\
	docs/img/HendonChurchEnd.png\
	docs/img/mapheathpassage.png\
	docs/img/CricklewoodRailwayterrace.png\
	docs/img/Totteridge.png\
	docs/img/MillHill.png\
	docs/img/FinchleyChurchEnd.png\
	docs/img/HGSboundary.png\
	docs/img/GoldersGreen.png\
	docs/img/TheBurroughsHendonCA.png\
	docs/img/229681FinchleyGardenVillage.png

SAVED=\
        docs/local-authority-district.geojson\
        docs/entities.geojson\
	docs/barnet.geojson

all:: $(DOCS) $(IMAGES) $(SAVED) $(DATA)

docs/index.html: template.html bin/render.py data/entities.csv
	@mkdir -p docs
	@touch docs/.nojekyll
	python3 bin/render.py

docs/local-authority-district.geojson:
	@mkdir -p docs
	curl -qfsL "https://www.planning.data.gov.uk/entity/8600286.geojson" > $@

docs/entities.geojson:
	@mkdir -p docs
	curl -qfsL 'https://www.planning.data.gov.uk/entity.geojson?dataset=conservation-area&geometry_curie=statistical-geography:E09000003&limit=500' > $@

docs/barnet.geojson: var/cache/barnet.gpkg
	@mkdir -p docs
	ogr2ogr -f GeoJSON -t_srs "EPSG:4326" $@ var/cache/barnet.gpkg

var/cache/barnet.gpkg:
	@mkdir -p var/cache/
	curl -qfsL 'https://open.barnet.gov.uk/download/20yo8/c6n/conservation_area.gpkg' > $@

var/cache/map/%.pdf:
	@mkdir -p var/cache/map/
	curl -qfsL 'https://www.barnet.gov.uk//sites/default/files/assets/citizenportal/documents/planningconservationandbuildingcontrol/$(notdir $@)' > $@

docs/img/%.jpg: var/cache/map/%.pdf
	@mkdir -p docs/img
	convert -density 150 $<[0] -quality 90 -resize 20% -background white -alpha remove -alpha off $@

docs/img/%.png: var/cache/map/%.pdf
	@mkdir -p docs/img
	convert -density 150 $<[0] -quality 90 -resize 20% -transparent white -alpha on $@

clean::
	rm -rf var docs

clobber::
	rm -f $(DOCS) $(IMAGES) $(SAVED)

server:
	python3 -m http.server --directory docs/

init::
	pip3 install -r requirements.txt
