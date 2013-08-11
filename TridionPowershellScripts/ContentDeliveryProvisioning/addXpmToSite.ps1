param 
(
    [parameter(Mandatory=$false)]   
    [ValidateScript({Test-Path $_})]
    [string]$InetPub = "C:\inetpub",

    [parameter(Mandatory=$false)]   
    [ValidateScript({Test-Path $_})]
    [string]$InstallerHome = "C:\Users\Administrator\Downloads\Tridion",

    [parameter(Mandatory=$false)]
    [ValidateScript({Test-Path (split-path($_))})]
    [string]$TempLocation = "C:\Users\Administrator\ScriptTempLocation",

    [parameter(Mandatory=$false)]   
    [string]$MainWebSiteName = "www.visitorsweb.local",

    [parameter(Mandatory=$false)]   
    [string]$UploadWebSiteName = "upload.visitorsweb.local",

    [parameter(Mandatory=$false)]
    [string]$previewDbServerName = "WSL117\DEV2012",

    [parameter(Mandatory=$false)]
    [string]$previewDatabaseName = "Tridion_XPM",

    [parameter(Mandatory=$false)]
    [string]$previewDbUserName = "TridionBrokerUser",

    [parameter(Mandatory=$false)]
    [string]$previewDbPassword = "Tridion1"
				
)

if (-not (test-path $InstallerHome)) 
{
    throw "$InstallerHome not found"
}

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
. "$scriptPath\TridionConfigurationFunctions.ps1"

Add-Type -AssemblyName System.Xml.Linq
import-namespace System.Xml.Linq

$MainSiteDirPath = "$InetPub\$MainWebSiteName"
if (-not (test-path $MainSiteDirPath)) 
{
    throw "$MainSiteDirPath not found"
}

rm -r -force $TempLocation
md $TempLocation | out-null

add-type -Assembly System.IO.Compression.FileSystem
$previewWebAppZipPath = "$InstallerHome\Content Delivery\roles\preview\web\dotNet\webapp\x86_64.zip"
[System.IO.Compression.ZipFile]::ExtractToDirectory($previewWebAppZipPath, $TempLocation) 

$jars = 'asm.jar','cd_odata.jar','cd_odata_types.jar','cd_preview_ambient.jar'`
	,'cd_preview_web.jar','cd_session.jar','cd_wrapper.jar','hsqldb.jar'`
	,'jackson-core-asl.jar','jackson-jaxrs.jar','jackson-mapper-asl.jar'`
	,'jackson-xc.jar','jersey-core.jar','jersey-json.jar','jersey-server.jar'`
	,'jersey-servlet.jar','jettison.jar'

foreach($jar in $jars) {cp "$TempLocation\bin\lib\$jar" "$MainSiteDirPath\bin\lib"}

cp "$TempLocation\bin\Tridion.ContentDelivery.Preview.dll" "$MainSiteDirPath\bin"

# Next up = fix up the web config.
$configTemplate = [XDocument]::Load("$(split-path $MyInvocation.MyCommand.Path)\PreviewConf.xml")
$webConfig = [XDocument]::Load("$MainSiteDirPath\Web.config")
$webConfig.Save("$MainSiteDirPath\Web.config.beforeAddXpmToSite")

# Add configuration.system.web.httphandlers from preview.xml 
$httpHandlers = $configTemplate.Element("configuration").Element("system.web").Element("httpHandlers")
$webConfig.Element("configuration").Element("system.web").AddFirst($httpHandlers)

# Add codedom
$codedom = $configTemplate.Element("configuration").Element("system.codedom")
$webConfig.Element("configuration").Element("system.web").AddAfterSelf($codeDom)

$webServer = $configTemplate.Element("configuration").Element("system.webServer")
$webConfig.Element("configuration").Element("system.codedom").AddAfterSelf($webServer)

$runtime = $configTemplate.Element("configuration").Element("runtime")
$webConfig.Element("configuration").Element("system.webServer").AddAfterSelf($runtime)

$webConfig.Save("$MainSiteDirPath\Web.config")

# The "standard" logback.xml already has entries for preview

# Copy the deployer config
$uploadSiteDirPath = "$InetPub\$UploadWebSiteName"
cp "$uploadSiteDirPath\bin\config\cd_deployer_conf.xml" "$MainSiteDirPath\bin\config"

# ignore the smart-target things for now

# cd license already points to location in tridion folder

# configure storage 
# 	add Bundle storage binding for preview 
# 	add Session Wrapper and storage settings for xpm
# 	Use the same storage settings as the xpm service
$storageConfLocation = "$MainSiteDirPath\bin\config\cd_storage_conf.xml"
$storageConfig = [XDocument]::Load($storageConfLocation)
$storagesElement = $StorageConfig.Element("Configuration").Element("Global").Element("Storages")
# Add the wrappers first ... the next addfirst will put the bindings in the right place.
$wrappersElement = [XElement]::Parse("<Wrappers><Wrapper Name='SessionWrapper'/></Wrappers>")
$storagesElement.AddFirst($WrappersElement)

$storageBindings = [XElement]::Parse("<StorageBindings><Bundle src='preview_dao_bundle.xml' /></StorageBindings>")
$storagesElement.AddFirst($storageBindings)

# switch to XmlDocument to use existing function
$StorageConfig.Save($storageConfLocation)
$storageConfig = [xml](gc $storageConfLocation)
$previewStorageElement = CreateDatabaseStorageElement $storageConfig $previewDbServerName $previewDatabaseName $previewDbUserName $previewDbPassword
$sessionWrapper = $storageConfig.Configuration.Global.Storages.Wrappers.Wrapper | ? {$_.Name -eq "SessionWrapper"}
$sessionWrapper.AppendChild($previewStorageElement) | Out-Null
$storageConfig.Save($storageConfLocation)

#
#configure adf config. Just copy the sample from preview and use that instead of the default one we used for visitorsweb
cp "$InstallerHome\Content Delivery\roles\preview\web\configuration\samples\cd_ambient_conf_sample.xml" "$MainSiteDirPath\bin\config\cd_ambient_conf.xml"
# and add the cartridges.... except they are already in that sample.  
cp "$InstallerHome\Content Delivery\roles\preview\web\configuration\samples\cd_ambient_cartridge_conf_sample.xml" "$MainSiteDirPath\bin\config\cd_ambient_cartridge_conf.xml"

#cd_wai_conf is already as it should be
# cd_dynamic_conf is already as it should be
# cd_link_conf is already as it should be.
# TODO could copy jvm_sample, but it currently doesn't configure anything.  Check the docs

# enable the adf in the web conf ... NOP - the sample elements we added already include this.
# disable recycling of app pool (NOP - already done for visitorsweb?)





