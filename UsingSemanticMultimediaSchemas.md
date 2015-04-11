# Using Semantic Multimedia Schemas #


## Introduction ##
Most WCM developers are familiar with the division between "layout" images and "content" images, but under the heading of content images, you can make further divisions. It's often the case that a web site design dictates the use of specific kinds of images in particular places. The designer wants a "theme" image displayed at the top of the page, and it has to be a square of 400 pixels, or whatever. Maybe some images are banners, also with dimensions specified in the design. You can go further: thumbnails, icons, and the rest. This recipe describes an approach to managing these within Tridion.

## Details ##
Many Tridion users use the default multimedia schema for everything, or they just have an Image schema that they use for all images. When you have various kinds of image in use, this is a missed opportunity. By setting up distinct schemas for each image type, you can help the content team to keep organised, and make it easier for them to choose the right items when creating and updating their web site. Setting up your schemas like this can help in the following ways:

  * Semantic names - it's not just an image, it's a banner image, or a theme image, or a content image (i.e. one where the picture is relevant to the content being presented.) A bit of thought up front can really make things clearer to work with.
  * Constrained choices - In a schema with multimedia links, you can specify which schemas are allowed. When working with the components, only images of the correct type will be listed, which can save effort and confusion when selecting a multimedia component to link to.
  * By setting default/mandatory schemas on folders, you can help the team to organise their image content based on purpose
  * Event system processing can be dictated by the choice of schema
  * GUI Extension processing can be dictated by the choice of schema

### Automatic processing ###
I've mentioned that different kinds of processing can be dictated by the choice of schema. The most obvious limitation of the semantic multimedia schemas approach is that in a rich text format area, you can link to any multimedia component. This is a prime candidate for a GUI extension to constrain the selection to specific types. (Volunteers - please sign up here!)

The other obvious enhancement is to enforce specific sizes for some kinds of image. This can be done with an Events System assembly, as can be seen in [this example code](https://code.google.com/p/tridion-practice/source/browse/#git%2FImageSizeChecker). This implementation checks the title of the schema to see whether the required size is specified in square brackets. This mechanism is simple to set up, and has the benefit of making the size visible whenever a component is being created. Of course, you could easily use other kinds of metadata or configuration if your needs are different.

Here you can see that a schema with this naming scheme is used:

![http://i.imgur.com/e3rFSci.png](http://i.imgur.com/e3rFSci.png)

... and the resulting error when the wrong size of file is uploaded.

![http://i.imgur.com/UZEVUDP.png](http://i.imgur.com/UZEVUDP.png)

## Discussion ##
Use of this technique will take place in the context of a broader design. Perhaps some images will be automatically generated or resized (at various points in their life cycle). The web content team will vary hugely from place to place, and project to project, and the amount of constraint or assistence they need will vary too.