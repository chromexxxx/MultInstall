# Recueillir des informations sur l'ordinateur local
$computerInfo = Get-CimInstance -ClassName Win32_ComputerSystem
$processorInfo = Get-CimInstance -ClassName Win32_Processor
$memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory
$diskInfo = Get-CimInstance -ClassName Win32_DiskDrive
$videoControllerInfo = Get-CimInstance -ClassName Win32_VideoController

# Créer un objet avec les informations recueillies
$result = [PSCustomObject]@{
	ComputerName = $computerInfo.Name
	Username	 = $computerInfo.UserName
	Domain	     = $computerInfo.Domain
	Processor    = $processorInfo.Name
	TotalRAM	 = ($computerInfo.TotalPhysicalMemory / 1GB) -as [int]
	RAMType	     = $memoryInfo.MemoryType
	VideoController = $videoControllerInfo.Name
	DiskName	 = $diskInfo.Model
	DiskSizeGB   = ($diskInfo.Size / 1GB) -as [int]
	PartitionStyle = (Get-CimInstance -ClassName Win32_DiskPartition).Type
}

# Chemin du fichier CSV
$csvPath = "C:\temp\ComputerInfo.csv"

# Vérifier si le fichier existe déjà
if (Test-Path -Path $csvPath)
{
	# Si oui, ajouter les données au fichier existant
	$result | Export-Csv -Path $csvPath -NoTypeInformation -Append
}
else
{
	# Si non, créer un nouveau fichier et ajouter les données
	$result | Export-Csv -Path $csvPath -NoTypeInformation
}
