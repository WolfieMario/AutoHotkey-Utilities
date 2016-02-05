; Simple numpad-emulating script by Gerrard Lukacs. Useful for using Blender without a numpad.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

AppsKey & 1:: Send {Numpad1}
AppsKey & 2:: Send {Numpad2}
AppsKey & 3:: Send {Numpad3}
AppsKey & 4:: Send {Numpad4}
AppsKey & 5:: Send {Numpad5}
AppsKey & 6:: Send {Numpad6}
AppsKey & 7:: Send {Numpad7}
AppsKey & 8:: Send {Numpad8}
AppsKey & 9:: Send {Numpad9}
AppsKey & 0:: Send {Numpad0}

AppsKey & .:: Send {NumpadDot}
AppsKey & /:: Send {NumPadDiv}
AppsKey & ,:: Send {NumPadMult}
AppsKey & +:: Send {NumPadAdd}
AppsKey & -:: Send {NumPadSub}
AppsKey & Enter:: Send {NumPadEnter}
