# (c) 2025 Anirudh Acharya
import argparse
import glob
import os

# Argument parsing
parser = argparse.ArgumentParser(
    description='Convert Foobar playlist paths to Rockbox format (Win2Mac version).'
)
parser.add_argument('--foobarpath', type=str, default='./playlists',
                    help='Path to Foobar playlists (default: %(default)s)')
parser.add_argument('--rockboxpath', type=str, default='./playlists',
                    help='Path to Rockbox playlists (default: %(default)s)')
parser.add_argument('--search_text', type=str, default='file:///Users/anirudh/Music/Music/Media.localized/Music',
                    help='Text to search for in playlist files (default: %(default)s)')
parser.add_argument('--replace_text', type=str, default='/mnt/ssd-media/media/music/music',
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
  

