#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#MaxThreads 20

; ----- Includes -----

#Include ./includes/gui/MenuEnumOption.ahk
#Include ./includes/gui/MenuToggleOption.ahk
#Include ./includes/gui/InputMultiLine.ahk
#Include ./includes/io/CopySelected.ahk


; ----- Settings -----

; The browser to use. Must be an instance of Browser.
global selectedBrowser := Browser.CHROME
; If true, open URLs in a private/incognito window.
global private := false
; If true, open multiple URLs with a single command.
; Not supported with Firefox in Private mode or Internet Explorer in any mode.
global simultaneous := true

; When opening URLs with multiple commands, wait this many milliseconds
; between each command. Too little delay, and the browser may crash.
global delayStep := 100

; A list of URLs opened by Alt+Browser_Home / Ctrl+Alt+Shift+Enter
global favorites := "
    (LTrim
        www.google.com
        en.wikipedia.org
    )"


; ----- Classes and Functions -----

class Browser extends MenuEnumItem
{
    static browsers := []
    
    static CHROME := new Browser("Google Chrome", "TrayChrome"
        , "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
        , "--incognito", true, true)
    static FIREFOX := new Browser("Mozilla Firefox", "TrayFirefox"
        , "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
        , "-private-window", true)
    static IE := new Browser("Internet Explorer", "TrayIE"
        , "C:\Program Files\Internet Explorer\iexplore.exe"
        , "-private")
    
    executable := ""
    privateFlag := ""
    supportsMulti := false
    supportsPrivateMulti := false
    
    __New(itemName, labelName, executable, privateFlag
        , supportsMulti=false, supportsPrivateMulti=false)
    {
        base.__New(itemName, labelName)
        this.executable := executable
        this.privateFlag := privateFlag
        this.supportsMulti := supportsMulti
        this.supportsPrivateMulti := supportsPrivateMulti
        
        Browser.browsers.insert(this)
    }
    
    supportsSimultaneous()
    {
        return private ? this.supportsPrivateMulti : this.supportsMulti
    }
    
    commandString()
    {
        if (private)
            return this.executable . " " . this.privateFlag
        else
            return this.executable
    }
    
    openURLs(urls)
    {
        command := this.commandString()
        if (simultaneous and this.supportsSimultaneous())
        {
            for _, url in urls
            {
                command .= " """ . url . """"
            }
            Run %command%
        }
        else
        {
            for _, url in urls
            {
                Run % command . " """ . url . """"
				Sleep delayStep
            }
        }
    }
    
}

splitLines(str)
{
    return StrSplit(str, ["`r`n", "`n"])
}


; ----- Tray Menu -----

updateSimultaneous()
{
    simultaneousOpt.setEnabled(selectedBrowser.supportsSimultaneous())
}

Menu Tray, Add ; Blank makes a separator
new MenuEnumOption("Tray", "selectedBrowser", Browser.browsers)
Menu Tray, Add
new MenuToggleOption("Tray", "Private Browsing", "TrayPrivate", "private")
global simultaneousOpt := new MenuToggleOption("Tray"
    , "Open Simultaneously", "TraySimultaneous", "simultaneous")
updateSimultaneous()
Return

TrayChrome:
TrayFirefox:
TrayIE:
    MenuEnumOption.options[A_ThisLabel].setVariable(A_ThisLabel)
    updateSimultaneous()
Return

TrayPrivate:
TraySimultaneous:
    MenuToggleOption.options[A_ThisLabel].toggleVariable()
    updateSimultaneous()
Return


; ----- Hotkeys -----

Browser_Home::
!Enter::
    selectedBrowser.openURLs(splitLines(copySelected()))
Return

^Browser_Home::
^!Enter::
    selectedBrowser.openURLs(splitLines(Clipboard))
Return

#MaxThreadsPerHotkey 9
+Browser_Home::
+!Enter::
    __inputText := inputMultiLine("Open URLs"
        , "Input URLs to open in " selectedBrowser.name ":", , , 300, "Open")
    if (__inputText)
        selectedBrowser.openURLs(splitLines(__inputText))
Return
#MaxThreadsPerHotkey 1

^+Browser_Home::
!Browser_Home::
^+!Enter::
    selectedBrowser.openURLs(splitLines(favorites))
Return
