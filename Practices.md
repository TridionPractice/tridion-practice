

<a href='Hidden comment: 
Table template

<table border="1">
<tr><td>Approach

Unknown end tag for &lt;/td&gt;

<td>Pros

Unknown end tag for &lt;/td&gt;

<td>Cons

Unknown end tag for &lt;/td&gt;



Unknown end tag for &lt;/tr&gt;


<tr>
<td>
*
*
*


Unknown end tag for &lt;/td&gt;


<td>
*
*
*


Unknown end tag for &lt;/td&gt;


<td>
*
*
*


Unknown end tag for &lt;/td&gt;




Unknown end tag for &lt;/tr&gt;




Unknown end tag for &lt;/table&gt;



'></a>

# Introduction #

This page describes Tridion practices, approaches, and trade-offs. It's meant to list implementation choices that don't fit actual Design [Patterns](Patterns.md).

# List #



## Avoid Hard-Coded TCM IDs ##

<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Avoid TCM IDs in metadata and template code.<br>
</li><li>Save ids in components or system configuration files.<br>
</li><li>If needed for delivery-side code, generate identifiers at publish time.<br>
</td>
<td>
</li><li>Easy maintenance and updates<br>
</li><li>Content Porter-friendly<br>
</li><li>Environment-agnostic approach<br>
</td>
<td>
</li><li>Few cons, but can obscure "sample" code<br>
</li><li>Minor, trivial inconvenience to track IDs down (debug)<br>
</td>
</tr>
</table></li></ul>

## CMS Environment (DTAP) ##
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Develop templates and functionality in CMS Dev.<br>
</li><li>Content Port changes through to Production.<br>
</li><li>Publish to synchronize CD.</td>
<td></td>
<td></td>
</tr>
</table></li></ul>


## BluePrinting ##

### Multiple Publication Layers ###
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Basic BluePrint assumes a diamond-shaped  setup (with an Empty Parent at the top):<br>
<ul><li>Schemas<br>
<ul><li>Content<br>
<ul><li>Site (inherits from Content <i>and</i> Design)<br>
</li></ul></li><li>Design<br>
</li></ul></li></ul></li><li>Additional layers require names to distinguish between parent and child publication layers. Options include:<br>
<ul><li>Global, Master, or Shared for Parent, sharing publications (Shared can be confusing as it can also imply items from parent publications, but in the context of a child publication)<br>
</li><li>Local, {Language}, or similar for Child publications, typically for translation<br>
</li><li>Website, Site, or similar for publishable publications<br>
</li></ul></li><li>Organizations with multilingual content include two or more language translation-specific layers. One to "send" to translation and one to "receive" localized content.<br>
</li><li>Some organizations forego the translation layers and opt for channel-specific publications.</li></ul>

Pattern: design as many layers as needed, planning for 5 to 10 years. Implement actual publications only when required. Best described by Manuel Garrido as <a href='http://tridionstrategist.blogspot.com/p/sdl-tridion-blueprint-minimizing.html'>minimize localization</a>.<br>
</td>
<td>
<ul><li>Simply author experience<br>
</li><li>Reduce content variations<br>
</li><li>Reduce maintenance costs<br>
</td>
<td>
</li><li>Percieved inflexibility<br>
</li><li>Requires appropriate security model<br>
</li><li>Difficult to implement after-the-fact<br>
</td>
</tr>
</table></li></ul>

## Master (Global) Publication for most Content ##
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Store localizable content in the parent content publication<br>
</td>
<td>
</li><li>Simplifies author experience<br>
</td>
<td>
</li><li>Requires additional minor authorization work and standards (to separate channel-specific content)<br>
</li><li>Less applicable for content not meant to ever be shared (Intranet, separate entity, etc)<br>
</td>
</tr>
</table></li></ul>

## Authorization ##
### User option trimming via folder permissions ###
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Hide schema by removing folder permissions<br>
</li><li>Hide template options by associating with schema and by removing folder permissions<br>
</li><li>Remove by placing schema and templates in folders<br>
</li><li>Doesn't apply to embeddable schema<br>
</td>
<td>
</li><li>Reduced options improve author experience<br>
</td>
<td>
</li><li>Maintenance overhead<br>
</li><li>Hard to test -- Tridion implementors are typically admins and don't experience author permissions regularly (consider browser add-on to create multiple user sessions)<br>
</td>
</tr>
</table></li></ul>


## Only setting publication scope on subgroups ##
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Leave "apply to all" setting on Parent group scope settings<br>
</li><li>Leave "apply to all" setting on user membership scope setting<br>
</li><li>Set scope in subgroups for<br>
</td>
<td>
</li><li>Easier maintenance and troubleshooting<br>
</td>
<td>
</li><li>
</li><li>
</li><li>
</td>
</tr>
</table></li></ul>

## Organizational Items ##

### Folder Design (by content type, product, organization) ###
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Depends on organization<br>
</li><li>Place more frequently updated content higher in the folder structure<br>
</td>
<td>
</li><li>Improves content creation and selection time<br>
</td>
<td>
</li><li>Does not simply map to content types<br>
</td>
</tr>
</table></li></ul>

### Structure Group numbering convention (for navigation and ordering) ###
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Organize items by using a "xxx" number prefix<br>
</li><li>Similar to "<i>" float convention where items prefixed with a character show at the top of a alphanumeric list<br>
</td></i><td>
</li><li>Easily drive navigation<br>
</td>
<td>
</li><li>Requires author training<br>
</td>
</tr>
</table></li></ul>

### Components instead of Folder or SG metadata ###
<table border='1'>
<tr><td>Approach</td><td>Pros</td><td>Cons</td></tr>
<tr>
<td>
<ul><li>Folder, SG, or template metadata have component links instead of fields<br>
</li><li>Apply as needed to manage content in components<br>
</td>
<td>
</li><li>Allows content localization higher in the BluePrint<br>
</li><li>Pages and templates don't need localization for content differences<br>
</td>
<td>
</li><li>Hard to explain Web "metadata" != Tridion metadata<br>
</li><li>Increased implementation steps<br>
</td>
</tr>
</table>