copy /y FLAC_iPod_Lossy.log FLAC_iPod_Lossy_old.log
copy /y FLAC_iPod_Lossless.log FLAC_iPod_Lossless_old.log
Robocopy "D:\BACKUP\music\Music\Lossless" "E:\Music\Lossless" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:FLAC_iPod_Lossless.log
Robocopy "D:\BACKUP\music\Music\Lossy" "E:\Music\Lossy" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:FLAC_iPod_Lossy.log

del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\--AUTOPLAYLISTS--.m3u"
del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\Not Imported Yet.m3u"
del /f /q "D:\BACKUP\music\Music\Playlists\Foobar_Playlists\Quicksearch.m3u"

REM ren F:\Playlists F:\iPodPlaylists
mkdir E:\Playlists
mkdir E:\RBPlaylists
del /f /q D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.*
del /f /q D:\BACKUP\music\Music\Playlists\Mac_Playlists\*.*
copy /y D:\BACKUP\music\Music\Playlists\Foobar_Playlists\*.* D:\BACKUP\music\Music\Playlists\Rockbox_Playlists
copy /y D:\BACKUP\music\Music\Playlists\Foobar_Playlists\*.* D:\BACKUP\music\Music\Playlists\Mac_Playlists
python foobar_win2mac_playlists.py
python foobar_2_rockbox_playlists.py
del /f/q E:\RBPlaylists\*.*
copy /y D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.* E:\RBPlaylists
copy /y D:\BACKUP\music\Music\Playlists\Rockbox_Playlists\*.* E:\Playlists
pause