[Setup]
AppId={#AppId}
AppName={#AppName}
AppVersion=1.0.0
AppPublisher={{Universitetet i Troms� - Norges arktiske universitet}
AppPublisherURL={{http://www.divvun.no/}
CreateAppDir=no
OutputBaseFilename=setup-{#Prefix}-libreoffice
Compression=lzma
SolidCompression=yes
SignedUninstaller=yes
SignTool=signtool
MinVersion=6.3.9200

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: ".\build\{#Prefix}.zhfst"; DestDir: "C:\voikko\3"; Flags: ignoreversion
