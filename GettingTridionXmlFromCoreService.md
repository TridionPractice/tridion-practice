# Introduction #

The CoreService gives us a really nice object model for our Tridion objects, but sometimes the "XML Cowboy" in you just wants to deal with the "real deal". Here's how you can ask WCF to get you the XML behind those Tridion object classes.


# Details #

It is actually pretty simple - once you know what it takes:

```
SessionAwareCoreServiceClient client = new SessionAwareCoreServiceClient("wsHttp_2011");
ReadOptions readOptions = new ReadOptions();
IdentifiableObjectData tridionObject = client.Read("tcm:0-12-1", readOptions);
DataContractSerializer dcs = new DataContractSerializer(tridionObject.GetType()); 
using (MemoryStream ms = new MemoryStream())
{
    dcs.WriteObject(ms, tridionObject);
    ms.Position = 0;
    XmlDocument document = new XmlDocument();
    document.Load(ms);
    Console.Write(document.OuterXml);
}
```

# Warning #

This will NOT return your good old Tridion [R5](https://code.google.com/p/tridion-practice/source/detail?r=5) Xml. When Tridion introduced Tridion 2011, it also introduced a new, faster and leaner, Xml format for Tridion objects - Tridion [R6](https://code.google.com/p/tridion-practice/source/detail?r=6) Xml - which is identified by a different namespace: "http://www.sdltridion.com/ContentManager/R6", so do play with the results of this before pulling up your XSLTs and what-not that you have in your Xml Toolkit.