# Introduction #

This document explains how to install and configure the [LinkMetaRedirector](https://code.google.com/p/tridion-practice/source/browse/#svn%2Ftrunk%2FHttpModules%2FLinkMetaRedirector) HttpModule for SDL Tridion 2011 and IIS7.5. It assumes that you've already downloaded the source code from the library.

# Installation Details #
Follow these steps to install the HttpModule:
  * Add a reference to Tridion.ContentDelivery.dll.
  * Compile the assembly.
  * Copy the assembly to the bin folder of your web application.

# Configuration Details #

To configure the module you need to follow the steps below to update the web.config file of your web application:
  * Add the GlobalPubId key to app settings, changing the value as appropriate for your Publication: `<add key="GlobalPubId" value="3" />`
  * Add the RedirectUrlField key to app settings: `<add key="RedirectUrlField" value="friendlyurl" />`. The value should reflect the XML name of the metadata field in your Page metadata where the redirect URL (the URL to redirect **from**) can be found.
  * Add the following module config to system.webserver > modules: `<add name="LinkMetaRedirector" type="LinkMetaRedirector.Module" preCondition="" />`.

# How it works #

The module catches all incoming requests and separates the path from the full URL. It then performs a Broker query to find a Page with the matching value in the RedirectUrlField. If a Page is found, the ID is used in a Page Link where, if resolved, the target URL is used in a 301 redirect.