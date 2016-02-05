; Simple numpad-emulating script by Gerrard Lukacs. Useful for using Blender without a numpad.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

AppsKey & 1:: Send {Blind}{Numpad1}
AppsKey & 2:: Send {Blind}{Numpad2}
AppsKey & 3:: Send {Blind}{Numpad3}
AppsKey & 4:: Send {Blind}{Numpad4}
AppsKey & 5:: Send {Blind}{Numpad5}
AppsKey & 6:: Send {Blind}{Numpad6}
AppsKey & 7:: Send {Blind}{Numpad7}
AppsKey & 8:: Send {Blind}{Numpad8}
AppsKey & 9:: Send {Blind}{Numpad9}
AppsKey & 0:: Send {Blind}{Numpad0}

AppsKey & .:: Send {Blind}{NumpadDot}
AppsKey & /:: Send {Blind}{NumPadDiv}
AppsKey & ,:: Send {Blind}{NumPadMult}
AppsKey & +:: Send {Blind}{NumPadAdd}
AppsKey & -:: Send {Blind}{NumPadSub}
AppsKey & Enter:: Send {Blind}{NumPadEnter}
