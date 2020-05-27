ESX = nil

local inWork = false
local lastWork = 0
local TIMEBEFOREWORK = 90 --seconds
local pay = {
    ['rich'] = {750, 1250},
    ['default'] = {100, 300},
    ['bad'] = {20, 80},
    ['poor'] = {0, 15}
}

TriggerEvent(
    'esx:getSharedObject',
    function(obj)
        ESX = obj
    end
)

RegisterServerEvent('esx_procurer:startWorking')
RegisterServerEvent('esx_procurer:workDone')
RegisterServerEvent('esx_procurer:pay')

AddEventHandler('esx_procurer:startWorking',
    function()
        local _source = source
        local timeRemaining = TIMEBEFOREWORK - (os.time() - lastWork)
        if not inWork then
            if lastWork == 0 or timeRemaining <= 0 then
                inWork = true
                TriggerClientEvent('esx:showNotification', _source, 'Vous êtes le ~p~Mac à dames~w~, occupez vous des ~g~clients~w~ et protégez les putes.')
                TriggerClientEvent('esx_procurer:startGuarding', _source)
            else
                TriggerClientEvent('esx:showNotification', _source, 'Elles ont déjà bossées. ~y~Laissez les se reposer encore ~r~' .. timeRemaining .. ' ~w~secondes.')
            end
        else
            TriggerClientEvent('esx:showNotification', _source, '~r~Elles sont déjà en train de bosser!')
        end
    end
)

AddEventHandler('esx_procurer:workDone',
    function()
        inWork = false
        lastWork = os.time()
    end
)

AddEventHandler('esx_procurer:pay',
    function(type)
        local _source = source
        local xPlayer = ESX.GetPlayerFromId(_source)
        local payPlayer = math.random(pay[type][1], pay[type][2])
        xPlayer.addAccountMoney('black_money', payPlayer)
        TriggerClientEvent('esx:showNotification', _source, 'Le ~g~client~w~ a fini! Vous avez gagné ~g~' .. payPlayer .. '~g~$')
    end
)