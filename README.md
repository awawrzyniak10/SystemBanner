# SystemBanner

-----
ABOUT
-----

SystemBanner is an application used to display relevant security classification information about the Windows systems it runs on.

For example, SystemBanner comes out of the box with Group Policy templates that can configure SystemBanner to display the different levels of United States Classified National Security Information as defined by EO 13526, as ammended, and United States Controlled Unclassified Information as defined by EO 13556, as ammended.

In addition, custom options implemented in Group Policy which sets relevant Registry values allow for other types of organizations to display custom messages and colors to warn users of Windows-based computers of the sensitivity of the information displayed, such as PII, PHI, Proprietary, or any kind of text-based marking or warning.

SystemBanner displays the selected message to the user as soon as they are logged into Windows. As the user connects to new monitors or resizes existing ones, SystemBanner regenerates new AppBars to accomodate those changes. If fullscreen apps are detected, or the user mouses over the SystemBanner, the opacity of the SystemBanner will decrease to allow visibility to objects behind the SystemBanner without fully hiding the relevant security information displayed. 

SystemBanner is a C# .NET Framework 4.7 Windows Forms Application that uses Scheduled Tasks, Group Policy and Registry values to maintain configuration variables and ensure that the application runs on logon. It uses the Win32 Shell AutoHideAppBarEX window type to generate AppBars on each screen. 

Unlike Microsoft NetBanner, which is unavailable to the public, full screen opacity choices ensure that full screen applications (like videos) do not fully cover the banner. Additionally, some applications that do not adhere to standard window formatting (like FireFox) which do obscure Microsoft NetBanner do not interfere with the visibility of SystemBanner's markings. Lastly, out of the box support for custom colors and CUI markings allows this application to be used in the Defense Industrial Base, private sector, and other locations where security banners are useful or required. 

SystemBanner has been tested to work on Windows 10 and Windows 11 with full functionality. Limited functionality may be available on other versions of Windows that support .NET Framework 4.7 or above (Such as Windows 11 or Windows Server 2016, 2019, and/or 2022).

------------
INSTALLATION
------------

To install SystemBanner, either install SystemBannerSetup.msi or download the project ZIP and run InstallSystemBanner.bat as an administrator. 

Each installer copies the SystemBanner Binary (SystemBanner.exe) to "C:\Program Files\SystemBanner", copies ADMX and ADML files (for Group Policy Functionality) to C:\Windows\PolicyDefinitions\ and C:\Windows\PolicyDefinitions\en-US\, creates a Scheduled Task for SystemBanner to run on logon of any user, and puts a Registry value into "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" to allow SystemBanner to be High DPI aware (ignore Windows Scaling). Lastly, it runs the scheduled task it made to start SystemBanner before exiting. 

-------
REMOVAL
-------

To remove SystemBanner, either remove SystemBannerSetup.msi or run RemoveSystemBanner.bat as an administrator.

Each removal method kills all running instances of SystemBanner.exe, then deletes "C:\Program Files\SystemBanner\SystemBanner.exe", the "C:\Program Files\SystemBanner" folder, all SystemBanner ADMX and ADML files from C:\Windows\PolicyDefinitions\ and C:\Windows\PolicyDefinitions\en-US\, and removes the scheduled task. Restarting Explorer.exe may clean up any remaining AppBar API calls that have not been cleaned up (the space the Banner makes for itself in the Windows UI).

--------------
ADMINISTRATION
--------------

SystemBanner comes out of the box with Group Policy templates to configure the security information displayed to the user. The ADMX/ADML files can be used to locally manage policy or can be loaded onto a domain's SYSVOL for domain-wide management. In either scenario, configuration items are located in Computer Configuration > Administrative Templates > SystemBanner. Once configuration changes are made, most are picked up by SystemBanner automatically while running. Custom color changes require an application restart at this time. 
