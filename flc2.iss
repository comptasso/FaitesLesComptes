; Voir le fichier start.rb pour plus d'info

[Setup]
AppName=Faites Les Comptes
AppVersion=0.7
DefaultDirName="{commondocs}\..\FaitesLesComptes"
DefaultGroupName=Faites Les Comptes
OutputBaseFilename=FaitesLesComptesInstaller


[Languages]
Name: "fr"; MessagesFile: "compiler:Languages\French.isl"


[Files]
Source: "LISEZ-MOI.txt"; DestDir: "{app}"; Flags: isreadme


[Icons]
Name: "{group}\FaitesLesComptes"; Filename: "{app}\FaitesLesComptes.exe"; 
Name: "{group}\D�sinstaller FaitesLesComptes"; Filename: "{uninstallexe}"; 
Name: "{userdesktop}\Faites Les Comptes"; Filename: "{app}\FaitesLesComptes.exe"; Tasks: "desktopicon"
 

[Tasks]
Name: desktopicon; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Run]
Filename: "{app}\FaitesLesComptes.exe"; Description: "Lancer l'application"; Flags: postinstall nowait skipifsilent unchecked

