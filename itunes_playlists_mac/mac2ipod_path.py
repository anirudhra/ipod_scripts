import glob
import os

foobarpath = "./ipod_flac_playlists"
rockboxpath = "./ipod_flac_playlists"
search_text = "file:///Users/anirudh/Music/MusicLibrary"
replace_text = "/Music"

for filename in glob.glob(os.path.join(rockboxpath, "*.m3u")):
    print("Processing: " + filename)
    with open(filename, "r") as file:
        data = file.read()
        data = data.replace(search_text, replace_text)
        data = data.replace("\\", "/")
    file.close()

    with open(filename, "w") as file:
        file.write(data)
    file.close()
