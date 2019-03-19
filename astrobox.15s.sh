#!/bin/bash
# <bitbar.title>Astrobox</bitbar.title>
# <bitbar.author>spuder</bitbar.author>
# <bitbar.author.github>spuder</bitbar.author.github>
# <bitbar.version>v0.1.0</bitbar.version>
# <bitbar.desc>3dprinter control with astrobox api</bitbar.desc>
# <bitbar.image>https://res-4.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_120,w_120,f_auto,b_white,q_auto:eco/v1415078489/p2ivykehjwdeqolokmll.png</bitbar.image>
# <bitbar.dependencies></bitbar.dependencies>

# TODO: change to relative path that also works with symlinks
. /Users/spencer.owen/Code/bitbar-astrobox/astrobox.config
if [[ -z "${ASTROBOX_APIKEY+x}" ]]; then
  echo "ASTROBOX_APIKEY is unset, please edit astrobox.config"
  exit 1
fi
if [[ -z "${ASTROBOX_ENDPOINT+x}" ]]; then
  echo "ASTROBOX_ENDPOINT is unset, please edit astrobox.config"
  exit 1
fi

JQ=/usr/local/bin/jq

if [[ ! -e $JQ ]]; then
  echo "please install 'jq' first"
  exit 1
fi

DEBUG=false
HEADER="X-Api-Key:$ASTROBOX_APIKEY"

# Request
# function runapi {
#   curl -s -gH "$HEADER" "$ASTROBOX_ENDPOINT/api/$1"
# 	return 0
# }
function getastrobox {
  astrobox_available=$(curl -s -I $ASTROBOX_ENDPOINT)
  return 0
}

# Get current state
function getprinter {
  printer=$(curl -s -X GET -H "${HEADER}" "${ASTROBOX_ENDPOINT}/api/printer")
  return 0
}
function getbed {
  bed=$(curl -s -X GET -H "${HEADER}" "${ASTROBOX_ENDPOINT}/api/printer/bed")
  return 0
}
function gettool {
  tool=$(curl -s -X GET -H "${HEADER}" "${ASTROBOX_ENDPOINT}/api/printer/tool")
  return 0
}

getastrobox

# Ready
if [[ -z $astrobox_available ]]; then
  echo "No astrobox"
else
  getprinter
  if [[ $(echo "$printer" | $JQ .state.flags.ready -r) = true ]]; then
    echo "Ready | color=green"
  elif [[ $(echo "$printer" | $JQ .state.flags.heatingUp -r) = true ]]; then
    getbed
    bedtarget=$(echo "$bed" | $JQ .bed.target -r)
    bedactual=$(echo "$bed" | $JQ .bed.actual -r)
    gettool
    tooltarget=$(echo "$tool" | $JQ .tool0.target -r)
    toolactual=$(echo "$tool" | $JQ .tool0.actual -r)
    echo "Heating | color=orange"
    echo "hotend:$toolactual/$tooltarget°C  bed:$bedactual/$bedtarget°C | color=black"
  elif [[ $(echo "$printer" | $JQ .state.flags.printing -r) = true ]]; then
    echo "Printing | color=red"
  else
    echo "No printer | color=white"
  fi
fi

