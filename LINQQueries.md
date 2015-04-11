
# Introduction #

This page contains LINQ queries for looking up certain things in the Tridion Content Manager. Most snippets are meant to be run in [LINQPad](http://www.linqpad.net/) through the [Tridion driver for LINQPad](http://www.sdltridionworld.com/community/2011_extensions/tridion_driver_for_linqpad.aspx). They can often be easily converted to regular Core Service code by changing `Tridion` to the name you gave to your Core Service client (typically `client`) and unfolding some extension methods.

# What Schemas exist in a Publication and which fields do they have? #

```
Tridion
  .GetListXml("tcm:0-10-1", new RepositoryItemsFilterData { 
    Recursive=true, 
    ItemTypes = new[] { ItemType.Schema }, 
    SchemaPurposes= new [] { SchemaPurpose.Component } 
  })
  .Elements()
  .Select(elm => new { 
    ID=elm.Attribute("ID").Value, 
    Title=elm.Attribute("Title").Value, 
    Fields=String.Join(", ", Tridion.ReadSchemaFields(elm.Attribute("ID").Value).Fields.Select(field => field.Name)) 
  })
```

# Where have all Components of a Schema been published to? #

```
Tridion
  .GetListXml("tcm:10-1768-8", new UsingItemsFilterData())
  .Elements()
  .Select(elm => new {
    ID=elm.Attribute("ID").Value,
    Title=elm.Attribute("Title").Value,
    PublishedTo=String.Join(",", Tridion.GetListPublishInfo(elm.Attribute("ID").Value).Select(pi => pi.PublicationTarget.Title).Distinct())
  })
```

# Show all publication and their parent #

```
Tridion
    .GetSystemWideListXml(new PublicationsFilterData())
    .Elements()
    .Select(elm => (PublicationData)Tridion.Read(elm.Attribute("ID").Value, null))
    .Select(pub => new {
        Publication=pub.Title+" ("+pub.Id+")",
        Parents=string.Join(",", pub.Parents.Select(parent => parent.Title+" ("+parent.IdRef+")"))
    })
```

# How many components are there per schema? #

```
Tridion
  .GetListXml("tcm:0-10-1", new RepositoryItemsFilterData { 
    Recursive=true, 
    ItemTypes = new[] { ItemType.Schema }, 
    SchemaPurposes= new [] { SchemaPurpose.Component } 
  })
  .Elements()
  .Select(elm => new {
  	ID=elm.Attribute("ID").Value,
	Title=elm.Attribute("Title").Value,
	ComponentCount=Tridion.GetListXml(elm.Attribute("ID").Value, new UsingItemsFilterData{ItemTypes=new[]{ItemType.Component}}).Elements().Count()
  })
  .OrderByDescending(result => result.ComponentCount);
```

If you're more visually oriented, keep the list above in a variable called `results` and add this snippet after it:

```
var labels = "";
var data = "";
foreach (var result in results)
{
  if (labels.Length > 0) labels += "|";
  if (data.Length > 0) data += ",";
  labels += result.Title;
  data += result.ComponentCount;
}
var url = string.Format("https://chart.googleapis.com/chart?cht=p&chd=t:{1}&chds=a&chs=400x200&chl={0}", labels, data);
Util.Image(url).Dump();
```

# How many Publish Transactions are there in each state? #

```
Tridion
	.GetSystemWideListXml(new PublishTransactionsFilterData{
		StartDate = DateTime.Now.AddDays(-1),
		EndDate = DateTime.Now.AddDays(1)
	})
	.Elements()
	.GroupBy(elm => elm.Attribute("State").Value)
	.Select(grp => new {
		State=(PublishTransactionState)int.Parse(grp.Key), 
		Count=grp.Count()
	})
```