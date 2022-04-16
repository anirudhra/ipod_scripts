copy /y iTunes_USB_HDD.log iTunes_USB_HDD_old.log
Robocopy "D:\aniru\Music\iTunes\iTunes Media\Music" "F:\BACKUP\music\iTunes" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:iTunes_USB_HDD.log
