# Scripted provisioning of Tridion Content Delivery #

## Introduction ##
If you've ever spent time setting up a Tridion infrastructure, there must have been moments when you wished that at least some parts of the process could be automated. Often this will be because you want to set up a development image quickly and simply, but you may also wish to automate Tridion provisioning in a more formal "DTAP street".
This recipe isn't the first example of automating a Tridion setup (see for example https://code.google.com/p/kickstart-tridion-environment/), and certainly won't be the last. Realistically, no such project can be generic, as your requirements will always be different, so the intention if this recipe is not so much to provide an out-of-the-box solution, but rather a demonstration of the possibilities, and of course, the chance to copy and paste some useful stuff. As it is scripted, you ought to be able to compose your own approach by abstracting the relevant parts and re-writing them to suit your own purposes.

## Prerequisites ##
The scripts are written in Powershell, and make use of a couple of modules from the Powershell Code Respository (http://poshcode.org/). Specifically, we use the Reflection module, which in turn uses the Autoload module. I would like to acknowledge with gratitude the work of Joel Bennett and other poshcode contributors. Many thanks - it's made this work a lot easier. The main reason to use the Reflection module is that it allows us the equivalent of a **using** directive in C#. In other words, we can import a namespace in a script, and thereafter refer to types in that namespace by much shorter names. I first stated using this technique when using the Tridion core service (in that context, you rapidly go insane if you have to type the names of everything in full), but it's also convenient here to be able to say `[XDocument]` instead of `[Xml.Linq.XDocument]`. Of course, if you prefer, you can do without the modules and simply add the namespaces by hand.

For the rest, of course you need to meet Tridion's own prerequisites, and ensure that the installation files are available. The assumption is that you will have downloaded the installation zip for the relevant version of Tridion and unzipped it somewhere on the server you are installing.

Did I mention that we're talking about Windows Server here? You could also do a scripted installation in a nix/Java flavour, If you do, we'd love to have it on Tridion Practice.

## What do the scripts do? ##
The main script is called createWebSite.ps1. This more or less follows the procedures in the SDL Tridion 2013 Installation Manual. It actually creates two web applications, one for your web site, and the other to host Tridion's HTTP upload. To get createWebSite to do its job, you have to provide it with various information. In fact, the parameters are all locations. Where are the items the script will need to find, and where do you want your installed sites to be located, both on disk and by DNS. (Although that's not to say that the script does anything beyond setting the host header name in IIS).

There are other scripts that set up the Experience Manager preview service, and add the XPM goodness to the staging site. (The way this is organised comes from following the installation guide as closely as possible. Next time, I might make XPM an option in the createWebSite script.) Disclaimer: the XPM parts aren't tested yet. Please let me know if you find issues - or better yet, have fixes.

The whole thing is kicked off from MasterSetup.ps1. In fact, the scripts have quite some parameters in common, so if you are doing it all, it makes sense to have one master script to ensure that the same values get passed to each where this is important.

## How to ##
  1. Download the scripts from the [repository](https://code.google.com/p/tridion-practice/source/browse/#git%2FTridionPowershellScripts%2FContentDeliveryProvisioning).
  1. If necessary, install the modules. For convenience these are also  in the repository under "Useful Modules"
  1. Edit MasterSetup.ps1 to suit your own needs. You'll find most of the default values come from the way I like to have a development box set up. (Folllowing tradition, of course the web site is called visitorsweb.) If you're doing a development box, this might be enough for you. To be honest, if you're doing a real DTAP setup, I'd expect you to customise rather more. Any feedback is welcome, for example, if there's something that should be configurable but isn't.
  1. Run MasterSetup.ps1