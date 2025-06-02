local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-juicebar:server:openStash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        exports['qb-inventory']:OpenInventory(src, Config.Stash.stashName, {
            maxweight = Config.Stash.maxWeight,
            slots = Config.Stash.slots
        })
    end
end)

RegisterNetEvent('juicebar:clockInOut', function(dutyStatus)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'juicebar' then
        TriggerClientEvent('QBCore:Notify', src, "You are not employed at the Juice Bar!", "error")
        return
    end
    Player.Functions.SetJobDuty(dutyStatus)
    local message = dutyStatus and "You started your shift!" or "You ended your shift!"
    TriggerClientEvent('QBCore:Notify', src, message, "success")
end)

QBCore.Functions.CreateCallback('juicebar:hasIngredient', function(source, cb, requiredItem)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    local item = Player.Functions.GetItemByName(requiredItem)
    local amount = (item and item.amount) or 0
    cb(amount > 0)
end)

RegisterNetEvent('juicebar:cutFruit', function(fruit, sliceItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local fruitItem = Player.Functions.GetItemByName(fruit)
    if not fruitItem or fruitItem.amount < 1 then
        TriggerClientEvent('QBCore:Notify', src, "You don't have any " .. fruit .. " to cut!", "error")
        return
    end
    Player.Functions.RemoveItem(fruit, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[fruit], "remove")
    Player.Functions.AddItem(sliceItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[sliceItem], "add")
    TriggerClientEvent('QBCore:Notify', src, "You cut the " .. fruit .. " into slices!", "success")
end)

RegisterNetEvent('juicebar:makeJuice', function(juiceType, requiredItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local item = Player.Functions.GetItemByName(requiredItem)
    if not item or item.amount < 1 then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough " .. requiredItem .. "!", "error")
        return
    end
    Player.Functions.RemoveItem(requiredItem, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[requiredItem], "remove")
    Player.Functions.AddItem(juiceType, 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[juiceType], "add")
    TriggerClientEvent('QBCore:Notify', src, "You made a " .. juiceType .. "!", "success")
end)

QBCore.Functions.CreateCallback('juicebar:getFruitShopItems', function(source, cb)
    cb(Config.FruitShop.products)
end)

RegisterNetEvent('juicebar:buyFruitItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shopProducts = Config.FruitShop.products
    local price = 0
    for _, prod in ipairs(shopProducts) do
        if prod.name == item then
            price = prod.price * amount
        end
    end
    if price == 0 then
        TriggerClientEvent('QBCore:Notify', src, "Item not found", "error")
        return
    end
    if Player.Functions.RemoveMoney('cash', price) then
        Player.Functions.AddItem(item, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
        TriggerClientEvent('QBCore:Notify', src, "You bought "..amount.." "..item.."(s)!", "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough money!", "error")
    end
end)
