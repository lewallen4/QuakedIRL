# Quaked - Earthquake Checker

Quaked is a simple Bash script that checks for recent earthquakes within **100 miles** of a given ZIP code using the USGS Earthquake API.

## Features
- Uses a local ZIP code database (`zipcodes/uszips.csv`) to find latitude and longitude.
- Queries the USGS Earthquake API for quakes in the past **two weeks**.
- Filters results by **minimum magnitude of 1.0**.
- Displays earthquake **magnitude, location, and time**.

## Requirements
- **GNU Coreutils** (for `date`, `grep`, `awk`, `sed`)
- **curl** (to fetch earthquake data)
- A ZIP code database in CSV format (`zipcodes/uszips.csv`)

## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/YOUR_GITHUB_USERNAME/Quaked.git
   cd Quaked

2. Ensure the script is executable:
   ```chmod +x quaked.sh

3. Install dependencies (if missing):
   ```sudo apt install curl  # Debian/Ubuntu
   brew install curl      # macOS