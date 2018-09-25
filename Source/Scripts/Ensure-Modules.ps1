$_validationCommandKey = "ValidationCommand";

$repositoryExists = $false;
$repositoryName = "RegionOrebroLan-Temporary-PowerShell-Gallery";
$repositoryPath = "\\DEV01\Temporary-PowerShell-Gallery\";
# Module "RegionOrebroLan.Transforming" requires .NET Framework 4.6 or higher.
$requiredModules = @{
	"RegionOrebroLan.IO"=@{
		$_validationCommandKey="Get-FileSystemEntryPathMatch"
	};
	"RegionOrebroLan.Transforming"=@{
		$_validationCommandKey="New-PackageTransform"
	}
};

foreach($repository in Get-PSRepository)
{
    if($repository.Name -eq $repositoryName)
    {
        $repositoryExists = $true;
        break;
    }
}

if(!$repositoryExists)
{
    Write-Host "Registering repository ""$($repositoryName)""...";
    Register-PSRepository -Name $repositoryName -InstallationPolicy Trusted -Scope CurrentUser -SourceLocation $repositoryPath;
}

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
		Install-Module -Name $key -Scope CurrentUser -Force; # -Scope CurrentUser;
	}
}

$ErrorActionPreference = $currentErrorActionPreference;