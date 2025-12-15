#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn VarUnset, Off
SetWorkingDir A_ScriptDir . "\.."
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



#Include "%A_ScriptDir%"
#include ..\lib\

#Include FormData.ahk
#Include Gdip_All.ahk
#include Gdip_ImageSearch.ahk
#include json.ahk
#Include roblox.ahk
#Include ComVar.ahk
#Include Promise.ahk
#Include WebView2.ahk
#Include WebViewToo.ahk

#Include ..\images\
#include bitmaps.ahk
#include ..\scripts\

#Include gui.ahk
#Include webhook.ahk
#Include timers.ahk




;@Ahk2Exe-AddResource Gui\index.html, Gui\index.html
;@Ahk2Exe-AddResource Gui\script.js, Gui\script.js
;@Ahk2Exe-AddResource Gui\style.css, Gui\style.css
;@Ahk2Exe-AddResource ..\Lib\32bit\WebView2Loader.dll, 32bit\WebView2Loader.dll
;@Ahk2Exe-AddResource ..\Lib\64bit\WebView2Loader.dll, 64bit\WebView2Loader.dll


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

Walk(studs, MoveKey1, MoveKey2:=0) {
	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
	Sleep studs
	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
}
; Walk(studs, MoveKey1, MoveKey2:=0) {
; 	speed := 0.022
; 	sleepTime := studs / speed
; 	Send "{" MoveKey1  " down}" (MoveKey2 ? "{" MoveKey2  " down}" : "")
; 	Sleep sleepTime
; 	Send "{" MoveKey1  " up}" (MoveKey2 ? "{" MoveKey2  " up}" : "")
; }


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
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Openbag"] , &OutputList, , , , , 100,,8) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + 2
        y := Cords[2] + windowY + 2
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

clearSearch(){
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    pBMScreen := Gdip_BitmapFromScreen(windowX + windowWidth // 2 "|" windowY + 30 "|" windowWidth // 2 "|" windowHeight - 30)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["x"] , &OutputList, , , , , 25,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["x2"] , &OutputList, , , , , 25,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 31
        MouseMove(x, y)
        Sleep(750)
        Click
        Click
        Sleep(250)
        Send("{Backspace}")
        Sleep(500)
    }
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Favorite"] , &OutputList, , , , , 20,,6) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + windowX + windowWidth // 2 
        y := Cords[2] + windowY + 30
        MouseMove(x, y)
        Sleep(750)
        Click
        Sleep(500)
    }
    Gdip_DisposeImage(pBMScreen)
}


searchItem(keyword){
    keyword := StrReplace(keyword, " ", "%S+")
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
        Send(keyword)
        Sleep(500)
        Gdip_DisposeImage(pBMScreen)
    } else {
        PlayerStatus("Could not detect Search in inventory", "0xFF0000")
        Gdip_DisposeImage(pBMScreen)
    }
}

clickItem(keyword, searchbitmap){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    Sleep(500)
    if (searchbitmap == "Bracket"){
        capX := windowX
        capY := windowY + 200 + windowHeight - 600
        capW := windowWidth
        capH := windowHeight - (400 + windowHeight - 600)
        pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Bracket2"], &OutputList, , , , , 20) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX + 4
            y := Cords[2] + capY + 4
            MouseMove(x, y)
            Sleep(250)
            Click
            Sleep(250)
            Gdip_DisposeImage(pBMScreen)
            closeBag()
            return true
        }
        Gdip_DisposeImage(pBMScreen)
    }
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)

    if (Gdip_ImageSearch(pBMScreen, bitmaps[searchbitmap], &OutputList, , , , , 20) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX + 4
        y := Cords[2] + capY + 4
        MouseMove(x, y)
        Sleep(250)
        Click
        Sleep(250)
        Gdip_DisposeImage(pBMScreen)
        if !(searchbitmap == "Recall Wrench"){
            closeBag()
        }
        return true
    } else {
        PlayerStatus("Missing " keyword " in inventory!", "0xff0000")
        Gdip_DisposeImage(pBMScreen)
        closeBag()
        return false
    }
}


clickCategory(category){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX
    capY := windowY + 200 + windowHeight - 600
    capW := windowWidth
    capH := windowHeight - (200 + windowHeight - 600)
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps[category] , &OutputList, , , , , 100) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(300)
        Click
    }
    Gdip_DisposeImage(pBMScreen)
}


equipRecall(){
    searchItem("recall")

    pBMScreen := Gdip_BitmapFromScreen(windowX "|" windowY "|" windowWidth "|" windowHeight )
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Recall Wrench"] , &OutputList, , , , , 25) = 1) {
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
    if (Gdip_ImageSearch(pBMScreen, bitmaps["recall slot"] , &OutputList, , , , , 30,,6) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["recall slot2"] , &OutputList, , , , , 30,,6) = 1) {
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



CheckSetting(item,value){
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
        varation := 10
    } else if (button == "Xbutton") {
        capX := windowX + windowWidth * 0.60
        capY := windowY + windowHeight * 0.1
        capW := windowWidth * 0.38
        capH := windowHeight * 0.25
        varation := 50
    } else if (button == "Robux"){
        capX := windowX windowWidth // 4
        capY := windowY 
        capW := windowWidth //2
        capH := windowHeight
        varation := 10
    }

    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (button == "Xbutton"){
        isFound := false
        

        loop 1 {
            ;  Only for santa event delete later 
            if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton5"], &OutputList, , , , ,  125,,7) = 1) {
                ; MsgBox("1")
                isFound := true
                Gdip_DisposeImage(pBMScreen)
                break
            }
            if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton6"], &OutputList, , , , ,  125,,7) = 1) {
                ; MsgBox("2")
                isFound := true
                Gdip_DisposeImage(pBMScreen)
                break
            }
        
            
            ; Light Xbutton
            if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton"], &OutputList, , , , , varation,,7) = 1) {
                ; MsgBox("3")
                isFound := true
                Gdip_DisposeImage(pBMScreen)
                break
            }
            ; Dark Xbutton
            if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton2"], &OutputList, , , , ,  varation,,7) = 1) {
                ; MsgBox("4")
                isFound := true
                Gdip_DisposeImage(pBMScreen)
                break
            }
        }

        if (clickit == 1 && isFound == true){
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX - 2
            y := Cords[2] + capY 
            MouseMove(x, y)
            Sleep(10)
            Click
        }
        return isFound

    } else {
        if (Gdip_ImageSearch(pBMScreen, bitmaps[button], &OutputList, , , , , varation,,7) = 1) {
            if (clickit == 1){
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + capX - 2
                y := Cords[2] + capY 
                MouseMove(x, y)
                Sleep(10)
                Click
            }
            Gdip_DisposeImage(pBMScreen)
            return 1
        } 
    }


    if (button == "Seeds" || button == "Sell") {    
        if (Gdip_ImageSearch(pBMScreen, bitmaps[button "2"], &OutputList, , , , , varation,,7) = 1) {
            if (clickit == 1){
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + capX - 2
                y := Cords[2] + capY 
                MouseMove(x, y)
                Sleep(10)
                Click
            }
            Gdip_DisposeImage(pBMScreen)
            return 1
        }
    } else if (button == "Robux"){
        if (Gdip_ImageSearch(pBMScreen, bitmaps["RobuxOld"], &OutputList, , , , , 10,,7) = 1) {
            if (clickit == 1){
                Cords := StrSplit(OutputList, ",")
                x := Cords[1] + capX - 2
                y := Cords[2] + capY 
                MouseMove(x, y)
                Sleep(10)
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
    HyperSleep(750)
    Send("{Tab}")
    HyperSleep(333)
    loop 10 {
        Send("{Up}")
        Sleep(50)
    }
    Sleep(150)
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
        if (Gdip_ImageSearch(pBMScreen, bitmaps[type] , , , , , , 25) = 1) {
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


CameraCorrection(){
    if (Disconnect()){
        Sleep(1500)
        equipRecall()
        Sleep(500)
    }

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
    PlayerStatus("Finished Aligning!","0x2260e6",,false,,false)
}

SpamClick(amount){
    loop amount {
        Click
        Sleep 20
    }
}






Crafting(Recipeitems, settingName, Names){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    
    for item in Recipeitems {
        if (IniRead(settingsFile, settingName, StrReplace(item.name, " ", "")) + 0 == 1){
            ; Claim Crafting item
            Send("{c}")
            Sleep(300)
            Send("{" Ekey "}")
            Sleep(2500)
            if (Clickbutton("Robux") == 1){
                PlayerStatus("Crafting not finished. Closing Robux prompt.","0xe67e22",,false)
                return Integer(item.CraftTime * 0.3)
            }
            CloseClutter()
            PlayerStatus("Claimed " item.Name "!", "0x22e6a8",,false)
            Send("{" Ekey "}")
            if !DetectShop("crafting"){
                return Integer(item.CraftTime * 1.1)
            }
            ; Choose to craft item
            buyShop(Names, settingName, true)


            Sleep(1500)
            Send("{f}")
            Sleep(1000)
            Send("{" Ekey "}")
            Send("{" Ekey "}")
            Sleep(1000)
            Send("1")
            Sleep(250)
            Send("1")
            CloseClutter()
            PlayerStatus("Crafting " item.Name "!", "0x22e6a8",,false)
            return Integer(item.CraftTime * 1.1)
        }
    }
    return 99999999
}


CheckStock(index, list, crafting := false){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    captureWidth := 150
    captureHeight := windowHeight // 2 + 100

    captureX := windowX + (windowWidth // 2) - (captureWidth // 2) - 150
    captureY := windowY + (windowHeight // 2) - (captureHeight // 2) + 50

    pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
    If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + captureX - 2
        y := Cords[2] + captureY - 10
        MouseMove(x, y)
        Sleep(25)
        Click
        Gdip_DisposeImage(pBMScreen)
    } else {
        Gdip_DisposeImage(pBMScreen)
        return 0
    }

    loop {
        pBMScreen := Gdip_BitmapFromScreen(captureX "|" captureY "|" captureWidth "|" captureHeight)
        If (Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock"], &OutputList, , , , , 3,,3) = 1 || Gdip_ImageSearch(pBMScreen, bitmaps["GreenStock2"], &OutputList , , , , , 3,,3) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + captureX - 5
            y := Cords[2] + captureY - 10
            MouseMove(x, y)
            Click
            Gdip_DisposeImage(pBMScreen)
            Sleep(25)
        } else {
            Gdip_DisposeImage(pBMScreen)
            PlayerStatus("Bought " list[index] "s!", "0x22e6a8",,false)
            return 1
        }
        if (A_index >= 5){
            SpamClick(5)
        }

        if (A_index == 50) {
            Gdip_DisposeImage(pBMScreen)
            return 0
        }
    }

}

buyShop(itemList, itemType, crafting := false){
    if (itemType == "Event" || itemType == "Eggs" || itemType == "Gears"){
        pos := 0.9
    } else if (itemType == "SantasStash"){
        pos := 0.835
    } else {
        pos := 0.9
    }
    

    for (item in itemlist){
        if (A_index == 1){
            if (crafting){
                relativeMouseMove(0.65,0.4)  
                Sleep(250)
                Click
                Sleep(250)
                Click
                Sleep(250)
            } 
            relativeMouseMove(0.4,pos)
            Loop itemList.length * 2.5 {
                Send("{WheelUp}")
                Sleep 20
            }
            Sleep(250)
            Click
            Sleep(250)
            Loop 12 {
                Send("{WheelUp}")
                Sleep 20
            }
            relativeMouseMove(0.5,0.4)
            Sleep(250)
        } else {
            relativeMouseMove(0.4,pos)
        }
        Click
        Sleep(350)
        if (A_Index >= 23 && itemType != "Seeds") {
            ScrollDown(0.25)
            Sleep(250)
        } else if ((A_Index >= 14 && itemType == "GearCrafting")){
            ScrollDown(0.25 + A_Index * 0.025)
            Sleep(250)
        }

        if (CheckSetting(itemType, StrReplace(item, " ", ""))){
            CheckStock(A_Index, itemlist, crafting)
        } else {
            Sleep(200)
        }
    }
    CloseShop(crafting)
}


ScrollDown(amount := 1) {
    BaseHeight := 1080

    ; Scale factor (based mostly on height, since scroll is vertical)
    Scale := WindowHeight / BaseHeight

    AdjustedAmount := Round(-amount * 120 * Scale)

    DllCall("user32.dll\mouse_event"
        , "UInt", 0x0800   ; MOUSEEVENTF_WHEEL
        , "UInt", 0
        , "UInt", 0
        , "UInt", AdjustedAmount
        , "UPtr", 0)
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
        case 2:
            if (option == 1){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (540  / 1080)
            } else if (option == 2){
                MouseMove windowWidth * (1500 / 1920), windowHeight * (750  / 1080)
            }
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
            Sleep(2500)
            PlayerStatus("Detected " shop " shop opened", "0x22e6a8",,false,,false)
            return 1
        }
    }
    PlayerStatus("Failed to open " shop " shop", "0x22e6a8",,false,,true)
    return 0
}


CloseShop(crafting := false){
    if (crafting == True){
        return 1
    }
    loop 15 {
        Sleep(500)
        if (Clickbutton("Xbutton") == 1){
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
    Sleep(200)
    CloseTokenGui()
    Clickbutton("Robux")
    Sleep(100)
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
            PlayerStatus("This is a very rare error! " e.Message, "0xFF0000",,true,,false)
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

initShops(){
    static Shopinit := true
    static Egginit := true
    static Merchantinit := true
    static Cosemticinit := true
    if (Shopinit == true){
        if ((Mod(A_Min, 10) = 3 || Mod(A_Min, 10) = 8)) {
            global LastShopTime := nowUnix()
            BuySeeds()
            BuyGears()
            Shopinit := false
        }
    } else if (Egginit == true){
        if (A_Min == 22 || A_Min == 52) {
            global LastEggsTime := nowUnix()
            BuyEggs()
            Egginit := false
        }
    } else if (Merchantinit == true){
        if (A_min < 5) {
            global LastMerchantTime := nowUnix()
            BuyMerchant()
            Merchantinit := false
        }
    } else if (Cosemticinit == true){
        UtcNow := A_NowUTC
        UtcHour := FormatTime(UtcNow, "H")
        if (Mod(UtcHour, 4) == 0 && A_min < 5) {
            global LastCosmetics := nowUnix()
            BuyCosmetics()
            Cosemticinit := false
        }
    } 


}

BuySeeds(){
    seedItems := getItems("Seeds")
    if !(CheckSetting("Seeds", "Seeds")){
        return
    }
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
    PlayerStatus("Failed to buy seeds 3 times, CLOSING ROBLOX!", "0x001a12")
    CloseRoblox()
}






BuyGears(){
    gearItems := getItems("Gears")
    if !(CheckSetting("Gears", "Gears")){
        return
    }
    loop 3 {
        PlayerStatus("Going to buy Gears!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Clickbutton("Garden")
        Sleep(500)
        Send("1")
        Sleep(750)
        relativeMouseMove(0.5, 0.5)
        Click
        Sleep(1500)
        Send("{" Ekey "}")
        if !DetectShop("gear"){
            CameraCorrection()
            continue
        }
        buyShop(gearItems, "Gears")
        CloseClutter()
        return 1
    }
    
    CloseClutter()
    Sleep(1500)
    equipRecall()
    PlayerStatus("Equiped recall wrench, failed to open gear shop 3 times.", "0x001a12")
}


BuyEggs(){
    if !(CheckSetting("Eggs", "Eggs")){
        return
    }
    eggitems := getItems("Eggs")
    loop 3 {
        PlayerStatus("Going to buy Eggs!", "0x22e6a8",,false,,false)
        ActivateRoblox()
        Clickbutton("Garden")
        Sleep(500)
        Send("1")
        MouseMove windowX + windowWidth//2, windowY + windowHeight//2
        Click
        Sleep(2000)
        Send("{s Down}")
        HyperSleep(600)
        Send("{s Up}")
        Sleep(1500)
        Send("{" Ekey "}")
        clickOption(1,4)
        if !DetectShop("egg"){
            CameraCorrection()
            continue
        }
        buyShop(eggitems, "Eggs")
        CloseClutter()
        return 1
    }
}


BuyCosmetics(){
    if !(CheckSetting("Settings", "Cosmetics")){
        return 0 
    }

    PlayerStatus("Going to buy Cosmetics!", "0x22e6a8",,false,,false)
    ActivateRoblox()
    Clickbutton("Garden")
    Sleep(500)
    Send("1")
    MouseMove windowX + windowWidth//2, windowY + windowHeight//2
    Click
    Sleep(2000)
    Send("{w Down}")
    HyperSleep(500)
    Send("{w Up}")
    Sleep(1500)
    Send("{" Ekey "}")
    if !DetectShop("Cosmetic"){
        return 0
    }
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.15
    capY := windowY + windowHeight * 0.3
    capW := windowWidth * 0.65
    capH := windowHeight * 0.5
    loop {
        pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
        if (Gdip_ImageSearch(pBMScreen, bitmaps["Cosmetics"] , &OutputList, , , , , 25) = 1) {
            Cords := StrSplit(OutputList, ",")
            x := Cords[1] + capX
            y := Cords[2] + capY
            MouseMove(x, y)
            Sleep(200)
            Click
        } else {
            Gdip_DisposeImage(pBMScreen)
            break
        }
        if (A_Index == 50) {
            Gdip_DisposeImage(pBMScreen)
            break
        }
        Gdip_DisposeImage(pBMScreen)
    }
    PlayerStatus("Finished buying Cosmetics!", "0x22e6a8",,false)
    CloseShop()
    return 1
}


GearCraft(){
    if !(CheckSetting("GearCrafting", "GearCrafting")){
        return
    }
    PlayerStatus("Going to craft Gears!", "0x22e6a8",,false,,false)
    ActivateRoblox()
    Clickbutton("Garden")
    Sleep(500)
    Send("1")
    Sleep(1000)
    relativeMouseMove(0.5, 0.5)
    Click
    Sleep(2000)
    Send("{" WKey " down}")
    HyperSleep(1200)
    Send("{" WKey " up}")
    Sleep(1000)
    GearRecipe := [
        { Name: "Lightning Rod", Materials: ["Poop"], CraftTime: 2700 },
        { Name: "Tanning Mirror", Materials: ["Poop"], CraftTime: 2700 },
        { Name: "Reclaimer", Materials: ["Poop"], CraftTime: 1500 },
        { Name: "Event Lantern", Materials: ["Poop"], CraftTime: 10 },
        { Name: "Anti Bee Egg", Materials: ["Poop"], CraftTime: 7200 },
        { Name: "Small Toy", Materials: ["Poop"], CraftTime: 600 },
        { Name: "Small Treat", Materials: ["Poop"], CraftTime: 600 },
        { Name: "Pet Pouch", Materials: ["Poop"], CraftTime: 1800 },
        { Name: "Pack Bee", Materials: ["Poop"], CraftTime: 14400 },
        { Name: "Silver Ingot", Materials: ["Poop"], CraftTime: 60 },
        { Name: "Gold Ingot", Materials: ["Poop"], CraftTime: 60 },
        { Name: "Silver Piggy", Materials: ["Poop"], CraftTime: 1800 },
        { Name: "Golden Piggy", Materials: ["Poop"], CraftTime: 2700 },
        { Name: "Chimera Stone", Materials: ["Poop"], CraftTime: 3600 },
        
        
    ]
    GearNames := getItems("GearCrafting")

    global GearCraftingTime
    GearCraftingTime := Crafting(GearRecipe, "GearCrafting", GearNames)
    Sleep(1000)

}


SeedCraft(){
    if !(CheckSetting("SeedCrafting", "SeedCrafting")){
        return
    }
    PlayerStatus("Going to craft Seeds!", "0x22e6a8",,false,,false)
    ActivateRoblox()
    Clickbutton("Garden")
    Sleep(500)
    Send("1")
    Sleep(1000)
    relativeMouseMove(0.5, 0.5)
    Click
    Sleep(2000)
    Send("{" WKey " down}")
    HyperSleep(800)
    Send("{" WKey " up}")
    Sleep(1000)
    SeedRecipe := [
        { Name: "Mandrake", Materials: ["Poop"], CraftTime: 300 },
        { Name: "Evo Apple I", Materials: ["Poop"], CraftTime: 600 },        
        { Name: "Evo Apple II", Materials: ["Poop"], CraftTime: 1200 },        
        { Name: "Evo Apple III", Materials: ["Poop"], CraftTime: 1800 },        
        { Name: "Evo Apple IV", Materials: ["Poop"], CraftTime: 2400 },        
        { Name: "Olive", Materials: ["Poop"], CraftTime: 900 },        
        { Name: "Hollow Bamboo", Materials: ["Poop"], CraftTime: 2700 },        
        { Name: "Yarrow", Materials: ["Poop"], CraftTime: 3600 },        
    ]
    SeedNames := getItems("SeedCrafting")


    global SeedCraftingtime
    SeedCraftingTime := Crafting(SeedRecipe, "SeedCrafting", SeedNames) 
    Sleep(1000)

}



BuyMerchant(){
    if !(CheckSetting("Settings", "TravelingMerchant")){
        return
    }

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
    merchantItems := [
        "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant",
        "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant",
        "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant", "TravelingMerchant"
    ]

    DetectOnett()
    if DetectShop("traveling merchant"){
        buyShop(merchantItems, "Settings")
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
    if (Gdip_ImageSearch(pBMScreen, bitmaps["HoneyMerchant"], , , , , , 50) = 1) {
        PlayerStatus("My goat Onett has arrived!!","0xe1ff00",,false)
        Send("{" Ekey "}")
        clickOption(2,5)
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false

}


Closelb(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth - 300  
    capY := windowY                      
    capW := 300                          
    capH := 200                          
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Leaderboard"], , , , , , 50) = 1) {
        Send("{Tab}")
        Sleep(100)
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
GearCraftingTime := 10000000000
SeedCraftingTime := 10000000000
EventCraftingTime := 10000000000

MainLoop() {

    if (GetRobloxHWND()){
        ResizeRoblox()
    }
    
    if (Disconnect()){
        Sleep(1500)
        return
    }

    MyWindow.Destroy()
    CloseChat() 
    Closelb()
    equipRecall()
    CameraCorrection()
    CookingEvent()
    BuySeeds()
    BuyGears()
    BuyEggs()
    BuySantasStash()
    ; BuyEvent()
    BuyCosmetics()
    global LastCookingTime := nowUnix()
    GearCraft()
    global LastGearCraftingTime := nowUnix()
    SeedCraft()
    global LastSeedCraftingTime := nowUnix()
    BuyMerchant()
    global LastEventCraftingtime := nowUnix()
    loop {
        initShops()
        
        if (((Mod(A_Min, 10) = 2 || Mod(A_Min, 10) = 7)) && A_Sec == 30) {
            CameraCorrection()
        }
        if ((Mod(A_Min, 10) = 3 || Mod(A_Min, 10) = 8)) {
            RewardInterupt()
        }
        if (Mod(A_Index, 30) == 0){
            CloseClutter()
            Closelb()
            if (Disconnect()){
                Sleep(1500)
                equipRecall()
                Sleep(500)
                CameraCorrection()
            }
        }
        ShowToolTip()
        Sleep(1000)
    }
    
    
    
}


ShowToolTip(){
    global LastShopTime
    global LastEggsTime
    global LastSantasStashTime
    ; global LastfallCosmeticsTime
    global LastDevillishDecorTime
    global LastCreepyCrittersTime
    global LastMerchantTime
    global LastGearCraftingTime
    global LastSeedCraftingTime
    global LastCookingTime

    global GearCraftingTime
    global SeedCraftingTime

    static SeedsEnabled := IniRead(settingsFile, "Seeds", "Seeds") + 0
    static GearsEnabled := IniRead(settingsFile, "Gears", "Gears") + 0
    static EggsEnabled := IniRead(settingsFile, "Eggs", "Eggs") + 0
    static SantasStashEnabled := IniRead(settingsFile, "SantasStash", "SantasStash") + 0
    ; static fallCosmeticsEnabled := IniRead(settingsFile, "fallCosmetics", "fallCosmetics") + 0
    static DevillishDecorEnabled := IniRead(settingsFile, "DevillishDecor", "DevillishDecor") + 0
    static CreepyCrittersEnabled := IniRead(settingsFile, "CreepyCritters", "CreepyCritters") + 0
    static gearCraftingEnabled := IniRead(settingsFile, "GearCrafting", "GearCrafting") + 0
    static seedCraftingEnabled := IniRead(settingsFile, "SeedCrafting", "SeedCrafting") + 0
    static cosmeticEnabled := IniRead(settingsFile, "Settings", "Cosmetics") + 0
    static merchantEnabled := IniRead(settingsFile, "Settings", "TravelingMerchant") + 0
    static CookingEnabled := IniRead(settingsFile, "Settings", "CookingEvent") + 0


    currentTime := nowUnix()

    tooltipText := ""
    if (SeedsEnabled) {
        static SeedTime := 300
        SeedRemaining := Max(0, SeedTime - (currentTime - LastShopTime))
        tooltipText .= "Seeds: " (SeedRemaining // 60) ":" Format("{:02}", Mod(SeedRemaining, 60)) "`n"
    }


    if (GearsEnabled) {
        static GearTime := 300
        GearRemaining := Max(0, GearTime - (currentTime - LastShopTime))
        tooltipText .= "Gears: " (GearRemaining // 60) ":" Format("{:02}", Mod(GearRemaining, 60)) "`n"
    }
    if (SantasStashEnabled) {
        static SantasStashTime := 1800
        SantasStashRemaining := Max(0, SantasStashTime - (currentTime - LastSantasStashTime))
        tooltipText .= "SantasStash: " (SantasStashRemaining // 60) ":" Format("{:02}", Mod(SantasStashRemaining, 60)) "`n"
    }
    ; if (fallCosmeticsEnabled) {
    ;     static fallCosmeticsTime := 3600
    ;     fallCosmeticsRemaining := Max(0, fallCosmeticsTime - (currentTime - LastfallCosmeticsTime))
    ;     tooltipText .= "fallCosmetics: " (fallCosmeticsRemaining // 60) ":" Format("{:02}", Mod(fallCosmeticsRemaining, 60)) "`n"
    ; }
    if (DevillishDecorEnabled) {
        static DevillishDecorTime := 3600
        DevillishDecorRemaining := Max(0, DevillishDecorTime - (currentTime - LastDevillishDecorTime))
        tooltipText .= "DevillishDecor: " (DevillishDecorRemaining // 60) ":" Format("{:02}", Mod(DevillishDecorRemaining, 60)) "`n"
    }
    if (CreepyCrittersEnabled) {
        static CreepyCrittersTime := 3600
        CreepyCrittersRemaining := Max(0, CreepyCrittersTime - (currentTime - LastCreepyCrittersTime))
        tooltipText .= "CreepyCritters: " (CreepyCrittersRemaining // 60) ":" Format("{:02}", Mod(CreepyCrittersRemaining, 60)) "`n"
    }
    if (EggsEnabled) {
        static EggTime := 1800
        EggRemaining := Max(0, EggTime - (currentTime - LastEggsTime))
        tooltipText .= "Eggs: " (EggRemaining // 60) ":" Format("{:02}", Mod(EggRemaining, 60)) "`n"
    }
    if (CookingEnabled) {
        static CookingTime := Integer(IniRead(settingsFile, "Settings", "CookingTime") * 1.1)
        CookingRemaining := Max(0, CookingTime - (currentTime - LastCookingTime))
        cookingM := CookingRemaining // 60
        cookingS := Mod(CookingRemaining, 60)
        tooltipText .= "Cooking: " cookingM ":" Format("{:02}", cookingS) "`n"
    }
    if (cosmeticEnabled) {
        utcNow := A_NowUTC
        utcHour := FormatTime(utcNow, "H")
        utcMin := FormatTime(utcNow, "m")
        utcSec := FormatTime(utcNow, "s")

        totalSecNow := utcHour * 3600 + utcMin * 60 + utcSec
        nextcosmeticSec := Ceil(totalSecNow / (4 * 3600)) * 4 * 3600
        remainingSec := Mod(nextcosmeticSec - totalSecNow, 14400)  ; every 4 hours

        cosmeticH := remainingSec // 3600
        cosmeticM := Mod(remainingSec, 3600) // 60
        cosmeticS := Mod(remainingSec, 60)

        tooltipText .= "Cosmetics: " cosmeticH ":" Format("{:02}", cosmeticM) ":" Format("{:02}", cosmeticS) "`n"
    }
    if (merchantEnabled) {
        static merchantTime := 3600
        merchantRemaining := Max(0, merchantTime - (currentTime - LastMerchantTime))
        tooltipText .= "Merchant: " (merchantRemaining // 60) ":" Format("{:02}", Mod(merchantRemaining, 60)) "`n"
    }
    if (gearCraftingEnabled) {
        gearCraftRemaining := Max(0, GearCraftingTime - (currentTime - LastGearCraftingTime))
        gearM := gearCraftRemaining // 60
        gearS := Mod(gearCraftRemaining, 60)
        tooltipText .= "Gear Crafting: " gearM ":" Format("{:02}", gearS) "`n"
    }

    if (seedCraftingEnabled) {
        seedCraftRemaining := Max(0, SeedCraftingTime - (currentTime - LastSeedCraftingTime))
        seedM := seedCraftRemaining // 60
        seedS := Mod(seedCraftRemaining, 60)
        tooltipText .= "Seed Crafting: " seedM ":" Format("{:02}", seedS) "`n"
    }
    

    ToolTip(tooltipText, 100, 100)
}


CloseTokenGui(){
    ActivateRoblox()
    hwnd := GetRobloxHWND()
    GetRobloxClientPos(hwnd)
    capX := windowX + windowWidth * 0.6
    capY := windowY + windowHeight * 0.3
    capW := windowWidth * 0.2
    capH := windowHeight * 0.3
    pBMScreen := Gdip_BitmapFromScreen(capX "|" capY "|" capW "|" capH)
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton3"],&OutputList , , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(200)  
        Click
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    if (Gdip_ImageSearch(pBMScreen, bitmaps["Xbutton4"],&OutputList , , , , , 25) = 1) {
        Cords := StrSplit(OutputList, ",")
        x := Cords[1] + capX
        y := Cords[2] + capY
        MouseMove(x, y)
        Sleep(200)  
        Click
        Gdip_DisposeImage(pBMScreen)
        return true
    }
    Gdip_DisposeImage(pBMScreen)
    return false
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
    buyShop(getItems("SantasStash"), "SantasStash")
    PauseMacro()
}

CookingEvent(){
    if !(CheckSetting("Settings", "CookingEvent")){
        return 0
    }

    PlayerStatus("Going to Cooking Event!", "0x22e6a8",,false,,false)
    Clickbutton("Garden")
    Sleep(1500)
    Send("{" Ekey "}")
    Send("{" Ekey "}")
    Sleep(2500)
    if (Clickbutton("Robux") == 1){
        PlayerStatus("Crafting not finished. Closing Robux prompt.","0xe67e22",,false)
        return 0
    }
    PlayerStatus("Claimed food!", "0x22e6a8",,false)
    searchListraw := IniRead(settingsFile, "Settings", "SearchList")
    searchList := StrSplit(searchListRaw, ",")
    for index, item in searchList {
        item := Trim(item)
        searchItem(item)
        Sleep(500)
        clickCategory("Fruit")
        Sleep(500)
        clickItem(item, "Bracket")
        Sleep(500)
        Send("{" Ekey "}")
        Send("{" Ekey "}")
        Sleep(500)
    }
    ZoomAlign()
    thing := 0.2
    loop 25 {
        thing += 0.025
        relativeMouseMove(0.5, thing)
        Click
    }
    CloseClutter()
    PlayerStatus("Cooking food!", "0x22e6a8",,false)
    Send("1")
    Sleep(250)
    Send("1")
}




BuySantasStash(){
    if !(CheckSetting("SantasStash", "SantasStash")){
        return 0
    }

    PlayerStatus("Going to Santas Stash Shop!", "0x22e6a8",,false,,false)

    searchItem("Event Lantern")
    clickItem("Event Lantern", "Event Lantern")
    Sleep(1000)
    Walk(1250,WKey)
    Sleep(1000)
    Send("{" Ekey "}")
    if !DetectShop("SantasStash"){
        return 0 
    }
    buyShop(getItems("SantasStash"), "SantasStash")
    CloseClutter()
    Clickbutton("Garden")
    return 1
}


BuyDevillishDecor(){
    if !(CheckSetting("DevillishDecor", "DevillishDecor")){
        return 0
    }
    PlayerStatus("Going to DevillishDecor Shop!", "0x22e6a8",,false,,false)

    searchItem("Event Lantern")
    clickItem("Event Lantern", "Event Lantern")

    Sleep(1500)
    Walk(600, Skey)
    Sleep(500)
    Walk(1750, Akey)
    Send("{" Ekey "}")
    if !DetectShop("DevillishDecor"){
        return 0 
    }
    buyShop(getItems("DevillishDecor"), "DevillishDecor")
    CloseClutter()
    return 1
}

BuyCreepyCritters(){
    if !(CheckSetting("CreepyCritters", "CreepyCritters")){
        return 0
    }
    PlayerStatus("Going to CreepyCritters Shop!", "0x22e6a8",,false,,false)

    searchItem("Event Lantern")
    clickItem("Event Lantern", "Event Lantern")

    Sleep(1500)
    Walk(600, Skey)
    Sleep(500)
    Walk(1750, Akey)
    Send("{" Ekey "}")

    if !DetectShop("CreepyCritters"){
        return 0 
    }
    buyShop(getItems("CreepyCritters"), "CreepyCritters")
    CloseClutter()
    return 1
}


; BuyfallCosmetics(){
;     if !(CheckSetting("fallCosmetics", "fallCosmetics")){
;         return 0
;     }
;     PlayerStatus("Going to fallCosmetics Shop!", "0x22e6a8",,false,,false)
;     if !DetectShop("fallCosmetics"){
;         return 0 
;     }
;     buyShop(getItems("fallCosmetics"), "fallCosmetics")
;     CloseClutter()
;     return 1
; }



