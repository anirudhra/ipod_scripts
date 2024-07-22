import glob
import os

rockboxpath = './Mac_Playlists'
search_text = "/Volumes/DATA/BACKUP/music/Music"
replace_text = "/Users/anirudh/Music/MusicLibrary"

for filename in glob.glob(os.path.join(rockboxpath, '*.m3u')):  
    print("Processing: " + filename)
    with open(filename, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
        data = data.replace("\\", "/")
    file.close()
  
    with open(filename, 'w') as file:
        file.write(data)
    file.close()
  

