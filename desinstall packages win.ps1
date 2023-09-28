# Liste des applications
$apps = Get-AppxPackage | Select-Object -Property Name, PackageFullName

# Sélection de l'application à désinstaller
$selectedApp = $apps | Out-GridView -Title "Select an App to uninstall" -OutputMode Single

# Vérification de la sélection
if ($null -ne $selectedApp)
{
	# Tentative de désinstallation
	Write-Host "Trying to uninstall $($selectedApp.Name)..."
	$appToRemove = Get-AppxPackage -Name $selectedApp.PackageFullName
	if ($null -ne $appToRemove)
	{
		$appToRemove | Remove-AppxPackage
		if ($?)
		{
			Write-Host "$($selectedApp.Name) successfully uninstalled."
		}
		else
		{
			Write-Host "Failed to uninstall $($selectedApp.Name)."
		}
	}
	else
	{
		Write-Host "$($selectedApp.Name) not found."
	}

}
else
{
	Write-Host "No application selected. Exiting..."
}