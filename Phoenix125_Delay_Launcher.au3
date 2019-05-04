#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\phoenix.ico
#AutoIt3Wrapper_Outfile=Builds\Phoenix125_Delay_Launcher.exe
#AutoIt3Wrapper_Outfile_x64=Builds\Phoenix125_Delay_Launcher(x64).exe
#AutoIt3Wrapper_Compile_Both=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=By Phoenix125
#AutoIt3Wrapper_Res_Description=Phoenix125_Delay_Launcher
#AutoIt3Wrapper_Res_Fileversion=1.1.0.0
#AutoIt3Wrapper_Res_ProductName=AtlasServerUpdateUtility
#AutoIt3Wrapper_Res_ProductVersion=v1.1.0
#AutoIt3Wrapper_Res_CompanyName=http://www.Phoenix125.com
#AutoIt3Wrapper_Res_LegalCopyright=http://www.Phoenix125.com
#AutoIt3Wrapper_Run_AU3Check=n
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/mo
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <MsgBoxConstants.au3>
#include <Date.au3>
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Global $aUtilName = "Phoenix125_Delay_Launcher"
Global $aUtilityVer = "v1.1.0"
Global $aLogFile = $aUtilName & ".log"
Global $aIniFile = @ScriptDir & "\" & $aUtilName & ".ini"
Global $aIniHeaderMain = " --------------- " & StringUpper($aUtilName) & " --------------- "
Global $aIniEntriesCountLine = "Number of programs (If changed, util will restart and new custom entries will be added)"
Global $aIniRequireTaskKillLine = "Require task kill to exit / cancel this utility? (yes/no)"
Global $aIniWaitForInternetLine = "Wait for internet connection before starting first program? (yes/no)"
Global $aIniMaxWaitTimeLine = "Maximum time to wait for internet before starting programs even if no internet (seconds, 0 to wait infinitely)"
Global $aIniShowStatusWindowLine = "Show status window? (yes/no)"
Global $aIniCheckForRedisLine = "Keep reruning first program every 10 seconds until Redis-Server is confirmed to be running? (yes/no)"
Global $aIniSystemUse = "System use only. Do not change"
Global $iIniEntriesChanged = False

LogWrite("---------------- " & $aUtilName & " Started ----------------")
If Not FileExists($aIniFile) Then NoIniExist(True)
LogWrite("Reading Ini file.")
ReadUini()
If $aRequireTaskKillYN = "yes" Then Opt("TrayMenuMode", 1)

Global $aStartText = "Starting programs." & @CRLF & @CRLF
If $aShowStatusWindowYN = "yes" Then Global $aSplashStartUp = SplashTextOn($aUtilName, $aStartText, 475, 140, -1, -1, $DLG_MOVEABLE, "")

If $aWaitForInternetYN = "yes" Then
	LogWrite("Waiting for internet connection.")
	Local $i = 0
	Local $aStopLoop = False
	Do
		$i += 1
		ControlSetText($aSplashStartUp, "", "Static1", $aStartText & "Waiting for internet connection." & @CRLF & $i)
		If $aMaxWaitTime > 0 Then
			If $i = $aMaxWaitTime Then $aStopLoop = True
		EndIf
		Sleep(1000)
		$aIsInternetConnected = _IsInternetConnected()
	Until $aStopLoop Or $aIsInternetConnected
	If $aIsInternetConnected Then LogWrite("Internet connected after " & $i & " seconds.")
	If $aStopLoop Then LogWrite("NOTICE! Internet did not connect within " & $aMaxWaitTime & " seconds.")
EndIf

For $x = 0 To ($aEntriesCount - 1)
	LogWrite("Waiting " & $xDelay[$x] & " seconds.")
	For $i = 1 To $xDelay[$x]
		ControlSetText($aSplashStartUp, "", "Static1", $aStartText & "Starting " & @CRLF & $xFile[$x] & @CRLF & " in " & ($xDelay[$x] - $i + 1) & " seconds.")
		Sleep(1000)
	Next
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($xFile[$x], $sDrive, $sDir, $sFileName, $sExtension)
	LogWrite("Starting program: " & $xFile[$x])
	Run($xFile[$x], $aPathSplit[1] & $aPathSplit[2])
Next

If $aShowStatusWindowYN = "yes" Then
	ControlSetText($aSplashStartUp, "", "Static1", $aStartText & "All programs started.")
	LogWrite("All programs started. ")
	Sleep(3000)
	SplashOff()
EndIf

Func NoIniExist($tRestart = True)
	Local $aWidth = 400
	Local $aHeight = 150
	Local $aTotalQuestionCount = 5
	Local $i = 0
	$i += 1
	Global $aEntriesCount = InputBox("Welcome to " & $aUtilName, "Question " & $i & " of " & $aTotalQuestionCount & @CRLF & "Please enter the number of programs you wish to start with this utility:", "2", "", $aWidth, $aHeight)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniEntriesCountLine, $aEntriesCount)
	$i += 1
	Global $aWaitForInternetYN = InputBox("Welcome to " & $aUtilName, "Question " & $i & " of " & $aTotalQuestionCount & @CRLF & $aIniRequireTaskKillLine, "no", "", $aWidth, $aHeight)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniRequireTaskKillLine, $aWaitForInternetYN)
	$i += 1
	Global $aRequireTaskKillYN = InputBox("Welcome to " & $aUtilName, "Question " & $i & " of " & $aTotalQuestionCount & @CRLF & $aIniWaitForInternetLine, "no", "", $aWidth, $aHeight)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniWaitForInternetLine, $aRequireTaskKillYN)
	$i += 1
	Global $aMaxWaitTime = InputBox("Welcome to " & $aUtilName, "Question " & $i & " of " & $aTotalQuestionCount & @CRLF & $aIniMaxWaitTimeLine, "120", "", $aWidth, $aHeight)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniMaxWaitTimeLine, $aMaxWaitTime)
	$i += 1
	Global $aShowStatusWindowYN = InputBox("Welcome to " & $aUtilName, "Question " & $i & " of " & $aTotalQuestionCount & @CRLF & $aIniShowStatusWindowLine, "yes", "", $aWidth, $aHeight)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniShowStatusWindowLine, $aShowStatusWindowYN)
	MsgBox($MB_OK, $aUtilName, "Restarting to implement changes.", 2)
	If $tRestart Then _RestartProgram()
EndFunc   ;==>NoIniExist

Func ReadUini()
	Global $iIniError = ""
	Global $iIniFail = 0
	$iIniRead = True
	Local $iniCheck = ""
	Local $aChar[3]
	For $i = 1 To 13
		$aChar[0] = Chr(Random(97, 122, 1)) ;a-z
		$aChar[1] = Chr(Random(48, 57, 1)) ;0-9
		$iniCheck &= $aChar[Random(0, 1, 1)]
	Next
	Global $aRequireTaskKillYN = IniRead($aIniFile, $aIniHeaderMain, $aIniRequireTaskKillLine, $iniCheck)
	Global $aEntriesCount = IniRead($aIniFile, $aIniHeaderMain, $aIniEntriesCountLine, $iniCheck)
	Global $aWaitForInternetYN = IniRead($aIniFile, $aIniHeaderMain, $aIniWaitForInternetLine, $iniCheck)
	Global $aMaxWaitTime = IniRead($aIniFile, $aIniHeaderMain, $aIniMaxWaitTimeLine, $iniCheck)
	Global $aShowStatusWindowYN = IniRead($aIniFile, $aIniHeaderMain, $aIniShowStatusWindowLine, $iniCheck)
	Global $aShowConfigTF = IniRead($aIniFile, $aIniHeaderMain, $aIniSystemUse, $iniCheck)
	Global $xDelay[$aEntriesCount], $xFile[$aEntriesCount]
	For $i = 0 To ($aEntriesCount - 1)
		$xDelay[$i] = IniRead($aIniFile, $aIniHeaderMain, ($i + 1) & "-Delay (seconds) ###", $iniCheck)
		$xFile[$i] = IniRead($aIniFile, $aIniHeaderMain, ($i + 1) & "-File ###", $iniCheck)
	Next
	If $iniCheck = $aEntriesCount Then
		$aEntriesCount = "1"
		$iIniFail += 1
		$iIniEntriesChanged = True
		$iIniError = $iIniError & "EntriesCount, "
	EndIf
	For $i = 0 To ($aEntriesCount - 1)
		If $iniCheck = $xDelay[$i] Then
			$xDelay[$i] = "30"
			$iIniFail += 1
			$iIniError = $iIniError & "Delay " & $i & ", "
		EndIf
		If $iniCheck = $xFile[$i] Then
			$xFile[$i] = @ScriptDir
			$iIniFail += 1
			$iIniError = $iIniError & "File " & $i & ", "
		EndIf
	Next
	If $iniCheck = $aRequireTaskKillYN Then
		$aRequireTaskKillYN = "no"
		$iIniFail += 1
		$iIniError = $iIniError & "RequireTaskKillYN, "
	EndIf
	If $iniCheck = $aWaitForInternetYN Then
		$aWaitForInternetYN = "no"
		$iIniFail += 1
		$iIniError = $iIniError & "WaitForInternetYN, "
	EndIf
	If $iniCheck = $aMaxWaitTime Then
		$aMaxWaitTime = "120"
		$iIniFail += 1
		$iIniError = $iIniError & "MaxWaitTime, "
	EndIf
	If $iniCheck = $aShowStatusWindowYN Then
		$aShowStatusWindowYN = "yes"
		$iIniFail += 1
		$iIniError = $iIniError & "ShowStatusWindowYN, "
	EndIf
	If $iniCheck = $aShowConfigTF Then
		$aShowConfigTF = True
		$iIniFail += 1
		$iIniError = $iIniError & "ShowConfigTF, "
	EndIf
	If $iIniEntriesChanged Then
		MsgBox($MB_OK, $aUtilName, "The number of entries changed. Restarting . . .", 3)
		IniWrite($aIniFile, $aIniHeaderMain, $aIniSystemUse, False)
		_RestartProgram()
	EndIf
	If $iIniFail > 0 Then
		IniFileFail()
		Local $tIniFail = True
	EndIf
EndFunc   ;==>ReadUini

Func IniFileFail()
	UpdateIni(False)
	MsgBox($MB_OK, $aUtilName, "Config file changed. Restarting setup wizard.")
	If $aShowConfigTF Then
		IniWrite($aIniFile, $aIniHeaderMain, $aIniSystemUse, True)
		NoIniExist(False)
	EndIf
	Local $aWidth = 400
	Local $aHeight = 165
	For $i = 0 To ($aEntriesCount - 1)
		Global $aDone = False
		#Region ### START Koda GUI section ### Form=
		Local $Form1 = GUICreate($aUtilName, 720, 120, -1, -1)
		Local $tInputSelectFile = GUICtrlCreateInput($xFile[$i], 8, 40, 617, 21)
		Local $tLabelSelectFile = GUICtrlCreateLabel("Entry " & ($i + 1) & " of " & $aEntriesCount & " - File to execute:", 8, 16, 200, 17)
		Local $tButtonSelectFile = GUICtrlCreateButton("Select File", 632, 40, 75, 25)
		Local $tButtonNext = GUICtrlCreateButton("Next", 8, 72, 75, 25)
		GUISetState(@SW_SHOW)
		#EndRegion ### END Koda GUI section ###

		Do
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $GUI_EVENT_CLOSE
					Exit
;~ 				Case $tInputSelectFile
				Case $tButtonSelectFile
					Global $tSourceFile = FileOpenDialog("Please select program to execute", $xFile[$i], "All (*.*)", 3, "")
					If @error Then
						GUICtrlSetData($tInputSelectFile, $xFile[$i])
					Else
						GUICtrlSetData($tInputSelectFile, $tSourceFile)
					EndIf
				Case $tButtonNext
					$xFile[$i] = GUICtrlRead($tInputSelectFile)
					GUIDelete($Form1)
					$aDone = True
			EndSwitch
			Sleep(50)
		Until $aDone = True
		IniWrite($aIniFile, $aIniHeaderMain, ($i + 1) & "-File ###", $xFile[$i])
		$xDelay[$i] = InputBox($aUtilName, "Entry " & ($i + 1) & " of " & $aEntriesCount & @CRLF & "Delay before executing " & @CRLF & $xFile[$i], $xDelay[$i], "", $aWidth, $aHeight)
		IniWrite($aIniFile, $aIniHeaderMain, ($i + 1) & "-Delay (seconds) ###", $xDelay[$i])
	Next
	UpdateIni(True)
	SplashOff()
	Run("notepad.exe " & $aIniFile)
	MsgBox($MB_OK, $aUtilName, "Setup Complete.")
	Exit
EndFunc   ;==>IniFileFail

Func UpdateIni($aMakeBackupTF = True)
	If $aMakeBackupTF Then
		Local $aMyDate, $aMyTime
		_DateTimeSplit(_NowCalc(), $aMyDate, $aMyTime)
		Local $iniDate = StringFormat("%04i_%02i_%02i_%02i%02i", $aMyDate[1], $aMyDate[2], $aMyDate[3], $aMyTime[1], $aMyTime[2])
		FileMove($aIniFile, $aIniFile & "_" & $iniDate & ".bak", 1)
	Else
		If FileExists($aIniFile) Then FileDelete($aIniFile)
	EndIf

	FileWriteLine($aIniFile, "[ --------------- " & StringUpper($aUtilName) & " INFORMATION --------------- ]")
	FileWriteLine($aIniFile, "Author   :  Phoenix125")
	FileWriteLine($aIniFile, "Version  :  " & $aUtilityVer)
	FileWriteLine($aIniFile, "Website  :  http://www.Phoenix125.com")
	FileWriteLine($aIniFile, "Discord  :  http://discord.gg/EU7pzPs")
	FileWriteLine($aIniFile, "Forum    :  https://phoenix125.createaforum.com/index.php")
	FileWriteLine($aIniFile, @CRLF)
	FileWriteLine($aIniFile, "[" & $aIniHeaderMain & "]")
	IniWrite($aIniFile, $aIniHeaderMain, $aIniRequireTaskKillLine, $aRequireTaskKillYN)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniWaitForInternetLine, $aWaitForInternetYN)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniMaxWaitTimeLine, $aMaxWaitTime)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniShowStatusWindowLine, $aShowStatusWindowYN)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniSystemUse, $aShowConfigTF)
	FileWriteLine($aIniFile, @CRLF)
	IniWrite($aIniFile, $aIniHeaderMain, $aIniEntriesCountLine, $aEntriesCount)
	FileWriteLine($aIniFile, @CRLF)
	For $i = 0 To ($aEntriesCount - 1)
		IniWrite($aIniFile, $aIniHeaderMain, ($i + 1) & "-Delay (seconds) ###", $xDelay[$i])
		IniWrite($aIniFile, $aIniHeaderMain, ($i + 1) & "-File ###", $xFile[$i])
	Next
EndFunc   ;==>UpdateIni

Func _RestartProgram() ; Thanks UP_NORTH
	$aRestart = True
	If @Compiled = 1 Then
		Run(FileGetShortName(@ScriptFullPath))
	Else
		Run(FileGetShortName(@AutoItExe) & " " & FileGetShortName(@ScriptFullPath))
	EndIf
	Exit
EndFunc   ;==>_RestartProgram

Func _IsInternetConnected()
	Local $aReturn = DllCall('connect.dll', 'long', 'IsInternetConnected')
	If @error Then
		Return SetError(1, 0, False)
	EndIf
	Return $aReturn[0] = 0
EndFunc   ;==>_IsInternetConnected

Func LogWrite($Msg)
	FileWriteLine($aLogFile, _NowCalc() & " " & $Msg)
EndFunc   ;==>LogWrite
