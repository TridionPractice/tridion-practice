
# Introduction #

Many people try to loop over a multi-value embedded field and find themself stuck with:

```
<!-- TemplateBeginRepeat name="Field.repeatablebody" -->
  <!-- TemplateBeginIf cond="Field.body!=''" -->
    <p>
      <!-- TemplateBeginRepeat name="Field.body" -->
        @@Field@@
      <!-- TemplateEndRepeat -->
    </p>
  <!-- TemplateEndIf -->
<!-- TemplateEndRepeat -->
```

The problem here is that there is only one `TemplateRepeatIndex` that we somehow expect to have multiple values at once.

# Solution #

In Tridion 2009 SP1 a new variable was introduced to handle this situation: `FieldPath`. This variable always holds the full XPath to the current field of the current (innermost) iteration.


The result is generic iteration over embedded multivalue fields is possible:

```
<!-- TemplateBeginRepeat name="Component.Fields" -->
  @@Field.Name@@
  <!-- TemplateBeginRepeat name="Field.Values" -->
    <!-- TemplateBeginIf cond="Field.ContentType = 'text/plain'" -->      
    @@RenderComponentField(FieldPath, TemplateRepeatIndex)@@
    <!-- TemplateEndIf -->
    <!-- TemplateBeginIf cond="Field.ContentType = 'tridion/field'" -->
      <!-- TemplateBeginRepeat name="Field.Fields" -->
        @@Field.Name@@
        <!-- TemplateBeginRepeat name="Field.Values" -->
          @@RenderComponentField(FieldPath, TemplateRepeatIndex)@@        
        <!-- TemplateEndRepeat -->
      <!-- TemplateEndRepeat -->
    <!-- TemplateEndIf -->
  <!-- TemplateEndRepeat -->
<!-- TemplateEndRepeat -->
```