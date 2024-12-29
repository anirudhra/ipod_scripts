#!/bin/sh
# (c) Anirudh Acharya 2024
# Script to generate NAS and iPod M3U playlists from iTunes Library XML file
#

basedir=${HOME}/Music/Playlists
nasplaylistsdir="${basedir}/nas_itunes_playlists"
nasplaylistsbackupdir="${nasplaylistsdir}_bak"
ituneslibraryxml="$basedir/Library.xml"
ipodplaylistsdir="${basedir}/ipod_itunes_playlists"
ipodplaylistsbackupdir="${ipodplaylistsdir}_bak"
localpathstring="file:///Users/anirudh/Music/MusicLibrary"
nasabspathstring="/mnt/ssd-media/media/music"
naspathstring="../music"
ipodpathstring="/Music"
nassync_playlistsdir=${HOME}/Music/MusicLibrary/playlists

#failsafe
mkdir -p "$basedir"
mkdir -p "$nassync_playlistsdir"

if [ ! -e "$ituneslibraryxml" ]; then
  echo "No iTunes Library found in $ituneslibraryxml!"
  exit
fi

# make backup of nas dir
rm -rf "$nasplaylistsbackupdir"
mv "$nasplaylistsdir" "$nasplaylistsbackupdir"
mkdir -p "$nasplaylistsdir"

#make backup of ipod dir
rm -rf "$ipodplaylistsbackupdir"
mv "$ipodplaylistsdir" "$ipodplaylistsbackupdir"
mkdir -p "$ipodplaylistsdir"

# export xml to m3u, convert to nas and ipod paths
./itunesexport -library "$ituneslibraryxml" -output "$nasplaylistsdir" -includeAllWithBuiltin
cp -r "$nasplaylistsdir"/* "$ipodplaylistsdir"

# preprocess escaped versions of path strings
localpathstring_esc=$(echo $localpathstring | sed 's_/_\\/_g')
naspathstring_esc=$(echo $naspathstring | sed 's_/_\\/_g')
ipodpathstring_esc=$(echo $ipodpathstring | sed 's_/_\\/_g')

# change to nas paths
cd $nasplaylistsdir
# use '|' as sed separator because the strings contain '\';
sed -i '' 's|'"$localpathstring_esc"'|'"$naspathstring_esc"'|g' *
cd -

# change to ipod paths
cd $ipodplaylistsdir
sed -i '' 's|'"$localpathstring_esc"'|'"$ipodpathstring_esc"'|g' *
cd -

# cleanup playlists
rm "$nasplaylistsdir/Tones.m3u"
rm "$nasplaylistsdir/Downloaded.m3u"
rm "$nasplaylistsdir/Dead Tracks.m3u"
mv "$nasplaylistsdir/Library.m3u" "$nasplaylistsdir/Full Library.m3u"

# cleanup ipod playlists, can't copy from nas playlists directory because paths are different
rm "$ipodplaylistsdir/Tones.m3u"
rm "$ipodplaylistsdir/Downloaded.m3u"
rm "$ipodplaylistsdir/Dead Tracks.m3u"
mv "$ipodplaylistsdir/Library.m3u" "$ipodplaylistsdir/Full Library.m3u"

# copy to playlists directory that's automatically sync'd with nas
# this playlist contains path that is relative to music direcotry instead of absolute
cp -r "$nasplaylistsdir"/* "$nassync_playlistsdir"
