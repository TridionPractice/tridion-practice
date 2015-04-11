# Get Tridion Install Path #


## Introduction ##

These functions tell you where Tridion Content Manager is installed on any system, based on the values that the installer writes into the Windows registry.

## Details ##

```
/// <summary>
/// Gets the Tridion Install Path
/// </summary>
/// <returns>the Tridion Install Path</returns>
public static string GetTridionInstallPath()
{
    string output;

    try
    {
        RegistryKey RegKey = FindKeyInRegistry("Software\\Tridion");
        output = RegKey.GetValue("InstallDir").ToString();
    }
    catch (Exception ex)
    {
        throw new Exception("Could not get install path!", ex);
    }

    return output;
}

// Opens a registry either from its normal location or from the Wow6432Node and either from HKEY_CURRENT_USER or HKEY_LOCAL_MACHINE.
private static RegistryKey FindKeyInRegistry(string registryKey)
{
    return Registry.CurrentUser.OpenSubKey(registryKey) ??
           Registry.CurrentUser.OpenSubKey(registryKey.Replace("Software\\", "Software\\Wow6432Node\\")) ??
           Registry.LocalMachine.OpenSubKey(registryKey) ??
           Registry.LocalMachine.OpenSubKey(registryKey.Replace("Software\\", "Software\\Wow6432Node\\"));
}
```