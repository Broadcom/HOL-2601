#$ErrorActionPreference = "Stop"

function Write-Info {
    param (
        [string]$Message
    )
    Write-Host "INFO: $Message" -ForegroundColor Green
}

function Write-ErrorMsg {
    param (
        [string]$Message
    )
    Write-Host "ERROR: $Message" -ForegroundColor Red
}

function Write-WarnMsg {
    param (
        [string]$Message
    )
    Write-Host "WARNING: $Message" -ForegroundColor Yellow
} 

function Connect-VCenter {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$vc,
        [Parameter(Mandatory)]
        [string]$username,
        [Parameter(Mandatory)]
        [string]$Password
    )
    
    $encryptedPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $encryptedPassword

    Connect-VIServer -Server $vc -Credential $credential -Force
}

function New-RandomPassword {
    [CmdletBinding()]

    param (
        [ValidateRange(8, 128)]
        [int]$Length
    )
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+[]{}|;:,.<>?'
    $bytes = New-Object byte[] ($Length)
    [System.Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)

    $PasswordChars = for ($i = 0; $i -lt $Length; $i++) {
        $chars[ $bytes[$i] % $chars.Length ]
    }
    -join $PasswordChars
}

function Connect-SsoDomain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$vc,
        [Parameter(Mandatory)]
        [string]$username,
        [Parameter(Mandatory)]
        [string]$Password
    )
    
    $encryptedPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $encryptedPassword

    Connect-SsoAdminServer -Server $vc -Credential $credential -SkipCertificateCheck
}

function Remove-Permission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Domain,
        [Parameter(Mandatory)]
        [string]$EntityName,
        [Parameter(Mandatory)]
        [ValidateSet("VM","Host", "Datastore", "Datacenter")]
        [string]$EntityType
        )    

    try {

        if ($EntityType -eq "Datacenter") {
            $entity = Get-Datacenter -Name $EntityName
        } else {
            $entity = Get-View (Get-Inventory -Name $EntityName -NoRecursion | Where-Object {$_.GetType().Name -eq $EntityType}).Id
        }

        $permission = Get-VIPermission -Principal "$Domain\$Username" -Entity $entity
        
        Remove-VIPermission -Permission $permission -Confirm:$false       
    } catch {
        Write-ErrorMsg "Failed to delete '$Username@$Domain' permission '$permission' from '$EntityName': $_"       
    }

}
function Set-Permission {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Domain,
        [Parameter(Mandatory)]
        [string]$RoleName,
        [Parameter(Mandatory)]
        [ValidateSet("VM","Host", "Datastore", "Datacenter")]
        [string]$EntityType,
        [Parameter(Mandatory)]
        [string]$EntityName,
        [Parameter(Mandatory)]
        [bool]$Propagate = $true
    )

    try {       
        if ($EntityType -eq "Datacenter") {
            $entity = Get-Datacenter -Name $EntityName 
        } else {
            $entity = Get-View (Get-Inventory -Name $EntityName -NoRecursion | Where-Object {$_.GetType().Name -eq $EntityType}).Id 
        }
        if (-not $entity){
            throw "Entity '$EntityName' of type '$EntityType' not found."
        }

        $role = Get-VIRole -Name $RoleName -ErrorAction Stop 

        New-VIPermission -Principal "$Domain\$Username" -Role $role -Entity $entity -Propagate:$Propagate -Confirm:$false 

        Write-Info "Role '$RoleName' assigned to '$Username@$Domain' on '$EntityName'."
    } catch {
        Write-ErrorMsg "Failed to assign permission to '$Username@$Domain': $_"
    }
}

function New-SsoUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Password,
        [Parameter(Mandatory)]
        [string]$Domain,
        [Parameter(Mandatory)]
        [string]$Firstname,
        [Parameter(Mandatory)]
        [string]$Lastname,
        [Parameter(Mandatory)]
        [string]$Description
    )
    
    try {

        $ssoUser = Get-SsoPersonUser -Name $Username -Domain $Domain 

        if ($ssoUser) {
            Write-Info "User '$Username' already exists in the '$Domain' domain."
        } else {
            New-SsoPersonUser -UserName $Username -Password $Password -FirstName $Firstname -LastName $Lastname -Email "$Username@$Domain" -Description $Description 

            Write-Info "User '$Username' in SSO Domain '$Domain' created successfully."
        }
    } catch {
        Write-ErrorMsg "Failed to create user: '$Username@$Domain': $_"
    }
}

function Remove-SsoUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Domain
    )
    
    try {

        $ssoUser = Get-SsoPersonUser -Name $Username -Domain $Domain 

        if ($ssoUser) {
            Write-Info "User '$Username' found in the '$Domain' domain."
            Get-SsoPersonUser -Name $Username -Domain $Domain | Remove-SsoPersonUser 
            Write-Info "User '$Username' in domain '$Domain' deleted."
        } else {
            Write-WarnMsg "User '$Username' not found in SSO Domain '$Domain'."
        }
    } catch {
        Write-ErrorMsg "Failed to delete user: '$Username@$Domain': $_"
    }
}

function New-Role {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RoleName,
        [Parameter(Mandatory=$true)]
        [string[]]$Privileges
    )

    try {
        $existingRole = Get-VIRole -Name $RoleName -ErrorAction SilentlyContinue 

        if ($existingRole) {
            Write-Info "INFO: Role '$RoleName' already exists."
        } else {
            $newRole = New-VIRole -Name $RoleName -Privilege (Get-VIPrivilege -id $Privileges) -ErrorAction Stop 
            Write-Info "INFO: Successfully created role '$RoleName'."
            return $NewRole
        }
    } catch {
        Write-ErrorMsg "ERROR: Failed to create role '$RoleName'. $_"
    }
}

function Remove-Role {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$RoleName
    )
    Write-Info "TASK: Remove Role: '$RoleName'."
    try {
        $role = Get-VIRole -Name $RoleName -ErrorAction SilentlyContinue 

        if ($role) {
            Remove-VIRole -Role $role -Confirm:$false
            Write-Info "INFO: Role '$RoleName' removed."
        } else {
            Write-WarnMsg "INFO: Role '$RoleName' does not exist."
        }
    } catch {
        Write-ErrorMsg "ERROR: Failed to delete role '$RoleName'. $_"
    }
}

########################################################################
## FUNCTIONS BEFORE THIS LINE
########################################################################

$modules = @("VCF.PowerCLI", "VMware.vSphere.SsoAdmin")

$PasswordFiles = @(
    "/home/holuser/creds.txt",
    "/home/holuser/Desktop/PASSWORD.txt"
)

$Password = $null

foreach ($file in $PasswordFiles) {
    if (Test-Path -Path $file -PathType Leaf) {
        $content = (Get-Content $file -TotalCount 1).Trim()
        if ($content) {
            $Password = $content
            Write-Info "Password retrieved from file: $file"
            break
        }
    }
}

if (-not $Password) {
    Write-ErrorMsg "Password not found in any of the specified files."
    exit 1
}

$vcFqdn = "vc-wld01-a.site-a.vcf.lab"
$vcUsername = "administrator@wld.sso"

$users = @(
    @{username="audituser"; domain="wld.sso"; password=$Password; firstname="audit"; lastname="user"; description="Created By Script"; roleName="HOL_Auditor"; EntityName="dc-a"; EntityType="Datacenter"}
    @{username="rogueadmin"; domain="wld.sso"; password=$Password; firstname="rogue"; lastname="admin"; description="Created By Script"; roleName="Admin"; EntityName="dc-a"; EntityType="Datacenter"}
    @{username="rogueuser"; domain="wld.sso"; password=$Password; firstname="rogue"; lastname="user"; description="Created By Script"; roleName="TrustedAdmin"; EntityName="dc-a"; EntityType="Datacenter"}
)

Write-Info "Importing PowerCLI Modules"

foreach ($module in $modules) {
    if (-Not (Get-Module -ListAvailable -Name $module )) {
        Write-Info "Module '$module' is not installed. Installing."
        Install-Module $module -Force 
    } 

    Import-Module $module -Force
    Write-Info "Module '$module' imported."
}

Connect-SsoDomain -vc $vcFqdn -username $vcUsername -password $Password
Connect-VCenter -vc $vcFqdn -username $vcUsername -password $Password

New-Role -RoleName "Hol_Auditor" -Privileges @("System.Anonymous", "System.Read", "System.View", "Namespaces.Observe","Namespaces.ListAccess", "Namespaces.View") 

foreach ($user in $Users) {
    New-SsoUser -Username $user.username -Domain $user.domain -Password $user.password -Firstname $user.firstname -Lastname $user.lastname -Description $user.description 
    Set-Permission -Username $user.username -Domain $user.domain -RoleName $user.roleName -EntityName $user.EntityName -EntityType $user.EntityType -Propagate:$true 
}

Disconnect-VIServer -Confirm:$false
Disconnect-SsoAdminServer -Server $vcFqdn

Start-Sleep -Seconds 10

foreach ($user in $Users) {
    $DomainUsername = $user.username+"@"+$user.domain 
    
    for ($i = 1; $i -lt 3; $i++) {
        Write-Info "Attempting to connect to vCenter with '$DomainUsername' and incorrect password. Attempt $($i+1) of 3."
        $randomPassword = New-RandomPassword -Length 12
        Connect-VCenter -vc $vcFqdn -username $DomainUsername -password $randomPassword
        Start-Sleep -Seconds 5

    }
    Connect-VCenter -vc $vcFqdn -username $DomainUsername -password $Password

    Disconnect-VIServer -Confirm:$false
    
}

Disconnect-VIServer -Confirm:$false
Disconnect-SsoAdminServer -Server $vcFqdn