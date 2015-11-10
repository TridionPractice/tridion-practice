import-module Tridion-CoreService
Set-TridionCoreServiceSettings -Version 2013-SP1 -ConnectionType netTcp
$core = Get-TridionCoreServiceClient -Verbose
$ro = new-object Tridion.ContentManager.CoreService.Client.ReadOptions
$httpsProtocolSchema = new-Object Tridion.ContentManager.CoreService.Client.LinkToSchemaData
$httpsProtocolSchema.IdRef = "tcm:0-6-8" #pragmatism FTW! This doesn't change after you've installed Tridion...

# Here also a bit of pragmatism. Script-as-data, and a visible structure that matches what we're familiar with. Copy-paste-edit

$publicationTargetsSpecification = ConvertFrom-Json @"
[
    {
        "title": "visitorsweb", 
        "description": "visitorsweb", 
        "targetLanguage": "ASP.NET", 
        "defaultCodePage": 65001,
        "minimalApprovalStatus": null,
        "priority": "Normal", 
        "destinations": [
             {
                 "title": "upload.visitorsweb.local",
                 "protocol": "<HTTPS xmlns='http://www.tridion.com/ContentManager/5.0/Protocol/HTTPS'>
                                 <UserName>foo</UserName>
                                 <Password>bar</Password>
                                 <URL>http://upload.visitorsweb.local/HTTPUpload.aspx</URL>
                             </HTTPS>"
             }    
        ],
        targetTypes: [
			{"title": "Live"}
		],
		publications: [
			{"title": "04 Web"}
		]
    },
    {
        "title": "staging", 
        "description": "staging", 
        "targetLanguage": "ASP.NET", 
        "defaultCodePage": 65001,
        "minimalApprovalStatus": null,
        "priority": "Normal", 
        "destinations": [
             {
                 "title": "upload.staging.visitorsweb.local",
                 "protocol": "<HTTPS xmlns='http://www.tridion.com/ContentManager/5.0/Protocol/HTTPS'>
                                 <UserName>foo</UserName>
                                 <Password>bar</Password>
                                 <URL>http://upload.staging.visitorsweb.local/httpupload.aspx</URL>
                             </HTTPS>"
             }    
        ],
        targetTypes: [
			{"title": "Staging"}
		],
		publications: [
			{"title": "04 Web"}
		],
		siteEdit: 
			"<configuration xmlns='http://www.sdltridion.com/2011/SiteEdit'>
				<PublicationTarget xmlns='http://www.sdltridion.com/2011/SiteEdit'>
					<EnableSiteEdit>true</EnableSiteEdit>
					<ODataServiceURL>http://xpmpreview.visitorsweb.local/odata.svc</ODataServiceURL>
					<ODataAccessTokenURL />
					<ODataServiceUserName />
					<ODataServicePassword />
					<WebsiteURLs>
						<se:Value xmlns:se='http://www.sdltridion.com/2011/SiteEdit'>http://staging.visitorsweb.local</se:Value>
					</WebsiteURLs>
				</PublicationTarget>
			</configuration>"
    },
        {
        "title": "tri staging", 
        "description": "tri", 
        "targetLanguage": "REL", 
        "defaultCodePage": 65001,
        "minimalApprovalStatus": null,
        "priority": "Normal", 
        "destinations": [
             {
                 "title": "tri",
                 "protocol": "<HTTPS xmlns='http://www.tridion.com/ContentManager/5.0/Protocol/HTTPS'>
                                 <UserName>foo</UserName>
                                 <Password>bar</Password>
                                 <URL>http://upload.tri.local/httpupload.aspx</URL>
                             </HTTPS>"
             }    
        ],
        targetTypes: [
			{"title": "tri"}
		],
		publications: [
			{"title": "400 Example Site"}
		],
		siteEdit: 
			"<configuration xmlns='http://www.sdltridion.com/2011/SiteEdit'>
				<PublicationTarget xmlns='http://www.sdltridion.com/2011/SiteEdit'>
					<EnableSiteEdit>true</EnableSiteEdit>
					<ODataServiceURL>http://xpmpreview.visitorsweb.local/odata.svc</ODataServiceURL>
					<ODataAccessTokenURL />
					<ODataServiceUserName />
					<ODataServicePassword />
					<WebsiteURLs>
						<se:Value xmlns:se='http://www.sdltridion.com/2011/SiteEdit'>http://tri.local</se:Value>
						<se:Value xmlns:se='http://www.sdltridion.com/2011/SiteEdit'>http://www.tri.local</se:Value>
						<se:Value xmlns:se='http://www.sdltridion.com/2011/SiteEdit'>http://tridev.local</se:Value>
					</WebsiteURLs>
				</PublicationTarget>
			</configuration>"
    }
]
"@

$pubsFilter = new-object Tridion.ContentManager.CoreService.Client.PublicationsFilterData
$pubs = $core.GetSystemWideList($pubsFilter)

$ptfilter = new-object Tridion.ContentManager.CoreService.Client.PublicationTargetsFilterData
$existingPublicationtargets = $core.GetSystemWideList($ptfilter)


function RecreatePublishingConfiguration($publicationTargetsSpec){ 

    foreach( $publicationTargetSpec in $publicationTargetsSpec) {
     
        $title = $publicationTargetSpec.title
        $pubTargetId = getIdFromTitle $title $existingPublicationtargets
     
        if ($pubTargetId -ne $null){
            $core.DecommissionPublicationTarget($pubTargetId)
            $core.Delete($pubTargetId)
        }
	    # Watch out for your parameter passing styles....
        createPublicationTarget $publicationTargetSpec
    }
}

function createDestinations($destinationsSpec){

    foreach ($destinationSpec in $destinationsSpec) {
        $newDestination = new-object Tridion.ContentManager.CoreService.Client.TargetDestinationData
        $newDestination.Title = $destinationSpec.title
        $newDestination.ProtocolSchema = $httpsProtocolSchema
        $newDestination.ProtocolData = $destinationSpec.protocol
        $newDestination
    }
}

function createPublicationTarget($publicationTargetSpec){

    $newPubtarg = new-object Tridion.ContentManager.CoreService.Client.PublicationTargetData
    $newPubtarg.Title = $publicationTargetSpec.title
    $newPubtarg.Description = $publicationTargetSpec.description
    $newPubtarg.TargetLanguage = $publicationTargetSpec.targetLanguage
    $newPubtarg.DefaultCodePage = $publicationTargetSpec.defaultCodePage
    $newPubtarg.MinApprovalStatus = $publicationTargetSpec.minimalApprovalStatus
    $newPubtarg.Priority = $publicationTargetSpec.priority
    $newPubtarg.Destinations = createDestinations $publicationTargetSpec.destinations

    foreach ($targetTypeSpec in $publicationTargetSpec.targetTypes) {
	    $title = $targetTypeSpec.title
	    $targetType = GetTargetType $title
	    $linkTotargetType = new-object Tridion.ContentManager.CoreService.Client.LinkToTargetTypeData
	    $linkToTargetType.Idref = $targetType.Id
	    $newPubtarg.TargetTypes += $linkToTargetType
    }

    foreach ($publicationSpec in $publicationTargetSpec.publications){
	    $title = $publicationSpec.Title
	    $linkToPublication = new-object Tridion.ContentManager.CoreService.Client.LinktoPublicationData
	    $linkToPublication.Idref = getIdFromTitle $title $pubs
	    $newPubtarg.Publications += $linkToPublication
    }
    
    $savedPubtarg = $core.Create($newPubtarg, $ro)
    $siteEditData = $publicationTargetSpec.siteEdit

    if ($siteEditData -ne $null) {
        $ad = new-object Tridion.ContentManager.CoreService.Client.ApplicationData 
        $ad.ApplicationId = "SiteEdit" 
        $ad.TypeId = "XmlElement:configuration, http://www.sdltridion.com/2011/SiteEdit"
        $ad.Data = [System.Text.Encoding]::UTF8.GetBytes($siteEditData)
        $core.SaveApplicationData($savedPubtarg.Id, @($ad))
    }
}

function getIdFromTitle($title, $collection){
	foreach ($item in $collection) {
		if ($item.Title -eq $title){
            $item.Id
            break
        }
    }
}


function getTargetType($targetTypeTitle){
    
    $targetTypes = $core.GetSystemWideList((new-object Tridion.ContentManager.CoreService.Client.TargetTypesFilterData))
    $existingTT = @($targetTypes | ? {$_.Title -eq $targetTypeTitle})
    if  ($existingTT.Count -gt 0) {
		$existingTT[0]
        
    } else {

		$newTargetType = new-object Tridion.ContentManager.CoreService.Client.TargetTypeData
		$newTargetType.Title = $targetTypeName
		$newTargetType.Description = "$targetTypeName`: created by script"
		$core.Create($newTargetType,$ro)
    }
}

RecreatePublishingConfiguration $publicationTargetsSpecification
