
# Problem #

In SDL Tridion 2011, a new concept was introduced: application data. The idea is that implementers of add-ons or other software that works with Tridion will often wish to store and retrieve data that is related in some way to the items in Tridion they are working with. The Application Data API allows you to store and retrieve such data from software, and by default it is not directly displayed in the user interface. Most often, the best way to use the Application Data API is via the core service.

# Solution #

This recipe shows a simple example of setting and retrieving some data using the core service from the PowerShell. This example was motivated by working on [an add-on that uses Application Data](http://code.google.com/p/tridion-notification-framework/), and wishing to get started by quickly adding some data to test.

The following code saves the value "foobar" in the application data of a user.
```
$core = Get-TridionCoreServiceClient                              
$ad = new-object Tridion.ContentManager.CoreService.Client.ApplicationData            
$ad.ApplicationId = "WorkflowNotificationFramework"
$ad.Data = [System.Text.Encoding]::Unicode.GetBytes("foobar")
$ad.TypeId = "WorkflowNotificationData"
$addarr = ,$ad
$core.SaveApplicationData($user.Id, $addarr)
```
Retrieving this data is done as follows:
```
$ad = $core.ReadApplicationData($user.Id, "WorkflowNotificationFramework")
[System.Text.Encoding]::Unicode.GetString($ad.Data)
```

## Discussion ##
In the code shown, we begin by getting a core service client. Here we use the Get-TridionCoreServiceClient method from the [Tridion PowerShell Modules](http://code.google.com/p/tridion-powershell-modules/) project.

If you consult the [core service documentation](https://www.sdltridionworld.com/downloads/documentation/SDLTridion2011SP1/index.aspx), you will see that ApplicationData is in the Tridion.ContentManager.Data namespace. As usual when working with the core service, the classes on the client side are in a different namespace. In this example, we're using the client shipped with Tridion 2011 SP1, and in this case, the namespace becomes Tridion.ContentManager.CoreService.Client
The Application Data API has three important properties:
  1. Application ID: You can think of this as being a bit like a namespace. You get to provide a string which ensures that your application data doesn't get mixed up with the data of other applications
  1. Type ID: Notionally, this identifies the type of the data you have stored. If your application stores more than one kind of data, this will allow your code to determine how to process a given item.
  1. Data: The data itself. As far as Tridion's concerned, it's just bytes. In our example, you can see that we're storing the bytes of a Unicode string.

The SaveApplicationData method expects an array of ApplicationData objects. In our example, we have only one ApplicationData object. In the PowerShell lists are delimited with commas, so the standard idiom for a single member array is to create a list by beginning with a comma. As we wish this data to be associated with a User object, we provide the ID of that object .

Retrieving the data is simply a matter of providing the ID of the object with which the data was associated, and the Application ID