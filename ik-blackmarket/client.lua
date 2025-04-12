local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ik-blackmarket:ShopMenu', function(data)
    local categories = data.categories
    local ShopMenu = {
        { header = data.name, txt = "", isMenuHeader = true },
        { header = "Close", txt = "", params = { event = "ik-blackmarket:CloseMenu" } }
    }

    for cat, category in pairs(categories) do
        ShopMenu[#ShopMenu + 1] = {
            header = category.label,
            params = {
                event = "ik-blackmarket:client:OpenCategory",
                args = {
                    label = category.label,
                    items = category.items,
                    k = data.k,
                    l = data.l,
                    categories = data.categories,
                    name = data.name
                }
            }
        }
    end

    for id, pkg in pairs(Config.Packages) do
        ShopMenu[#ShopMenu + 1] = {
            header = pkg.label,
            txt = "(Package)",
            params = {
                event = "ik-blackmarket:client:BuyPackage",
                args = {
                    id = id,
                    data = pkg
                }
            }
        }
    end

    exports['qb-menu']:openMenu(ShopMenu)
end)

RegisterNetEvent('ik-blackmarket:client:OpenCategory', function(data)
    local Menu = {
        { header = data.label, txt = "", isMenuHeader = true },
        {
            header = "Back",
            txt = "",
            params = {
                event = "ik-blackmarket:ShopMenu",
                args = {
                    categories = data.categories,
                    name = data.name,
                    k = data.k,
                    l = data.l
                }
            }
        }
    }

    for _, item in ipairs(data.items) do
        local label = QBCore.Shared.Items[item.name] and QBCore.Shared.Items[item.name].label or item.name
        local weight = QBCore.Shared.Items[item.name] and QBCore.Shared.Items[item.name].weight or 0
        Menu[#Menu + 1] = {
            header = label,
            txt = ("Price: $%s<br>Weight: %s %s<br>Stock: %s"):format(item.price, weight / 1000, Config.Measurement, item.amount or 0),
            params = {
                event = "ik-blackmarket:Charge",
                args = {
                    item = item.name,
                    cost = item.price,
                    shoptable = data.items,
                    k = data.k,
                    l = data.l,
                    amount = item.amount
                }
            }
        }
    end

    exports['qb-menu']:openMenu(Menu)
end)

RegisterNetEvent('ik-blackmarket:client:BuyPackage', function(data)
    local pkg = data.data
    local id = data.id
    local cooldown = pkg.cooldown or 0
    TriggerServerEvent('ik-blackmarket:server:BuyPackage', id, pkg, cooldown)
end)

RegisterNetEvent('ik-blackmarket:Charge', function(data)
    local item = data.item
    local cost = data.cost
    local amount = data.amount or 1
    local itemLabel = QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label or item

    local dialog = exports['qb-input']:ShowInput({
        header = "Purchase "..itemLabel,
        submitText = "Buy",
        inputs = {
            {
                type = "number",
                isRequired = true,
                name = "amount",
                text = "How many would you like to buy?"
            }
        }
    })

    if dialog then
        local buyAmount = tonumber(dialog.amount)
        if not buyAmount or buyAmount <= 0 then
            QBCore.Functions.Notify("Invalid amount.", "error")
            return
        end

        TriggerServerEvent("ik-blackmarket:GetItem", buyAmount, Config.Payment, item, data.shoptable, cost, nil, data.k)
        exports['qb-menu']:closeMenu()
    end
end)

RegisterNetEvent('ik-blackmarket:CloseMenu', function()
    exports['qb-menu']:closeMenu()
end)

function mainthread()
    for k, v in pairs(Config.Locations) do
        for l, b in pairs(v.coords) do
            local pedModel = v.model[math.random(1, #v.model)]
            RequestModel(pedModel)
            while not HasModelLoaded(pedModel) do Wait(0) end

            local npc = CreatePed(0, pedModel, b.x, b.y, b.z - 1.0, b.w, false, false)
            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)

            exports['qb-target']:AddCircleZone("blackmarket_ped_"..k.."_"..l, vector3(b.x, b.y, b.z), 2.0, {
                name = "blackmarket_ped_"..k.."_"..l,
                useZ = true,
            }, {
                options = {
                    {
                        event = "ik-blackmarket:ShopMenu",
                        icon = "fas fa-certificate",
                        label = "Browse Black Market",
                        categories = v.categories,
                        name = v.label,
                        k = k,
                        l = l,
                    },
                },
                distance = 2.0
            })
        end
    end
end

CreateThread(function()
    mainthread()
end)
