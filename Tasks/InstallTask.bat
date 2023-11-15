@echo off
SCHTASKS /CREATE /XML "C:\Program Files\SystemBanner\Tasks\SystemBanner.XML" /TN "SystemBanner" 
SCHTASKS /RUN /TN "SystemBanner" 