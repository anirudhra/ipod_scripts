# (c) 2025 Anirudh Acharya
# This script converts Foobar playlists to Rockbox playlists.
# It searches for the text "D:\BACKUP\music\Music\" in the playlist files and replaces it with "/Music/".
# It also replaces all backslashes with forward slashes.
# It then saves the modified playlist files to the Rockbox playlists directory.
# It also creates a new playlist file in the Rockbox playlists directory with the name "foobar_playlists.m3u".
# It then copies the modified playlist files to the Rockbox playlists directory.

import argparse
import glob
import os

# Argument parsing
parser = argparse.ArgumentParser(
    description='Convert Foobar playlist paths to Rockbox format.'
)
parser.add_argument('--foobarpath', type=str, default='D:/BACKUP/music/Music/Playlists/Foobar_Playlists',
                    help='Path to Foobar playlists (default: %(default)s)')
parser.add_argument('--rockboxpath', type=str, default='D:/BACKUP/music/Music/Playlists/Rockbox_Playlists',
                    help='Path to Rockbox playlists (default: %(default)s)')
parser.add_argument('--search_text', type=str, default="D:\\BACKUP\\music\\Music\\",
                    help='Text to search for in playlist files (default: %(default)s)')
parser.add_argument('--replace_text', type=str, default='/Music/',
                    help='Text to replace search_text with (default: %(default)s)')
args = parser.parse_args()

foobarpath = args.foobarpath
rockboxpath = args.rockboxpath
search_text = args.search_text
replace_text = args.replace_text

for filename in glob.glob(os.path.join(rockboxpath, '*.m3u')):  
    with open(filename, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
        data = data.replace("\\", "/")
    file.close()
  
    with open(filename, 'w') as file:
        file.write(data)
    file.close()
  
