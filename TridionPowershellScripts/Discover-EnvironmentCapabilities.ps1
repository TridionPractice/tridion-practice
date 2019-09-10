param(
    $discoveryURL="http://cd.local:8082/discovery.svc",
    $client_id='cduser',
    $client_secret='CDUserP@ssw0rd'
)


# Ask the discovery service where to find token service: This looks like the only query you can make without an Authorization token
$tokenCapabilities = Invoke-RestMethod -uri "$discoveryUrl/TokenServiceCapabilities"
$tokenURL = $tokenCapabilities.content.properties.URI

#Get a token
$params = @{client_id=$client_id;client_secret=$client_secret;grant_type='client_credentials';resources='/'}
$token = Invoke-RestMethod -Uri $tokenURL -Method POST -Body $params 

# Now use the token to make more interesting queries
$Authorization = $token.token_type + ' ' + $token.access_token

$metadataQueryURI = $discoveryURL + '/$metadata'
$metadata = Invoke-RestMethod -Method Get -Uri $metadataQueryURI -Headers @{Authorization=$Authorization}

$platform = $metadata.Edmx.DataServices.Schema | ? {$_.Namespace -eq 'Tridion.WebDelivery.Platform'}

$ns = @{edm="http://docs.oasis-open.org/odata/ns/edm"}
$navigationProperties = Select-Xml -Xml $platform -Namespace $ns -XPath "edm:EntityType[@Name='Environment']/edm:NavigationProperty"

$capabilityNames = $navigationProperties | % {$_.Node.getAttribute("Name")} 

foreach ($capabilityName in $capabilityNames) {
    try {
        $capabilityData = Invoke-RestMethod -Method Get -Uri ($discoveryURL + '/Environment/' + $capabilityName) -Headers @{Authorization=$Authorization}
        new-Object PSObject -Property ([ordered]@{
            Capability = $capabilityName
            Found = $true
            'Service URI' = $capabilityData.entry.content.properties.URI
        })
    }
    catch {
        new-Object PSObject -Property ([ordered]@{
            Capability = $capabilityName
            Found = $false
            'Service URI' = ''
        })
    }

}
