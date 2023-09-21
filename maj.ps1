
# Mettez le contenu de votre script ici
Set-ExecutionPolicy Unrestricted -Force -Scope Process
# Installer le module PSWindowsUpdate, si nécessaire
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate))
{
	Write-Host "Installing PSWindowsUpdate Module..."
	Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
}

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


Add-Type -AssemblyName System.Windows.Forms

# Créez un nouveau formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Mise à jour sélective'
$form.Size = New-Object System.Drawing.Size(300, 300)
$form.StartPosition = 'CenterScreen'

# Ajoutez des cases à cocher pour chaque type de mise à jour
$chkChocolatey = New-Object System.Windows.Forms.CheckBox
$chkChocolatey.Location = New-Object System.Drawing.Point(10, 10)
$chkChocolatey.Size = New-Object System.Drawing.Size(250, 20)
$chkChocolatey.Text = 'Mettre à jour les logiciels Chocolatey'
$form.Controls.Add($chkChocolatey)

$chkWindows = New-Object System.Windows.Forms.CheckBox
$chkWindows.Location = New-Object System.Drawing.Point(10, 40)
$chkWindows.Size = New-Object System.Drawing.Size(250, 20)
$chkWindows.Text = 'Mettre à jour Windows'
$form.Controls.Add($chkWindows)

# Ajoutez des cases à cocher pour chaque type de mise à jour
$chkWinget = New-Object System.Windows.Forms.CheckBox
$chkWinget.Location = New-Object System.Drawing.Point(10, 70)
$chkWinget.Size = New-Object System.Drawing.Size(250, 20)
$chkWinget.Text = 'Mettre à jour les Winget'
$form.Controls.Add($chkWinget)

# Ajoutez un bouton pour démarrer la mise à jour
$btnUpdate = New-Object System.Windows.Forms.Button
$btnUpdate.Location = New-Object System.Drawing.Point(10, 230)
$btnUpdate.Size = New-Object System.Drawing.Size(250, 30)
$btnUpdate.Text = 'Démarrer la mise à jour'
$btnUpdate.Add_Click({
		if ($chkChocolatey.Checked)
		{
			Write-Host "Mise à jour des logiciels Chocolatey..."
			Write-Progress -Activity 'Mise a jour logiciels...' -Status 'En cours...' -PercentComplete 0
			choco upgrade all -y > C:\temp\cocolateyup.txt
			Write-Progress -Activity 'Mise a jour logiciels...' -Status 'Termine.' -PercentComplete 100
			Add-Content -Path "C:\temp\logfile.txt" -Value "Mise à jour de tous les logiciels avec Chocolatey terminée."
		}
		if ($chkWindows.Checked)
		{
			Write-Host "Mise à jour de Windows..."
			
			Get-WindowsUpdate -Install -AcceptAll -AutoReboot
			Add-Content -Path "C:\temp\logfile.txt" -Value "Windows Update ok"
		}
		if ($chkWinget.Checked) # Corrigé ici
		{
			Write-Host "Mise à jour avec Winget..."
			winget upgrade --all # Alternative à Start-Process
			Add-Content -Path "C:\temp\logfile.txt" -Value "Mise à jour de tous les logiciels avec winget terminée."
		}
		$form.Close()
	})
$form.Controls.Add($btnUpdate)

# Affichez le formulaire
$form.ShowDialog()