#!/usr/bin/env bash

path=""
PS3="Please choose a map type:"
select option in states counties congressional PUMAs
do
    case $option in
        states) 
            path="http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_state_20m.zip" 
            break
            ;;
        counties) 
            path="http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_county_500k.zip"
            break
            ;;
        congressional)
            path="http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_cd114_500k.zip"
            break
            ;; 
        PUMAs)
            path="../shp/USPUMAs.zip"
            break
            ;; 
        *) exit;;
    esac
done

#download and extract the SHP file we need
mkdir -p topojson;
mkdir -p temp; cd temp;

#PUMAs.zip is local
if [[ "$option" != 'PUMAs' ]]; then
	echo "Downloading $path";
	curl -# -O $path;
	filename=${path##*/}
	unzip "$filename";
	basename=${filename%.zip}
	id_property="GEOID"
else
	unzip "$path";
	basename="USPUMAs"
	id_property="GEOID10"
fi

#echo "What sort of quantization do you want? Default is 1e5. You can just enter '6' for 1e6 if you want."
#read quantization

select projection in "pre-projected" "not pre-projected"
do
    case $projection in
        pre-projected) 
				node --max_old_space_size=8192 ../node_modules/.bin/topojson \
				-q 1e5 \
				--simplify-proportion 0.25 \
				--projection 'd3.geo.albersUsa()' \
				--id-property="$id_property" \
				-p st=STATEFP,name=NAME \
				--out="../topojson/$option.preprojected.topo.json" \
				-- $option="$basename.shp"
		break
		;;
        "not pre-projected") 
				node --max_old_space_size=8192 ../node_modules/.bin/topojson \
				-q 1e5 \
				-s 100 \
				--id-property="$id_property" \
				-p st=STATEFP,name=NAME \
				--out="../topojson/$option.topo.json" \
				-- $option="$basename.shp"
		break
		;;
		*) exit;;
	esac
done

if [[ "$projection" == 'pre-projected' ]]; then
	topo_file="$option.preprojected.topo.json"
else 
	topo_file="$option.topo.json"
fi	

echo "$topo_file"

cd ..
rm -rf temp

#let's tell the Node scripts what source of data to use

node add_census.js "$topo_file" --type=$option