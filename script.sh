#!/bin/bash


# Welcome message
echo ""
echo " .d88888b.                    888                    888   "
echo "d88P' 'Y88b                   888                    888    "
echo "888     888                   888                    888   "
echo "888     888 888  888  8888b.  888  888  .d88b.   .d88888   "
echo "888     888 888  888     '88b 888 .88P d8P  Y8b d88' 888    "
echo "888 Y8b 888 888  888 .d888888 888888K  88888888 888  888    "
echo "Y88b.Y8b88P Y88b 888 888  888 888 '88b Y8b.     Y88b 888   "
echo " 'Y888888'   'Y88888 'Y888888 888  888  'Y8888   'Y88888   "
echo "       Y8b                                           888   "
echo ""

# Prompt for ZIP code
read -p "    Enter your zip code: " zip_code

# Path to the ZIP code database
ZIP_DB="zipcodes/uszips.csv"

# Extract latitude and longitude from the CSV
location_data=$(grep -m 1 "^\"$zip_code\"" "$ZIP_DB")

# Error message for debugging
if [ -z "$location_data" ]; then
    echo "Invalid ZIP code or not found in database."
    exit 1
fi

# Define the variables
latitude=$(echo "$location_data" | awk -F',' '{print $2}' | tr -d '"')
longitude=$(echo "$location_data" | awk -F',' '{print $3}' | tr -d '"')

# Show the user
echo " "
echo "Location: $latitude, $longitude"
echo " "

# Pull the date so you only get recent events
get_2weeks_ago_timestamp() {
    date -u -d "14 days ago" +"%Y-%m-%dT%H:%M:%S"
}

# Call the function and store the result in a variable
twoweeks=$(get_2weeks_ago_timestamp)

# USGS API endpoint for earthquake data (past hour)
API_URL="https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&latitude=$latitude&longitude=$longitude&maxradiuskm=160&starttime=$twoweeks&minmagnitude=1"

# Fetch earthquake data
response=$(curl -s "$API_URL")

# Extract the number of earthquakes
quake_count=$(echo "$response" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')

# Be sad if there are no earthquakes
if [ -z "$quake_count" ] || [ "$quake_count" -eq 0 ]; then
    echo "No recent earthquakes within 100 miles."
    exit 0
fi

# Display the output to the user
echo "Recent earthquakes near your location:"
echo " "

# Extract and format earthquake details, write to quakes.txt
echo "$response" | grep -o '"mag":[0-9.]*\|"place":"[^"]*"\|"time":[0-9]*' | sed 's/"//g' |
while read -r line; do
    case "$line" in
        mag:*) magnitude=${line#*:} ;;
        place:*) location=${line#*:} ;;
        time:*)
            timestamp=${line#*:}
            date_time=$(date -d @"$((timestamp / 1000))" +"%Y-%m-%d %H:%M")
            echo "Magnitude: $magnitude | $location | $date_time"
            ;;
    esac
done > quakes.txt

# Print quakes.txt in reverse order
tac quakes.txt


read -p " " end

