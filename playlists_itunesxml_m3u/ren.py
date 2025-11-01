import fnmatch
import os
import re

# Patterns to remove (replace with empty string)
remove_patterns = [
    r"bestwap.in_\(",
    r"bestwap.in_",
    r"bestwap",
    r"Bestwap",
    r"\(",
    r"\)",
]

for file in os.listdir('.'):
    if fnmatch.fnmatch(file, '*bestwap*'):
        new_name = file
        for pattern in remove_patterns:
            new_name = re.sub(pattern, "", new_name)
        #new_name = re.sub(r"\.in_", "", new_name)
        #new_name = re.sub(r"\.in", "", new_name)
        new_name = re.sub(r"_.mp3", ".mp3", new_name)
        new_name = re.sub(r"^_", "", new_name)
        #print(file."  ->  ".new_name)
        os.rename(file, new_name)
        print(new_name)
