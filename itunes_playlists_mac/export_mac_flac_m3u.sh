#!/bin/sh

rm -rf ./mac_flac_playlists_backup
mv ./mac_flac_playlists ./mac_flac_playlists_backup
mkdir -p ./mac_flac_playlists
./itunesexport -library ./SwinsianLibrary.xml -output ./mac_flac_playlists -includeAllWithBuiltin
#python3 ./mac2ipod_path.py
rm ./mac_flac_playlists/Tones.m3u
mv "./mac_flac_playlists/Library.m3u" "./mac_flac_playlists/Full Library.m3u"
