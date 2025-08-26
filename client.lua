ESX = exports['es_extended']:getSharedObject()


local bikeModels = { "bmx", "cruiser", "scorcher", "fixter", "tribike", "tribike2", "tribike3" }
local hasBike = false

local function pickupBike(bikeEntity)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle and vehicle ~= 0 then return end

    local fingerBone = GetPedBoneIndex(ped, 58867)
    AttachEntityToEntity(bikeEntity, ped, fingerBone, 0.0, 0.24, 0.10, 340.0, 330.0, 330.0, true, true, false, true, 1, true)
    SetEntityCollision(bikeEntity, false, true)

    lib.showTextUI('[BACKSPACE] - Pustit Kolo')

    local animDict = "anim@heists@box_carry@"
    hasBike = true
    lib.requestAnimDict(animDict)
    TaskPlayAnim(ped, animDict, "idle", 2.0, 2.0, -1, 51, 0, false, false, false)

    CreateThread(function()
        while hasBike do
            if not IsEntityPlayingAnim(ped, animDict, "idle", 3) then
                lib.requestAnimDict(animDict)
                TaskPlayAnim(ped, animDict, "idle", 2.0, 2.0, -1, 51, 0, false, false, false)
            end

            if IsControlJustPressed(0, 194) then -- X key
                DetachEntity(bikeEntity, nil, nil)
                SetVehicleOnGroundProperly(bikeEntity)
                ClearPedTasksImmediately(ped)
                SetEntityCollision(bikeEntity, true, true)
                hasBike = false
                lib.hideTextUI() -- odstranění TextUI
                RemoveAnimDict(animDict)
            end
            Wait(5)
        end
    end)
end


exports.ox_target:addModel(bikeModels, {
    {
        icon = "fa-solid fa-bicycle",
        label = "Zvednout kolo",
        canInteract = function(entity, distance, coords, name, bone)
            return distance < 1.3 and not hasBike
        end,
        onSelect = function(data)
            pickupBike(data.entity)
        end
    }
})

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    hasBike = false
end)
