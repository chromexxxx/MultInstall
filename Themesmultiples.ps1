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
		Url	    = "https://github.com/chromexxxx/MultInstall/raw/main/Themes/3d-visual-effects.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/1722/3d-visual-effects.jpg";
	}
	@{
		Name    = "A b s t r a c t i o n Male";
		Url	    = "https://github.com/chromexxxx/MultInstall/raw/main/Themes/A%20b%20s%20t%20r%20a%20c%20t%20i%20o%20n%20Male.themepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/643/abstract-thb.jpg";
	}
	@{
		Name    = "Automne UHD";
		Url	    = "https://github.com/chromexxxx/MultInstall/raw/main/Themes/Automne-uhd-theme.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/2115/tb.jpg";
	}
	@{
		Name    = "Beach Hd";
		Url	    = "https://github.com/chromexxxx/MultInstall/raw/main/Themes/beach-hd-theme.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/416/beach-thb.jpg";
	}
	@{
		Name    = "Japanese Autumn";
		Url	    = "https://github.com/chromexxxx/MultInstall/raw/main/Themes/japanese-autumn.deskthemepack";
		Preview = "https://themepack.me/i/c/357x223/media/g/2157/tb.jpg";
	}
	# Ajoutez d'autres thèmes ici avec leurs aperçus
)

# Créer la fenêtre de dialogue
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sélectionnez un thème'
$form.Size = New-Object System.Drawing.Size(440, 400)
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
	# Récupérer l'URL du thème sélectionné
	$selectedTheme = $themes | Where-Object { $_.Name -eq $comboBox.SelectedItem }
	$url = $selectedTheme.Url
	
	# Le chemin d'accès où vous voulez sauvegarder le thème
	$output = "C:\temp\theme.deskthemepack"
	
	# Télécharger le thème
	Invoke-WebRequest -Uri $url -OutFile $output
	# Définir le chemin du bureau
	$cheminBureau = [Environment]::GetFolderPath("Desktop")
	
	# Le chemin d'accès complet au fichier de thème
	$themePath = "C:\temp\theme.deskthemepack"
	
	# Appliquer le thème
	if ($null -ne $textBox)
	{
		$textBox.AppendText("Application du thème..." + [Environment]::NewLine)
	}
	Invoke-Item $themePath
	
	Add-Content -Path "C:\temp\logfile.txt" -Value "Thème ok"
	if ($null -ne $textBox)
	{
		$textBox.AppendText("Installation du Thème Ok.`r`n")
	}
}

# Nettoyage
$form.Dispose()