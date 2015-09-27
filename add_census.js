var fs = require("fs");
var inquirer = require("inquirer");
var streamCSV = require("node-stream-csv");

var args = require('minimist')(process.argv.slice(2));

var properties = require("./census/properties.json"),
    fips = require("./census/fips.json"),
    reverse_index = {},
    options = [ new inquirer.Separator("Options:") ],
    choices;

if (args.type === "PUMAs") {
    properties = properties.IPUMS;
} else {
    properties = properties.Census;
}

Object.keys(properties).forEach(function(property) {
    reverse_index[properties[property]] = property;
    options.push({
        name: properties[property]
    });
});

function ask() {
    inquirer.prompt(
        {
            type: "checkbox",
            name: "census_properties",
            message: "Select the properties you'd like to bake in to your map file.",
            choices: options
        },
        function( answers ) {
            choices = answers.census_properties;
            inquirer.prompt(
                {
                    type: "confirm",
                    name: "is_this_correct",
                    message: "You chose: " + choices.join(", ") + ". Is that correct?",
                    default: true,
                },
                function( answers ) {
                    if (!answers.is_this_correct) {
                        ask();
                    } else {
                        add_data();
                    }
                }
            );
        }
    );
}

ask();

function add_data() {
    var index = {};

    choices.push("fips");
    var selected_properties = choices.map(function(property) { return reverse_index[property]; });

    // load the raw census data and filter down to the properties we've identified we might want in properties.json
    streamCSV({
    		filename: "census/ACS_13_5YR_DP05/ACS_13_5YR_DP05_with_ann.csv",
    		dontguess: "GEO.id,GEO.id2"
    	},
        function(line, c) {
        	var location = {};
        	for (var prop in line) {
                if (selected_properties.indexOf(prop) != -1) {
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

        			//geometry.properties.fips = index[geometry.id].fips;

                    choices.forEach(function(prop) {
    					if (index[geometry.id].hasOwnProperty(prop)) {
    						geometry.properties[prop] = index[geometry.id][prop];
    					} else {
    						console.log("Couldn't find a value for '" + prop + "' for " + geometry.properties.fips, " You might want to check case.");
    					}
    				});
    	    	});
    	    }
    	    fs.writeFileSync("./topojson/" + args._[0].replace(".json", ".data.json"), JSON.stringify(geography));
            console.log("Wrote your file to " + "./topojson/" + args._[0].replace(".json", ".data.json"));
        }       
    );
}