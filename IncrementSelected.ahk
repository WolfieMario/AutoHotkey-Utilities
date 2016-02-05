#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SC029 is tilde key `

global increment := 1

^SC029::
	clipbrdBackup := ClipboardAll ; Save clipboard
	Send, ^c
	ClipWait, 1 ; Wait for clipboard data
	Sleep 100
	
	global increment
	incremented := Clipboard + increment
	SendInput %incremented%
	
	ClipBoard := clipbrdBackup ; Restore clipboard
	Return

^+SC029::
	returnVal := set("Increment", "Enter increment amount")
	if not ErrorLevel
		global increment := returnVal
	Return

set(title, input)
{
	InputBox, value, %title%, %input%
	Return value
}
