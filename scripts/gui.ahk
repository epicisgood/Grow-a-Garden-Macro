
#Requires AutoHotkey v2.0

version := "v1.1.1"
settingsFile := "settings.ini"





if (A_IsCompiled) {
	; WebViewCtrl.CreateFileFromResource((A_PtrSize * 4) "bit\WebView2Loader.dll", WebViewCtrl.TempDir)
    ; WebViewSettings := {DllPath: WebViewCtrl.TempDir "\" (A_PtrSize * 4) "bit\WebView2Loader.dll"}

	WebViewCtrl.CreateFileFromResource((A_PtrSize * 8) "bit\WebView2Loader.dll", WebViewCtrl.TempDir)
    WebViewSettings := {DllPath: WebViewCtrl.TempDir "\" (A_PtrSize * 8) "bit\WebView2Loader.dll"}
} else {
    WebViewSettings := {}
    TraySetIcon("images\\GameIcon.ico")
}




MyWindow := WebViewGui("-Resize -Caption ",,,WebViewSettings) ; ignore error it somehow works with it.....
MyWindow.OnEvent("Close", (*) => StopMacro())
MyWindow.Navigate("scripts/Gui/index.html")
MyWindow.AddHostObjectToScript("ButtonClick", { func: WebButtonClickEvent })
MyWindow.AddHostObjectToScript("Save", { func: SaveSettings })
MyWindow.AddHostObjectToScript("ReadSettings", { func: SendSettings })
MyWindow.Show("w650 h470")



F1::{
    Start
}

F2::{
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
        )", "WARNING!!", 0x1030 " T60"
    }
}
ScreenResolution()



WebButtonClickEvent(button) {
	switch button {
		case "Start":
			Send("{F1}")
        case "Stop":
			Send("{F2}")
	}
}



SaveSettings(settingsJson) {
    settings := JSON.Parse(settingsJson)
    IniFile := A_ScriptDir . "\settings.ini"

    for key, val in settings {
        if (key == "url" || key == "discordID" || key == "VipLink" || key == "TravelingMerchant") {
            IniWrite(val, IniFile, "Settings", key)
        }
    }

    sectionMap := Map(
        "seedItems", "Seeds",
        "gearItems", "Gears",
        "EggItems",  "Eggs",
        "GearCraftingItems", "GearCrafting",
        "SeedCraftingItems", "SeedCrafting",
        "EventItems", "Events",
    )

    for groupName, sectionName in sectionMap {
        if settings.Has(groupName) {
            group := settings[groupName]
            for itemName, isEnabled in group {
                IniWrite(isEnabled ? 1 : 0, IniFile, sectionName, StrReplace(itemName, " ", ""))
            }
        }
    }
    MsgBox("Saved settings.",,"T0.5")
}


SendSettings(){
	settingsFile := A_ScriptDir . "\settings.ini"

    seedItems := getItems("Seeds")

    gearItems := getItems("Gears")

    EggItems := getItems("Eggs")

    GearCraftingItems := ["GearCrafting"]

    GearCraftingItems.Push(getItems("GearCrafting")*)
    
    SeedCraftingItems := ["SeedCrafting"]

    SeedCraftingItems.Push(getItems("SeedCrafting")*)
    
    EventItems := getItems("Events")


    if (!FileExist(settingsFile)) {
        IniWrite("", settingsFile, "Settings", "url")
        IniWrite("", settingsFile, "Settings", "discordID")
        IniWrite("", settingsFile, "Settings", "VipLink")
        IniWrite("0", settingsFile, "Settings", "TravelingMerchant")
        for i in seedItems {
            IniWrite("1", settingsFile, "Seeds", StrReplace(i, " ", ""))
        }
        for i in gearItems {
            IniWrite("1", settingsFile, "Gears", StrReplace(i, " ", ""))
        }
        for i in EggItems {
            IniWrite("1", settingsFile, "Eggs", StrReplace(i, " ", ""))
        }
        for i in GearCraftingItems {
            IniWrite("0", settingsFile, "GearCrafting", StrReplace(i, " ", ""))
        }
        for i in SeedCraftingItems {
            IniWrite("0", settingsFile, "SeedCrafting", StrReplace(i, " ", ""))
        }
        for i in EventItems {
            IniWrite("0", settingsFile, "Events", StrReplace(i, " ", ""))
        }
        Sleep(200)
    }

    SettingsJson := { 
        url:       IniRead(settingsFile, "Settings", "url")
      , discordID: IniRead(settingsFile, "Settings", "discordID")
      , VipLink:   IniRead(settingsFile, "Settings", "VipLink")
      , TravelingMerchant:  IniRead(settingsFile, "Settings", "TravelingMerchant")
      , SeedItems: Map()
      , GearItems: Map()
      , EggItems:  Map()
      , GearCraftingItems: Map()
      , SeedCraftingItems: Map()
      , EventItems: Map()
    }

    for item in seedItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "Seeds", key, "1")
        IniWrite(value, settingsFile, "Seeds", key)
        SettingsJson.SeedItems[item] := value
    }

    for item in gearItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "Gears", key, "1")
        IniWrite(value, settingsFile, "Gears", key)
        SettingsJson.GearItems[item] := value
    }

    for item in EggItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "Eggs", key, "1")
        IniWrite(value, settingsFile, "Eggs", key)
        SettingsJson.EggItems[key] := value
    }

    for item in GearCraftingItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "GearCrafting", key, "0")
        IniWrite(value, settingsFile, "GearCrafting", key)
        SettingsJson.GearCraftingItems[key] := value
    }

    for item in SeedCraftingItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "SeedCrafting", key, "0")
        IniWrite(value, settingsFile, "SeedCrafting", key)
        SettingsJson.GearCraftingItems[key] := value
    }

    for item in EventItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "Events", key, "0")
        IniWrite(value, settingsFile, "Events", key)
        SettingsJson.EventItems[key] := value
    }


	MyWindow.PostWebMessageAsJson(JSON.stringify(SettingsJson))
}








if (IniRead(settingsFile, "Settings", "url",0)){
    PlayerStatus("Connected to discord!", "0x34495E", , false, , false)
}






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
                Run "https://github.com/epicisgood/Grow-a-Garden-Macro/releases/latest"
            }

        }
	}
}

AsyncHttpRequest("GET", "https://api.github.com/repos/epicisgood/Grow-a-Garden-Macro/releases/latest", CheckUpdate, Map("accept", "application/vnd.github+json"))





