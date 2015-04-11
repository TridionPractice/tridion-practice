# Get Core Service Client without config file #


## Introduction ##

The most common way to connect to Tridion 2011's Core Service is to add a Service Reference to your Visual Studio project. Behind the scenes this generates code to wrap a lot of the XML required when talking to the Core Service and it creates a web.config or app.config with bindings for the machine you connected to.

The code is compiled into our main assembly or into the .exe. But that .config file somehow has to travel with your binary all the time.

## Details ##

The code fragment below creates the necessary binding and endpoint. If you read the code you'll see that it is pretty similar to the stuff you'd normally have in configuration.

```
static ICoreService2010 GetNewClient(string hostname, string username, string password)
{
    var binding = new BasicHttpBinding()
    {
        MaxBufferSize = 4194304, // 4MB
        MaxBufferPoolSize = 4194304,
        MaxReceivedMessageSize = 4194304,
        ReaderQuotas = new System.Xml.XmlDictionaryReaderQuotas()
        {
            MaxStringContentLength = 4194304, // 4MB
            MaxArrayLength = 4194304,
        },
        Security = new BasicHttpSecurity()
        {
            Mode = BasicHttpSecurityMode.TransportCredentialOnly,
            Transport = new HttpTransportSecurity()
            {
                ClientCredentialType = HttpClientCredentialType.Windows,
            }
        }
    };
    hostname = string.Format("{0}{1}{2}", hostname.StartsWith("http") ? "" : "http://", hostname, hostname.EndsWith("/") ? "" : "/");
    var endpoint = new EndpointAddress(hostname + "/webservices/CoreService.svc/basicHttp_2010");
    ChannelFactory<ICoreService2010> factory = new ChannelFactory<ICoreService2010>(binding, endpoint);
    factory.Credentials.Windows.ClientCredential = new System.Net.NetworkCredential(username, password);
    return factory.CreateChannel();
}
```

You'll also see that we get the basicHttp binding and assume it is in the default location. If those settings don't work for you, just update the code.

**Update**

The code fragment above has been used by many people as a starting point. I now use the fragment below, which is significantly short, but only works when you have access tot he netTcp binding on Tridion 2011 SP1 (or later):

```
var binding = new NetTcpBinding { 
        MaxReceivedMessageSize = 2147483647, 
        ReaderQuotas = new XmlDictionaryReaderQuotas { 
                MaxStringContentLength = 2147483647, 
                MaxArrayLength = 2147483647 } };
var endpoint = new EndpointAddress("net.tcp://localhost:2660/CoreService/2011/netTcp");
	
var client = new CoreServiceClient(binding, endpoint);
client.ChannelFactory.Credentials.Windows.ClientCredential = new NetworkCredential("Administrator", "tridion");
```