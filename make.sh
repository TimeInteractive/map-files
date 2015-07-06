#!/usr/bin/env bash
path=""
PS3="Please choose a map type:"
select option in states counties congressional
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
        *) exit;;
    esac
done

#download and extract the SHP file we need
mkdir -p topojson;
mkdir -p shp; cd shp;
echo "Downloading $path";
curl -# -O $path;
filename=${path##*/}
unzip "$filename";

basename=${filename%.zip}

select projection in "pre-projected" "not pre-projected"
do
    case $projection in
        pre-projected) 
				node --max_old_space_size=8192 ../node_modules/.bin/topojson \
				-q 1e5 \
				-s 1 \
				--projection 'd3.geo.albersUsa()' \
				--id-property=GEOID \
				-p st=STATEFP,name=NAME \
				--out="../topojson/$option.preprojected.topo.json" \
				-- $option="$basename.shp"
		break
		;;
        "not pre-projected") 
				node --max_old_space_size=8192 ../node_modules/.bin/topojson \
				-q 1e5 \
				-s 1 \
				--id-property=GEOID \
				-p fips=STATEFP,name=NAME \
				--out="../topojson/$option.topo.json" \
				-- $option="$basename.shp"
		break
		;;
		*) exit;;
	esac
done

cd ..
#rm -rf shp
