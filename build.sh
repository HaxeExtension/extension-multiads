#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f extension-multiads.zip
zip -r extension-multiads.zip extension haxelib.json include.xml
