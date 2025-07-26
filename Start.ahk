#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir A_ScriptDir
KeyDelay := 40

Setkeydelay KeyDelay


GetRobloxClientPos()
pToken := Gdip_Startup()
bitmaps := Map()
bitmaps.CaseSense := 0
currentWalk := {pid:"", name:""} ; stores "pid" (script process ID) and "name" (pattern/movement name)
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"
SendMode "Event"

WKey:="sc011" ; w
AKey:="sc01e" ; a
SKey:="sc01f" ; s
Dkey:="sc020" ; d


RotLeft := "vkBC" ; ,
RotRight := "vkBE" ; .
RotUp := "sc149" ; PgUp
RotDown := "sc151" ; PgDn
ZoomIn := "sc017" ; i
ZoomOut := "sc018" ; o
Ekey := "sc012" ; e
Rkey := "sc013" ; r
Lkey := "sc026" ; l
EscKey := "sc001" ; Esc
EnterKey := "sc01c" ; Enter
SpaceKey := "sc039" ; Space
SlashKey := "vk6F" ; /
SC_LShift:="sc02a" ; LShift



#include %A_ScriptDir%\lib\

#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include roblox.ahk
#Include ComVar.ahk
#Include Promise.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk

#Include %A_ScriptDir%\images\
#include bitmaps.ahk
#include %A_ScriptDir%\scripts\

#Include gui.ahk
#Include webhook.ahk
#Include timers.ahk




HyperSleep(ms) {
    static freq := (DllCall("QueryPerformanceFrequency", "Int64*", &f := 0), f)
    DllCall("QueryPerformanceCounter", "Int64*", &begin := 0)
    current := 0, finish := begin + ms * freq / 1000
    while (current < finish) {
        if ((finish - current) > 30000) {
            DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
            DllCall("Sleep", "UInt", 1)
            DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
        }
        DllCall("QueryPerformanceCounter", "Int64*", &current)
    }
}


CheckDisconnnect(){
    static VipLink := IniRead(settingsFile, "Settings", "VipLink")
    hwnd := GetRobloxHWND()
    GetRobloxClientPos()
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["disconnected"], , , , , , 2) = 1 || GetRobloxHWND() == 0)  {
        PlayerStatus("Starting Grow A Garden", "0x00a838", ,false, ,false)    
        Gdip_DisposeImage(pBMScreen)
        CloseRoblox()
        PlaceID := 126884695634066

        linkCode := ""
        shareCode := ""

        if RegExMatch(VipLink, "privateServerLinkCode=(\d+)", &match)
            linkCode := match[1]
        else if RegExMatch(VipLink, "code=([a-f0-9]+)&type=Server", &match)
            shareCode := match[1]
        
        if linkCode {
        DeepLink := "roblox://placeID=" PlaceID "&linkCode=" linkCode
        } else if shareCode {
            DeepLink := "https://www.roblox.com/share?code=" shareCode "&type=Server"
        } else {
            DeepLink := "roblox://placeID=" PlaceID
        }
        try Run DeepLink

        loop 60 {
            if GetRobloxHWND() {
                Sleep(500)
                for hwnd in WinGetList(,, "Program Manager")
                {
                    p := WinGetProcessName("ahk_id " hwnd)
                    if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                        continue ; skip roblox and AHK windows
                    title := WinGetTitle("ahk_id " hwnd)
                    if (title = "")
                        continue ; skip empty title windows
                    s := WinGetStyle("ahk_id " hwnd)
                    if ((s & 0x8000000) || !(s & 0x10000000))
                        continue ; skip NoActivate and invisible windows
                    s := WinGetExStyle("ahk_id " hwnd)
                    if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                        continue ; skip ToolWindow and AlwaysOnTop windows
                    try
                    {
                        WinActivate "ahk_id " hwnd
                        WinMaximize("ahk_id " hwnd)
                        Sleep 500
                        Send "^{w}"
                    }
                    break
                }
                Sleep(500)
                ActivateRoblox()
                Sleep(25000)
                ActivateRoblox()
                ResizeRoblox()
                GetRobloxClientPos(GetRobloxHWND())
                MouseMove windowX + windowWidth//2, windowY + windowHeight//2
                Sleep(500)
                Click
                Click
                PlayerStatus("Game Succesfully loaded", "0x00a838", ,false)
                Sleep(1000)
                Send("{Tab}")
                Send("1")
                Sleep(300)
                CloseChat()
                Sleep(1500)
                return 1
            }
            Sleep(1000)
        }
        if (A_Index == 60){
            Sleep(500)
            for hwnd in WinGetList(,, "Program Manager")
            {
                p := WinGetProcessName("ahk_id " hwnd)
                if (InStr(p, "Roblox") || InStr(p, "AutoHotkey"))
                    continue ; skip roblox and AHK windows
                title := WinGetTitle("ahk_id " hwnd)
                if (title = "")
                    continue ; skip empty title windows
                s := WinGetStyle("ahk_id " hwnd)
                if ((s & 0x8000000) || !(s & 0x10000000))
                    continue ; skip NoActivate and invisible windows
                s := WinGetExStyle("ahk_id " hwnd)
                if ((s & 0x80) || (s & 0x40000) || (s & 0x8))
                    continue ; skip ToolWindow and AlwaysOnTop windows
                try
                {
                    WinActivate "ahk_id " hwnd
                    WinMaximize("ahk_id " hwnd)
                    Sleep 500
                    Send "^{w}"
                }
                break
            }
            Sleep(500)
        }
        Gdip_DisposeImage(pBMScreen)
        return 0

    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }
}

CloseChat(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.25 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Chat"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}

openBag(){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth * 0.5 "|" windowHeight //8)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Openbag"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + 50
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)

}

closeBag(){
    relativeMouseMove(0.95, 0.5)
    Click
    Sleep(500)
}

equipRecall(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    openBag()
    Sleep(1000)
    clearSearch()
    Sleep(1000)
    cordx := 0
    cordy := 0
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Search"] , &OutputList, , , , , 50) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        cordx := x
        cordy := y
        MouseMove(x, y)
        Sleep(300)
        Click
        Sleep(500)
        Send("recall")
        Sleep(300)
        Gdip_DisposeImage(pBMScreen)
    } else {
        PlayerStatus("Could not detect Search in inventory", "0xFF0000")
        Gdip_DisposeImage(pBMScreen)
    }


    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Recall"] , &OutputList, , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY
        MouseMove(x, y)
        Sleep(300)
        Send("{Click down}")
        Sleep(300)
    }
    Gdip_DisposeImage(pBMScreen)

    pBMScreen := Gdip_BitmapFromScreen(
        windowX "|" 
        windowY + windowHeight - (windowHeight // 8) - 35 "|" 
        windowWidth * 0.4 "|" 
        windowHeight // 8
    )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["recall slot"] , &OutputList, , , , , 10,,6) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["recall slot2"] , &OutputList, , , , , 10,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + windowHeight - (windowHeight // 8) 
        MouseMove(x, y)
        Sleep(300)
        Send("{Click up}")
        Sleep(300)
    }
    Send("{Click up}")
    Sleep(500)
    clearSearch()
    closeBag()
    Gdip_DisposeImage(pBMScreen)

}

clearSearch(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["x"] , &OutputList, , , , , 20,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX 
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(750)
        Click
        Click
        Sleep(500)
    }
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Favorite"] , &OutputList, , , , , 20,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX 
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(750)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}

SearchItem(searchitems, searchbitmap){
    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Search"] , &OutputList, , , , , 25,,2) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX
        y := Cords[2] + windowY + 30
        MouseMove(x,y)
        Sleep(200)
        Click
        Sleep(200)
        Send(searchitems)
        Sleep(3000)
        Gdip_DisposeImage(pBMScreen)
        Sleep(100)
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
        if (Gdip_ImageSearch(pBMScreen, bitmaps[searchbitmap], &OutputList, , , , , 25) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + windowX
            y := Cords[2] + windowY + 30
            MouseMove(x, y)
            Sleep(250)
            Click
            Sleep(250)
            closeBag()
            Gdip_DisposeImage(pBMScreen)
        } else {
            PlayerStatus("Missing " searchitems " in inventory!", "0xff0000")
            Gdip_DisposeImage(pBMScreen)
            closeBag()
        }
    } else {
        PlayerStatus("Could not detect Search in inventory", "0xFF0000")
        Gdip_DisposeImage(pBMScreen)
        closeBag()
    }
}


CheckSetting(value, item){
    if (IniRead(settingsFile, item, value) == 1){
        return true
    }
    return false
}


relativeMouseMove(relx, rely) {
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    moveX := windowX + Round(relx * windowWidth)
    moveY := windowY + Round(rely * windowHeight)
    MouseMove(moveX,moveY)
}


Clickbutton(button, clickit := 1){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)    
    
    if (button == "Garden" || button == "Sell" || button == "Seeds"){
        capX := windowX + (windowWidth // 4)
        capY := windowY + 30
        capW := windowWidth // 2
        capH := 100
    ; } else if (button == "Xbutton" || button == "Xbutton2") {
    } else if (button == "Xbutton") {
        capX := windowX + windowWidth * 0.6411
        capY := windowY + windowHeight * 0.2065
        capW := windowWidth * 0.1
        capH := windowHeight * 0.1667
    } else if (button == "Robux"){
        capX := windowX windowWidth // 4
        capY := windowY 
        capW := windowWidth //2
        capH := windowHeight
    }

    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , 25,,7) = 1) {
        if (clickit == 1){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX - 2
            y := Cords[2] + capY 
            MouseMove(x, y)
            Sleep(50)
            Click
        }
        Gdip_DisposeImage(pBMScreen)
        return 1
    }
    if ("Seeds" || "Sell") {    
        if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , 100,,7) = 1) {
            if (clickit == 1){
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + capX - 2
                y := Cords[2] + capY 
                MouseMove(x, y)
                Sleep(50)
                Click
            }
            Gdip_DisposeImage(pBMScreen)
            return 1
        }
    }
    Gdip_DisposeImage(pBMScreen)
    return 0
}

ChangeCamera(type){
    Send("{" EscKey "}")
    HyperSleep(333)
    Send("{Tab}")
    HyperSleep(333)
    Send("{Down}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    Send("{Right}")
    HyperSleep(333)
    checkCamera(type)
    Send("{" EscKey "}")
    HyperSleep(1000)
}


checkCamera(type){  
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    loop 8 {
        pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight)
        if (Gdip_ImageSearch(pBMScreen, bitmaps[type] , &OutputList, , , , , 25) = 1) {
            Gdip_DisposeImage(pBMScreen)
            return 1
        } else {
            Send("{Right}")
            Sleep(1000)
            Gdip_DisposeImage(pBMScreen)
        }
    }

}




ZoomAlign(){
    relativeMouseMove(0.5,0.5)
    Click
    Loop 40 {
        Send("{WheelUp}")
        Sleep 20
    }

    Sleep(500)
    Loop 6 {
        Send("{WheelDown}")
        Sleep 50
    }
    Sleep(100)
    Click
    Sleep(250)
}


CheckAligned(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth * 0.8 "|" windowY "|" windowWidth * 0.2 "|" windowHeight)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Seeds"] , , , , , , 75) = 1) {
        Gdip_DisposeImage(pBMScreen)
        return true
    } else {
        Gdip_DisposeImage(pBMScreen)
        return false
    }
}


CameraCorrection(){
    loop 3 {
        if (Disconnect()){
            equipRecall()
            Sleep(500)
        }
        Send("{o down}")
        Sleep 500
        Send("{o up}")
        Clickbutton("Garden")
        CloseClutter()
        Sleep(300)
        ChangeCamera("Follow")
    
        ZoomAlign()
    
        Click("Right", "Down")
        Sleep(200)
        relativeMouseMove(0.5, 0.5)
        Sleep(200)
        MouseMove(0, 800, 10, "R")
        Sleep(200)
        Click("Right", "Up")
        Sleep(250)
    
        loop 10 {
            Clickbutton("Sell") 
            Clickbutton("Seeds") 
        }
        Sleep(500)
        Clickbutton("Seeds")
        Sleep(250)
    
        ChangeCamera("Classic")
        Sleep(1000)
        relativeMouseMove(0.5,0.5)
        Sleep(500)
        if (CheckAligned()){
            PlayerStatus("Aligned Succesfully!","0x2260e6",,false,,false)
            return true
        } else {
            PlayerStatus("Failed alignment.","0xcfe622",,false)
        }
    }
}

SpamClick(amount){
    loop amount {
        Click
        Sleep 20
    }
}





GearCraftingTime := 100000 ; Default crafting time, will be overwritten by the first item in the recipe
EventCraftingtime := 100000 ; Default crafting time, will be overwritten by the first item in the recipe
SeedCraftingtime := 100000 ; Default crafting time, will be overwritten by the first item in the recipe


Crafting(Recipeitems, settingName, Names){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)

    
    for item in Recipeitems {
        if (IniRead(settingsFile, settingName, StrReplace(item.name, " ", "")) == "1"){
            ; Claim Crafting item
            Send("{c}")
            Sleep(300)
            Send("{" Ekey "}")
            Sleep(2500)
            if (Clickbutton("Robux") == 1){
                PlayerStatus("Crafting not finished. Closing Robux prompt.","0xe67e22",,false)
                return item.CraftTime
            }
            CloseClutter()
            PlayerStatus("Claimed " item.Name "!", "0x22e6a8",,false)
            Send("{" Ekey "}")
            if !DetectShop("crafting"){
                return item.CraftTime
            }
            ; Choose to craft item
            buyShop(Names, settingName, 1)
            ; Search for the name 
            openBag()
            clearSearch()
            Sleep(1500)
            cordx := 0
            cordy := 0
            pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
            if (Gdip_ImageSearch(pBMScreen, bitmaps["Search"] , &OutputList, , , , , 25,,2) = 1) {
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + windowX
                y := Cords[2] + windowY + 30
                cordx := x
                cordy := y
                Gdip_DisposeImage(pBMScreen)
            } else {
                PlayerStatus("Could not detect Search in inventory", "0xFF0000")
                Gdip_DisposeImage(pBMScreen)
                closeBag()
                return item.CraftTime
            }
            ; Clicked on the search bar, now type the name

            for Material in item.Materials {
                MouseMove(cordx, cordy)
                Sleep(300)
                Click
                Sleep(1000)
                Send(StrReplace(Material, "item", ""))
                Sleep(1500)
                pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
                if (Gdip_ImageSearch(pBMScreen, bitmaps[Material], &OutputList, , , , , 25,,2) = 1) {
                    Cords := StrSplit(OutputList, ",")
                    x := Cords[1] + windowX
                    y := Cords[2] + windowY + 30
                    MouseMove(x, y)
                    Sleep(250)
                    Click
                    Sleep(1000)
                    Send("{" Ekey "}")
                    Sleep(250)
                    Send("1")
                    Sleep(100)
                    Send("1")
                    Sleep(500)
                    Gdip_DisposeImage(pBMScreen)
                } else {
                    PlayerStatus("Missing " Material " for " item.Name "!", "0xff0000",,false,,pBMScreen)
                    Gdip_DisposeImage(pBMScreen)
                }
                clearSearch()
            }
            closeBag()
            Send("{" Ekey "}")
            Send("{" Ekey "}")
            Sleep(1000)
            CloseClutter()
            PlayerStatus("Crafting " item.Name "!", "0x22e6a8",,false)
            return item.CraftTime
        }
    }
    return 99999999
}


CheckStock(index, list, crafter := 0){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    captureWidth := 150
    captureHeight := windowHeight // 2 + 100

    captureX := windowX + (windowWidth // 2) - (captureWidth // 2) - 150
    captureY := windowY + (windowHeight // 2) - (captureHeight // 2) + 20

    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + captureX 
        y := Cords[2] + captureY 
        MouseMove(x, y)
        Gdip_DisposeImage(pBMScreen)
        Sleep(100)
        if (list[index] == "Carrot Seed" || list[index] == "Orange Tulip" || list[index] == "Bamboo Seed" || list[index] == "Mushroom Seed"){
            SpamClick(25)
        } else if (crafter == 1){
            Click
        } else {
            SpamClick(6)
        }
        Sleep(200)
        PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false)
        return 1
    }
    Gdip_DisposeImage(pBMScreen)
    return 0

}

buyShop(itemList, itemType, crafter := 0){
    for (item in itemlist){
        if (A_index == 1){
            relativeMouseMove(0.5,0.4)
            Sleep(100)
            Loop 40 {
                Send("{WheelUp}")
                Sleep 20
            }
            Sleep(500)
        } else {
            if (itemType == "Event" || itemType == "Eggs"){
                relativeMouseMove(0.4,0.8)
            } else {
                relativeMouseMove(0.4,0.845)
            }
        }
        if (A_index >= 19){
            if ((A_Index - 19) / 8 == 0.5){
                ScrollDown(0.75)
                Sleep(500)
            } else {
                ScrollDown(0.25  + (A_Index - 19) / 8)
                Sleep(500)
            }
        }
        Click
        Sleep(350)
        if (CheckSetting(StrReplace(item, " ", ""), itemType)){
            CheckStock(A_Index, itemlist, crafter)
        } else {
            Sleep(200)
        }
    }
    CloseShop()
}


ScrollDown(amount := 1) {
    DllCall("user32.dll\mouse_event", "UInt", 0x0800, "UInt", 0, "UInt", 0, "UInt", -amount * 120, "UPtr", 0)
}

; 1 = 1st option, 2 = 2nd option, etc for example the gear shop to open the shop
clickOption(option, optionamount){
    Sleep(500)
    ZoomAlign()
    Sleep(2000)
    Loop 4 {
        Send("{WheelUp}")
        Sleep 50
    }
    Sleep(500)

    switch optionamount {
        case 3: 
            if (option == 1){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (390 / 1080)
            } else if (option == 2){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (570 / 1080)
            } else if (option == 3){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (770 / 1080)
            }      
        case 4:
            if (option == 1){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (390 / 1080)
            } else if (option == 2){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (550 / 1080)
            } else if (option == 3){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (750 / 1080)
            } else if (option == 4){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (874 / 1080)
            }

        case 5:
            if (option == 1){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (300 / 1080)
            } else if (option == 2){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (450 / 1080)
            } else if (option == 3){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (580 / 1080)
            } else if (option == 4){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (770 / 1080)
            } else if (option == 5){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (990 / 1080)
            }  

        case 6:
            if (option == 1){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (200 / 1080)
            } else if (option == 2){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (340 / 1080)
            } else if (option == 3){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (490 / 1080)
            } else if (option == 4){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (670 / 1080)
            } else if (option == 5){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (850 / 1080)
            } else if (option == 6){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (1030 / 1080)

            }  
    }
    Sleep(500)
    Click
    Loop 4 {
        Send("{WheelDown}")
        Sleep 50
    }
    Sleep(2500)
}


DetectShop(shop){
    loop 15 {
        Sleep(500)
        if (Clickbutton("Xbutton",0) == 1){
        ; if (Clickbutton("Xbutton",0) == 1 || Clickbutton("Xbutton2",0) == 1){
            Sleep(2500)
            PlayerStatus("Detected " shop " shop opened", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to open " shop " shop", "0x22e6a8",,false,,true)
    return 0
}


CloseShop(){
    loop 15 {
        Sleep(500)
        if (Clickbutton("Xbutton") == 1){
        ; if (Clickbutton("Xbutton") == 1 || Clickbutton("Xbutton2") == 1){
            Sleep(1000)
            PlayerStatus("Closed shop!", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to close shop.", "0xFF0000",,false,,true)
    return 0

}


CloseClutter(){
    Clickbutton("Xbutton")
    Sleep(100)
    ; Clickbutton("Xbutton2")
    Clickbutton("Robux")
    Sleep(300)
}

getItems(item){
    static fileContent := ""

    if !fileContent {
        try {
            request := ComObject("WinHttp.WinHttpRequest.5.1")
            request.Open("GET", "https://raw.githubusercontent.com/epicisgood/GAG-Updater/refs/heads/main/items.json", true)
            request.Send()
            request.WaitForResponse()
            fileContent := JSON.parse(request.ResponseText)
            global MyWindow
            MyWindow.ExecuteScriptAsync("document.querySelector('#random-message').textContent = '" fileContent["message"] "'")
            
        } catch as e {
            MsgBox "Request failed " e.Message
        }
    }
    names := []
    for itemObj in fileContent[item] {
        names.Push(itemObj["name"])
    }
    return names
    ; jsonData := fileContent
    ; return jsonData[item]
}

BuySeeds(){
    seedItems := getItems("Seeds")

    loop 3 {
        PlayerStatus("Going to buy Seeds!", "0x22e6a8",,false,,false)
        relativeMouseMove(0.5, 0.5)
        Sleep(500)
        Clickbutton("Seeds")
        Sleep(1000)
        Send("{" Ekey "}")
        if !DetectShop("Seeds"){
            CameraCorrection()
            continue
        }
        buyShop(seedItems, "Seeds")
        CloseClutter()
        return 1
    }
}






BuyGears(){
    gearItems := getItems("Gears")

    loop 3 {
        PlayerStatus("Going to buy Gears!", "0x22e6a8",,false,,false)
        Send("1")
        Sleep(300)
        relativeMouseMove(0.5, 0.5)
        Click
        Sleep(1500)
        Send("{" Ekey "}")
        clickOption(1,3)
        if !DetectShop("gear"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, "Gears")
        CloseClutter()
        return 1
    }
}


BuyEggs(){
    eggitems := getItems("Eggs")
    loop 3 {
        PlayerStatus("Going to buy Eggs!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Send("1")
        MouseMove windowX + windowWidth//2, windowY + windowHeight//2
        Click
        Sleep(1000)
        Send("{s Down}")
        HyperSleep(600)
        Send("{s Up}")
        Sleep(1500)
        Send("{" Ekey "}")
        clickOption(1,6)
        if !DetectShop("egg"){
            CameraCorrection()
            continue
        }
        buyShop(eggitems, "Eggs")
        CloseClutter()
        return 1
    }
}


GearCraft(){
    if (IniRead(settingsFile, "GearCrafting", "GearCrafting") + 0 == 0){
        return
    }
    PlayerStatus("Going to craft Gears!", "0x22e6a8",,false,,false)
    Sleep(300)
    Send("1")
    Sleep(300)
    relativeMouseMove(0.5, 0.5)
    Click
    Sleep(1500)
    Send("{" WKey " down}")
    HyperSleep(1200)
    Send("{" WKey " up}")
    Sleep(1000)
    GearRecipe := [
        { Name: "Lighting Rod", Materials: ["Basic Sprinkler", "Advanced Sprinkler", "Godly Sprinkler"], CraftTime: 2700 },
        { Name: "Reclaimer", Materials: ["Common Egg item", "Harvest Tool"], CraftTime: 1500 },
        { Name: "Tropical Mist Sprinkler", Materials: ["Coconut", "Dragon Fruit", "Mango", "Godly Sprinkler"], CraftTime: 3600 },
        { Name: "Berry Blusher Sprinkler", Materials: ["Grape", "Blueberry", "Strawberry", "Godly Sprinkler"], CraftTime: 3600 },
        { Name: "Spice Spirtzer Sprinkler", Materials: ["Pepper", "Ember Lily", "Cacao", "Master Sprinkler"], CraftTime: 3600 },
        { Name: "Sweet Soaker Sprinkler", Materials: ["Watermelon", "Watermelon", "Watermelon", "Master Sprinkler"], CraftTime: 3600 },
        { Name: "Flower Froster Sprinkler", Materials: ["Orange Tulip", "Daffodil", "Advanced Sprinkler", "Basic Sprinkler"], CraftTime: 3600 },
        { Name: "Stalk Sprout Sprinkler", Materials: ["Bamboo", "Beanstalk", "Mushroom", "Advanced Sprinkler"], CraftTime: 3600 },
        { Name: "Mutation Spray Choc", Materials: ["Cleaning Spray", "Cacao"], CraftTime: 720 },
        { Name: "Mutation Spray Chilled", Materials: ["Cleaning Spray", "Godly Sprinkler"], CraftTime: 300 },
        { Name: "Mutation Spray Shocked", Materials: ["Cleaning Spray", "Lighting Rod"], CraftTime: 1800 },
        { Name: "Anti Bee Egg", Materials: ["Bee Egg item"], CraftTime: 7200 },
        { Name: "Small Toy", Materials: ["Common Egg item", "Seed Coconut", "Coconut"], CraftTime: 600 },
        { Name: "Small Treat", Materials: ["Common Egg item", "Seed Dragon Fruit", "Blueberry"], CraftTime: 600 },
        { Name: "Pack Bee", Materials: ["Anti Bee Egg item", "Sunflower", "Purple Dahila"], CraftTime: 14400 },
        
        
    ]
    GearNames := getItems("GearCrafting")

    global GearCraftingTime
    GearCraftingTime := Crafting(GearRecipe, "GearCrafting", GearNames) + 200
    Sleep(1000)

}


SeedCraft(){
    if (IniRead(settingsFile, "SeedCrafting", "SeedCrafting") + 0 == 0){
        return
    }
    PlayerStatus("Going to craft Seeds!", "0x22e6a8",,false,,false)
    Sleep(300)
    Send("1")
    Sleep(300)
    relativeMouseMove(0.5, 0.5)
    Click
    Sleep(1500)
    Send("{" WKey " down}")
    HyperSleep(800)
    Send("{" WKey " up}")
    Sleep(1000)
    SeedRecipe := [
        { Name: "Horsetail", Materials: ["Stonebite Seed", "Bamboo", "Corn"], CraftTime: 900 },
        { Name: "Lingonberry", Materials: ["Blueberry", "Blueberry", "Blueberry", "Horsetail"], CraftTime: 900 },
        { Name: "Amber Spine", Materials: ["Cactus", "Pumpkin", "Horsetail"], CraftTime: 1800 },
        { Name: "Grand Volcania", Materials: ["Ember Lily", "Dinosaur Egg item", "Ancient Seed Pack"], CraftTime: 2700 },
        
        
    ]
    SeedNames := getItems("SeedCrafting")


    global SeedCraftingtime
    SeedCraftingTime := Crafting(SeedRecipe, "SeedCrafting", SeedNames) + 200
    Sleep(1000)

}



BuyMerchant(){
    if (IniRead(settingsFile, "Settings", "TravelingMerchant") + 0  == 0){
        return
    }
    seedItems := [
        "Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed",
        "Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed","Mushroom Seed",
    ]

    PlayerStatus("Going to buy Traveling Merchant!", "0x22e6a8",,false,,false)
    Clickbutton("Seeds")
    Sleep(1500)
    Send("{" Akey " down}")
    HyperSleep(250)
    Send("{" Akey " up}")
    
    Send("{" Wkey " down}")
    HyperSleep(1200)
    Send("{" Wkey " up}")
    
    Send("{" Dkey " down}")
    HyperSleep(250)
    Send("{" Dkey " up}")
    Sleep(1000)

    Send("{" Ekey "}")
    DetectOnett()
    if DetectShop("traveling merchant"){
        buyShop(seedItems, "Seeds")
        CloseClutter()
        return 1
    }
    return 0
}

DetectOnett(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.6411
    capY := windowY + windowHeight * 0.2065
    capW := windowWidth * 0.1
    capH := windowHeight * 0.1667
    
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["HoneyMerchant"], , , , , , 100) = 1) {
        PlayerStatus("My goat Onett has arrived!!","0xe1ff00",,false)
        clickOption(2,5)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false

}










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main Macro Functions.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Disconnect(){
    loop 3 {
        if (CheckDisconnnect()){
            return 1
        }
    }
}

MainLoop() {

    if (GetRobloxHWND()){
        ResizeRoblox()
    }
    
    if (Disconnect()){
        return
    }

    CloseChat() 
    equipRecall()
    CameraCorrection()
    BuySeeds()
    BuyGears()
    BuyEggs()
    BuyEvent()
    GearCraft()
    SeedCraft()
    BuyMerchant()
    loop {
        RewardInterupt()
        if (Disconnect()){
            equipRecall()
            Sleep(500)
            CameraCorrection()
        }
        ToolTip("Seed Shop: " (r:=Mod(300 - Mod(A_Min*60 + A_Sec, 300), 300))//60 ":" Mod(r,60) 
        "`nGear Shop: " (r:=Mod(300 - Mod(A_Min*60 + A_Sec, 300), 300))//60 ":" Mod(r,60) 
        "`nEgg Shop: " (r:=Mod(1800 - Mod(A_Min*60 + A_Sec, 1800),1800))//60 ":" Mod(r,60),100,100), 1000
        Sleep(1000)
    }
    
    
    
}


F3::
{


    ; ActivateRoblox()
    ; ResizeRoblox()
    ; hwnd := GetRobloxHWND()
    ; GetRobloxClientPos(hwnd)
    ; pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY + 30 "|" windowWidth "|" windowHeight - 30)
    ; Gdip_SaveBitmapToFile(pBMScreen,"ss.png")
    ; Gdip_DisposeImage(pBMScreen)
    Clickbutton("Robux")
    ; PauseMacro()
}







BuyEvent(){
    PlayerStatus("Going to Zen Event Shop!", "0x22e6a8",,false,,false)
    Sleep(300)
    Send("1")
    Sleep(300)
    relativeMouseMove(0.5, 0.5)
    Sleep(200)
    Click
    Sleep(1500)

    ; Move down from gear shop as there is a new tree in the way.
    Send("{s Down}")
    HyperSleep(1200)
    Send("{s Up}")

    Send("{" Dkey " down}")
    HyperSleep(10000)
    Send("{" Dkey " up}")
    Sleep(500)
    Send("{" Wkey " down}")

    HyperSleep(1500)
    Send("{" Wkey " up}")

    Sleep(500)
    Send("{" Dkey " down}")
    HyperSleep(500)
    Send("{" Dkey " up}")

    Sleep(500)
    Send("{" WKey " down}")
    HyperSleep(100)
    Send("{" WKey " up}")

    Sleep(1500)
    Send("{" Ekey "}")
    clickOption(1,5)
    if !DetectShop("Zen"){
        return 0 
    }
    buyShop(getItems("Events"), "Events")
    CloseClutter()
    return 1
}





