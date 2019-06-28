::Default values
set version="0.0.0"
set update_channel=windows
set arch=x86

if not "%1"=="" (
	set version=%1
)
if not "%2"=="" (
	set update_channel=%2
)
if not "%3"=="" (
	set arch=%3
)

if not exist BatchSubstitute.bat (
	echo "This script requires BatchSubstitute.bat"
	pause
	exit
)

where /q candle || ECHO Cound not find candle.exe from wix. Needs to be in your PATH. && EXIT /B
where /q light || ECHO Cound not find light.exe from wix. Needs to be in your PATH. && EXIT /B

::Strip all binaries
cd bin
echo "Stripping binaries..."
strip --strip-unneeded screencloud.exe
cd ..
::Set the version number in the wix file
copy wix\ScreenCloud.wxs wix\ScreenCloud.wxs.backup
CALL BatchSubstitute.bat "VERSIONNUMBERNOTSET" %version% wix\ScreenCloud.wxs 1> wix\ScreenCloud.wxs.temp
move wix\ScreenCloud.wxs.temp wix\ScreenCloud.wxs
cd wix
::Use heat to include directories
heat dir ..\DLLs -o DLLs.wxs -scom -frag -srd -sreg -gg -cg PY_DLLS -dr PY_DLLS -var var.PDSourceDir
heat dir ..\modules -o modules.wxs -scom -frag -srd -sreg -gg -cg PY_MODULES -dr PY_MODULES -var var.PMSourceDir
::Build installer
candle.exe ScreenCloud.wxs DLLs.wxs modules.wxs -dPDSourceDir=..\DLLs -dPMSourceDir=..\modules -ext WixUIExtension -ext WixUtilExtension
light.exe ScreenCloud.wixobj DLLs.wixobj modules.wixobj -o ScreenCloud.msi -ext WixUIExtension -ext WixUtilExtension
cd ..
::Unset the version number
CALL BatchSubstitute.bat "%version%" VERSIONNUMBERNOTSET wix\ScreenCloud.wxs 1> wix\ScreenCloud.wxs.temp
move wix\ScreenCloud.wxs.temp wix\ScreenCloud.wxs

mkdir installers\%update_channel%\%version%
copy wix\ScreenCloud.msi installers\%update_channel%\%version%\ScreenCloud-%version%-%arch%.msi
copy wix\ScreenCloud.msi ScreenCloud-%version%-%arch%.msi
echo "Finished building installer"
exit
