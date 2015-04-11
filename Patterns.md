

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

This page outlines Tridion design approaches and patterns in the spirit of [Software Design Patterns](http://en.wikipedia.org/wiki/Software_design_pattern). See [Practices](Practices.md) for Tridion implementation recommendations.

# List #



## Potential Patterns ##

  * Output HTML
  * Output Non-HTML
  * CD-Side Rendering ("Fried")
  * CM-Side Rendering ("Baked")
  * [CM-Side Domain Specific Classes](http://www.tridiondeveloper.com/making-your-life-simpler-as-a-tridion-developer)
  * [Content Injection (Containers)](http://www.tridionworld.com/articles/understanding_content_injection.aspx)
  * Link List
  * Merge Fields
  * Modular Templating
  * Navigation by Structure Groups
  * Page Regions
  * Recursive Defaults

## Output HTML ##

**Overview**
  * Templates output markup such as HTML4, XHTML, HTML5, etc
  * Page Template extension may be .htm or .html

**Benefits**
  * Simple, easy-to-create, near out-of-the-box implementation
  * Designers can create DWT layout

**Trade-offs**
  * Lacks presentation server logic except for JavaScript

## Output Non-HTML ##

**Overview**
  * Tridion publishes pages with standard component presentations into an intermediate format (.NET, .JSP, or agnostic formats such as XML/ JSON)

**Benefits**
  * Flexible and familiar datasource
  * Content Consuming developers need less Tridion experience
  * Platform agnostic--similar sources can be used across channels, sites, technologies (.NET vs Java), etc
  * Flexibility in  handling content, metadata, and multimedia in render-side logic

**Trade-offs**
  * Designers lose access to DWT or must understand/be allowed to use the rendering framework format
  * XML, JSON, and other formats are stricter than HTML
  * Format and self-managed standards apply for the output
  * Troubleshooting involves queries rather than just rendered output (e.g. check database, metadata, templates, tcm ids, etc)

**Examples**
  * DD4T
  * CWA
  * Most Tridion-using organizations that have .NET or Java websites

## CM-Side Rendering ("Baked") ##
  * Familiar API to Tridion consultants
  * Impacts publishing performance
  * Possibly improves rendering performance
  * "Static" snapshot of CM-side relationships may not reflect published CPs

## CD-Side Rendering ("Fried") ##
  * Implementaton may optionally use CD API with dynamic component presentations and custom metadata
  * Object (and query) caching provides fast results when using CD-API specific approach
  * Improves CM-side performance
  * Improves publishing performance
  * Retrieves and displays only published CPs

## Navigation by Structure Groups ##
  * "Classic" navigation approach includes generating a navigation file, typically XML
  * XSLT or code transforms XML into appropriate markup
  * Standard, well-known, and documented approach
  * Straightforward author-friendly navigation management

## Recursive Defaults ##
Based on the premise that good defaults improve the author experience and improves output.
  * Use a value in the lowest, most specific context (for example "alt" text from a schema that links to an image or page SEO information)
  * If value not available, use the value in the next higher, less specific context (e.g. if article component doesn't have SEO information, check page)
  * If value still not available, recursively check higher and higher items (e.g. check page, then check parent SG, then parent's parent, all the way to root or publication metadata)

Note: to follow translation best practices, use components instead of page/SG metadata.

# Considerations #

The appropriateness of a particular design pattern depends on the target development environment, consider the following when choosing an approach.

  * People - project and long-term resources, skill level, and number of individuals and teams
  * Process - organizational standards, measurements, cost structure, and incentives
  * Technology - software versions, rendering framework (.NET or Java), and hardware