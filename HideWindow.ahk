; Window Hiding/Showing Script by Gerrard Lukacs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global window_ids := []
global hidden_ids := []

; Hide active window, and remember it
#^Down::
    WinGet win_id, ID, A
    WinHide ahk_id %win_id%
    window_ids.Insert(win_id)
Return

; Show all windows hidden by Ctrl+Win+Down during this session
#^Up::
    for index, win_id in window_ids
    {
        WinShow ahk_id %win_id%
    }
    window_ids := []
Return

; Show literally all windows - even those which are meant to stay hidden
; ... NEVER ACTUALLY USE THIS.
#^+Up::
    DetectHiddenWindows On
    WinGet ids, List, , , ahk_class AutoHotkeyGUI
    loop %ids%
    {
        win_id := ids%A_Index%
		;if (A_Index > 100)
		;	Msgbox %win_id%, %A_Index%
		WinGet win_style, Style, ahk_id %win_id%
		if !(win_style & 0x10000000) ; WS_VISIBLE
		{
			WinShow ahk_id %win_id%
			hidden_ids.Insert(win_id)
		}
    }
Return

; Hide all windows Ctrl+Shift+Win+Up showed during this session.
#^+Down::
    for index, win_id in hidden_ids
    {
        WinHide ahk_id %win_id%
    }
Return
