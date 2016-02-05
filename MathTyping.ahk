; Math/Greek Typing Script by Gerrard Lukacs

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

global alphabeticalGreek := false
global latinToGreek := {a:"α", b:"β", c:"χ", d:"δ", e:"ε", f:"φ"
                      , g:"γ", h:"η", i:"ι", k:"κ", l:"λ", m:"μ"
                      , n:"ν", o:"ο", p:"π", q:"θ", r:"ρ", s:"σ"
                      , t:"τ", u:"υ", w:"ω", x:"ξ", y:"ψ", z:"ζ"}

initializeHotkeys()
Menu Tray, Add    ; Blank makes a separator
Menu Tray, Add, Alphabetical Greek, TrayGreek
if (alphabeticalGreek)
    Menu Tray, Check, Alphabetical Greek
Return

initializeHotkeys()
{
    letter := Asc("a")
    endLetter := Asc("z")
    
    while (letter <= endLetter)
    {
        Hotkey % "!" . Chr(letter), LowerGreekHotkey
        Hotkey % "+!" . Chr(letter), UpperGreekHotkey
        letter++
    }
}

lowerGreek(latin)
{
    static a := Asc("a")
    static alpha := Asc("α")
    static finalSigma := Asc("ς")
    
    if (alphabeticalGreek)
    {
        if (latin >= "y")
            return ""
        
        greek := Asc(latin) - a + alpha
        if (greek >= finalSigma)
            greek++
        return Chr(greek)
    }
    else
    {
        return latinToGreek[latin]
    }
}

upperGreek(latin)
{
    static upperDist := Asc("α") - Asc("Α") ; Uppercase Alpha
    ; Note: final sigma has no uppercase form, but Unicode leaves
    ; a blank slot so all the numbers line up nicely.
    
    greek := lowerGreek(latin)
    return Chr(Asc(greek) - upperDist)
}

TrayGreek:
    alphabeticalGreek := !alphabeticalGreek
    Menu Tray, ToggleCheck, Alphabetical Greek
    Return

LowerGreekHotkey:
    Send % lowerGreek(SubStr(A_ThisHotkey, 2))
    Return

UpperGreekHotkey:
    Send % upperGreek(SubStr(A_ThisHotkey, 3))
    Return

; By default, Alt with a Latin letter produces its corresponding Greek
; letter, e.g. αβχδεφγ (there are no Greek letters for j or v. h is η,
; q is θ, c is χ, x is ξ, u is υ, y is ψ, and w is ω). If "Alphabetical
; Greek" is selected from the tray menu, letters are transliterated
; alphabetically, e.g. αβγδεζη (there are no letters for y and z).
; Alt with a capital letter works similarly: ΑΒΧΔΕΦΓ / ΑΒΓΔΕΖΗ.

^!s:: Send ς  ; Final Sigma            Ctrl Alt s

^!a:: Send ∀ ; For All                Ctrl Alt a
^!e:: Send ∃ ; There Exists           Ctrl Alt e
^!t:: Send ∴ ; Therefore              Ctrl Alt t
^!b:: Send ∵ ; Because                Ctrl Alt b
^!d:: Send ∆  ; Delta/change           Ctrl Alt d
^!+d::Send ∇ ; Del Operator           Ctrl Alt D
^!+p::Send ∏  ; Product                Ctrl Alt P
^!+s::Send ∑  ; Summation              Ctrl Alt S
^!r:: Send √  ; Square Root            Ctrl Alt r
^!i:: Send ∫  ; Integral               Ctrl Alt i
!8::  Send ∞  ; Infinity                    Alt 8
!0::  Send Ø  ; Empty Set*                  Alt 0
              ; *This is actually Capital O with Stroke, because the
              ; actual Empty Set symbol doesn't render in Notepad++.

!+,:: Send ≤  ; Less Than or Equal To       Alt <
!+.:: Send ≥  ; Greater Than or Equal To    Alt >
!=::  Send ≠  ; Not Equal                   Alt =
!+=:: Send ±  ; Plus or Minus               Alt +
!+8:: Send ×  ; Multiplication              Alt *
!/::  Send ÷  ; Division                    Alt /
!.::  Send ∙  ; Bullet Operator             Alt .
!-::  Send ‾  ; Overline                    Alt -

!3::  Send ∈ ; Element of                  Alt 3
^!3:: Send ∋ ; Contains as Member     Ctrl Alt 3
!+9:: Send ⊂ ; Subset                      Alt (
!+0:: Send ⊃ ; Superset                    Alt )
^!+9::Send ⊆ ; Subset or Equal To     Ctrl Alt (
^!+0::Send ⊇ ; Superset or Equal To   Ctrl Alt )
^!u:: Send ∪ ; Union                  Ctrl Alt u
^!+u::Send ∩  ; Intersection           Ctrl Alt U
^!v:: Send ∨ ; Disjunction            Ctrl Alt v
!+6:: Send ∧ ; Conjunction                 Alt ^
