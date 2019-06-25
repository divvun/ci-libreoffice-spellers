# LibreOffice Spellers

[![Build Status](https://dev.azure.com/divvun/libreoffice/_apis/build/status/divvun.ci-libreoffice-spellers?branchName=master)](https://dev.azure.com/divvun/libreoffice/_build/latest?definitionId=1&branchName=master)

This repository contains scripts for building the libreoffice voikko extension for windows and macOS.

## Source
[https://gtsvn.uit.no/langtech/trunk/giella-libs/LibreOffice-voikko/5.0](https://gtsvn.uit.no/langtech/trunk/giella-libs/LibreOffice-voikko/5.0)

## Windows

### Requirements
* Powershell
* InnoSetup unicode

```powershell
# build by setting the following environment variables
# to their respective values and then run the build 
# script in the win folder
$Env:DIVVUN_KEY = ".."
$Env:PFX_PASSWORD = ".."
cd win
build.ps1
```

## macOS
The easiest way is to install the XCode developer tools installed.

### Requirements
* pkgutil
* pkgbuild
* productbuild
* productsign

```sh
# build by setting the following environment variables
# to their respective values and then run the build 
# script in the macos folder
export DIVVUN_KEY=".."
cd macos
sh build.sh
```
