# Log to file from event handler #


## Introduction ##

When writing Tridion event handlers it always takes some time to figure out from which processes your event handler is being invoked. These logging functions write not just the usual date/time, but also add the current process and AppDomain to make it easier to spot in which process your problems happen.

## Usage ##

Put the two methods below in your class and then invoke them like this:

```
Log("SessionAwareCoreServiceClient created");
```

Or this:

```
Log("Impersonated '{0}'", userToImpersonate);
```

The output will be something like this:
<pre>
2012-05-03 15:20:18Z,TcmServiceHost.exe,TcmServiceHost,SessionAwareCoreServiceClient created<br>
2012-05-03 15:20:18Z,TcmServiceHost.exe,TcmServiceHost,impersonated 'TRIDION2011SP1\Administrator'<br>
2012-05-03 15:20:19Z,DefaultDomain,dllhst3g,SessionAwareCoreServiceClient created<br>
2012-05-03 15:20:19Z,DefaultDomain,dllhst3g,impersonated 'TRIDION2011SP1\Administrator'<br>
</pre>

## Code ##

```
internal static void Log(string msg)
{
    string LogTime = DateTime.Now.ToString("u");
    string LogModule = AppDomain.CurrentDomain.FriendlyName + "," + Process.GetCurrentProcess().ProcessName;
    File.AppendAllText("c:\\tridion\\eventhandler.log", LogTime +","+ LogModule +","+ msg.Replace("\n", "\n\t") + "\n");
}
internal static void Log(string formatMsg, params object[] args)
{
    Log(string.Format(formatMsg, args));
}
```