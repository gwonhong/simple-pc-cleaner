Modules := [{ Name: "Git", Process: "", Script: "
    (
    echo resetting git credentials...
    del `%UserProfile%\.eclipse\org.eclipse.equinox.security\secure_storage
    del `%UserProfile%\.gitconfig
    cmdkey /delete:git:https://lab.ssafy.com
    )"
}, { Name: "Chrome", Process: "chrome.exe", Script: "
    (
    rd /s /q `%localappdata%\google\chrome\user data
    )"
}, { Name: "MatterMost", Process: "mattermost.exe", Script: "
    (
    rd /s /q `%appdata%\mattermost
    )"
}
]

; Create a simple GUI
MainGui := Gui()
MainGui.AddText(, "Select modules to apply:")
ModuleCheckBoxes := []

; Dynamically create checkboxes for each module
for index, module in Modules {
    VarName := "Module" . (index + 1)
    checkbox := MainGui.AddCheckBox("v" module.Name, module.Name)
    ModuleCheckBoxes.Push(checkbox)
}

ShutdownPC := MainGui.AddCheckbox("vShutdownPC", "Shutdown PC")
RunButton := MainGui.AddButton(, "Run")
RunButton.OnEvent("Click", Run)

MainGui.Show

; Apply button event handler
Run(*) {
    global Modules, ModuleCheckBoxes, ShutdownPC

    ; Loop through each module and apply the actions if the checkbox is checked
    for index, module in Modules {
        if ModuleCheckBoxes[index].Value {
            ; Close the process if specified
            if module.Process != ""
                ProcessClose(module.Process)

            ; Run the script if specified
            if module.Script != ""
            {
                ; Expand environment variables and run the script
                ScriptToRun := module.Script
                localAppData := EnvGet("LOCALAPPDATA")
                appData := EnvGet("APPDATA")
                StrReplace(ScriptToRun, "%localappdata%", localAppData)
                StrReplace(ScriptToRun, "%appdata%", appData)
                RunWait(A_ComSpec " /c " ScriptToRun, "", "Hide")
            }
        }
    }

    ; Shutdown the PC if selected
    if ShutdownPC.Value
        Shutdown(1)

    MsgBox("Actions applied.")
}

; Handle GUI close event
MainGui.OnEvent("Close", GuiClose)

GuiClose(*) {
    ExitApp()
}
