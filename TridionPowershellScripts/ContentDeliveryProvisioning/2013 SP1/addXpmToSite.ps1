param 
(
    [parameter(Mandatory=$true)]   
    [ValidateScript({Test-Path $_})]
    [string]$InetPub,

    [parameter(Mandatory=$true)]   
    [ValidateScript({Test-Path $_})]
    [string]$InstallerHome,

    [parameter(Mandatory=$true)]
    [ValidateScript({Test-Path (split-path($_))})]
    [string]$TempLocation,

    [parameter(Mandatory=$true)]   
    [string]$MainWebSiteName,

    [parameter(Mandatory=$true)]   
    [string]$UploadWebSiteName,

    [parameter(Mandatory=$true)]
    [string]$previewDbServerName,

    [parameter(Mandatory=$true)]
    [string]$previewDatabaseName,

    [parameter(Mandatory=$true)]
    [string]$previewDbUserName,

    [parameter(Mandatory=$true)]
    [string]$previewDbPassword, 

    [parameter(Mandatory=$true)]
    [string]$webPublicationId
				
)

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

$previewStorageElement = CreateDatabaseStorageXElement -ServerName $previewDbServerName `
							-DatabaseName $previewDatabaseName `
							-DatabasePassword $previewDbPassword `
							-DatabaseUserName $previewDbUserName `
							-StorageElementId "sessionDb"

$wrappersElement.Element("Wrapper").AddFirst($previewStorageElement)							
$storageConfig.Save($storageConfLocation)

#
#configure adf config. Just copy the sample from preview and use that instead of the default one we used for visitorsweb
cp "$InstallerHome\Content Delivery\roles\preview\web\configuration\samples\cd_ambient_conf_sample.xml" "$MainSiteDirPath\bin\config\cd_ambient_conf.xml"
# and add the cartridges.... except they are already in that sample.  
cp "$InstallerHome\Content Delivery\roles\preview\web\configuration\samples\cd_ambient_cartridge_conf_sample.xml" "$MainSiteDirPath\bin\config\cd_ambient_cartridge_conf.xml"

#cd_wai_conf is already as it should be
# cd_dynamic_conf already has a mapping, which we should update
$dynamicConfLocation = "$MainSiteDirPath\bin\config\cd_dynamic_conf.xml"
$dynamicConfig = [XDocument]::Load($dynamicConfLocation)
$publicationElement = $dynamicConfig.Element("Configuration").Element("URLMappings").Element("StaticMappings").Element("Publications").Element("Publication")
$publicationElement.SetAttributeValue("Id", $webPublicationId)
$publicationElement.Elements("Host") | ? {$_.Attribute("Port").Value -eq "80"} | % {$_.SetAttributeValue("Domain", $MainWebSiteName)}
$publicationElement.Elements("Host") | ? {$_.Attribute("Port").Value -eq "8080"} | % {$_.Remove()}
$dynamicConfig.Save($dynamicConfLocation)

# cd_link_conf is already as it should be.
# TODO could copy jvm_sample, but it currently doesn't configure anything.  Check the docs

# enable the adf in the web conf ... NOP - the sample elements we added already include this.
# disable recycling of app pool (NOP - already done for visitorsweb?)





