nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}


LastShopTime := nowUnix()
LastEggsTime := nowUnix()

LastGearCraftingTime := nowUnix()
LastSeedCraftingTime := nowUnix()
LastEventCraftingtime := nowUnix()
LastCookingTime := nowUnix()

LastFourHours := nowUnix()

RewardChecker() {
    global LastGearCraftingTime, EventCraftingtime, LastSeedCraftingTime, LastCookingTime, LastShopTime, LastEggsTime, LastFourHours
    static CookingTime := Integer(IniRead(settingsFile, "Settings", "CookingTime") * 1.1)

    Rewardlist := []

    currentTime := nowUnix()


    if (currentTime - LastShopTime >= 300) {
        LastShopTime := currentTime
        Rewardlist.Push("Seeds")
        Rewardlist.Push("Gears")
    }
    if (currentTime - LastEggsTime >= 1800) {
        LastEggsTime := currentTime
        Rewardlist.Push("Eggs")
    }
    ; if (A_Min == 0) {
    ;     Rewardlist.Push("Event")
    ; }
    if (currentTime - LastFourHours >= 14400) {
        Rewardlist.Push("Cosmetics")
    }
    if (currentTime - LastFourHours >= 14400) {
        Rewardlist.Push("TravelingMerchant")
    }
    if (currentTime - LastGearCraftingTime >= GearCraftingTime) {
        Rewardlist.Push("GearCrafting")
    }
    if (currentTime - LastSeedCraftingTime >= SeedCraftingTime) {
        Rewardlist.Push("SeedCrafting")   
    }
    if (currentTime - LastCookingTime >= CookingTime) {
        Rewardlist.Push("Cooking")
    }

    return Rewardlist
}

; Calls RewardChecker -> RewardChecked functions to see if we are able to run those things
RewardInterupt() {

    variable := RewardChecker()

    for (k, v in variable) {
        ToolTip("")
        ActivateRoblox()
        if (v = "Seeds") {
            BuySeeds()
        }
        if (v = "Gears") {
            BuyGears()
        }
        if (v = "Eggs") {
            BuyEggs()
        }
        ; if (v = "Event"){
        ;     BuyEvent()
        ; }
        if (v = "GearCrafting") {
            GearCraft()
            Sleep(2000)
            global LastGearCraftingTime
            LastGearCraftingTime := nowUnix()
        }
        if (v = "SeedCrafting") {
            SeedCraft()
            Sleep(2000)
            global LastSeedCraftingTime
            LastSeedCraftingTime := nowUnix()
        }
        if (v = "TravelingMerchant") {
            BuyMerchant()
        }
        if (v = "Cosmetics") {
            BuyCosmetics()
        }
        if (v = "Cooking") {
            CookingEvent()
            Sleep(2000)
            global LastCookingTime
            LastCookingTime := nowUnix()
        }
    }
    
    if (variable.Length > 0) {
        Clickbutton("Garden")
        relativeMouseMove(0.5, 0.5)
        return 1
    }
}


