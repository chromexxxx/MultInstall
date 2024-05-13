﻿Set-ExecutionPolicy Unrestricted -Force -Scope Process

# Installer le module PSWindowsUpdate, si nécessaire
if (!(Get-Module -ListAvailable -Name PSWindowsUpdate))
{
	Write-Host "Installing PSWindowsUpdate Module..."
	Install-Module -Name PSWindowsUpdate -Force -Confirm:$false
}

Write-Host 'Mise a jour logiciels...'

# Vérification de la présence de Curl
if (!(choco list --localonly curl))
{
	Write-Host 'Curl n est pas installe. Installation en cours...'
	choco install curl -y *> C:\temp\curl.txt
	Write-Host 'Installation de Curl terminee.'
	"Installation de Curl terminée." | Out-File -FilePath "C:\temp\logfile.txt" -Append
}
else
{
	Write-Host 'Curl est installe. Mise a jour en cours...'
	choco upgrade curl -y *> C:\temp\curl.txt
	Write-Host 'Mise a jour de Curl terminee.'
	"Mise à jour de Curl terminée." | Out-File -FilePath "C:\temp\logfile.txt" -Append
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

$chkWinget = New-Object System.Windows.Forms.CheckBox
$chkWinget.Location = New-Object System.Drawing.Point(10, 70)
$chkWinget.Size = New-Object System.Drawing.Size(250, 20)
$chkWinget.Text = 'Mettre à jour les logiciels via Winget'
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
			choco upgrade all -y *> C:\temp\cocolateyup.txt
			Write-Progress -Activity 'Mise a jour logiciels...' -Status 'Termine.' -PercentComplete 100
			"Mise à jour de tous les logiciels avec Chocolatey terminée." | Out-File -FilePath "C:\temp\logfile.txt" -Append
		}
		if ($chkWindows.Checked)
		{
			Write-Host "Mise à jour de Windows..."
			Get-WindowsUpdate -Install -AcceptAll -AutoReboot
			"Windows Update ok" | Out-File -FilePath "C:\temp\logfile.txt" -Append
		}
		if ($chkWinget.Checked)
		{
			Write-Host "Mise à jour avec Winget..."
			winget upgrade --all *> C:\temp\wingetup.txt
			"Mise à jour de tous les logiciels avec winget terminée." | Out-File -FilePath "C:\temp\logfile.txt" -Append
		}
		$form.Close()
	})
$form.Controls.Add($btnUpdate)

# Affichez le formulaire
$form.ShowDialog()