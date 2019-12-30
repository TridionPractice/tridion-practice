param(
    $discoveryURL="http://cd.local:8082/discovery.svc",
    $client_id='cduser',
    $client_secret='CDUserP@ssw0rd'
)

function Get-AuthorizationToken($discoveryUrl, $client_id, $client_secret){

    $tokenCapabilities = Invoke-RestMethod -uri "$discoveryUrl/TokenServiceCapabilities"
    $tokenURL = $tokenCapabilities.content.properties.URI

    $params = @{client_id=$client_id;client_secret=$client_secret;grant_type='client_credentials';resources='/'}
    $token = Invoke-RestMethod -Uri $tokenURL -Method POST -Body $params 

    $token.token_type + ' ' + $token.access_token
}

function Get-RootUri($uri) {
    ([URI]$uri).GetComponents([URIComponents]::SchemeAndServer, [URIFormat]::UriEscaped) + '/'

}

function Get-CapabilityServiceURI($CapabilityName, $discoveryURL, $AuthorizationToken) {

        $capabilityData = Invoke-RestMethod -Method Get -Uri ($discoveryURL + '/Environment/' + $capabilityName) -Headers @{Authorization=$AuthorizationToken}
        $capabilityData.entry.content.properties.URI
}

function Query-GraphQlService($graphQlQuery, $AuthorizationToken, $ContentServiceURI) {


    $jsonRequestBody = @{"query"=$graphQlQuery} |ConvertTo-Json
    $uri = (Get-RootUri $ContentServiceURI) + 'cd/api'

    $body = $jsonRequestBody
    $headers = @{
        Authorization=$AuthorizationToken
        Accept='application/json'
        'Content-Type'='application/json;Charset=UTF-8'
    }

    $data = Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body 
    $data.data | convertto-json -Depth 100

}

# Main
$AuthorizationToken = Get-AuthorizationToken $discoveryURL $client_id $client_secret
$ContentCapabilityName = 'ContentServiceCapability' 
$ContentServiceURI = Get-CapabilityServiceURI $ContentCapabilityName $discoveryURL $AuthorizationToken 


# My DXA publication is 5
$getDxaPages = @"
{
  items(filter: {
            itemTypes: [PAGE], 
            namespaceIds: [1],
            publicationIds: [5]
            }) {
    edges {
      node {
        id
        itemId
        itemType
        title
        ... on Page {
          url
          containerItems {
            ... on ComponentPresentation {
              rawContent {
                data
              }
            }
          }
        }
      }
    }
  }
}
"@

Query-GraphQlService $getDxaPages $AuthorizationToken $ContentServiceURI
