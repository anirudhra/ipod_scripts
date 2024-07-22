copy /y FLAC_USB_HDD.log FLAC_USB_HDD_old.log
Robocopy "D:\BACKUP\music\Music" "E:\BACKUP\music\Music" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:FLAC_USB_HDD.log
pause