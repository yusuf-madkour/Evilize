Write-Host  "Welcome to Evilize" 
$Logs_Path = Read-Host -Prompt "Please, Enter Events logs path" 
$Destination_Path=Read-Host -Prompt "Please, Enter Path of Results you want to save to"

##Validating Paths
$LogsPathTest=Test-Path -Path "$Logs_Path"
$DestPathTest=Test-Path -Path "$Destination_Path"
if((($LogsPathTest -eq $true) -and ($DestPathTest -eq $true)) -ne $true ){
        Write-Host "Error 0x001: Invalid Paths, Enter a valid path"
        exit
    }
##Create Results Directory

$Destination_Path= Join-Path -Path $Destination_Path -ChildPath "Results"
$DestPathTest=Test-Path -Path "$Destination_Path"
#check if it's already exist
if ($DestPathTest -eq $false) {
    New-Item -Path $Destination_Path -ItemType Directory    
}

#Event Logs Paths
$Security_Path= Join-Path -Path $Logs_Path -ChildPath "Security.evtx"
$System_Path= Join-Path -Path $Logs_Path -ChildPath "System.evtx"
$RDPCORETS_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx"
$WMI_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WMI-Activity%4Operational.evtx"
$PowerShellOperational_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-PowerShell%4Operational.evtx"
$WinPowerShell_Path= Join-Path -Path $Logs_Path -ChildPath "Windows PowerShell.evtx"
$WinRM_Path= Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-WinRM%4Operational.evtx"
$TaskScheduler_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TaskScheduler%4Maintenance.evtx"
$TerminalServices_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx"
$RemoteConnection_Path=Join-Path -Path $Logs_Path -ChildPath "Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx"

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
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "SuccessfulLogons.csv"
    $Query="SELECT TimeGenerated,EventID , EXTRACT_TOKEN(Strings, 5, '|') as Username, EXTRACT_TOKEN(Strings, 6, '|') as Domain, EXTRACT_TOKEN(Strings, 8, '|') as LogonType,EXTRACT_TOKEN(strings, 9, '|') AS AuthPackage, EXTRACT_TOKEN(Strings, 11, '|') AS Workstation, EXTRACT_TOKEN(Strings, 17, '|') AS ProcessName, EXTRACT_TOKEN(Strings, 18, '|') AS SourceIP INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID  And LogonType<>'5'"  
    LogParser.exe -stats:OFF -i:EVT $Query
    $SuccessfulLogons= GetStats $OutputFile
    Write-Host "Successful Logons:" $SuccessfulLogons -ForegroundColor Green
}


function AdminLogonCreated  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4672
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "AdminLogonCreated.csv"
    $Query="Select TimeGenerated,EventID , EXTRACT_TOKEN(Strings, 1, '|') AS Username, EXTRACT_TOKEN(Strings, 2, '|') AS Domain , EXTRACT_TOKEN(Strings, 3, '|') as LogonID INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $AdminLogonsCreated= GetStats $OutputFile
    Write-Host "Admin Logons Created: " $AdminLogonsCreated -ForegroundColor Green
    
}


function InstalledServices {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4697
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "InstalledServices.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 5, '|') AS ServiceFileName, EXTRACT_TOKEN(Strings, 6, '|') AS ServiceType,  EXTRACT_TOKEN(Strings, 7, '|') AS ServiceStartType  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $InstalledServices= GetStats $OutputFile
    Write-Host "Installed Services [Security Log]: " $InstalledServices -ForegroundColor Green
    
}



function ScheduledTaskCreated {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4698
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTaskCreated.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskCreated= GetStats $OutputFile
    Write-Host "Scheduled Tasks Created: " $ScheduledTaskCreated -ForegroundColor Green
    
}

function ScheduledTaskDeleted {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4699
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTaskDeleted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskDeleted= GetStats $OutputFile
    Write-Host "Scheduled Tasks Deleted: " $ScheduledTaskDeleted -ForegroundColor Green
    
}

function ScheduledTaskEnabled {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4700
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTaskEnabled.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskEnabled= GetStats $OutputFile
    Write-Host "Scheduled Tasks Enbaled: " $ScheduledTaskEnabled -ForegroundColor Green
}

function ScheduledTaskDisabled{
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4701
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTaskDisabled.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskDisabled= GetStats $OutputFile
    Write-Host "Scheduled Tasks Disabled: " $ScheduledTaskDisabled -ForegroundColor Green
}


function ScheduledTaskUpdated{
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4702
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTaskUpdated.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS TaskName, EXTRACT_TOKEN(Strings, 5, '|') AS TaskContent  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTaskUpdated= GetStats $OutputFile
    Write-Host "Scheduled Tasks Updated: " $ScheduledTaskUpdated -ForegroundColor Green
}


function KerberosAuthenticationRequested {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4768
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "KerberosAuthenticationRequested.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS AccountName, EXTRACT_TOKEN(Strings, 1, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 9, '|') AS SourceIP , EXTRACT_TOKEN(Strings, 10, '|') AS SourcePort INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $KerberosAuthenticationRequested= GetStats $OutputFile
    Write-Host "Kerberos Authentication Tickets Requested: " $KerberosAuthenticationRequested -ForegroundColor Green
    
}

function KerberosServiceRequested {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4769
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "KerberosServiceRequested.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS AccountName, EXTRACT_TOKEN(Strings, 1, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 2, '|') AS ServiceName ,EXTRACT_TOKEN(Strings, 6, '|') AS SourceIP , EXTRACT_TOKEN(Strings, 7, '|') AS SourcePort INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $KerberosServiceRequested= GetStats $OutputFile
    Write-Host "Kerberos Services Tickets Requested: " $KerberosServiceRequested -ForegroundColor Green
    
    
}

function ComputerToValidate  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4776
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ComputerToValidate.csv"
    $Query="Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID " 
    LogParser.exe -stats:OFF -i:EVT $Query
    $ComputerToValidate= GetStats $OutputFile
    Write-Host "Computer To Validate: " $ComputerToValidate -ForegroundColor Green

}

function RDPReconnected  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4778
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPReconnected.csv"
    $Query= "SELECT TimeGenerated,EventID ,EXTRACT_TOKEN(Strings, 0, '|') AS Username, EXTRACT_TOKEN(Strings, 1, '|') AS Domain, EXTRACT_TOKEN(Strings, 4, '|') AS Workstation, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID" 
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPReconencted= GetStats $OutputFile
    Write-Host "RDP sessions reconnected: " $RDPReconencted -ForegroundColor Green

    
}


function RDPDisconnected  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4779
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPDisconnected.csv"
    $Query= "SELECT TimeGenerated,EventID ,EXTRACT_TOKEN(Strings, 0, '|') AS Username, EXTRACT_TOKEN(Strings, 1, '|') AS Domain, EXTRACT_TOKEN(Strings, 4, '|') AS Workstation, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP  INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID" 
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPDisconnected= GetStats $OutputFile
    Write-Host "RDP sessions Disconnected: " $RDPDisconnected  -ForegroundColor Green  
}
function NetworkShareAccessed  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5140
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "NetworkShareAccessed.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccountName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS SourceIP, EXTRACT_TOKEN(Strings, 5, '|') AS SourcePort, EXTRACT_TOKEN(Strings, 6, '|') AS ShareName INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $NetworkShareAccessed= GetStats $OutputFile
    Write-Host "Network Share Objects Accessed: " $NetworkShareAccessed -ForegroundColor Green
}

function NetworkShareChecked  {
    if ($Valid_Security_Path -eq $false) {
        write-host "Error: Security event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5145
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "NetworkShareChecked.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 1, '|') AS AccounName, EXTRACT_TOKEN(Strings, 2, '|') AS AccountDomain, EXTRACT_TOKEN(Strings, 3, '|') AS LogonID , EXTRACT_TOKEN(Strings, 4, '|') AS ObjectType, EXTRACT_TOKEN(Strings, 5, '|') AS SourceIP, EXTRACT_TOKEN(Strings, 6, '|') AS SourePort, EXTRACT_TOKEN(Strings, 7, '|') AS ShareName, EXTRACT_TOKEN(Strings, 8, '|') AS SharePath, EXTRACT_TOKEN(Strings, 11, '|') as Accesses, EXTRACT_TOKEN(Strings, 12, '|') as AccessesCheckResult INTO $OutputFile FROM '$Security_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $NetworkShareChecked= GetStats $OutputFile
    Write-Host "Network Share Objects Checked : " $NetworkShareChecked -ForegroundColor Green
}



function ServiceCrashedUnexpect {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7034
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServiceCrashedUnexpect.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS Times INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceCrashedUnexpect= GetStats $OutputFile
    Write-Host "Services Crashed unexpectedly [System Log]: " $ServiceCrashedUnexpect -ForegroundColor Green
}

function ServicesStatus {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7036
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServicesStatus.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS State INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServicesStatus= GetStats $OutputFile
    Write-Host "Services Stopped Or Started: " $ServicesStatus -ForegroundColor Green
 
}
function ServiceSentStartStopControl {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7035
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServiceSentStartStopControl.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS RequestSent INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceSentStartStopControl= GetStats $OutputFile
    Write-Host "Services Sent Stop/Start Control [System Log]: " $ServiceSentStartStopControl -ForegroundColor Green
}

function ServiceStartTypeChanged {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7040
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServiceStartTypeChanged.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS ChangedFrom , EXTRACT_TOKEN(Strings, 2, '|') AS ChangedTo INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServiceStartTypeChanged= GetStats $OutputFile
    Write-Host "Services Start Type Changed [System Log]: " $ServiceStartTypeChanged -ForegroundColor Green
}

function SystemInstalledServices {
    if ($Valid_System_Path -eq $false) {
        write-host "Error: System event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=7045
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "SystemInstalledServices.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ServiceName, EXTRACT_TOKEN(Strings, 1, '|') AS ImagePath, EXTRACT_TOKEN(Strings, 2, '|') AS ServiceType , EXTRACT_TOKEN(Strings, 3, '|') AS StartType, EXTRACT_TOKEN(Strings, 4, '|') AS AccountName INTO $OutputFile FROM '$System_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $SystemInstalledServices= GetStats $OutputFile
    Write-Host "Services Installed on System [System Log]: " $SystemInstalledServices -ForegroundColor Green
}

########################################## WMI ################################################
function WMIOperationStarted {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5857
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "WMIOperationStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ProviderName, EXTRACT_TOKEN(Strings, 1, '|') AS Code, EXTRACT_TOKEN(Strings, 3, '|') AS ProcessID, EXTRACT_TOKEN(Strings, 4, '|') AS ProviderPath INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationStarted= GetStats $OutputFile
    Write-Host "WMI Operations Started [WMI Log]: " $WMIOperationStarted   -ForegroundColor Green 
}


function WMIOperationTemporaryEssStarted {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5860
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "WMIOperationTemporaryEssStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS NameSpace, EXTRACT_TOKEN(Strings, 1, '|') AS Query,EXTRACT_TOKEN(Strings, 2, '|') AS User ,EXTRACT_TOKEN(Strings, 3, '|') AS ProcessID, EXTRACT_TOKEN(Strings, 4, '|') AS ClientMachine INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationTemporaryEssStarted= GetStats $OutputFile
    Write-Host "WMI Operations ESS Started [WMI Log]: " $WMIOperationTemporaryEssStarted  -ForegroundColor Green  
}


function WMIOperationESStoConsumerBinding {
    if ($Valid_WMI_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WMI-Activity%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=5861
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "WMIOperationESStoConsumerBinding.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS NameSpace, EXTRACT_TOKEN(Strings, 1, '|') AS ESS,EXTRACT_TOKEN(Strings, 2, '|') AS Consumer ,EXTRACT_TOKEN(Strings, 3, '|') AS PossibleCause INTO $OutputFile FROM '$WMI_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WMIOperationESStoConsumerBinding= GetStats $OutputFile
    Write-Host "WMI Operations ESS to Consumer Binding [WMI Log]: " $WMIOperationESStoConsumerBinding  -ForegroundColor Green   
}


#===============Microsoft-Windows-PowerShell%4Operational.evtx=========
function PSModuleLogging {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4103
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "PSModuleLogging.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ContextINFO, EXTRACT_TOKEN(Strings, 2, '|') AS Payload INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSModuleLogging= GetStats $OutputFile
    Write-Host "PS Modules Logged : " $PSModuleLogging -ForegroundColor Green

}

function PSScriptBlockLogging  {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=4104
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "PSScriptBlockLogging.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS MessageNumber, EXTRACT_TOKEN(Strings, 1, '|') AS TotalMessages, EXTRACT_TOKEN(Strings, 2, '|') AS ScriptBlockText , EXTRACT_TOKEN(Strings, 3, '|') AS ScriptBlockID , EXTRACT_TOKEN(Strings,4 , '|') AS ScriptPath INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSScriptBlockLogging= GetStats $OutputFile
    Write-Host "PS Script Blocks Logged : " $PSScriptBlockLogging -ForegroundColor Green
    
}    

function PSAuthneticatingUser  {
    if ($Valid_PowerShellOperational_Path -eq $false) {
        write-host "Error: Microsoft-Windows-PowerShell%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=53504
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "PSAuthneticatingUser.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS Process, EXTRACT_TOKEN(Strings, 1, '|') AS AppDomain INTO $OutputFile FROM '$PowerShellOperational_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSAuthneticatingUser= GetStats $OutputFile
    Write-Host "PS Authenticating User : " $PSAuthneticatingUser -ForegroundColor Green
    
}
#=====================WinRM log=======================
function SessionCreated {
    if ($Valid_WinRM_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WinRM%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=91
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "SessionCreated.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_TOKEN(Strings, 0, '|') AS ResourceUrl INTO $OutputFile FROM '$WinRM_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $SessionCreated= GetStats $OutputFile
    Write-Host "Session Created [WinRM log] : " $SessionCreated -ForegroundColor Green
    
}  

function WinRMAuthneticatingUser {
    if ($Valid_WinRM_Path -eq $false) {
        write-host "Error: Microsoft-Windows-WinRM%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=168
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "WinRMAuthneticatingUser.csv"
    $Query= "Select TimeGenerated,EventID, Message INTO $OutputFile FROM '$WinRM_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $WinRMAuthneticatingUser= GetStats $OutputFile
    Write-Host "WinRM Authenticating User  [WinRM log] : " $WinRMAuthneticatingUser -ForegroundColor Green

}

#####======= Windows PowerShell.evtx======
function ServerRemoteHostStarted {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=400
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServerRemoteHostStarted.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServerRemoteHostStarted= GetStats $OutputFile
    Write-Host "ServerRemoteHosts Started : " $ServerRemoteHostStarted -ForegroundColor Green

    
}
function ServerRemoteHostEnded {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=403
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ServerRemoteHostEnded.csv"
    $Query= "Select TimeGenerated,EventID,  EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ServerRemoteHostEnded= GetStats $OutputFile
    Write-Host "ServerRemoteHosts Ended : " $ServerRemoteHostEnded -ForegroundColor Green
}

function PSPartialCode {
    if ($Valid_WinPowerShell_Path -eq $false) {
        write-host "Error: Windows PowerShell event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=800
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "PSPartialCode.csv"
    $Query= "Select TimeGenerated,EventID, EXTRACT_Suffix(Message, 0, 'HostApplication=') AS HostApplication  INTO $OutputFile FROM '$WinPowerShell_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $PSPartialCode= GetStats $OutputFile
    Write-Host "Partial Scripts Code : " $PSPartialCode   -ForegroundColor Green
}

#==============Task Scheduler=============

function ScheduledTasksCreated {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=106
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTasksCreated.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksCreated= GetStats $OutputFile
    Write-Host "Scheduled Tasks Updated : " $ScheduledTasksCreated  -ForegroundColor Green
 
}

function ScheduledTasksUpdated {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=140
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTasksUpdated.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksUpdated= GetStats $OutputFile
    Write-Host "Scheduled Tasks Updated : " $ScheduledTasksUpdated  -ForegroundColor Green
 
}

function ScheduledTasksDeleted {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=141
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTasksDeleted.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as TaskName, extract_token(strings, 1, '|') as User INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksDeleted= GetStats $OutputFile
    Write-Host "Scheduled Tasks Deleted : " $ScheduledTasksDeleted  -ForegroundColor Green
 
}

function ScheduledTasksExecuted {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=200
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTasksExecuted.csv"
    $Query= "Select TimeGenerated,EventID, extract_token(strings,0, '|') as TaskName, extract_token(strings, 1, '|') as TaskAction, extract_token(strings, 2, '|') as Instance  INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksExecuted= GetStats $OutputFile
    Write-Host "Scheduled Tasks Executed : " $ScheduledTasksExecuted  -ForegroundColor Green
}


function ScheduledTasksCompleted {
    if ($Valid_TaskScheduler_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TaskScheduler%4Maintenance event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=201
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "ScheduledTasksCompleted.csv"
    $Query= "Select TimeGenerated,EventID, extract_token(strings,0, '|') as TaskName, extract_token(strings, 1, '|') as TaskAction, extract_token(strings, 2, '|') as Instance  INTO $OutputFile FROM '$TaskScheduler_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $ScheduledTasksCompleted= GetStats $OutputFile
    Write-Host "Scheduled Tasks Completed : " $ScheduledTasksCompleted  -ForegroundColor Green
}

##============= Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx============
function RDPLocalSuccessfulLogon1 {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=21
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPLocalSuccessfulLogon1.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulLogon1= GetStats $OutputFile
    Write-Host "RDP Local Successful Logons [EventID=21] : " $RDPLocalSuccessfulLogon1 -ForegroundColor Green
}

function RDPLocalSuccessfulLogon2 {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=22
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPLocalSuccessfulLogon2.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulLogon2= GetStats $OutputFile
    Write-Host "RDP Local Successful Logons [EventID=22]: " $RDPLocalSuccessfulLogon2 -ForegroundColor Green
}

function RDPLocalSuccessfulReconnection {
    if ($Valid_TerminalServices_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=22
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPLocalSuccessfulReconnection.csv"
    $Query= "Select TimeGenerated,EventID , extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as SessionID ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$TerminalServices_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPLocalSuccessfulReconnection= GetStats $OutputFile
    Write-Host "RDP Local Successful Reconnections: " $RDPLocalSuccessfulReconnection -ForegroundColor Green
}

#=========================Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx=======================
function RDPConnectionEstablished {
    if ($Valid_RemoteConnection_Path -eq $false) {
        write-host "Error: Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=1149
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPConnectionEstablished.csv"
    $Query= "Select TimeGenerated,EventID  ,extract_token(strings, 0, '|') as User, extract_token(strings, 1, '|') as Domain ,extract_token(strings,2, '|') as SourceIP   INTO $OutputFile FROM '$RemoteConnection_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPConnectionEstablished= GetStats $OutputFile
    Write-Host "RDP Connections Established: " $RDPConnectionEstablished -ForegroundColor Green
    
    
}


#============Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx=============

function RDPConnectionsAttempts {
    if ($Valid_RDPCORETS_Path -eq $false) {
        write-host "Error: Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=131
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPConnectionsAttempts.csv"
    $Query= "Select TimeGenerated,EventID  ,extract_token(strings, 0, '|') as ConnectionType, extract_token(strings, 1, '|') as CLientIP INTO $OutputFile FROM '$RDPCORETS_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPConnectionsAttempts= GetStats $OutputFile
    Write-Host "RDP Connections Attempts : " $RDPConnectionsAttempts -ForegroundColor Green
}

function RDPSuccessfulTCPConnections {
    if ($Valid_RDPCORETS_Path -eq $false) {
        write-host "Error: Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational event log is not found" -ForegroundColor Red
        return  
    }
    $EventID=98
    $OutputFile= Join-Path -Path $Destination_Path -ChildPath "RDPSuccessfulTCPConnections.csv"
    $Query= "Select TimeGenerated,EventID  INTO $OutputFile FROM '$RDPCORETS_Path' WHERE EventID = $EventID"
    LogParser.exe -stats:OFF -i:EVT $Query
    $RDPSuccessfulTCPConnections= GetStats $OutputFile
    Write-Host "RDP Successful TCP Connections: " $RDPSuccessfulTCPConnections -ForegroundColor Green
}