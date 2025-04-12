local QBCore = exports['qb-core']:GetCoreObject()
local Balance = 0
local location = {}
local BMItems = {}
local PackageCooldowns = {}

RegisterNetEvent('ik-blackmarket:server:RandomLocation', function()
    for k, v in pairs(Config.Locations) do
        if v["products"] == nil then
            print("Config.Locations['"..k.."'] can't find its product table")
        end
        if Config.RandomLocation then
            local m = math.random(1, #v["coords"])
            location = {bm = k, loc= m, data = v}
            m = 0
        end
    end
end)

if Config.UseTimer then
    CreateThread(function()
        local minutes = Config.ChangeLocationTime
        while true do
            Wait(60000)
            minutes = minutes - 1
            if minutes == 0 then
                TriggerEvent('ik-blackmarket:server:RandomLocation')
                TriggerClientEvent("ik-blackmarket:client:removeall", -1)
                TriggerClientEvent('ik-blackmarket:client:CreatePed', -1)
                minutes = Config.ChangeLocationTime
            end
        end
    end)
end

QBCore.Functions.CreateCallback("ik-blackmarket:server:PedLocation", function (_, cb)
    cb(location)
end)

QBCore.Functions.CreateCallback("ik-blackmarket:server:GetBMLocation", function (_, cb)
    cb(location)
end)

-- ##### Package Buy System ##### --
RegisterNetEvent('ik-blackmarket:server:BuyPackage', function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local pkg = Config.Packages[id]
    if not pkg then return end

    local cooldownKey = src .. ":" .. id
    local now = os.time()
    if PackageCooldowns[cooldownKey] and now < PackageCooldowns[cooldownKey] then
        local timeLeft = PackageCooldowns[cooldownKey] - now
        TriggerClientEvent('QBCore:Notify', src, 'Cooldown active: ' .. timeLeft .. 's', 'error')
        return
    end

    local BlackMoneyName = Config.BlackMoneyName
    local balance = Player.Functions.GetItemByName(BlackMoneyName)?.amount or 0
    if balance < pkg.price then
        TriggerClientEvent('QBCore:Notify', src, 'Not enough dirtymoney', 'error')
        return
    end

    Player.Functions.RemoveItem(BlackMoneyName, pkg.price)
    for _, item in pairs(pkg.items) do
        Player.Functions.AddItem(item.name, item.amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", item.amount)
    end

    PackageCooldowns[cooldownKey] = now + (pkg.cooldown or 600)
    TriggerClientEvent('QBCore:Notify', src, 'Package purchased!', 'success')
end)

-- ##### Other Shop Logic ##### --

-- ... (rest of original code unchanged)

RegisterNetEvent("ik-blackmarket:server:callCops", function(coords)
    local alertData = {
        title = "10-33 | Shop Robbery",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Someone Is WireTapping Phonecalls!"
    }
    TriggerClientEvent("ik-blackmarket:client:wiretappingCall", -1, coords)
    TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
end)
