#!/bin/bash
. /Users/spencer.owen/Code/bitbar-astrobox/astrobox.config

# brew install fswatch
fswatch -0 $HOME/Desktop/foobar --event Created |while read -d "" event
do
  echo ${event}
  filename=$(basename -- "$event")
  extension="${filename##*.}"
  echo $extension
  if [ $extension == 'stl' ]; then
    X="$event" /usr/bin/osascript -e 'display notification system attribute "X"'
    curl -X POST \
    "${ASTROBOX_ENDPOINT}/api/files/local" \
    -H "X-Api-Key: ${ASTROBOX_APIKEY}" \
    -H 'content-type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW' \
    -F file=@${event}
    rm ${event}
  else
    X="STL files only" /usr/bin/osascript -e 'display notification system attribute "X"'
  fi
done
