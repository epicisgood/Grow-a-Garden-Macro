#Requires AutoHotkey v2.0

version := "v1.3.8"
settingsFile := "settings.ini"





if (A_IsCompiled) {
	WebViewCtrl.CreateFileFromResource((A_PtrSize * 8) "bit\WebView2Loader.dll", WebViewCtrl.TempDir)
    WebViewSettings := {DllPath: WebViewCtrl.TempDir "\" (A_PtrSize * 8) "bit\WebView2Loader.dll"}
    guipath := A_WorkingDir
} else {
    WebViewSettings := {}
    TraySetIcon("images\\GameIcon.ico")
    guipath := ''
}


MyWindow := WebViewGui("-Resize -Caption ",,,WebViewSettings) ; ignore error it somehow works with it.....
MyWindow.Navigate(guipath "\scripts\Gui\index.html")
MyWindow.OnEvent("Close", (*) => StopMacro())
; MyWindow.Navigate("scripts/Gui/index.html")
MyWindow.AddHostObjectToScript("ButtonClick", { func: WebButtonClickEvent })
MyWindow.AddHostObjectToScript("Save", { func: SaveSettings })
MyWindow.AddHostObjectToScript("ReadSettings", { func: SendSettings })

MyWindow.Show("w600 h400")



F1::{
    Start
}

F3::{
    ResetMacro
}

Alt & S:: {
    ResetMacro
}

Start(*) {

    PlayerStatus("Starting " version " Grow A Garden Macro by epic", "0xFFFF00", , false, , false)
    OnError (e, mode) => (mode = "return") * (-1)
    Loop {
        MainLoop() 
    }
}

ResetMacro(*) { 
    ; PlayerStatus("Stopped Grow A Garden Macro", "0xff8800", , false, , false)
    Send "{" Dkey " up}{" Wkey " up}{" Akey " up}{" Skey " up}{F14 up}"
    Try Gdip_Shutdown(pToken)
    Reload 
}
StopMacro(*) {
    PlayerStatus("Closed Grow A Garden Macro", "0xff5e00", , false, , false)
    Send "{" Dkey " up}{" Wkey " up}{" Akey " up}{" Skey " up}{F14 up}"
    Try Gdip_Shutdown(pToken)
    ExitApp()
}

PauseToggle := true
PauseMacro(*){
    global PauseToggle
    PauseToggle := !PauseToggle
    if PauseToggle {
        Pause(false) ; Unpause
        ToolTip "Macro Unpaused"
        PlayerStatus("Unpaused Grow A Garden Macro", "0x91ff00", , false, , false)
    } else {
        Pause(true)  ; Pause
        ToolTip "Macro Paused"
        PlayerStatus("Paused Grow A Garden Macro", "0x003cff", , false, , false)
    }
    SetTimer () => ToolTip(), -1000
}




ScreenResolution() {
    if (A_ScreenDPI != 96) {
        MsgBox "
        (
        Your Display Scale seems to be ≠100%. The macro will NOT work correctly!
        Set Scale to 100% in Display Settings, then restart Roblox & this macro.
        Windows key > change the resolution of display > Scale > 100%
        )", "WARNING!!", 0x1030 " T60"
    }
}
ScreenResolution()

if (WinExist("Roblox ahk_exe ApplicationFrameHost.exe")){
        MsgBox "
        (
        Please change your roblox to website version, Your corrently are using microsoft version.
        Download roblox from the official website https://www.roblox.com/download
        )", "WARNING!!", 0x1030 " T60"
}




WebButtonClickEvent(button) {
    switch button {
        case "Start":
            Send("{F1}")
        case "Pause":
			Send("{F2}")
        case "Stop":
			Send("{F3}")
	}
}



global CORE_SETTINGS := ["url", "discordID", "VipLink", "Cosmetics", "TravelingMerchant", "CookingEvent", "SearchList", "CookingTime", "ThemeToggle"]
global CATEGORIES    := ["Seeds", "Gears", "Eggs", "GearCrafting", "SeedCrafting", "EasterSeed", "CreepyCritters"]

SaveSettings(settingsJson) {
    settings := JSON.Parse(settingsJson)
    IniFile := A_WorkingDir . "\settings.ini"

    for key, val in settings {
        for coreKey in CORE_SETTINGS {
            if (key == coreKey) {
                IniWrite(val, IniFile, "Settings", key)
                break
            }
        }
    }

    if settings.Has("dynamicItems") {
        for categoryName, items in settings["dynamicItems"] {
            for itemName, isEnabled in items {
                sanitizedKey := StrReplace(itemName, " ", "")
                IniWrite(isEnabled ? 1 : 0, IniFile, categoryName, sanitizedKey)
            }
        }
    }
    ; MsgBox("Saved settings.",, "T0.5")
}

SendSettings() {
    settingsFile := A_WorkingDir . "\settings.ini"
    
    if (!FileExist(settingsFile)) {
        IniWrite("",  settingsFile, "Settings", "url")
        IniWrite("",  settingsFile, "Settings", "discordID")
        IniWrite("",  settingsFile, "Settings", "VipLink")
        IniWrite("0", settingsFile, "Settings", "Cosmetics")
        IniWrite("1", settingsFile, "Settings", "TravelingMerchant")
        IniWrite("0", settingsFile, "Settings", "CookingEvent")
        IniWrite("",  settingsFile, "Settings", "SearchList")
        IniWrite("",  settingsFile, "Settings", "CookingTime")
        IniWrite("0", settingsFile, "Settings", "ThemeToggle")

        for category in CATEGORIES {
            defaultState := (category == "Seeds" || category == "Gears" || category == "Eggs") ? "1" : "0"
            items := getItems(category)
            items.Push(category)
            
            for item in items {
                IniWrite(defaultState, settingsFile, category, StrReplace(item, " ", ""))
            }
        }
        Sleep(200)
    }

    SettingsJson := {}
    for key in CORE_SETTINGS {
        SettingsJson.%key% := IniRead(settingsFile, "Settings", key, "")
    }

    SettingsJson.dynamicItems := {}
    for category in CATEGORIES {
        SettingsJson.dynamicItems.%category% := Map()
        
        defaultVal := (category == "Seeds" || category == "Gears" || category == "Eggs") ? "1" : "0"
        items := getItems(category)
        items.Push(category)

        for item in items {
            sanitizedKey := StrReplace(item, " ", "")
            val := IniRead(settingsFile, category, sanitizedKey, defaultVal)
            SettingsJson.dynamicItems.%category%[item] := val
        }
    }

    MyWindow.PostWebMessageAsJson(JSON.stringify(SettingsJson))
}





PlayerStatus("Connected to discord!", "0x34495E", , false, , false)






AsyncHttpRequest(method, url, func?, headers?) {
	req := ComObject("Msxml2.XMLHTTP")
	req.open(method, url, true)
	if IsSet(headers)
		for h, v in headers
			req.setRequestHeader(h, v)
	if IsSet(func)
		req.onreadystatechange := func.Bind(req)
	req.send()
}


CheckUpdate(req)
{

	if (req.readyState != 4)
		return

	if (req.status = 200)
	{
		LatestVer := Trim((latest_release := JSON.parse(req.responseText))["tag_name"], "v")
        
		if (VerCompare(version, LatestVer) < 0)
		{

            message := "
            (
            A new update is available!

            Would you like to open the GitHub release page
            to download the latest version?

            )"

            if MsgBox(message, "Update Available", 0x40004 | 0x40 | 0x4 ) = "Yes" ; 0x4 = Yes/No, 0x40 = info icon, 0x1 = OK/Cancel default button
            {
                handleUpdate(LatestVer)
            }

        }
	}
}

handleUpdate(ver){
    confirmMsg := "
    (
    Do you want to update the macro now and delete the current folder?

    Click Yes to auto update and migrate settings.
    No to just open the release page.
    )"

    choice := MsgBox(confirmMsg, "Confirm Update", 0x40004 | 0x40 | 0x4) 

    if choice = "Yes"
    {
        url := "https://github.com/epicisgood/Grow-a-Garden-Macro/releases/download/v" ver "/Epics_GAG_macro_v" ver ".zip"
        CopySettings := 1
        olddir := A_WorkingDir
        DeleteOld := 1

        Run '"' A_WorkingDir '\scripts\update.bat" "' url '" "' olddir '" "' CopySettings '" "' DeleteOld '" "' ver '"'
        StopMacro()
    }
    else
    {
        Run "https://github.com/epicisgood/Grow-a-Garden-Macro/releases/latest"
    }
}

AsyncHttpRequest("GET", "https://api.github.com/repos/epicisgood/Grow-a-Garden-Macro/releases/latest", CheckUpdate, Map("accept", "application/vnd.github+json"))





