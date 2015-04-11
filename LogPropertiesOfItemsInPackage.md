
# Introduction #

Everyone who has ever done anything with Tridion Compound Templates knows that the items in the Package are the magic that makes everything tick. But not everyone knows that each item has a "hidden" grab bag of information, known as its `Properties`. Looking at these properties, you can learn many things about the items in the package and how Tridion treats them.

# Details #

Put this code in a C# fragment TBB and drop that TBB into your Compound Template in the spot where you want to see the properties:

```
var entries = package.GetEntries();
foreach (var entry in entries)
{
  var name = entry.Key;
  var item = entry.Value;
  log.Info("Properties for item "+name);
  foreach (var property in item.Properties)
  {
    log.Info("\t"+property.Key+"="+property.Value);
  }
}
```


In an example run, this is the output:

```
CSharpSourceTemplate: Properties for item Output
CSharpSourceTemplate: 	BaseTCMURI=tcm:4-445-2048
CSharpSourceTemplate: Properties for item Chrysanthemum with spaces.jpg
CSharpSourceTemplate: 	TCMURI=tcm:5-114
CSharpSourceTemplate: 	FileName=Chrysanthemum with spaces.jpg
CSharpSourceTemplate: Properties for item Component
CSharpSourceTemplate: 	TCMURI=tcm:5-114
```

After we run the Image Resizer TBB to resize the image to 50%, the output is:

```
CSharpSourceTemplate: Properties for item Output
CSharpSourceTemplate: 	BaseTCMURI=tcm:4-445-2048
CSharpSourceTemplate: Properties for item Chrysanthemum with spaces.jpg
CSharpSourceTemplate: 	TCMURI=tcm:5-114
CSharpSourceTemplate: 	FileName=Chrysanthemum with spaces.jpg
CSharpSourceTemplate: 	FileNameSuffix=_50percent
CSharpSourceTemplate: 	TemplateURI=tcm:4-444-32
CSharpSourceTemplate: Properties for item Component
CSharpSourceTemplate: 	TCMURI=tcm:5-114
```

So apparently the Image Resizer TBB added FileNameSuffix and TemplateURI properties to the image item. In this case the FileNameSuffix property is later combined with the FileName property by the default "Publish Binaries In Package" TBB (that is part of the Default Finish Actions) to determine the filename of the image in the transport package.