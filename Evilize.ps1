function Evilize  {
    $Method= Read-Host -Prompt "Evilize Events using Logparser Or WinEvent? [Default=Logparser]" 
    IF(($Method -eq "Logparser") -or ($Method -eq "")){
        . .\Logparser.ps1
    }
    elseif (($Method -eq "Logparser")) {
        . .\WinEvent.ps1
    }
}
