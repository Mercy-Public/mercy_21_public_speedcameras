QBCore = exports['qb-core']:GetCoreObject()

local PlayerData = {}
local monitoringSpeed = false
local hasBeenCaught = false

local speedCoeff = 3.6
local speedUnit = " KPH"

if Config.MPH then
    speedCoeff = 2.236936
    speedUnit = " MPH"
end

local function nonbilling()
end

local function createDefaultBlips()
    if not Config.useBlips then return end
    for camera_speed, camera_data in pairs(Config.Cameras) do
        local camera_title = "Speed Camera [" .. tostring(camera_speed) .. speedUnit .. "]"
        for _, camera_location in pairs(camera_data.locations) do
            local blip = AddBlipForCoord(camera_location.x, camera_location.y, camera_location.z)
            SetBlipSprite(blip, camera_data.blipSprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, camera_data.blipSize)
            SetBlipColour(blip, camera_data.blipColour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(camera_title)
            EndTextCommandSetBlipName(blip)
        end
    end
end

local blips = {}  
local function turnBlipsGreen()
    if not Config.useBlips then return end
    CreateThread(function()
        for camera_speed, camera_data in pairs(Config.Cameras) do
            local camera_title = "Currently Intercepting file uploads"
            for _, camera_location in pairs(camera_data.locations) do
                local blip = AddBlipForCoord(camera_location.x, camera_location.y, camera_location.z)
                SetBlipSprite(blip, camera_data.blipSprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, camera_data.blipSize)
                SetBlipColour(blip, 2) 
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(camera_title)
                EndTextCommandSetBlipName(blip)

                table.insert(blips, blip)

                Wait(200)
            end
        end

        Wait(500) 
        for _, blip in pairs(blips) do
            SetBlipColour(blip, 1)  
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Interception Complete")
            EndTextCommandSetBlipName(blip)
            Wait(200) 
        end

        QBCore.Functions.Notify("Interception Complete", "success")

        Wait(500)  
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
            Wait(200) 
        end

        blips = {}
    end)
end





---@return boolean
local function isJobExempt()
    local playerJob = PlayerData.job
    if not playerJob then return false end
    for _, job in pairs(Config.ignoredJobs) do
        if playerJob.name == job and playerJob.onduty then return true end
    end
    return false
end

---@param camera_data table
---@param maxSpeed number
---@param units string
local function billPlayer(camera_data, maxSpeed, units)
    local msg = Lang:t('info.mail_msg', {
        fineAmount = tostring(camera_data.fineAmount),
        maxSpeed = tostring(maxSpeed),
        speedUnit = units
    })

    if Config.showNotification then
        QBCore.Functions.Notify(msg, "error")
    end

    if Config.sendEmail then
        TriggerServerEvent('qb-phone:server:sendNewMail', {
        sender = Lang:t('info.mail_sender'),
        subject = Lang:t('info.mail_subject'),
        message = msg,
        button = {}
        })
    end
    TriggerServerEvent('qb-speedcameras:server:PayBill', camera_data.fineAmount)
end

---@param playerCar number
---@param camera_data table
---@param maxSpeed number
local function handleBilling(playerCar, camera_data, maxSpeed)
    if not Config.useBilling then nonbilling() return end
    if not Config.OnlyBillIfOwned then billPlayer(camera_data, maxSpeed, speedUnit) return end

    local plate = QBCore.Functions.GetPlate(playerCar)
    QBCore.Functions.TriggerCallback("qb-speedcameras:server:checkOwnership", function(result)
        if result then
            billPlayer(camera_data, maxSpeed, speedUnit)
        end
    end, plate)

end

local function policeAlert(vehSpeed, maxSpeed, playerCar)
    if not Config.alertPolice and vehSpeed > Config.alertSpeed then return end

    local message = Lang:t('alert.caught_speeding', {
        vehicle_plate = GetVehicleNumberPlateText(playerCar),
        veh_speed = tostring(math.ceil(vehSpeed)),
        max_speed = tostring(maxSpeed),
        speedUnit = speedUnit
    })

    TriggerServerEvent("police:server:policeAlert", message)
end

local function cameraFlash()
    if Config.useFlashingScreen then
        TriggerServerEvent('qb-speedcameras:server:openGUI')

        if Config.useCameraSound then
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "speedcamera", 0.5)
        end

        Wait(200)
        TriggerServerEvent('qb-speedcameras:server:closeGUI')
    end
end

local function monitorSpeed()
    if not Config.enableSpeedCameras then return end
    CreateThread(function()
        monitoringSpeed = true
        local sleep
        if isJobExempt() then return end
        while monitoringSpeed do
            sleep = 1000
            local playerPed = PlayerPedId()
            local playerCar = GetVehiclePedIsIn(playerPed, false)

            if not IsPedInAnyVehicle(playerPed, false) then return end
            if GetPedInVehicleSeat(playerCar, -1) ~= playerPed then sleep = 5000 goto continue end

            for maxSpeed, camera_data in pairs(Config.Cameras) do
                for _, camera_location in pairs(camera_data.locations) do
                    local plyCoords = GetEntityCoords(playerPed, false)
                    local dist = #(plyCoords - camera_location)
                    local vehSpeed = GetEntitySpeed(playerPed) * speedCoeff

                    if dist > 100.0 then goto next end
                    if vehSpeed < maxSpeed then goto continue end
                    if hasBeenCaught then goto continue end
                    sleep = 100

                    policeAlert(vehSpeed, maxSpeed, playerCar)

                    cameraFlash()

                    handleBilling(playerCar, camera_data, maxSpeed)

                    hasBeenCaught = true
                    Wait(5000)
                    TriggerEvent("qb-speedcameras:client:caught", playerCar, camera_location)
                    TriggerServerEvent("qb-speedcameras:server:caught", NetworkGetNetworkIdFromEntity(playerCar), camera_location)

                    ::next::
                end
                hasBeenCaught = false
            end
            ::continue::
            Wait(sleep)
        end
    end)
end


RegisterNetEvent('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerData = QBCore.Functions.GetPlayerData()
        createDefaultBlips()  -- Create default speed camera blips
        
        if Config.enableSpeedCameras then
            monitorSpeed()
        end
    end
end)

RegisterNetEvent('myScript:toggleSpeedCamerasDirect', function()
    Config.enableSpeedCameras = not Config.enableSpeedCameras
    local status = Config.enableSpeedCameras and "enabled" or "disabled"
    
    QBCore.Functions.Notify("Speed cameras are now " .. status, "success")

    if Config.enableSpeedCameras then
        createDefaultBlips()
        monitorSpeed()
    else
        turnBlipsGreen()
        monitoringSpeed = false
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    createDefaultBlips()

    if Config.enableSpeedCameras then
        monitorSpeed()
    end
end)


RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    if isJobExempt() then
        monitoringSpeed = false
    else
        monitorSpeed()
    end
end)

RegisterNetEvent('qb-speedcameras:client:openGUI', function()
    SetNuiFocus(false,false)
    SendNUIMessage({type = 'openSpeedcamera'})
end)

RegisterNetEvent('qb-speedcameras:client:closeGUI', function()
    SendNUIMessage({type = 'closeSpeedcamera'})
end)

RegisterNetEvent("QBCore:Client:EnteredVehicle", function()
    monitorSpeed()
end)

RegisterNetEvent("QBCore:Client:LeftVehicle", function()
    monitoringSpeed = false
end)
