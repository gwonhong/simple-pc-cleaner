; Define modules as an array of objects
Modules := [
    {
        Name: "Git",
        Process: "",
        Script: "
        (
        echo resetting git credentials...
        del "%UserProfile%\.eclipse\org.eclipse.equinox.security\secure_storage"
        del "%UserProfile%\.gitconfig"
        cmdkey /delete:git:https://lab.ssafy.com
        )"
    },
    {
        Name: "Chrome",
        Process: "chrome.exe",
        Script: "
        (
        rd /s /q "%localappdata%\google\chrome\user data"
        )"
    },
    {
        Name: "MatterMost",
        Process: "mattermost.exe",
        Script: "
        (
        rd /s /q "%appdata%\mattermost"
        )
        "
    }
    
]

; Create a simple GUI
Gui, Add, Text,, Select modules to apply:
ModuleVars := {}

; Dynamically create checkboxes for each module
Loop, % Modules.MaxIndex()
{
    Module := Modules[A_Index]
    VarName := "Module" . A_Index
    Gui, Add, Checkbox, v%VarName%, %Module.Name%
    ModuleVars[A_Index] := VarName
}

Gui, Add, Checkbox, vShutdownPC, Shutdown PC
Gui, Add, Button, gApply, Apply
Gui, Show,, Application Manager
Return

; Apply button event handler
Apply:
Gui, Submit, NoHide

; Loop through each module and apply the actions if the checkbox is checked
Loop, % Modules.MaxIndex()
{
    Module := Modules[A_Index]
    VarName := ModuleVars[A_Index]
    if (%VarName%)
    {
        ; Close the process if specified
        if (Module.Process != "")
        {
            Process, Close, %Module.Process%
        }
        
        ; Run the script if specified
        if (Module.Script != "")
        {
            ; Expand environment variables and run the script
            ScriptToRun := Module.Script
            EnvGet, localAppData, LOCALAPPDATA
            StringReplace, ScriptToRun, ScriptToRun, %localappdata%, %localAppData%, All
            RunWait, %ComSpec% /c %ScriptToRun%,, Hide
        }
    }
}

; Shutdown the PC if selected
if (ShutdownPC)
{
    Shutdown, 1
}

MsgBox, Actions applied.
Return

; Handle GUI close event
GuiClose:
ExitApp
