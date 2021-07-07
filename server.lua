ESX = nil

local maviDovuscuHazir = false
local kirmiziDovuscuHazir = false
local dovus = {}

TriggerEvent('esx:getSharedObject',
    function(obj)
        ESX = obj
    end
)

RegisterServerEvent('lp_streetfight:katil')
AddEventHandler('lp_streetfight:katil', function(bahisMiktar, birim)

        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)

		if birim == 0 then
			maviDovuscuHazir = true
		else
			kirmiziDovuscuHazir = true
		end

        local dovuscu = {
            id = source,
            amount = bahisMiktar
        }
        table.insert(dovus, dovuscu)

        lpdenge = xPlayer.getAccount('money').money
        if (lpdenge > bahisMiktar) or bahisMiktar == 0 then
            xPlayer.removeAccountMoney('money', bahisMiktar)
            TriggerClientEvent('esx:showNotification', source, 'Başarıyla katıldınız.')

            if birim == 0 then
                TriggerClientEvent('lp_streetfight:oyuncuKatildi', -1, 1, source)
            else
                TriggerClientEvent('lp_streetfight:oyuncuKatildi', -1, 2, source)
            end

            if kirmiziDovuscuHazir and maviDovuscuHazir then 
                TriggerClientEvent('lp_streetfight:dovusBasla', -1, dovus)
            end

        else
            TriggerClientEvent('esx:showNotification', source, 'Yeterli paranız yok!')
        end
end)

local sayi = 240
local gercekSayi = 0
function countdown(kopyaDovus)
    for i = sayi, 0, -1 do
        gercekSayi = i
        Citizen.Wait(1000)
    end

    if kopyaDovus == dovus then
        TriggerClientEvent('lp_streetfight:dovusBitti', -1, -2)
        dovus = {}
        maviDovuscuHazir = false
        kirmiziDovuscuHazir = false
    end
end

RegisterServerEvent('lp_streetfight:dovusBitis')
AddEventHandler('lp_streetfight:dovusBitis', function(kaybeden)
       TriggerClientEvent('lp_streetfight:dovusBitti', -1, kaybeden)
       dovus = {}
       maviDovuscuHazir = false
       kirmiziDovuscuHazir = false
end)

RegisterServerEvent('lp_streetfight:dovustenAyril')
AddEventHandler('lp_streetfight:dovustenAyril', function(id)
       if maviDovuscuHazir or kirmiziDovuscuHazir then
            maviDovuscuHazir = false
            kirmiziDovuscuHazir = false
            dovus = {}
            TriggerClientEvent('lp_streetfight:dovuscuAyrildi', -1, id)
       end
end)

RegisterServerEvent('lp_streetfight:ode')
AddEventHandler('lp_streetfight:ode', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.addAccountMoney('money', amount * 2)
end)

RegisterServerEvent('lp_streetfight:bahisYukselt')
AddEventHandler('lp_streetfight:bahisYukselt', function(kaybeden)
       TriggerClientEvent('lp_streetfight:gercekBahisArttir', -1)
end)

RegisterServerEvent('lp_streetfight:kazananiGoster')
AddEventHandler('lp_streetfight:kazananiGoster', function(id)
       TriggerClientEvent('lp_streetfight:kazananDgoster', -1, id)
end)