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

Function ConnectToSsoDomain {
    param (
        [string]$vc,
        [string]$username,
        [string]$password
    )
    
    $encryptedPassword = ConvertTo-SecureString -String $password -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $encryptedPassword

    Connect-SsoAdminServer -Server $vc -Credential $credential -SkipCertificateCheck
}

Function Remove-Permission {
    param (    
        [string]$Username,
        [string]$Domain,
        [string]$RoleName,
        [string]$EntityName,
        [ValidateSet("VM","Host", "Datastore", "Datacenter")][string]$EntityType
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
        Write-Host "ERROR: Failed to delete '$Username@$Domain' permission '$permission' from '$EntityName': $_" -ForegroundColor Red        
    }

}

Function Set-Permission {
    param (
        [string]$Username,
        [string]$Domain,
        [string]$RoleName,
        [string]$EntityName,
        [ValidateSet("VM","Host", "Datastore", "Datacenter")][string]$EntityType,
        [bool]$Propagate=$true
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

        Write-Host "INFO: Role '$RoleName' assigned to '$Username@$Domain' on '$EntityName'." -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to assign permission to '$Username@$Domain': $_" -ForegroundColor Red
    }
}

Function New-SsoUser {
    param (
        [string]$Username,
        [string]$Password,
        [string]$Domain,
        [string]$Firstname,
        [string]$Lastname,
        [string]$Description
    )
    
    try {

        $ssoUser = Get-SsoPersonUser -Name $Username -Domain $Domain 

        if ($ssoUser) {
            Write-Host "INFO: User '$Username' already exists in the '$Domain' domain." -ForegroundColor Yellow
        } else {
            New-SsoPersonUser -UserName $Username -Password $Password `
                          -FirstName $Firstname -LastName $Lastname -Email "$Username@$Domain" `
                          -Description $Description

            Write-Host "INFO: User '$Username' in SSO Domain '$Domain' created successfully." -ForegroundColor Green
        }
    } catch {
        Write-Host "ERROR: Failed to create user: '$Username@$Domain': $_" -ForegroundColor Red
    }
}

Function Remove-SsoUser {
    param (
        [string]$Username,
        [string]$Password,
        [string]$Domain
    )
    
    try {

        $ssoUser = Get-SsoPersonUser -Name $Username -Domain $Domain 

        if ($ssoUser) {
            Write-Host "INFO: User '$Username' found in the '$Domain' domain." -ForegroundColor White
            Get-SsoPersonUser -Name $Username -Domain $Domain | Remove-SsoPersonUser
            Write-Host "INFO: User '$Username' in domain '$Domain' deleted." -ForegroundColor Green
        } else {
            Write-Host "INFO: User '$Username' not found in SSO Domain '$Domain'." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "ERROR: Failed to delete user: '$Username@$Domain': $_" -ForegroundColor Red
    }
}

Function New-Role {
    param (
        [Parameter(Mandatory=$true)][string]$RoleName,
        [Parameter(Mandatory=$true)][string[]]$Privileges
    )

    try {
        $existingRole = Get-VIRole -Name $RoleName -ErrorAction SilentlyContinue

        if ($existingRole) {
            Write-Host "INFO: Role '$RoleName' already exists." -ForegroundColor Yellow
        } else {
            $newRole = New-VIRole -Name $RoleName -Privilege (Get-VIPrivilege -id $Privileges) -ErrorAction Stop
            Write-Host "INFO: Successfully created role '$RoleName'." -ForegroundColor Green
            return $NewRole
        }
    } catch {
        Write-Error "ERROR: Failed to create role '$RoleName'. $_"
    }
}

Function Remove-Role {
    param (
        [Parameter(Mandatory=$true)][string]$RoleName
    )
    Write-Host "TASK: Remove Role: '$RoleName'." -ForegroundColor White
    try {
        $role = Get-VIRole -Name $RoleName -ErrorAction SilentlyContinue

        if ($role) {
            Remove-VIRole -Role $role -Confirm:$false
            Write-Host "INFO: Role '$RoleName' removed." -ForegroundColor Green
        } else {
            Write-Host "INFO: Role '$RoleName' does not exist." -ForegroundColor Yellow
        }
    } catch {
        Write-Error "ERROR: Failed to delete role '$RoleName'. $_"
    }
}

########################################################################
## FUNCTIONS BEFORE THIS LINE
########################################################################

$password = Get-Content "/home/holuser/Desktop/PASSWORD.txt" -TotalCount 1
$vcFqdn = "vc-wld01-a.site-a.vcf.lab"
$vcUsername = "administrator@wld.sso"

$users = @(
    @{username="audituser"; domain="wld.sso"; password=$password; firstname="audit"; lastname="user"; description="Created By Script"; roleName="HOL_Auditor"; EntityName="wld-01a-DC"; EntityType="Datacenter"}
    @{username="rogueadmin"; domain="wld.sso"; password=$password; firstname="rogue"; lastname="admin"; description="Created By Script"; roleName="Admin"; EntityName="wld-01a-DC"; EntityType="Datacenter"}
)

ConnectToSsoDomain -vc $vcFqdn -username $vcUsername -password $password
ConnectToVcenter -vc $vcFqdn -username $vcUsername -password $password

New-Role -RoleName "Hol_Auditor" -Privileges @("System.Anonymous", "System.Read", "System.View", "Namespaces.Observe","Namespaces.ListAccess", "Namespaces.View")

foreach ($user in $Users) {
    New-SsoUser -Username $user.username -Domain $user.domain -Password $user.password -Firstname $user.firstname -Lastname $user.lastname -Description $user.description
    Set-Permission -Username $user.username -Domain $user.domain -RoleName $user.roleName -EntityName $user.EntityName -EntityType $user.EntityType -Propogate:$true
}

Disconnect-VIServer -Confirm:$false
Disconnect-SsoAdminServer -Server $vcFqdn
