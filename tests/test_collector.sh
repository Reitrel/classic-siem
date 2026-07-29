#!/bin/bash

# ================================================
# Classic SIEM - Test for the collector.sh module
# Version: 1.0
# Purpose: Automatic health check collector.sh
# Author:  Reitrel/Classic SIEM
# ================================================


# Error Counter
ERRORS=0

# Result
CHEK_RESULTS=""


# --- 1. Checking: Does the file exists collector.sh ---
echo "[1] Checking for file availability src/collector.sh"
if [ -f "src/collector.sh" ]; then
    CHEK_RESULTS+="      [ \u2705] The file has been found!\n"
    CHEK_RESULTS+="      [   ] The file not found\n\n"
else
    CHEK_RESULTS+="The file not found!\n"
    ERRORS=$((ERRORS+1))
fi



# --- 2. Verification of execution rights ---
echo "[2] Verification of execution rights"
if [ -x "src/collector.sh" ]; then
    CHEK_RESULTS+="      [ \u2705] Execution rights are available!\n"
    CHEK_RESULTS+="      [   ] There are no execution rights\n\n" 
else
    CHEK_RESULTS+="There are no execution rights!\n"
    ERRORS=$((ERRORS+1))
fi



# --- 3. Checking the creation of a directory for logs ---
echo "[3] Checking the creation of a directory for logs"
if [ -d "logs" ]; then
    CHEK_RESULTS+="      [ \u2705] The logs/ directory exists!\n"
    CHEK_RESULTS+="      [   ] The directory is absent\n\n"
else
    CHEK_RESULTS+="The directory is absent!\n"
    ERRORS=$((ERRORS+1))
fi



# --- 4. Running the script and cheching the result ---
echo "[4] Lauching the collector.sh"
./src/collector.sh


# Result
clear
echo "=============================================================================================="
echo "Classic SIEM - Testing Collector"
echo "=============================================================================================="

printf "$CHEK_RESULTS"



# Cheking if there is a new log file
LATEST_LOG=$(ls -t logs/collected_logs_*.log 2>/dev/null | head -n1)

if [ -f "$LATEST_LOG" ]; then
    CHEK_RESULTS+="      [ \u2705] The log-file has been created: $LATEST_LOG\n"
    CHEK_RESULTS+="      [   ] The log-file has not been created\n\n"
# We show the first 3 lines for confirmation
    echo "The first lines:"
    head -3 "$LATEST_LOG" | sed 's/^/      /'
else
    CHEK_RESULTS+="The log-file has not been created!"
    ERRORS=$((ERRORS+1))
fi

# Result
echo ""
echo "=============================================================================================="

if [ $ERRORS -eq 0 ]; then
    echo "ALL TESTS PASSED SUCCESSFULLY!!!"
    echo "Classic SIEM is working correctly!"
else
    echo "Errors detected: $ERRORS"
fi
echo "=============================================================================================="
echo ""













































