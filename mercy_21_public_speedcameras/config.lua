Config = {}

Config.MPH = true                 
Config.useFlashingScreen = true   
Config.useCameraSound = true      
Config.useBlips = true            
Config.alertPolice = true         
Config.alertSpeed = 130           
Config.useBilling = true          
Config.OnlyBillIfOwned = true    
Config.showNotification = false  
Config.sendEmail = true           
Config.enableSpeedCameras = true  

Config.ignoredJobs = {
    'police',
    'ambulance'
}

Config.Cameras = {
    [60] = {
        fineAmount = 75,
        blipColour = 0,
        blipSprite = 163,
        blipSize = 0.5,
        locations = {
            vector3(-13.63, -966.63, 29.08),
            vector3(109.86, -508.32, 42.48),
            vector3(591.64, -839.56, 40.55),
            vector3(-124.15, -1351.35, 29.94),
            vector3(499.68, 103.61, 95.49),
            vector3(-212.8, 272.77, 91.19),
            vector3(-866.28, 237.44, 72.94),
            vector3(-1425.26, -56.55, 52.52),
            vector3(-1306.31, -74.7, 46.92),
            vector3(-300.64, -412.7, 29.37),
            vector3(-1556.37, -204.65, 54.89),
            vector3(-1382.79, -417.2, 35.7),
            vector3(-1134.86, -721.91, 19.92),
            vector3(-828.69, -1033.39, 12.47)
        }
    }
}