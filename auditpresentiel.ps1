# Audit matériel
# Chemin de sortie paramétrable
param (
	[string]$OutputPath = "C:\temp"
)

# Créer le répertoire de sortie s'il n'existe pas
if (-not (Test-Path $OutputPath))
{
	New-Item -Path $OutputPath -ItemType Directory
}

# Chemin du fichier de sortie
$outputFile = "$OutputPath\Audit_$(Get-Date -Format 'yyyyMMddHHmmss').txt"

# Fonction pour gérer les erreurs
function Handle-Error
{
	param (
		[Parameter(Mandatory = $true)]
		[string]$Message
	)
	
	Write-ToFile "ERREUR : $Message"
}

# Redirection vers le fichier
function Write-ToFile
{
	param (
		[Parameter(ValueFromPipeline = $true)]
		[string]$InputObject,
		[int]$NewLines = 2
	)
	
	Add-Content -Path $outputFile -Value $InputObject
	
	0 .. ($NewLines - 1) | ForEach-Object {
		Add-Content -Path $outputFile -Value ""
	}
}

function Write-ToFile
{
	param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject,
		[Parameter()]
		$NewLines = 2
	)
	
	Add-Content -Path $outputFile -Value $InputObject
	for ($i = 2; $i -lt $NewLines; $i++)
	{
		Add-Content -Path $outputFile -Value ""
	}
}


function Get-GraphicsCardDetails
{
	$graphicsCards = Get-CimInstance Win32_VideoController
	
	Write-ToFile "`n------ Carte(s) graphique(s) ------"
	$graphicsCards | ForEach-Object {
		Write-ToFile "Nom: $($_.Name)"
		Write-ToFile "Processeur: $($_.VideoProcessor)"
		Write-ToFile "Mémoire vidéo (KB): $($_.AdapterRAM)"
		Write-ToFile "Driver Version: $($_.DriverVersion)"
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
}

function Get-ProcessorDetails
{
	$processor = Get-CimInstance CIM_Processor
	Write-ToFile "------ Processeur ------"
	Write-ToFile "Nom: $($processor.Name)"
	Write-ToFile "Nombre de cœurs: $($processor.NumberOfCores)"
	Write-ToFile "Vitesse (MHz): $($processor.MaxClockSpeed)"
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}

function Get-ComputerName
{
	$computerName = $env:COMPUTERNAME
	Write-ToFile "`n------ Nom de l'ordinateur ------"
	Write-ToFile "Nom: $computerName"
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}

function Get-InstalledSoftware
{
	$installedSoftware = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
	Where-Object { $_.DisplayName -and $_.DisplayVersion -and $_.Publisher } |
	Select-Object DisplayName, DisplayVersion, Publisher
	
	Write-ToFile "`n------ Logiciels installés ------"
	$installedSoftware | ForEach-Object {
		Write-ToFile "Nom: $($_.DisplayName)"
		Write-ToFile "Version: $($_.DisplayVersion)"
		Write-ToFile "Fabricant: $($_.Publisher)"
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
}

function Translate-MemoryType
{
	param (
		[Parameter(Mandatory = $true)]
		[int]$typeCode
	)
	
	# Utilisez un hashtable pour traduire les codes en types lisibles
	$memoryTypes = @{
		24 = "DDR3"
		26 = "DDR4"
		31 = "DDR5"
		0 = "Inconnu"
	}
	
	return $memoryTypes[$typeCode]
	
	
}



function Get-MemoryDetails
{
	$memoryModules = Get-CimInstance Win32_PhysicalMemory
	$totalMemory = $memoryModules | Measure-Object -Property Capacity -Sum
	
	Write-ToFile "`n------ Mémoire ------"
	Write-ToFile "Total RAM (GB): $($totalMemory.Sum / 1GB)"
	Write-ToFile ""
	
	# Afficher le type, la capacité et le type de module (si possible) de chaque module de mémoire
	$memoryModules | ForEach-Object {
		$memoryType = Translate-MemoryType -typeCode $_.MemoryType
		$moduleType = if ($_.Description -like "*SODIMM*") { "SODIMM" }
		else { "DIMM" }
		
		Write-ToFile "Type: $memoryType ($moduleType)"
		Write-ToFile "Capacité (GB): $($_.Capacity / 1GB)"
		Write-ToFile ""
	}
}




function Get-DiskDetails
{
	$disks = Get-CimInstance Win32_DiskDrive
	
	Write-ToFile "`n------ Détails des disques ------"
	
	foreach ($disk in $disks)
	{
		# Pour le type de disque
		if ($disk.PNPDeviceID -like "*NVMe*")
		{
			$diskType = "NVMe"
		}
		else
		{
			$diskType = "SATA"
		}
		
		# Pour le style de partition
		$partitions = Get-CimInstance Win32_DiskPartition | Where-Object { $_.DiskIndex -eq $disk.Index }
		$partitionStyle = if ($partitions) { $partitions[0].Type }
		else { "Inconnu" }
		
		Write-ToFile "Nom: $($disk.DeviceID)"
		Write-ToFile "Modèle: $($disk.Model)"
		Write-ToFile "Type: $diskType"
		Write-ToFile "Capacité (GB): $($disk.Size / 1GB)"
		Write-ToFile "Style de partition: $partitionStyle"
		Write-ToFile "--------------------------------------"
		
	}
}

function Get-PartitionDetails
{
	# Récupérer toutes les informations sur les disques physiques
	$disks = Get-CimInstance Win32_DiskDrive
	
	foreach ($disk in $disks)
	{
		# Afficher les détails du disque
		Write-ToFile "`nDisque: $($disk.DeviceID) - $($disk.Model)"
		
		# Récupérer les partitions associées à ce disque
		$partitions = Get-CimInstance Win32_DiskPartition | Where-Object { $_.DiskIndex -eq $disk.Index }
		
		foreach ($partition in $partitions)
		{
			# Récupérer le volume logique associé à cette partition
			$logicalDisk = Get-CimAssociatedInstance -InputObject $partition -ResultClassName Win32_LogicalDisk
			
			# Récupérer le nom de la partition (Volume)
			$volumeName = if ($logicalDisk.VolumeName) { $logicalDisk.VolumeName }
			else { "Sans nom" }
			
			# Afficher les détails de la partition et du volume
			Write-ToFile " $($partition.Name) - $($partition.Size / 1GB) GB"
			Write-ToFile "$($logicalDisk.DeviceID) - $volumeName - $($logicalDisk.Size / 1GB) GB"
			Write-ToFile "--------------------------------------"
			#Write-ToFile ""
		}
	}
}

function Get-OSDetails
{
	$os = Get-CimInstance Win32_OperatingSystem
	Write-ToFile "`n------ Système d'exploitation ------"
	Write-ToFile "Nom: $($os.Caption)"
	Write-ToFile "Version: $($os.Version)"
	Write-ToFile "Architecture: $($os.OSArchitecture)"
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}

function Get-MotherboardDetails
{
	$mb = Get-CimInstance Win32_BaseBoard
	Write-ToFile "------ Détails de la carte mère ------"
	Write-ToFile "Fabricant: $($mb.Manufacturer)"
	Write-ToFile "Produit: $($mb.Product)"
	Write-ToFile "Version: $($mb.Version)"
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}

function Get-DefaultNetworkAdapterDetails
{
	# Récupérer l'adaptateur par défaut (celui qui a une passerelle)
	$defaultAdapter = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.DefaultIPGateway }
	
	if ($defaultAdapter)
	{
		Write-ToFile "`n------ Détails de l'adaptateur réseau par défaut ------"
		Write-ToFile "Nom: $($defaultAdapter.Description)"
		
		# Afficher l'adresse IP
		$ipAddress = $defaultAdapter.IPAddress[0]
		Write-ToFile "Adresse IP: $ipAddress"
		
		# Vérifier si c'est DHCP ou fixe
		$dhcpEnabled = if ($defaultAdapter.DHCPEnabled) { "DHCP" }
		else { "Fixe" }
		Write-ToFile "Attribution IP: $dhcpEnabled"
		
		# Afficher le masque de sous-réseau
		$subnetMask = $defaultAdapter.IPSubnet[0]
		Write-ToFile "Masque de sous-réseau: $subnetMask"
		
		# Afficher la passerelle
		$gateway = $defaultAdapter.DefaultIPGateway -join ', '
		Write-ToFile "Passerelle: $gateway"
		
		# Afficher les serveurs DNS
		$dnsServers = $defaultAdapter.DNSServerSearchOrder -join ', '
		Write-ToFile "Serveurs DNS: $dnsServers"
		
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
	else
	{
		Write-ToFile "`n------ Détails de l'adaptateur réseau par défaut ------"
		Write-ToFile "Aucun adaptateur par défaut trouvé."
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
}
function Get-BatteryDetails
{
	$battery = Get-CimInstance Win32_Battery
	if ($battery)
	{
		Write-ToFile "------ Détails de la batterie ------"
		Write-ToFile "État: $($battery.BatteryStatus)"
		Write-ToFile "État de santé: $($battery.Status)"
		Write-ToFile "Capacité maximale: $($battery.DesignCapacity)"
		Write-ToFile "Capacité actuelle: $($battery.FullChargeCapacity)"
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
}

function Get-LocalUsers
{
	$users = Get-LocalUser
	Write-ToFile "------ Utilisateurs locaux ------"
	foreach ($user in $users)
	{
		Write-ToFile "Nom: $($user.Name)"
		Write-ToFile "Nom complet: $($user.FullName)"
		Write-ToFile "Description: $($user.Description)"
		Write-ToFile "--------------------------------------"
		Write-ToFile ""
	}
}

function Translate-AntivirusState
{
	param (
		[Parameter(Mandatory = $true)]
		[int]$productState
	)
	
	# Les bits du champ productState indiquent l'état de protection de l'antivirus.
	# Les valeurs ci-dessous sont basées sur la documentation.
	
	$securityProductState = @{
		0x00000010 = "Désactivé"
		0x00000100 = "Mises à jour à jour"
		0x00010000 = "Actif"
		0x00020000 = "À jour"
	}
	
	$result = @()
	foreach ($state in $securityProductState.Keys)
	{
		if (($productState -band $state) -eq $state)
		{
			$result += $securityProductState[$state]
		}
	}
	
	# Si l'antivirus est actif et à jour
	if ($result -contains "Actif" -and $result -contains "À jour")
	{
		return "Actif et à jour"
	}
	# Si l'antivirus est actif mais pas à jour
	elseif ($result -contains "Actif")
	{
		return "Actif mais pas à jour"
	}
	# Si l'antivirus est désactivé
	elseif ($result -contains "Désactivé")
	{
		return "Désactivé"
	}
	# Autre état non spécifié
	else
	{
		return "Inconnu (Code: $productState)"
	}
}

function Get-AntivirusDetails
{
	$antivirus = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntiVirusProduct
	
	Write-ToFile "`n------ Détails de l'antivirus ------"
	
	if ($antivirus)
	{
		$antivirus | ForEach-Object {
			Write-ToFile "Nom: $($_.displayName)"
			Write-ToFile "Path: $($_.pathToSignedProductExe)"
			Write-ToFile "État: $(Translate-AntivirusState -productState $_.productState)"
			Write-ToFile "--------------------------------------"
			Write-ToFile ""
		}
	}
	else
	{
		Write-ToFile "Aucun antivirus détecté."
	}
}
function Get-OfficeStatus
{
	$officePaths = @(
		"C:\Program Files (x86)\Microsoft Office\Office*",
		"C:\Program Files\Microsoft Office\Office*",
		"C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
	)
	
	$officeFound = $false
	foreach ($path in $officePaths)
	{
		if (Test-Path $path)
		{
			$officeFound = $true
			break
		}
	}
	
	Write-ToFile "`n------ Microsoft Office ------"
	
	if (-not $officeFound)
	{
		Write-ToFile "Status: Non installé"
	}
	else
	{
		# Notez que cette partie ne vérifie pas l'activation, mais seulement la présence.
		# La vérification d'activation est plus complexe et dépend de la version d'Office.
		Write-ToFile "Status: Installé"
	}
	
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}
function Get-OfficeActivationStatus
{
	$officePaths = @(
		"C:\Program Files (x86)\Microsoft Office\Office*\ospp.vbs",
		"C:\Program Files\Microsoft Office\Office*\ospp.vbs"
	)
	
	$activationStatus = "Inconnu"
	foreach ($path in $officePaths)
	{
		if (Test-Path $path)
		{
			# Exécuter ospp.vbs pour obtenir le statut de la licence
			$result = cscript.exe $path /dstatus
			if ($result -like "*LICENSED*")
			{
				$activationStatus = "Activé"
				break
			}
			elseif ($result -like "*NOT LICENSED*")
			{
				$activationStatus = "Non Activé"
				break
			}
		}
	}
	
	Write-ToFile "`n------ Microsoft Office ------"
	Write-ToFile "Statut d'activation: $activationStatus"
	Write-ToFile "--------------------------------------"
	Write-ToFile ""
}



try
{
Get-ComputerName
Get-ProcessorDetails
Get-MemoryDetails
Get-DiskDetails
Get-PartitionDetails
Get-GraphicsCardDetails
	Get-OSDetails
	Get-OfficeStatus
	Get-OfficeActivationStatus
#Get-MotherboardDetails
	Get-DefaultNetworkAdapterDetails
Get-BatteryDetails
Get-AntivirusDetails
Get-LocalUsers
#Get-InstalledSoftware

# Ouvrir le fichier avec le programme par défaut
	Invoke-Item $outputFile
	
}
catch
{
	Handle-Error $_.Exception.Message
}

Write-ToFile "Script terminé avec succès à $(Get-Date)"
