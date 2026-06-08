/**
 * @param {string Boolean} statusImage Pbitmap or Boolean
 * @param {string} statusColor RGB color codes. Example: 0xe67e22
 */
PlayerStatus(statusTitle, statusColor, statusDescription := "", Mentions := True, content := "", statusImage := True, statusTimestamp := True) {
    url := IniRead(settingsFile, "Settings", "url", "")
    if (url == "") {
        return
    }
    
    try {
        FileExist("ss.jpg") ? FileDelete("ss.jpg") : ""
    } catch Error as e {
        return 0
    }

    DiscordUserId := IniRead(settingsFile, "Settings", "discordID", "")
    mentionStr := Mentions ? "<@" DiscordUserId ">" : ""

    ; Create a timestamp in the proper ISO 8601 format
    timestamp := FormatTime(A_NowUTC, "yyyy-MM-ddTHH:mm:ssZ")

    ; Build the JSON payload with the timestamp
    payload_json := '{"content": "' content ' ' mentionStr '", "embeds": [{"title": "' statusTitle '", "description": "' statusDescription '", "color": ' statusColor + 0

    if (statusTimestamp == true){
        payload_json .= ', "timestamp": "' timestamp '"'
}

    if (statusImage == True) {
        pToken := Gdip_Startup()
        hwnd := GetRobloxHWND()
        GetRobloxClientPos(hwnd)
        pBitmap := Gdip_BitmapFromScreen((windowWidth > 0) ? (windowX "|" windowY "|" windowWidth "|" windowHeight) : 0)
        Gdip_SaveBitmapToFile(pBitmap, "ss.jpg")
        Gdip_DisposeImage(pBitmap)
        payload_json .= ', "image": {"url": "attachment://ss.jpg"}'
    } else if (statusImage != "" && statusImage != True && statusImage != False) {
        Gdip_SaveBitmapToFile(statusImage, "ss.jpg")
        Gdip_DisposeImage(statusImage)
        payload_json .= ', "image": {"url": "attachment://ss.jpg"}'
    }

    payload_json .= '}]}'

    objParam := Map("payload_json", payload_json)

    if (statusImage != False) {
        objParam["file"] := ["ss.jpg"]  
    }

    try {
        CreateFormDataClass(&postdata, &hdr_ContentType, objParam)
        webhook := ComObject("WinHttp.WinHttpRequest.5.1")
        webhook.Open("POST", url, true)
        webhook.SetRequestHeader("User-Agent", "AHK")
        webhook.SetRequestHeader("Content-Type", hdr_ContentType)
        webhook.Send(postdata)
        webhook.WaitForResponse()
        
        FileExist("ss.jpg") ? FileDelete("ss.jpg") : ""
    } catch Error as e {
        return
    }
}
