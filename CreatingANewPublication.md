# Creating a new publication #


## Details ##

```
CoreServiceClient client = ...
var publication = (PublicationData)client.GetDefaultData(ItemType.Publication, "tcm:0-0-0");
publication.Title = "My new publication title";
publication.Key = publication.Title;
publication.Parents = new[] { new LinkToRepositoryData { IdRef = "tcm:0-1-1" } };
publication = (PublicationData) client.Create(publication, new ReadOptions());
Console.WriteLine(publication.Id);
```