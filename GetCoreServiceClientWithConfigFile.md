
# Introduction #

About 60% of the times I needed to use the Core Service it was for a simple, one-off operations (fix Schema namespaces, import content from RSS, create test content, etc), and I usually create Console Applications for this.

This is really just the intro on how to create a basic CoreService client app, since I still see people struggling with this.

# Details #

  1. Open Visual Studio and create a new console application
  1. Add a reference to `[`Tridion\_Home`]`\bin\client\Tridion.ContentManager.CoreService.Client.dll
  1. You may also need to add references to System.Runtime.Serialization and System.ServiceModel
  1. In Visual Studio, Add -> New -> Application Configuration file (app.config)
  1. Copy the contents of `[`Tridion\_Home`]`\bin\client\Tridion.ContentManager.CoreService.Client.dll.Config into your app.config.

Now, in your code, do something like this:

```
SessionAwareCoreServiceClient client = new SessionAwareCoreServiceClient("netTcp_2011");
Console.Write("Connected to CoreService with user " + client.GetCurrentUser().Title);
```

### Notes ###

If you want to see what other bindings you can use, just browse through the app.config. NetTcp is recommended only if your code executes on the same machine as Tridion. To execute remotely it is recommended to use WsHttp.

If you want/need to use BasicHttp you cannot use the SessionAwareCoreServiceClient, instead you must use CoreServiceClient.