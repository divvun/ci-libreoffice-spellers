set LO_UNO_PATH=C:\Program Files\LibreOffice\program
set LO_REG_KEY=HKLM\SOFTWARE\LibreOffice\UNO\InstallPath

for /f "tokens=1-2,*" %%a in ('REG QUERY %LO_REG_KEY% /ve') do (
    set LO_REG_KEY=%%c
)

"%LO_UNO_PATH%\unopkg.exe" add voikko-5.0.oxt || exit /b 1
