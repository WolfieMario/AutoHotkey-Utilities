#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SC029 is tilde key `

global increment := 1

^SC029::
	clipbrdBackup := ClipboardAll ; Save clipboard
	Clipboard =
	Send, ^x
	ClipWait, 1 ; Wait for clipboard data
	Sleep 100
	
	global increment
	
	clipStr := Clipboard
	start := 1
	index := 1
	result := ""
	
	while (index > 0)
	{
		index := RegExMatch(clipStr, "[0-9]+", numberStr, start)
		
		if (index > 0)
		{
			result .= SubStr(clipStr, start, index - start)
			result .= numberStr + increment
			start := index + StrLen(numberStr)
		}
	}
	result .= SubStr(clipStr, start, StrLen(clipStr) - start + 1)
	
	;Send % "{Raw}" . result
	
	ClipBoard := result
	SendInput ^v
	Sleep 1000
	Clipboard =
	SendInput ^c
	ClipWait, 1 ; Wait for clipboard data
	
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
