# Module "RegionOrebroLan.Transforming", https://www.powershellgallery.com/packages/RegionOrebroLan.Transforming/, requires .NET Framework 4.6 or higher.

$requiredModules = @("RegionOrebroLan.Transforming");

foreach($module in $requiredModules)
{
	if(Get-Module -ListAvailable -Name $module)
	{
		Write-Host "Module ""$($module)"" already installed.";
	} 
	else
	{
		Write-Host "Installing module ""$($module)""...";
		Install-Module -Force -Name $module -Scope CurrentUser;
	}
}