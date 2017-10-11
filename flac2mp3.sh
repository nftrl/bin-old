#!/bin/bash

# Convert .flac to .mp3
# https://askubuntu.com/questions/385636/what-is-the-proper-way-to-convert-flac-files-to-320-kbit-sec-mp3

[[ $# == 0 ]] && set -- *.flac
for f; do
	avconv -i "$f" -qscale:a 0 "${f[@]/%flac/mp3}"
done
