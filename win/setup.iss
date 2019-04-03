#define MyAppName "Voikko extension for LibreOffice"
#define MyAppVersion "5.0.0"
#define MyAppPublisher "Universitetet i Troms� - Norges arktiske universitet"
#define MyAppURL "http://www.divvun.no"

[Setup]
AppId={{696A0EC6-5725-4079-9117-40F715DE6D72}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
CreateAppDir=yes
OutputBaseFilename=setup
Compression=lzma
SolidCompression=yes
DefaultDirName={pf}\Voikko Extension for LibreOffice
SignedUninstaller=yes
SignTool=signtool
MinVersion=6.3.9200

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "install_extension.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "uninstall_extension.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\voikko\voikko-5.0.oxt"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\install_extension.bat"; Flags: runhidden

[UninstallRun]
Filename: "{app}\uninstall_extension.bat"; Flags: runhidden
