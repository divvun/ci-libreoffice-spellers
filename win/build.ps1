if (!$Env:DIVVUN_KEY) {
    Write-Error "DIVVUN_KEY variable not set"
    exit 1
}
if (!$Env:PFX_PASSWORD) {
    Write-Error "PFX_PASSWORD variable not set"
    exit 1
}
function DownloadSpeller {
    param (
        $From,
        $Match,
        $OutFile    
    )

    New-Item -Path .\build\tmp-download -ItemType directory
    Set-Location .\build\tmp-download

    # list files using the $From url and
    # match the file we want to download using $Match
    $request = Invoke-WebRequest $From
    $filename = $request.ParsedHtml.getElementsByTagName("a") | Where-Object { $_.innerHTML -match $Match } | Select-Object -ExpandProperty innerHTML
    $fileurl = "$From/$filename"

    Invoke-WebRequest $fileurl -OutFile intermediate.deb
    
    Get-ChildItem ".\" -Filter *.deb | Foreach-Object {
        New-Item tmp -ItemType Directory
        Set-Location tmp
        7z x $_.FullName
        if ($LastExitCode -ne 0) { throw }
        tar xf .\data.tar
        if ($LastExitCode -ne 0) { throw }
        Get-ChildItem ".\usr\share\giella\mobilespellers\*" -Filter *.zhfst | Foreach-Object {
            Move-Item $_.FullName ..\..\$OutFile
        }
        Set-Location ..
        Remove-Item -Force -Recurse -ErrorAction Ignore tmp
    }

    Set-Location ..
    Remove-Item -Force -Recurse -ErrorAction Ignore tmp-download
    Set-Location ..
}

function InvokeIscc {
    param (
        $IssFile,
        $PfxPath,
        $PfxPassword
    )

    $isccPath = "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
    $signToolArg = '/S"signtool=C:\Program Files (x86)\Microsoft SDKs\ClickOnce\SignTool\signtool.exe sign /t http://timestamp.verisign.com/scripts/timstamp.dll /f ' + $PfxPath + ' /p ' + $PfxPassword + ' $f"'
    $isccArgs = @('/Qp', '/O.\build\output', $signToolArg, $IssFile)
    Write-Output $isccArgs
    $process = Start-Process -FilePath $isccPath -ArgumentList $isccArgs -PassThru -Wait -NoNewWindow
    if ($process.ExitCode -ne 0) { throw }   
}

Try
{
    $ErrorActionPreference = "Stop"

    # remove any left-overs in the build directory
    # and then create a fresh one
    Remove-Item -Force -Recurse -ErrorAction Ignore build
    New-Item -Path build -ItemType directory
    Set-Location build

    git clone -q https://github.com/divvun/divvun-ci-config
    if ($LastExitCode -ne 0) { throw }
    openssl aes-256-cbc -d -in .\divvun-ci-config\config.txz.enc -pass pass:$Env:DIVVUN_KEY -out config.txz
    if ($LastExitCode -ne 0) { throw }
    7z e config.txz
    if ($LastExitCode -ne 0) { throw }
    tar xf config.tar
    if ($LastExitCode -ne 0) { throw }
    New-Item -Path voikko -ItemType directory
    Set-Location voikko
    svn checkout https://gtsvn.uit.no/langtech/trunk/giella-libs/LibreOffice-voikko/5.0
    if ($LastExitCode -ne 0) { throw }
    7z a -tzip voikko-5.0.oxt .\5.0\*
    if ($LastExitCode -ne 0) { throw }
    Set-Location ..\..

    $pfxPath = $(Get-Location).Path + "\build\enc\creds\windows\divvun.pfx"
    Write-Output $pfxPath
    Write-Output "Packaging voikko extension"
    InvokeIscc -IssFile "setup.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    Write-Output "Packaging se speller"
    DownloadSpeller -From "https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sme" -Match "^giella-sme_.*\.deb$" -OutFile "se.zhfst"
    InvokeIscc -IssFile "se.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    Write-Output "Packaging sma speller"
    DownloadSpeller -From "https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sma" -Match "^giella-sma_.*\.deb$" -OutFile "sma.zhfst"
    InvokeIscc -IssFile "sma.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    Write-Output "Packaging smj speller"
    DownloadSpeller -From "https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-smj" -Match "^giella-smj_.*\.deb$" -OutFile "smj.zhfst"
    InvokeIscc -IssFile "smj.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    Write-Output "Packaging smn speller"
    DownloadSpeller -From "https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-smn" -Match "^giella-smn_.*\.deb$" -OutFile "smn.zhfst"
    InvokeIscc -IssFile "smn.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    Write-Output "Packaging sms speller"
    DownloadSpeller -From "https://apertium.projectjj.com/apt/nightly/pool/main/g/giella-sms" -Match "^giella-sms_.*\.deb$" -OutFile "sms.zhfst"
    InvokeIscc -IssFile "sms.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    exit 0
}
Catch [Exception]
{
    Write-Error $_.Exception.Message
    exit 1
}

