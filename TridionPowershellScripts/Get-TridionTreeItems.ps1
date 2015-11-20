import-module Tridion-CoreService

function Get-TridionTreeItems{
    Param(
            [parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Tridion.ContentManager.CoreService.Client.SessionAwareCoreServiceClient]$core, 
            [Tridion.ContentManager.CoreService.Client.IdentifiableObjectData]$parent=$null
         )
    $ro = new-object Tridion.ContentManager.CoreService.Client.ReadOptions
    if ($parent -eq $null){
        [Tridion.ContentManager.CoreService.Client.PublicationData[]]$items =  `
        @($core.GetSystemWideList((new-object Tridion.ContentManager.CoreService.Client.PublicationsFilterData)))        
        foreach ($item in $items) {
            $fullItem = $core.Read($item.Id, $ro)           
            Add-Member -InputObject $fullItem -Name "Level" -Value 1 -MemberType NoteProperty
            Write-Output $fullItem
            Get-TridionTreeItems $core $fullItem 
        }
    }
    else {
        if ($parent -is [Tridion.ContentManager.CoreService.Client.OrganizationalItemData]){
            $items = $core.GetList($parent.Id, (new-object Tridion.ContentManager.CoreService.Client.OrganizationalItemItemsFilterData))
        } else {
            $items = $core.GetList($parent.Id, (new-object Tridion.ContentManager.CoreService.Client.RepositoryItemsFilterData))
        }

        foreach($item in $items) {
            $fullItem = $core.Read($item.Id, $ro)
            Add-Member -InputObject $fullItem -Name "Level" -value (([int]$parent.Level) + 1) -MemberType NoteProperty
            Write-Output $fullItem
            if ($fullItem -is [Tridion.ContentManager.CoreService.Client.PublicationData]) {
                Get-TridionTreeItems $core $fullItem 
            } elseif ($item -is [Tridion.ContentManager.CoreService.Client.OrganizationalItemData]) {
                Get-TridionTreeItems $core $fullItem 
            }
        }
    }
}
set-alias gtt Get-TridionTreeItems
