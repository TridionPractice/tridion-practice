import-module reflection
import-namespace System.Xml.Linq

function GetDefaultACE {
	param(
	[string]$account, 
	[System.Security.AccessControl.FileSystemRights]$rights
	)

# http://technet.microsoft.com/en-us/library/ff730951.aspx
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 
	$objType =[System.Security.AccessControl.AccessControlType]::Allow 
	$objUser = New-Object System.Security.Principal.NTAccount($account) 
	New-Object System.Security.AccessControl.FileSystemAccessRule($objUser, $rights, $InheritanceFlag, $PropagationFlag, $objType)    
}

function CreateDatabaseStorageElement {
    param(

	[parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
        [xml]$storageConf,

        [parameter(Mandatory=$True)]   
        [string]$ServerName , 

        [parameter(Mandatory=$True)]   
        [string]$DatabaseName,

        [parameter(Mandatory=$True)]   
        [string]$DatabaseUserName,

        [parameter(Mandatory=$True)]   
        [string]$DatabasePassword,
	
	[parameter(Mandatory=$false)]
	[string]$storageElementId="defaultDb"
    )

    $brokerStorageElement = $storageConf.CreateElement("Storage")
        $brokerStorageElement.SetAttribute("Type", "persistence")
        $brokerStorageElement.SetAttribute("Id", $storageElementId) 
        $brokerStorageElement.SetAttribute("dialect", "MSSQL")
        $brokerStorageElement.SetAttribute("Class", "com.tridion.storage.persistence.JPADAOFactory")
    $poolElement = $storageConf.CreateElement("Pool")
        $poolElement.SetAttribute("Type", "jdbc")
        $poolElement.SetAttribute("Size", "5")
        $poolElement.SetAttribute("MonitorInterval", "60")
        $poolElement.SetAttribute("IdleTimeout", "120")
        $poolElement.SetAttribute("CheckoutTimeout", "120")
        $brokerStorageElement.AppendChild($poolElement) | Out-Null
    $dataSourceElement = $storageConf.CreateElement("DataSource")
        $dataSourceElement.SetAttribute("Class", "com.microsoft.sqlserver.jdbc.SQLServerDataSource")
        $serverNamePropertyElement = $storageConf.CreateElement("Property")
        $serverNamePropertyElement.SetAttribute("Name","serverName")
        $serverNamePropertyElement.SetAttribute("Value",$ServerName)
        $dataSourceElement.AppendChild($serverNamePropertyElement) | Out-Null
    
        $databaseNamePropertyElement = $storageConf.CreateElement("Property")
        $databaseNamePropertyElement.SetAttribute("Name","databaseName")
        $databaseNamePropertyElement.SetAttribute("Value",$DatabaseName)
        $dataSourceElement.AppendChild($databaseNamePropertyElement) | Out-Null

        $userNamePropertyElement = $storageConf.CreateElement("Property")
        $userNamePropertyElement.SetAttribute("Name","user")
        $userNamePropertyElement.SetAttribute("Value",$DatabaseUserName)
        $dataSourceElement.AppendChild($userNamePropertyElement) | Out-Null

        $passwordPropertyElement = $storageConf.CreateElement("Property")
        $passwordPropertyElement.SetAttribute("Name","password")
        $passwordPropertyElement.SetAttribute("Value",$DatabasePassword)
        $dataSourceElement.AppendChild($passwordPropertyElement) | Out-Null
    
        $brokerStorageElement.AppendChild($dataSourceElement) | Out-Null
        $brokerStorageElement
}

function CreateDatabaseStorageXElement {
    param(
        [parameter(Mandatory=$True)]   
        [string]$ServerName , 

        [parameter(Mandatory=$True)]   
        [string]$DatabaseName,

        [parameter(Mandatory=$True)]   
        [string]$DatabaseUserName,

        [parameter(Mandatory=$True)]   
        [string]$DatabasePassword,
	
	[parameter(Mandatory=$false)]
	[string]$storageElementId="defaultDb"
    )

	$template = @"
	<Storage Type="persistence" Id="" dialect="MSSQL" Class="com.tridion.storage.persistence.JPADAOFactory">
		<Pool Type="jdbc" Size="5" MonitorInterval="60" IdleTimeout="120" CheckoutTimeout="120"/>
		<DataSource Class="com.microsoft.sqlserver.jdbc.SQLServerDataSource">
			<Property Name="serverName"/>
			<Property Name="databaseName" />
			<Property Name="user" />
			<Property Name="password" /> 
		</DataSource>
	</Storage>
"@
	$storageXElement = [XElement]::Parse($template)
	$storageXElement.SetAttributeValue("Id", $storageElementId)
	$storageXElement.Element("DataSource").Elements("Property") | ? {$_.Attribute("Name").Value -eq "serverName"} | % {$_.SetAttributeValue("Value", $ServerName)}
	$storageXElement.Element("DataSource").Elements("Property") | ? {$_.Attribute("Name").Value -eq "databaseName"} | % {$_.SetAttributeValue("Value", $DatabaseName)}
	$storageXElement.Element("DataSource").Elements("Property") | ? {$_.Attribute("Name").Value -eq "user"} | % {$_.SetAttributeValue("Value", $DatabaseUserName)}
	$storageXElement.Element("DataSource").Elements("Property") | ? {$_.Attribute("Name").Value -eq "password"} | % {$_.SetAttributeValue("Value", $DatabasePassword)}
    $storageXElement
}
