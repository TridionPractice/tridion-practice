# Check versions of content delivery Jar files #


## Introduction ##

When you are troubleshooting content delivery issues, it's sometimes very useful to be able to verify that the jars you have in place match those on a "known good" system. Of course, a Jar file is just a zip archive, so you can open one up using widely available tools, but it's very difficult to keep your focus through such a tedious task. A script is called for.

# Details #

When Tridion Jars are built, the Tridion build server adds various information to the manifest. Here's an example from the cd\_core.jar
```
Manifest-Version: 1.0
Archiver-Version: Plexus Archiver
Created-By: Apache Maven
Built-By: SRV-CDBUILD
Build-Jdk: 1.5.0_15
Hudson-Build-Number: 1032
Hudson-Project: CD_6.1-Hotfixes_Nightly_build
Hudson-Version: 1.432
Jenkins-Build-Number: 1032
Jenkins-Project: CD_6.1-Hotfixes_Nightly_build
Jenkins-Version: 1.432
TCD-build-version: 6.1.0.1032
TCD-release-version: 6.1.0
```

What we want to do is open the archive, extract the manifest, and grab the TCD-build-version information.

Our script will make use of the Powershell community extensions, available from http://pscx.codeplex.com/, so you will need to download these and install them in your Powershell Modules directory according to the instructions on the site. (Note: The version number appended to the zip file needs to be removed, so that the directory is simply called "Pscx")

The community extensions offer various useful utilities: we are interested in the tools for working with archive files, specifically "expand-archive".

In the following Powershell snippet (to be placed in your $profile), you can see that we first import the extensions, and then define a function that will accept the location of the jar file and extract the build version number.

```
import-module Pscx

function get-tcdBuildVersion($jar){
    $tempDir = "c:\temp\tcdBuildVersionTemp"
   
    mkdir -force -Path $tempDir | out-null
    expand-archive -Path $jar -index 1 -OutputPath $tempDir -force
    $manifest = gc "$tempDir\META-INF\MANIFEST.MF"
    $buildVersion = $manifest | ? {$_ -like "TCD-build-version:*"}
    $buildVersion.split(':')[1]
    rm -r $tempDir
}
```

With this function available in your $profile, you can open a Powershell and navigate to the relevant lib directory and type a command similar to the following:

```
gci cd_*.jar | % {"$($_.Name)`t`t`t$(get-tcdBuildVersion $_)"}
```

giving results like this:

```
cd_ambient.jar                   6.1.0.1032
cd_broker.jar                    6.1.0.348
cd_cache.jar                     6.1.0.348
cd_core.jar                      6.1.0.1032
cd_datalayer.jar                         6.1.0.1032
cd_deployer.jar                  6.1.0.348
cd_dynamic.jar                   6.1.0.1032
cd_linking.jar                   6.1.0.348
cd_model.jar                     6.1.0.348
cd_monitor.jar                   6.1.0.348
cd_tcdl.jar                      6.1.0.348
cd_upload.jar                    6.1.0.348
cd_wai.jar                       6.1.0.348
cd_webservice.jar                        6.1.0.1032
```

This output can easily be compared with similar output obtained from your working system.

## Limitations ##
Using expand-archive in this way requires that we write the manifest first to disk and then read it in to a variable with get-content. Here we create a temporary directory in C:\temp, but anywhere you have the correct permissions would be suitable. There are potential techniques using .NET framework classes and working with streams, that would eliminate the need for file system access, but these techniques are comparatively complex and probably not worth it.