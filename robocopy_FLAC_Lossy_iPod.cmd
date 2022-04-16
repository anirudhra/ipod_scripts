copy /y FLAC_iPod_Lossy.log FLAC_iPod_Lossy_old.log
copy /y FLAC_iPod_Lossless.log FLAC_iPod_Lossless_old.log
Robocopy "D:\BACKUP\music\Music\Lossless" "F:\Music\Lossless" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:FLAC_iPod_Lossless.log
Robocopy "D:\BACKUP\music\Music\Lossy" "F:\Music\Lossy" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:FLAC_iPod_Lossy.log

del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\--AUTOPLAYLISTS--.m3u"
del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\Not Imported Yet.m3u"
del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\Quicksearch.m3u"

REM ren F:\Playlists F:\iPodPlaylists
mkdir F:\Playlists
mkdir F:\RBPlaylists
del /f /q D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.*
copy /y D:\BACKUP\music\Music\Playlists\Foobar_Playlists\*.* D:\BACKUP\music\Music\Playlists\Rockbox_Playlists
python foobar_2_rockbox_playlists.py
del /f/q F:\RBPlaylists\*.*
copy /y D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.* F:\RBPlaylists
copy /y D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.* F:\Playlists
