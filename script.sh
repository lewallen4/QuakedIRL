#!/bin/bash

# Welcome message
echo "                                Quaked"

# Prompt for ZIP code
read -p "    Enter your zip code: " zip_code

# Path to the ZIP code database (adjust this if necessary)
ZIP_DB="zipcodes/uszips.csv"

# Extract latitude and longitude from the CSV
location_data=$(grep -m 1 "^\"$zip_code\"" "$ZIP_DB")

if [ -z "$location_data" ]; then
    echo "Invalid ZIP code or not found in database."
    exit 1
fi

latitude=$(echo "$location_data" | awk -F',' '{print $2}' | tr -d '"')
longitude=$(echo "$location_data" | awk -F',' '{print $3}' | tr -d '"')

echo "Location: $latitude, $longitude"


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

if [ -z "$quake_count" ] || [ "$quake_count" -eq 0 ]; then
    echo "No recent earthquakes within 100 miles."
    exit 0
fi

echo "Recent earthquakes near your location:"

# Extract and format earthquake details
echo "$response" | grep -o '"mag":[0-9.]*\|"place":"[^"]*"\|"time":[0-9]*' | sed 's/"//g' |
while read -r line; do
    case "$line" in
        mag:*) magnitude=${line#*:} ;;
        place:*) location=${line#*:} ;;
        time:*)
            timestamp=${line#*:}
            date_time=$(date -d @"$((timestamp / 1000))" +"%Y-%m-%d %H:%M:%S")
            echo "Magnitude: $magnitude | Location: $location | Time: $date_time"
            ;;
    esac
done
