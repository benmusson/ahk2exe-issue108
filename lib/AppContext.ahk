#Include "..\include\GuiReSizer.ahk"

#Include "DisplayManager.ahk"
#Include "NamedValues.ahk"
#Include "MenuManager.ahk"
#Include "SettingsManager.ahk"


class AppContext {
    __New() {
        this.Version := "${VERSION}"
        this.ReleaseName := "${RELEASE_NAME}"
        this.DisplayManager := DisplayManager()
        this.SettingsManager := SettingsManager(this)

        this.SettingsManager.Load(SettingsManager.configPath)	

        this.GlobalValues := NamedValues()
        this.InitializeGlobals()

        this.GuiMain := Gui()
        this.GuiMain.Title := "Steam AutoLauncher"
        this.GuiMain.OnEvent("Size", GuiResizer)
        this.GuiMain.OnEvent("Escape", (*) => this.GuiMain.Hide)
        this.GuiMain.OnEvent("Close", (*) => {})
        this.GuiMain.Opt("+Resize +MinSize450x350")

        this.MenuManager := MenuManager(this)

        this.GuiAbout := Gui()
        this.GuiAbout.Title := "About"
        this.GuiAbout.OnEvent("Size", GuiResizer)
        this.GuiAbout.Opt("+MinSize450x350")
        this.GuiAbout.Text := {}, this.GuiAbout.Pic := {}, this.GuiAbout.Button := {}
        this.GuiAbout.Text.Name := this.GuiAbout.Add("Text",,"Steam AutoLauncher " this.Version "(x64)")
        license := "
        (
        Copyright (C) 2024 Ben Musson

        This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
        
        This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License along with this program; if not, see <a href="http://www.gnu.org/licenses/gpl-3.0">here</a>.
        )"
        this.GuiAbout.Text.License := this.GuiAbout.Add("Link","w400",license)
    }

    InitializeGlobals() {
        this.GlobalValues := NamedValues()
        this.GlobalValues.Set("date", (*) => FormatTime(, "yyyyMMdd")) 
		this.GlobalValues.Set("myName", "Ben") 
    }

    OpenAbout() {
        this.GuiAbout.Show()
    }

    CloseAbout() {
        this.GuiAbout.Hide
    }
}