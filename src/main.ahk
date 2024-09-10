Modules := [{
    Name: "git_certs",
    DisplayName: "Git Certs (lab.ssafy.com, github.com)",
    Processes: [],
    Script: "
(
del %UserProfile%\.gitconfig
cmdkey /delete:git:https://lab.ssafy.com
cmdkey /delete:git:https://github.com
)"
}, {
    Name: "eclipse_secure_storage",
    DisplayName: "Eclipse Secure Storage",
    Processes: ["SpringToolSuite4.exe", "eclipse.exe"
    ],
    Script: "
(
del %UserProfile%\.eclipse\org.eclipse.equinox.security\secure_storage
)"
}, {
    Name: "Chrome",
    Processes: ["chrome.exe"
    ],
    Script: "
(
rmdir /s /q "%localappdata%\google\chrome\user data"
)"
}, {
    Name: "MatterMost",
    Processes: ["mattermost.exe"
    ],
    Script: "
(
rmdir /s /q "%appdata%\mattermost"
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

    if module.HasProp("DisplayName") {
        checkbox := MainGui.AddCheckBox("v" module.Name, module.DisplayName)
    } else {
        checkbox := MainGui.AddCheckBox("v" module.Name, module.Name)
    }

    ModuleCheckBoxes.Push(checkbox)
}

ShutdownPC := MainGui.AddCheckbox("vShutdownPC", "Shutdown PC")
RunButton := MainGui.AddButton(, "Run")
RunButton.OnEvent("Click", Run)

MainGui.Show

RunMultilineScript(scriptToRun) {
    shell := ComObject("WScript.Shell")
    ; Open cmd.exe with echoing of commands disabled
    exec := shell.Exec(A_ComSpec " /Q /K")
    ; Send the commands to execute, separated by newline
    exec.StdIn.WriteLine(scriptToRun "`nexit")  ; Always exit at the end!
    ; Read and return the output of all commands
    return exec.StdOut.ReadAll()
}

; Apply button event handler
Run(*) {
    global Modules, ModuleCheckBoxes, ShutdownPC

    wholeScript := ""
    ; Loop through each module and apply the actions if the checkbox is checked
    for index, module in Modules {
        if ModuleCheckBoxes[index].Value {
            ; Close the processes if specified
            for _, process in module.Processes {
                while ProcessExist(process)
                    ProcessClose process
            }
            ; Build up a single script
            wholeScript := wholeScript . module.Script . "`n"
        }
    }

    ; Run the whole scripts at once
    result := RunMultilineScript(wholeScript)

    ; Shutdown the PC if selected
    if ShutdownPC.Value
        Shutdown(1)

    MsgBox("Execution Result:`n`n" . result . "`n`nDone!")
}

; Handle GUI close event
MainGui.OnEvent("Close", GuiClose)

GuiClose(*) {
    ExitApp()
}
