Import-Module VMware.PowerCLI

Function ConnectToVcenter {
param (
[string]$vc,
[string]$username,
[string]$password
)

$encryptedPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $encryptedPassword

Connect-VIServer -Server $vc -Credential $credential -Force
}

########################################################################
## FUNCTIONS BEFORE THIS LINE
########################################################################

$password = Get-Content "/home/holuser/Desktop/PASSWORD.txt" -TotalCount 1
$vcFqdn = "vc-wld01-a.site-a.vcf.lab"
$vcUsername = "administrator@wld.sso"

$vm = "hol-snapshot-001"

ConnectToVcenter -vc $vcFqdn -username $vcUsername -password $password

Get-vm $vm | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemLimitGB 1 -CpuLimitMhz 500 | Out-Null

Write-Warning -Message "DO NOT CLOSE THIS WINDOW, Script is still running in the background to allow VCF Operations to collect data"
Start-Sleep -Seconds 500
Get-vm $vm | Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemLimitGB $null -CpuLimitMhz $null | Out-Null
Write-Warning -Message "Script execution completed, we can go ahead and close this window."
Disconnect-VIServer -Confirm:$false