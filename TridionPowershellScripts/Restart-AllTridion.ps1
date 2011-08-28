"### Restart All Tridion ###"
"Stopping All Tridion CM services"
$runningServices = service     TCMBCCOM, `
#                TCMIMPEXP, `
                TcmPublisher, `
                TCMSearchHost, `
                TcmSearchIndexer, `
                TcmServiceHost, `
                TCMWorkflow `
        | where {$_.Status -eq "Running"}
$runningServices | % {stop-service -force -InputObject $_}
Kill-Tridion
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
