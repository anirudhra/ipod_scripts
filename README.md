# iPod Classic Playlist Management, Sync Scripts and Utilities

* eq_presets contains rockbox parametric eq presets, save them to /EQ Presets directory on iPod
* foobar contains scripts to convert from Foobar to Rockbox M3U
* iPod_Utilities contains Windows utilities for extracting album art and converting playlists from proprietory iTunes/iPod DB to Rockbox accessible ones
* itunes_playlists_mac contains iTunes playlist management and music and playlists sync scripts for iPod and NAS/Server
* rockbox contains a snapshot of currently installed iPod Classic themes and album art in BMP
* Windows_scripts contains iPod/NAS/USB sync scripts for Windows

## iPod Music and Playlists Sync

iPod Music and Playlists sync scripts for rockbox are NOT in this repo. They are instead in the repo: https://github.com/anirudhra/pve_server, as .../pve_lxc_scripts/maintenance/ipodsync.sh. iPod sync needs to happen from PVE Server/NAS only. Script is POSIX compliant and should work both on Linux and macOS.
