#!/usr/bin/env bash

# This script lets you define and download external openscad dependencies
# that your project may require.
#
# - You can define a dependencies.txt file in the same directory as this
#   bootstrap script, or you can pass in a filepath as $1
# - This file downloads all dependencies to: "./external"
# - Sets file attributes, if specified
#
# The dependencies.txt file might look like this:
#
#   adgaudio/shape_primitives.scad-->https://raw.githubusercontent.com/adgaudio/3dPrinter/master/lib/shape_primitives.scad
#
# Executable dependencies may also look like this:
#   openscad_exporter-->+x-->https://raw.githubusercontent.com/adgaudio/OpenSCAD-Tools/master/openscad_exporter
#
# Then, your openscad code might include this library:
#
#   include <adgaudio/shape_primitives.scad>
#
# And finally, openscad will know where the external libraries are if you define:
#
#   export OPENSCADPATH=./external:$OPENSCADPATH


DIR="$( cd "$( dirname "$0" )" && pwd )"
cmdfail="echo -ne \e[0;41;97mFAIL: "
if [ -z "$1" ] ; then
  dependencies_txt="./dependencies.txt"
else
  dependencies_txt="$1"
fi

set -e
set -u

echo downloading dependencies
while read line ; do
  [[ "$line" =~ ^\ *#.*$ ]] && echo skip $line && continue
  fname="./external/${line%%-->*}"
  url="${line##*-->}"
  echo $fname $url
  _middle="${line#*-->}"
  file_attrs="${_middle%%-->*}"
  if [ "$file_attrs" = "$url" ] ; then file_attrs="`expr 666 - $(umask)`" ; fi

  echo
  echo "GET $url"
  echo "WRITE $fname"
  mkdir -p "`dirname \"$fname\"`"
  cmdwget="wget -O "$fname" "$url""
  $cmdwget 2>/dev/null 1>/dev/null || {
    $cmdfail
    $cmdwget
  }
  chmod $file_attrs $fname
done < "$dependencies_txt"
echo successfully fetched dependencies


{
  echo -e "\n====="
  echo "OPENSCADPATH should be set in your OS environment"\
   "so downloaded files are available to openscad."
  echo "I suggest adding one of these two lines to your ~/.bashrc:"
  echo -en "\n\e[0;1;40;33m"
  echo "  export OPENSCADPATH=$DIR/external:\$OPENSCADPATH"
  echo "OR"
  echo "  export OPENSCADPATH=./external:\$OPENSCADPATH"
  exit 1
}

