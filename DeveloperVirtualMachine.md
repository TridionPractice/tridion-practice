# Introduction #

SDL Tridion practitioners ("Tridionauts") typically need development machines and environments.

# Step-by-step Guide #
**See the
[SDL Tridion 2013 TridionWorld guide for Creating a Development VM](http://www.sdltridionworld.com/articles/sdltridion2013/tutorials/creating-development-vm-1.aspx) or the [2011 version](http://www.sdltridionworld.com/articles/sdltridion2011/tutorials/creating-development-vm-1.aspx)**. Then get community feedback, recommendations, and practices on setting up and maintaining a VM for learning and development below.

Consider using or contributing to the [Kickstart Tridion Environment](http://code.google.com/p/kickstart-tridion-environment/wiki/GettingStarted) to accelerate your setup (classic diamond BluePrint and example content in 5 minutes after install!).

# Typical Practices #

See [SDLTridionWorld for a post on VMs](https://forum.sdltridion.com/topic.asp?TOPIC_ID=7148) related to this topic.

Typical practices (these are just suggested guidelines--adjust to meet your needs and feel free to comment below!):

  1. **Make a version or two.** Keep one or two of the latest CMS versions (e.g. SDL Tridion 2013 GA and SDL Tridion 2011 SP1-HR1).
  1. **Create all-in-one boxes.**
  1. **Simplify publishing.** Use HTTP for publishing to allow different configurations on the same machine.
  1. **Add more VMs as needed.** Create a separate VM for Linux-based content delivery, otherwise use the same Windows-based machine.
  1. **Take care with your sandbox**. Be wary of any pre-release or demo Tridion software--an upgrade path is not guaranteed.
  1. **Save time.** Create a "baseline" VM with your preferred OS, IDEs, and database before installing the parts that vary (different CMS versions).
  1. **Automate.** [Use scripts to restart after configuration changes.](https://code.google.com/p/tridion-practice/wiki/ProgrammaticallyRestartTridionContentManager)

### Saving Space ###

Space is a premium on such a VM. Here are some tips:

  * You can safely delete the temporary files in C:\ProgramData\SDL\Upload.
  * Look out for Windows Error Reporting logs, even if turned off, Windows may still collect dump files.


## Example SDL Tridion 2013 Setup ##

| Feature | Detail |
|:--------|:-------|
| Tridion Version | **SDL Tridion 2013 (GA, when ready)**|
| Modules and Extensions | Content Management, Templating, Extensions, and Content Delivery |
| Publishing | HTTP |
| IDEs | Visual Studio 2012, Eclipse, Notepad++ or Notepad2, XMLSpy|
| Server | <ul><li>Microsoft Windows Server 2012 (x64)</li><li>Microsoft IIS 8</li><li>Microsoft .NET Framework 4.5</li><li>Java SE 7.0 (64-bit)</li><li>if using Oracle: ODAC 11.2.0.3</li></ul> |

## Example SDL Tridion 2011 Setup ##

| Feature | Detail |
|:--------|:-------|
| Tridion Version | **SDL Tridion 2011 SP1-HR1** |
| Modules and Extensions | Content Management, Templating, Extensions, and Content Delivery |
| Publishing | HTTP |
| IDEs | Visual Studio 2010, Eclipse, Notepad++ or Notepad2, XMLSpy|

# Tips #
Other tips (fron Nuno Linhares, Robert Curlette, and Elena Serghie):

  * You can share a VM disk (.vmdk) across VM's but not concurrently. Either avoid placing it on a removable drive (or never remove it while in use to avoid corrupted data).
  * Re-use the same CM and CD licenses by pointing configs to a shared location.
  * Run exec sp\_updatestats on Tridion database about monthly.
  * Set the VM up with enough RAM (3GB min ~2012) for the OS, Tridion, IDEs (Visual Studio, Eclipse), web server, and SQL Server Management Studio.
  * [Clean-up tips for Windows](http://www.hanselman.com/blog/GuideToFreeingUpDiskSpaceUnderWindows7.aspx) (7, but most apply to Windows Servers)
  * If using ExperienceManager (SiteEdit), you'll need two sets of deployers, brokers, websites, and other extensions (thanks, Elena).
  * Third-party integrations may be out of scope--consider ways to fake or otherwise integrate this data
  * Powerdown the VM before adding hardware
  * Solidstate Drives (SSD) help
  * Enable WebDAV on the server with Server Manager > Features Summary > Desktop Experience (WebDAV is enabled for Tridion by default)
  * VM on a cloud instance may help a distributed team and for training
  * Remote desktop: Windows shortcuts work differently between VMWare and Remote Desktop. If you see only see the Visio plugin in what should be %TRIDION\_HOME%, you're likely looking at your host computer (i.e. Windows + E works with VMWare Player only)
  * [Copy and Paste problems with VMWare?](http://www.createandbreak.net/2012/12/cant-paste-from-vmware-player-to.html)
  * Finally, a VM != Source Control. You can back up the entire instance, but this is not the same as using a source code version control system, backing up the database, or saving a Content Port.

# Resources #

  * Get and Install [VMWare Player](http://www.vmware.com/products/player/) or skip the software and [consider the (Amazon's) cloud](http://aws.amazon.com/).
  * Get ready with [Prerequisites for SDL Tridion 2011 SP1](http://sdllivecontent.sdl.com/LiveContent/content/en-US/SDL_Tridion_2011_SPONE/concept_53EFC5A6A1D147AF845341E2E317076A)
  * Get your OS, IDE, and Database software by visiting [MSDN's Licenses and Downloads](http://msdn.microsoft.com/en-US/), [Biz Spark for businesses](http://www.microsoft.com/bizspark/), or [Dreamspark](https://www.dreamspark.com/) if you happen to be a student with a Tridion license
  * Check dll versions using [Assembly Information](http://assemblyinformation.codeplex.com/)

# FAQ #

The most frequent question about Tridion test VM's seem to be how to get a demo or a license.

  * [Getting started with SDL Tridion?](http://stackoverflow.com/questions/5590673/getting-started-with-sdl-tridion) (closed on StackOverflow)
  * [Can I get SDL Tridion Virtual Machine for my own purpose without license cost?](http://stackoverflow.com/questions/11691078/can-i-get-sdl-tridion-virtual-machine-for-my-own-purpose-without-license-cost)

Get started purchasing it, joining a company that uses it, or winning an [SDL Tridion MVP award](http://sdltridionworld.com/community/mvp_award/index.aspx).

  * [Chris Summers blogged on the Fifth Tridion Environment](http://www.urbancherry.net/blogengine/post/2010/02/06/The-Fifth-Environment.aspx)
  * [Alvin Reyes described how to started with SDL Tridion](http://www.createandbreak.net/2011/11/how-to-get-to-play-with-sdl-tridion.html)

_Comments, questions, and feedback welcome below._