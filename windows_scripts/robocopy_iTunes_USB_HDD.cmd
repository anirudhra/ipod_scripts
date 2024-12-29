copy /y iTunes_USB_HDD.log iTunes_USB_HDD_old.log
Robocopy "D:\Anirudh\Music\iTunes\iTunes Media\Music" "E:\BACKUP\music\iTunes" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:iTunes_USB_HDD.log
Robocopy "D:\BACKUP\music\iTunes" "E:\BACKUP\music\iTunes" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:iTunes_USB_HDD.log
pause