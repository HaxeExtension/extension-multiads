#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove extension-multiads
haxelib local extension-multiads.zip
