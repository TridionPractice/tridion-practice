# Adding minimal WCF service #


## Introduction ##

The Tridion 2011 GUI can be extended by adding your own Editors and Models to it. It is fairly common for your Model to need to call some custom code on the Content Manager server. Below is the minimum code+configuration that is needed to make a WCF service available to your client-side extension.

## ExtensionsService.svc ##

```
<%@ ServiceHost Language="C#" Service="ExtensionModel.Services.ExtensionService" Debug="true" %>
```

## ExtensionService.svc.cs ##

```
using System.ServiceModel;
using System.ServiceModel.Activation;
using System.ServiceModel.Web;

namespace ExtensionModel.Services
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    [AspNetCompatibilityRequirements(RequirementsMode = AspNetCompatibilityRequirementsMode.Required)]
    [ServiceContract(Namespace= "ExtensionModel.Services")]
    public class ExtensionService
    {
        [OperationContract]
        [WebInvoke(Method = "POST",
                    RequestFormat = WebMessageFormat.Json,
                    ResponseFormat = WebMessageFormat.Json)]
        public bool IsEnabled(string itemId)
        {
            return true;
        }
    }
}
```

Compile this .svc and the .cs file into a DLL and put that DLL into your %TRIDION\_HOME%\Web\WebUI\Webroot\bin directory. Don't forget to update the DLL when you make changes to the code.

## ExtensionModel.config ##

```
<?xml version="1.0" encoding="utf-8" ?>
<Configuration xmlns="http://www.sdltridion.com/2009/GUI/Configuration/Merge"
               xmlns:cfg="http://www.sdltridion.com/2009/GUI/Configuration"
               xmlns:ext="http://www.sdltridion.com/2009/GUI/extensions"
               xmlns:cmenu="http://www.sdltridion.com/2009/GUI/extensions/ContextMenu">
  <resources cache="true">
    <cfg:filters/>
    <cfg:groups>
      <cfg:group name="Extension.Models">
        <cfg:domainmodel name="Extension.Models">
          <cfg:fileset>
          </cfg:fileset>
          <cfg:services>
            <cfg:service type="wcf">Services/ExtensionService.svc</cfg:service>
          </cfg:services>
        </cfg:domainmodel>
      </cfg:group>
    </cfg:groups>

  </resources>
  <definitionfiles/>
  <extensions>
    <ext:editorextensions />
    <ext:dataextenders />
    <ext:modelextensions />
  </extensions>
  <commands/>
  <contextmenus/>
  <localization/>
  <settings>
    <customconfiguration/>
  </settings>
</Configuration>
```

## Web.config ##

This web.config goes into the root of your Model directory.

```
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <system.web>
    <compilation debug="true" targetFramework="4.0" />
  </system.web>
  <system.serviceModel>
      <services>
        <service name="ExtensionModel.Services.ExtensionService" 
                 behaviorConfiguration="Tridion.Web.UI.ContentManager.WebServices.DeveloperBehavior">
          <endpoint name="ExtensionService" address="" 
                    behaviorConfiguration="Tridion.Web.UI.ContentManager.WebServices.AspNetAjaxBehavior" 
                    binding="webHttpBinding" 
                    bindingConfiguration="Tridion.Web.UI.ContentManager.WebServices.WebHttpBindingConfig" 
                    contract="ExtensionModel.Services.ExtensionService"/>
        </service>
      </services>
    </system.serviceModel>
</configuration>
```

# System.config fragment #

```
    <model name="Extension">
      <installpath>C:\Projects\MyExtensions\ExtensionModel</installpath>
      <configuration>Configuration\ExtensionModel.config</configuration>
      <vdir>Extension</vdir>
    </model>
```

## Calling it from your JavaScript = ##

```
ExtensionModel.Services.ExtensionsService.IsEnabled("tcm:0-1-2")
```