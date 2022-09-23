Several years ago i wrote some PowerShell to solve an issue for a client.  The issue in question was allow / deny USB storage devices;  only certain , IT supplied , devices could be used.   

The solution I came up with was to use PowerShell - it's a windows only environment, that checks the serial number of USB storage device on connection.  If the serial number matched that in a list, then it was approved. 


Serial numbers are stored as a JSON document using this format


{
    "ValidSerialNumbers": [
	    {"USBSerial":string}
	]
}

The document is called usb_serial.json and the PowerShell expects it to be located in C:\programdata\usbcontrol\

To install on a windows computer

*Create this directory structure  C:\programdata\usbcontrol\ 
*Copy CheckIfApprovedUSB.ps1 and CreateTaskScheduleUSBControl.ps1 into usbcontrol 
*Create and save the usb_serial.json file using the structure described above
*Run CreateTaskScheduleUSBControl.ps1 as a local admin.  This sets up a service that launchs powershell.exe using the CheckIfApprovedUSB.ps1  script.  
*USB storage allow / deny is logged in the Windows event log under 'CheckUSB'

This is not being actively developed but might be of use for someone out there. 

The other two PowerShell files, CreateTaskScheduleWPDControl.ps1 and CheckIfApprovedWPD.ps1, take care of allow / deny for storage present on digital cameras.

Sames format / process as the USB stuff, I ran out of time to merge it all together into one set of files. 

