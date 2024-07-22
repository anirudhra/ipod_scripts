copy /y iTunes_Server_NAS.log iTunes_Server_NAS_old.log
Robocopy "D:\aniru\Music\iTunes\iTunes Media\Music" "Z:\media\music\music" /MIR /XJD /R:5 /W:15 /MT:16 /V /NP /LOG:iTunes_Server_NAS.log
echo Done!
pause
