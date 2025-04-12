Config = {
    Debug = false,
    img = "qs-inventory/html/images/",
    MaxSlots = 41,
    MaxWeight = 120000,
    Measurement = "kg",
    RandomLocation = false,
    RemoveItem = false,
    UseDirtyMoney = true,
    Payment = "blackmoney",
    BlackMoneyName = "dirtymoney",
    BlackMoneyMultiplier = 1.0,
    UseTimer = false,
    ChangeLocationTime = 30,
    EnableHacking = true,
    Stock = true
}

Config.PhoneModels = {
    "prop_phonebox_04",
    "prop_phonebox_01a"
}

Config.Minigame = "keyminigame"
Config.Dispatch = "qbcore"

Config.Categories = {
    pistols = {
        label = "Pistols",
        items = {
            { name = 'weapon_pistol', price = 60000, amount = 5 },
            { name = 'weapon_combatpistol', price = 65000, amount = 5 },
            { name = 'weapon_pistol50', price = 70000, amount = 5 },
            { name = 'weapon_heavypistol', price = 75000, amount = 5 },
        }
    },
    smgs = {
        label = "SMGs",
        items = {
            { name = 'weapon_microsmg', price = 80000, amount = 5 },
            { name = 'weapon_smg', price = 70000, amount = 5 },
            { name = 'weapon_assaultsmg', price = 70000, amount = 5 },
        }
    },
    rifles = {
        label = "Rifles",
        items = {
            { name = 'weapon_assaultrifle', price = 100000, amount = 5 },
            { name = 'weapon_carbinerifle', price = 110000, amount = 5 },
            { name = 'weapon_advancedrifle', price = 120000, amount = 5 },
        }
    },
    shotguns = {
        label = "Shotguns",
        items = {
            { name = 'weapon_pumpshotgun', price = 110000, amount = 5 },
            { name = 'weapon_sawnoffshotgun', price = 110000, amount = 5 },
            { name = 'weapon_bullpupshotgun', price = 100000, amount = 5 },
        }
    },
    lmgs = {
        label = "LMGs",
        items = {
            { name = 'weapon_mg', price = 220000, amount = 5 },
            { name = 'weapon_combatmg', price = 230000, amount = 5 },
        }
    },
    snipers = {
        label = "Snipers",
        items = {
            { name = 'weapon_sniperrifle', price = 250000, amount = 5 },
            { name = 'weapon_heavysniper', price = 300000, amount = 5 },
        }
    },
    ammo = {
        label = "Ammo",
        items = {
            { name = 'pistol_ammo', price = 250, amount = 100 },
            { name = 'rifle_ammo', price = 500, amount = 100 },
            { name = 'smg_ammo', price = 500, amount = 100 },
            { name = 'shotgun_ammo', price = 250, amount = 100 },
            { name = 'mg_ammo', price = 5000, amount = 100 },
            { name = 'snp_ammo', price = 1000, amount = 100 },
        }
    },
    tools = {
        label = "Tools & Devices",
        items = {
            { name = 'security_card_01', price = 2500, amount = 50 },
            { name = 'security_card_02', price = 5000, amount = 50 },
            { name = 'advanced_lockpick', price = 125, amount = 50 },
            { name = 'electronickit', price = 500, amount = 50 },
            { name = 'gatecrack', price = 1000, amount = 50 },
            { name = 'thermite', price = 250, amount = 50 },
            { name = 'trojan_usb', price = 5000, amount = 50 },
            { name = 'drill', price = 5000, amount = 50 },
            { name = 'radioscanner', price = 5000, amount = 50 },
            { name = 'cryptostick', price = 5000, amount = 50 },
            { name = 'exoticsalescard', price = 500, amount = 2 },
            { name = 'dice', price = 10, amount = 10 },
        }
    }
}

Config.Packages = {
    ["meth_kit"] = {
        label = "Meth Starter Kit",
        price = 1000,
        cooldown = 1800,
        items = {
            { name = "methlab", amount = 1 },
            { name = "beaker", amount = 1 },
            { name = "red_phos", amount = 2 },
            { name = "hydrochloricacid", amount = 2 },
            { name = "pestle_and_mortar", amount = 1 },
            { name = "gasmask", amount = 1 },
            { name = "lithium", amount = 1 },
            { name = "crushed_pseudo", amount = 1 },
        }
    }
}

Config.Locations = {
    ["blackmarket"] = {
        label = "Black Market",
        model = {
            `s_f_y_stripper_01`, `s_f_y_stripper_02`, `s_f_y_stripperlite`,
            `g_m_y_ballaeast_01`, `g_m_y_ballaorig_01`, `g_m_y_ballasout_01`,
            `g_m_y_famca_01`, `g_m_y_famdnf_01`, `g_m_y_famfor_01`,
            `g_m_y_lost_01`, `g_m_y_lost_02`, `g_m_y_lost_03`,
            `g_f_y_families_01`, `g_f_y_lost_01`
        },
        coords = {
            [1] = vector4(115.1197, 1239.5315, 217.6069, 190.9227),
        },
        categories = Config.Categories,
        hideblip = true
    }
}

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
