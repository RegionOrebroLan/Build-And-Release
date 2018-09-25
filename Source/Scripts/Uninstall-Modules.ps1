# This does not seem to work for the system-account:
#Uninstall-Module "RegionOrebroLan.IO" -AllVersions -Force;
#Uninstall-Module "RegionOrebroLan.Transforming" -AllVersions -Force;

# Maybe we need to delete them from disk:
# C:\Windows\ServiceProfiles\NetworkService\Documents\WindowsPowerShell\Modules\RegionOrebroLan.IO\1.0.0\RegionOrebroLan.PowerShell.IO.dll
# C:\Windows\ServiceProfiles\NetworkService\Documents\WindowsPowerShell\Modules\RegionOrebroLan.Transforming\1.0.0\RegionOrebroLan.PowerShell.Transforming.dll

Remove-Item -Path "C:\Windows\ServiceProfiles\NetworkService\Documents\WindowsPowerShell\Modules\RegionOrebroLan.IO" -Recurse -Force;
Remove-Item -Path "C:\Windows\ServiceProfiles\NetworkService\Documents\WindowsPowerShell\Modules\RegionOrebroLan.Transforming" -Recurse -Force;