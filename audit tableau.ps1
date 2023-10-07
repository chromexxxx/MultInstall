Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Configuration des chemins et des identifiants
$TempFolderPath = "C:\temp"
if (-not (Test-Path -Path $TempFolderPath))
{
	New-Item -Path $TempFolderPath -ItemType Directory
}
$url = "https://stephaninformatique.fr/pws/cred.txt"
$localPath = "$TempFolderPath\cred.txt"
Invoke-WebRequest -Uri $url -OutFile $localPath -ErrorAction Stop

$password = Get-Content $localPath | ConvertTo-SecureString
$username = "steph"
$credential = New-Object System.Net.NetworkCredential($username, $password)

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = $credential
$ftpUrl = "ftp://stephaninformatique.fr/httpdocs/pws/audit/ComputerInfo.csv"
$csvPath = "$TempFolderPath\ComputerInfo.csv"
$webclient.DownloadFile($ftpUrl, $csvPath) # Téléchargement du fichier

# Collecte et configuration des données
$form = New-Object Windows.Forms.Form
$form.Text = 'Entrer le nom du propriétaire'
$form.Size = New-Object Drawing.Size @(300, 150)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object Windows.Forms.Button
$okButton.Location = New-Object Drawing.Point @(75, 75)
$okButton.Size = New-Object Drawing.Size @(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$textBox = New-Object Windows.Forms.TextBox
$textBox.Location = New-Object Drawing.Point @(50, 25)
$textBox.Size = New-Object Drawing.Size @(200, 20)
$form.Controls.Add($textBox)

$form.Topmost = $true
$form.Add_Shown({ $textBox.Select() })
$result = $form.ShowDialog()

if ($result -eq [Windows.Forms.DialogResult]::OK)
{
	# (Insérez ici votre logique de collecte et d'écriture de données CSV)
	# Assurez-vous de gérer et formater correctement les données


	$owner = $textBox.Text
	$computerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
	$processorInfo = Get-CimInstance -ClassName Win32_Processor
	$memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory
	$diskInfo = Get-CimInstance -ClassName Win32_DiskDrive
	$videoControllerInfo = Get-CimInstance -ClassName Win32_VideoController
	$partitionStyle = (Get-CimInstance -ClassName Win32_DiskPartition).Type
	$freeSpaceOnC = (Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace / 1GB -as [int]
	$antivirusProduct = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct | Select-Object -ExpandProperty displayName
	# Obtenir toutes les interfaces réseau
	$networkInterfaces = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration
	
	# Filtrer les interfaces qui ont une passerelle par défaut (souvent votre connexion principale)
	$mainInterface = $networkInterfaces | Where-Object { $_.DefaultIPGateway -ne $null }
	
	# Si plusieurs interfaces ont une passerelle, vous pouvez choisir celle que vous considérez comme principale
	if ($mainInterface.Count -gt 1)
	{
		$mainInterface = $mainInterface | Select-Object -First 1 # Ou utilisez une autre logique pour sélectionner l'interface principale
	}
	$ipAddress = $mainInterface.IPAddress[0] # Prend la première adresse IP, généralement IPv4
	$dhcpEnabled = $mainInterface.DHCPEnabled # Vérifie si DHCP est activé
	
	$officeRegPath = Get-Item -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' -ErrorAction SilentlyContinue
	$officeInstalled = if ($officeRegPath) { $true }
	else { $false }
	$officeVersion = $officeRegPath.GetValue('ClientVersionToReport', $null)
	# Obtenir des informations sur le système d'exploitation
	$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
	
	# Vérifier si le système d'exploitation est 32 bits ou 64 bits
	$osArchitecture = $osInfo.OSArchitecture # Retourne "32 bits" ou "64 bits"
	
	# Obtenir des informations sur les partitions de disque
	$diskPartitionInfo = Get-CimInstance -ClassName Win32_DiskPartition
	
	# Vérifier si le système utilise UEFI ou BIOS
	# La propriété `Type` de `Win32_DiskPartition` peut indiquer si la partition est une partition GPT
	# Les systèmes qui démarrent en UEFI utilisent généralement une partition système GPT
	$uefiUsed = $diskPartitionInfo.Type -contains "GPT" # Retourne $true si GPT est trouvé, sinon $false
	
	# Si vous avez plusieurs antivirus, vous pouvez choisir le premier ou les lister tous
	if ($antivirusProduct -is [array])
	{
		$antivirusProduct = $antivirusProduct -join '; '
		
		$newData = [PSCustomObject]@{
			Proprietaire   = $owner
			NomOrdinateur  = $computerInfo.Name
			NomUtilisateur = $computerInfo.UserName
			Domaine	       = $computerInfo.Domain
			Processeur	   = $processorInfo.Name
			RAMTotaleGB    = ($computerInfo.TotalPhysicalMemory / 1GB) -as [int]
			TypeRAM	       = $memoryInfo.MemoryType
			CarteGraphique = $videoControllerInfo.Name
			NomDisque	   = $diskInfo.Model
			TailleDisqueGB = ($diskInfo.Size / 1GB) -as [int]
			EspaceLibreDisqueC = $freeSpaceOnC
			StylePartition = $partitionStyle
			AdresseIP	   = $ipAddress
			DHCPActif	   = $isDhcpEnabled
			OSArchitecture = $osArchitecture
			ModeBootUEFI   = Test-Path -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State'
			OfficeInstalle = $officeInstalled
			VersionOffice  = $officeVersion
			Antivirus	   = $antivirusProduct
		}
		
		$existingData = @()
		if (Test-Path -Path $csvPath)
		{
			$existingData = Import-Csv -Path $csvPath
			if ($existingData -isnot [array])
			{
				$existingData = @($existingData)
			}
		}
		
		$allData = $existingData + @($newData)
		$allData | Export-Csv -Path $csvPath -NoTypeInformation
	}
	
	try
	{
		$webclient.UploadFile($ftpUrl, $csvPath)
	}
	catch
	{
		Write-Error "Erreur lors du téléversement du fichier CSV: $_"
	}
}
Remove-Item -Path $TempFolderPath -Recurse -Force
