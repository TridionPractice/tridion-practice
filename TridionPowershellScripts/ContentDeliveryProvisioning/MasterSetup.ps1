param(
[Parameter(Mandatory=$false, HelpMessage='Prefix to let you test the scripts in a different directory etc.')]
[string]$testPrefix
)

# Confirm destructive operation. Alternatively you could pass -NoClobber to createWebSite.ps1
$caption = "Confirm"
$message = "This script will delete your websites. Do you want to go ahead?"
$yes = new-object System.Management.Automation.Host.ChoiceDescription "&Yes", "help"
$no = new-object System.Management.Automation.Host.ChoiceDescription "&No", "help"
$choices = $yes,$no
$answer = $host.ui.PromptForChoice($caption,$message,$choices,0)
if ($answer -ne 0){
	"Bailing out. Thank you for your kind consideration."
    exit
}

$currentPath=Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path

$InetPub = "C:\inetpub"
$InstallerHome = "C:\Users\Administrator\Downloads\Tridion"
$TempLocation = "C:\Users\Administrator\ScriptTempLocation"
$stagingVisitorsSiteName = $testPrefix + "staging.visitorsweb.local"
$stagingUploadSiteName = $testPrefix + "upload.staging.visitorsweb.local"
$stagingIncomingDir = "C:\Tridion\incoming\stagingvisitorsweb"
$liveVisitorsWebSiteName = $testPrefix + "www.visitorsweb.local"
$liveUploadWebSiteName = $testPrefix + "upload.visitorsweb.local"
$liveIncomingDir = "c:\Tridion\Incoming\visitorsweb"
$previewDbServerName = "DATABASE_SERVER"
$brokerServerName = "DATABASE_SERVER"
$previewDatabaseName = "Tridion_XPM"
$previewDbUserName = "TridionBrokerUser"
$previewDbPassword = "Tridion1"
$SqlJdbcJar = "C:\Users\Administrator\Downloads\sqljdbc4.jar"
$cdLicensePath = "C:\Program Files (x86)\Tridion\config\cd_licenses.xml"
$LogDir = "C:\Tridion\Log"

iisreset /stop

# main visitors web site
& "$currentPath\createWebSite.ps1" 	-InstallerHome $InstallerHome `
					-SqlJdbcJarPath $SqlJdbcJar `
					-InetPub $InetPub `
					-UploadWebSiteName $liveUploadWebSitename `
					-MainWebSiteName $liveVisitorsWebSiteName `
					-MainWebSiteAppPoolName $liveVisitorsWebSiteName `
					-LicensePath $cdLicensePath `
					-LoggingDirectoryPath $LogDir `
					-DeployerIncomingDirectory "c:\Tridion\Incoming\visitorsweb" `
					-MainStorageDatabaseServerName $brokerServerName `
					-MainStorageDatabaseName "Tridion_Broker" `
					-MainStorageDatabaseUsername "TridionBrokerUser" `
					-MainStorageDatabasePassword "Tridion1" `
					-NoIISReset

# staging site
& "$currentPath\createWebSite.ps1" 	-InstallerHome $InstallerHome `
					                -SqlJdbcJarPath $SqlJdbcJar `
					                -InetPub $InetPub `
							-UploadWebSiteName $stagingUploadSiteName `
					                -MainWebSiteName $stagingVisitorsSiteName `
							-MainWebSiteAppPoolName $stagingVisitorsSiteName `
                					-LicensePath $cdLicensePath `
                					-LoggingDirectoryPath $LogDir `
							-DeployerIncomingDirectory $stagingIncomingDir `
                					-MainStorageDatabaseServerName $brokerServerName `
							-MainStorageDatabaseName "Tridion_staging_broker" `
                					-MainStorageDatabaseUsername "TridionBrokerUser" `
                					-MainStorageDatabasePassword "Tridion1" `
							-NoIISReset

# we want the xpm service to use the staging settings
& "$currentPath\xpmweb.ps1" 		-InstallerHome $InstallerHome `
					-sqlJdbcJarPath $SqlJdbcJar `
					-XpmPreviewWebSiteName "xpmpreview.visitorsweb.local" `
					-XpmPreviewAppPoolName "xpmpreview.visitorsweb.local" `
					-TargetWebSiteName "staging.visitorsweb.local" `
                            		-UploadWebSiteName "upload.staging.visitorsweb.local" `
                			-LicensePath $cdLicensePath `
                			-LoggingDirectoryPath $LogDir `
					-InetPub $InetPub `
					-MainStorageDatabaseServerName $brokerServerName `
                            		-MainStorageDatabaseName "Tridion_staging_broker" `
					-MainStorageDatabaseUsername "TridionBrokerUser" `
					-MainStorageDatabasePassword "Tridion1" `
					-PreviewDbServerName $previewDbServerName `
					-PreviewDatabaseName $previewDatabaseName `
					-PreviewDbUserName $previewDbUserName `
					-PreviewDbPassword $previewDbPassword `
                            		-NoIISReset

# fixups to make the staging site support xpm
& "$currentPath\addXpmToSite.ps1" 	-InetPub $InetPub `
				  	-InstallerHome $InstallerHome `
					-TempLocation $TempLocation `
					-MainWebSiteName $stagingVisitorsSiteName `
					-UploadWebSiteName $stagingUploadSiteName `
					-previewDbServerName $previewDbServerName `
					-previewDatabaseName $previewDatabaseName `
					-PreviewDbUserName $previewDbUserName `
					-PreviewDbPassword $previewDbPassword `
					-webPublicationId "5"

iisreset /start


