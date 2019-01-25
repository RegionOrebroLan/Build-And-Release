# Build-And-Release

PowerShell-scripts and task-groups to use with build- and release-definitions in TFS.

## 1 PowerShell-scripts

### [1.1 Create release packages (Create-Release-Packages.ps1)](/Source/Scripts/Create-Release-Packages.ps1)

To get this script to work, to create release packages properly, you need to build the project correctly.
To build the project correctly use the following arguments (MSBuild Arguments) for the **Visual Studio Build**-task:

    /p:_PackageTempDir=$(Build.ArtifactStagingDirectory)\Package\
    /p:AutoParameterizationWebConfigConnectionStrings=false
    /p:DeployOnBuild=true
    /p:MarkWebConfigAssistFilesAsExclude=false
    /p:PackageAsSingleFile=false
    /p:ProfileTransformWebConfigEnabled=false
    /p:SkipInvalidConfigurations=true
    /p:TransformWebConfigEnabled=false
    /p:WebPublishMethod=FileSystem

#### 1.1.1 Argument examples for [Create-Release-Packages.ps1](/Source/Scripts/Create-Release-Packages.ps1)

##### 1.1.1.1
 
    -Environments @{"Development"=@{"MachineName"="SYSTEM-DEVELOPMENT-01"};"Test"=@{"MachineName"="SYSTEM-TEST-01"};"Stage"=@{"Stage-A"=@{"MachineName"="SYSTEM-STAGE-02";"PathToDeletePatterns"=@("Modules")};"Stage-B"=@{"MachineName"="SYSTEM-STAGE-03";"PathToDeletePatterns"=@("Modules")};"Stage-Edit"=@{"MachineName"="SYSTEM-STAGE-01"}};"Production"=@{"Production-A"=@{"MachineName"="SYSTEM-PRODUCTION-02";"PathToDeletePatterns"=@("Modules")};"Production-B"=@{"MachineName"="SYSTEM-PRODUCTION-03";"PathToDeletePatterns"=@("Modules")};"Production-Edit"=@{"MachineName"="SYSTEM-PRODUCTION-01"}}}
    -PackagePath $(System.DefaultWorkingDirectory)\Build\Drop\Package\
    -ReleaseDirectoryPath \\SOME-MACHINE\Releases\
    -ReleaseName $(Release.ReleaseName)
    -SystemName Company-Web

##### 1.1.1.2

    -Environments @{"Development"=@{"MachineName"="SYSTEM-DEVELOPMENT-01"};"Test"=@{"MachineName"="SYSTEM-TEST-01"};"Stage"=@{"Stage-A"=@{"MachineName"="SYSTEM-STAGE-02";"PathToDeletePatterns"=@("Modules")};"Stage-B"=@{"MachineName"="SYSTEM-STAGE-03";"PathToDeletePatterns"=@("Modules")};"Stage-Edit"=@{"MachineName"="SYSTEM-STAGE-01"}};"Production"=@{"Production-A"=@{"MachineName"="SYSTEM-PRODUCTION-02";"PathToDeletePatterns"=@("Modules")};"Production-B"=@{"MachineName"="SYSTEM-PRODUCTION-03";"PathToDeletePatterns"=@("Modules")};"Production-Edit"=@{"MachineName"="SYSTEM-PRODUCTION-01"}}}
    -NumberOfReleasesToKeep 20
    -PackagePath $(System.DefaultWorkingDirectory)\Build\Drop\Package\
    -ReleaseDirectoryPath \\SOME-MACHINE\Releases\
    -ReleaseName $(Release.ReleaseName)
    -SystemName Company-Web

##### 1.1.1.3 - the environments-argument

    $environments = @{
	    "Development"=@{
		    "MachineName"="SYSTEM-DEVELOPMENT-01"
	    };
	    "Test"=@{
		    "MachineName"="SYSTEM-TEST-01"
	    };
	    "Stage"=@{
		    "Stage-A"=@{
			    "MachineName"="SYSTEM-STAGE-02";
			    "PathToDeletePatterns"=@("Modules")
		    };
		    "Stage-B"=@{
			    "MachineName"="SYSTEM-STAGE-03";
			    "PathToDeletePatterns"=@("Modules")
		    };
		    "Stage-Edit"=@{
			    "MachineName"="SYSTEM-STAGE-01"
		    }
	    };
	    "Production"=@{
		    "Production-A"=@{
			    "MachineName"="SYSTEM-PRODUCTION-02";
			    "PathToDeletePatterns"=@("Modules")
		    };
		    "Production-B"=@{
			    "MachineName"="SYSTEM-PRODUCTION-03";
			    "PathToDeletePatterns"=@("Modules")
		    };
		    "Production-Edit"=@{
			    "MachineName"="SYSTEM-PRODUCTION-01"
		    }
	    }
    };

## 2 Task-groups

### [2.1 Create release packages (Create-Release-Packages.json)](/Source/Task-Groups/Create-Release-Packages.json)

Requires the [**DownloadFile-task**](https://marketplace.visualstudio.com/items?itemName=automagically.DownloadFile).