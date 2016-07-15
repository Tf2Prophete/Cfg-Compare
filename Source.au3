#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Imgs\Icon.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=R.S.S.
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
; *** Start added by AutoIt3Wrapper ***
; *** End added by AutoIt3Wrapper ***

#include <GUIConstantsEx.au3>
#include <GuiListView.au3>
#include <Array.au3>
#include <File.au3>



Opt("GUIOnEventMode", 1)

; Start Declaring GUIS

Global $MainGui

; Finish Declaring GUIS

; Start Declaring Controls

Global $FileACheckBox, $ClipACheckBox, $FileBCheckBox, $ClipBCheckBox, $UniqueFileAList, $UniqueFileBList
Global $SameList

; Finish Declaring Controls

; Start Declaring Variables

Global $LoadFileA = "", $LoadFileB = "", $CfgAState = 0, $CfgBState = 0, $CfgA, $CfgB
Global $ReadCfgA, $ReadCfgB, $FoundComments = 0, $String, $Found = 0, $Stop = 0, $WaitForReset = 0

; Stop Declaring Variables

; Start Declaring Arrays

Dim $CfgACommands[0], $CfgBCommands[0], $CfgAUnique[0], $CfgBUnique[0], $SameCommands[0]

; Stop Declaring Arrays



_CreateGui()

Func _CreateGui()

	$LoadFileA = ""
	$CfgAState = 0
	$CfgBState = 0
	$WaitForReset = 0

	$MainGui = GUICreate("Cfg Compare Tool v1.0 - TF2Prophete", 800, 630)
	GUISetOnEvent($GUI_EVENT_CLOSE, "_Exit")

	$LoadFileAButton = GUICtrlCreateButton("Load Cfg A From File", 10, 20, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_LoadCfgAFromFile")

	GUICtrlCreateLabel("", 60, 65, 100, 40)
	$FileACheckBox = GUICtrlCreateCheckbox("Loaded", 60, 65, 100, 40)
	GUICtrlSetFont(-1, 14)


	$ClipFileAButton = GUICtrlCreateButton("Load Cfg A From Clip", 10, 110, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_LoadCfgAFromClip")

	GUICtrlCreateLabel("", 60, 155, 100, 40)
	$ClipACheckBox = GUICtrlCreateCheckbox("Loaded", 60, 155, 100, 40)
	GUICtrlSetFont(-1, 14)

	$LoadFileBButton = GUICtrlCreateButton("Load Cfg B From File", 590, 20, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_LoadCfgBFromFile")

	GUICtrlCreateLabel("", 650, 65, 100, 40)
	$FileBCheckBox = GUICtrlCreateCheckbox("Loaded", 650, 65, 100, 40)
	GUICtrlSetFont(-1, 14)


	$ClipFileBButton = GUICtrlCreateButton("Load Cfg B From Clip", 590, 110, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_LoadCfgBFromClip")

	GUICtrlCreateLabel("", 650, 155, 100, 40)
	$ClipBCheckBox = GUICtrlCreateCheckbox("Loaded", 650, 155, 100, 40)
	GUICtrlSetFont(-1, 14)

	$ClearASetButton = GUICtrlCreateButton("Unload A Side", 10, 520, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_UnloadSideA")

	$ClearBSetButton = GUICtrlCreateButton("Unload B Side", 590, 520, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_UnloadSideB")

	$ExecuteCheck = GUICtrlCreateButton("Compare Cfgs", 290, 65, 200, 40)
	GUICtrlSetFont(-1, 14)
	GUICtrlSetOnEvent(-1, "_Compare")

	$UniqueFileAList = GUICtrlCreateListView("File A Unique List", 10, 200, 200, 300)
	_GUICtrlListView_SetColumnWidth(-1, 0, 500)
	GUICtrlSetFont(-1, 13)

	$SameList = GUICtrlCreateListView("Identical Lines List", 300, 200, 200, 300)
	_GUICtrlListView_SetColumnWidth(-1, 0, 500)
	GUICtrlSetFont(-1, 13)

	$UniqueFileBList = GUICtrlCreateListView("File B Unique List", 590, 200, 200, 300)
	_GUICtrlListView_SetColumnWidth(-1, 0, 500)
	GUICtrlSetFont(-1, 13)

	$ResetButton = GUICtrlCreateButton("Reset", 300, 520, 200, 40)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "_Reset")

	$CloseButton = GUICtrlCreateButton("Close", 300, 580, 200, 40)
	GUICtrlSetFont(-1, 16)
	GUICtrlSetOnEvent(-1, "_Exit")

	GUICtrlCreateLabel("© RS Software", 735, 620, 200)
	GUICtrlSetFont(-1, 7)
	GUICtrlCreateLabel("Version 1.0", 2, 620, 200)
	GUICtrlSetFont(-1, 7)

	GUISetState()
EndFunc   ;==>_CreateGui

Func _Compare()

	If $WaitForReset = 0 Then

		Dim $ReadCfgA[0], $ReadCfgB[0], $CfgACommands[0], $CfgBCommands[0], $SameCommands[0]

		If $CfgAState = 0 Then
			MsgBox(48, "Error", "No Cfg loaded on A side!")
			$Stop = 1
		EndIf

		If $CfgBState = 0 Then
			MsgBox(48, "Error", "No Cfg loaded on B side!")
			$Stop = 1
		EndIf

		If $CfgAState = 1 Then
			_FileReadToArray($LoadFileA, $ReadCfgA)
		ElseIf $CfgAState = 2 Then
			_FileReadToArray(@TempDir & "/TempCfgA.txt", $ReadCfgA)
		EndIf

		If $CfgBState = 1 Then
			_FileReadToArray($LoadFileB, $ReadCfgB)
		ElseIf $CfgBState = 2 Then
			_FileReadToArray(@TempDir & "/TempCfgB.txt", $ReadCfgB)
		EndIf

		If $Stop = 0 Then


			For $i = 1 To UBound($ReadCfgA) - 1
				$Null = 0
				$FoundComments = 0
				$ReadCfgA[$i] = StringStripWS($ReadCfgA[$i], 8)
				$ReadCfgA[$i] = StringReplace($ReadCfgA[$i], "'", "")
				$ReadCfgA[$i] = StringReplace($ReadCfgA[$i], '"', "")
				If StringInStr($ReadCfgA[$i], "//") Then
					$RemoveComments = StringSplit($ReadCfgA[$i], "//")
					$FoundComments = 1
				Else
					$String = $ReadCfgA[$i]
				EndIf

				If $FoundComments = 1 Then
					$String = $RemoveComments[1]
				EndIf

				If StringLen($String) < 1 Then
					$Null = 1
				EndIf

				If StringInStr($String, "echo") Then
					$Null = 1
				EndIf

				If StringInStr($String, "alias") Then
					$Null = 1
				EndIf

				If $Null = 0 Then

					$GetLen = StringLen($String)
					$Count = 0
					$Null = 1
					For $a = 1 To $GetLen
						$Trim = StringTrimLeft($String, $a)
						If StringIsDigit($Trim) Then
							$Count = $a
							$Null = 0
							ExitLoop
						EndIf
					Next

					If $Null = 0 Then

						$Variable = StringTrimLeft($String, $Count)
						$GetLen = StringLen($Variable)
						$Command = StringTrimRight($String, $GetLen)

						If StringInStr($Command, ".") Then
							$Command = StringReplace($Command, ".", "")
							$GetLen = StringLen($Command)
							$TrimOffNumbers = StringTrimLeft($Command, $GetLen - 1)
							If StringIsDigit($TrimOffNumbers) Then
								$Command = StringTrimRight($Command, 1)
								$Variable = $TrimOffNumbers & "." & $Variable
							Else
								$Variable = "." & $Variable
							EndIf
						EndIf

						If StringInStr($Command, "-") Then
							$Command = StringTrimRight($Command, 1)
							$Variable = "-" & $Variable
						EndIf

						$String = $Command & " " & '"' & $Variable & '"'

						_ArrayAdd($CfgACommands, $String)
					EndIf
				EndIf

			Next

			For $i = 1 To UBound($ReadCfgB) - 1
				$Null = 0
				$FoundComments = 0
				$ReadCfgB[$i] = StringStripWS($ReadCfgB[$i], 8)
				$ReadCfgB[$i] = StringReplace($ReadCfgB[$i], "'", "")
				$ReadCfgB[$i] = StringReplace($ReadCfgB[$i], '"', "")
				If StringInStr($ReadCfgB[$i], "//") Then
					$RemoveComments = StringSplit($ReadCfgB[$i], "//")
					$FoundComments = 1
				Else
					$String = $ReadCfgB[$i]
				EndIf

				If $FoundComments = 1 Then
					$String = $RemoveComments[1]
				EndIf

				If StringLen($String) < 1 Then
					$Null = 1
				EndIf

				If StringInStr($String, "echo") Then
					$Null = 1
				EndIf

				If StringInStr($String, "alias") Then
					$Null = 1
				EndIf


				If $Null = 0 Then

					$GetLen = StringLen($String)
					$Count = 0
					$Null = 1
					For $a = 1 To $GetLen
						$Trim = StringTrimLeft($String, $a)
						If StringIsDigit($Trim) Then
							$Count = $a
							$Null = 0
							ExitLoop
						EndIf
					Next

					If $Null = 0 Then

						$Variable = StringTrimLeft($String, $Count)
						$GetLen = StringLen($Variable)
						$Command = StringTrimRight($String, $GetLen)

						If StringInStr($Command, ".") Then
							$Command = StringReplace($Command, ".", "")
							$GetLen = StringLen($Command)
							$TrimOffNumbers = StringTrimLeft($Command, $GetLen - 1)
							If StringIsDigit($TrimOffNumbers) Then
								$Command = StringTrimRight($Command, 1)
								$Variable = $TrimOffNumbers & "." & $Variable
							Else
								$Variable = "." & $Variable
							EndIf
						EndIf

						If StringInStr($Command, "-") Then
							$Command = StringTrimRight($Command, 1)
							$Variable = "-" & $Variable
						EndIf

						$String = $Command & " " & '"' & $Variable & '"'

						_ArrayAdd($CfgBCommands, $String)
					EndIf
				EndIf

			Next

			$CheckLen1 = UBound($CfgACommands)
			$CheckLen2 = UBound($CfgBCommands)

			If $CheckLen1 > $CheckLen2 Then
				$Length = 1
			Else
				$Length = 2
			EndIf

			If $Length = 2 Then
				For $a = 0 To UBound($CfgACommands) - 1
					$CheckString = $CfgACommands[$a]
					For $b = 0 To UBound($CfgBCommands) - 1
						If $CheckString = $CfgBCommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 0 Then
						_ArrayAdd($CfgAUnique, $CheckString)
					EndIf
					$Found = 0
				Next

				For $a = 0 To UBound($CfgACommands) - 1
					If $a > UBound($CfgBCommands) - 1 Then
						ExitLoop
					EndIf
					$CheckString = $CfgBCommands[$a]
					For $b = 0 To UBound($CfgACommands) - 1
						If $CheckString = $CfgACommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 0 Then
						_ArrayAdd($CfgBUnique, $CheckString)
					EndIf
					$Found = 0
				Next

				For $a = 0 To UBound($CfgACommands) - 1
					If $a > UBound($CfgBCommands) - 1 Then
						ExitLoop
					EndIf
					$CheckString = $CfgACommands[$a]
					For $b = 0 To UBound($CfgBCommands) - 1
						If $CheckString = $CfgBCommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 1 Then
						_ArrayAdd($SameCommands, $CheckString)
					EndIf
					$Found = 0
				Next

			EndIf

			If $Length = 1 Then
				For $a = 0 To UBound($CfgBCommands) - 1
					$CheckString = $CfgACommands[$a]
					For $b = 0 To UBound($CfgBCommands) - 1
						If $CheckString = $CfgBCommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 0 Then
						_ArrayAdd($CfgAUnique, $CheckString)
					EndIf
					$Found = 0
				Next

				For $a = 0 To UBound($CfgBCommands) - 1
					If $a > UBound($CfgACommands) - 1 Then
						ExitLoop
					EndIf
					$CheckString = $CfgBCommands[$a]
					For $b = 0 To UBound($CfgACommands) - 1
						If $CheckString = $CfgACommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 0 Then
						_ArrayAdd($CfgBUnique, $CheckString)
					EndIf
					$Found = 0
				Next

				For $a = 0 To UBound($CfgBCommands) - 1
					If $a > UBound($CfgACommands) - 1 Then
						ExitLoop
					EndIf
					$CheckString = $CfgBCommands[$a]
					For $b = 0 To UBound($CfgACommands) - 1
						If $CheckString = $CfgACommands[$b] Then
							$Found = 1
						EndIf
					Next
					If $Found = 1 Then
						_ArrayAdd($SameCommands, $CheckString)
					EndIf
					$Found = 0
				Next

			EndIf

			For $a = 0 To UBound($CfgACommands) - 1
				If $a > UBound($CfgACommands) - 1 Then
					ExitLoop
				EndIf
				$CheckString = $CfgACommands[$a]
				For $b = 0 To UBound($SameCommands) - 1
					If $CheckString = $SameCommands[$b] Then
						_ArrayDelete($CfgACommands, $a)
						ExitLoop
					EndIf
				Next
			Next


			For $a = 0 To UBound($CfgBCommands) - 1
				If $a > UBound($CfgBCommands) - 1 Then
					ExitLoop
				EndIf
				$CheckString = $CfgBCommands[$a]
				For $b = 0 To UBound($SameCommands) - 1
					If $CheckString = $SameCommands[$b] Then
						_ArrayDelete($CfgBCommands, $a)
						ExitLoop
					EndIf
				Next
			Next


			For $i = 0 To UBound($CfgACommands) - 1
				If $i > UBound($CfgACommands) - 1 Then
					ExitLoop
				EndIf
				GUICtrlCreateListViewItem($CfgACommands[$i], $UniqueFileAList)
			Next

			For $i = 0 To UBound($CfgBCommands) - 1
				If $i > UBound($CfgBCommands) - 1 Then
					ExitLoop
				EndIf
				GUICtrlCreateListViewItem($CfgBCommands[$i], $UniqueFileBList)
			Next

			For $i = 0 To UBound($SameCommands) - 1
				If $i > UBound($SameCommands) - 1 Then
					ExitLoop
				EndIf
				GUICtrlCreateListViewItem($SameCommands[$i], $SameList)
			Next

			$WaitForReset = 1

		EndIf

		$Stop = 0

	Else
		GUISetState(@SW_DISABLE, $MainGui)
		MsgBox(48, "Error", "Please use the reset button and reload cfg's before trying again!")
		GUISetState(@SW_ENABLE, $MainGui)
		Sleep(100)
		WinActivate($MainGui)
	EndIf

;~ _ArrayDisplay($CfgACommands)
;~ _ArrayDisplay($CfgBCommands)
;~ _ArrayDisplay($SameCommands)

EndFunc   ;==>_Compare


Func _Reset()
	GUISetState(@SW_DISABLE, $MainGui)
	$CheckMsgBox = MsgBox(4, "Reset..", "Are you sure you wish to reset?")
	If $CheckMsgBox = 6 Then
		MsgBox(0, "Reset", "Reset complete!")
		GUIDelete($MainGui)
		_CreateGui()
	Else
		MsgBox(48, "Cancelled", "Reset has been cancelled!")
		GUISetState(@SW_ENABLE, $MainGui)
		Sleep(100)
		WinActivate($MainGui)
	EndIf
EndFunc   ;==>_Reset

Func _LoadCfgAFromFile()
	GUISetState(@SW_DISABLE, $MainGui)
	If $WaitForReset = 0 Then
		$LoadFileA = ""
		While $LoadFileA = ""
			$LoadFileA = FileOpenDialog("Cfg File A...", @DesktopDir, "All(*.*)")
			If $LoadFileA = "" Then
				MsgBox(48, "Cancelled", "No file loaded or file open cancelled!")
				$LoadFileA = "0"
			Else
				GUICtrlSetState($FileACheckBox, $GUI_CHECKED)
				GUICtrlSetState($ClipACheckBox, $GUI_UNCHECKED)
				MsgBox(0, "Loaded", "Cfg A loaded from file!")
				$CfgAState = 1
			EndIf
		WEnd
	Else
		MsgBox(48, "Error", "Please use the reset button and reload cfg's before trying again!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)

EndFunc   ;==>_LoadCfgAFromFile

Func _LoadCfgAFromClip()
	GUISetState(@SW_DISABLE, $MainGui)
	If $WaitForReset = 0 Then
		$LoadFileA = ""
		$CfgAState = 2
		$LoadFileA = ClipGet()
		GUICtrlSetState($ClipACheckBox, $GUI_CHECKED)
		GUICtrlSetState($FileACheckBox, $GUI_UNCHECKED)
		FileDelete(@TempDir & "/TempCfgA.txt")
		FileWrite(@TempDir & "/TempCfgA.txt", $LoadFileA)
		MsgBox(0, "Loaded", "Cfg A loaded from clipboard!")
	Else
		MsgBox(48, "Error", "Please use the reset button and reload cfg's before trying again!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)
EndFunc   ;==>_LoadCfgAFromClip

Func _UnloadSideA()
	GUISetState(@SW_DISABLE, $MainGui)
	$CheckMsgBox = MsgBox(4, "Confirm...", "Do you wish to clear Side A?")
	If $CheckMsgBox = 6 Then
		$LoadFileA = ""
		GUICtrlSetState($FileACheckBox, $GUI_UNCHECKED)
		GUICtrlSetState($ClipACheckBox, $GUI_UNCHECKED)
		GUICtrlDelete($UniqueFileAList)
		$CfgAState = 0
		$UniqueFileAList = GUICtrlCreateListView("File A Unique List", 10, 200, 200, 300)
		_GUICtrlListView_SetColumnWidth(-1, 0, 196)
		GUICtrlSetFont(-1, 13)
		MsgBox(0, "Cleared", "Side A has been cleared!")
	Else
		MsgBox(0, "Cancelled", "Clearing has been cancelled!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)
EndFunc   ;==>_UnloadSideA

Func _LoadCfgBFromFile()
	GUISetState(@SW_DISABLE, $MainGui)
	If $WaitForReset = 0 Then
		$LoadFileB = ""
		While $LoadFileB = ""
			$LoadFileB = FileOpenDialog("Cfg File B...", @DesktopDir, "All(*.*)")
			If $LoadFileB = "" Then
				MsgBox(48, "Cancelled", "No file loaded or file open cancelled!")
				$LoadFileB = "0"
			Else
				GUICtrlSetState($FileBCheckBox, $GUI_CHECKED)
				GUICtrlSetState($ClipBCheckBox, $GUI_UNCHECKED)
				$CfgBState = 1
			EndIf
		WEnd
	Else
		MsgBox(48, "Error", "Please use the reset button and reload cfg's before trying again!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)
EndFunc   ;==>_LoadCfgBFromFile

Func _LoadCfgBFromClip()
	GUISetState(@SW_DISABLE, $MainGui)
	If $WaitForReset = 0 Then
		$LoadFileB = ""
		$CfgBState = 2
		$LoadFileB = ClipGet()
		FileDelete(@TempDir & "/TempCfgB.txt")
		FileWrite(@TempDir & "/TempCfgB.txt", $LoadFileB)
		GUICtrlSetState($ClipBCheckBox, $GUI_CHECKED)
		GUICtrlSetState($FileBCheckBox, $GUI_UNCHECKED)
		MsgBox(0, "Loaded", "Cfg B loaded from clipboard!")
	Else
		MsgBox(48, "Error", "Please use the reset button and reload cfg's before trying again!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)
EndFunc   ;==>_LoadCfgBFromClip

Func _UnloadSideB()
	GUISetState(@SW_DISABLE, $MainGui)
	$CheckMsgBox = MsgBox(4, "Confirm...", "Do you wish to clear Side B?")
	If $CheckMsgBox = 6 Then
		$LoadFileB = ""
		GUICtrlSetState($FileBCheckBox, $GUI_UNCHECKED)
		GUICtrlSetState($ClipBCheckBox, $GUI_UNCHECKED)
		GUICtrlDelete($UniqueFileBList)
		$CfgBState = 0
		$UniqueFileBList = GUICtrlCreateListView("File B Unique List", 590, 200, 200, 300)
		_GUICtrlListView_SetColumnWidth(-1, 0, 196)
		GUICtrlSetFont(-1, 13)
		MsgBox(0, "Cleared", "Side B has been cleared!")
	Else
		MsgBox(0, "Cancelled", "Clearing has been cancelled!")
	EndIf
	GUISetState(@SW_ENABLE, $MainGui)
	Sleep(100)
	WinActivate($MainGui)
EndFunc   ;==>_UnloadSideB



Func _Exit()
	FileDelete(@TempDir & "/TempCfgB.txt")
	FileDelete(@TempDir & "/TempCfgA.txt")
	Exit
EndFunc   ;==>_Exit

While 1
	Sleep(10)
WEnd
