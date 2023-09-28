
Set-ExecutionPolicy Unrestricted -Force -Scope Process


# Obtenir le chemin vers le script ospp.vbs en fonction de l'architecture du système d'exploitation
if ([System.Environment]::Is64BitOperatingSystem)
{
	$path = "C:\Program Files\Microsoft Office\Office16\ospp.vbs"
}
else
{
	$path = "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs"
}

# Vérifier que le script existe
if (Test-Path -Path $path)
{
	# Boucler jusqu'à ce que l'utilisateur choisisse de quitter
	while ($true)
	{
		# Présenter un menu à l'utilisateur
		$selection = Show-InputBox "Choisissez une option : `n 1. Afficher le statut `n 2. Supprimer la clé `n 3. Activer une nouvelle clé `n 4. Quitter" "Sélection" "1"
		
		switch ($selection)
		{
			1 {
				# Exécuter le script avec l'option /dstatus et capturer la sortie
				$output = Run-Script $path "/dstatus"
				
				# Afficher la sortie dans une boîte de message
				[System.Windows.Forms.MessageBox]::Show($output)
				Add-Content -Path "C:\temp\logfile.txt" -Value "Statut Office Ok ok"
				
			}
			2 {
				# Demander à l'utilisateur de saisir la clé à supprimer
				$key = Show-InputBox "Veuillez entrer la clé à supprimer" "Suppression de clé" ""
				
				# Exécuter le script avec l'option /unpkey et capturer la sortie
				$output = Run-Script $path "/unpkey:$key"
				Add-Content -Path "C:\temp\logfile.txt" -Value "Suppression clé Office Ok ok"
				
				# Afficher la sortie dans une boîte de message
				[System.Windows.Forms.MessageBox]::Show($output)
			}
			3 {
				#ouvrir url licence
				Start-Process -FilePath "msedge.exe" -ArgumentList "-inprivate", "http://licence.xwz.fr"
				
				# Demander à l'utilisateur de saisir la nouvelle clé à activer
				$newKey = Show-InputBox "Veuillez entrer la nouvelle clé à activer" "Activation de clé" ""
				
				# Exécuter le script avec l'option /inpkey pour insérer la nouvelle clé et capturer la sortie
				$output = Run-Script $path "/inpkey:$newKey"
				Add-Content -Path "C:\temp\logfile.txt" -Value "Activation Office Ok ok"
				
				# Afficher la sortie dans une boîte de message
				[System.Windows.Forms.MessageBox]::Show($output)
			}
			4 {
				# Sortir de la boucle, ce qui mettra fin au script
				return
			}
			default {
				[System.Windows.Forms.MessageBox]::Show("Vous avez quitté.")
				return
			}
		}
	}
}