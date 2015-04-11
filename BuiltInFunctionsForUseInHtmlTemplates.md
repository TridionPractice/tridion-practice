
# Introduction #

These are the built-in DWT functions as of Tridion 2011 SP1:
  * StringLength(object obj)
  * GetBinaryInfo()
  * GetFieldMetadata(string fieldName)
  * GetFieldMetadata(string fieldName, bool isMetaDataField)
  * RenderComponentField(string fieldExpression, int fieldIndex, bool htmlEncodeResult, bool resolveHtmlAsRTFContent)
  * RenderComponentField(string fieldExpression, int fieldIndex, string value, bool htmlEncodeResult, bool resolveHtmlAsRTFContent)
  * RenderComponentField(string fieldExpression, int fieldIndex)
  * RenderComponentField(string fieldExpression, int fieldIndex, string value)
  * RenderComponentPresentation()
  * RenderComponentPresentation(string componentUri, string templateUri)
  * SetRenderContextVariable(object name, object value)
  * CollectionLength(string expression)

They are all documented in the TOM.NET CHM. You can find them by looking for the members of the BuiltInFunctions class.

# Example Output #

I've run them on a Component with this XML:

<pre>
<Content xmlns="uuid:4acb40fc-0a11-4c6e-aa28-03f889524613"><br>
<br>
<Image xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="tcm:1-98" xlink:title="!Halo3BestSeller"><br>
<br>
Unknown end tag for </Image><br>
<br>
<br>
<br>
<!ItemLink xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="tcm:1-97" xlink:title="Halo3"><br>
<br>
Unknown end tag for </ItemLink><br>
<br>
<br>
<br>
<br>
<br>
Unknown end tag for </Content><br>
<br>
<br>
</pre>

And found the following outputs:

<pre>
!StringLength(object obj)<br>
------------------------<br>
<br>
!StringLength("fixed value")=11<br>
!StringLength(Component.Title)=15<br>
!StringLength(Title)=15<br>
<br>
!GetBinaryInfo()<br>
---------------<br>
<br>
!GetBinaryInfo()=<br>
<br>
!GetFieldMetadata(string fieldName)<br>
----------------------------------<br>
<br>
!GetFieldMetadata("Image")=Name: Image<br>
Description: Image Width: 250px Height : 250px<br>
!CustomUrl:<br>
!MinOccurs: 1<br>
!MaxOccurs: 1<br>
<br>
!GetFieldMetadata("!ItemLink")=!AllowMultimediaLinks: False<br>
Name: !ItemLink<br>
Description: !ItemLink<br>
!CustomUrl:<br>
!MinOccurs: 1<br>
!MaxOccurs: 1<br>
<br>
!GetFieldMetadata("!NonExistentField")=<br>
<br>
<br>
!GetFieldMetadata(string fieldName, bool isMetaDataField)<br>
--------------------------------------------------------<br>
<br>
!GetFieldMetadata("!ItemLink", false)=!AllowMultimediaLinks: False<br>
Name: !ItemLink<br>
Description: !ItemLink<br>
!CustomUrl:<br>
!MinOccurs: 1<br>
!MaxOccurs: 1<br>
<br>
!GetFieldMetadata("!ItemLink", true)=<br>
<br>
<br>
!SetRenderContextVariable(object name, object value)<br>
---------------------------------------------------<br>
<br>
!SetRenderContextVariable("Thanks", "Giving")=<br>
<br>
<br>
!CollectionLength(string expression)<br>
-----------------------------------<br>
<br>
!CollectionLength("Component")=1<br>
!CollectionLength("Image")=1<br>
!CollectionLength("Image.Values")=1<br>
!CollectionLength("ItemLink.Values")=1<br>
!CollectionLength("Component.Properties")=0<br>
</pre>

I skipped all the RenderCompontentField and RenderComponentPresentation overloads, since those are familiar to most people already.

GetBinaryInfo didn't generate output above, since this was a normal Component. On a multimedia component, it gives:

<pre>
!GetBinaryInfo()<br>
------------------<br>
<br>
!GetBinaryInfo()=!IsExternal: False<br>
Filename: haloBestSeller.jpg<br>
!FileSize: 21838<br>
!UploadFromFile:<br>
!MimeType: image/jpeg<br>
Title: Jpeg image<br>
!CreationDate: 1/1/0001 12:00:00 AM<br>
!RevisionDate: 1/1/0001 12:00:00 AM<br>
!AllowedActions: Edit, View, Delete<br>
!DeniedActions: None<br>
!LoadState: !FullyLoaded<br>
!LoadFlags: None<br>
!IsEditable: True<br>
</pre>