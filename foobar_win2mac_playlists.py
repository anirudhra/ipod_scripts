import glob
import os

foobarpath = './playlists'
rockboxpath = './playlists'
search_text = "file:///Users/anirudh/Music/Music/Media.localized/Music"
replace_text = "/mnt/ssd-media/media/music/music"

for filename in glob.glob(os.path.join(rockboxpath, '*.m3u')):  
    with open(filename, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
        data = data.replace("\\", "/")
    file.close()
  
    with open(filename, 'w') as file:
        file.write(data)
    file.close()
  

