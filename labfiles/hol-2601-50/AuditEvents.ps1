Install-Module VMware.vSphere.SsoAdmin
Install-Module VMware.PowerCLI
Import-Module VMware.PowerCLI
Import-Module VMware.vSphere.SsoAdmin

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

Function New-RandomPassword {
    param (
        [int]$length = 12
    )

    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+[]{}|;:,.<>?'
    $bytes = [byte[]]::new($length)
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
    $password = -join ($bytes | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    return $password
}

########################################################################
## FUNCTIONS BEFORE THIS LINE
########################################################################

$password = Get-Content "/home/holuser/Desktop/PASSWORD.txt" -TotalCount 1
$vcFqdn = "vc-wld01-a.site-a.vcf.lab"

$users = @(
    @{username="audituser"; domain="wld.sso"; password=$password; firstname="audit"; lastname="user"; description="Created By Script"; roleName="HOL_Auditor"; EntityName="wld-01a-DC"; EntityType="Datacenter"}
    @{username="rogueadmin"; domain="wld.sso"; password=$password; firstname="rogue"; lastname="admin"; description="Created By Script"; roleName="Admin"; EntityName="wld-01a-DC"; EntityType="Datacenter"}
)

foreach ($user in $Users) {
    $DomainUsername = $user.username+"@"+$user.domain
    $randomPassword = New-RandomPassword -length 12
    
    ConnectToVcenter -vc $vcFqdn -username $DomainUsername -password $randomPassword
    sleep(5)
    ConnectToVcenter -vc $vcFqdn -username $DomainUsername -password $password

    Disconnect-VIServer -Confirm:$false
    
}