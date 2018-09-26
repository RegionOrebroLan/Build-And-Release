$_validationCommandKey = "ValidationCommand";

# Module "RegionOrebroLan.Transforming" must be published to https://www.powershellgallery.com/. At the moment its not possible. Waiting for reply.
# Module "RegionOrebroLan.Transforming" requires .NET Framework 4.6 or higher.
$requiredModules = @{
	"RegionOrebroLan.Transforming"=@{
		$_validationCommandKey="New-PackageTransform"
	}
};

$currentErrorActionPreference = $ErrorActionPreference;
$ErrorActionPreference = "Stop";

foreach($key in $requiredModules.Keys)
{
	try
	{
		$command = Get-Command -Name $requiredModules[$key][$_validationCommandKey];

		# Information
		Write-Host "DLL: $($command.DLL)";
		Write-Host "Implementing-type: $($command.ImplementingType)";
		Write-Host "Module: $($command.Module)";
	}
	catch
	{
		Write-Host "Installing module ""$($key)""...";
		Install-Module -Name $key -Scope CurrentUser -Force;
	}
}

$ErrorActionPreference = $currentErrorActionPreference;