#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#singleinstance, force
msgbox Motosnip v1.00, (C) 2017 APS Inc`n`nInvoke with backslash \,`n point-space-point-space,`n Done!`n`nCtrl-Alt-Y to unload MotoSnip.
filecounter = 0
return

\::
coordmode,mouse,screen
coordmode,pixel,screen
SaveFolder = %a_ScriptDir%
msgbox Click OK. Then...`n`nPoint to top left of capture`n and press key.`n Then point to bottom right`n and press key.
fileCounter++
Filename = %FileCounter%.bmp
Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
; get position of mouse when first key pressed
MouseGetPos, Press1X, Press1Y
Input, SingleKey, L1, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
; get position of mouse when second key pressed
MouseGetPos, Press2X, Press2Y
; tell user it's in progress - show message to the right or left of the X, at same Y-ish

WMY := Press2Y - Press1Y
WMY := WMY / 2
WMY := WMY + Press1Y
WMY := WMY - 35
WMX = 100 ; obviously replaced by the calculations below!
if (Press1X) > 320
	WMX := Press1X - 200
else
	WMX := Press2X + 100
SplashTextOn,100,70,MOTOSNIP,Capture in progress to %Filename%
sleep 20
WinActivate,MOTOSNIP
sleep 20
WinMove,MOTOSNIP,,%WMX%,%WMY%

; move the mouse out of the way
MouseMove, 125, 125, 90, R

XWidth := Press2X-Press1X
YHeight := Press2Y-Press1Y
pixelrow = 0
WidthInBytes := Xwidth * 3
WidthLeftoverBits := mod(WidthInBytes,4)
WidthPadoutBits := 4-WidthLeftoverBits
if WidthPadoutBits = 4
	WidthPadoutBits = 0 ; because 4 is a whole and can be thrown away
SizeOfBitmap := XWidth + WidthPadoutBits ; intermediate sum - one line
SizeOfBitmap := YHeight * SizeOfBitmap
;create the initial file to build out
file := FileOpen(Filename,"w")
; write a standard bitmap file header.
bit1 := "B"
bit2 := "M"
file.RawWrite(bit1,1)
file.RawWrite(bit2, 1)
SizeOfFile = SizeOfBitmap + 54
ByteD := floor(SizeOfFile/16777216)
Remainder := mod(SizeOfFile,16777216)
ByteC := floor(Remainder/65536)
Remainder := mod(Remainder,65536)
ByteB := floor(Remainder/256)
ByteA := mod(Remainder,256)
file.WriteChar(ByteA)
file.WriteChar(ByteB)
file.WriteChar(ByteC)
file.WriteChar(ByteD)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0x36)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0x28)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
ByteD := floor(XWidth/16777216)
Remainder := mod(XWidth,16777216)
ByteC := floor(Remainder/65536)
Remainder := mod(Remainder,65536)
ByteB := floor(Remainder/256)
ByteA := mod(Remainder,256)
file.WriteChar(ByteA)
file.WriteChar(ByteB)
file.WriteChar(ByteC)
file.WriteChar(ByteD)
ByteD := floor(YHeight/16777216)
Remainder := mod(YHeight,16777216)
ByteC := floor(Remainder/65536)
Remainder := mod(Remainder,65536)
ByteB := floor(Remainder/256)
ByteA := mod(Remainder,256)
file.WriteChar(ByteA)
file.WriteChar(ByteB)
file.WriteChar(ByteC)
file.WriteChar(ByteD)
file.WriteChar(0x01)
file.WriteChar(0)
file.WriteChar(0x18)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0x4b)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)
file.WriteChar(0)

;that finishes the header. Now we'll copy the bits out of the section of the screen we defined.
LoopX=%Press1X%
LoopY=%Press2Y%
loop %YHeight%
{
	loop %XWidth%
	{
		LoopX++
		PixelGetColor,BlueGreenRed,LoopX,LoopY
		Blue := "0x" . substr(BLueGreenRed,3,2)
		file.WriteChar(Blue)
		Green := "0x" . substr(BlueGreenRed,5,2)
		file.WriteChar(Green)
		Red := "0x" . substr(BlueGreenRed,7,2)
		file.WriteChar(Red)
	}
	Loopy--
	PixelRow++
	; now pad out to the even number width
	loop %WidthPadoutBits%
	{
		file.WriteChar(0)
	}
	LoopX = %Press1X% ; reset to the edge again for next row
}
; done writing the file. turn off the message.
file.close()
SplashTextOff
return

;Our emergency exit
^!y::
ExitApp
