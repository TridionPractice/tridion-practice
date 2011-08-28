"C:\Users\dominic\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Add this directory to the path so we can just invoke scripts 
# directly if they are here.
$psDir = split-path $profile
if (-not $env:path.contains($psDir)) {
	$env:Path  = $env:Path + ';' + $psDir
}

set-alias -name kt -value Kill-Tridion
set-alias -name rat -value Restart-AllTridion