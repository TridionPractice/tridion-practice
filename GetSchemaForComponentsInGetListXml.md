# Get Schema For Components in GetListXml #


## Introduction ##

If you're using the Core Service to communicate with Tridion, you can use the following sample code to cheaply retrieve a list of all Components in a folder including their Schema URI.

## Details ##


```
var filter = new OrganizationalItemItemsFilterData
                 {
                 	Recursive = false,
                 	ItemTypes = new ItemType[] { ItemType.Component },
                 	ShowNewItems = true,
                 	BaseColumns = ListBaseColumns.Extended
                 };
var xml = client.GetListXml("tcm:5-14-2", filter);

Console.WriteLine(xml);
```

An example of the result:
```
<tcm:ListItems Managed="10682" ID="tcm:5-14-2" xmlns:tcm="http://www.tridion.com/ContentManager/5.0">
  <tcm:Item ID="tcm:5-85" Title="SDL launches profile-based marketing and e-commerce solution" Type="16" 
    Modified="2011-02-23T05:41:24" From Pub="020 Content" IsNew="false" Icon="T16L0P1" SchemaId="tcm:5-83-8"
    SubType="0" IsPublished="true" Lock="0" IsShared="true" IsLocalized="false" Trustee="tcm:0-0-0" />
  <tcm:Item ID="tcm:5-84" Title="The different levels of Compound Templating  Part 1 of 3" Type="16" 
    Modified="2011-01-31T19:52:40" FromPub="020 Content" IsNew="false" Icon="T16L0P1" SchemaId="tcm:5-83-8"
    SubType="0" IsPublished="true" Lock="0" IsShared="true" IsLocalized="false" Trustee="tcm:0-0-0" />
</tcm:ListItems>
```