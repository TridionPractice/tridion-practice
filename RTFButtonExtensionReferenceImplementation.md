# Introduction #

The RTF Button Reference Implementation is designed to show how to add a button the the rich text field formatting toolbar. The functionality is somewhat limited, but should serve as a good starting point for someone wishing to build this kind of extension.


# Details #

To install the extension, carry out the following steps:

  * Add a reference to Tridion.Web.UI.Core.dll (usually found in WebUI\WebRoot\bin)
  * Build the solution
  * Copy the created dll to WebUI\WebRoot\bin
  * Create the virtual directory for the editor in the SDL Tridion 2011 website, under WebUI/Editors
  * Configure the Editor in System.config, found in WebUI\WebRoot\Configuration
  * Increment the modification attribute at the top of System.config
  * Start the CME, open a Component with a rich text field and check that the button appears and works.

You _may_ need to clear your browser cache or perform an iisreset if the button doesn't appear at first.