# Increment the value of a build-variable i TFS. Only tested in on-prem environment.
# Prerequisites:
# 1) "Allow scripts to access OAuth token" must be enabled in the Agent phase of the build definition.
# 2) The Project Collection Build Service must have "Edit build definition" set to "Allow"
param (
    [Parameter(Mandatory=$true,Position=0)][string]$versionVariableName
 )

# START OF VALUES TO BE SET BY THE USER
$apiVersion ="4.1"   #ensures all the API calls use the same API Version
# END OF VALUES TO BE SET BY THE USER

$uriRoot = $env:SYSTEM_TEAMFOUNDATIONSERVERURI
$ProjectName = $env:SYSTEM_TEAMPROJECT
$uri = "$uriRoot$ProjectName/_apis/build/definitions?api-version=$apiVersion"
$buildDefName = $env:BUILD_DEFINITIONNAME;
$sysToken = $env:SYSTEM_ACCESSTOKEN;
# Write-Host "Token : $sysToken";
# Base64-encodes the Access Token appropriately
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "", $sysToken)))
$header = @{Authorization = ("Basic {0}" -f $base64AuthInfo)}

# Get the list of Build Definitions
$buildDefs = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers $header

# Find the build definition for this project
$buildDef = $buildDefs.value | Where-Object { $_.Name -eq $buildDefName }
if (  $null -eq $buildDef)
{
    Write-Error "Unable to find a build definition for Project '$ProjectName'. Check the config values and try again." -ErrorAction Stop
}
$getUrl = "$($buildDef.Url)?api-version=$apiVersion"
$projectDef = Invoke-RestMethod -Uri $getUrl -Method Get -ContentType "application/json" -Headers $header

if ($null -eq $projectDef.variables.$versionVariableName)
{
    Write-Error "Unable to find a variable called '$versionVariableName' in Project $ProjectName. Please check the config and try again." -ErrorAction Stop
}
# get and increment the variable in $versionVariableName
[int]$counter = [convert]::ToInt32($projectDef.variables.$versionVariableName.Value, 10)
$updatedCounter = $counter + 1
Write-Host "Project Build Number for '$ProjectName/$buildDefName' is $counter. Will be updating to $updatedCounter"

# Update the value and update VSTS
$projectDef.variables.$versionVariableName.Value = $updatedCounter.ToString()
$projectDefJson = $projectDef | ConvertTo-Json -Depth 100 -Compress

# build the URL to cater for if the Project Definition URL already has parameters or not.
$separator = "?"
if ($projectDef.Url -like '*?*')
{
    $separator = "&"
}
$putUrl = "$($projectDef.Url)$($separator)api-version=$apiVersion"
Write-Host "Updating Project Build number with URL: $putUrl"
Invoke-RestMethod -Method Put -Uri $putUrl -Headers $header -ContentType "application/json" -Body ([System.Text.Encoding]::UTF8.GetBytes($projectDefJson))  | Out-Null