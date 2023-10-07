$computers = "Computer1", "Computer2" # Liste des ordinateurs que vous souhaitez interroger

# Initialiser le tableau pour stocker les résultats
$results = @()

foreach ($computer in $computers)
{
	# Vérifier si l'ordinateur est accessible
	if (Test-Connection -ComputerName $computer -Count 2 -Quiet)
	{
		Write-Host "Recueillir des informations de $computer"
		
		# Recueillir des informations sur chaque ordinateur
		$computerInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_ComputerSystem
		$processorInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_Processor
		$memoryInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_PhysicalMemory
		$diskInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_DiskDrive
		$videoControllerInfo = Get-CimInstance -ComputerName $computer -ClassName Win32_VideoController
		
		# Ajouter les informations recueillies au tableau de résultats
		$results += [PSCustomObject]@{
			ComputerName = $computerInfo.Name
			Username	 = $computerInfo.UserName
			Domain	     = $computerInfo.Domain
			Processor    = $processorInfo.Name
			TotalRAM	 = ($computerInfo.TotalPhysicalMemory / 1GB) -as [int]
			RAMType	     = $memoryInfo.MemoryType
			VideoController = $videoControllerInfo.Name
			DiskName	 = $diskInfo.Model
			DiskSizeGB   = ($diskInfo.Size / 1GB) -as [int]
			PartitionStyle = (Get-CimInstance -ComputerName $computer -ClassName Win32_DiskPartition).Type
		}
	}
	else
	{
		Write-Host "$computer n'est pas accessible"
	}
}

# Exporter les résultats au format CSV
$results | Export-Csv -Path "C:\temp\ComputerInfo.csv" -NoTypeInformation
