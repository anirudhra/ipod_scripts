import fnmatch
import os
import re

for file in os.listdir('.'):
    if fnmatch.fnmatch(file, '*bestwap*'):
        new_name = file
        new_name = re.sub(r"bestwap.in_\(", "", new_name)
        new_name = re.sub(r"bestwap.in_", "", new_name)
        new_name = re.sub(r"bestwap", "", new_name)
        new_name = re.sub(r"Bestwap", "", new_name)
        new_name = re.sub(r"\(", "", new_name)
        new_name = re.sub(r"\)", "", new_name)
        #new_name = re.sub(r"\.in_", "", new_name)
        #new_name = re.sub(r"\.in", "", new_name)
        new_name = re.sub(r"_.mp3", ".mp3", new_name)
        new_name = re.sub(r"^\_", "", new_name)
        #print(file."  ->  ".new_name)
        os.rename(file, new_name)
        print(new_name)
