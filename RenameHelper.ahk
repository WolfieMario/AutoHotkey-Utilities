#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#IfWinActive ahk_class CabinetWClass

global start := "{F2}{Home}{Ctrl Down}{Left 5}{Ctrl Up}" ; Workaround for Home bug
global end := "{F2}{Right}{Left}" ; Before .extension

; Move cursor to start
F1:: Send %start%
; Highlight first word
+F1:: Send %start%{Ctrl Down}{Shift Down}{Right}{Ctrl Up}{Left}{Shift Up}

; Move cursor to end (before .extension)
F3:: Send %end%
; Highlight last word (before .extension)
+F3:: Send %end%{Ctrl Down}{Shift Down}{Left}{Shift Up}{Ctrl Up}
; Highlight extension
^F3:: Send %end%{Right}{Ctrl Down}{Shift Down}{Right}{Shift Up}{Ctrl Up}

; Note: F2 on its own enters Rename mode the default way, with everything before .extension highlighted. This is standard on Windows.
