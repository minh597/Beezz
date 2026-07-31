-- Kaitun Config
-- Copy vào script chính hoặc đặt trước khi chạy

getgenv().KeyKaitun = "" -- API Key từ Bocchi World

-- Cài đặt gem
getgenv().Gem = 1000 -- Số gem cần để change acc / về lobby

-- Cài đặt bán unit
getgenv().SellDelay = 1 -- Delay giữa mỗi lần sell (giây)
getgenv().SellOnWave = 10 -- Wave cần bán tất cả unit

-- Cài đặt đặt unit
getgenv().MaxPlacement = 50 -- Số unit tối đa được đặt

-- Cài đặt evolution
getgenv().EvoGem = 1000 -- Số gem cần để evolution

getgenv().UnitEvo = {
    -- Bật evolution cho unit nào
    -- Ví dụ: ["unit_id"] = true
}

-- Cài đặt auto sell theo rarity
getgenv().autosell_rare = false
getgenv().autosell_epic = false
getgenv().autosell_rare_shiny = false
getgenv().autosell_epic_shiny = false
getgenv().autosell_legendary = false
getgenv().autosell_legendary_shiny = false

-- Vị trí đặt unit (Vector3)
getgenv().PlacePosition = {
    x = 20,
    y = 20,
    z = 20,
}
