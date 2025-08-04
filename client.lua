-- client.lua
local ox_target = exports.ox_target

local cfg = Config

local npc

CreateThread(function()
    RequestModel(cfg.NPCModel)
    while not HasModelLoaded(cfg.NPCModel) do Wait(100) end

    npc = CreatePed(4, cfg.NPCModel, cfg.NPCCoords.x, cfg.NPCCoords.y, cfg.NPCCoords.z - 1.0, cfg.NPCCoords.w, false, true)

    SetEntityInvincible(npc, true)
    SetEntityHeading(npc, cfg.NPCCoords.w)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_GUARD_STAND", 0, true)

    ox_target:addLocalEntity(npc, {
        {
            label = 'Hvidvask',
            icon = 'fa-solid fa-suitcase',
            event = 'npc:interaction',
            distance = cfg.TargetDistance
        }
    })
end)

RegisterNetEvent('npc:interaction', function()
    local input = lib.inputDialog('Hvidvask penge', {
        {
            type = 'number',
            label = 'Hvor mange sorte penge vil du vaske?',
            placeholder = 'Indtast antal',
            icon = 'dollar-sign',
            required = true,
            min = 1,
        }
    })

    if not input then
        lib.notify({title = 'Hvidvask', description = 'Du annullerede.', type = 'error'})
        return
    end

    local amount = tonumber(input[1])
    if not amount or amount <= 0 then
        lib.notify({title = 'Hvidvask', description = 'Ugyldigt beløb.', type = 'error'})
        return
    end

    -- Tjek om spilleren har nok sorte penge før progressbaren
    local blackMoneyCount = exports.ox_inventory:GetItemCount(cfg.BlackMoneyItem)
    if blackMoneyCount < amount then
        lib.notify({title = 'Hvidvask', description = 'Du har ikke nok sorte penge.', type = 'error'})
        return
    end

    local success = lib.progressBar({
        duration = cfg.ProgressDuration,
        label = cfg.ProgressLabel,
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
    })

    if not success then
        lib.notify({title = 'Hvidvask', description = 'Du annullerede handlingen.', type = 'error'})
        return
    end

    TriggerServerEvent('moneywash:tryWash', amount)
end)