local currentProp = nil
local selectedPoints = {}
local currentPointIndex = 0
local satelliteBlips = {}

local function createSatelliteBlip(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Satellite Point")
    EndTextCommandSetBlipName(blip)

    return blip
end

local function removeBlip(blip)
    if DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

local function spawnSatelliteDish(coords)
    local propModel = `prop_elecbox_08`
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(1)
    end

    currentProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, false)
    PlaceObjectOnGroundProperly(currentProp)
    FreezeEntityPosition(currentProp, true)

    satelliteBlips[currentPointIndex] = createSatelliteBlip(coords)

    exports.ox_target:addLocalEntity(currentProp, {
        {
            name = 'startRandomMinigame',
            label = 'Upload Virus',
            icon = 'fas fa-satellite-dish',
            onSelect = function()
                local minigames = {
                    function() return exports['bl_ui']:CircleProgress(1, 50) end,
                    function() return exports['bl_ui']:Progress(1, 50) end,
                    function() return exports['bl_ui']:KeySpam(1, 50) end,
                    function() return exports['bl_ui']:KeyCircle(1, 50, 3) end,
                    function() return exports['bl_ui']:NumberSlide(1, 50, 3) end,
                    function() return exports['bl_ui']:RapidLines(1, 50, 5) end,
                    function() return exports['bl_ui']:CircleShake(1, 50, 3) end
                }
                
                local randomMinigame = minigames[math.random(1, #minigames)]

                local success = randomMinigame()

                if success then
                    print('Minigame success at point ' .. currentPointIndex)

                    DeleteObject(currentProp)
                    currentProp = nil

                    removeBlip(satelliteBlips[currentPointIndex])

                    currentPointIndex = currentPointIndex + 1
                    if currentPointIndex <= #selectedPoints then
                        spawnSatelliteDish(selectedPoints[currentPointIndex])
                    else
                        lib.notify({
                            title = 'Speed Camera Interception Complete',
                            description = 'You have successfully uploaded the virus to all satellite points.',
                            type = 'success',
                            duration = 10000
                        })

                        for _, blip in pairs(satelliteBlips) do
                            removeBlip(blip)
                        end

                        satelliteBlips = {}

                        TriggerEvent('myScript:toggleSpeedCamerasDirect')
                    end
                else
                    print('Minigame failed at point ' .. currentPointIndex)
                end
            end,
        }
    })
end

RegisterNetEvent('myScript:startSpeedCameraInterception', function()
    local satellitePoints = {
        vector3(213.05, -998.62, 28.29),
        vector3(-144.89, -419.76, 33.39),
        vector3(-803.76, -96.02, 36.59),
        vector3(-1087.07, -1325.5, 4.23),
        vector3(731.56, 146.07, 79.75),
        vector3(297.39, -355.49, 44.15),
        vector3(-22.57, 45.98, 71.24),
        vector3(-1443.39, -782.83, 22.47),
        vector3(-968.66, -177.75, 36.8),
        vector3(-911.98, -100.89, 37.23),
        vector3(-1008.41, 303.83, 67.07),
        vector3(-468.56, -722.48, 31.73),
        vector3(13.7, -790.34, 30.77),
        vector3(109.42, -820.83, 30.31)
    }

    local numPoints = math.random(3, 6)
    selectedPoints = {}

    while #selectedPoints < numPoints do
        local randomIndex = math.random(1, #satellitePoints)
        local point = satellitePoints[randomIndex]

        local alreadySelected = false
        for _, selectedPoint in ipairs(selectedPoints) do
            if selectedPoint == point then
                alreadySelected = true
                break
            end
        end

        if not alreadySelected then
            table.insert(selectedPoints, point)
        end
    end

    lib.notify({
        title = 'Speed Camera Interception',
        description = 'You need to upload a virus to ' .. numPoints .. ' satellite points. Good luck!',
        type = 'inform',
        duration = 10000
    })

    currentPointIndex = 1
    spawnSatelliteDish(selectedPoints[currentPointIndex])
end)


local pedModel = `csb_talcc`
local pedCoords = vector4(196.95, -1493.81, 28.14, 131.36)

RequestModel(pedModel)
while not HasModelLoaded(pedModel) do
    Wait(1)
end

local undergroundTechPed = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)

TaskSetBlockingOfNonTemporaryEvents(undergroundTechPed, true)
SetEntityInvincible(undergroundTechPed, true)
FreezeEntityPosition(undergroundTechPed, true)

exports.ox_target:addLocalEntity(undergroundTechPed, {
    {
        name = 'startSpeedCameraInterception',
        label = 'Start Speed Camera Interception',
        icon = 'fas fa-camera',
        onSelect = function()
            TriggerEvent('myScript:startSpeedCameraInterception')
        end,
    }
})

exports.ox_target:addLocalEntity(undergroundTechPed, {
    {
        name = 'undergroundTechAssociate',
        label = 'Underground Tech Associate',
        icon = 'fas fa-user',
        onSelect = function()
            lib.registerContext({
                id = 'underground_tech_menu',
                title = 'Underground Tech Organization',
                options = {
                    {
                        title = 'OK',
                        description = 'We are an underground tech organization fighting against tyrannical governments and their unconstitutional laws.',
                        event = 'myScript:confirmTechMessage',
                        arrow = true
                    }
                }
            })

            lib.showContext('underground_tech_menu')
        end,
    }
})

RegisterNetEvent('myScript:confirmTechMessage', function()
    lib.notify({
        title = 'Underground Tech',
        description = 'When you start this job for us just know we are not going to bail you out. If anyone asks us, we do not know you and never met you.',
        type = 'inform',
        duration = 10000
    })

    Wait(11000) 

    lib.notify({
        title = 'Underground Tech',
        description = 'OK, now that we got things straight, you are going to have to upload a virus to some government satellite points. Let\'s get started.',
        type = 'inform',
        duration = 10000
    })

    Wait(11000)

    lib.notify({
        title = 'Underground Tech',
        description = 'Click Start Speed Camera Interception to get started.',
        type = 'inform',
        duration = 10000
    })
end)
