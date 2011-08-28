  if ( -not $global:TridionIsSetUp ) { 
    "Setting up Tridion access for powershell" | out-host
    [appdomain]::CurrentDomain.SetData("APP_CONFIG_FILE", "C:\Program Files (x86)\Tridion\config\Tridion.ContentManager.config")
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.Common.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.Common.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.Publishing.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.Queuing.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.TemplateTypes.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.Templating.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.ContentManager.TypeRegistration.dll"
    add-type -path "C:\Program Files (x86)\Tridion\bin\client\Tridion.Logging.dll"    
  }
  $global:TridionIsSetUp = $true
