
#Requires Autohotkey v2
#SingleInstance Force

#Include "include\GuiReSizer.ahk"
#Include "include\LightJson.ahk"
#Include "lib\AppContext.ahk"

guiCommon := {
	margin: 8
}

/**
 * Tray definition 
 */
A_IconTip := "Steam AutoLauncher"
TraySetIcon( A_WorkingDir . "\images\favicon.ico",,true)
TrayTip("(Win + H) to Open...", "Steam AutoLauncher Started")


/**
 * Initialize Application Context
 */
context := AppContext()

/**
 * Main GUI
 */
ui := context.GuiMain

ui.Tab := {}
ui.Tab.Nav := ui.Add("Tab3",, ["Events"])
ui.Tab.Nav.W := -8
ui.Tab.Nav.H := -8

ui.Tab.Nav.UseTab("Events")
ui.DropDownList := {}, ui.Checkbox := {}, ui.Button := {}
ui.DropDownList.Displays := ui.Add("DropDownList", "", context.DisplayManager.ListMonitors())
ui.Button.RefreshDisplays := ui.Add("Button", "", "Refresh")
ui.Checkbox.EnableAutoLaunch := ui.Add("Checkbox", "", "Enable AutoLaunch")

; context.GuiMain.Edit := {}, context.GuiMain.Button := {}, context.GuiMain.ListView := {}, context.GuiMain.Checkbox := {}

; context.GuiMain.ListView := context.HotstringManager.InitializeListView(context.GuiMain)
; context.GuiMain.ListView.Y := (4*guiCommon.margin)
; context.GuiMain.ListView.H := -24 - (3*guiCommon.margin)
; context.GuiMain.ListView.W := -(3*guiCommon.margin) + 2

; context.GuiMain.Button.HotstringDelete := context.GuiMain.Add("Button",, "Delete")
; context.GuiMain.Button.HotstringDelete.H := 24
; context.GuiMain.Button.HotstringDelete.W := 60
; context.GuiMain.Button.HotstringDelete.X := -80
; context.GuiMain.Button.HotstringDelete.Y := - (2*guiCommon.margin) - context.GuiMain.Button.HotstringDelete.H
; context.GuiMain.Button.HotstringDelete.OnEvent("Click", (*) => context.HotstringManager.Delete())

; context.GuiMain.Button.HotstringAdd := context.GuiMain.Add("Button",, "Add")
; context.GuiMain.Button.HotstringAdd.H := 24
; context.GuiMain.Button.HotstringAdd.W := 60
; context.GuiMain.Button.HotstringAdd.X := context.GuiMain.Button.HotstringDelete.X - context.GuiMain.Button.HotstringAdd.W - guiCommon.margin
; context.GuiMain.Button.HotstringAdd.Y := - (2*guiCommon.margin) - context.GuiMain.Button.HotstringAdd.H
; context.GuiMain.Button.HotstringAdd.OnEvent("Click", (*) => context.HotstringManager.OpenNewEditor())

/**
 * Load Hotstrings (Once GUI is Ready)
 */
; context.HotstringManager.Load(context.SettingsManager.settings['hotstrings']['filePath'])

; GetDisplays() {
; 	displays := []
; 	Loop MonitorGetCount() {
		
; 		MonitorGet A_Index, &L, &T, &R, &B
; 		MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB

; 		display := map()
; 		display["id"] := A_Index
; 		display["name"] := MonitorGetName(A_Index)
; 		display["left"] := L
; 		display["top"] := T
; 		display["right"] := R
; 		display["bottom"] := B
; 		display["workingLeft"] := WL
; 		display["workingTop"] := WT
; 		display["workingRight"] := WR
; 		display["workingBottom"] := WB
; 		displays.Push(display)
; 	}
; 	return displays
; }

ListDisplays(displays) {
	for display in displays {
		MsgBox
		(
			"Monitor:`t#" display.Get("id") "
			Name:`t" display.Get("name") "
			Left:`t" display.Get("left") " (" display.Get("workingLeft") " work)
			Top:`t" display.Get("top") " (" display.Get("workingTop") " work)
			Right:`t" display.Get("right") " (" display.Get("workingRight") " work)
			Bottom:`t" display.Get("bottom") " (" display.Get("workingBottom") " work)"
		)
	}
}
	

WM_DISPLAYCHANGE(wParam, lParam, msg, hwnd) {
	MsgBox "WM_DISPLAYCHANGE!`nwParam:" wParam "`nlParam: " lParam
	Run "steam://open/bigpicture"
	; displays := GetDisplays()
	; MonitorCount := MonitorGetCount()
	; MonitorPrimary := MonitorGetPrimary()
	; MsgBox "Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary
	; Loop MonitorCount
	; {
	; 	MonitorGet A_Index, &L, &T, &R, &B
	; 	MonitorGetWorkArea A_Index, &WL, &WT, &WR, &WB
	; 	MsgBox
	; 	(
	; 		"Monitor:`t#" A_Index "
	; 		Name:`t" MonitorGetName(A_Index) "
	; 		Left:`t" L " (" WL " work)
	; 		Top:`t" T " (" WT " work)
	; 		Right:`t" R " (" WR " work)
	; 		Bottom:`t" B " (" WB " work)"
	; 	)
	; }
}

OnMessage(0x7E, WM_DISPLAYCHANGE)
/**
 * Hotkeys
 */
#SuspendExempt
#h:: context.GuiMain.Show
#ESC:: Reload


/**
 * Demo?
 */
#Include "include\XInput.ahk"
XInput_Init()
Loop {
    Loop 4 {
        if State := XInput_GetState(A_Index-1) {
            LT := State.bLeftTrigger
            RT := State.bRightTrigger
            XInput_SetState(A_Index-1, LT*257, RT*257)
        }
    }
    Sleep 100
}

; /**
;  * Fix Ctrl+Backspace for applications that use special characters.
;  */
; #HotIf WinActive("ahk_class AutoHotkeyGUI")
; #HotIf WinActive('ahk_exe LogixDesigner.Exe')
; ^BS::Send("^+{Left}{Delete}")
; #HotIf

#SuspendExempt false
