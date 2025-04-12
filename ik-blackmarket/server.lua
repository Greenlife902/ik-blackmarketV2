local QBCore = exports['qb-core']:GetCoreObject()
local Balance = 0
local location = {}
local BMItems = {}
local PackageCooldowns = {}

RegisterNetEvent('ik-blackmarket:server:RandomLocation', function()
    for k, v in pairs(Config.Locations) do
        if Config.RandomLocation then
            local m = math.random(1, #v["coords"])
            location = {bm = k, loc = m, data = v}
        end
    end
end)

if Config.UseTimer then
    CreateThread(function()
        local minutes = Config.ChangeLocationTime
        while true do
            Wait(60000)
            minutes -= 1
            if minutes == 0 then
                TriggerEvent('ik-blackmarket:server:RandomLocation')
                TriggerClientEvent("ik-blackmarket:client:removeall", -1)
                TriggerClientEvent('ik-blackmarket:client:CreatePed', -1)
                minutes = Config.ChangeLocationTime
            end
        end
    end)
end

QBCore.Functions.CreateCallback("ik-blackmarket:server:PedLocation", function(_, cb)
    cb(location)
end)

QBCore.Functions.CreateCallback("ik-blackmarket:server:GetBMLocation", function(_, cb)
    cb(location)
end)

-- ✅ Package purchase with cooldown
RegisterNetEvent('ik-blackmarket:server:BuyPackage', function(id, pkg, cooldown)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not pkg then return end

    local key = ("%s:%s"):format(src, id)
    local now = os.time()

    if PackageCooldowns[key] and now < PackageCooldowns[key] then
        TriggerClientEvent('QBCore:Notify', src, "Cooldown active: " .. (PackageCooldowns[key] - now) .. "s", "error")
        return
    end

    local has = Player.Functions.GetItemByName(Config.BlackMoneyName)
    if not has or has.amount < pkg.price then
        TriggerClientEvent("QBCore:Notify", src, "Not enough dirtymoney", "error")
        return
    end

    Player.Functions.RemoveItem(Config.BlackMoneyName, pkg.price)

    for _, item in pairs(pkg.items) do
        Player.Functions.AddItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", item.amount)
    end

    PackageCooldowns[key] = now + cooldown
    TriggerClientEvent("QBCore:Notify", src, "Package purchased!", "success")
end)

-- ✅ Regular item purchase
RegisterNetEvent("ik-blackmarket:GetItem", function(amount, paymentType, item, shoptable, price, _, bm)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local total = tonumber(price) * tonumber(amount)
    local itemData = QBCore.Shared.Items[item]
    if not itemData then return end

    -- Inventory checks
    local weight = 0
    local slots = 0
    for _, v in pairs(Player.PlayerData.items) do
        weight += v.weight * v.amount
        slots += 1
    end
    if (weight + (itemData.weight * amount)) > Config.MaxWeight then
        return TriggerClientEvent("QBCore:Notify", src, "Too heavy", "error")
    end
    if itemData.unique and (Config.MaxSlots - slots) < amount then
        return TriggerClientEvent("QBCore:Notify", src, "Not enough slots", "error")
    end

    -- Payment handling
    local success = false
    if paymentType == "blackmoney" then
        local money = Player.Functions.GetItemByName(Config.BlackMoneyName)
        if money and money.amount >= total then
            Player.Functions.RemoveItem(Config.BlackMoneyName, total)
            success = true
        end
    elseif paymentType == "crypto" then
        if Player.PlayerData.money.crypto >= total then
            Player.Functions.RemoveMoney("crypto", total, "bm-buy")
            success = true
        end
    else
        if Player.PlayerData.money.cash >= total then
            Player.Functions.RemoveMoney("cash", total, "bm-buy")
            success = true
        end
    end

    if not success then
        return TriggerClientEvent("QBCore:Notify", src, "Not enough funds", "error")
    end

    -- Give item
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent("inventory:client:ItemBox", src, itemData, "add", amount)
    TriggerClientEvent("QBCore:Notify", src, "Item purchased!", "success")
end)

RegisterNetEvent("ik-blackmarket:server:callCops", function(coords)
    local alertData = {
        title = "10-33 | Shop Robbery",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Someone is wiretapping phonecalls!"
    }
    TriggerClientEvent("ik-blackmarket:client:wiretappingCall", -1, coords)
    TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
end)
