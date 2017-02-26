import-module Tridion-CoreService
 
 
function Get-TridionTreeItems{
    Param(
            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Tridion.ContentManager.CoreService.Client.SessionAwareCoreServiceClient]$core,
            [Tridion.ContentManager.CoreService.Client.IdentifiableObjectData]$parent=$null
         )
    $ro = new-object Tridion.ContentManager.CoreService.Client.ReadOptions
    try {
        if ($parent -eq $null){
            [Tridion.ContentManager.CoreService.Client.PublicationData[]]$items =  `
            @($core.GetSystemWideList((new-object Tridion.ContentManager.CoreService.Client.PublicationsFilterData)))       
            foreach ($item in $items | ?{$_.Id} ) {
                $fullItem = $core.Read($item.Id, $ro)          
                Add-Member -InputObject $fullItem -Name "Level" -Value 1 -MemberType NoteProperty
                Write-Output $fullItem
                Get-TridionTreeItems $core $fullItem
            }
        }
        else {
            if ($parent -is [Tridion.ContentManager.CoreService.Client.OrganizationalItemData]){
                $itemsXml = [xml]$core.GetListXml($parent.Id, (new-object Tridion.ContentManager.CoreService.Client.OrganizationalItemItemsFilterData))           
                $items = $itemsXml.ListItems.Item
 
            } else {
                $itemsXml = [xml]$core.GetListXml($parent.Id, (new-object Tridion.ContentManager.CoreService.Client.RepositoryItemsFilterData))
                $items = $itemsXml.ListItems.Item
            }
 
            foreach($item in $items | ?{$_.Id}) {
                $fullItem = $core.Read($item.ID, $ro)
                Add-Member -InputObject $fullItem -Name "Level" -value (([int]$parent.Level) + 1) -MemberType NoteProperty
                Write-Output $fullItem
                if ($fullItem -is [Tridion.ContentManager.CoreService.Client.PublicationData]) {
                    Get-TridionTreeItems $core $fullItem
                } elseif ($fullItem -is [Tridion.ContentManager.CoreService.Client.OrganizationalItemData]) {
                    Get-TridionTreeItems $core $fullItem
                }
            }
        }
    } catch {
 
        $exception
 
    }
}
set-alias gtt Get-TridionTreeItems
 
