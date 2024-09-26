#Requires AutoHotkey v2.0

#Include "Strings.ahk"

class DisplayManager {

    /*

    Resources:
        - EnumDisplayDevicesW function (winuser.h)
            https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumdisplaydevicesw
        - DISPLAY_DEVICEA structure (wingdi.h)
            https://learn.microsoft.com/en-us/windows/win32/api/wingdi/ns-wingdi-display_devicea
        - Get display name that matches that found in display settings
            https://stackoverflow.com/questions/7486485/get-display-name-that-matches-that-found-in-display-settings
        - Secondary Monitor
            https://www.autohotkey.com/board/topic/20084-secondary-monitor/
    */
    EnumDisplayDevices(iDevNum, &DISPLAY_DEVICEA:="", dwFlags:=0) {
        static   
            EDD_GET_DEVICE_INTERFACE_NAME := 0x00000001
            ,byteCount              := 4+4+((32+128+128+128)*2)
            ,offset_cb              := 0
            ,offset_DeviceName      := 4                            ,length_DeviceName      := 32
            ,offset_DeviceString    := 4+(32*2)                     ,length_DeviceString    := 128
            ,offset_StateFlags      := 4+((32+128)*2)
            ,offset_DeviceID        := 4+4+((32+128)*2)             ,length_DeviceID        := 128
            ,offset_DeviceKey       := 4+4+((32+128+128)*2)         ,length_DeviceKey       := 128
    
        DISPLAY_DEVICEA := ""
    
        if (iDevNum ~= "\D" || (dwFlags !=0 && dwFlags != EDD_GET_DEVICE_INTERFACE_NAME))
            return false
    
        lpDisplayDevice := Buffer(byteCount,0)
        Numput("UInt", byteCount, lpDisplayDevice, offset_cb)
    
        if !DllCall("EnumDisplayDevices", "Ptr",0, "UInt",iDevNum, "Ptr",lpDisplayDevice.Ptr, "UInt",0)
            return false
    
        if (dwFlags == EDD_GET_DEVICE_INTERFACE_NAME)    {
            DeviceName := StrGet(lpDisplayDevice.Ptr + offset_DeviceName, length_DeviceName)
    
            lpDisplayDevice.__New(byteCount, 0), Numput("UInt",byteCount, lpDisplayDevice, offset_cb)
            lpDevice := Buffer(length_DeviceName * 2, 0), StrPut(DeviceName, lpDevice, length_DeviceName)
    
            DllCall("EnumDisplayDevices", "Ptr",lpDevice.Ptr, "UInt",0, "Ptr",lpDisplayDevice.Ptr, "UInt",dwFlags)
        }
    
        DISPLAY_DEVICEA := Map( 
            "cb", 0,
            "DeviceName", "",
            "DeviceString", "",
            "StateFlags", 0,
            "DeviceID", "",
            "DeviceKey", ""
        )
        for key in (DISPLAY_DEVICEA) {
            switch key
            {
                case "cb","StateFlags":  DISPLAY_DEVICEA[key] := NumGet(lpDisplayDevice, offset_%key%, "UInt")
                default:                 DISPLAY_DEVICEA[key] := StrGet(lpDisplayDevice.Ptr + offset_%key%, length_%key%)
            }
        }
        return true
    }

    /**
     * Get an array of monitors using WMI backend.
     * @returns {Array} an array of maps, each index representing a monitor.
     *  Monitor Keys:
     *      `Active` (int),
     *      `InstanceName` (string),
     *      `ManufacturerName` (string),
     *      `ProductCodeID` (string),
     *      `SerialNumberID` (string),
     *      `WeekOfManufacture` (int),
     *      `YearOfManufacture` (int),
     *      `UserFriendlyName` (string)
     */
    GetWMIMonitors() {
        monitors := []
        wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")
        for monitor in wmi.ExecQuery("Select * from WmiMonitorID") {
            fname := ""
            for char in monitor.UserFriendlyName
                fname .= chr(char)
    
            m := Map()
            m["Active"] := monitor.Active
            m["InstanceName"] := monitor.InstanceName
            m["ManufacturerName"] := ComObjArrayToString(monitor.ManufacturerName)
            m["ProductCodeID"] := ComObjArrayToString(monitor.ProductCodeID)
            m["SerialNumberID"] := ComObjArrayToString(monitor.SerialNumberID)
            m["WeekOfManufacture"] := monitor.WeekOfManufacture
            m["YearOfManufacture"] := monitor.YearOfManufacture
            m["UserFriendlyName"] := ComObjArrayToString(monitor.UserFriendlyName)
            monitors.Push(m)
        }
    
        return monitors
    }
    
    /**
     * Get an array of interfaces using GDI backend.
     * @returns {Array} an array of maps
     */
    GetGDIInterfaces() {
        interfaces := Array()
        while this.EnumDisplayDevices(A_Index-1, &interface) {
            if !interface["StateFlags"]
                continue
            interfaces.Push(interface)
        }
        return interfaces
    }
    
        /**
     * Get an array of displays using GDI backend.
     * @returns {Array} an array of maps
     */
    GetGDIDisplays() {
        displays := Array()
        while this.EnumDisplayDevices(A_Index-1, &display, 1) {
            if !display["StateFlags"]
                continue
            displays.Push(display)
        }
        return displays
    }
    
    GetInterfaces() {
        displays := Map()
        displays["interfaces"] := this.GetGDIInterfaces()
        displays["displays"] := this.GetGDIDisplays()
        displays["monitors"] := this.GetWMIMonitors()
    
        for display in displays["displays"] {
            for monitor in displays["monitors"] {
                if InStr(display["DeviceID"], monitor["InstanceName"]) {
                    display["FriendlyName"] := monitor["FriendlyName"]
                }
            }
        }
        return displays
    }

    /**
     * Show a MessageBox with all inteface information.
     */
    ShowInterfaces() {
        interfaces := this.GetInterfaces()
        text := ""
        for gpu in interfaces["interfaces"] {
            text .= "Interface #" A_Index "`n"
            for key, value in gpu {
                text .= key " : " value "`n"
            }
            text .= "`n"
        }

        for display in interfaces["displays"] {
            text .= "Display #" A_Index "`n"
            for key, value in display {
                text .= key " : " value "`n"
            }
            text .= "`n"
        }

        for monitor in interfaces["monitors"] {
            text .= "Monitor #" A_Index "`n"
            for key, value in monitor {
                text .= key " : " value "`n"
            }
            text .= "`n"
        }
        MsgBox text
    }


    ChangeResolution(Screen_Width := 1920, Screen_Height := 1080, Color_Depth := 32) {
        Device_Mode := Buffer(156, 0)
        NumPut("UShort", 156, Device_Mode, 36)
        DllCall("EnumDisplaySettingsA", "UInt",0, "UInt",-1, "Ptr",Device_Mode)
        NumPut("UInt", 0x5c0000, Device_Mode, 40)
        NumPut("UInt", Color_Depth, Device_Mode, 104)
        NumPut("UInt", Screen_Width, Device_Mode, 108)
        NumPut("UInt", Screen_Height, Device_Mode, 112)
        Return DllCall( "ChangeDisplaySettingsA", "Ptr",Device_Mode, "UInt",0 )
    }

    ChangeResolution2() {
        static   
            byteCount              := 4+4+((32+128+128+128)*2)
            ,offset_cb              := 0
            ,offset_DeviceName      := 4                            ,length_DeviceName      := 32
            ,offset_DeviceString    := 4+(32*2)                     ,length_DeviceString    := 128
            ,offset_StateFlags      := 4+((32+128)*2)
            ,offset_DeviceID        := 4+4+((32+128)*2)             ,length_DeviceID        := 128
            ,offset_DeviceKey       := 4+4+((32+128+128)*2)         ,length_DeviceKey       := 128
    }

    /**
     * 
     * @returns {Array} a list of attached monitors' UserFriendlyNames
     */
    ListMonitors() {
        monitors := this.GetWMIMonitors()
        a := Array()
        for monitor in monitors {
            a.Push(monitor["UserFriendlyName"])
        }
        return a
    }
}
