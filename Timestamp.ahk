; Script to write timestamps, time activities, and perform simple arithmetic
; on timestamps by Gerrard Lukacs.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; ----- Settings -----

; Include seconds in timer timestamps
global timerSeconds := false
; Include hours in short-form timer timestamps (always included in long-form)
global timerHours := true

; When performing time arithmetic, assume times are given in *increasing*
; order, and negate the final result. Times are assumed to increase by adding
; hours in a consistent manner, e.g. "11:14PM-12:01AM" adds 24 hours to
; 12:01AM, making it 47 minutes later, while "7:05-6:03" adds 12 hours to
; 6:03, because AM/PM is not specified, and "23-4" adds 1 hour to 4.
; This is useful when combining a group of timer timestamps, e.g. on
; "8:36-10:04 10:12-10:31 10:55-1:00" it will compute the total time between
; each pair of start and end times (3 hours, 52 minutes, in this case).
; However, it should be disabled for conventional arithmetic: the increasing
; time assumption will likely be incorrect (you probably calculate differences
; as "big - small", not "-(small - big)"), leading to unexpected results.
global arithmeticTimer := true
; Whether time arithmetic should show tooltips for success and errors.
global arithmeticTooltips := true

; ----- Variables -----

global timerActive := false

global timerFormat, timerFormatLong, timerRegEx, timerRegExLong
updateTimerFormats()

global trayVariables := {}


; ----- General Functions -----

currentTime(format)
{
	; Returns the current time formatted by 'format'
	FormatTime, result, , %format%
	return result
}

timer(format)
{
	; Writes a timer timestamp using 'format' and toggles the timer state.
	if (timerActive)
		Send % "-" currentTime(format) " "
	else
		Send % currentTime(format)
	timerActive := !timerActive
}

updateTimerFormats()
{
	; Updates the format strings and regular expressions used by the timer
	; and time arithmetic hotkeys.
	
	static formatHourMin := "h:mm"
	static regExHourMin := "(?P<hour>\d{1,2}):(?P<min>\d{2})"
	
	timerFormat := ""
	timerRegEx := ""
	if (timerSeconds)
	{
		timerFormat := timerFormat . ":ss"
		timerRegEx := ":(?P<sec>\d{2})"
	}
	
	timerFormatLong := formatHourMin . timerFormat . "tt"
	timerRegExLong := regExHourMin . timerRegEx . "(?P<time>AM|PM)"
	if (timerHours)
	{
		timerFormat := formatHourMin . timerFormat
		timerRegEx := regExHourMin . timerRegEx
	}
	else
	{
		timerFormat := "m" . timerFormat
		timerRegEx := "(?P<min>\d{1,2})" . timerRegEx
	}
}

numChar(str, char)
{
	; Returns the number of occurrences of 'char' in 'str'.
	StringReplace _, str, %char%, , UseErrorLevel
	return ErrorLevel ; ErrorLevel stores the number of replacements.
}


; ----- Time Arithmetic Functions -----

timeArithmetic(timeString, timerMode=true, tooltips=false)
{
	; Compute and return result of time arithmetic on the input 'timeString'.
	; 'timerMode' assumes timestamps in 'timeString' are in increasing order
	;  (hours or days ahead of preceding timestamps, if necessary), and
	;  negates the final result.
	; 'tooltips' allows tooltips to be shown for errors and results.
	; See description of ^+!R hotkey for details.
	
	static regExSeparator := "(?P<delim>[,;`r`n +-]*)"
	timerRegExAny := "(?:" . timerRegExLong . "|" . timerRegEx . ")"
	; O is the option for Match Object output.
	; J is the option to allow multiple subpatterns to use the same names.
	timerMatchRegEx := "OJ)" . regExSeparator . timerRegExAny
	
	; Extract matching, parseable pattern
	matchPos := RegExMatch(timeString
			  , "OJ)(?:" . regExSeparator . timerRegExAny . ")+"
			  , fullMatch)
	
	if (matchPos == 0)
	{
		error := "Error: no time strings matching " . timerFormat
			   . " or " . timerFormatLong . " selected.`r`n"
			   . "Selection: '" . timeString . "'."
		if (tooltips)
			timedTooltip(error, 7000)
		return error
	}
	
	remainingString := fullMatch.Value(0)
	formulaString := ""
	totalSeconds := 0
	prevPM := false
	prevHours := 0
	prevMinutes := 0
	; Loop over string and parse subpatterns
	while (StrLen(remainingString) > 0 && matchPos > 0)
	{
		matchPos := RegExMatch(remainingString, timerMatchRegEx, match)
		if (matchPos > 0)
		{
			negative := Mod(numChar(match["delim"], "-"), 2) == 1
			
			seconds := timerSeconds ? match["sec"] : 0
			minutes := match["min"]
			
			longForm := match["time"] != ""
			pm := longForm ? (match["time"] == "PM") : prevPM
			
			if (timerHours || longForm)
				hours := Mod(match["hour"], 12) + (pm ? 12 : 0)
			else
				hours := timerMode ? prevHours : 0
			if (timerMode)
			{
				; Offset without making an inconsistent assumption.
				; If we know AM/PM, offset must be in increments of 24.
				; If we know the hour, offset must be in increments of 12.
				; Otherwise any whole number offset is acceptable; assume 1.
				increment := longForm ? 24 : (timerHours ? 12 : 1)
				if (hours < prevHours)
					hours += increment * Ceil((prevHours - hours) / increment)
				if (hours == prevHours && minutes < prevMinutes)
					hours += increment
			}
			
			currentSeconds := toSeconds(hours, minutes, seconds)
			totalSeconds += currentSeconds * (negative ? -1 : 1)
			formulaString .= (negative ? "-" : "+") . " "
						   . toTimeDelta(currentSeconds, timerSeconds) . " "
			
			prevPM := pm
			prevHours := hours
			prevMinutes := minutes
			remainingString := SubStr(remainingString, match.Len(0) + 1)
		}
	}
	if (timerMode)
	{
		totalSeconds := -totalSeconds
		formulaString := "-(" . formulaString . ")"
	}
	
	result := toTimeDelta(totalSeconds, timerSeconds)
	if (tooltips)
		timedTooltip("Computed on '" . fullMatch.Value(0) . "'.`r`n"
				   . "Computed as " . formulaString . "`r`n"
				   . "Result: " . result, 16000)
	return result
}

toSeconds(hours, minutes, seconds)
{
	; Convert hours, minutes, and seconds into total seconds.
	return hours * 60*60 + minutes * 60 + seconds
}

toTimeDelta(seconds, includeSeconds)
{
	; Convert seconds into a timestamp of the format H:mm:ss, where ':ss' is
	; only included if 'includeSeconds' is true, and 'H:' is only included if
	; more than one hour is represented. If 'seconds' is more than 24 hours,
	; the timestamp is prefixed by '#D,', where # is the number of days.
	
	static timePadFormat := "{:02d}"
	
	result := ""
	if (seconds < 0)
	{
		result .= "-"
		seconds := -seconds
	}
	
	minutes := seconds // 60
	hours := minutes // 60
	days := hours // 24
	
	seconds := Mod(seconds, 60)
	minutes := Mod(minutes, 60)
	hours := Mod(hours, 24)
	
	if (days > 0)
		result .= days . "D,"
	if (days > 0 || hours > 0)
	{
		result .= hours . ":"
		result .= Format(timePadFormat, minutes)
	}
	else
	{
		result .= minutes
	}
	if (includeSeconds)
		result .= ":" . Format(timePadFormat, seconds)
	
	return result
}


; ----- Tray Menu -----

addTrayOption(name, label, variableName)
{
	; Adds a boolean option 'name' to the tray menu, which triggers 'label'
	; and toggles 'variableName'. 'label' must be unique for each option.
	
	Menu Tray, Add, %name%, %label%
	if (%variableName%)
		Menu Tray, Check, %name%
	
	trayVariables[label] := variableName
}

Menu Tray, Add ; Blank makes a separator
addTrayOption("Timer: Time Seconds", "TrayTiSeconds", "timerSeconds")
addTrayOption("Timer: Time Hours", "TrayTiHours", "timerHours")
Menu Tray, Add
addTrayOption("Arithmetic: Timer Mode", "TrayArTimer", "arithmeticTimer")
addTrayOption("Arithmetic: Show Tooltips", "TrayArTooltip", "arithmeticTooltips")
Return

TrayTiSeconds:
TrayTiHours:
TrayArTimer:
TrayArTooltip:
	_trayVarName := trayVariables[A_ThisLabel]
	%_trayVarName% := !%_trayVarName%
	if (A_ThisLabel == "TrayTiSeconds" || A_ThisLabel == "TrayTiHours")
		updateTimerFormats()
	Menu Tray, ToggleCheck, %A_ThisMenuItem%
Return


; ----- Tooltips -----

timedTooltip(text, duration)
{
	; Show a tooltip with 'text' for 'duration' milliseconds.
	; The tooltip may also be manually dismissed by left-clicking anywhere.
	; Unlike AHK's own implementation, dismissing the tooltip works
	; regardless of Windows version.
	ToolTip % text
	SetTimer TooltipHideClick, -1
	SetTimer TooltipHideDelay, % -duration
}

TooltipHideClick:
	KeyWait LButton, D
	ToolTip
Return

TooltipHideDelay:
	ToolTip
Return


; ----- Hotkeys -----

; Simple Timestamps:
; Type the current time or date in various formats.
!T:: Send % currentTime("Time") ; Example: 9:07 AM
^!T:: Send % currentTime("ShortDate") ; Example: 1/30/2016
+!T:: Send % currentTime("M-d-yy") ; Useful for filenames. Example: 1-30-16
^+!T:: Send % currentTime("LongDate") ; Example: Saturday, January 30, 2016

; Timer Timestamps:
; Type the current time in one of two formats, depending on the timerSeconds
; and timerHours options ("Timer: Time Seconds" and "Timer: Time Hours" menu
; options, respectively). Every even-numbered time, the timestamp will
; automatically be preceded by a dash and followed by a space.
!R:: timer(timerFormat) ; Examples: 9:07, 9:07:18, 7:18, 7
^!R:: timer(timerFormatLong) ; Examples: 9:07AM, 9:07:18AM
; Toggle timer state:
; Toggles whether or not the next timer timestamp has the automatic dash/space.
+!R:: timerActive := !timerActive

; Perform arithmetic on selected timestamps, and leave the answer on the
; clipboard. Addition (+) and subtraction (-) are supported; blank spaces,
; commas, semicolons, and newlines are interpreted as addition.
; Extra spaces and double-negatives are allowed.
; Timestamps are assumed to use timerFormat or timerFormatLong at the time
; this is executed; other formats should not be used.
; If arithmeticTimer is true, when there is ambiguity, time will be assumed
; to be increasing, starting from 12AM (e.g. "12:55, 1:10, 1:05" are assumed
; to represent "12:55AM, 1:10AM, 1:05PM"), and the result is negated (giving
; a positive result when used on timer timestamps).
^+!R::
	Clipboard := ""
	Send ^c
	ClipWait 1
	Clipboard := timeArithmetic(Clipboard, arithmeticTimer, arithmeticTooltips)
Return
