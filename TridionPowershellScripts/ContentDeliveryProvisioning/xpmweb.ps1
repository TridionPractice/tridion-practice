# This script is to set up the XPM web service site. There is another script that injects the XPM settings into an existing web site.
param 
(
    [parameter(Mandatory=$false)]   
    [ValidateScript({Test-Path $_})]
    [string]$InstallerHome = "C:\Users\Administrator\Downloads\Tridion",
    
    [parameter(Mandatory=$false)]   
    [ValidateScript({Test-Path $_})]
    [string]$sqlJdbcJar = "C:\Users\Administrator\Downloads\sqljdbc4.jar",

    [parameter(Mandatory=$false)]   
    [string]$XpmPreviewWebSiteName = "xpmpreview.visitorsweb.local",

    [parameter(Mandatory=$false)]   
    [string]$XpmPreviewAppPoolName = "xpmpreview.visitorsweb.local", 

    [parameter(Mandatory=$false)]   
    [string]$UploadWebSiteName = "upload.visitorsweb.local",
    
    [parameter(Mandatory=$false)]
    [ValidateScript({Test-Path $_})]
    [string]$cdLicensePath = "C:\Program Files (x86)\Tridion\config\cd_licenses.xml",
        
    [parameter(Mandatory=$false)]
    [ValidateScript({Test-Path $_})]
    [string]$logDir = "C:\Tridion\log",
    
    [parameter(Mandatory=$false)]   
    [ValidateScript({Test-Path $_})]
    [string]$InetPub = "C:\inetpub",

    [parameter(Mandatory=$false)]
    [string]$brokerServerName = "WSL117\DEV2012",

    [parameter(Mandatory=$false)]
    [string]$brokerDatabaseName = "Tridion_broker",

    [parameter(Mandatory=$false)]
    [string]$brokerUserName = "TridionBrokerUser",

    [parameter(Mandatory=$false)]
    [string]$brokerPassword = "Tridion1",

    [parameter(Mandatory=$false)]
    [string]$previewDbServerName = "WSL117\DEV2012",

    [parameter(Mandatory=$false)]
    [string]$previewDatabaseName = "Tridion_XPM",

    [parameter(Mandatory=$false)]
    [string]$previewDbUserName = "TridionBrokerUser",

    [parameter(Mandatory=$false)]
    [string]$previewDbPassword = "Tridion1", 
    
    [parameter(Mandatory=$false)]   
    [string]$TargetWebSiteName = "staging.visitorsweb.local", 

    [parameter(Mandatory=$false)]
    [switch]$NoIISReset = $false

)

Import-Module WebAdministration
Import-Module ServerManager

$currentPath=Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

. "$currentPath\TridionConfigurationFunctions.ps1"

# Check pre-requisites. Just bail if not met. 
# (Installing them from the script is also possible but prolly too much grief)
if ( -not (get-windowsfeature NET-WCF-HTTP-Activation45).Installed) {
    Write-Host ".NET framework 4.5 WCF services HTTP activation is not installed"
    Exit
}

if (-not $NoIISReset){ iisreset /stop }

"Executing xpmweb script for $XpmPreviewWebSiteName"
# clean up... rm seems to work better than the webadmin cmdlets
$XpmPreviewWebSitePath = "IIS:\Sites\{0}" -f $XpmPreviewWebSiteName
if (test-path $XpmPreviewWebSitePath) 
{
    rm -r $XpmPreviewWebSitePath
}

$XpmPreviewAppPoolPath = "IIS:\AppPools\{0}" -f $XpmPreviewAppPoolName
if (test-path $XpmPreviewAppPoolPath) 
{
    rm -r $XpmPreviewAppPoolPath
}

$XpmPreviewSiteDirPath = "$InetPub\$XpmPreviewWebSiteName"
if (test-path $XpmPreviewSiteDirPath) 
{
    rm -r $XpmPreviewSiteDirPath 
}

# create directory and put jars and assemblies in there 
ni $XpmPreviewSiteDirPath -ItemType Directory | Out-Null

$PreviewRoleDir = "$InstallerHome\Content Delivery\roles\preview"

add-type -Assembly System.IO.Compression.FileSystem
$XpmPreviewAppZipPath = "$PreviewRoleDir\webservice\dotNET\webapp\x86_64.zip"
[System.IO.Compression.ZipFile]::ExtractToDirectory($XpmPreviewAppZipPath, $XpmPreviewSiteDirPath) 
cp $sqlJdbcJar "$XpmPreviewSiteDirPath\bin\lib"

Write-Debug "Creating $XpmPreviewSiteDirPath\bin\config"
ni "$XpmPreviewSiteDirPath\bin\config" -ItemType Directory | Out-Null


#Logback
$logbackConf = [xml](gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\logback.xml")
$logbackConf.configuration.property | ?{$_.name -eq "log.folder"} | % {$_.value="$logDir\xpmpreview"}
$logbackConf.Save("$XpmPreviewSiteDirPath\bin\config\logback.xml")

#Deployer
$uploadSiteDirPath = "$InetPub\$UploadWebSiteName"
if (-not (test-path $uploadSiteDirPath)) 
{
    throw "$uploadSiteDirPath not found"
}
cp "$uploadSiteDirPath\bin\config\cd_deployer_conf.xml" "$XpmPreviewSiteDirPath\bin\config"

# LINK config
$linkConf = [xml](gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_link_conf_sample.xml")
$licenseElement = $linkConf.CreateElement("License")
$licenseElement.SetAttribute("Location", $cdLicensePath)
$linkConf.Configuration.AppendChild($licenseElement) | Out-Null
$linkConf.Save("$XpmPreviewSiteDirPath\bin\config\cd_link_conf.xml")

# WAI config
$waiConf = [xml](gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_wai_conf_sample.xml")
#TODO - or is the domain the same as visitorsweb
$waiConf.Configuration.Presentations.Presentation.Host[0].Domain = $XpmPreviewWebSiteName
$licenseElement = $waiConf.CreateElement("License")
$licenseElement.SetAttribute("Location", $cdLicensePath)
$waiConf.Configuration.AppendChild($licenseElement) | Out-Null
$waiConf.Save("$XpmPreviewSiteDirPath\bin\config\cd_wai_conf.xml")

#DYNAMIC
cp "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_dynamic_conf_sample.xml" "$XpmPreviewSiteDirPath\bin\config\cd_dynamic_conf.xml"

#AMBIENT
#here we want to comment out the security node, because we're not going to implement security just yet.
# regex the text, because otherwise the nested comments get too nasty... Oh wait - now you have two problems
# Even this won't deal with the general case, so IRL we'll probably end up just starting with a file that already has the commenting.... was fun though...
$ambientConfText = (gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_ambient_conf_sample.xml")
$ambientConfText = [System.Text.RegularExpressions.Regex]::Replace($ambientConfText, '((<Security>.*?)<!--)', '<!--$2--><!--')
$ambientConfText = [System.Text.RegularExpressions.Regex]::Replace($ambientConfText, '-->(((?!-->).)*)</Security>', '-->$1<!--</Security>-->')
$ambientConf = [xml]$ambientConfText
$ambientConf.Save("$XpmPreviewSiteDirPath\bin\config\cd_ambient_conf.xml")

#AMBIENT CARTRIDGE
cp "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_ambient_cartridge_conf_sample.xml" "$XpmPreviewSiteDirPath\bin\config\cd_ambient_cartridge_conf.xml"

#WEBSERVICE
cp "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_webservice_conf_sample.xml" "$XpmPreviewSiteDirPath\bin\config\cd_webservice_conf.xml"

#STORAGE 
$storageConf = [xml](gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\cd_storage_conf_sample.xml")
$licenseElement = $storageConf.CreateElement("License")
$licenseElement.SetAttribute("Location", $cdLicensePath)
$storageConf.Configuration.AppendChild($licenseElement) | Out-Null

$previewStorageElement = CreateDatabaseStorageElement $storageConf $previewDbServerName $previewDatabaseName $previewDbUserName $previewDbPassword
$sessionWrapper = $storageConf.Configuration.Global.Storages.Wrappers.Wrapper | ? {$_.Name -eq "SessionWrapper"}
$sessionWrapper.AppendChild($previewStorageElement) | Out-Null

$databaseStorageElement = CreateDatabaseStorageElement $storageConf $brokerServerName $brokerDatabaseName $brokerUserName $brokerPassword
$storageConf.Configuration.Global.Storages.AppendChild($databaseStorageElement) | Out-Null

# We use the file system storage location of the target site. (i.e. the one which will display the XPM ui
$TargetSiteDirPath = "$InetPub\$TargetWebSiteName"

$defaultFileStorage = $storageConf.Configuration.Global.Storages.Storage | ? {$_.Id -eq "defaultFile"} 
$defaultFileStorage.Root.Path = $TargetSiteDirPath
$defaultDataFileStorage = $storageConf.Configuration.Global.Storages.Storage | ? {$_.Id -eq "defaultDataFile"} 
$defaultDataFileStorage.ParentNode.RemoveChild($defaultDataFileStorage) | Out-Null

$storageConf.Configuration.ItemTypes.defaultStorageId="defaultDb"
$storageConf.Configuration.ItemTypes.cached="true"

# Uncomment to remove all those goldurned comments
# $storageConf.SelectNodes("//comment()") | % {$_.ParentNode.RemoveChild($_)} | Out-Null

$storageConf.Save("$XpmPreviewSiteDirPath\bin\config\cd_storage_conf.xml")             

#Logback
$logbackConf = [xml](gc "$InstallerHome\Content Delivery\roles\preview\webservice\configuration\samples\logback.xml")
$logbackConf.configuration.property | ?{$_.name -eq "log.folder"} | % {$_.value="$logDir\xpmweb"}
$logbackConf.Save("$XpmPreviewSiteDirPath\bin\config\logback.xml")

# schemas
cp -r "$InstallerHome\Content Delivery\resources\schemas" "$XpmPreviewSiteDirPath\bin\config"

$colRights = [System.Security.AccessControl.FileSystemRights]"Read,Write,Modify" 
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 
$objType =[System.Security.AccessControl.AccessControlType]::Allow 

$objUser = New-Object System.Security.Principal.NTAccount("NT AUTHORITY\NETWORK SERVICE") 

$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule `
    ($objUser, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

$objACL = Get-ACL $XpmPreviewSiteDirPath
$objACL.AddAccessRule($objACE) 

Set-ACL $XpmPreviewSiteDirPath $objACL

$XpmPreviewAppPool = New-WebAppPool -Name $XpmPreviewAppPoolName
$XpmPreviewAppPool.recycling.periodicRestart.time = [TimeSpan]::Zero 
$XpmPreviewAppPool.processModel.identityType = "NetworkService"
$XpmPreviewAppPool | set-item
Write-Debug "Creating web site $XpmPreviewWebSiteName"
New-WebSite -Name $XpmPreviewWebSiteName -Port 80 -HostHeader $XpmPreviewWebSiteName -PhysicalPath $XpmPreviewSiteDirPath -ApplicationPool $XpmPreviewAppPoolName | Out-Null

# OK - so created like that, we'll get an Integrated Mode App pool so...

$webConfig = [xml](gc "$XpmPreviewSiteDirPath\Web.config")
$adModule = $webConfig.configuration.'system.webServer'.modules.add | ? {$_.name -eq "Tridion.ContentDelivery.AmbientData.HttpModule"}
$adModule.SetAttribute("preCondition", "managedHandler")
$webConfig.Save("$XpmPreviewSiteDirPath\Web.config")

if (-not $NoIISReset){ iisreset /start }

