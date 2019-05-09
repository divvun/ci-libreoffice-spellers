$ErrorActionPreference = "Stop"

if (!$Env:DEPLOY_VERSION_VOIKKO) {
    Write-Error "DEPLOY_VERSION_VOIKKO variable not set"
    exit 1
}
if (!$Env:DEPLOY_VERSION_SPELLER_SE) {
    Write-Error "DEPLOY_VERSION_SPELLER_SE variable not set"
    exit 1
}
if (!$Env:DEPLOY_VERSION_SPELLER_SMA) {
    Write-Error "DEPLOY_VERSION_SPELLER_SMA variable not set"
    exit 1
}
if (!$Env:DEPLOY_VERSION_SPELLER_SMJ) {
    Write-Error "DEPLOY_VERSION_SPELLER_SMJ variable not set"
    exit 1
}
if (!$Env:DEPLOY_VERSION_SPELLER_SMN) {
    Write-Error "DEPLOY_VERSION_SPELLER_SMN variable not set"
    exit 1
}
if (!$Env:DEPLOY_VERSION_SPELLER_SMS) {
    Write-Error "DEPLOY_VERSION_SPELLER_SMS variable not set"
    exit 1
}
if (!$Env:PAHKAT_REPO_NAME) {
    Write-Error "PAHKAT_REPO_NAME variable not set"
    exit 1
}
if (!$Env:BRANCH) {
    Write-Error "BRANCH variable not set"
    exit 1
}
if (!$Env:DEPLOY_SVN_URL) {
    Write-Error "DEPLOY_SVN_URL variable not set"
    exit 1
}
if (!$Env:DEPLOY_SVN_USER) {
    Write-Error "DEPLOY_SVN_USER variable not set"
    exit 1
}
if (!$Env:DEPLOY_SVN_PASSWORD) {
    Write-Error "DEPLOY_SVN_PASSWORD variable not set"
    exit 1
}

function SvnAddOrUpdate {
    param (
        $Artifact,
        $Version,
        $Package,
        $Template
    )

    $deployAs = "$Package-$((Get-Date).ToUniversalTime().ToString('yyyyMMddTHHmmssZ')).exe"

    # make sure artifact exists
    if (-not (Test-Path $Artifact)) { throw }

    # determine if the application binary has already 
    # been added to version control, then do add or up
    $ErrorActionPreference = "Continue"
    svn info .\artifacts\$deployAs
    $ErrorActionPreference = "Stop"

    if ($LastExitCode -eq 0) {
        svn up .\artifacts\$deployAs
        if ($LastExitCode -ne 0) { throw }
        Copy-Item $Artifact .\artifacts\$deployAs
    }
    else {
        Copy-Item $Artifact .\artifacts\$deployAs
        svn add .\artifacts\$deployAs
        if ($LastExitCode -ne 0) { throw }
    }

    # update the pahkat package description
    $fileSize = (Get-Item ".\artifacts\$deployAs").length
    $template = Get-Content $Template -Raw
    $template = $template -replace "DEPLOY_VERSION", $Version
    $template = $template -replace "DEPLOY_SVN_URL", $Env:DEPLOY_SVN_URL
    $template = $template -replace "DEPLOY_FILE_NAME", $deployAs
    $template = $template -replace "DEPLOY_FILE_SIZE", $fileSize

    # write updated package description to repo
    $utf8 = New-Object System.Text.UTF8Encoding $false
    Set-Content -Value $utf8.GetBytes($template) -Encoding Byte -Path ".\packages\$Package\index.json"
}

function SvnCommit {
    param ()
    
    if ($LastExitCode -ne 0) { throw }
    svn status
    if ($LastExitCode -ne 0) { throw }

    if ($Env:DEPLOY_SVN_COMMIT) {
        svn commit -m "Automated Deploy to $Env:PAHKAT_REPO_NAME: libreoffice spellers" --username=$Env:DEPLOY_SVN_USER --password=$Env:DEPLOY_SVN_PASSWORD
        if ($LastExitCode -ne 0) { throw }
    }
    else {
        Write-Host "Warning: DEPLOY_SVN_COMMIT not set, ie. changes to repo will not be committed"
    }
}

Try
{
    # determine the current version of the pahkat client
    $intermediateRepo = ".\build\deploy-repo"

    # remove intermediate repo
    Remove-Item -Force -Recurse -ErrorAction Ignore $intermediateRepo

    # checkout the svn repo to use for deployment
    svn checkout --depth immediates $Env:DEPLOY_SVN_URL $intermediateRepo
    if ($LastExitCode -ne 0) { throw }
    Set-Location $intermediateRepo
    svn up packages --set-depth=infinity
    if ($LastExitCode -ne 0) { throw }
    svn up virtuals --set-depth=infinity
    if ($LastExitCode -ne 0) { throw }
    svn up index.json
    if ($LastExitCode -ne 0) { throw }

    SvnAddOrUpdate -Artifact "..\output\setup.exe" -Version $Env:DEPLOY_VERSION_VOIKKO -Package "libreoffice-voikko" -Template "..\..\pahkat-template.json"
    SvnAddOrUpdate -Artifact "..\output\setup-se-libreoffice.exe" -Version $Env:DEPLOY_VERSION_SPELLER_SE -Package "libreoffice-speller-se" -Template "..\..\pahkat-template-se.json"
    SvnAddOrUpdate -Artifact "..\output\setup-sma-libreoffice.exe" -Version $Env:DEPLOY_VERSION_SPELLER_SMA -Package "libreoffice-speller-sma" -Template "..\..\pahkat-template-sma.json"
    SvnAddOrUpdate -Artifact "..\output\setup-smj-libreoffice.exe" -Version $Env:DEPLOY_VERSION_SPELLER_SMJ -Package "libreoffice-speller-smj" -Template "..\..\pahkat-template-smj.json"
    SvnAddOrUpdate -Artifact "..\output\setup-smn-libreoffice.exe" -Version $Env:DEPLOY_VERSION_SPELLER_SMN -Package "libreoffice-speller-smn" -Template "..\..\pahkat-template-smn.json"
    SvnAddOrUpdate -Artifact "..\output\setup-sms-libreoffice.exe" -Version $Env:DEPLOY_VERSION_SPELLER_SMS -Package "libreoffice-speller-sms" -Template "..\..\pahkat-template-sms.json"

    # re-index using pahkat
    $ErrorActionPreference = "Continue"
    pahkat repo index
    $ErrorActionPreference = "Stop"

    SvnCommit

    Set-Location ..\..

    exit 0
}
Catch [Exception]
{
    Write-Error $_.Exception.Message
    exit 1
}
