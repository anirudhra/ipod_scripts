#!/bin/sh
# (c) Anirudh Acharya 2024
# Script to generate NAS and iPod M3U playlists from iTunes Library XML file
#

usage() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -b BASEDIR              Base directory for playlists (default: \"${HOME}/Music/Playlists\")"
  echo "  -l LOCALPATHSTRING      Local path string (default: file:///Users/anirudh/Music/MusicLibrary)"
  echo "  -n NASSYNC_PLAYLISTSDIR NAS sync playlists directory (default: \"${HOME}/Music/MusicLibrary/playlists\")"
  echo "  -a NASPATHSTRING        NAS path string (default: ..)"
  echo "  -p IPODPATHSTRING       iPod path string (default: /Music)"
  echo "  -h                      Show this help message and exit"
  exit 1
}

# Function to replace paths and clean up playlists
do_path_replace_and_cleanup() {
  playlistdir="$1"
  src_esc="$2"
  dst_esc="$3"

  cd "$playlistdir" || exit 1
  sed -i '' "s|$src_esc|$dst_esc|g" *
  cd -

  # Array of playlist files to remove
  files_to_remove=(
    "Tones.m3u"
    "Music.m3u"
    "Downloaded.m3u"
    "Dead Tracks.m3u"
  )
  for f in "${files_to_remove[@]}"; do
    rm "$playlistdir/$f"
  done

  mv "$playlistdir/Library.m3u" "$playlistdir/Full Library.m3u"
}

# Default values
basedir="${HOME}/Music/Playlists" # destination path for converted NAS and iPod playlists
localpathstring="file:///Users/anirudh/Music/MusicLibrary" # source path for iTunes Library XML file and Music
nassync_playlistsdir="${HOME}/Music/MusicLibrary/playlists" # destination path for NAS playlists auto sync'd
naspathstring=".."
ipodpathstring="/Music"

while getopts "b:l:n:a:p:h" opt; do
  case $opt in
    b) basedir="$OPTARG" ;;
    l) localpathstring="$OPTARG" ;;
    n) nassync_playlistsdir="$OPTARG" ;;
    a) naspathstring="$OPTARG" ;;
    p) ipodpathstring="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

nasplaylistsdir="${basedir}/nas_itunes_playlists"
nasplaylistsbackupdir="${nasplaylistsdir}_bak"
ituneslibraryxml="$basedir/Library.xml"
ipodplaylistsdir="${basedir}/ipod_itunes_playlists"
ipodplaylistsbackupdir="${ipodplaylistsdir}_bak"
#nasabspathstring="/mnt/pve-sata-ssd/ssd-media/media/music"
# use relative path instead of absolute, this shouls also work for ipod technically

#failsafe
mkdir -p "${nassync_playlistsdir}"

if [ ! -e "${ituneslibraryxml}" ]; then
  echo "No iTunes Library found in ${ituneslibraryxml}!"
  exit 1
fi

# make backup of nas dir
rm -rf "${nasplaylistsbackupdir}"
mv "${nasplaylistsdir}" "${nasplaylistsbackupdir}"
mkdir -p "${nasplaylistsdir}"

#make backup of ipod dir
rm -rf "${ipodplaylistsbackupdir}"
mv "${ipodplaylistsdir}" "${ipodplaylistsbackupdir}"
mkdir -p "${ipodplaylistsdir}"

# export xml to m3u, convert to nas and ipod paths
./itunesexport -library "${ituneslibraryxml}" -output "${nasplaylistsdir}" -includeAllWithBuiltin
cp -r "${nasplaylistsdir}"/* "${ipodplaylistsdir}"

# preprocess escaped versions of path strings
localpathstring_esc=$(echo ${localpathstring} | sed 's_/_\\/_g')
naspathstring_esc=$(echo ${naspathstring} | sed 's_/_\\/_g')
ipodpathstring_esc=$(echo ${ipodpathstring} | sed 's_/_\\/_g')

# change to nas paths and cleanup
#do_path_replace_and_cleanup <playlistdir> <src_esc> <dst_esc>
do_path_replace_and_cleanup "$nasplaylistsdir" "$localpathstring_esc" "$naspathstring_esc"
do_path_replace_and_cleanup "$ipodplaylistsdir" "$localpathstring_esc" "$ipodpathstring_esc"

# copy to playlists directory that's automatically sync'd with nas
# this playlist contains path that is relative to music direcotry instead of absolute
cp -r "${nasplaylistsdir}"/* "${nassync_playlistsdir}"

echo
echo All Done!
echo
