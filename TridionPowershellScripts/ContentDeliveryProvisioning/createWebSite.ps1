# Script to create a Tridion-enabled web site

param(

# Script control parameters
[parameter(Mandatory=$false)]
[switch]$NoIISReset = $false, 

# Main web site params
[Parameter(Mandatory=$true, HelpMessage='The web site name for your main web site.')]
[string]$MainWebSiteName,

[Parameter(Mandatory=$false, HelpMessage='The application pool name for your main web site')]
[string]$MainWebSiteAppPoolName = $MainWebSiteName,

[Parameter(Mandatory=$false, HelpMessage='The host header for the main web site - defaults to web site name')]
[string]$MainWebSiteHostHeader = $MainWebSiteName,

# Upload web site params
[Parameter(Mandatory=$true, HelpMessage='The web site name for your upload web site')]
[string]$UploadWebSiteName,

[Parameter(Mandatory=$false, HelpMessage='The application pool name for your upload web site')]
[string]$UploadWebSiteAppPoolName = $UploadWebSiteName,

[Parameter(Mandatory=$false, HelpMessage='The host header for the upload web site - defaults to web site name')]
[string]$UploadWebSiteHostHeader = $UploadWebSiteName,

#File system locations
[Alias('InetPub')]
[Parameter(Mandatory=$true, HelpMessage='The directory where your web site directories belong.')]
[ValidateScript({Test-Path $_})]
[string]$WebSitesRootDirectory = 'C:\InetPub',

[Parameter(
	Mandatory=$true, 
	HelpMessage='The directory into which you have unzipped the Tridion distribution you are installing')]
[ValidateScript({Test-Path $_})]
[string]$InstallerHome = 'C:\Users\Administrator\Downloads\Tridion',

[ValidateScript({Test-Path $_})]
[Parameter(Mandatory=$true, HelpMessage='The path to the SQLJDBC jar file')]
[string]$SqlJdbcJarPath,

[ValidateScript({Test-Path $_})]
[Parameter(Mandatory=$true, HelpMessage='Path to the Tridion license file for content delivery')]
[string]$LicensePath,

[ValidateScript({Test-Path $_})]
[Parameter(Mandatory=$true, HelpMessage='Path to directory where all logs will go, in suitable sub-directories')]
[string]$LoggingDirectoryPath, 

[ValidateScript({Test-Path $_})]
[Parameter(Mandatory=$true, HelpMessage='Path to directory where incoming transport packages will arrive')]
[string]$DeployerIncomingDirectory,

#Database params
[Parameter(Mandatory=$true, HelpMessage='The database name of the main storage database, as used by MSSQL')]
[string]$MainStorageDatabaseServerName,

[Parameter(Mandatory=$true, HelpMessage='The name of the main storage database instance')]
[string]$MainStorageDatabaseName,

[Parameter(Mandatory=$true, HelpMessage='The Username used to access the main storage database')]
[string]$MainStorageDatabaseUsername,

[Parameter(Mandatory=$true, HelpMessage='The Password used to access the main storage database')]
[string]$MainStorageDatabasePassword,

[switch]$NoClobber = $false,
[switch]$StripConfigComments = $true
)

# import various stuff we need
Import-Module WebAdministration
Import-Module Reflection
add-type -Assembly System.IO.Compression.FileSystem
import-namespace System.IO.Compression
import-namespace System.Xml.Linq
#http://stackoverflow.com/questions/801967/how-can-i-find-the-source-path-of-an-executing-script
$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
. "$scriptPath\TridionConfigurationFunctions.ps1"

if (-not $NoIISReset) { iisreset -stop }

#Set up locations for Main and Upload site
$MainWebSiteIISPath = "IIS:\Sites\" + $MainWebSiteName
$MainWebSiteAppPoolPath = "IIS:\AppPools\" + $MainWebSiteAppPoolName  
$MainWebSiteDirectoryPath = "$WebSitesRootDirectory\$MainWebSiteName"
$UploadWebSiteIISPath = "IIS:\Sites\" + $UploadWebSiteName
$UploadWebSiteAppPoolPath = "IIS:\AppPools\" + $UploadWebSiteAppPoolName 
$UploadWebSiteDirectoryPath = "$WebSitesRootDirectory\$UploadWebSiteName"

$cleanUpPaths = $MainWebSiteIISPath,$MainWebSiteAppPoolPath,$MainWebSiteDirectoryPath,`
		 $UploadWebSiteIISPath,$UploadWebSiteAppPoolPath,$UploadWebSiteDirectoryPath

if ($NoClobber) {
	foreach ($path in $cleanUpPaths){
		if (test-path $Path) { throw "$path already exists and NoClobber set. Bailing"}
	}
}
foreach ($path in $cleanUpPaths){
	if (test-path $Path) {rm -r $path}
}

# New Main Web site
new-item $MainWebSiteDirectoryPath -ItemType Directory | Write-Debug
new-item "$MainWebSiteDirectoryPath\bin" -ItemType Directory | Write-Debug
new-item "$MainWebSiteDirectoryPath\bin\lib" -ItemType Directory | Write-Debug
new-item "$MainWebSiteDirectoryPath\bin\config" -ItemType Directory | Write-Debug

$ApiRolePath = "$InstallerHome\Content Delivery\roles\api"
copy "$ApiRolePath\dotNet\x86_64\*.dll" "$MainWebSiteDirectoryPath\bin"
copy "$ApiRolePath\java\lib\*.jar" "$MainWebSiteDirectoryPath\bin\lib"
copy "$ApiRolePath\java\third-party-lib\*.jar" "$MainWebSiteDirectoryPath\bin\lib"
copy $SqlJdbcJarPath "$MainWebSiteDirectoryPath\bin\lib"

#New Upload Site
new-item $UploadWebSiteDirectoryPath -ItemType Directory | Out-Null

$uploadWebApplicationZipPath = "$InstallerHome\Content Delivery\roles\upload\dotNET\webapp\x86_64\upload.zip"
[ZipFile]::ExtractToDirectory($uploadWebApplicationZipPath, $UploadWebSiteDirectoryPath)
copy $SqlJdbcJarPath  "$UploadWebSiteDirectoryPath\bin\lib"

if (-not (Test-Path $DeployerIncomingDirectory)) {
	ni -ItemType Directory $DeployerIncomingDirectory | Out-Null
	} 

# Deployer
$deployerConf = [XDocument]::Load("$InstallerHome\Content Delivery\resources\configurations\cd_deployer_conf_sample.xml")
$deployerConf.Element("Deployer").Element("Queue").Element("Location").Attribute("Path").Value `
									= $DeployerIncomingDirectory
$ReceiverElement = $deployerConf.Element("Deployer").Element("HTTPSReceiver")
$ReceiverElement.Attribute("Location") = $DeployerIncomingDirectory
$licenceElement = [XElement]::Parse("<License Location='$LicensePath'/>")
$ReceiverElement.AddAfterSelf($licenseElement)
$deployerConf.Save("$UploadWebSiteDirectoryPath\bin\config\cd_deployer_conf.xml")

# Link
$linkConfig = [XDocument]::Load("$InstallerHome\Content Delivery\resources\configurations\cd_link_conf_sample.xml")
$linkConfig.Element("Configuration").Add([XElement]::Parse("<License Location='$LicensePath'/>"))
$linkConfig.Save("$UploadWebSiteDirectoryPath\bin\config\cd_deployer_conf.xml")
$linkConfig.Save("$MainWebSiteDirectoryPath\bin\config\cd_deployer_conf.xml")

#Wai
$waiConfig = [XDocument]::Load("$InstallerHome\Content Delivery\resources\configurations\cd_wai_conf_sample.xml")
$waiConfig.Element("Configuration").Element("Presentations").Element("Presentation").Element("Host")[0].Attribute("Domain").Value = $MainWebSiteName
$waiConfig.Element("Configuration").Add([XElement]::Parse("<License Location='$LicensePath'/>"))
$waiConfig.Save("$MainWebSiteDirectoryPath\bin\config\cd_wai_conf.xml")

#Dynamic
copy "$InstallerHome\Content Delivery\resources\configurations\cd_dynamic_conf_sample.xml" "$MainWebSiteDirectoryPath\bin\config\cd_dynamic_conf.xml"

# Storage
$storageConfig = [XDocument]::Load("$InstallerHome\Content Delivery\resources\configurations\cd_storage_conf_sample.xml")
$storageConfig.Element("Configuration").Add([XElement]::Parse("<License Location='$LicensePath'/>"))
$dbStorageElement = CreateDatabaseStorageXElement $MainStorageDatabaseServerName $MainStorageDatabaseName $MainStorageDatabaseUsername $MainStorageDatabasePassword

$storageConfig.Element("Configuration").Element("Global").Element("Storages").Add($dbStorageElement)

$defaultFileStorage = $storageConfig.Element("Configuration").Element("Global").Element("Storages").Elements("Storage") | ? {$_.Attribute("Id").Value -eq "defaultFile"} 
$defaultFileStorage.Element("Root").Attribute("Path").Value = $MainWebSiteDirectoryPath 

$ItemTypesElement = $storageConfig.Element("Configuration").Element("ItemTypes")
$ItemTypesElement.SetAttributeValue("defaultStorageId","defaultDb")
$ItemTypesElement.SetAttributeValue("cached","true")

if ($StripConfigComments) {
	$comments = $storageConfig.DescendantNodes() | ? {$_.NodeType -eq 'Comment'} 
	$comments | % {$_.Remove()}
}

$storageConfig.Save("$MainWebSiteDirectoryPath\bin\config\cd_storage_conf.xml")
$storageConfig.Save("$UploadWebSiteDirectoryPath\bin\config\cd_storage_conf.xml")

# configure logback
$logbackConfig = [XDocument]::Load("$InstallerHome\Content Delivery\resources\configurations\logback.xml")
$logFolderProperty = $logbackConfig.Element("configuration").Elements("property") | ? {$_.Attribute("name").Value -eq "log.folder"}
$logFolderProperty.SetAttributeValue("value", "$LoggingDirectoryPath\$MainWebSiteName")
$logbackConfig.Save("$MainWebSiteDirectoryPath\bin\config\logback.xml")
$logFolderProperty.SetAttributeValue("value", "$LoggingDirectoryPath\$UploadWebSiteName")
$logbackConfig.Save("$UploadWebSiteDirectoryPath\bin\config\logback.xml")

# copy the schemas to the config directories
copy -r "$InstallerHome\Content Delivery\resources\schemas" "$MainWebSiteDirectoryPath\bin\config"
copy -r "$InstallerHome\Content Delivery\resources\schemas" "$UploadWebSiteDirectoryPath\bin\config"

# add file system rights to the web site directory for network service
$MainWebSiteDirectoryPathACL = Get-ACL $MainWebSiteDirectoryPath
$ace = GetDefaultACE "NT AUTHORITY\NETWORK SERVICE" "Read,Write,Modify"
$MainWebSiteDirectoryPathACl.AddAccessRule($ace)
Set-ACL $MainWebSiteDirectoryPath $MainWebSiteDirectoryPathACL

# create app pools for web site and upload site - set restart time to zero (separate function?)
$MainWebSiteAppPool = New-WebAppPool -Name $MainWebSiteAppPoolName
$MainWebSiteAppPool.recycling.periodicRestart.time = [TimeSpan]::Zero
$MainWebSiteAppPool.processModel.identityType = "NetworkService"
$MainWebSiteAppPool | set-item

New-WebSite -Name $MainWebSiteName -Port 80 -HostHeader $MainWebSiteHostHeader -PhysicalPath $MainWebSiteDirectoryPath -ApplicationPool $MainWebSiteApplicationPoolName | Out-Null

$UploadWebSiteAppPool = New-WebAppPool -Name $UploadWebSiteAppPoolName
$UploadWebSiteAppPool.recycling.periodicRestart.time = [TimeSpan]::Zero
$UploadWebSiteAppPool.processModel.identityType = "NetworkService"
$UploadWebSiteAppPool | set-item

New-WebSite -Name $UploadWebSiteName -Port 80 -HostHeader $UploadWebSiteHostHeader -PhysicalPath $UploadWebSiteDirectoryPath -ApplicationPool $UploadWebSiteApplicationPoolName | Out-Null

# copy in the web config
copy "$(split-path $MyInvocation.MyCommand.Path)\Web.config.base" "$MainWebSiteDirectoryPath\Web.config"

if (-not $NoIISReset) { iisreset -start }
