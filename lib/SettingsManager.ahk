#Include "..\include\LightJson.ahk"
#Include "Strings.ahk"

class SettingsManager {

	static configPath := A_AppData . "\Steam AutoLauncher\settings.json"

	settings := {
		autolaunch: {
			enabled: true,
			triggers: []
		},
	}

	__New(context) {
		this.context := context
		if(!FileExist(SettingsManager.configPath)) {
			DirCreate(A_AppData . "\Steam AutoLauncher")
			FileAppend(this.Serialize(this.settings), SettingsManager.configPath)
			this.Autosave()
		}
	}

	/**
	 * Prompt the user to open and load a settings file.
	 */
	PromptLoad() {
		filePath := FileSelect("1", SettingsManager.configPath, "Open Steam AutoLauncher Settings", "Steam AutoLauncher Settings (*.json)")
		if(filePath = "") {
			return
		}
		this.Load(filePath)
	}

	/**
	 * Load a settings file.
	 * @param {String} FileName
	 */
	Load(FileName) {
		try {
			json := FileRead(FileName)
			savedObj := LightJson.Parse(json)
		}
		catch {
			MsgBox("Error parsing settings file.", "Error", 16)
			this.SaveAs()
			return
		}
		this.settings := savedObj
		this.Autosave()
	}

	/**
	 * Save configured settings to a file.
	 * @param {String} FileName
	 */
	Save(FileName) {
		try FileMove(FileName, FileName ".bak", true)
		FileAppend(this.Serialize(this.settings), FileName)
		try FileDelete(FileName ".bak")
	}

	Autosave() {
		this.Save(SettingsManager.configPath)
	}

	Serialize(settings) {
		return LightJson.Stringify(settings, "`t")
	}

	/**
	 * Prompt the user to save configured settings to a new file.
	 */
	SaveAs() {
		filePath := FileSelect("S8", SettingsManager.configPath, "Save Steam AutoLauncher Settings", "Steam AutoLauncher Settings (*.json)")
		if(filePath = "") {
			return
		}
		this.Save(filePath)
	}

	AutoLaunchSetEnabled(value) {
		this.settings.autolaunch.enabled := value
	}

	AutoLaunchToggle(value) {
		this.AutoLaunchSetEnabled(!this.settings.autolaunch.enabled)
		state := (this.settings.autolaunch.enabled ? "Enabled" : "Disabled")
		SetTimer () => ToolTip(), -5000
		TrayTip("Auto Launch " state, "Steam AutoLauncher")
		; (this.settings['hotstrings']['enabled'] ? Suspend(false) : Suspend(true))
	}

	SetControlDelay(Value) {
		this.settings.delay.control := Value
	}

	SetWindowDelay(Value) {
		this.settings.delay.window := Value
	}
}
