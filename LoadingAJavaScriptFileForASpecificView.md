
# Introduction #

Although it is in general better to use Tridion's UI framework itself to build extensions, the wish/need to load a JavaScript file and have its code applied to a specific view is still quite common.

# Details #

To load a JavaScript file in every view in Tridion, you can use the following configuration for an extension:

```
<?xml version="1.0"?>
<Configuration xmlns="http://www.sdltridion.com/2009/GUI/Configuration/Merge" 
    xmlns:cfg="http://www.sdltridion.com/2009/GUI/Configuration"
    xmlns:ext="http://www.sdltridion.com/2009/GUI/extensions"
    xmlns:cmenu="http://www.sdltridion.com/2009/GUI/extensions/ContextMenu">
  <resources cache="true">
    <cfg:filters/>
    <cfg:groups>
      <cfg:group name="MyFileGroup">
        <cfg:domainmodel name="MyModel">
          <cfg:fileset>
            <cfg:file type="script" id="myfile">myjavascriptfile.js</cfg:file>
          </cfg:fileset>
          <cfg:services/>
        </cfg:domainmodel>
      </cfg:group>
    </cfg:groups>
  </resources>
  <definitionfiles/>
  <extensions>
    <ext:editorextensions/>
    <ext:dataextenders/>
  </extensions>
  <commands/>
  <contextmenus/>
  <localization/>
  <settings>
    <defaultpage />
    <navigatorurl />
    <editurls/>
    <listdefinitions/>
    <itemicons/>
    <theme>
      <path/>
    </theme>
    <customconfiguration/>
  </settings>
</Configuration>
```

This will load `myjavascriptfile.js` into every view of the extension.