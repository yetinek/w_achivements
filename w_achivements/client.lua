local ConfigLoaded = false
-- local CanClaim = true
local PlayerAchivements = {}
local isDead = 0

RegisterCommand("osiagniecia", function ()
    if not ConfigLoaded then
        SendNUIMessage({
            action = 'LoadConfig',
            config = Config.Achivements
        })
        ConfigLoaded = true
    end
    ESX.TriggerServerCallback('w_achivements:GetAchivements', function(CallbackData) 
        PlayerAchivements = CallbackData
        SendNUIMessage({
            action = 'Open',
            playerAchivments = CallbackData
        })
        SetNuiFocus(true, true)
    end)
end)

exports('OpenAchivements', function()
    if not ConfigLoaded then
        SendNUIMessage({
            action = 'LoadConfig',
            config = Config.Achivements
        })
        ConfigLoaded = true
    end
    ESX.TriggerServerCallback('w_achivements:GetAchivements', function(CallbackData) 
        PlayerAchivements = CallbackData
        SendNUIMessage({
            action = 'Open',
            playerAchivments = CallbackData
        })
        SetNuiFocus(true, true)
    end)
end)

RegisterNUICallback('Close', function()
    SetNuiFocus(false, false)
end)


RegisterNetEvent('w_achivements:UnlockAchivement', function(AchivementID)
    if not ConfigLoaded then
        SendNUIMessage({
            action = 'LoadConfig',
            config = Config.Achivements
        })
        ConfigLoaded = true
    end
    SendNUIMessage({
        action = 'achivmentUnlocked',
        id = AchivementID
    })
end)

RegisterNUICallback('ClaimReward', function(data)
    TriggerServerEvent('w_achivements:ClaimReward', data.AchivementID)
end)

exports('CheckIsUnlocked', function(source, AchivementID)
    for k, v in pairs(PlayerAchivements) do
        if v.id == AchivementID then
            return v.dateUnlocked ~= 'N/A'
        end
    end
    return false
end)

AddEventHandler("playerSpawned", function()

end)

AddEventHandler("playerSpawned", function(data)
    isDead = 0
    Wait(400)
    SendNUIMessage({
        action = 'updatePosition',
        death = isDead
    })
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = 1

    local weapon =  data.deathCause
    local sourceofdeath = GetPedSourceOfDeath(ESX.PlayerData.ped)
    local damagedbycar = (weapon == 0 and sourceofdeath == 0 and HasEntityBeenDamagedByWeapon(ESX.PlayerData.ped, `WEAPON_RUN_OVER_BY_CAR`, 0))

    if weapon == `WEAPON_UNARMED` or ((weapon == `WEAPON_RUN_OVER_BY_CAR` or damagedbycar) and sourceofdeath ~= playerPed) or weapon == `WEAPON_NIGHTSTICK` then
        --obezwladiony
    else
        SendNUIMessage({
            action = 'updatePosition',
            death = isDead
        })
    end
end)

AddEventHandler('esx:enteredVehicle', function(vehicle, plate, seat, displayName, netId)
    SendNUIMessage({
        action = 'updatePosition',
        death = isDead,
        vehicle = 1
    })
end)

AddEventHandler('esx:exitedVehicle', function(vehicle, plate, seat, displayName, netId)
    SendNUIMessage({
        action = 'updatePosition',
        death = isDead,
        vehicle = 0
    })
end)