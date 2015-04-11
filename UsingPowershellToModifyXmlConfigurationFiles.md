
# Introduction #

This might not even be a Tridion-specific recipe, but it's definitely useful in a Tridion context. After all, most of the configuration files are XML, and there are even more of them than there used to be. This recipe shows how the XML support built-in to the Windows PowerShell makes it a really useful tool to make such tasks simpler.

# Details #
These examples are really just to demonstrate the principle. Often it's useful to have some functions available in your PowerShell $profile to generally help with managing your server. This first example would probably not be used so frequently - it might perhaps be useful in a script for automatically provisioning a hotfix.

We want to increment the GUI modification level, so the first thing we do is get-content on the configuration file. This pulls the contents of the file into a string, but by casting the result to [xml](xml.md) we automatically get it in a loaded XmlDocument instead.

The powershell wraps some of its own magic around the XmlDocument, so instead of needing to use XPath, we can just address the element/attribute hierarchy with dots, and it's namespace-agnostic too, which helps. To get the increment to work, you have to cast to an int and back to a string, but that's not too hard.

```
function IncrementGUIModification {
  $filename = 'C:\Program Files (x86)\Tridion\web\WebUI\WebRoot\Configuration\System.config'
  $conf = [xml](gc $filename)
  $modification = [int]$conf.Configuration.servicemodel.server.modification
  $modification++
  $conf.Configuration.servicemodel.server.modification = [string]$modification
  "Incremented Configuration.servicemodel.server.modification to $modification" 
  $conf.Save($filename)
}

```

In the second example, we're grabbing all the filters, and then piping the collection into the [where-object](http://technet.microsoft.com/en-us/library/hh849715.aspx) cmdlet (? for short) to select only JScriptMinifiers, and then piping the results into a [foreach](http://technet.microsoft.com/en-us/library/hh849731.aspx) to set the enabled value. (Obviously, this isn't going to be robust in scenarios where you have unexpected amounts of JScriptMinifiers that you wish to treat independently, but that's unlikely enough for a script like this.) As you can see, we finish off with an iisreset.

The two functions at the end are really aliases. Powershell does have support for aliases, but sometimes it's easier to write a function. This is one such situation.

Each of these functions is preceded by its name in double quotes. this is the easiest way to echo a string to the shell. I typically do this in $profile scripts so that when I start the shell, I get feedback on what functions are available to me by default in my session.

```

function SetGuiMinification($value){
  $filename = 'C:\Program Files (x86)\Tridion\web\WebUI\WebRoot\Configuration\System.config'
  $conf = [xml](gc $filename)
  $conf.Configuration.filters.filter |?{$_.type -like '*JScriptMinifier*'} |%{$_.enabled = $value}
  $conf.Save($filename)
  iisreset
}

"guimin"
function guimin {SetGuiMinification "always"}
"guinomin"
function guinomin {SetGuiMinification "never"}

```