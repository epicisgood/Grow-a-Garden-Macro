nowUnix() {
    return DateDiff(A_NowUTC, "19700101000000", "Seconds")
}

LastShopTime := nowUnix()
LastEggsTime := nowUnix()
LastSantasStashTime := nowUnix()
; LastfallCosmeticsTime := nowUnix()
LastDevillishDecorTime := nowUnix()
LastCreepyCrittersTime := nowUnix()
LastMerchantTime := nowUnix()

LastGearCraftingTime := nowUnix()
LastSeedCraftingTime := nowUnix()
LastEventCraftingtime := nowUnix()
LastCookingTime := nowUnix()

LastCosmetics := nowUnix()

RewardChecker() {
    global LastGearCraftingTime, EventCraftingtime, LastSeedCraftingTime, LastCookingTime, LastShopTime, LastEggsTime,
        LastCosmetics, LastMerchantTime, LastSantasStashTime, LastCreepyCrittersTime, lastDevillishDecorTime
    ; , LastfallCosmeticsTime

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
    ; if (currentTime - LastfallCosmeticsTime >= 3600) {
    ;     LastfallCosmeticsTime := currentTime
    ;     Rewardlist.Push("fallCosmetics")
    ; }
    if (currentTime - LastDevillishDecorTime >= 3600) {
        LastDevillishDecorTime := currentTime
        Rewardlist.Push("DevillishDecor")
    }
    if (currentTime - LastCreepyCrittersTime >= 3600) {
        LastCreepyCrittersTime := currentTime
        Rewardlist.Push("CreepyCritters")
    }
    if (currentTime - LastSantasStashTime >= 1800) {
        LastSantasStashTime := currentTime
        Rewardlist.Push("SantasStash")
    }
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
        if (v = "Gears") {
            BuyGears()
        }
        if (v = "Eggs") {
            BuyEggs()
        }
        if (v = "SantasStash") {
            BuySantasStash()
        }
        ; if (v = "fallCosmetics"){
        ;     BuyfallCosmetics()
        ; }
        if (v = "DevillishDecor") {
            BuyDevillishDecor()
        }
        if (v = "CreepyCritters") {
            BuyCreepyCritters()
        }
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
