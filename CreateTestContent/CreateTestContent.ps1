$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

$core = Get-TridionCoreServiceClient
Import-Module Tridion-CoreService

Import-Module Reflection
Import-Namespace Tridion.ContentManager.CoreService.Client

Add-Type -Path (Join-Path $scriptPath "Tridion.Practice.ChangeContentOrMetadata.dll")
Import-Namespace Tridion.Practice

# N.B. System schemas is the one local to the content pub. Then we don't have to localize urls
$systemSchemasFolderURL = "/webdav/02%20Content/Building%20Blocks/System/Schemas"
$perSchemaFolderURL = "/webdav/02%20Content/Building%20Blocks/Test/PerSchema"

$toxicChars = "[<>`"&'ŦĐŜ]"
$rtfTemplate = @'
<h1 xmlns='http://www.w3.org/1999/xhtml' id='{0}'>{0} Header One</h1>
Plain text 
<p xmlns='http://www.w3.org/1999/xhtml'>paragraph</p>
<br xmlns='http://www.w3.org/1999/xhtml'/>
<h2 xmlns='http://www.w3.org/1999/xhtml'>{0} Header Two</h2>
<h3 xmlns='http://www.w3.org/1999/xhtml'>{0} Header Three</h3>
<h4 xmlns='http://www.w3.org/1999/xhtml'>{0} Header Four</h4>
<h5 xmlns='http://www.w3.org/1999/xhtml'>{0} Header Five</h5>
<h6 xmlns='http://www.w3.org/1999/xhtml'>{0} Header Six</h6>
<section xmlns='http://www.w3.org/1999/xhtml'>
Here is a section
</section>
<script xmlns='http://www.w3.org/1999/xhtml' type="text/javascript">
  $(function($){{
    $("body").append("<p>Added by script</p>");
  }});
</script>
'@

$shouldResolveComponentsFolder = "/webdav/02%20Content/Building%20Blocks/Test/Linking/ShouldResolve"
$shouldResolveComponents = $core.GetList($shouldResolveComponentsFolder, (New-Object OrganizationalItemItemsFilterData))
$dateFieldValue = [DateTime]::Parse("28 September 1961")
$externalLinkValue = "https://www.google.nl/search?q=[<>`"&'ŦĐŜ]"

function Create-TestComponentForSchema ([string]$schemaID, [string]$perSchemafolderId, 
                                        [string]$componentTitle, [switch]$OnlyMandatory=$false){

    $schema = $core.Read($schemaID,$null)
    $schemaVersion = $schema.VersionInfo.Version
    $schemaTitle = $schema.Title

    $schemaFields = $core.ReadSchemaFields($schema.Id,$true,$null)
    if ($OnlyMandatory) {
        #TODO - if a top-level embedded field is optional, then we'll never process 
        # the field... so how do we test the fields within such a field?
        $schemaFields.Fields = $schemaFields.Fields | ? {$_.MinOccurs -gt 0}
        $schemaFields.MetadataFields = $schemaFields.MetadataFields | ? {$_.MinOccurs -gt 0}
    }

    $SchemaFolder = Get-SchemaFolder $perSchemafolderId $schemaTitle

    $component = $core.GetDefaultData(16,$schemaFolder.Id, (New-Object ReadOptions))
    $component.Title = $componentTitle + "_" + $schemaVersion

    # find out if comp already exists at this version. 
    $itemsFilter = New-Object OrganizationalItemItemsFilterData
    $itemsFilter.ItemTypes = @([ItemType]::Component)
    $matching = @($core.GetList($schemaFolder.Id, $itemsFilter)) 
    if (($matching | ? {$_.Title -eq $component.Title}).Count -gt 0) {
        $schemaFolder.Title + "\" + $component.Title + " already exists"
        return
    }

    $component.Schema = New-Object LinkToSchemaData
    $component.Schema.IdRef = $schema.Id

    $fields = [Fields]::ForContentOf($schemaFields)

    Process-Fields $fields

    $component.Content = $fields.ToString();
    "Creating " + $schemaFolder.Title + "\" + $component.Title 
    $savedComponent = $core.Create($component,(New-Object ReadOptions));

    $syncOptions = New-Object SynchronizeOptions
    $syncOptions.SynchronizeFlags = [SynchronizeFlags]::ApplyFilterXsltToXhtmlFields
    $syncResult = $core.SynchronizeWithSchemaAndUpdate($savedComponent.Id, $syncOptions)

}

function Get-SchemaFolder ($perSchemafolderId, $schemaTitle){
    $perSchemaFolder = $core.Read($perSchemafolderId,$null)    
    $schemaFolder = $core.GetList($perSchemafolderId, (New-Object OrganizationalItemItemsFilterData)) | ?{$_.Title -eq $schemaTitle}
    if ($schemaFolder -eq $null) {

        $folder = $core.GetDefaultData(2,$perSchemafolderId, (New-Object ReadOptions))
        $folder.Title = $schemaTitle
        $schemaFolder = $core.Create($folder,  (New-Object ReadOptions))
    }
    $SchemaFolder
}

function Get-ShouldResolveComponent($allowedSchemas, [switch]$IsMultimedia=$false){
    if ($IsMultimedia){
        $components = $shouldResolveComponents | ? {$_.BinaryContent -ne $null}
    }
    else {
        $components = $shouldResolveComponents | ? {$_.BinaryContent -eq $null}
    }
    
    if ($allowedSchemas.Count -lt 1) {
        $components[0]
    }
    else {
        foreach ($schema in $allowedSchemas){
            foreach($component in $components){
                if ($component.Title -eq $schema.Title){
                    return $component                     
                }
            }
        }
    }    
}

function Process-Fields([Collections.IEnumerable]$fields){

    foreach($field in @($fields))    
    {
        switch ($field.Type.Name) {
            SingleLineTextFieldDefinitionData {
                $fieldName = [string]$field.Name
                $field.Value = "$fieldName " + $toxicChars
                break;
            }
            XhtmlFieldDefinitionData {
                $fieldName = [string]$field.Name
                $field.Value = [string]::Format($rtfTemplate, $fieldName)
                break;
            }
            ComponentLinkFieldDefinitionData {
                $targetComponent = Get-ShouldResolveComponent $field.AllowedTargetSchemas
                $field.Value = $targetComponent.Id
                break;
            }
            DateFieldDefinitionData {
                $field.Value = $dateFieldValue.ToString("o")
                break;
            }
            EmbeddedSchemaFieldDefinitionData {
                #Calling GetSubFields first makes .SubFields work. TODO - figure out why
                $field.GetSubFields(0) | Out-Null
                $subfields = [Collections.IEnumerable]$field.SubFields
                foreach($subField in $subfields){
                    Process-Fields $subField                
                }
                break;
            }
            ExternalLinkFieldDefinitionData {
                $field.Value = $externalLinkValue 
                break;
            }
            KeywordFieldDefinitionData {
                $linkToCategory = $field.Category
                $firstKeyword = $core.GetList($linkToCategory.IdRef, (New-Object KeywordsFilterData))[0]
                $field.Value = $firstKeyword.Title
                break;
            }
            MultiLineTextFieldDefinitionData {
                $fieldName = [string]$field.Name
                $field.Value = "$fieldName"
                break;
            }
            MultimediaLinkFieldDefinitionData {                
                $targetComponent = Get-ShouldResolveComponent $field.AllowedTargetSchemas -IsMultimedia
                $field.Value = $targetComponent.Id
                break;
            }
            NumberFieldDefinitionData {
                $field.Value = 99.99
                break;
            }
        }        
    }
}


$schemasFilter = New-Object OrganizationalItemItemsFilterData
$schemasFilter.ItemTypes = @([ItemType]::Schema)
$schemasFilter.SchemaPurposes = @([SchemaPurpose]::Component)
$schemas = $core.GetList($systemSchemasFolderURL, $schemasFilter)
foreach($schema in $schemas){
    Create-TestComponentForSchema $schema.Id $perSchemaFolderURL "GeneratedTestData"
    Create-TestComponentForSchema $schema.Id $perSchemaFolderURL "MandatoryOnlyTestData" -OnlyMandatory
}


