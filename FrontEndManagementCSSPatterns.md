# CSS Management Patterns #
This page outlines possible approaches for managing CSS in SDL Tridion. If you haven't yet, please read  [the page on managing CSS in Tridion](FrontEndManagementCSS.md).

## Flat CSS ##
A single component containing all styles for a website

### Synonyms ###
Flat CSS may also be called:

  * Single CSS File

### Approach ###
  * Single stylesheet  is added as [Binary](FrontEndManagementCSS#Approach_1:_Binary_Files.md) or [Code](FrontEndManagementCSS#Approach_2:__Code_Components.md) Component
  * CSS is published using one of the two standard publishing practices.

### Context ###
This is often used for small websites or for projects where little development is required of a single developer.


---

## Modular CSS ##
CSS files are broken into multiple parts. The big idea is that the CSS files are divided by "blocks" or single sets of requirements. There may be one file for header, another for navigation, another for a widget.

### Synonyms ###
  * Layered CSS
  * Object Oriented CSS (OOCS)

### Approach ###
  * CSS is split into multiple parts
  * Folder is created in Tridion to contain multiple parts
  * CSS parts are typically divided as components / non-components
  * CSS parts typically address one block on the web page (usually a single set of UI requirements)
  * CSS file names start with `xxx-` to denote order in which they should be assembled on a CSS page
    * `001-reset.css`
    * `002-branding.css`
    * `003-header.css `

### References ###
**[Frank M. Taylor: Layers of Design](http://blog.frankmtaylor.com/2011/11/03/the-layers-of-design/)**

### Context ###
Modular CSS is used when multiple developers may be working on a project and need to develop CSS, HTML, or JavaScript. This allows for a team to develop multiple elements of the front-end without needing to merge changes into a single file.


---

## Syndicated Design ##
CSS files are broken into multiple parts with a distinct pattern. The big idea is that a single design element is separate, discrete, and reusable in another web site.

### Synonyms ###
  * Syndicated CSS
  * Object Oriented Design (OOD)

### Approach ###
  * CSS is split into four broad sections.
    * **Reset**: meyer reset, normalize css
    * **Brand**: font families, color,text, border size, width, hover effects, animations for entire site
    * **Layout** : layout for pages. Addresses 1 column, 2 column, 3 column. Only styles major wrappers
    * **Components**: Layout CSS for individual component templates.
  * CSS files are labelled with a numbering pattern that demonstrates to which section the file applies.
    * 000 for reset`000-reset.css`
    * 001-009 for branding: `001-typography.css`, `002-colors.css`, `003-tables.css`, `004-global-classes.css`
    * 010 - 019 for Layout :`010-oneColumn.css`, `011-twoColumn.css`, `012-oneColumn-mobile.css`
    * 020 - 099 for Component Templates: `020-Header.css`, `021-Footer.css`, `030-carousel.css`
  * Styles do not overlap from one to the other.
  * Component CSS does not contain branding, except in cases where the component template has a non-branded feature
  * Page template typically contains over 30 CSS components


## Pros and Cons ##
|        | **Pros** | **Cons**|
|:-------|:---------|:--------|
|Flat CSS |  Easy to deliver website <br />CSS remains as-delivered <br />Training is minimal<br /> Easily integrates to a front-end designer's workflow | Not good for a team <br />slow to update a single component template <br /> Time consuming to debug front-end issues<br /> Unmonitored browser hacks <br /> Can become unsustainable over time |
|Modular CSS | Works for a Team <br /> Easy to update a single component template <br /> Design is sustainable <br /> Easy to manage FOUC by reorganizing components of a CSS page <br /> Easy to add or remove components| If CSS is not written in distinct parts, time consuming to split it up <br /> risk of losing some code <br /> training required for new people <br /> risk of repeated styles <br />browser hacks are easily managed <br /> risk of inconsistently written CSS across modules|
|Syndicated Design |Works for a Team <br /> Easy to update a single component template <br /> Design is sustainable <br /> Easy to manage FOUC by reorganizing components of a CSS page <br /> Easy to share brand to another website <br /> Easy to share the layout of a component template to another publication <br />easy to update layout without affecting entire experience <br /> Easy to add or remove components <br /> easy to add responsive modules <br /> Easy to switch to new CSS layout methods such as Regions and Felxbox  | If CSS is not written in distinct parts, time consuming to split it up  <br /> time consuming to agree on a labeling system<br /> risk of losing some code <br /> training required for new people <br /> risk of repeated styles <br />browser hacks are easily managed <br /> risk of inconsistently written CSS across modules|
