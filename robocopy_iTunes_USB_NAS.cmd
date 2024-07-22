copy /y iTunes_USB_NAS.log iTunes_USB_NAS_old.log
Robocopy "D:\aniru\Music\iTunes\iTunes Media\Music" "E:\media\music\music" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:iTunes_USB_NAS.log
pause
