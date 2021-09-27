$Logs_Path = Read-Host -Prompt "Please, Enter Events logs path"  
$Destination_Path=$Logs_Path

##Validating Paths
$LogsPathTest=Test-Path -Path "$Logs_Path"
$DestPathTest=Test-Path -Path "$Destination_Path"
if((($LogsPathTest -eq $true) -and ($DestPathTest -eq $true)) -ne $true ){
        Write-Host "Error: Invalid Paths, Enter a valid path"
        exit
    }
##Create Results Directory

$Destination_Path= Join-Path -Path $Destination_Path -ChildPath "Results"
#check if it's already exist
if ((Test-Path -Path "$Destination_Path")-eq $false) {
    New-Item -Path $Destination_Path -ItemType Directory    
}
$RemoteDesktop_Path=Join-Path -Path $Destination_Path -ChildPath "RemoteDesktop"
#Check if Remote Desktop already exist
if ((Test-Path -Path "$RemoteDesktop_Path")-eq $false) {
    New-Item -Path $RemoteDesktop_Path -ItemType Directory    
}
$MapNetworkShares_Path=Join-Path -Path $Destination_Path -ChildPath "MapNetworkShares"
#Check if MapNetworkShares already exist
if ((Test-Path -Path "$MapNetworkShares_Path")-eq $false) {
    New-Item -Path $MapNetworkShares_Path -ItemType Directory    
}
$PsExec_Path=Join-Path -Path $Destination_Path -ChildPath "PsExec"
#Check if PsExec already exist
if ((Test-Path -Path "$PsExec_Path")-eq $false) {
    New-Item -Path $PsExec_Path -ItemType Directory    
}
$ScheduledTasks_Path=Join-Path -Path $Destination_Path -ChildPath "ScheduledTasks"
#Check if ScheduledTasks already exist
if ((Test-Path -Path "$ScheduledTasks_Path")-eq $false) {
    New-Item -Path $ScheduledTasks_Path -ItemType Directory    
}
$Services_Path=Join-Path -Path $Destination_Path -ChildPath "Services"
#Check if Services already exist
if ((Test-Path -Path "$Services_Path")-eq $false) {
    New-Item -Path $Services_Path -ItemType Directory    
}
$WMIOut_Path=Join-Path -Path $Destination_Path -ChildPath "WMI"
#Check if WMI already exist
if ((Test-Path -Path "$WMIOut_Path")-eq $false) {
    New-Item -Path $WMIOut_Path -ItemType Directory    
}
$PowerShellRemoting_Path=Join-Path -Path $Destination_Path -ChildPath "PowerShellRemoting"
#Check if PowerShellRemoting already exist
if ((Test-Path -Path "$PowerShellRemoting_Path")-eq $false) {
    New-Item -Path $PowerShellRemoting_Path -ItemType Directory    
}


## Convert evt to evtx
$Securityevt_Path= Join-Path -Path $Logs_Path -ChildPath "Security.evt"
$Security_Path= Join-Path -Path $Logs_Path -ChildPath "Security.evtx"
$Systemevt_Path= Join-Path -Path $Logs_Path -ChildPath "System.evt"
$System_Path= Join-Path -Path $Logs_Path -ChildPath "System.evtx"
$RDPCORETS_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx"
$RDPCORETSevt_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evt"
$WMI_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WMI-Activity%4Operational.evtx"
$WMIevt_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WMI-Activity%4Operational.evt"
$PowerShellOperational_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-PowerShell%4Operational.evtx"
$PowerShellOperationalevt_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-PowerShell%4Operational.evt"
$WinPowerShell_Path= Join-Path -Path $Logs_Path -ChildPath "Windows PowerShell.evtx"
$WinPowerShellevt_Path= Join-Path -Path $Logs_Path -ChildPath "Windows PowerShell.evt"
$WinRM_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WinRM%4Operational.evtx"
$WinRMevt_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WinRM%4Operational.evt"
$TaskScheduler_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TaskScheduler%4Maintenance.evtx"
$TaskSchedulerevt_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TaskScheduler%4Maintenance.evt"
$TerminalServices_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx"
$TerminalServiceevt_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evt"
$RemoteConnection_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx"
$RemoteConnectionevt_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evt"

function Evt2Evtx {
    param (
        [Parameter(Mandatory=$true)]
        [string]$EvtPath,
        [Parameter(Mandatory=$true)]
        [string]$EvtxPath
    )
    if (((Test-Path -Path $EvtPath) -eq $true) -and ((Test-Path -Path $EvtxPath) -eq $false)) {
        wevtutil epl $EvtPath $EvtxPath /lf:true    
    }
    else {
        return
    }   
}
Evt2Evtx $Securityevt_Path $Security_Path
Evt2Evtx $Systemevt_Path  $System_Path
Evt2Evtx $RDPCORETSevt_Path $RDPCORETS_Path
Evt2Evtx $WMIevt_Path $WMI_Path
Evt2Evtx $WinPowerShellevt_Path $WinPowerShell_Path
Evt2Evtx $WinRMevt_Path $WinRM_Path
Evt2Evtx $TaskSchedulerevt_Path $TaskScheduler_Path
Evt2Evtx $TerminalServiceevt_Path $TerminalServices_Path
Evt2Evtx $RemoteConnectionevt_Path $RemoteConnection_Path
Evt2Evtx $PowerShellOperationalevt_Path $PowerShellOperational_Path
#Event Logs Paths

## Testing if the log file exist ? 
$Valid_Security_Path= Test-Path -Path $Security_Path
$Valid_System_Path= Test-Path -Path $System_Path
$Valid_RDPCORETS_Path= Test-Path -Path $RDPCORETS_Path
$Valid_WMI_Path= Test-Path -Path $WMI_Path
$Valid_PowerShellOperational_Path=Test-Path -Path $PowerShellOperational_Path
$Valid_WinPowerShell_Path= Test-Path -Path $WinPowerShell_Path
$Valid_WinRM_Path= Test-Path -Path $WinRM_Path
$Valid_TaskScheduler_Path= Test-Path -Path $TaskScheduler_Path
$Valid_TerminalServices_Path= Test-Path -Path $TerminalServices_Path
$Valid_RemoteConnection_Path= Test-Path -Path $RemoteConnection_Path
$ResultsArray= @{}
function GetStats {
    param (
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    $Valid=Test-Path -Path "$FilePath"
    if($Valid -eq $true){
        $NumRows=LogParser.exe -i:csv -stats:OFF "Select Count (*) from '$FilePath'" | Out-String
        $NumRows.Substring([int](29)) 
    } 
    else {
        Return 0
    }
}
function SuccessfulLogons {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4624
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "SuccessfulLogons.csv"
    $Query="SELECT TimeGenerated,EventID , EXTRACT_TOKEN(Strings, 5, '|') as Username, EXTRACT_TOKEN(Strings, 6, '|') as Domain, EXTRACT_TOKEN(Strings, 8, '|') as LogonType,EXTRACT_TOKEN(strings, 9, '|') AS AuthPackage, EXTRACT_TOKEN(Strings, 11, '|') AS Workstation, EXTRACT_TOKEN(Strings, 17, '|') AS ProcessName, EXTRACT_TOKEN(Strings, 18, '|') AS SourceIP INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID  And LogonType<>'5'"  
    LogParser.exe -stats:OFF -i:EVT $Query
    $SuccessfulLogons= GetStats $OutputFile
    $ResultsArray.Add("4624 RemoteDesktop     Successful Logons",$SuccessfulLogons)
    Write-Host "Successful Logons:" $SuccessfulLogons -ForegroundColor Green
}


function AdminLogonCreated  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4672
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "AdminLogonCreated.csv"
    $Query="Select TimeGenerated,EventID , EXTRACT_TOKEN(Strings, 1, '|') AS Username, EXTRACT_TOKEN(Strings, 2, '|') AS Domain , EXTRACT_TOKEN(Strings, 3, '|') as LogonID INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $AdminLogonsCreated= GetStats $OutputFile
    $ResultsArray.Add("4672 MapNetworkShares  Admin Logons Created",$AdminLogonsCreated)
    Write-Host "Admin Logons Created: " $AdminLogonsCreated -ForegroundColor Green
    
}


function InstalledServices {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4697
    $OutputFile= Join-Path -Path $Services_Path -ChildPath "InstalledServices.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 5, '|') AS ServiceFileName, EXTRACT_TOKEN(Strings, 6, '|') AS ServiceType,  EXTRACT_TOKEN(Strings, 7, '|') AS ServiceStartType  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $InstalledServices= GetStats $OutputFile
    $ResultsArray.Add("4697 Services          Installed Services [Security Log]",$InstalledServices)
    Write-Host "Installed Services [Security Log]: " $InstalledServices -ForegroundColor Green
    
}



function ScheduledTaskCreatedSec {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4698
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTaskCreatedSec.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskCreatedSec= GetStats $OutputFile
    $ResultsArray.Add("4698 ScheduledTasks    Scheduled Tasks Created [Security Log]",$ScheduledTaskCreatedSec)
    Write-Host "Scheduled Tasks Created [Security Log]: " $ScheduledTaskCreatedSec -ForegroundColor Green
    
}

function ScheduledTaskDeletedSec {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4699
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTaskDeletedSec.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskDeletedSec= GetStats $OutputFile
    $ResultsArray.Add("4699 ScheduledTasks    Scheduled Tasks Deleted [Security Log]",$ScheduledTaskDeletedSec)
    Write-Host "Scheduled Tasks Deleted [Security Log]: " $ScheduledTaskDeletedSec -ForegroundColor Green
    
}

function ScheduledTaskEnabledSec {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4700
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTaskEnabledSec.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskEnabledSec= GetStats $OutputFile
    $ResultsArray.Add("4700 ScheduledTasks    Scheduled Tasks Enabled [Security Log]",$ScheduledTaskEnabledSec)
    Write-Host "Scheduled Tasks Enbaled [Security Log]: " $ScheduledTaskEnabledSec -ForegroundColor Green
}

function ScheduledTaskDisabledSec{
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4701
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTaskDisabledSec.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskDisabledSec= GetStats $OutputFile
    $ResultsArray.Add("4701 ScheduledTasks    Scheduled Tasks Disabled [Security Log]",$ScheduledTaskDisabledSec)
    Write-Host "Scheduled Tasks Disabled [Security Log]: " $ScheduledTaskDisabledSec -ForegroundColor Green
}


function ScheduledTaskUpdatedSec{
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4702
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTaskUpdatedSec.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskUpdatedSec= GetStats $OutputFile
    $ResultsArray.Add("4702 ScheduledTasks    Scheduled Tasks Updated [Security Log]",$ScheduledTaskUpdatedSec)
    Write-Host "Scheduled Tasks Updated [Security Log]: " $ScheduledTaskUpdatedSec -ForegroundColor Green
}


function KerberosAuthenticationRequested {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4768
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "KerberosAuthenticationRequested.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS AccountName, EXTRACT_TOKEN(Strings, 1, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 9, '|') AS SourceIP , EXTRACT_TOKEN(Strings, 10, '|') AS SourcePort INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $KerberosAuthenticationRequested= GetStats $OutputFile
    $ResultsArray.Add("4768 MapNetworkShares  Kerberos Authentication Tickets Requested",$KerberosAuthenticationRequested)
    Write-Host "Kerberos Authentication Tickets Requested: " $KerberosAuthenticationRequested -ForegroundColor Green
    
}

function KerberosServiceRequested {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4769
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "KerberosServiceRequested.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS AccountName, EXTRACT_TOKEN(Strings, 1, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 2, '|') AS ServiceName ,EXTRACT_TOKEN(Strings, 6, '|') AS SourceIP , EXTRACT_TOKEN(Strings, 7, '|') AS SourcePort INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $KerberosServiceRequested= GetStats $
    $ResultsArray.Add("4769 MapNetworkShares  Kerberos Services Tickets Requested",$KerberosServiceRequested)
    Write-Host "Kerberos Services Tickets Requested: " $KerberosServiceRequested -ForegroundColor Green
    
    
}

function ComputerToValidate  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4776
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "ComputerToValidate.csv"
    $Query="Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID " 
    LogParser.exe -stats:OFF -i:EVT $Query
    $ComputerToValidate= GetStats $OutputFile
    $ResultsArray.Add("4776 MapNetworkShares  Computer To Validate",$ComputerToValidate)    
    Write-Host "Computer To Validate: " $ComputerToValidate -ForegroundColor Green

}

function RDPReconnected  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4778
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPReconnected.csv"
    $Query= "SELECT TimeGenerated,EventID ,EXTRACT_TOKEN(Strings, 0, '|') AS Username, EXTRACT_TOKEN(Strings, 1, '|') AS Domain, EXTRACT_TOKEN(Strings, 4, '|') AS Workstation, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID" 
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPReconencted= GetStats $OutputFile
    $ResultsArray.Add("4778 RemoteDesktop     RDP sessions reconnected",$RDPReconencted)    
    Write-Host "RDP sessions reconnected: " $RDPReconencted -ForegroundColor Green

    
}


function RDPDisconnected  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4779
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPDisconnected.csv"
    $Query= "SELECT TimeGenerated,EventID ,EXTRACT_TOKEN(Strings, 0, '|') AS Username, EXTRACT_TOKEN(Strings, 1, '|') AS Domain, EXTRACT_TOKEN(Strings, 4, '|') AS Workstation, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID" 
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPDisconnected= GetStats $OutputFile
    $ResultsArray.Add("4779 RemoteDesktop     RDP sessions Disconnected",$RDPDisconnected)    
    Write-Host "RDP sessions Disconnected: " $RDPDisconnected  -ForegroundColor Green  
}
function NetworkShareAccessed  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5140
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "NetworkShareAccessed.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS SourceIP, EXTRACT_TOKEN(Strings, 5, '|') AS SourcePort, EXTRACT_TOKEN(Strings, 6, '|') AS ShareName INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $NetworkShareAccessed= GetStats $OutputFile
    $ResultsArray.Add("5140 MapNetworkShares  Network Share Objects Accessed",$NetworkShareAccessed)    
    Write-Host "Network Share Objects Accessed: " $NetworkShareAccessed -ForegroundColor Green
}

function NetworkShareChecked  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5145
    $OutputFile= Join-Path -Path $MapNetworkShares_Path -ChildPath "NetworkShareChecked.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccounName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS ObjectType, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP, EXTRACT_TOKEN(Strings, 6, '|') AS SourePort, EXTRACT_TOKEN(Strings, 7, '|') AS ShareName, EXTRACT_TOKEN(Strings, 8, '|') AS SharePath, EXTRACT_TOKEN(Strings, 11, '|') as Accesses, EXTRACT_TOKEN(Strings, 12, '|') as AccessesCheckResult INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $NetworkShareChecked= GetStats $OutputFile
    $ResultsArray.Add("5145 MapNetworkShares  Network Share Objects Checked",$NetworkShareChecked)    
    Write-Host "Network Share Objects Checked : " $NetworkShareChecked -ForegroundColor Green
}



function ServiceCrashedUnexpect {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7034
    $OutputFile= Join-Path -Path $Services_Path -ChildPath "ServiceCrashedUnexpect.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS Times INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceCrashedUnexpect= GetStats $OutputFile
    $ResultsArray.Add("7034 Services          Services Crashed unexpectedly",$ServiceCrashedUnexpect)    
    Write-Host "Services Crashed unexpectedly [System Log]: " $ServiceCrashedUnexpect -ForegroundColor Green
}

function ServicesStatus {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7036
    $OutputFile= Join-Path -Path $Services_Path -ChildPath "ServicesStatus.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS ServiceName INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServicesStatus= GetStats $OutputFile
    $ResultsArray.Add("7036 Services          Services Stopped Or Started",$ServicesStatus)    
    Write-Host "Services Stopped Or Started: " $ServicesStatus -ForegroundColor Green
 
}
function ServiceSentStartStopControl {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7035
    $OutputFile= Join-Path -Path $Services_Path -ChildPath "ServiceSentStartStopControl.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS RequestSent INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceSentStartStopControl= GetStats $OutputFile
    $ResultsArray.Add("7035 Services          Services Sent Stop/Start Control",$ServiceSentStartStopControl)    
    Write-Host "Services Sent Stop/Start Control [System Log]: " $ServiceSentStartStopControl -ForegroundColor Green
}

function ServiceStartTypeChanged {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7040
    $OutputFile= Join-Path -Path $Services_Path -ChildPath "ServiceStartTypeChanged.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS ChangedFrom , EXTRACT_TOKEN(Strings, 2, '|') AS ChangedTo INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceStartTypeChanged= GetStats $OutputFile
    $ResultsArray.Add("7040 Services          Services Start Type Changed",$ServiceStartTypeChanged)    
    Write-Host "Services Start Type Changed [System Log]: " $ServiceStartTypeChanged -ForegroundColor Green
}

function SystemInstalledServices {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7045
    $OutputFile= Join-Path -Path $PsExec_Path -ChildPath "SystemInstalledServices.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS ImagePath, EXTRACT_TOKEN(Strings, 2, '|') AS ServiceType , EXTRACT_TOKEN(Strings, 3, '|') AS StartType, EXTRACT_TOKEN(Strings, 4, '|') AS AccountName INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $SystemInstalledServices= GetStats $OutputFile
    $ResultsArray.Add("7045 PsExec            Services Installed on System [System Log]",$SystemInstalledServices)    
    Write-Host "Services Installed on System [System Log]: " $SystemInstalledServices -ForegroundColor Green
}

########################################## WMI ################################################
function WMIOperationStarted {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5857
    $OutputFile= Join-Path -Path $WMIOut_Path -ChildPath "WMIOperationStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ProviderName, EXTRACT_TOKEN(Strings, 1, '|') AS Code, EXTRACT_TOKEN(Strings, 3, '|') AS ProcessID, EXTRACT_TOKEN(Strings, 4, '|') AS ProviderPath INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationStarted= GetStats $OutputFile
    $ResultsArray.Add("5857 WMI               WMI Operations Started [WMI Log]",$WMIOperationStarted)    
    Write-Host "WMI Operations Started [WMI Log]: " $WMIOperationStarted   -ForegroundColor Green 
}


function WMIOperationTemporaryEssStarted {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5860
    $OutputFile= Join-Path -Path $WMIOut_Path -ChildPath "WMIOperationTemporaryEssStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS NameSpace, EXTRACT_TOKEN(Strings, 1, '|') AS Query,EXTRACT_TOKEN(Strings, 2, '|') AS User ,EXTRACT_TOKEN(Strings, 3, '|') AS ProcessID, EXTRACT_TOKEN(Strings, 4, '|') AS ClientMachine INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationTemporaryEssStarted= GetStats $OutputFile
    $ResultsArray.Add("5860 WMI               WMI Operations ESS Started [WMI Log]",$WMIOperationTemporaryEssStarted)    
    Write-Host "WMI Operations ESS Started [WMI Log]: " $WMIOperationTemporaryEssStarted  -ForegroundColor Green  
}


function WMIOperationESStoConsumerBinding {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5861
    $OutputFile= Join-Path -Path $WMIOut_Path -ChildPath "WMIOperationESStoConsumerBinding.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS NameSpace, EXTRACT_TOKEN(Strings, 1, '|') AS ESS,EXTRACT_TOKEN(Strings, 2, '|') AS Consumer ,EXTRACT_TOKEN(Strings, 3, '|') AS PossibleCause INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationESStoConsumerBinding= GetStats $OutputFile
    $ResultsArray.Add("5861 WMI               WMI Operations ESS to Consumer Binding [WMI Log]",$WMIOperationESStoConsumerBinding)    
    Write-Host "WMI Operations ESS to Consumer Binding [WMI Log]: " $WMIOperationESStoConsumerBinding  -ForegroundColor Green   
}


#===============Microsoft-Windows-PowerShell%4Operational.evtx=========
function PSModuleLogging {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4103
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "PSModuleLogging.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ContextINFO, EXTRACT_TOKEN(Strings, 2, '|') AS Payload INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSModuleLogging= GetStats $OutputFile
    $ResultsArray.Add("4103 PowerShellRemoting PS Modules Logged",$PSModuleLogging)    
    Write-Host "PS Modules Logged : " $PSModuleLogging -ForegroundColor Green

}

function PSScriptBlockLogging  {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4104
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "PSScriptBlockLogging.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS MessageNumber, EXTRACT_TOKEN(Strings, 1, '|') AS TotalMessages, EXTRACT_TOKEN(Strings, 2, '|') AS ScriptBlockText , EXTRACT_TOKEN(Strings, 3, '|') AS ScriptBlockID , EXTRACT_TOKEN(Strings,4 , '|') AS ScriptPath INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSScriptBlockLogging= GetStats $OutputFile
    $ResultsArray.Add("4104 PowerShellRemoting PS Script Blocks Logged",$PSScriptBlockLogging)    
    Write-Host "PS Script Blocks Logged : " $PSScriptBlockLogging -ForegroundColor Green
    
}    

function PSAuthneticatingUser  {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=53504
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "PSAuthneticatingUser.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS Process, EXTRACT_TOKEN(Strings, 1, '|') AS AppDomain INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSAuthneticatingUser= GetStats $OutputFile
    $ResultsArray.Add("53504PowerShellRemoting PS Authenticating User",$PSAuthneticatingUser)    
    Write-Host "PS Authenticating User : " $PSAuthneticatingUser -ForegroundColor Green
    
}
#=====================WinRM log=======================
function SessionCreated {
    if ($Valid_WinRM_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WinRM%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=91
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "SessionCreated.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ResourceUrl INTO $OutputFile FROM '$WinRM_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $SessionCreated= GetStats $OutputFile
    $ResultsArray.Add("91   PowerShellRemoting Session Created [WinRM log]",$SessionCreated)    
    Write-Host "Session Created [WinRM log] : " $SessionCreated -ForegroundColor Green
    
}  

function WinRMAuthneticatingUser {
    if ($Valid_WinRM_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WinRM%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=168
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "WinRMAuthneticatingUser.csv"
    $Query= "Select TimeGenerated,EventID, Message INTO $OutputFile FROM '$WinRM_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WinRMAuthneticatingUser= GetStats $OutputFile
    $ResultsArray.Add("168  PowerShellRemoting WinRM Authenticating User [WinRM log]",$WinRMAuthneticatingUser)    
    Write-Host "WinRM Authenticating User  [WinRM log] : " $WinRMAuthneticatingUser -ForegroundColor Green

}

#####======= Windows PowerShell.evtx======
function ServerRemoteHostStarted {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=400
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "ServerRemoteHostStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServerRemoteHostStarted= GetStats $OutputFile
    $ResultsArray.Add("400  PowerShellRemoting Server Remote Hosts Started",$ServerRemoteHostStarted)    
    Write-Host "Server Remote Hosts Started : " $ServerRemoteHostStarted -ForegroundColor Green

    
}
function ServerRemoteHostEnded {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=403
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "ServerRemoteHostEnded.csv"
    $Query= "Select TimeGenerated,EventID,  EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServerRemoteHostEnded= GetStats $OutputFile
    $ResultsArray.Add("403  PowerShellRemoting Server Remote Hosts Ended",$ServerRemoteHostEnded)
    Write-Host "Server Remote Hosts Ended : " $ServerRemoteHostEnded -ForegroundColor Green
}

function PSPartialCode {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=800
    $OutputFile= Join-Path -Path $PowerShellRemoting_Path -ChildPath "PSPartialCode.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication  INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSPartialCode= GetStats $OutputFile
    $ResultsArray.Add("800  PowerShellRemoting Partial Scripts Code",$PSPartialCode)
    Write-Host "Partial Scripts Code : " $PSPartialCode   -ForegroundColor Green
}

#==============Task Scheduler=============

function ScheduledTasksCreatedTS {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=106
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTasksCreatedTS.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksCreatedTS= GetStats $OutputFile
    $ResultsArray.Add("106  ScheduledTasks    Scheduled Tasks Created [Task Scheduler Log]",$ScheduledTasksCreatedTS)
    Write-Host "Scheduled Tasks Created [Task Scheduler Log] : " $ScheduledTasksCreatedTS  -ForegroundColor Green
 
}

function ScheduledTasksUpdatedTS {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=140
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTasksUpdatedTS.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksUpdatedTS= GetStats $OutputFile
    $ResultsArray.Add("140  ScheduledTasks    Scheduled Tasks Updated [Task Scheduler Log]",$ScheduledTasksUpdatedTS)
    Write-Host "Scheduled Tasks Updated [Task Scheduler Log]: " $ScheduledTasksUpdatedTS  -ForegroundColor Green
 
}

function ScheduledTasksDeletedTS {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=141
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTasksDeletedTS.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksDeletedTS= GetStats $OutputFile
    $ResultsArray.Add("141  ScheduledTasks    Scheduled Tasks Deleted [Task Scheduler Log]",$ScheduledTasksDeletedTS)
    Write-Host "Scheduled Tasks Deleted [Task Scheduler Log] : " $ScheduledTasksDeletedTS  -ForegroundColor Green
 
}

function ScheduledTasksExecutedTS {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=200
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTasksExecutedTS.csv"
    $Query= "Select TimeGenerated,EventID, extract_token(strings,0, '|') as TaskName, extract_token(strings, 1, '|') as TaskAction, extract_token(strings, 2, '|') as Instance  INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksExecutedTS= GetStats $OutputFile
    $ResultsArray.Add("200  ScheduledTasks    Scheduled Tasks Executed [Task Scheduler Log]",$ScheduledTasksExecutedTS)
    Write-Host "Scheduled Tasks Executed [Task Scheduler Log]: " $ScheduledTasksExecutedTS  -ForegroundColor Green
}


function ScheduledTasksCompletedTS {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=201
    $OutputFile= Join-Path -Path $ScheduledTasks_Path -ChildPath "ScheduledTasksCompletedTS.csv"
    $Query= "Select TimeGenerated,EventID, extract_token(strings,0, '|') as TaskName, extract_token(strings, 1, '|') as TaskAction, extract_token(strings, 2, '|') as Instance  INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksCompletedTS= GetStats $OutputFile
    $ResultsArray.Add("201  ScheduledTasks    Scheduled Tasks Completed [Task Scheduler Log]",$ScheduledTasksCompletedTS)
    Write-Host "Scheduled Tasks Completed [Task Scheduler Log] : " $ScheduledTasksCompletedTS  -ForegroundColor Green
}

##============= Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx============
function RDPLocalSuccessfulLogon1 {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=21
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPLocalSuccessfulLogon1.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulLogon1= GetStats $OutputFile
    $ResultsArray.Add("21   RemoteDesktop     RDP Local Successful Logons [EventID=21]",$RDPLocalSuccessfulLogon1)
    Write-Host "RDP Local Successful Logons [EventID=21] : " $RDPLocalSuccessfulLogon1 -ForegroundColor Green
}

function RDPLocalSuccessfulLogon2 {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=22
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPLocalSuccessfulLogon2.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulLogon2= GetStats $OutputFile
    $ResultsArray.Add("22   RemoteDesktop     RDP Local Successful Logons [EventID=22]",$RDPLocalSuccessfulLogon2)
    Write-Host "RDP Local Successful Logons [EventID=22]: " $RDPLocalSuccessfulLogon2 -ForegroundColor Green
}

function RDPLocalSuccessfulReconnection {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=25
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPLocalSuccessfulReconnection.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulReconnection= GetStats $OutputFile
    $ResultsArray.Add("25   RemoteDesktop     RDP Local Successful Reconnections",$RDPLocalSuccessfulReconnection)
    Write-Host "RDP Local Successful Reconnections: " $RDPLocalSuccessfulReconnection -ForegroundColor Green
}
function RDPBegainSession {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=41
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPBeginSession.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPBeginSession= GetStats $OutputFile
    $ResultsArray.Add("41   RemoteDesktop     RDP Sessios Begain",$RDPBeginSession)
    Write-Host "RDP Sessios Begain : " $RDPBeginSession -ForegroundColor Green
}

#=========================Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx=======================
function RDPConnectionEstablished {
    if ($Valid_RemoteConnection_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=1149
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPConnectionEstablished.csv"
    $Query= "Select TimeGenerated,EventID  ,extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as Domain ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$RemoteConnection_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPConnectionEstablished= GetStats $OutputFile
    $ResultsArray.Add("1149 RemoteDesktop     RDP Connections Established",$RDPConnectionEstablished)
    Write-Host "RDP Connections Established: " $RDPConnectionEstablished -ForegroundColor Green
    
    
}


#============Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx=============

function RDPConnectionsAttempts {
    if ($Valid_RDPCORETS_Path -eq $false) {
        write-host "Error: Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=131
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPConnectionsAttempts.csv"
    $Query= "Select TimeGenerated,EventID  ,extract_token(strings, 0, '|') as ConnectionType, extract_token(strings, 1, '|') as CLientIP INTO $OutputFile FROM '$RDPCORETS_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPConnectionsAttempts= GetStats $OutputFile
    $ResultsArray.Add("131  RemoteDesktop     RDP Connections Attempts",$RDPConnectionsAttempts)
    Write-Host "RDP Connections Attempts : " $RDPConnectionsAttempts -ForegroundColor Green
}

function RDPSuccessfulTCPConnections {
    if ($Valid_RDPCORETS_Path -eq $false) {
        write-host "Error: Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=98
    $OutputFile= Join-Path -Path $RemoteDesktop_Path -ChildPath "RDPSuccessfulTCPConnections.csv"
    $Query= "Select TimeGenerated,EventID  INTO $OutputFile FROM '$RDPCORETS_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPSuccessfulTCPConnections= GetStats $OutputFile
    $ResultsArray.Add("98   RemoteDesktop     RDP Successful TCP Connections",$RDPSuccessfulTCPConnections)
    Write-Host "RDP Successful TCP Connections: " $RDPSuccessfulTCPConnections -ForegroundColor Green
}
