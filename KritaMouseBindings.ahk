; Simple script to add custom mouse shortcuts to Krita by Gerrard Lukacs. Useful when using a tablet.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Only apply for windows used by Krita.
GroupAdd Krita, ahk_class QWidget
GroupAdd Krita, ahk_exe krita.exe
#IfWinActive ahk_group Krita

; Alt+LeftClick: Toggle Erase
!LButton:: Send e

; Alt+RightClick: Swap Foreground and Background Colors
!RButton:: Send x
; Shift+RightClick: Switch to Previous Preset
+RButton:: Send /

; Alt+MiddleClick : Reset Zoom and Rotation
!MButton:: Send 15
