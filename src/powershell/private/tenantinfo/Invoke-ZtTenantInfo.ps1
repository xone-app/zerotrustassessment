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
        Write-PSFMessage -Level Warning -Message "Error in Add-ZtTenantOverview: $_" -ErrorRecord $_ -Tag TenantInfo
    }

    # Only run if Pillar is All or Identity
    if ($Pillar -in ('All', 'Identity')) {
        try {
            Add-ZtOverviewCaMfa -Database $Database
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Error in Add-ZtOverviewCaMfa: $_" -ErrorRecord $_ -Tag TenantInfo
        }

        try {
            Add-ZtOverviewCaDevicesAllUsers -Database $Database
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Error in Add-ZtOverviewCaDevicesAllUsers: $_" -ErrorRecord $_ -Tag TenantInfo
        }

        try {
            Add-ZtOverviewAuthMethodsAllUsers -Database $Database
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Error in Add-ZtOverviewAuthMethodsAllUsers: $_" -ErrorRecord $_ -Tag TenantInfo
        }

        try {
            Add-ZtOverviewAuthMethodsPrivilegedUsers -Database $Database
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Error in Add-ZtOverviewAuthMethodsPrivilegedUsers: $_" -ErrorRecord $_ -Tag TenantInfo
        }
    }

    if ($Pillar -in ('All', 'Devices')) {
        $IntunePlan = Get-ZtLicenseInformation -Product Intune
        if ($null -ne $IntunePlan) {
            try {
                Add-ZtDeviceOverview -Database $Database
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Error in Add-ZtDeviceOverview: $_" -ErrorRecord $_ -Tag TenantInfo
            }

            try {
                Add-ZtDeviceWindowsEnrollment
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Error in Add-ZtDeviceWindowsEnrollment: $_" -ErrorRecord $_ -Tag TenantInfo
            }

            try {
                Add-ZtDeviceEnrollmentRestriction
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Error in Add-ZtDeviceEnrollmentRestriction: $_" -ErrorRecord $_ -Tag TenantInfo
            }

            try {
                Add-ZTDeviceCompliancePolicies
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Error in Add-ZTDeviceCompliancePolicies: $_" -ErrorRecord $_ -Tag TenantInfo
            }

            try {
                Add-ZTDeviceAppProtectionPolicies
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Error in Add-ZTDeviceAppProtectionPolicies: $_" -ErrorRecord $_ -Tag TenantInfo
            }
        }
    }
}
