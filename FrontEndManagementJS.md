# Introduction #
This page outlines Tridion design approaches and trade-offs with two approaches to managing JavaScript.

JavaScript is code for which a Tridion developer is responsible for maintaining, and possibly writing.   JavaScript is a dynamically typed programming language which is used predominantly for interactions in the web browser.  Like any quality code, it should be well-architected so that it is flexible, maintainable, and sustainable. This will outline patterns for managing JavaScript.

# JavaScript Management #
There are two approaches for managing the JavaScript for a website in Tridion

## Approach 1: Binary Files ##

### Synonyms ###

  * Multimedia Components
  * JavaScript Schema
### Context ###

> This approach is often used with a code repository.
  * A developer uses WebDav to transfer JavaScript files from a code repo.
  * JavaScript is put into Tridion using multimedia schema
  * Default Multimedia Schema is used or a JavaScript multimedia schema is created
#### Publishing ####
  * The JavaScript binaries can be published to the web server
  * JavaScript component template can be created, JavaScript components added to a page template for JavaScript, the JavaScript page is published

## Approach 2:  Code Components ##

### Synonyms ###

  * Code Schemas
  * Plain text Schemas

### Context ###
This approach is often used without a code repository.
  * A developer copies and pastes JavaScript from a text editor into a code component.
  * JavaScript is managed in Tridion as either a generic "code component" or a custom JavaScript component which contains a large plaintext field

#### Publishing ####
  * JavaScript components must be added to a JavaScript page template with a JavaScript component Template
  * A JavaScript page is published

## Pros and Cons ##

|                            | **Pros** | **Cons** |
|:---------------------------|:---------|:---------|
| **Binary File**            |Easy to migrate from code repo, no risk of errors in migration | Cannot edit JavaScript in Tridion <br /> front-end debugging goes more slowly            |
| **Code Component** | Easy to migrate from code repo, no risk of errors in migration <br />Can edit JavaScript in Tridion <br /> front-end debugging goes quickly <br /> Tridion can automatically publish the javascript in the correct encoding           | difficult to migrate from code repo <br />risk of migration errors <br /> Difficult to write completely modular JavaScript for many front-end designers |