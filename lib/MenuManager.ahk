#Requires AutoHotkey v2.0

class MenuManager {
    __New(context) {
        this.context := context
        
        this.FileMenu := Menu()
        this.FileMenu.Add("&Open Settings...`tCtrl+O", (*) => context.SettingsManager.PromptLoad())
        this.FileMenu.Add("&Save Settings`tCtrl+S", (*) => context.SettingsManager.Autosave())
        this.FileMenu.Add("Save Settings As...", (*) => context.SettingsManager.SaveAs())
        this.FileMenu.Add()
        this.FileMenu.Add("Minimize`tWin+H", (*) => context.GuiMain.Hide())
        this.FileMenu.Add("Exit", (*) => ExitApp())
        this.FileMenu.SetIcon("&Open Settings...`tCtrl+O","shell32.dll", 4)
        this.FileMenu.SetIcon("&Save Settings`tCtrl+S","shell32.dll", 259)
        
        this.HelpMenu := Menu()
        this.HelpMenu.Add("&Help`tF1", this.MenuHandler)
        this.HelpMenu.Add()
        this.HelpMenu.Add("About", (*) => this.context.OpenAbout())
        this.HelpMenu.SetIcon("&Help`tF1","shell32.dll", 24)
        this.MenuBar := MenuBar()
        this.MenuBar.Add("&File", this.FileMenu)
        this.MenuBar.Add("Help", this.HelpMenu)
        this.context.GuiMain.MenuBar := this.MenuBar
    }


    MenuHandler(*) {
        ToolTip("Click! This is a sample action.`n")
        SetTimer () => ToolTip(), -3000
    }
}
