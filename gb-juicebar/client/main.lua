local QBCore = exports['qb-core']:GetCoreObject()

local isClockedIn = false
local isProcessingClock = false
local lastOutfit = nil
local spawnedVehicle = nil
local spawnedNPC = nil

local function AttachProp(propName, boneIndex, x, y, z, rx, ry, rz)
    local ped = PlayerPedId()
    local bone = GetPedBoneIndex(ped, boneIndex)
    RequestModel(GetHashKey(propName))
    while not HasModelLoaded(GetHashKey(propName)) do Wait(10) end
    local prop = CreateObject(GetHashKey(propName), 1.0, 1.0, 1.0, true, true, false)
    AttachEntityToEntity(prop, ped, bone, x, y, z, rx, ry, rz, true, true, false, true, 1, true)
    return prop
end

local function RemoveProp(prop)
    if prop and DoesEntityExist(prop) then
        DeleteEntity(prop)
    end
end

local function HasItem(itemName)
    local hasItem = false
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.items then
        for _, item in pairs(playerData.items) do
            if item.name == itemName and item.amount and item.amount > 0 then
                hasItem = true
                break
            end
        end
    end
    return hasItem
end

local function StartProgress(text, duration, onSuccess, onCancel)
    if QBCore.Functions.Progressbar then
        QBCore.Functions.Progressbar("juice_progress", text, duration, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = true,
            disableCombat = true,
        }, {}, {}, {}, onSuccess, onCancel)
    else
        local start = GetGameTimer()
        while GetGameTimer() - start < duration do Wait(100) end
        onSuccess()
    end
end

local dutyUniform = {
    mask = { item = 150, texture = 0 },
    tshirt = { item = 15, texture = 0 },
    pants = { item = 27, texture = 0 },
    shoes = { item = 95, texture = 0 },
    hat = { item = 173, texture = 0 },
    vest = { item = 0, texture = 0 },
    arms = { item = 0, texture = 0 },
    torso2 = { item = 0, texture = 3 }
}

local components = {
    mask = 1,
    arms = 3,
    pants = 4,
    shoes = 6,
    tshirt = 8,
    torso2 = 11
}

RegisterNetEvent('juicebar:applyUniform', function()
    local ped = PlayerPedId()
    lastOutfit = {
        mask = GetPedDrawableVariation(ped, 1),
        maskTexture = GetPedTextureVariation(ped, 1),
        arms = GetPedDrawableVariation(ped, 3),
        armsTexture = GetPedTextureVariation(ped, 3),
        pants = GetPedDrawableVariation(ped, 4),
        pantsTexture = GetPedTextureVariation(ped, 4),
        shoes = GetPedDrawableVariation(ped, 6),
        shoesTexture = GetPedTextureVariation(ped, 6),
        tshirt = GetPedDrawableVariation(ped, 8),
        tshirtTexture = GetPedTextureVariation(ped, 8),
        torso2 = GetPedDrawableVariation(ped, 11),
        torso2Texture = GetPedTextureVariation(ped, 11),
        hat = GetPedPropIndex(ped, 0),
        hatTexture = GetPedPropTextureIndex(ped, 0)
    }
    for part, data in pairs(dutyUniform) do
        if part == "hat" then
            if data.item ~= nil then
                ClearPedProp(ped, 0)
                SetPedPropIndex(ped, 0, data.item, data.texture, true)
            end
        else
            local compId = components[part]
            if compId then
                SetPedComponentVariation(ped, compId, data.item, data.texture, 0)
            end
        end
    end
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
    Wait(2000)
    ClearPedTasksImmediately(ped)
end)

RegisterNetEvent('juicebar:removeUniform', function()
    local ped = PlayerPedId()
    if lastOutfit then
        SetPedComponentVariation(ped, 1, lastOutfit.mask, lastOutfit.maskTexture, 0)
        SetPedComponentVariation(ped, 3, lastOutfit.arms, lastOutfit.armsTexture, 0)
        SetPedComponentVariation(ped, 4, lastOutfit.pants, lastOutfit.pantsTexture, 0)
        SetPedComponentVariation(ped, 6, lastOutfit.shoes, lastOutfit.shoesTexture, 0)
        SetPedComponentVariation(ped, 8, lastOutfit.tshirt, lastOutfit.tshirtTexture, 0)
        SetPedComponentVariation(ped, 11, lastOutfit.torso2, lastOutfit.torso2Texture, 0)
        if lastOutfit.hat and lastOutfit.hat ~= -1 then
            ClearPedProp(ped, 0)
            SetPedPropIndex(ped, 0, lastOutfit.hat, lastOutfit.hatTexture, true)
        else
            ClearPedProp(ped, 0)
        end
    else
        QBCore.Functions.Notify("No previous outfit found. Please change manually.", "error")
    end
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_COP_IDLES", 0, true)
    Wait(2000)
    ClearPedTasksImmediately(ped)
end)

local clockInLocation = vector3(-1248.19, -747.13, 20.83)

CreateThread(function()
    exports['qb-target']:AddBoxZone("JuiceBarClockIn", clockInLocation, 1.5, 1.5, {
        name = "JuiceBarClockIn",
        heading = 0,
        debugPoly = false,
        minZ = clockInLocation.z - 1.0,
        maxZ = clockInLocation.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "juicebar:clockInOut",
                icon = "fas fa-user-clock",
                label = "Clock In / Clock Out",
                job = "juicebar"
            }
        },
        distance = 2.0
    })

    exports['qb-target']:AddBoxZone("juicebar_stash", Config.Stash.coords, 1.5, 1.5, {
        name = "juicebar_stash",
        heading = 0,
        debugPoly = false,
        minZ = Config.Stash.coords.z - 1.0,
        maxZ = Config.Stash.coords.z + 1.0,
    }, {
        options = {
            {
                type = "server",
                event = "qb-juicebar:server:openStash",
                icon = "fas fa-box",
                label = "Open Juice Bar Stash",
                job = "juicebar",
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent('juicebar:clockInOut', function()
    if isProcessingClock then return end
    isProcessingClock = true
    local playerData = QBCore.Functions.GetPlayerData()
    if not playerData.job or playerData.job.name ~= "juicebar" then
        QBCore.Functions.Notify("You are not employed at the Juice Bar!", "error")
        isProcessingClock = false
        return
    end
    if not isClockedIn then
        TriggerEvent('juicebar:applyUniform')
    else
        TriggerEvent('juicebar:removeUniform')
    end
    isClockedIn = not isClockedIn
    TriggerServerEvent('juicebar:clockInOut', isClockedIn)
    Citizen.SetTimeout(1000, function()
        isProcessingClock = false
    end)
end)

local cuttingLocation = vector3(-1249.37, -745.54, 20.83)

CreateThread(function()
    exports['qb-target']:AddBoxZone("JuiceBarCutFruit", cuttingLocation, 1.5, 1.5, {
        name = "JuiceBarCutFruit",
        heading = 0,
        debugPoly = false,
        minZ = cuttingLocation.z - 1.0,
        maxZ = cuttingLocation.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "juicebar:openCuttingNUI",
                icon = "fas fa-cut",
                label = "Cut Whole Fruit",
                job = "juicebar"
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent('juicebar:openCuttingNUI', function()
    if not isClockedIn then
        QBCore.Functions.Notify("You must be on duty to cut fruit.", "error")
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openCuttingMenu" })
end)

RegisterNUICallback('cutFruit', function(data, cb)
    if not isClockedIn then
        QBCore.Functions.Notify("You must be on duty to cut fruit.", "error")
        cb({})
        return
    end
    local fruit = data.fruit
    local sliceItem = data.sliceItem
    if not fruit or not sliceItem then
        cb({})
        return
    end
    if not HasItem(fruit) then
        QBCore.Functions.Notify("You don't have any " .. fruit .. " to cut.", "error")
        cb({})
        return
    end
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    local knifeProp = AttachProp("w_me_knife_01", 57005, 0.15, 0.03, 0.0, 0.0, 0.0, 90.0)
    RequestAnimDict("melee@knife@streamed_core")
    while not HasAnimDictLoaded("melee@knife@streamed_core") do Wait(10) end
    TaskPlayAnim(ped, "melee@knife@streamed_core", "Slash_Forward_A", 8.0, -8.0, -1, 49, 0, false, false, false)
    StartProgress("Cutting " .. fruit, 5000, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        RemoveProp(knifeProp)
        TriggerServerEvent('juicebar:cutFruit', fruit, sliceItem)
        cb({})
    end, function()
        ClearPedTasksImmediately(ped)
        FreezeEntityPosition(ped, false)
        RemoveProp(knifeProp)
        QBCore.Functions.Notify("Cutting cancelled", "error")
        cb({})
    end)
end)

RegisterNUICallback('closeCuttingMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeCuttingMenu" })
    cb({})
end)

local juiceStation = vector3(-1249.14, -748.67, 20.83)

CreateThread(function()
    exports['qb-target']:AddBoxZone("JuiceBarMakeJuice", juiceStation, 1.5, 1.5, {
        name = "JuiceBarMakeJuice",
        heading = 0,
        debugPoly = false,
        minZ = juiceStation.z - 1.0,
        maxZ = juiceStation.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "juicebar:openJuiceNUI",
                icon = "fas fa-blender",
                label = "Prepare Juice",
                job = "juicebar"
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent('juicebar:openJuiceNUI', function()
    if not isClockedIn then
        QBCore.Functions.Notify("You must be on duty to prepare juice.", "error")
        return
    end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openJuiceMenu" })
end)

RegisterNUICallback('prepareJuice', function(data, cb)
    if not isClockedIn then
        QBCore.Functions.Notify("You must be on duty to prepare juice.", "error")
        cb({})
        return
    end
    local juiceType = data.juiceType
    local requiredItem = data.requiredItem
    if not juiceType or not requiredItem then
        cb({})
        return
    end
    QBCore.Functions.TriggerCallback('juicebar:hasIngredient', function(hasItem)
        if not hasItem then
            QBCore.Functions.Notify("You don't have the required ingredient: " .. requiredItem, "error")
            cb({})
            return
        end
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, true)
        local progressCompleted = false
        local function juiceOnSuccess()
            if progressCompleted then return end
            progressCompleted = true
            ClearPedTasksImmediately(ped)
            FreezeEntityPosition(ped, false)
            TriggerServerEvent('juicebar:makeJuice', juiceType, requiredItem)
            cb({})
        end
        local function juiceOnCancel()
            ClearPedTasksImmediately(ped)
            FreezeEntityPosition(ped, false)
            QBCore.Functions.Notify("Juice preparation cancelled", "error")
            cb({})
        end
        TaskStartScenarioInPlace(ped, "PROP_HUMAN_BBQ", 0, true)
        StartProgress("Preparing " .. juiceType, 5000, function()
            ClearPedTasksImmediately(ped)
            Wait(100)
            juiceOnSuccess()
        end, function()
            ClearPedTasksImmediately(ped)
            Wait(100)
            juiceOnCancel()
        end)
        Citizen.SetTimeout(5500, function()
            if not progressCompleted then
                juiceOnSuccess()
            end
        end)
    end, requiredItem)
end)

RegisterNUICallback('closeJuiceMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeJuiceMenu" })
    cb({})
end)

CreateThread(function()
    local spawner = Config.JuiceBarVehicleSpawner
    RequestModel(GetHashKey(spawner.ped))
    while not HasModelLoaded(GetHashKey(spawner.ped)) do Wait(10) end
    spawnedNPC = CreatePed(4, GetHashKey(spawner.ped), spawner.coords.x, spawner.coords.y, spawner.coords.z - 1.0, spawner.coords.w, false, true)
    SetEntityInvincible(spawnedNPC, true)
    SetBlockingOfNonTemporaryEvents(spawnedNPC, true)
    FreezeEntityPosition(spawnedNPC, true)
    TaskStartScenarioInPlace(spawnedNPC, spawner.scenario, 0, true)
end)

CreateThread(function()
    local spawner = Config.JuiceBarVehicleSpawner
    exports['qb-target']:AddBoxZone("JuiceBarVehicleSpawner", vector3(spawner.coords.x, spawner.coords.y, spawner.coords.z), 1.5, 1.5, {
        name = "JuiceBarVehicleSpawner",
        heading = spawner.coords.w,
        debugPoly = false,
        minZ = spawner.coords.z - 1.0,
        maxZ = spawner.coords.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "juicebar:spawnVehicleMenu",
                icon = spawner.targetIcon,
                label = "Spawn Vehicle",
                job = spawner.requiredJob
            },
            {
                type = "client",
                event = "juicebar:returnVehicle",
                icon = "fas fa-undo",
                label = "Return Vehicle",
                job = spawner.requiredJob,
                canInteract = function()
                    return spawnedVehicle ~= nil
                end
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent('juicebar:spawnVehicleMenu', function()
    local player = QBCore.Functions.GetPlayerData()
    local spawner = Config.JuiceBarVehicleSpawner
    if player.job.name ~= spawner.requiredJob or not player.job.onduty then
        QBCore.Functions.Notify("You must be ON DUTY at the Juice Bar to use this!", "error")
        return
    end
    if spawnedVehicle then
        QBCore.Functions.Notify("You already have a vehicle! Return it first.", "error")
        return
    end
    local vehicleMenu = {
        {
            header = "Juice Bar Vehicles",
            txt = "Select a vehicle to spawn",
            isMenuHeader = true
        }
    }
    for _, vehicle in pairs(spawner.vehicles) do
        vehicleMenu[#vehicleMenu+1] = {
            header = vehicle.label,
            txt = "Spawn a " .. vehicle.label,
            params = {
                event = "juicebar:spawnVehicle",
                args = { model = vehicle.model, color = vehicle.color }
            }
        }
    end
    vehicleMenu[#vehicleMenu+1] = {
        header = "Close Menu",
        txt = "",
        params = { event = "qb-menu:closeMenu" }
    }
    exports['qb-menu']:openMenu(vehicleMenu)
end)

RegisterNetEvent('juicebar:spawnVehicle', function(data)
    local model = data.model
    local color = data.color
    local spawnCoords = Config.JuiceBarVehicleSpawner.spawnLocation
    if not model then return end
    if spawnedVehicle then
        QBCore.Functions.Notify("You already have a vehicle! Return it first.", "error")
        return
    end
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do Wait(10) end
    spawnedVehicle = CreateVehicle(GetHashKey(model), spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, true, false)
    SetVehicleNumberPlateText(spawnedVehicle, "JUICE"..math.random(100,999))
    SetVehicleColours(spawnedVehicle, color[1], color[2])
    SetVehicleModKit(spawnedVehicle, 0)
    SetVehicleLivery(spawnedVehicle, -1)
    SetVehicleDirtLevel(spawnedVehicle, 0.0)
    SetVehicleFuelLevel(spawnedVehicle, 100.0)
    TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(spawnedVehicle))
    QBCore.Functions.Notify("Vehicle spawned: " .. model .. ". You have the keys!", "success")
end)

RegisterNetEvent('juicebar:returnVehicle', function()
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
        QBCore.Functions.Notify("Your vehicle has been returned!", "success")
    else
        QBCore.Functions.Notify("No vehicle to return!", "error")
    end
end)

CreateThread(function()
    local blip = AddBlipForCoord(-1253.37, -750.3, 20.19)
    SetBlipSprite(blip, 93)
    SetBlipColour(blip, 33)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Lemonaid Bar")
    EndTextCommandSetBlipName(blip)
end)

local fruitShopPed = nil

CreateThread(function()
    local c = Config.FruitShop.coords
    RequestModel(GetHashKey(Config.FruitShop.ped))
    while not HasModelLoaded(GetHashKey(Config.FruitShop.ped)) do Wait(10) end
    fruitShopPed = CreatePed(4, GetHashKey(Config.FruitShop.ped), c.x, c.y, c.z - 1.0, c.w, false, true)
    SetEntityInvincible(fruitShopPed, true)
    SetBlockingOfNonTemporaryEvents(fruitShopPed, true)
    FreezeEntityPosition(fruitShopPed, true)
    TaskStartScenarioInPlace(fruitShopPed, Config.FruitShop.scenario, 0, true)
    exports['qb-target']:AddBoxZone("JuiceBarFruitShop", vector3(c.x, c.y, c.z), 1.5, 1.5, {
        name = "JuiceBarFruitShop",
        heading = c.w,
        debugPoly = false,
        minZ = c.z - 1.0,
        maxZ = c.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "juicebar:openFruitShop",
                icon = "fas fa-apple-alt",
                label = "Open Shop",
                job = Config.FruitShop.job,
                canInteract = function()
                    local Player = QBCore.Functions.GetPlayerData()
                    return Player.job and Player.job.name == Config.FruitShop.job and Player.job.onduty
                end
            }
        },
        distance = 2.0
    })
end)

RegisterNetEvent("juicebar:openFruitShop", function()
    QBCore.Functions.TriggerCallback('juicebar:getFruitShopItems', function(items)
        local menu = {
            { header = "Fruit Shop", isMenuHeader = true }
        }
        for _, v in pairs(items) do
            menu[#menu+1] = {
                header = v.name.." ($"..v.price..")",
                txt = "Buy x1 / x5 / x10",
                params = {
                    event = "juicebar:buyFruitAmount",
                    args = { item = v.name, price = v.price }
                }
            }
        end
        menu[#menu+1] = { header = "Close", params = { event = "qb-menu:closeMenu" } }
        exports['qb-menu']:openMenu(menu)
    end)
end)

RegisterNetEvent("juicebar:buyFruitAmount", function(data)
    local item = data.item
    local menu = {
        { header = "Select Quantity", isMenuHeader = true },
        { header = "Buy x1", params = { event = "juicebar:buyFruitFinal", args = { item = item, amount = 1 } } },
        { header = "Buy x5", params = { event = "juicebar:buyFruitFinal", args = { item = item, amount = 5 } } },
        { header = "Buy x10", params = { event = "juicebar:buyFruitFinal", args = { item = item, amount = 10 } } },
        { header = "Back", params = { event = "juicebar:openFruitShop" } }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("juicebar:buyFruitFinal", function(data)
    TriggerServerEvent("juicebar:buyFruitItem", data.item, data.amount)
end)
