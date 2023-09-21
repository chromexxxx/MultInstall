
# Mettez le contenu de votre script ici
Set-ExecutionPolicy Unrestricted -Force -Scope Process
# Installer le module PSWindowsUpdate, si nécessaire
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate))
{
	Write-Host "Installing PSWindowsUpdate Module..."
	Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
}



#Maj Logiciels chocolateyWrite-Host "Mise à jour logiciels..."


Write-Host 'Mise a jour logiciels...'
# Vérification de la présence de Curl
$curlInstalled = choco list --localonly -r | Where-Object { $_ -match 'curl' }

if ($null -eq $curlInstalled)
{
	Write-Host 'Curl n est pas installe. Installation en cours...'
	choco install curl -y > C:\temp\curl.txt
	Write-Host 'Installation de Curl terminee.'
	Add-Content -Path "C:\temp\logfile.txt" -Value "Installation de Curl terminée."
}
else
{
	Write-Host 'Curl est installe. Mise a jour en cours...'
	choco upgrade curl -y > C:\temp\curl.txt
	Write-Host 'Mise a jour de Curl terminee.'
	Add-Content -Path "C:\temp\logfile.txt" -Value "Mise à jour de Curl terminée."
}

Write-Progress -Activity 'Mise a jour logiciels...' -Status 'En cours...' -PercentComplete 0
choco upgrade all -y > C:\temp\cocolateyup.txt
Write-Progress -Activity 'Mise a jour logiciels...' -Status 'Termine.' -PercentComplete 100
Add-Content -Path "C:\temp\logfile.txt" -Value "Mise à jour de tous les logiciels avec Chocolatey terminée."

# Mettre à jour tous les logiciels installés avec winget
# Obtenir la liste des logiciels qui ont des mises à jour disponibles
$updatesAvailable = winget upgrade

# Vérifier si des mises à jour sont disponibles
if ($updatesAvailable -ne $null -and $updatesAvailable -notmatch "No installed package found with an available update.")
{
	# Ajouter la liste des logiciels avec des mises à jour à logfile.txt
	Add-Content -Path C:\temp\logfile.txt -Value "Logiciels avec des mises à jour disponibles:"
	Add-Content -Path C:\temp\logfile.txt -Value $updatesAvailable
	
	# Mettre à jour tous les logiciels installés avec winget
	Write-Host "Updating all winget applications..."
	Start-Process -Wait -FilePath winget -ArgumentList 'upgrade', '--all'
	Add-Content -Path C:\temp\logfile.txt -Value 'Mise à jour de tous les logiciels avec winget terminée.'
}
else
{
	Add-Content -Path C:\temp\logfile.txt -Value 'Aucune mise à jour disponible pour les logiciels installés avec winget.'
}
# Mettre à jour Windows
Write-Host "Starting Windows Update..."
Get-WindowsUpdate -Install -AcceptAll -AutoReboot
Add-Content -Path "C:\temp\logfile.txt" -Value "Windows Update ok"


# Nettoyer le disque
Write-Host "Starting Disk Cleanup..."
cleanmgr /sagerun:1
Add-Content -Path "C:\temp\logfile.txt" -Value "nettoyage disk ok."

# Vérifier l'intégrité du système
Write-Host "Starting System File Check..."
sfc /scannow
Add-Content -Path "C:\temp\logfile.txt" -Value "Vérification de l'intégrité du système terminée."

# Vérifier l'intégrité du disque
Write-Host "Starting Check Disk..."
chkdsk /f
Add-Content -Path "C:\temp\logfile.txt" -Value "Vérification de l'intégrité du disque terminée."

# Défragmenter le disque (si votre disque est un SSD, ne faites pas de défragmentation)
# Récupère les informations du disque
$InfoDisque = Get-PhysicalDisk | Where-Object { $_.DeviceID -eq 0 }

# Vérifie si c'est un SSD ou un HDD
if ($InfoDisque.MediaType -eq 'HDD')
{
	# Défragmentation du disque
	Write-Host "Démarrage de la défragmentation du disque..."
	defrag C: /U /V
}
else
{
	Write-Host "Le disque est un SSD. Défragmentation ignorée..."
}




# Crée une nouvelle instance de PowerShell pour exécuter votre script
Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-Command", $scriptBlock
				