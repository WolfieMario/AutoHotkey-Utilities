#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global delayStep := 100
global commandString := "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
global urls := "
	(LTrim
		www.google.com
		en.wikipedia.org
	)"

;StringReplace urlsNewline, urls, `r`n, `n, All
urlList := StrSplit(urls, ["`r`n", "`n"])
for index, url in urlList
{
	Sleep delayStep
	Run % commandString . " """ . url . """"
}
