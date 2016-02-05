#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ----- Variables and Settings -----

#NoTrayIcon
showInTray := false

AhkDir := "C:\Program Files\AutoHotkey"

; Used for Key History
#InstallKeybdHook

; Used when finding other AutoHotkey scripts' windows
DetectHiddenWindows On
SetTitleMatchMode 2

global ahk_exe_AHK := " ahk_exe AutoHotkey.exe"

class GuiSizes
{
	static buttonWidth := 100
	static buttonHeight := 23
	
	static horizontalPad := 6
	
	static columnWidth := 150
}


; ----- General Functions -----

runProgram(directory, file, singleInstance=false, options="")
{
	if (singleInstance)
	{
		Process Exist, %file%
		if (ErrorLevel)
		{
			return
		}
	}
	Run %directory%/%file%, %directory%, %options%
}

openFolder(directory)
{
	Run explore %directory%
}


; ----- GUI Functions -----

; The main menu of this script
showUtilitiesMenu()
{	
	originalWidth := GuiSizes.columnWidth
	Gui Utilities:New, +LastFound, Utilities
	
	startColumn("Run Programs", 200)
	addButton("Firefox, Notepad++, Winamp, Skype", "RunGeneral")
	addButton("Task Manager", "RunTaskManager")
	addButton("AutoHotkey Scripts Folder", "OpenScriptsFolder")
	; Python button row
	pythonButtonStyle := "W" ((GuiSizes.columnWidth - GuiSizes.horizontalPad) / 2) " H" GuiSizes.buttonHeight
	Gui Add, Button, %pythonButtonStyle% gRunPython, Python
	pythonButtonStyle .= " x+" GuiSizes.horizontalPad
	Gui Add, Button, %pythonButtonStyle% gRunPython27, Python 2.7.9
	; End row
	addButton("SourceTree, Unity, MonoDevelop, Flux", "RunFlux", "xm")
	
	startColumn("AutoHotkey Scripts", 120)
	addScriptButton("MultiClipboard")
	addScriptButton("Timestamp")
	addScriptButton("MathTyping")
	addScriptButton("RenameHelper")
	addScriptButton("NumpadBindings")
	addScriptButton("KritaMouseBindings")
	addScriptButton("BlackScreen")
	
	startColumn("Script Utilities", 100)
	addButton("Key History", "ShowKeyHistory")
	addButton("Window Spy", "RunAHKWindowSpy")
	addButton("AutoHotkey Help", "RunAHKHelp")
	addButton("Reload Script", "ReloadScript")
	addCheckbox("Show in tray", "showInTray", "ToggleTray")
	
	Gui Show
	GuiSizes.columnWidth := originalWidth
}

startColumn(label, width, style="")
{
	GuiSizes.columnWidth := width
	style .= " W" GuiSizes.columnWidth " Center"
	Gui Add, Text, %style% Ym, %label%
}

addButton(label, onClick, style="")
{
	style .= " W" GuiSizes.columnWidth " H" GuiSizes.buttonHeight
	Gui Add, Button, %style% G%onClick%, %label%
}

addCheckbox(label, variable, onClick, style="")
{
	style .= " W" GuiSizes.columnWidth (%variable% ? " Checked" : "")
	Gui Add, Checkbox, %style% V%variable% G%onClick%, %label%
}

addScriptButton(scriptName)
{
	style := "W" GuiSizes.columnWidth
	if (WinExist(scriptName . ahk_exe_AHK))
	{
		style .= " Checked"
	}
	Gui Add, Checkbox, %style% gToggleScript, %scriptName%
}

Return


; ----- GUI Labels -----

UtilitiesGuiClose:
UtilitiesGuiEscape:
	Gui Cancel
Return


RunGeneral:
	runProgram("C:\Program Files (x86)\Mozilla Firefox", "firefox.exe", true)
	runProgram("C:\Program Files (x86)\Notepad++", "notepad++.exe", true)
	runProgram("C:\Program Files (x86)\Winamp", "winamp.exe", true)
	runProgram("C:\Program Files (x86)\Skype", "Phone\Skype.exe")
Return

RunTaskManager:
	Run %A_WinDir%\system32\taskmgr.exe /7
Return

OpenScriptsFolder:
	openFolder(A_ScriptDir)
Return

RunPython:
	Run cmd /K "python", %A_Desktop%
Return
RunPython27:
	Run cmd /K "C:\Python27\python.exe", %A_Desktop%
Return

RunFlux:
	runProgram("C:\Program Files (x86)\Atlassian\SourceTree", "SourceTree.exe", true)
	runProgram("C:\Program Files\Unity\Editor", "Unity.exe", true)
	runProgram("C:\Program Files\Unity\MonoDevelop\bin", "MonoDevelop.exe", true)
	openFolder(A_MyDocuments "\Gerrard\My Games\Flux")
Return


ToggleScript:
	scriptName := A_GuiControl . ".ahk"
	scriptHWND := WinExist(scriptName . ahk_exe_AHK)
	if (scriptHWND) ; Script is already running
	{
		WinClose ahk_id %scriptHWND%
	}
	else
	{
		Run %scriptName%
	}
Return


ToggleTray:
	Gui Submit, NoHide
	if (showInTray)
		Menu, Tray, Icon
	else
		Menu, Tray, NoIcon
Return

ShowKeyHistory:
	KeyHistory
Return

RunAHKWindowSpy:
	runProgram(AhkDir, "AU3_Spy.exe")
Return

RunAHKHelp:
	runProgram(AhkDir, "AutoHotkey.chm", false, "Max")
Return

ReloadScript:
	Reload
Return


; ----- Hotkeys -----

Browser_Favorites:: showUtilitiesMenu()
