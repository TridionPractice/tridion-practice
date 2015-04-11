# Tridion UI 2012 functions for use in HTML templates #


## Introduction ##

Like previous SiteEdit releases before it, the new Tridion UI 2012 comes with a set of Template Building Blocks that help in outputting the necessary markup for making the content editable on your preview/staging site. Unfortunately these TBBs insist on outputting a new tag around every Component Presentation and Component Field. In many cases these new tags don't cause problems and allow the new UI to do its magic. But in some cases the generated tags introduce problems with the existing layout. In such cases the function source on this page helps to retain full control over the layout.

## Details ##

Below is the code for a custom [FunctionSource](http://sdllivecontent.sdl.com/LiveContent/content/en-US/SDL_Tridion_2011_SPONE/task_EFD94BC0585D4186A13F7F3C3B6F47EA) that implements three helper functions for use in your (DWT) HTML layout:
  * MarkPage - Marks the current page and tells the bootstrap JavaScript where the Tridion Content Manager server is
  * MarkComponentPresentation - Marks either the current Component Presentation or an explicitly named Component Presentation
  * MarkComponentField - Marks a specific field of the current Component
  * MarkRegion - Marks a region of the page for a single Content Type

These functions will only output the minimum information needed by Tridion UI 2012. They will not output any tags that influence the layout in any way, nor do they output such tags to help separate the editable content from its surroundings.

## Usage example ##

Basic example in a Component layout DWT:
```
<div class="ContentArea">
    <div class="ContentFull">
        @@MarkComponentPresentation()@@
        <h1>@@MarkComponentField('Title')@@@@Component.Fields.Title@@</h1>
        <div>@@MarkComponentField('Image')@@<img src="@@Image.ID@@"/></div>
        <div class="FullDescription">
            <div class="FullDescriptionText">@@MarkComponentField('Description')@@@@Component.Fields.Description@@</div>
        </div>
        <div>
            <div>
                <h1>$<span>@@MarkComponentField('Price')@@@@Price@@</span></h1>
            </div>
            <!-- TemplateBeginIf cond="Component.Fields.ReleaseDate != ''" -->
            <div><h4>Release Date: <span>@@MarkComponentField('ReleaseDate')@@@@ReleaseDate@@</span></h4></div>
            <!-- TemplateEndIf -->
            <div class="Availability">
                <div><h4>
                    <span>@@MarkComponentField('Availability')@@@@Availability@@</span> for 
                    <!-- TemplateBeginRepeat name="Component.Fields.Console" -->
                        <!-- TemplateBeginIf cond="TemplateRepeatIndex > 0" -->, <!-- TemplateEndIf -->
                        <span>@@MarkComponentField('Console', TemplateRepeatIndex)@@@@Field@@</span>
                    <!-- TemplateEndRepeat -->
                </h4></div>
            </div>
        </div>
        <div class="RelatedItems">
            @@MarkRegion('RelatedItems',2,4,'tcm:1-41-8','tcm:1-43-32')@@
            <!-- TemplateBeginIf cond="RelatedItems" -->
                Related Items:
                <!-- TemplateBeginRepeat name="RelatedItems" -->
                    <!-- TemplateBeginIf cond="TemplateRepeatIndex > 0" -->
                        <span> , </span>
                    <!-- TemplateEndIf -->
                    <a tridion:href="@@Component.ID@@" class="RelatedItemsLink">@@Component.Fields.Title@@</a>
                <!-- TemplateEndRepeat -->
            <!-- TemplateEndIf -->
        </div>
    </div>
</div>
```

As you can see there are a lot of repeats of this constructs
```
@@MarkComponentField('Title')@@@@Component.Fields.Title@@
```

So we first output a field marking and then the value of that field. The result of this sequence is:

```
<!-- Start Component Field: {'XPath' : 'tcm:Content/custom:Content/custom:Title[1]'} -->The Elder Scrolls V - Skyrim
```

So no additional (DOM-influencing) markup is generated.



### Marking the Page layout DWT ###
```
    <div class="Footer">Copyright © 1999-2012 ...</div>
    @@MarkPage("http://tridion2011sp1")@@
</body>
</html>
```

### Marking up fields of a linked Component ###
```
    <div>
    @@MarkComponentPresentation(Component.Fields.ItemLink,'tcm:1-40-32')@@
        <h2>
            <a tridion:href="@@Component.Fields.ItemLink@@" class="FeaturedItemTitleLink" >
                @@MarkComponentField('Title')@@@@ItemLink.Fields.Title@@
            </a>
        </h2>
        <div>
            @@MarkComponentField('Availability')@@
            @@Availability@@
        </div>
    </div>
```


### Marking up a region ###
It is possible to mark regions of your page, so that only Components of a certain schema can be dropped in there and the correct Template will automatically be applied to them.

To set up a region named "RelatedItems" with between 2 and 4 Components of schema "tcm:1-41-8" that a rendered with Template "tcm:1-43-32" put the following in your Page DWT:
```
    <div>
        @@MarkRegion('RelatedItems',2,4,'tcm:1-41-8','tcm:1-43-32')@@
        <!-- TemplateBeginRepeat name="RelatedItems" -->
            @@RenderComponentPresentation()@@
        <!-- TemplateEndRepeat -->
    </div>
```

Alternatively you can set up a matching ContentType on the relevant Publication. If there is a ContentType with the exact same name as the region, the function will read the Schema and Component Template from there.
```
    <div>
        @@MarkRegion('RelatedItems',2,4)@@
        <!-- TemplateBeginRepeat name="RelatedItems" -->
            @@RenderComponentPresentation()@@
        <!-- TemplateEndRepeat -->
    </div>
```


## Configuration ##

To start using these functions you need to compile the code below into a .NET 3.5 assembly, sign that assembly with your own strong named key and deploy the assembly to the GAC (e.g. copy/paste it into C:\Windows\Assembly). Then add this fragment to your %TRIDION\_HOME%\config\Tridion.ContentManager.config

```
      <functionSource type="SiteEdit2012FunctionSource.SiteEdit2012FunctionSource"
         assembly="SiteEdit2012FunctionSource, Version=1.0.0.1, Culture=neutral, PublicKeyToken=3b7addfb0e727d79" />
```

Make sure the version number and PublicKeyToken match with the ones you specify in your Visual Studio project.

# Code #

```
using System;
using Tridion.ContentManager;
using Tridion.ContentManager.CommunicationManagement;
using Tridion.ContentManager.Templating;
using Tridion.ContentManager.Templating.Expression;

namespace SiteEdit2012FunctionSource
{
    public class SiteEdit2012FunctionSource : IFunctionSource
    {
        private Engine _engine;
        private Package _package;

        public void Initialize(Engine engine, Package package)
        {
            _engine = engine;
            _package = package;
        }

        [TemplateCallable]
        public string MarkPage(string serverUrlBase)
        {
            IdentifiableObject page = _engine.PublishingContext.ResolvedItem.Item;
            IdentifiableObject template = _engine.PublishingContext.ResolvedItem.Template;

            var pageSettings = string.Format("<!-- Page Settings: {{'PageID':'{0}','PageModified':'{1}','PageTemplateID':'{2}','PageTemplateModified':'{3}'}} -->", page.Id, FormatDate(page.RevisionDate), template.Id, FormatDate(template.RevisionDate));
            var scriptTag = string.Format("<script type='text/javascript' language='javascript' defer='defer' src='{0}/WebUI/Editors/SiteEdit/Views/Bootstrap/Bootstrap.aspx?mode=js' id='tridion.siteedit'></script>", serverUrlBase);

            return pageSettings + Environment.NewLine + scriptTag;
        }


        [TemplateCallable]
        public string MarkComponentPresentation()
        {
            IdentifiableObject component = _engine.PublishingContext.ResolvedItem.Item;
            IdentifiableObject template = _engine.PublishingContext.ResolvedItem.Template;
            return string.Format(
                "<!-- Start Component Presentation: {{ 'ComponentID' : '{0}', 'ComponentModified' : '{1}', 'ComponentTemplateID' : '{2}', 'ComponentTemplateModified' : '{3}' }} -->",
                component.Id, FormatDate(component.RevisionDate), template.Id, FormatDate(template.RevisionDate));
        }

        [TemplateCallable]
        public string MarkComponentPresentation(string componentId, string templateId)
        {
            return MarkComponentPresentation(componentId, templateId, true);
        }

        [TemplateCallable]
        public string MarkComponentPresentation(string componentId, string templateId, Boolean isQueryBased)
        {
            IdentifiableObject component = _engine.GetObject(componentId);
            ComponentTemplate template = (ComponentTemplate) _engine.GetObject(templateId);
            var dynamicProperty = template.IsRepositoryPublishable ? ", 'IsRepositoryPublished': true": "";
            var queryBasedProperty = isQueryBased ? ", 'IsQueryBased': true" : "";
            return string.Format(
                "<!-- Start Component Presentation: {{ 'ComponentID' : '{0}', 'ComponentModified' : '{1}', 'ComponentTemplateID' : '{2}', 'ComponentTemplateModified' : '{3}'{4}{5} }} -->",
                component.Id, FormatDate(component.RevisionDate), template.Id, FormatDate(template.RevisionDate), dynamicProperty, queryBasedProperty);
        }

        private static string FormatDate(DateTime date)
        {
            return date.ToString("u").Replace(' ', 'T').Replace("Z", "");
        }

        [TemplateCallable]
        public string MarkComponentField(string name)
        {
            return MarkComponentField(name, 0);

        }
        
        [TemplateCallable]
        public string MarkComponentField(string name, string indexAsString)
        {
            return MarkComponentField(name, int.Parse(indexAsString));
        }

        [TemplateCallable]
        public string MarkComponentField(string name, int index)
        {
            // <!-- Start Component Field: {"XPath" : "tcm:Content/custom:Content/custom:Title[1]"} -->
            return string.Format("<!-- Start Component Field: {{'XPath' : 'tcm:Content/custom:Content/custom:{0}[{1}]'}} -->", name, index + 1);
        }

        [TemplateCallable]
        public string MarkRegion(string title, int minOccurs, int maxOccurs, string schemaId, string templateId)
        {
            return string.Format("<!-- Start Region: {{ 'title': '{0}', 'allowedComponentTypes': [{{ 'schema': '{1}', 'template': '{2}' }}], 'minOccurs': {3}, 'maxOccurs': {4} }} -->", title, schemaId, templateId, minOccurs, maxOccurs);
        }

        [TemplateCallable]
        public string MarkRegion(string contentTypeAndTitle, int minOccurs, int maxOccurs)
        {
            // Note: that the content type must have the exact same name as the title of the region
            Page page = new Page(_package.GetByName("Page").GetAsXmlDocument().DocumentElement, _engine.GetSession());
            Publication pub = (Publication) page.ContextRepository;
            XmlElement appdata = pub.LoadApplicationData("SiteEdit").GetAs<XmlElement>();
            XmlNamespaceManager nsmgr = new XmlNamespaceManager(appdata.OwnerDocument.NameTable);
            nsmgr.AddNamespace("siteedit", "http://www.sdltridion.com/2011/SiteEdit");
            nsmgr.AddNamespace("xlink", "http://www.w3.org/1999/xlink");
            XmlElement contenttype = (XmlElement)appdata.SelectSingleNode("//siteedit:ContentType[@Title='"+contentTypeAndTitle+"']", nsmgr);
            if (contenttype != null)
            {
                var component = (Component)_engine.GetObject(contenttype.SelectSingleNode("siteedit:Component/@xlink:href", nsmgr).Value);
                var schemaId = component.Schema.Id;
                var templateId = contenttype.SelectSingleNode("siteedit:ComponentTemplate/@xlink:href", nsmgr).Value;
                return string.Format("<!-- Start Region: {{ 'title': '{0}', 'allowedComponentTypes': [{{ 'schema': '{1}', 'template': '{2}' }}], 'minOccurs': {3}, 'maxOccurs': {4} }} -->", contentTypeAndTitle, schemaId, templateId, minOccurs, maxOccurs);
            }
            else
            {
                throw new ArgumentException("No content type found matching this title", "contentTypeAndTitle");
            }

        }
    }
}
```

# MarkRegion Update #

To allow for multiple Schemas and Component Templates in the allowedComponentTypes, I've updated the MarkRegion function to accept a comma separated list of allowed Schema IDs and Template IDs.
You only need to use item id for each (it wil be set to the Publication ID of the published Page, and the number of items for both Schemas and Templates should be equal.

To set up a region named "RelatedItems" with between 2 and 4 Components of Schemas "tcm:1-41-8" and "tcm:1-42-8" that are rendered with Templates "tcm:1-43-32" and "tcm:1-44-32",
put the following in your Page DWT:
```
    <div>
        @@MarkRegion('RelatedItems',2,4,'41,42','43,44')@@
        <!-- TemplateBeginRepeat name="RelatedItems" -->
            @@RenderComponentPresentation()@@
        <!-- TemplateEndRepeat -->
    </div>
```

# Code #

```
[TemplateCallable]
public string MarkRegion(string title, int minOccurs, int maxOccurs, string schemaIds, string templateIds)
{
    // get current publication id
    IdentifiableObject page = _engine.PublishingContext.ResolvedItem.Item;
    int publicationId = page.Id.PublicationId;

    // get comma separated lists of schema and template ids (should be equal number)
    string[] schemas = schemaIds.Replace(" ", string.Empty).Split(',');
    string[] templates = templateIds.Replace(" ", string.Empty).Split(',');

    // build allowed component types
    StringBuilder allowedComponentTypes = new StringBuilder();
    for (int i = 0; i < schemas.Length; i++)
    {
	var schema = schemas[i];
	var template = templates[i];
	string separator = string.Empty;
	if (i > 0)
	{
	    separator = ", ";
	}
	allowedComponentTypes.Append(string.Format("{3}{{schema: \"tcm:{0}-{1}-8\", template: \"tcm:{0}-{2}-32\"}}", publicationId, schema, template, separator));
    }

    // set maxoccurs only if needed
    string maxOccursValue = string.Empty;
    if (maxOccurs > 0)
    {
	maxOccursValue = string.Format(", maxOccurs: {0}", maxOccurs);
    }

    return string.Format("<!-- Start Region: {{title: \"{0}\", allowedComponentTypes: [{1}], minOccurs: {2}{3}}} -->", title, allowedComponentTypes, minOccurs, maxOccursValue);
}
```