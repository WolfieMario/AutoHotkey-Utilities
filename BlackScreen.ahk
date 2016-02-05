; Black Screen Script by Gerrard Lukacs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.

global defaultHeight := 40
global taskbarHeight := defaultHeight

screenSize()
{
	return "x0 y0 w" . A_ScreenWidth . " h" . (A_ScreenHeight - taskbarHeight)
}

resizeBy(amount)
{
	taskbarHeight += amount
	Gui Show, % screenSize()
}

resizeTo(amount)
{
	taskbarHeight := amount
	Gui Show, % screenSize()
}

Gui Color, black
Gui -Caption
Gui Show, % screenSize()
Return

GuiEscape:
GuiClose:
	ExitApp

#IfWinActive ahk_class AutoHotkeyGUI
Up:: resizeBy(1)
Down:: resizeBy(-1)
^Up:: resizeBy(5)
^Down:: resizeBy(-5)
^+Up:: resizeTo(A_ScreenHeight)
^+Down:: resizeTo(defaultHeight)

#IfWinActive ; Active in all windows
#Space:: WinSet Style, ^0xC00000, A ; Toggle WS_CAPTION of active window
!#Space:: WinSet Style, ^0x40000, A ; Toggle WS_SIZEBOX of active window
