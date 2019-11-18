; PortableApps.com Installer: Custom.nsh

!macro CustomCodePreInstall
!macroend

!macro CustomCodePostInstall
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

