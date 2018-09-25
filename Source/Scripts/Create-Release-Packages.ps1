param
(
	[Parameter(Mandatory)]
	[hashtable]$environments,
	[int]$numberOfReleasesToKeep = 10,
	[Parameter(Mandatory)]
	[string]$packagePath,
	[Parameter(Mandatory)]
	[string]$releaseDirectoryPath,
	[Parameter(Mandatory)]
	[string]$releaseName,
	[Parameter(Mandatory)]
	[string]$systemName
)

function TryAddReleasePackageInformation
{
	param
	(
		[Parameter(Mandatory)]
		[string]$_directoryPath,
		[Parameter(Mandatory)]
		[hashtable]$_environment,
		[Parameter(Mandatory)]
		[hashtable]$_releasePackageInformationList,
		[Parameter(Mandatory)]
		[string]$_transformationName
	)

	if($_environment.ContainsKey($machineNameKey))
	{
		$_pathToDeletePatterns = New-Object System.Collections.Generic.List[string];
		
		foreach($pathToDeletePattern in $pathToDeletePatterns)
		{
			$_pathToDeletePatterns.Add($pathToDeletePattern);
		}

		$_explicitPathToDeletePatterns = $_environment[$pathToDeletePatternsKey];
		
		if($_explicitPathToDeletePatterns)
		{
			foreach($explicitPathToDeletePattern in $_explicitPathToDeletePatterns)
			{
				$_pathToDeletePatterns.Add($explicitPathToDeletePattern);
			}
		}

		$_transformationNames = New-Object System.Collections.Generic.List[string];

		foreach($transformationName in $transformationNames)
		{
			$_transformationNames.Add($transformationName);
		}

		$_transformationNames.Add($_transformationName);

		$_releasePackageInformation = New-Object System.Collections.Hashtable;

		$_releasePackageInformation.Add($machineNameKey, $_environment[$machineNameKey]);
		$_releasePackageInformation.Add($pathToDeletePatternsKey, $_pathToDeletePatterns);
		$_releasePackageInformation.Add($transformationNamesKey, $_transformationNames);

		$_releasePackageInformationList.Add($_directoryPath, $_releasePackageInformation);

		return $true;
	}

	return $false;
}

$currentErrorActionPreference = $ErrorActionPreference;
$ErrorActionPreference = "Stop";

$fileToTransformPatterns = @("**\*.config", "**\*.json", "**\*.xml");
$machineNameKey = "MachineName";
$pathToDeletePatterns = @("bin\**\*.pdb", "bin\**\*.config");
$pathToDeletePatternsKey = "PathToDeletePatterns";
$transformationNames = @("Release");
$transformationNamesKey = "TransformationNames";

Write-Host "Account running the process: ""$($env:UserName)""";

Write-Host "Package-path: ""$($packagePath)""";

if(!(Test-Path -Path $packagePath))
{
	throw [System.IO.IOException] "There is no directory/file with path ""$($packagePath)"".";
}

$ErrorActionPreference = $currentErrorActionPreference;

if(!(Test-Path -Path $releaseDirectoryPath))
{
	throw [System.IO.DirectoryNotFoundException] "There is no release-directory with path ""$($releaseDirectoryPath)"".";
}

$systemReleaseDirectoryPath = Join-Path -ChildPath $systemName -Path $releaseDirectoryPath;

if(!(Test-Path -Path $systemReleaseDirectoryPath))
{
	Write-Host "Creating system-release-directory ""$($systemReleaseDirectoryPath)"" ...";
	New-Item -ItemType Directory -Path $systemReleaseDirectoryPath;
}

$currentReleaseDirectoryPath = Join-Path -ChildPath $releaseName -Path $systemReleaseDirectoryPath;

Write-Host "Creating current release-directory ""$($currentReleaseDirectoryPath)"" ...";
New-Item -ItemType Directory -Path $currentReleaseDirectoryPath;

$releasePackageInformationList = New-Object System.Collections.Hashtable;

foreach($key in $environments.Keys)
{
	$environmentDirectoryPath = Join-Path -ChildPath $key -Path $currentReleaseDirectoryPath;
	Write-Host "Creating environment-directory ""$($environmentDirectoryPath)"" ...";
	New-Item -ItemType Directory -Path $environmentDirectoryPath;

	if(!(TryAddReleasePackageInformation $environmentDirectoryPath $environments[$key] $releasePackageInformationList $key))
	{
		foreach($subKey in $environments[$key].Keys)
		{
			$subEnvironmentDirectoryPath = Join-Path -ChildPath $subKey -Path $environmentDirectoryPath;
			Write-Host "Creating sub-environment-directory ""$($subEnvironmentDirectoryPath)"" ...";
			New-Item -ItemType Directory -Path $subEnvironmentDirectoryPath;

			TryAddReleasePackageInformation $subEnvironmentDirectoryPath $environments[$key][$subKey] $releasePackageInformationList $subKey;
		}
	}
}

foreach($key in $releasePackageInformationList.Keys)
{
	Write-Host "Creating release-package at ""$($key)"" ...";

	$_destination = Join-Path -ChildPath "Package.zip" -Path $key;
	$_releasePackageInformation = $releasePackageInformationList[$key];

	$machineNameFilePath = Join-Path -ChildPath "$($_releasePackageInformation[$machineNameKey]).txt" -Path $key;
	Write-Host "Creating machine-name-file ""$($machineNameFilePath)"" ...";
	New-Item -ItemType File -Path $machineNameFilePath;

	Write-Host "Transforming package ...";

	$_transformationNames = $_releasePackageInformation[$transformationNamesKey];

	New-PackageTransform `
		-Destination $_destination `
		-FileToTransformPatterns $fileToTransformPatterns `
		-PathToDeletePatterns $_releasePackageInformation[$pathToDeletePatternsKey] `
		-Source $packagePath `
		-TransformationNames $_transformationNames;
}

$index = 1;
foreach($releaseDirectory in Get-ChildItem $systemReleaseDirectoryPath | Sort-Object CreationTime -Descending)
{
	if($numberOfReleasesToKeep -lt $index)
	{
		Write-Host "Removing release ""$($releaseDirectory.FullName)"" ...";
		Remove-Item -Path $releaseDirectory.FullName -Recurse -Force;
	}
	else
	{
		Write-Host "$($index). Name: ""$($releaseDirectory.Name)"", Creation-time: $($releaseDirectory.CreationTime.ToString()) (keeping this release)";
	}
    
	$index = $index + 1;
}