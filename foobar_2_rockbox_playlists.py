import glob
import os

foobarpath = 'D:/BACKUP/music/Music/Playlists/Foobar_Playlists'
rockboxpath = 'D:/BACKUP/music/Music/Playlists/Rockbox_Playlists'
search_text = "D:\\BACKUP\\music\\Music\\"
replace_text = "/Music/"

for filename in glob.glob(os.path.join(rockboxpath, '*.m3u')):  
    with open(filename, 'r') as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
        data = data.replace("\\", "/")
    file.close()
  
    with open(filename, 'w') as file:
        file.write(data)
    file.close()
  
