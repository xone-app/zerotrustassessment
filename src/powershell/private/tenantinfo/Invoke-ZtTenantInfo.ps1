<#
.SYNOPSIS
    Runs all the cmdlets to gather tenant information.
    Each function is wrapped in try-catch to allow partial data collection.
#>

function Invoke-ZtTenantInfo {
    [CmdletBinding()]
    param (
        # The database to export the tenant information to.
        $Database,

        # The Zero Trust pillar to assess. Defaults to All.
        [ValidateSet('All', 'Identity', 'Devices')]
        [string]
        $Pillar = 'All'
    )

    # Always run (shown on dashboard)
    try {
        Add-ZtTenantOverview
    }
    catch {
        # Check if $_ is an ErrorRecord before passing to -ErrorRecord parameter
        # When ErrorActionPreference is 'Stop', $_ may be an ActionPreferenceStopException instead
        $errorParams = @{
            Level = 'Warning'
            Message = "Error in Add-ZtTenantOverview: $_"
            Tag = 'TenantInfo'
        }
        if ($_ -is [System.Management.Automation.ErrorRecord]) {
            $errorParams['ErrorRecord'] = $_
        }
        Write-PSFMessage @errorParams
    }

    # Only run if Pillar is All or Identity
    if ($Pillar -in ('All', 'Identity')) {
        try {
            Add-ZtOverviewCaMfa -Database $Database
        }
        catch {
            $errorParams = @{
                Level = 'Warning'
                Message = "Error in Add-ZtOverviewCaMfa: $_"
                Tag = 'TenantInfo'
            }
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $errorParams['ErrorRecord'] = $_
            }
            Write-PSFMessage @errorParams
        }

        try {
            Add-ZtOverviewCaDevicesAllUsers -Database $Database
        }
        catch {
            $errorParams = @{
                Level = 'Warning'
                Message = "Error in Add-ZtOverviewCaDevicesAllUsers: $_"
                Tag = 'TenantInfo'
            }
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $errorParams['ErrorRecord'] = $_
            }
            Write-PSFMessage @errorParams
        }

        try {
            Add-ZtOverviewAuthMethodsAllUsers -Database $Database
        }
        catch {
            $errorParams = @{
                Level = 'Warning'
                Message = "Error in Add-ZtOverviewAuthMethodsAllUsers: $_"
                Tag = 'TenantInfo'
            }
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $errorParams['ErrorRecord'] = $_
            }
            Write-PSFMessage @errorParams
        }

        try {
            Add-ZtOverviewAuthMethodsPrivilegedUsers -Database $Database
        }
        catch {
            $errorParams = @{
                Level = 'Warning'
                Message = "Error in Add-ZtOverviewAuthMethodsPrivilegedUsers: $_"
                Tag = 'TenantInfo'
            }
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                $errorParams['ErrorRecord'] = $_
            }
            Write-PSFMessage @errorParams
        }
    }

    if ($Pillar -in ('All', 'Devices')) {
        $IntunePlan = Get-ZtLicenseInformation -Product Intune
        if ($null -ne $IntunePlan) {
            try {
                Add-ZtDeviceOverview -Database $Database
            }
            catch {
                $errorParams = @{
                    Level = 'Warning'
                    Message = "Error in Add-ZtDeviceOverview: $_"
                    Tag = 'TenantInfo'
                }
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errorParams['ErrorRecord'] = $_
                }
                Write-PSFMessage @errorParams
            }

            try {
                Add-ZtDeviceWindowsEnrollment
            }
            catch {
                $errorParams = @{
                    Level = 'Warning'
                    Message = "Error in Add-ZtDeviceWindowsEnrollment: $_"
                    Tag = 'TenantInfo'
                }
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errorParams['ErrorRecord'] = $_
                }
                Write-PSFMessage @errorParams
            }

            try {
                Add-ZtDeviceEnrollmentRestriction
            }
            catch {
                $errorParams = @{
                    Level = 'Warning'
                    Message = "Error in Add-ZtDeviceEnrollmentRestriction: $_"
                    Tag = 'TenantInfo'
                }
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errorParams['ErrorRecord'] = $_
                }
                Write-PSFMessage @errorParams
            }

            try {
                Add-ZTDeviceCompliancePolicies
            }
            catch {
                $errorParams = @{
                    Level = 'Warning'
                    Message = "Error in Add-ZTDeviceCompliancePolicies: $_"
                    Tag = 'TenantInfo'
                }
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errorParams['ErrorRecord'] = $_
                }
                Write-PSFMessage @errorParams
            }

            try {
                Add-ZTDeviceAppProtectionPolicies
            }
            catch {
                $errorParams = @{
                    Level = 'Warning'
                    Message = "Error in Add-ZTDeviceAppProtectionPolicies: $_"
                    Tag = 'TenantInfo'
                }
                if ($_ -is [System.Management.Automation.ErrorRecord]) {
                    $errorParams['ErrorRecord'] = $_
                }
                Write-PSFMessage @errorParams
            }
        }
    }
}
