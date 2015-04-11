# Change Content or Metadata #

## Introduction ##

The Core Service in Tridion 2011 (and up) is a great way to access items in your Tridion system from anywhere. It is both easy to use and exposes a reasonable object model for the various item types. One thing it doesn't do however is to allow you to structured access to the Content and Metadata of Components.

The Fields class below puts a familiar facade over the Content and Metadata properties of a Component (and probably also over the Metadata of other types).

## Examples of usage ##

This code assumes that ```
client``` is a properly initialized Core Service client.

```
// load the schema
var schemaFields = client.ReadSchemaFields(SCHEMA_URI, true, DEFAULT_READ_OPTIONS);

// load a component based on that schema
var component = (ComponentData)client.Read(COMPONENT_URI, DEFAULT_READ_OPTIONS);
Console.WriteLine(component.Content);

// build a magical Fields object from it
var fields = Fields.ForContentOf(schemaFields, component);

// let's first quickly list all values of all fields
foreach (var field in fields)
{
	Console.WriteLine(string.Format("{0} (Type={1})", field.Name, field.Type));
	foreach (var value in field.Values)
	{
		Console.WriteLine("\t" + value);
	}
}

// now let's change the title
fields["Title"].Value += " (modified at " + DateTime.Now + ")";

// did it stick?
Console.WriteLine("Title=" + fields["Title"].Value);

// the Intro field doesn't have a value, let's set it
fields["Intro"].Value = "This is the (new) intro";

// change a value in a multi-value field
fields["Section"].Values[2] = "This is the new value for the third section";

// add a value to a multi-value field
try
{
	fields["Section"].Values[3] = "This is the (new) fourth section";
}
catch (IndexOutOfRangeException)
{
	// this is an expected exception, the field only has three values so you can't set/change 
	// anything beyond that. Instead you should use AddValue, like this:
	fields["Section"].AddValue("This is the (new) fourth section");
}

fields["Section"].AddValue("This is the (new) sixth section");

// Photo is an embedded schema field
Console.WriteLine("First Photo");
Fields photoFields = fields["Photo"].GetSubFields();
foreach (var field in photoFields)
{
	Console.WriteLine(string.Format("\t{0} (Type={1})", field.Name, field.Type));
	foreach (var value in field.Values)
	{
		Console.WriteLine("\t\t" + value);
	}
}

// Let's see if we can add an author to the photo
photoFields["Author"].Values[0] = "Annie Analyst";
photoFields["Author"].AddValue("Craig Cufflynx");
photoFields["Author"].RemoveValue("Annie Analyst");

//client.CheckOut(COMPONENT_URI, true, DEFAULT_READ_OPTIONS);
//client.Save(component, DEFAULT_READ_OPTIONS);

component.Content = fields.ToString();
Console.WriteLine(component.Content);

Console.WriteLine();

// Let's test with all field types
schemaFields = client.ReadSchemaFields("tcm:8-403-8", true, DEFAULT_READ_OPTIONS);
component = (ComponentData)client.Read("tcm:8-404", DEFAULT_READ_OPTIONS);
Console.WriteLine(component.Content);

fields = Fields.ForContentOf(schemaFields, component);

foreach (var field in fields)
{
	Console.WriteLine(string.Format("{0} (Type={1})", field.Name, field.Type));
	foreach (var value in field.Values)
	{
		Console.WriteLine("\t" + value);
	}
}

fields["RichTextField"].Value += " <span xmlns='http://www.w3.org/1999/xhtml'>more more more</span>";
fields["DropdownListField"].Value = "Value 2";
fields["CheckboxesField"].AddValue("Value 2");

Console.WriteLine(fields["ComponentLinkField"].Values[0]);

// change a component link
fields["ComponentLinkField"].Value = "tcm:8-404";

component.Content = fields.ToString();
Console.WriteLine(component.Content);

//client.CheckOut("tcm:8-404", true, DEFAULT_READ_OPTIONS);
//client.Save(component, DEFAULT_READ_OPTIONS);

Console.WriteLine();

// next test - creating a new component
schemaFields = client.ReadSchemaFields(SCHEMA_URI, true, DEFAULT_READ_OPTIONS);
component = client.GetDefaultData(ItemType.Component, NEW_COMPONENT_FOLDER_URI) as ComponentData;
Console.WriteLine(component.Content);

fields = Fields.ForContentOf(schemaFields);

component.Title = "Name of component (created at "+ DateTime.Now + ")";
fields["Title"].Value = "Title of newly created component";
fields["Intro"].Value = "Intro of newly created component";
fields["Section"].AddValue("This is the first section");
fields["Section"].AddValue("This is the section section");
fields["Photo"]["Picture"].Value = "tcm:8-394";
fields["Photo"]["Author"].Value = "Author of the photo";
fields["Photo"].AddValue();
fields["Photo"][1]["Picture"].Value = "tcm:8-394";
fields["Photo"][1]["Author"].Value = "Author of the photo";

component.Content = fields.ToString();
Console.WriteLine(component.Content);

//component = (ComponentData)client.Create(component, DEFAULT_READ_OPTIONS);
//Console.WriteLine(component.Id);
//Console.WriteLine(component.Content);


// another test - creating a new component that also has mandatory metadata
schemaFields = client.ReadSchemaFields("tcm:8-403-8", true, DEFAULT_READ_OPTIONS);
component = client.GetDefaultData(ItemType.Component, "tcm:8-34-2") as ComponentData;
component.Schema = new LinkToSchemaData { IdRef = "tcm:8-403-8" };
Console.WriteLine(component.Content);

fields = Fields.ForContentOf(schemaFields);

component.Title = "Test component (created at " + DateTime.Now + ")";
//fields["Title"].Value = "Title of newly created component";

component.Content = fields.ToString();
Console.WriteLine(component.Content);

fields = Fields.ForMetadataOf(schemaFields, component);
fields["MetadataField"].Value = "Value of MetadataField";

component.Metadata = fields.ToString();
Console.WriteLine(component.Metadata);

component = (ComponentData)client.Create(component, DEFAULT_READ_OPTIONS);
Console.WriteLine(component.Id);
Console.WriteLine(component.Content);


// one more test - changing the metadata of a folder
Console.WriteLine();
Console.WriteLine("Showing and manipulating folder metadata");
Console.WriteLine();

var folder = (FolderData)client.Read("tcm:8-34-2", DEFAULT_READ_OPTIONS); // Building Blocks folder
schemaFields = client.ReadSchemaFields(folder.MetadataSchema.IdRef, true, DEFAULT_READ_OPTIONS);
Console.WriteLine(folder.Metadata);

fields = Fields.ForMetadataOf(schemaFields, folder);

// gerically print fields
foreach (var field in fields)
{
	Console.WriteLine(string.Format("{0} (Type={1})", field.Name, field.Type));
	foreach (var value in field.Values)
	{
		Console.WriteLine("\t" + value);
	}
}

// now print them given that we know what we're doing
for (var i = 0; i < fields["Configuration"].Values.Count; i++) // TODO: make it so that we can foreach
{
	var subfields = fields["Configuration"][i];
	Console.WriteLine(subfields["Key"]);
	foreach (var value in subfields["Value"].Values)
	{
		Console.WriteLine("\t" + value);
	}
	if (subfields["Key"].Value == "Key2")
	{
		subfields["Value"].AddValue("Value set at " + DateTime.Now);
	}
}
foreach (var subfields in fields["Configuration"].SubFields)
{             
	Console.WriteLine(subfields["Key"]);
	foreach (var value in subfields["Value"].Values)
	{
		Console.WriteLine("\t" + value);
	}
	if (subfields["Key"].Value == "Key2")
	{
		subfields["Value"].AddValue("Value set at " + DateTime.Now);
	}
}

Console.WriteLine(fields.ToString());

//folder.Metadata = fields.ToString();
//client.Save(folder, DEFAULT_READ_OPTIONS);


// Last test: creating a reference MMC for an item on the VFS
schemaFields = client.ReadSchemaFields("tcm:8-389-8", true, DEFAULT_READ_OPTIONS);
component = (ComponentData)client.GetDefaultData(ItemType.Component, "tcm:8-46-2");
fields = Fields.ForMetadataOf(schemaFields, component);

// TODO: set mandatory metadata fields

Console.WriteLine(fields.ToString());

component.Metadata = fields.ToString();
//component = (ComponentData)client.Save(component, DEFAULT_READ_OPTIONS);
//Console.WriteLine(component.Id);
```


## Code ##

The code has been moved out of the article body and into the GIT repository:

https://code.google.com/p/tridion-practice/source/browse/ChangeContentOrMetadata/CreateContentOrMetadata/CreateContentOrMetadata.cs