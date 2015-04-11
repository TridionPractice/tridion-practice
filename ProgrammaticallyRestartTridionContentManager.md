# Programmatically restart Tridion Content Manager #


## Introduction ##

During development it is a very common task to have to restart various parts of your Tridion Content Manager. These scripts will allow you to restart Tridion with a lot less clicking around.

## Details (using CMD) ##

There are two files involved:
  * RestartTridionCM.cmd - restarts all the Tridion services
  * ShutdownTCM.vbs - shuts down the Tridion Content Manager COM+ application

So to restart everything you just run RestartTridionCM and count to 20.

RestartTridionCM.cmd
```
@echo off
echo.
echo Stopping Tridion Content Manager Explorer
REM net stop /y "Tridion Content Manager Communicator" 1>nul 2>&1
REM net stop /y TridionTranslationManager 1>nul 2>&1
REM net stop /y Aggregation 1>nul 2>&1
net stop /y OESynchronizer 1>nul 2>&1
net stop /y OETracker 1>nul 2>&1
net stop /y OETrigger 1>nul 2>&1
net stop /y OEMailer 1>nul 2>&1
iisreset /stop 1>nul 2>&1
echo Stopping Tridion network services
net stop /y TCMPublisher 1>nul 2>&1
net stop /y TCDTransportService 1>nul 2>&1
net stop /y TcmSearchIndexer 1>nul 2>&1
net stop /y TcmSearchHost 1>nul 2>&1
net stop /y TcmServiceHost 1>nul 2>&1
echo Restarting Tridion backwards compatibility subsystem
cscript.exe //nologo "c:\shutdowntcm.vbs" 1>nul 2>&1
echo Restarting Tridion network services
net start TcmServiceHost 1>nul 2>&1
net start TcmSearchHost 1>nul 2>&1
net start TcmSearchIndexer 1>nul 2>&1
net start TCDTransportService 1>nul 2>&1
net start TcmPublisher 1>nul 2>&1
echo Restarting Tridion Content Manager Explorer
iisreset /start 1>nul 2>&1
net start OEMailer 1>nul 2>&1
net start OETrigger 1>nul 2>&1
net start OETracker 1>nul 2>&1
net start OESynchronizer 1>nul 2>&1
REM net start Aggregation 1>nul 2>&1
REM net start TridionTranslationManager 1>nul 2>&1
REM net start "Tridion Content Manager Communicator" 1>nul 2>&1
echo.
echo.
echo Done.
echo.
echo.
echo.
echo.
```

ShutdownTCM.vbs:
```
Dim catalog
Set catalog = CreateObject("COMAdmin.COMAdminCatalog")
catalog.connect("My Computer")
catalog.ShutdownApplication("SDL Tridion Content Manager")
Set catalog = Nothing
```

## Details (using PowerShell) ##

It is also possible to do something similar from the Windows Powershell. If you put the following code in your profile, you can restart Tridion by typing "RestartAllTridion" (or "rat")
(Note: this example uses a different list of services than the CMD example. Of course in either case, you will probably want to tailor it to your own needs, depending on which Tridion products you have installed.)

```
"rat"
set-alias -name rat -value RestartAllTridion
function RestartAllTridion
{
"### Restart All Tridion ###"
"Stopping All Tridion CM services"
$runningServices = service     TCMBCCOM, `
                TCMIMPEXP, `
                TcmPublisher, `
                TCMSearchHost, `
                TcmSearchIndexer, `
                TcmServiceHost, `
                TCMWorkflow `
        | where {$_.Status -eq "Running"}
$runningServices | % {stop-service -force -InputObject $_}
kt
"Doing an IISRESET"
iisreset
"Starting Tridion services"
# This script basically does best-effort, so we need a sick-bag in case a service is disabled or whatever 
# (feel free to wire up the WMI stuff if you need to scratch this)
&{
  trap [Exception] {}
  $runningServices | where { "Stopped", "StopPending" -contains $_.Status } | start-service
  }
}
"kt"
set-alias -name kt -value killTridion
function KillTridion {
"Shutting down Tridion COM+ Application"
$COMAdminCatalog = new-object -com COMAdmin.COMAdminCatalog
$COMAdminCatalog.ShutdownApplication("SDL Tridion Content Manager")
}

```

## Discussion ##
Your choice of which technique to use will mostly depend on your personal preferences. Apart from that, there are still Windows servers which don't have the Powershell installed, but cmd.exe is everywhere.