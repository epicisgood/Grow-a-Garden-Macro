nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}


LastShopTime := nowUnix()
LastSeeds2Time := nowUnix()
LastEggs2Time := nowUnix()
LastEggsTime := nowUnix()
LastEvoSeedsTime := nowUnix()
; LastfallCosmeticsTime := nowUnix()
; LastfallGearsTime := nowUnix()
; LastfallPetsTime := nowUnix()
LastMerchantTime := nowUnix()

LastGearCraftingTime := nowUnix()
LastSeedCraftingTime := nowUnix()
LastEventCraftingtime := nowUnix()
LastCookingTime := nowUnix()

LastCosmetics := nowUnix()

RewardChecker() {
    global LastGearCraftingTime, EventCraftingtime, LastSeedCraftingTime, LastCookingTime, LastShopTime, LastSeeds2Time, LastEggsTime, LastCosmetics, LastMerchantTime, LastEggs2Time,
    LastEvoSeedsTime 
    ; , LastfallPetsTime, lastfallGearsTime, LastfallCosmeticsTime

    static CookingTime := Integer(IniRead(settingsFile, "Settings", "CookingTime") * 1.1)

    Rewardlist := []

    currentTime := nowUnix()


    if (currentTime - LastShopTime >= 300) {
        LastShopTime := currentTime
        Rewardlist.Push("Seeds")
        Rewardlist.Push("Gears")
        Rewardlist.Push("EvoSeeds")
        
    }
    if (currentTime - LastSeeds2Time >= 3600) {
        LastSeeds2Time := currentTime
        Rewardlist.Push("Seeds2")
    }
    if (currentTime - LastEggsTime >= 1800) {
        LastEggsTime := currentTime
        Rewardlist.Push("Eggs")
    }
    if (currentTime - LastEggs2Time >= 1800) {
        LastEggs2Time := currentTime
        Rewardlist.Push("Eggs2")
    }
    ; if (currentTime - LastfallCosmeticsTime >= 3600) {
    ;     LastfallCosmeticsTime := currentTime
    ;     Rewardlist.Push("fallCosmetics")
    ; }
    ; if (currentTime - LastfallGearsTime >= 3600) {
    ;     LastfallGearsTime := currentTime
    ;     Rewardlist.Push("fallGears")
    ; }
    ; if (currentTime - LastfallPetsTime >= 3600) {
    ;     LastfallPetsTime := currentTime
    ;     Rewardlist.Push("fallPets")
    ; }
    if (currentTime - LastMerchantTime >= 3600) {
        LastMerchantTime := currentTime
        Rewardlist.Push("TravelingMerchant")
    }
    if (currentTime - LastCosmetics >= 14400) {
        LastCosmetics := currentTime
        Rewardlist.Push("Cosmetics")
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
        if (v = "Seeds2") {
            BuySeeds2()
        }
        if (v = "Gears") {
            BuyGears()
        }
        if (v = "Eggs") {
            BuyEggs()
        }
        if (v = "Eggs2") {
            BuyEggs2()
        }
        if (v = "EvoSeeds"){
            BuyEvoSeeds()
        }
        ; if (v = "fallCosmetics"){
        ;     BuyfallCosmetics()
        ; }
        ; if (v = "fallGears"){
        ;     BuyfallGears()
        ; }
        ; if (v = "fallPets"){
        ;     BuyfallPets()
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


