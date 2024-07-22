#!/bin/sh

rm -rf ./nas_itunes_playlists_backup
mv ./nas_itunes_playlists ./nas_itunes_playlists_backup
mkdir ./nas_itunes_playlists
./itunesexport -library ./iTunesLibrary.xml -output ./nas_itunes_playlists -includeAllWithBuiltin
python3 ./mac2nas_path.py
rm ./nas_itunes_playlists/Tones.m3u
mv "./nas_itunes_playlists/Library.m3u" "./nas_itunes_playlists/Full Library.m3u"

