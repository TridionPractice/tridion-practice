# Introduction #
This page outlines Tridion design approaches and trade-offs with two approaches to managing CSS.

CSS is code for which a Tridion developer is responsible for maintaining, but not necessarily writing.   CSS is a stylesheet language which is used for formatting markup, predominantly HTML.  Like any quality code, it should be well-architected so that it is flexible, maintainable, and sustainable. This will outline patterns for managing CSS.

# CSS Management #
There are two approaches for managing the CSS for a website in Tridion

## Approach 1: Binary Files ##

### Synonyms ###

  * Multimedia Components
  * CSS Schema
### Context ###

> This approach is often used with a code repository.
  * A developer uses WebDav to transfer CSS files from a code repo.
  * CSS is put into Tridion using multimedia schema
  * Default Multimedia Schema is used or a CSS multimedia schema is created
#### Publishing ####
  * The CSS binaries can be published to the web server
  * CSS component template can be created, CSS components added to a page template for CSS, the CSS page is published

## Approach 2:  Code Components ##

### Synonyms ###

  * Code Schemas
  * Plain text Schemas

### Context ###
This approach is often used without a code repository.
  * A developer copies and pastes CSS from a text editor into a code component.
  * CSS is managed in Tridion as either a generic "code component" or a custom CSS component which contains a large plaintext field

#### Publishing ####
  * CSS components must be added to a CSS page template with a CSS component Template
  * A CSS page is published

## Pros and Cons ##

|                            | **Pros** | **Cons** |
|:---------------------------|:---------|:---------|
| **Binary File**            |Easy to migrate from code repo, no risk of errors in migration | Cannot edit CSS in Tridion, front-end debugging goes more slowly            |
| **Code Component** | Can edit CSS in Tridion, front-end debugging goes quickly           | difficult to migrate from code repo, risk of migration errors |