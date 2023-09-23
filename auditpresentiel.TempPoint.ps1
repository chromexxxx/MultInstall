# Script d'audit simple pour un ordinateur

# Information système générale
$systemInfo = Get-CimInstance Win32_ComputerSystem
$OSInfo = Get-CimInstance Win32_OperatingSystem

# Processeur
$processor = Get-CimInstance Win32_Processor

# Mémoire RAM
$memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum

# Carte graphique
$graphics = Get-CimInstance Win32_VideoController

# Disques
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

# Réseau
$network = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true }

# Liste des logiciels installés
$software = Get-CimInstance Win32_Product

# Affichage des informations

Write-Output "------ Information système ------"
Write-Output "Nom de l'ordinateur: $($systemInfo.Name)"
Write-Output "Modèle: $($systemInfo.Model)"
Write-Output "Fabricant: $($systemInfo.Manufacturer)"
Write-Output "Type: $($systemInfo.SystemType)"
Write-Output "Version de l'OS: $($OSInfo.Version)"

Write-Output "`n------ Processeur ------"
Write-Output "Nom: $($processor.Name)"
Write-Output "Fabricant: $($processor.Manufacturer)"
Write-Output "Description: $($processor.Description)"

Write-Output "`n------ Mémoire RAM ------"
Write-Output "Capacité totale: $($memory.Sum / 1GB) GB"

Write-Output "`n------ Carte graphique ------"
$graphics | ForEach-Object {
	Write-Output "Nom: $($_.Name)"
	Write-Output "Description: $($_.Description)"
}

Write-Output "`n------ Disques ------"
$disks | ForEach-Object {
	Write-Output "Nom: $($_.Name)"
	Write-Output "Taille: $($_.Size / 1GB) GB"
	Write-Output "Espace libre: $($_.FreeSpace / 1GB) GB"
}

Write-Output "`n------ Réseau ------"
$network | ForEach-Object {
	Write-Output "Description: $($_.Description)"
	Write-Output "IP Address: $($_.IPAddress)"
	Write-Output "Subnet Mask: $($_.IPSubnet)"
}

Write-Output "`n------ Logiciels installés ------"
$software | ForEach-Object {
	Write-Output "Nom: $($_.Name)"
	Write-Output "Version: $($_.Version)"
	Write-Output "Fabricant: $($_.Vendor)"
}

