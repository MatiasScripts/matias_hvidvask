-- server.lua
local ox_inventory = exports.ox_inventory
local cfg = Config

RegisterNetEvent('moneywash:tryWash', function(amount)
    local src = source

    local blackMoneyCount = ox_inventory:GetItemCount(src, cfg.BlackMoneyItem)

    if blackMoneyCount < amount then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Hvidvask',
            description = 'Du har ikke nok sorte penge.',
            type = 'error'
        })
        return
    end

    local removed = ox_inventory:RemoveItem(src, cfg.BlackMoneyItem, amount)
    if not removed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Hvidvask',
            description = 'Fejl ved fjernelse af sorte penge.',
            type = 'error'
        })
        return
    end

    local cleanMoney = math.floor(amount * cfg.WashPercentage)

    local added = ox_inventory:AddItem(src, cfg.CashItem, cleanMoney)
    if not added then
        ox_inventory:AddItem(src, cfg.BlackMoneyItem, amount)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Hvidvask',
            description = 'Kunne ikke give kontanter, sorte penge returneret.',
            type = 'error'
        })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Hvidvask',
        description = ('Du har hvidvasket %d sorte penge til %d kontanter.'):format(amount, cleanMoney),
        type = 'success'
    })
end)
