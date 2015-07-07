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


#echo "What sort of quantization do you want? Default is 1e5. You can just enter '6' for 1e6 if you want."
#read quantization

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
rm -rf shp


#now let's add some properties from the Census tables. First we'll load them from the JSON file

PROPERTIES=()

re=": \"(.*)\""
while IFS='' read -r line || [[ -n $line ]]; do
	if [[ $line =~ $re ]]; then
        name="${BASH_REMATCH[1]}"
        PROPERTIES+=($name);
    fi
done < "census/properties.json"

menu() {
    echo "Avaliable options:"
    for i in ${!PROPERTIES[@]}; do 
        printf "%3d%s) %s\n" $((i+1)) "${choices[i]:- }" "${PROPERTIES[i]}"
    done
    [[ "$msg" ]] && echo "$msg"; :
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#PROPERTIES[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${PROPERTIES[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

myprops=""
msg=""
for i in ${!PROPERTIES[@]}; do 
    [[ "${choices[i]}" ]] && { myprops+="${PROPERTIES[i]},"; }
done

#remove trailing comma
myprops="${myprops%?}";

echo "You chose $myprops";

node add_census.js "$topo_file" --properties="$myprops"