
# Introduction #

Below are snippets that are useful when interacting with the Tridion GUI in JavaScript. The snippets are written to be executed in the JavaScript console of your browser, but can also be easily modified to run in your regular JavaScript.



# Determine the current view #

```
>$display.getView()
Component object
```

```
>$display.getView().getTypeName()
"Tridion.Cme.Views.Component"
```


# Determine the current item #

```
>$display.getItem()
Tcm$Component object
```

```
>$display.getItem().getTypeName()
"Tridion.ContentManager.Component"
```

# Determine the editor control that currently has the focus #
```
>$display.getView().properties.activeEditor
<input class="text" value="Current field value" type="text">
```

Note that this property loses its value as soon as the field loses focus, so to display it in the JavaScript console you'll typically want to do something like this:

```
>setTimeout("console.log($display.getView().properties.activeEditor.properties)", 2000)
```

And then quickly click inside the field that you're interested in.

Alternatively you can get it from the FieldBuilder:

```
>$display.getView().properties.controls.fieldBuilder.properties.focusField
SingleLineTextField object
```

# Determine the name of the rich text field being currently edited #

```
>$display.getView().getSourceEditorName()
"Description"
```

# Determine the selected text in the current rich text field #

```
>$display.getView().properties.activeEditor.getSelectedHTMLElement().toString()
"licensed "
```

There is a lot more information available if you want on the selection:

```
>$display.getView().properties.activeEditor.getSelectedHTMLElement()
Range object
```

# Get the FieldBuilder in the Component view #

```
>$display.getView().properties.controls.fieldBuilder
```

If you want to get the FieldBuilder of the metadata tab:

```
$display.getView().getMetadataTab().properties.controls.fieldBuilder
```

# Get a field from a FieldBuilder #

```
> var fb = ...
> field = fb.getField("HeaderImage")
MultimediaLinkField object
```

# Get or set the value(s) of a field through FieldBuilder #

All fields are inherently multi-value, they just consider "1" a valid value of "multi".

If you look up a field like above, you can get its value(s) like this:

```
var values = field.getValues();
var value = field.getValues()[0];
```

Setting the value of a single-value field is simple:

```
field.setValues(["New value"]);
field.setValues(["Nintendo3DS", "PC"])
```

For a multi-value field you must realize that you are setting all values in one go, so you'll have to take care of the other values:

```
field.setValues(field.getValues().concat("PC"))
```


# Register a command #

```
> $commands.registerCommand("WhereUsed", new function(name) {
    Type.enableInterface(this, "TestWhereUsed");
    this.addInterface("Tridion.Cme.Command", name);
    this._isAvailable = function(selection, pipeline) { return true; },
    this._isEnabled = function(selection, pipeline) { return true; },
    this._execute = function(selection, pipeline) { console.log("Look here WhereUsed") }
});
```

# Getting back to the Component window from a custom (RTF) popup #

If you create a custom popup window to help modifying the values of a field (so it pops up from the Component window), you can get back to the Component view with this:

```
> openener.$display.getView()
Component object
```

Note that you can get the DisplayController of your own popup with:

```
> $display.getView()
Tridion.Cme.Views.Image object
```

# Passing the value from a popup back into the Component view #

```
this.fireEvent("submit", { value: select.options[select.selectedIndex].text });
```

# Setting the values of a Keyword field through Checkboxes #

When you programmatically try to set the value of a Keyword field (one that is based on a Category), you may get an error:

```
Cannot read property 'maxOccurs' of undefined
```

This seems to be caused by a problem in the interaction between KeywordField and Checkbox constrols. You may be able to work around it by adding a reference to the settings object in the Checkbox control of your Keyword field:

```
var fieldBuilder = ...
var field = fieldBuilder.getField("RelatedKeywords");
field .properties.input.settings = field .properties.input.properties.settings
```

# Experience Manager #

Opening the library:

```
$display.getView().openLibrary($see.Controls.SEDrillDown.Mode.SELECT, null, null, true, function () {});
```

Getting the properties panel:

```
$controls.getControl(document.getElementById('PropertiesBox'), 'Tridion.Web.UI.Editors.SiteEdit.Controls.PropertiesBox')
```