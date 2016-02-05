; Multiple-Clipboard Script by Gerrard Lukacs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global delayStep := 70
SetKeyDelay delayStep

global slowMode := false
global prevSlowMode := slowMode

global clipboards := []
loop 10
	clipboards[A_Index - 1] := new StoredClipboard()

class StoredClipboard
{
	static numClipboards := 0
	
	index := 0
	raw := false
	
	__New()
	{
		global
		this.index := ++StoredClipboard.numClipboards
		
		local index := this.index
		clipboard%index% := ""
	}
	
	size()
	{
		index := this.index
		return StrLen(clipboard%index%) * (A_IsUnicode ? 2 : 1)
	}
	
	toString()
	{
		index := this.index
		return """" clipboard%index% """, " . (this.raw ? "raw" : this.size())
	}
}

cleanNewlines(text)
{
	return RegExReplace(text, "\r\n?|\n\r?", "`n")
}

paste(index)
{
	board := clipboards[index]
	clipIdx := board.index
	
	if (board.raw)
	{
		if (slowMode)
			SendEvent % cleanNewlines(clipboard%clipIdx%)
		else
			Send % cleanNewlines(clipboard%clipIdx%)
	}
	else
	{
		clipBackup := ClipboardAll
		Clipboard := clipboard%clipIdx%
		Send ^v
		Sleep delayStep
		Clipboard := clipBackup
	}
}

copy(index, cut=false, raw=false)
{
	clipBackup := ClipboardAll
	Clipboard := ""
	
	if (cut)
		Send ^x
	else
		Send ^c
	ClipWait 5
	
	board := clipboards[index]
	clipIdx := board.index
	if (raw)
		clipboard%clipIdx% := Clipboard
	else
		clipboard%clipIdx% := ClipboardAll
	; Important note: ClipboardAll assignment must be on its own line.
	; Also, a pseudo-array is necessary because ClipboardAll cannot be stored in an object.
	board.raw := raw
	
	Clipboard := clipBackup
}

Menu Tray, Add, Debug, TrayDebug
Return

TrayDebug:
	_boards := ""
	for _key, _obj in clipboards
		_boards .= _key ": " _obj.toString() . "`n"
	MsgBox % _boards
	_boards := ""
Return

!1::
!2::
!3::
!4::
!5::
!6::
!7::
!8::
!9::
!0::
	StringSplit, _key, A_ThisLabel
	paste(_key2)
Return

^!1::
^!2::
^!3::
^!4::
^!5::
^!6::
^!7::
^!8::
^!9::
^!0::
+!1::
+!2::
+!3::
+!4::
+!5::
+!6::
+!7::
+!8::
+!9::
+!0::
^+!1::
^+!2::
^+!3::
^+!4::
^+!5::
^+!6::
^+!7::
^+!8::
^+!9::
^+!0::
	StringSplit, _key, A_ThisLabel
	
	if (_key0 = 4)
		copy(_key4, , true)
	else
		copy(_key3, _key1 = "+")
Return

!-:: slowMode := true
!+=:: slowMode := false
!_:: prevSlowMode := slowMode
!=:: slowMode := prevSlowMode
