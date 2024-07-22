#!/bin/sh

rm -rf ./ipod_flac_playlists_backup
mv ./ipod_flac_playlists ./ipod_flac_playlists_backup
mkdir -p ./ipod_flac_playlists
./itunesexport -library ./SwinsianLibrary.xml -output ./ipod_flac_playlists -includeAllWithBuiltin
python3 ./mac2ipod_path.py
rm ./ipod_flac_playlists/Tones.m3u
mv "./pod_flac_playlists/Library.m3u" "./ipod_flac_playlists/Full Library.m3u"
