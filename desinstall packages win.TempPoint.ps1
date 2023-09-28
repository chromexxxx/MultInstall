Add-Type -AssemblyName System.Windows.Forms

# Création du formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Désinstaller des Applications'
$form.Size = New-Object System.Drawing.Size(500, 400)

# Création de la ListBox
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 10)
$listBox.Size = New-Object System.Drawing.Size(460, 300)

# Récupération et ajout des applications à la ListBox
$apps = Get-AppxPackage | Select-Object -Property Name, PackageFullName
foreach ($app in $apps)
{
	$listBox.Items.Add("$($app.Name) - $($app.PackageFullName)")
}

$form.Controls.Add($listBox)

# Création du bouton de désinstallation
$button = New-Object System.Windows.Forms.Button
$button.Location = New-Object System.Drawing.Point(10, 320)
$button.Size = New-Object System.Drawing.Size(460, 30)
$button.Text = 'Désinstaller l`'application sélectionnée'

# Action lors du clic sur le bouton
$button.Add_Click({
    $selectedItem = $listBox.SelectedItem
    if ($null -ne $selectedItem) {
        $packageName = ($selectedItem -split ' - ')[1]
        Get-AppxPackage -Name $packageName | Remove-AppxPackage
        [System.Windows.Forms.MessageBox]::Show("Application `$($selectedItem -split ' - ')[0]` désinstallée")
    }
})

$form.Controls.Add($button)

# Affichage du formulaire
$form.ShowDialog()
