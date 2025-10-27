#Requires AutoHotkey v2.0

version := "v1.2.5"
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
MyWindow.Show("w650 h450")



F1::{
    Start
}

F2::{
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
        case "Stop":
			Send("{F2}")
	}
}



SaveSettings(settingsJson) {
    settings := JSON.Parse(settingsJson)
    IniFile := A_WorkingDir . "\settings.ini"

    for key, val in settings {
        if (key == "url" || key == "discordID" || key == "VipLink" || key == "Cosmetics" || key == "TravelingMerchant" || key == "CookingEvent" || key == "SearchList" || key == "CookingTime") {
            IniWrite(val, IniFile, "Settings", key)
        }
    }

    sectionMap := Map(
        "seedItems", "Seeds",
        "gearItems", "Gears",
        "EggItems",  "Eggs",
        "GearCraftingItems", "GearCrafting",
        "SeedCraftingItems", "SeedCrafting",
        "SpookySeedsItems", "SpookySeeds",
        ; "fallCosmeticsItems", "fallCosmetics",
        "DevillishDecorItems", "DevillishDecor",
        "CreepyCrittersItems", "CreepyCritters",
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
	settingsFile := A_WorkingDir . "\settings.ini"
    seedItems := getItems("Seeds")

    gearItems := getItems("Gears")

    EggItems := getItems("Eggs")

    GearCraftingItems := getItems("GearCrafting")
    
    SeedCraftingItems := getItems("SeedCrafting")
    
    SpookySeedsItems := getItems("SpookySeeds")
    ; fallCosmeticsItems := getItems("fallCosmetics")
    DevillishDecorItems := getItems("DevillishDecor")
    CreepyCrittersItems := getItems("CreepyCritters")

    seedItems.Push("Seeds")
    gearItems.Push("Gears")
    EggItems.Push("Eggs")
    GearCraftingItems.Push("GearCrafting")
    SeedCraftingItems.Push("SeedCrafting")
    SpookySeedsItems.Push("SpookySeeds")
    ; fallCosmeticsItems.Push("fallCosmetics")
    DevillishDecorItems.Push("DevillishDecor")
    CreepyCrittersItems.Push("CreepyCritters")


    if (!FileExist(settingsFile)) {
        IniWrite("", settingsFile, "Settings", "url")
        IniWrite("", settingsFile, "Settings", "discordID")
        IniWrite("", settingsFile, "Settings", "VipLink")
        IniWrite("0", settingsFile, "Settings", "Cosmetics")
        IniWrite("1", settingsFile, "Settings", "TravelingMerchant")
        IniWrite("0", settingsFile, "Settings", "CookingEvent")
        IniWrite("", settingsFile, "Settings", "SearchList")
        IniWrite("", settingsFile, "Settings", "CookingTime")
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
        for i in SpookySeedsItems {
            IniWrite("0", settingsFile, "SpookySeeds", StrReplace(i, " ", ""))
        }
        ; for i in fallCosmeticsItems {
        ;     IniWrite("0", settingsFile, "fallCosmetics", StrReplace(i, " ", ""))
        ; }
        for i in DevillishDecorItems {
            IniWrite("0", settingsFile, "DevillishDecor", StrReplace(i, " ", ""))
        }
        for i in CreepyCrittersItems {
            IniWrite("0", settingsFile, "CreepyCritters", StrReplace(i, " ", ""))
        }
        Sleep(200)
    }

    Other := [
        "TravelingMerchant",
        "Cosmetics",
        "CookingEvent"
    ]

    for item in Other {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "Settings", key, "0")
        IniWrite(value, settingsFile, "Settings", key)
    }
    
    SettingsJson := { 
        url:       IniRead(settingsFile, "Settings", "url")
      , discordID: IniRead(settingsFile, "Settings", "discordID")
      , VipLink:   IniRead(settingsFile, "Settings", "VipLink")
      , Cosmetics:  IniRead(settingsFile, "Settings", "Cosmetics")
      , TravelingMerchant:  IniRead(settingsFile, "Settings", "TravelingMerchant")
      , CookingEvent:  IniRead(settingsFile, "Settings", "CookingEvent")
      , SearchList:  IniRead(settingsFile, "Settings", "SearchList")
      , CookingTime:  IniRead(settingsFile, "Settings", "CookingTime")
      , SeedItems: Map()
      , GearItems: Map()
      , EggItems:  Map()
      , GearCraftingItems: Map()
      , SeedCraftingItems: Map()
      , SpookySeedsItems: Map()
    ;   , fallCosmeticsItems: Map()
      , DevillishDecorItems: Map()
      , CreepyCrittersItems: Map()
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

    for item in SpookySeedsItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "SpookySeeds", key, "0")
        IniWrite(value, settingsFile, "SpookySeeds", key)
        SettingsJson.SpookySeedsItems[key] := value
    }
    ; for item in fallCosmeticsItems {
    ;     key := StrReplace(item, " ", "")
    ;     value := IniRead(settingsFile, "fallCosmetics", key, "0")
    ;     IniWrite(value, settingsFile, "fallCosmetics", key)
    ;     SettingsJson.fallCosmeticsItems[key] := value
    ; }
    for item in DevillishDecorItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "DevillishDecor", key, "0")
        IniWrite(value, settingsFile, "DevillishDecor", key)
        SettingsJson.DevillishDecorItems[key] := value
    }
    for item in CreepyCrittersItems {
        key := StrReplace(item, " ", "")
        value := IniRead(settingsFile, "CreepyCritters", key, "0")
        IniWrite(value, settingsFile, "CreepyCritters", key)
        SettingsJson.CreepyCrittersItems[key] := value
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





