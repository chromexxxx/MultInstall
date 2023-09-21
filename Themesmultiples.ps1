# Ajouter les types nécessaires pour l'interface utilisateur
Add-Type -AssemblyName System.Windows.Forms

# Liste des thèmes disponibles
$themes = @(
	@{
		Name    = "Landscape";
		Url	    = "https://stephaninformatique.fr/pws/landscape.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/786/landscape-thb.jpg";
	}
	@{
		Name    = "3d Visual";
		Url	    = "https://stephaninformatique.fr/pws/landscape.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/1722/3d-visual-effects.jpg";
	}
	# Ajoutez d'autres thèmes ici avec leurs aperçus
)

# Créer la fenêtre de dialogue
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sélectionnez un thème'
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = 'CenterScreen'

# Ajouter la liste déroulante (ComboBox) pour la sélection du thème
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = New-Object System.Drawing.Point(30, 30)
$comboBox.Size = New-Object System.Drawing.Size(230, 20)
$themes | ForEach-Object { $comboBox.Items.Add($_.Name) }
$comboBox.Add_SelectedIndexChanged({
		$selectedTheme = $themes | Where-Object { $_.Name -eq $comboBox.SelectedItem }
		$pictureBox.ImageLocation = $selectedTheme.Preview
	})
$form.Controls.Add($comboBox)

# Ajouter PictureBox pour l'aperçu
$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Point(30, 60)
$pictureBox.Size = New-Object System.Drawing.Size(500, 250)
$form.Controls.Add($pictureBox)

# Ajouter le bouton OK
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(30, 320)
$okButton.Size = New-Object System.Drawing.Size(75, 23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton

# Afficher la fenêtre de dialogue
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
	# ... Votre code pour télécharger et appliquer le thème choisi ...
}

# Nettoyage
$form.Dispose()
