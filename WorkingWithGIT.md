# Introduction #
We've recently migrated this Google Code project to GIT. Mostly, this means no change, as most of the work is in the Wiki anyway. If you've been used to working on a checked-out copy of the wiki pages, please note that the migration is to TWO git repositories, one for the code and one for the wiki. On the Source page, there's a dropdown that defaults to "default", but you can also select "Wiki" to get the details of cloning the wiki.

# Authentication #
Getting your username and password working properly can be a bit fiddly, and of course, the setup depends a lot on your GIT client. For people using TortoiseGIT (the majority of us??) the simplest thing seems to be to embed your username and password in the URL of the remote repository. Of course, this approach relies on you working on a computer that you control access to. With that caveat, here's how:

From the TortoiseGIT context menu, select Settings, and navigate to Git->Remote. Select the relevant remote and ensure that the URL is

https://your.identity:xxxxxxxxxx@code.google.com/p/tridion-practice/

using your own Google Code identity and replacing the x's with your Google code password. Make sure this is the one to be found here:

https://code.google.com/hosting/settings

in other words, NOT your Google password.

You might also want to check further down that page to ensure that the security checkbox is checked, allowing access from GIT clients.