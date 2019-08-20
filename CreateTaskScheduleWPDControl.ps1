#Creates task schedule to launch powershell script that checks windows portable devices and only allows approved ones
#This powershell must be run from Admin prompt
#Assumes usb mass storage script is c:\programdata\usbcontrol\checkifapprovedwpd.ps1
#Change that in $schTaskArguments line if needed
#Error message if there is already a task called 'USBControl' is to be expected




#Variables for use with New-ScheduledTaskAction

$schTaskExecute = "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe"
$schTaskArguments = "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force ; Start-Process C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -ArgumentList '-noExit c:\programdata\usbcontrol\checkifapprovedwpd.ps1'"


# Variables for use with Register-ScheduledTask
$schTaskTrigger = New-ScheduledTaskTrigger -AtStartup

# Name that appears in Task Scheduler
$schTaskName = "WPDControl"
$schTaskUser = "NT AUTHORITY\SYSTEM"

# Does the task already exist on this device?


$schTaskExists = Get-ScheduledTask -TaskName $schTaskName -TaskPath \



if($schTaskExists) {
   #Task does exist, delete it
   Unregister-ScheduledTask -TaskName $schTaskName -Confirm:$false
   }

#Create scheduled task
$schTask= New-ScheduledTaskAction -Execute $schTaskExecute -Argument $schTaskArguments

Register-ScheduledTask -TaskName $schTaskName -User $schTaskUser -Action $schTask -RunLevel Highest -Trigger $schTaskTrigger



