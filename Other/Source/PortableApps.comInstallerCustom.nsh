; PortableApps.com Installer: Custom.nsh

!macro CustomCodePreInstall
!macroend

!macro CustomCodePostInstall
	execDos::exec `"$INSTDIR\App\_bin\lzma.exe" d "$INSTDIR\App\Minecraft\launcher.pack.lzma" "$INSTDIR\App\Minecraft\launcher.pack"` "" ""
	Pop $R0
	execDos::exec `"$INSTDIR\App\_bin\unpack200.exe" -r -q "$INSTDIR\App\Minecraft\launcher.pack" "$INSTDIR\App\Minecraft\launcher.jar"` "" ""
	Pop $R0
	; Check for settings
	${IfNot} ${FileExists} `$INSTDIR\Data\settings`
		CreateDirectory `$INSTDIR\Data\settings`
		${If} ${FileExists} `$INSTDIR\App\DefaultData\*.*`
			CopyFiles /SILENT `$INSTDIR\App\DefaultData\*.*` `$INSTDIR\Data`
		${EndIf}
	${EndIf}
!macroend

!macro CustomCodeOptionalCleanup
!macroend

