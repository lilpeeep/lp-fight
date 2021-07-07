ESX = nil
local bahisMiktar = 0
local dovusDurum = DURUM_ILK
local DURUM_ILK = 0
local DURUM_KATILDI = 1
local DURUM_BASLADI = 2
local maviKatildi = false
local kirmiziKatildi = false
local oyuncular = 0
local geriSayimGoster = false
local katilimcilar = false
local rakip = nil
local Eldiven = {}
local kazananiGoster = false
local kazanan = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(
            'esx:getSharedObject',
            function(obj)
                ESX = obj
            end
        )
        Citizen.Wait(0)
    end
    CreateBlip(Config.BLIP.coords, Config.BLIP.text, Config.BLIP.sprite, Config.BLIP.color, Config.BLIP.scale)
    RunThread()
end)

RegisterNetEvent('lp_streetfight:oyuncuKatildi')
AddEventHandler('lp_streetfight:oyuncuKatildi', function(birim, id)

        if birim == 1 then
            maviKatildi = true
        else
            kirmiziKatildi = true
        end

        if id == GetPlayerServerId(PlayerId()) then
            katilimcilar = true
            koyEldiven()
        end
        oyuncular = oyuncular + 1
        dovusDurum = DURUM_KATILDI

end)

RegisterNetEvent('lp_streetfight:dovusBasla')
AddEventHandler('lp_streetfight:dovusBasla', function(dovusData)

    for index,value in ipairs(dovusData) do
        if(value.id ~= GetPlayerServerId(PlayerId())) then
            rakip = value.id      
        elseif value.id == GetPlayerServerId(PlayerId()) then
            katilimcilar = true
        end
    end

    dovusDurum = DURUM_BASLADI
    geriSayimGoster = true
    countdown()

end)

RegisterNetEvent('lp_streetfight:dovuscuAyrildi')
AddEventHandler('lp_streetfight:dovuscuAyrildi', function(id)

    if id == GetPlayerServerId(PlayerId()) then
        ESX.ShowNotification('Ringden ayrıldığın için dövüşten muaf edildin.')
        SetPedMaxHealth(PlayerPedId(), 200)
        SetEntityHealth(PlayerPedId(), 200)
        kaldirEldiven()
    elseif katilimcilar == true then
        TriggerServerEvent('lp_streetfight:ode', bahisMiktar)
        ESX.ShowNotification('Sen kazandın ~r~' .. (bahisMiktar * 2) .. '$')
        SetPedMaxHealth(PlayerPedId(), 200)
        SetEntityHealth(PlayerPedId(), 200)
        kaldirEldiven()
    end
    reset()

end)

RegisterNetEvent('lp_streetfight:dovusBitti')
AddEventHandler('lp_streetfight:dovusBitti', function(kaybeden)

    if katilimcilar == true then
        if(kaybeden ~= GetPlayerServerId(PlayerId()) and kaybeden ~= -2) then
            TriggerServerEvent('lp_streetfight:ode', bahisMiktar)
            ESX.ShowNotification('Sen kazandın ~r~' .. (bahisMiktar * 2) .. '$')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
    
            TriggerServerEvent('lp_streetfight:kazananiGoster', GetPlayerServerId(PlayerId()))
        end
    
        if(kaybeden == GetPlayerServerId(PlayerId()) and kaybeden ~= -2) then
            ESX.ShowNotification('Dövüşü kaybettin ~r~-' .. bahisMiktar .. '$')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
        end
    
        if kaybeden == -2 then
            ESX.ShowNotification('Zaman dolduğu için dövüş sonlandırıldı.')
            SetPedMaxHealth(PlayerPedId(), 200)
            SetEntityHealth(PlayerPedId(), 200)
        end

        kaldirEldiven()
    end
    
    reset()

end)

RegisterNetEvent('lp_streetfight:gercekBahisArttir')
AddEventHandler('lp_streetfight:gercekBahisArttir', function()
    bahisMiktar = bahisMiktar * 2
    if bahisMiktar == 0 then
        bahisMiktar = 2000
    elseif bahisMiktar > 100000 then
        bahisMiktar = 0
    end
end)

RegisterNetEvent('lp_streetfight:kazananDgoster')
AddEventHandler('lp_streetfight:kazananDgoster', function(id)
    kazananiGoster = true
    kazanan = id
    Citizen.Wait(5000)
    kazananiGoster = false
    kazanan = nil
end)

local gercekSayi = 0
function countdown()
    for i = 5, 0, -1 do
        gercekSayi = i
        Citizen.Wait(1000)
    end
    geriSayimGoster = false
    gercekSayi = 0

    if katilimcilar == true then
        SetPedMaxHealth(PlayerPedId(), 500)
        SetEntityHealth(PlayerPedId(), 500)
    end
end

function koyEldiven()
    local ped = GetPlayerPed(-1)
    local hash = GetHashKey('prop_boxing_glove_01')
    while not HasModelLoaded(hash) do RequestModel(hash); Citizen.Wait(0); end
    local pos = GetEntityCoords(ped)
    local gloveA = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    local gloveB = CreateObject(hash, pos.x,pos.y,pos.z + 0.50, true,false,false)
    table.insert(Eldiven,gloveA)
    table.insert(Eldiven,gloveB)
    SetModelAsNoLongerNeeded(hash)
    FreezeEntityPosition(gloveA,false)
    SetEntityCollision(gloveA,false,true)
    ActivatePhysics(gloveA)
    FreezeEntityPosition(gloveB,false)
    SetEntityCollision(gloveB,false,true)
    ActivatePhysics(gloveB)
    if not ped then ped = GetPlayerPed(-1); end -- gloveA = L, gloveB = R
    AttachEntityToEntity(gloveA, ped, GetPedBoneIndex(ped, 0xEE4F), 0.05, 0.00,  0.04,     00.0, 90.0, -90.0, true, true, false, true, 1, true) -- object is attached to right hand 
    AttachEntityToEntity(gloveB, ped, GetPedBoneIndex(ped, 0xAB22), 0.05, 0.00, -0.04,     00.0, 90.0,  90.0, true, true, false, true, 1, true) -- object is attached to right hand 
end

function kaldirEldiven()
    for k,v in pairs(Eldiven) do DeleteObject(v); end
end

function spawnMarker(coords)
    local centerRing = GetDistanceBetweenCoords(coords, vector3(-517.61,-1712.04,20.46), true)
    if centerRing < Config.UZAKLIK and dovusDurum ~= DURUM_BASLADI then
        
        DrawMarker(1, Config.BAHISALAN.x, Config.BAHISALAN.y, Config.BAHISALAN.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 204,204, 0, 100, false, true, 2, false, false, false, false)
        DrawText3D(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z +1.5, 'Oyuncular: ~r~' .. oyuncular .. '/2 \n ~w~Bahis: ~r~'.. bahisMiktar ..'$ ', 0.8)

        local maviAlan = GetDistanceBetweenCoords(coords, vector3(Config.MAVIALAN.x, Config.MAVIALAN.y, Config.MAVIALAN.z), true)
        local kirmiziAlan = GetDistanceBetweenCoords(coords, vector3(Config.KIRMIZIALAN.x, Config.KIRMIZIALAN.y, Config.KIRMIZIALAN.z), true)
        local bahisAlan = GetDistanceBetweenCoords(coords, vector3(Config.BAHISALAN.x, Config.BAHISALAN.y, Config.BAHISALAN.z), true)

        if maviKatildi == false then
            DrawText3D(Config.MAVIALAN.x, Config.MAVIALAN.y, Config.MAVIALAN.z +1.5, 'Dövüşe Katıl [~b~E~w~]', 0.4)
            if maviAlan < Config.UZAKLIK_ETKILESIM then
                ESX.ShowHelpNotification("Mavi tarafa katılmak için ~INPUT_CONTEXT~ bas.")
                if IsControlJustReleased(0, Config.E_ANAHTAR) and katilimcilar == false then
                    TriggerServerEvent('lp_streetfight:katil', bahisMiktar, 0 )
                end
            end
        end

        if kirmiziKatildi == false then
            DrawText3D(Config.KIRMIZIALAN.x, Config.KIRMIZIALAN.y, Config.KIRMIZIALAN.z +1.5, 'Dövüşe Katıl [~r~E~w~]', 0.4)
            if kirmiziAlan < Config.UZAKLIK_ETKILESIM then
                ESX.ShowHelpNotification("Kırmızı tarafa katılmak için ~INPUT_CONTEXT~ bas.")
                if IsControlJustReleased(0, Config.E_ANAHTAR) and katilimcilar == false then
                    TriggerServerEvent('lp_streetfight:katil', bahisMiktar, 1)
                end
            end
        end

        if bahisAlan < Config.UZAKLIK_ETKILESIM and dovusDurum ~= DURUM_KATILDI and dovusDurum ~= DURUM_BASLADI then
            ESX.ShowHelpNotification("Bahsi değiştirmek için ~INPUT_CONTEXT~ bas.")
            if IsControlJustReleased(0, Config.E_ANAHTAR) then
                TriggerServerEvent('lp_streetfight:bahisYukselt', bahisMiktar)
            end
        end

    end
end

function get3DDistance(x1, y1, z1, x2, y2, z2)
    local a = (x1 - x2) * (x1 - x2)
    local b = (y1 - y2) * (y1 - y2)
    local c = (z1 - z2) * (z1 - z2)
    return math.sqrt(a + b + c)
end

function DrawText3D(x, y, z, text, scale)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextColour(255, 255, 255, 215)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function CreateBlip(coords, text, sprite, color, scale)
	local blip = AddBlipForCoord(coords.x, coords.y)
	SetBlipSprite(blip, sprite)
	SetBlipScale(blip, scale)
	SetBlipColour(blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandSetBlipName(blip)
end

function reset() 
    kirmiziKatildi = false
    maviKatildi = false
    katilimcilar = false
    oyuncular = 0
    dovusDurum = DURUM_ILK
end

function RunThread()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local coords = GetEntityCoords(PlayerPedId())
            spawnMarker(coords)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        if dovusDurum == DURUM_BASLADI and katilimcilar == false and GetEntityCoords(PlayerPedId()) ~= rakip then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z,coords.x,coords.y,coords.z) < Config.TP_UZAKLIK then
                ESX.ShowNotification('Ringden uzak dur!')
                for height = 1, 1000 do
                    SetPedCoordsKeepVehicle(GetPlayerPed(-1), -521.58, -1723.58, 19.16)
                    local bulunanYer, zPos = GetGroundZFor_3dCoord(-521.58, -1723.58, 19.16)
                    if bulunanYer then
                        SetPedCoordsKeepVehicle(GetPlayerPed(id), -521.58, -1723.58, 19.16)
                        break
                    end
                    Citizen.Wait(5)
                end
            end
        end
        Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if geriSayimGoster == true then
            DrawText3D(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z + 1.5, 'Kavganın başlamasına: ' .. gercekSayi, 2.0)
        elseif geriSayimGoster == false and dovusDurum == DURUM_BASLADI then
            if GetEntityHealth(PlayerPedId()) < 150 then
                TriggerServerEvent('lp_streetfight:dovusBitis', GetPlayerServerId(PlayerId()))
                dovusDurum = DURUM_ILK
            end
        end
       
        if katilimcilar == true then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z,coords.x,coords.y,coords.z) > Config.DOVUS_AYRIL_UZAKLIK then
                TriggerServerEvent('lp_streetfight:dovustenAyril', GetPlayerServerId(PlayerId()))
            end
        end

        if kazananiGoster == true and kazanan ~= nil then
            local coords = GetEntityCoords(GetPlayerPed(-1))
            if get3DDistance(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z,coords.x,coords.y,coords.z) < 15 then
                DrawText3D(Config.MERKEZ.x, Config.MERKEZ.y, Config.MERKEZ.z + 2.5, '~r~ID: ' .. kazanan .. ' kazandı!', 2.0)
            end
        end
    end
end)