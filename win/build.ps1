if (!$Env:DIVVUN_KEY) {
    Write-Error "DIVVUN_KEY variable not set"
    exit 1
}
if (!$Env:PFX_PASSWORD) {
    Write-Error "PFX_PASSWORD variable not set"
    exit 1
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
    openssl aes-256-cbc -d -in .\divvun-ci-config\config.txz.enc -pass pass:$Env:DIVVUN_KEY -out config.txz -md md5
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
    InvokeIscc -IssFile "setup.iss" -PfxPath $pfxPath -PfxPassword $Env:PFX_PASSWORD

    exit 0
}
Catch [Exception]
{
    Write-Error $_.Exception.Message
    exit 1
}

