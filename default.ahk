#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

;=============================
; Section 0 - Helper functions
;=============================

/**
 * Advanced Window Snap
 * Snaps the Active Window to one of nine different window positions.
 *
 * @author Andrew Moore <andrew+github@awmoore.com>
 * @version 1.0
 */

/**
 * SnapActiveWindow resizes and moves (snaps) the active window to a given position.
 * @param {string} winPlaceVertical   The vertical placement of the active window.
 *                                    Expecting "bottom" or "middle", otherwise assumes
 *                                    "top" placement.
 * @param {string} winPlaceHorizontal The horizontal placement of the active window.
 *                                    Expecting "left" or "right", otherwise assumes
 *                                    window should span the "full" width of the monitor.
 * @param {string} winSizeHeight      The height of the active window in relation to
 *                                    the active monitor's height. Expecting "half" size,
 *                                    otherwise will resize window to a "third".
 */
SnapActiveWindow(winPlaceVertical, winPlaceHorizontal, winSizeHeight) {
    WinGet activeWin, ID, A
    activeMon := GetMonitorIndexFromWindow(activeWin)

    SysGet, MonitorWorkArea, MonitorWorkArea, %activeMon%

    if (winSizeHeight == "full") {
        height := MonitorWorkAreaBottom - MonitorWorkAreaTop
    } else if (winSizeHeight == "half") {
        height := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/2
    } else {
        height := (MonitorWorkAreaBottom - MonitorWorkAreaTop)/3
    }

    if (winPlaceHorizontal == "left") {
        posX  := MonitorWorkAreaLeft
        width := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/2
    } else if (winPlaceHorizontal == "right") {
        posX  := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft)/2
        width := (MonitorWorkAreaRight - MonitorWorkAreaLeft)/2
    } else {
        posX  := MonitorWorkAreaLeft
        width := MonitorWorkAreaRight - MonitorWorkAreaLeft
    }

    if (winPlaceVertical == "bottom") {
        posY := MonitorWorkAreaBottom - height
    } else if (winPlaceVertical == "middle") {
        posY := MonitorWorkAreaTop + height
    } else {
        posY := MonitorWorkAreaTop
    }

    WinMove,A,,%posX%,%posY%,%width%,%height%
}

/**
 * GetMonitorIndexFromWindow retrieves the HWND (unique ID) of a given window.
 * @param {Uint} windowHandle
 * @author shinywong
 * @link http://www.autohotkey.com/board/topic/69464-how-to-determine-a-window-is-in-which-monitor/?p=440355
 */
GetMonitorIndexFromWindow(windowHandle) {
    ; Starts with 1.
    monitorIndex := 1

    VarSetCapacity(monitorInfo, 40)
    NumPut(40, monitorInfo)

    if (monitorHandle := DllCall("MonitorFromWindow", "uint", windowHandle, "uint", 0x2))
        && DllCall("GetMonitorInfo", "uint", monitorHandle, "uint", &monitorInfo) {
        monitorLeft   := NumGet(monitorInfo,  4, "Int")
        monitorTop    := NumGet(monitorInfo,  8, "Int")
        monitorRight  := NumGet(monitorInfo, 12, "Int")
        monitorBottom := NumGet(monitorInfo, 16, "Int")
        workLeft      := NumGet(monitorInfo, 20, "Int")
        workTop       := NumGet(monitorInfo, 24, "Int")
        workRight     := NumGet(monitorInfo, 28, "Int")
        workBottom    := NumGet(monitorInfo, 32, "Int")
        isPrimary     := NumGet(monitorInfo, 36, "Int") & 1

        SysGet, monitorCount, MonitorCount

        Loop, %monitorCount% {
            SysGet, tempMon, Monitor, %A_Index%

            ; Compare location to determine the monitor index.
            if ((monitorLeft = tempMonLeft) and (monitorTop = tempMonTop)
                and (monitorRight = tempMonRight) and (monitorBottom = tempMonBottom)) {
                monitorIndex := A_Index
                break
            }
        }
    }

    return %monitorIndex%
}



SwapMonOfActiveWindow() ; Swaps monitor of active window
{

  SysGet, Mon1, Monitor, 1
  SysGet, Mon2, Monitor, 2
  WinGetPos, WinX, WinY, WinWidth, , A

  WinCenter := WinX + (WinWidth / 2) ; Determines which monitor this is on by the position of the center pixel.
  if (WinCenter > Mon1Left and WinCenter < Mon1Right) {
    WinX := Mon2Left + (WinX - Mon1Left)
  } else if (WinCenter > Mon2Left and WinCenter < Mon2Right) {
    WinX := Mon1Left + (WinX - Mon2Left)
  }

  WinMove, A, , %WinX%, %WinY%
  return
}


; Modifiers:
; # - Win
; ! - Alt
; ^ - Control
; + - Shift

;============================================
; Section 1 - Adjustments for individual keys
;============================================

; Make tilde, backslash and pipe available on GoldTouch Pro
; Note - these seem to require the 'US' keyboard layout to work correctly
$#::send, \
$+#::send, |
$+`::send, ~
;$@::send, "
;$"::send, @


; Shift+3 => octothorpe
+3::send, {#}

; Make CapsLock an Escape key
Capslock::Esc


;=================================
; Section 2 - Common menu commands
;=================================

; Disable Windows keys on their own
; ~LWin Up:: return
; ~RWin Up:: return

; New Document / File
!n::send, ^n

; New Tab
!t::send, ^t

; Open
!o::send, ^o

; Open Location
!l::send, {F6}

; Save
!s::send, ^s

; Print
!p::send, ^p

; Close Window
; Some applications don't respond to Ctrl+F4, so we need to send them Alt+F4 instead
#IfWinActive ahk_exe explorer.exe
  !w::
#IfWinActive ahk_exe notepad.exe
  !w::
  send, !{F4}
#IfWinActive
!w::send, ^{F4}

; Quit / Exit
!q::send, !{F4}

; Undo
!z::send, ^z

; Redo
+!z::send, ^y

; Cut, Copy & Paste
!x::send, ^x
!c::send, ^c
!v::send, ^v

; Find
!f::send, ^f

; Replace
#!f::send, ^h

; Find Next
!g::send, {F3}

; Select All
!a::send, ^a

; Bold / Italic / Underline
!b::send, ^b
!i::send, ^i
!u::send, ^u

; Refresh
!r::send, {F5}

; Chrome Tab Switching
!1::send, ^1
!2::send, ^2
!3::send, ^3
!4::send, ^4
!5::send, ^5
!6::send, ^6
!7::send, ^7
!8::send, ^8
!9::send, ^9

; Back / Forward (Alt+[ / ] map to Alt+Left / Right)
![::send, !{Left}
!]::send, !{Right}

; Zoom in / out / reset
!-::send, ^-
!=::send, ^=
!0::send, ^0

;============================
; Section 3 - Text navigation
;============================

; Win+Left/Right => Forward / back one word
#Left::send, ^{Left}
#Right::send, ^{Right}

; Shift+Win+Left/Right => Select forward / back one word
+#Left::send, +^{Left}
+#Right::send, +^{Right}

; Alt+Left/Right => Start / end of+ line
!Left::send, {Home}
!Right::send, {End}

; Shift+Alt+Left/Right => Select to Start / end of line
+!Left::send, +{Home}
+!Right::send, +{End}

; Win+Backspace => delete back one word
#Backspace::send, ^+{Left}{Del}

; Alt+Backspace => delete back to start of line
!Backspace::send, +{Home}{Del}



;==============================
; Section 4 - Window Management
;==============================

; Snap active window to left or right of screen
^#Left::SnapActiveWindow("top", "left", "full")
^#Right::SnapActiveWindow("top", "right", "full")

; Maximise
^#Up::SnapActiveWindow("full", "full", "full")

; Switch monitor of active window
^#!Left::
^#!Right::
    SwapMonOfActiveWindow()
    SnapActiveWindow("full", "full", "full")
    return





;==================================
; Section 5 - Specific Applications
;==================================

#IfWinActive ahk_exe Evernote.exe

  ; Shift+Alt+U -> create bulleted list
  +!u:: send, +^b

  ; Alt+K -> Hyperlink
  !k:: send, ^k

  ; Shift+Alt+M -> set font to Andale Mono
  +!m::
    send, ^d
    WinWaitActive,Font,,2
    send Andale Mono{enter}
    return

  ; Shift+Alt+N -> set font to Arial
  +!n::
    send ^d
    WinWaitActive,Font,,2
    send Arial{Tab}Regular{enter}
    return

#IfWinActive

#IfWinActive ahk_exe mintty.exe

  ; Alt+C -> Ctrl+Insert (copy)
  !c:: send, ^{Insert}

  ; Alt+V -> Shift+Insert (paste)
  !v:: send, +{Insert}

#IfWinActive
