"Shutting down Tridion COM+ Application"
$COMAdminCatalog = new-object -com COMAdmin.COMAdminCatalog
$COMAdminCatalog.ShutdownApplication("SDL Tridion Content Manager")