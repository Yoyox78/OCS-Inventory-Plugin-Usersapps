
# Effacer la variable xml
Clear-Variable -Name "xml" -ErrorAction SilentlyContinue
# Je crée  une variable xml
$xml = ""
# Je récupère tout les utilisateurs correspondant a ce que je recherche dans le dossier users 
# RegexDeSelectionProfile = mettre une regex a la place de ce mot permettant de séléctionner que les utilisateur AD, ex : martine-aubry, ce qui donne en regex ^\w+\-\w+$
# si vous ne connaissait rien en regex, demander a chatGPT (attention il est loin d'être parfait pour cela)
# Le notlike peut etre enlever car j'avais aussi des user qui correspondait a la nomanclature AD, sauf que c'etait un user local
$Userlocal = (Get-ChildItem -Path C:\Users | where-object {$_.name -match 'RegexDeSelectionProfile' -and $_.name -notlike 'UserAExclure'}).Name
foreach($i in $Userlocal)
{
    # Je récupère le SID de l'utilisateur
    $user = New-Object System.Security.Principal.NTAccount($i) 
    $sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
    
    # Je récupère tous les logiciels présent dans sa partie registre
    $Applocal = (Get-ChildItem -Path "Registry::HKEY_USERS\$($sid.Value)\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Select-Object DisplayName).DisplayName
    if($Applocal -ne "" -or $Applocal -ne $null)
    {
      # J'implémente la variable avec les info pour chaque logiciel
      foreach($y in $Applocal)
      {
          $xml += "<USERSAPPS>`n"
          $xml += "<DATE>$(Get-Date -Format "dd/MM/yyyy_HH:mm")</DATE>`n"
          $xml += "<USER>${i}</USER>`n"
          $xml += "<SOFT>${y}</SOFT>`n"
          $xml += "</USERSAPPS>`n"
      }
    }
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)