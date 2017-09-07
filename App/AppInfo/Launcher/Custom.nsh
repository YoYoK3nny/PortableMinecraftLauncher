${SegmentFile}

!addplugindir "${PACKAGE}\App\AppInfo\Launcher\Plugins"
!include "${PACKAGE}\App\AppInfo\Launcher\PortableApps.comLauncherLANG.nsh"

;################
;## START CODE ##
;################

Var /GLOBAL bAutoUpdate

!define custom_LocalFile "launcher.pack.lzma"
!define custom_PackFile "launcher.pack"
!define custom_JarFile "launcher.jar"
!define custom_RemoteFile "http://s3.amazonaws.com/Minecraft.Download/launcher/launcher.pack.lzma"
!define custom_UpdateHeader "$PLUGINSDIR\header.txt"

Function custom_CheckForProgram
	; Make sure the program is there

	${IfNot} ${FileExists} "$EXEDIR\App\Minecraft\${custom_LocalFile}"
		Call custom_DownloadUpdate
		${If} $R0 != "OK"
			StrCpy $1 "${custom_RemoteFile}"
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherDownloadFailed)`
			Abort
		${Else}
			Call custom_ApplyUpdate
		${EndIf}
	${Else}
		Call custom_CheckForUpdate
	${EndIf}

	${If} ${FileExists} "$EXEDIR\App\Minecraft\${custom_LocalFile}"
	${AndIfNot} ${FileExists} "$EXEDIR\App\Minecraft\${custom_JarFile}"
		Call custom_ApplyUpdate
	${EndIf}
FunctionEnd

Function custom_CheckForUpdate
	; Check for update

	inetc::head /silent "${custom_RemoteFile}" "${custom_UpdateHeader}"
	Pop $R0
	${If} $R0 != "OK"
		StrCpy $1 "remote-file header"
		MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherDownloadFailed)`
		Abort
	${EndIf}

	CallAnsiPlugin::Call "$PLUGINSDIR\unicode.dll" FileUnicode2UTF8 3 "${custom_UpdateHeader}" "${custom_UpdateHeader}" "UTF-16LE"
	Pop $0

	${LineFind} "${custom_UpdateHeader}" "/NUL" "" "custom_ParseLine"
	Delete "${custom_UpdateHeader}"
	md5dll::GetMD5File "$EXEDIR\App\Minecraft\${custom_LocalFile}"
	Pop $0
	
	${If} "$0" != "$R2"
		StrCmp "$bAutoUpdate" "true" custom_Updater_noprompt
			MessageBox MB_YESNO "$(LauncherUpdateAvailable)" IDYES 0 IDNO custom_Updater_false
		custom_Updater_noprompt:
		Call custom_DownloadUpdate
		${If} $R0 != "OK"
			StrCpy $1 "${custom_RemoteFile}"
			MessageBox MB_OK|MB_ICONEXCLAMATION `$(LauncherDownloadFailed)`
			Abort
		${Else}
			Call custom_ApplyUpdate
		${EndIf}
		Goto custom_Updater_done
		custom_Updater_false:
			MessageBox MB_OK|MB_ICONEXCLAMATION "$(LauncherUpdateIgnored)"
		custom_Updater_done:
	${EndIf}

FunctionEnd

Function custom_DownloadUpdate
	; Download the update

	inetc::get /silent /nocancel "${custom_RemoteFile}" "$EXEDIR\App\Minecraft\${custom_LocalFile}" /end
	Pop $R0

FunctionEnd

Function custom_ApplyUpdate
	; Unpack the update

	execDos::exec `"$EXEDIR\App\_bin\lzma.exe" d "$EXEDIR\App\Minecraft\${custom_LocalFile}" "$EXEDIR\App\Minecraft\${custom_PackFile}"` "" ""
	Pop $R0
	execDos::exec `"$EXEDIR\App\_bin\unpack200.exe" -r -q "$EXEDIR\App\Minecraft\${custom_PackFile}" "$EXEDIR\App\Minecraft\${custom_JarFile}"` "" ""
	Pop $R0

FunctionEnd

Function custom_ParseLine
	; $R9       current line
	; $R8       current line number
	; $R7       current line negative number
	; $R6       current range of lines
	; $R5       handle of a file opened to read
	; $R4       handle of a file opened to write ($R4="" if "/NUL")

	; you can use any string functions
	; $R0-$R3  are not used (save data in them).

	${TrimNewLines} '$R9' $R1
	StrCpy $R0 $R1 4
	StrCmp "$R0" "ETag" 0 +4
		StrCpy $0 StopLineFind
		StrCpy $R2 "$R1" -1 7
		Goto +2
		StrCpy $0 SkipWrite

	Push $0		; If $var="StopLineFind"  Then exit from function
				; If $var="SkipWrite"     Then skip current line (ignored if "/NUL")
FunctionEnd

;################
;### END CODE ###
;################

${SegmentInit}
	File "/ONAME=$PLUGINSDIR\unicode.dll" "${PACKAGE}\App\AppInfo\Launcher\Plugins\unicode.dll"

	${ReadUserConfig} $bAutoUpdate AutoUpdate

	Call custom_CheckForProgram
!macroend
