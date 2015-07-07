var fs = require("fs");
var args = require('minimist')(process.argv.slice(2));
var streamCSV = require("node-stream-csv");

var properties = require("./census/properties.json");
var fips = require("./census/fips.json");
var index = {};


// load the raw census data and filter down to the properties we've identified we might want in properties.json
streamCSV({
		filename: "census/ACS_13_5YR_DP05/ACS_13_5YR_DP05_with_ann.csv",
		dontguess: "GEO.id,GEO.id2"
	},
    function(line, c) {
    	var location = {};
    	for (var prop in line) {
    		if (properties[prop]) {
    			location[properties[prop]] = line[prop];
    		}
    	}
    	index[location.fips] = location;
    },
    function() { // on close 
    	try {
	    	var geography = require("./topojson/" + args._[0]);
	    } catch (e) {
	    	console.log(e);
	    	return;
	    }
	    for (var geo_type in geography.objects) {
	    	var geometries = geography.objects[geo_type].geometries;
	    	geometries.forEach(function(geometry) {
	    		if (!geometry.properties) {
                    return;
	    		}
                if (!fips[geometry.properties.st]) {
                    //usually PR
                    //console.log("Couldn't find a FIPS code matching", geometry.properties.st);
                    return;
                }
	    		// they all have a FIPS code, so let's add state name and abbr
	    		geometry.properties.state = fips[geometry.properties.st][0];
	    		geometry.properties.abbr = fips[geometry.properties.st][1];

	    		//console.log(geometry);
                if (!index[geometry.id]) {
                    // usually Puerto Rico
                    //console.log("Couldn't find ID", geometry.id, "in the index (" + geometry.properties.st + ")");
                    return;
                }


    			geometry.properties.fips = index[geometry.id].fips;
    			if (args.properties) {
    				args.properties.split(",").forEach(function(prop) {
    					prop = prop.toLowerCase();
    					if (index[geometry.id].hasOwnProperty(prop)) {
    						geometry.properties[prop] = index[geometry.id][prop];
    					} else {
    						console.log("Couldn't find a value for '" + prop + "' for " + geometry.properties.fips);
    					}
    				});
    			}
	    	});
	    }
	    fs.writeFileSync("./topojson/rich_" + args._[0], JSON.stringify(geography));
        console.log("Wrote your file to " + "./topojson/rich_" + args._[0]);

    }       
);
