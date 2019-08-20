# Unregister this event only

Unregister-Event RemovableWPDDetection -Force

# $query = "SELECT * FROM __InstanceOperationEvent WITHIN 5 WHERE TargetInstance ISA 'Win32_LogicalDisk' AND TargetInstance.DriveType=2"


$query = "SELECT * From __InstanceOperationEvent WITHIN 5 Where TargetInstance ISA 'Win32_PNPEntity' And TargetInstance.Service='WUDFWpdMtp' "

$action = {
	$strUSBSerialFilename = "C:\programdata\usbcontrol\wpd_serial.json" 
	$strClass = $eventArgs.NewEvent.__CLASS
	$strPNPdeviceID = $eventArgs.NewEvent.TargetInstance.DeviceID
    $arraySplitPNPdeviceID = $strPNPdeviceID.split("\")
	$strConnectedUSBSerial = $arraySplitPNPdeviceID[-1]
	$strlogfile = 'c:\programdata\usbcontrol\wpdcontrol.log'
	$strdatetime = Get-Date
	$strdatetime = $strdatetime.GetDateTimeFormats()[19]
	
	function Read-approved-USB($strFileWithPath) {
	if(Test-Path $strFileWithPath) {
        $tempObj = $null 
        try {   
			$tempObj = Get-Content -Raw -Path $strFileWithPath | ConvertFrom-Json
			
			Write-Output $tempObj # Return powershell representation of JSON file back .  Must have this line.  
			}
		catch {
			$ErrorMessage = $_.Exception.Message

			$FailedItem = $_.Exception.ItemName
			
			$strMessageToSend = "WPD [$strdatetime] Error: $ErrorMessage for $FailedItem"
			
			Write-Host " $strMessageToSend "
			
			Write-Output " $strMessageToSend " | Out-File $strlogfile -Append
			
            Write-Error $StrMessageToSend -ErrorAction Stop
			}
        }
	}
	
	function Check-for-approved-USB ($strSerialFileName, $strConUSBSerial) { 
	$IntReturnValue = 0
	
	$objSerials = Read-approved-USB $strSerialFileName
	
	$objSerials.ValidSerialNumbers | foreach {
		$ApprovedSN = $_; if ($ApprovedSN.USBSerial -eq $strConUSBSerial) {        
				#The USB serial is on the approved list, indicate that by setting IntReturnValue to 1
				$IntReturnValue = 1
				$strMessageToSend = "WPD [$strdatetime]JSON value: " + $ApprovedSN.USBSerial + " Equals " +  $USBSerialNumber
				Write-Host "$strMessageToSend"
				Write-Output "$strMessageToSend " | Out-File $strlogfile -Append
				}
			else {
				$strMessageToSend = "WPD [$strdatetime] JSON value: " + $ApprovedSN.USBSerial + " Not equals " +  $USBSerialNumber
				Write-Host " $strMessageToSend"  
				Write-Output "$strMessageToSend " | Out-File $strlogfile -Append
				}
		}
	Write-Output $IntReturnValue
    }

	
	switch($strClass)
	{
		__InstanceCreationEvent {
			$intApprovedUSB = 0
			Disable-PnpDevice -InstanceId $strPNPdeviceID -Confirm:$false
			$intApprovedUSB = Check-for-approved-USB $strUSBSerialFilename $strConnectedUSBSerial
			
			$strMessageToSend = "WPD [$strdatetime] Insertion event for $strPNPdeviceID. Check if approved returned: $intApprovedUSB"
			
			Write-Host $strMessageToSend
			Write-Output " $strMessageToSend " | Out-File $strlogfile -Append			
			
			if ($intApprovedUSB -eq 1 ) {
				$strMessageToSend = "WPD [$strdatetime] Inserted, device id: $strPNPdeviceID with serial: $strConnectedUSBSerial on approved list."
				Write-Host $strMessageToSend 
				Write-Output " $strMessageToSend " | Out-File $strlogfile -Append
				Enable-PnpDevice -InstanceId $strPNPdeviceID -Confirm:$false
				}
			else {
				$strMessageToSend = "WPD [$strdatetime] Inserted, device id: $strPNPdeviceID with serial: $strConnectedUSBSerial not on approved list."
				Write-Host $strMessageToSend
				Write-Output "$strMessageToSend " | Out-File $strlogfile -Append
				}
			}
			
		__InstanceDeletionEvent {
			$strMessageToSend = "WPD [$strdatetime] Removed, device id: $strPNPdeviceID with serial: $strConnectedUSBSerial"
            Write-Host $strMessageToSend
			Write-Output " $strMessageToSend " | Out-File $strlogfile -Append
			}

		__InstanceModificationEvent {
			$intApprovedUSB = 0
			Disable-PnpDevice -InstanceId $strPNPdeviceID -Confirm:$false
			$intApprovedUSB = Check-for-approved-USB $strUSBSerialFilename $strConnectedUSBSerial
			
			$strMessageToSend = "WPD [$strdatetime] Modification event for $strPNPdeviceID. Check if approved returned: $intApprovedUSB"
			
			Write-Host $strMessageToSend
			Write-Output " $strMessageToSend " | Out-File $strlogfile -Append			
			
			if ($intApprovedUSB -eq 1 ) {
				$strMessageToSend = "WPD [$strdatetime] Inserted, device id: $strPNPdeviceID with serial: $strConnectedUSBSerial on approved list."
				Write-Host $strMessageToSend 
				Write-Output " $strMessageToSend " | Out-File $strlogfile -Append
				Enable-PnpDevice -InstanceId $strPNPdeviceID -Confirm:$false
				}
			else {
				$strMessageToSend = "WPD [$strdatetime] Inserted, device id: $strPNPdeviceID with serial: $strConnectedUSBSerial not on approved list."
				Write-Host $strMessageToSend
				Write-Output " $strMessageToSend " | Out-File $strlogfile -Append
				}
			}
		
	}
}


Register-WmiEvent -Query $query -SourceIdentifier RemovableWPDDetection -Action $action -computername $ENV:COMPUTERNAME

