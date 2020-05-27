ESX = nil

local Customer = {
    modelType = {
        {
            name = 'rich',
            models = {
                1423699487,
                1982350912,
                1068876755,
                1720428295,
                -1697435671,
                2120901815,
                -912318012,
                -1280051738,
                -1589423867,
                1048844220,
                -1852518909,
                1561705728,
                1264851357,
                534725268,
                835315305
            }
        },
        {
            name = 'default',
            models = {
                68070371,
                -2077764712,
                -900269486,
                2114544056,
                1984382277,
                -1481174974,
                436345731,
                -37334073,
                377976310,
                131961260,
                -1806291497,
                -1453933154,
                115168927,
                891398354,
                587703123,
                349505262,
                706935758,
                696250687,
                452351020,
                -1302522190,
                1906124788,
                -283816889,
                1626646295,
                -1299428795,
                -681546704,
                539004493,
                1328415626,
                919005580,
                605602864,
                -2039163396,
                -1029146878,
                -812470807,
                -1023672578,
                -1976105999,
                -1007618204,
                238213328,
                -1948675910,
                -417940021,
                718836251,
                1750583735,
                -1047300121
            }
        },
        {
            name = 'bad',
            models = {
                1299424319,
                -973145378,
                -673538407,
                -1739208332,
                349680864,
                -2039072303,
                -106498753,
                -1538846349,
                1161072059,
                -1643617475,
                -396800478,
                1822107721,
                2064532783,
                1358380044,
                321657486,
                810804565,
                653210662,
                228715206,
                -48477765,
                -1398552374,
                -1620232223
            }
        },
        {
            name = 'poor',
            models = {
                -512913663,
                1430544400,
                -1251702741,
                1268862154,
                -2132435154,
                1191548746,
                1787764635,
                516505552,
                390939205,
                1404403376,
                -521758348,
                -264140789,
                2097407511,
                1768677545,
                1082572151
            }
        }
    },
    pos = vector3(1504.18, 6408.81, 22.2),
    h = 69.77
}
local Gang = {
    gangType = {
        {
            name = 'armenian',
            models = {
                -39239064,
                -984709238,
                -984709238,
                -236444766
            }
        },
        {
            name = 'ballas',
            models = {
                -198252413,
                588969535,
                -1492432238,
                599294057
            }
        },
        {
            name = 'triades',
            models = {
                -1463670378,
                2119136831,
                275618457,
                -1176698112
            }
        },
        {
            name = 'korean',
            models = {
                891945583,
                2093736314,
                -1880237687,
                611648169
            }
        },
        {
            name = 'vagos',
            models = {
                -1109568186,
                1226102803,
                832784782,
                -1773333796
            }
        },
        {
            name = 'marabunta_grande',
            models = {
                -1872961334,
                663522487,
                846439045,
                62440720
            }
        }
    },
    pos = vector3(1504.18, 6408.81, 22.2),
    h = 69.77
}
local Hooker = {
    model = 348382215,
    pos = vector3(1441.61, 6334.1, 22.8),
    h = 76.8,
    anim = 'WORLD_HUMAN_PROSTITUTE_HIGH_CLASS'
}
local PlayerData = {}
local JOBTIME = 300 --seconds
local MAXDISTANCE = 40
local CLOSE = 2
local WORKPOS = {x = 1458.91, y = 6346.37, z = 23.5}
local GOTOPED = vector3(1474.46, 6369.22, 23.63)
local GOTOHOOKER = vector3(1457.33, 6346.52, 22.8)
local SpawnedHooker = nil
local SpawnedPed = nil
local missionStarted = false
local incomingHooker = false
local inPlaceHooker = false
local incomingPed = false
local gotoHookerPed = false

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
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx_procurer:startWorking')
RegisterNetEvent('esx_procurer:startGuarding')

AddEventHandler('esx_procurer:startWorking',
    function()
        if not missionStarted then
            TriggerServerEvent('esx_procurer:startWorking')
        else
            ESX.ShowNotification("~r~C'est déjà toi le mac.")
        end
    end
)

AddEventHandler('esx_procurer:startGuarding',
    function()
        missionStarted = true
        SpawnHookers()
        local maxTimer = JOBTIME * 100
        local timer = maxTimer
        local diceAttack = maxTimer * 1.5
        local rollAttack = math.random(10000, diceAttack)
        while timer > 0 do
            Citizen.Wait(0)
			local playerPos = GetEntityCoords(PlayerPedId(), true)
			local hookerPos = GetEntityCoords(SpawnedHooker)
			ShowInGuard(0.66, 1.44, 1.0, 1.0, 0.4, '~p~Mac à Dames', 255, 255, 255, 255)
			if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) > (MAXDISTANCE - 5) then
                ESX.ShowNotification('Restez près des ~y~putes~w~ sinon la ~y~protection~w~ va être ~r~annulée~w~.')
            end
            if timer < maxTimer then
                if timer % 1000 == 0 then
                    local rollCustomer = math.random(0, 2)
                    if rollCustomer > 0 then
                        CallCustomer()
                    end
                end
            end
            if rollAttack == timer then
                StartAttack()
            end
            if IsPedDeadOrDying(PlayerPedId()) == 1 then
                ResetWork()
                timer = 0
            end
			if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < MAXDISTANCE then
				if Vdist(hookerPos.x, hookerPos.y, hookerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < (MAXDISTANCE - 5) then
					if IsPedDeadOrDying(SpawnedHooker) == false then
						if inPlaceHooker then
							timer = timer - 1
						end
					else
						ESX.ShowNotification('La ~y~pute~w~ est ~r~morte~w~! Vous devez la ~r~protéger~w~.')
						ResetWork()
						timer = 0
					end
				else
					ESX.ShowNotification('La ~y~pute~w~ est ~r~effrayée~w~ et elle est partie!')
					ResetWork()
					timer = 0
				end
			else
				ESX.ShowNotification('La ~y~protection~w~ est ~r~annulée!~w~.')
                ResetWork()
				timer = 0
			end
        end
        ResetWork()
    end
)

function SpawnHookers()
    RequestModel(Hooker.model)
    while not HasModelLoaded(Hooker.model) do
        Citizen.Wait(1)
    end
    SpawnedHooker = CreatePed(2, Hooker.model, Hooker.pos, Hooker.h, true, true)
    SetEntityAsMissionEntity(SpawnedHooker)
    TaskGoToCoordAnyMeans(SpawnedHooker, GOTOHOOKER, 1.1, 0, 0, 0, 0)
    incomingHooker = true
    while incomingHooker do
        Citizen.Wait(0)
        local hookerPos = GetEntityCoords(SpawnedHooker)
        local distanceHookerPlace = GetDistanceBetweenCoords(hookerPos.x, hookerPos.y, hookerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z, true)
		local playerPos = GetEntityCoords(PlayerPedId(), true)
		ShowInGuard(0.66, 1.44, 1.0, 1.0, 0.4, '~p~Mac à Dames', 255, 255, 255, 255)
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) > (MAXDISTANCE - 5) then
			ESX.ShowNotification('Restez près des ~y~putes~w~ sinon la ~y~protection~w~ va être ~r~annulée~w~.')
        end
        if IsPedDeadOrDying(PlayerPedId()) == 1 then
            ResetWork()
        end
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < MAXDISTANCE then
			if Vdist(hookerPos.x, hookerPos.y, hookerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < (MAXDISTANCE - 5) then
				if IsPedDeadOrDying(SpawnedHooker) == false then 
					if distanceHookerPlace < CLOSE then
						TaskGoToCoordAnyMeans(SpawnedHooker, 1456.8, 6348.5, 22.8, 1.0, 0, 0, 0, 0)
						Citizen.Wait(500)
						ReturnAnim()
						incomingHooker = false
					end
				else
					ESX.ShowNotification('La ~y~pute~w~ est ~r~morte~w~! Vous devez la ~r~protéger~w~.')
					ResetWork()
				end
			else
				ESX.ShowNotification('La ~y~pute~w~ est ~r~effrayée~w~ et elle est partie!')
				ResetWork()
			end
		else
			ESX.ShowNotification('La ~y~protection~w~ est ~r~annulée!~w~.')
			ResetWork()
		end
    end
end

function CallCustomer()
    local type = math.random(1, #Customer.modelType)
    local models = Customer.modelType[type].models
    local model = models[math.random(1, #models)]
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(1)
    end
    SpawnedPed = CreatePed(2, model, Customer.pos, Customer.h, true, true)
    SetEntityAsMissionEntity(SpawnedPed)
    SetEntityNoCollisionEntity(SpawnedPed, SpawnedHooker, 0)
    TaskGoToCoordAnyMeans(SpawnedPed, GOTOPED, 1.0, 0, 0, 0, 0)
    ESX.ShowNotification("Un ~g~client~w~ arrive, attendez qu'il se rapproche et occupez vous de lui.")
    incomingPed = true
    while incomingPed do
        Citizen.Wait(0)
        local playerPos = GetEntityCoords(PlayerPedId())
        local pedPos = GetEntityCoords(SpawnedPed)
        local hookerPos = GetEntityCoords(SpawnedHooker)
        local distancePedPlayer = GetDistanceBetweenCoords(pedPos.x, pedPos.y, pedPos.z, playerPos.x, playerPos.y, playerPos.z, true)
		local distancePedPlace = GetDistanceBetweenCoords(pedPos.x, pedPos.y, pedPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z, true)
		ShowInGuard(0.66, 1.44, 1.0, 1.0, 0.4, '~p~Mac à Dames', 255, 255, 255, 255)
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) > (MAXDISTANCE - 5) then
			ESX.ShowNotification('Restez près des ~y~putes~w~ sinon la ~y~protection~w~ va être ~r~annulée~w~.')
        end
        if IsPedDeadOrDying(PlayerPedId()) == 1 then
            ResetWork()
        end
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < MAXDISTANCE then
			if Vdist(hookerPos.x, hookerPos.y, hookerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < (MAXDISTANCE - 5) then
				if distancePedPlace < (MAXDISTANCE * 3) then
					if IsPedDeadOrDying(SpawnedHooker) == false then
						if IsPedDeadOrDying(SpawnedPed) == false then
							if distancePedPlayer < CLOSE then
								ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour ~g~accepter~w~ ou sur ~INPUT_CREATOR_LT~ pour ~r~refuser~w~.')
								if IsControlJustPressed(1, 38) and GetLastInputMethod(2) then
									TaskGoToCoordAnyMeans(SpawnedPed, hookerPos, 1.0, 0, 0, 0, 0)
									incomingPed = false
									GotoHooker(type)
								end
								if IsControlJustPressed(1, 73) and GetLastInputMethod(2) then
									ESX.ShowNotification('Vous avez ~r~refusé~w~ le ~g~client~w~.')

									if Customer.modelType[type].name == 'rich' or Customer.modelType[type].name == 'default' then
										ResetCustomer()
									elseif Customer.modelType[type].name == 'poor' then
										local rollChanceAngry = math.random(0, 4)
										if rollChanceAngry == 0 then
											TaskCombatPed(SpawnedPed, SpawnedHooker, 0, 16)
											SetModelAsNoLongerNeeded(SpawnedPed)
											incomingPed = false
										else
											ResetCustomer()
										end
									elseif Customer.modelType[type].name == 'bad' then
										local rollChanceAngry = math.random(0, 2)
										local target = math.random(0, 3)
										if rollChanceAngry > 0 then
											if target > 0 then
												TaskCombatPed(SpawnedPed, GetPlayerPed(-1), 0, 16)
												SetModelAsNoLongerNeeded(SpawnedPed)
												incomingPed = false
											else 
												TaskCombatPed(SpawnedPed, SpawnedHooker, 0, 16)
												SetModelAsNoLongerNeeded(SpawnedPed)
												incomingPed = false
											end
										else
											ResetCustomer()
										end
									end
								end
							end
						else
							ESX.ShowNotification('Le ~g~client~w~ est ~r~mort~w~!')
							ResetCustomer()
						end
					else
						ESX.ShowNotification('La ~y~pute~w~ est ~r~morte~w~! Vous devez la ~r~protéger~w~.')
						ResetWork()
					end
				else
					ESX.ShowNotification('Le ~g~client~w~ est ~r~parti~w~!')
					ResetCustomer()
				end
			else
				ESX.ShowNotification('La ~y~pute~w~ est ~r~effrayée~w~ et elle est partie!')
				ResetWork()
			end
        else
            ESX.ShowNotification('La ~y~protection~w~ est ~r~annulée!~w~.')
            ResetWork()
        end
    end
end

function GotoHooker(type)
    ESX.ShowNotification("Vous avez ~y~accepté~w~ le ~g~client~w~. Attendez qu'il fasse son affaire pour gagner de l'argent.")
    gotoHookerPed = true
    while gotoHookerPed do
        Citizen.Wait(0)
        local playerPos = GetEntityCoords(PlayerPedId())
        local pedPos = GetEntityCoords(SpawnedPed)
        local hookerPos = GetEntityCoords(SpawnedHooker)
        local distancePedHooker = GetDistanceBetweenCoords(pedPos.x, pedPos.y, pedPos.z, hookerPos.x, hookerPos.y, hookerPos.z, true)
		local distancePedPlace = GetDistanceBetweenCoords(pedPos.x, pedPos.y, pedPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z, true)
		ShowInGuard(0.66, 1.44, 1.0, 1.0, 0.4, '~p~Mac à Dames', 255, 255, 255, 255)
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) > (MAXDISTANCE - 5) then
			ESX.ShowNotification('Restez près des ~y~putes~w~ sinon la ~y~protection~w~ va être ~r~annulée~w~.')
        end
        if IsPedDeadOrDying(PlayerPedId()) == 1 then
            ResetWork()
        end
		if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < MAXDISTANCE then
			if Vdist(hookerPos.x, hookerPos.y, hookerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < (MAXDISTANCE - 5) then
				if distancePedPlace < (MAXDISTANCE * 3) then
					if IsPedDeadOrDying(SpawnedHooker) == false then
						if IsPedDeadOrDying(SpawnedPed) == false then
							if distancePedHooker < CLOSE then
								gotoHookerPed = false
								HookerWork(type)
							end
						else
							ESX.ShowNotification('Le ~g~client~w~ est ~r~mort~w~!')
							ResetCustomer()
						end
					else
						ESX.ShowNotification('La ~y~pute~w~ est ~r~morte~w~! Vous devez la ~r~protéger~w~.')
						ResetWork()
					end
				else
					ESX.ShowNotification('Le ~g~client~w~ est ~r~parti~w~!')
					ResetCustomer()
				end
			else
				ESX.ShowNotification('La ~y~pute~w~ est ~r~effrayée~w~ et elle est partie!')
				ResetWork()
			end
        else
            ESX.ShowNotification('La ~y~protection~w~ est ~r~annulée!~w~.')
            ResetWork()
        end
    end
end

function HookerWork(type)
    local pedPos = GetEntityCoords(SpawnedPed)
    local distancePedPlace = GetDistanceBetweenCoords(pedPos.x, pedPos.y, pedPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z, true)
    local workingTime = 1000
    RequestAnimDict('mini@prostitutes@sexnorm_veh')
    while not HasAnimDictLoaded('mini@prostitutes@sexnorm_veh') do
        Citizen.Wait(0)
	end
    if distancePedPlace < (MAXDISTANCE * 3) then
        if IsPedDeadOrDying(SpawnedPed) == false then
            FreezeEntityPosition(SpawnedPed, true)
            FreezeEntityPosition(SpawnedHooker, true)
            SetEntityCollision(SpawnedPed, 0, 0)
            SetEntityCollision(SpawnedHooker, 0, 0)
			TaskPlayAnimAdvanced(SpawnedHooker, 'mini@prostitutes@sexnorm_veh', 'sex_loop_prostitute', WORKPOS.x, WORKPOS.y, WORKPOS.z, 0, 0, 0, 8.0, 8.0, -1, 1, 1.0, 0, 0)
			TaskPlayAnimAdvanced(SpawnedPed, 'mini@prostitutes@sexnorm_veh', 'sex_loop_male', WORKPOS.x, WORKPOS.y, WORKPOS.z, 0, 0, 0, 8.0, 8.0, -1, 1, 1.0, 0, 0)
            while workingTime > 0 do
                Citizen.Wait(0)
                local playerPos = GetEntityCoords(PlayerPedId())
                SetEntityCoords(SpawnedPed, WORKPOS.x, WORKPOS.y, WORKPOS.z - 1.4, 0, 0, 0, 0)
				SetEntityCoords(SpawnedHooker, WORKPOS.x + 0.85, WORKPOS.y + 0.05, WORKPOS.z - 1.45, 0, 0, 0, 0)
				ShowInGuard(0.66, 1.44, 1.0, 1.0, 0.4, '~p~Mac à Dames', 255, 255, 255, 255)
				if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) > (MAXDISTANCE - 5) then
					ESX.ShowNotification('Restez près des ~y~putes~w~ sinon la ~y~protection~w~ va être ~r~annulée~w~.')
                end
                if IsPedDeadOrDying(PlayerPedId()) == 1 then
                    ResetWork()
                    workingTime = 0
                end
                if Vdist(playerPos.x, playerPos.y, playerPos.z, WORKPOS.x, WORKPOS.y, WORKPOS.z) < MAXDISTANCE then
                    if IsPedDeadOrDying(SpawnedHooker) == false then
                        if IsPedDeadOrDying(SpawnedPed) == false then
                            workingTime = workingTime - 1
                        else
                            ESX.ShowNotification('Le ~g~client~w~ est ~r~mort~w~!')
                            SetEntityCollision(SpawnedPed, 1, 1)
                            SetEntityCollision(SpawnedHooker, 1, 1)
                            FreezeEntityPosition(SpawnedPed, false)
                            FreezeEntityPosition(SpawnedHooker, false)
                            ResetCustomer()
                            workingTime = 0
                        end
                    else
						ESX.ShowNotification('La ~y~pute~w~ est ~r~morte~w~! Vous devez la ~r~protéger~w~.')
						ResetWork()
                        workingTime = 0
                    end
                else
					ESX.ShowNotification('La ~y~protection~w~ est ~r~annulée!~w~.')
					ResetWork()
                    workingTime = 0
                end
                if workingTime < 1 then
                    SetEntityCollision(SpawnedPed, 1, 1)
                    SetEntityCollision(SpawnedHooker, 1, 1)
                    FreezeEntityPosition(SpawnedPed, false)
                    FreezeEntityPosition(SpawnedHooker, false)
                    ResetCustomer()
                    TriggerServerEvent('esx_procurer:pay', Customer.modelType[type].name)
                end
            end
        else
            ESX.ShowNotification('Le ~g~client~w~ est ~r~mort~w~!')
            ResetCustomer()
        end
    else
        ESX.ShowNotification('Le ~g~client~w~ est ~r~parti~w~!')
        ResetCustomer()
    end
end

function StartAttack()
    local type = math.random(1, #Gang.gangType)
    ESX.ShowNotification('Un ~r~gang~w~ veut reprendre la zone. ~y~Défendez vous!~w~')
    for _, model in pairs(Gang.gangType[type].models) do
        if model ~= nil then
            RequestModel(model)
            while not HasModelLoaded(model) do
                Citizen.Wait(1)
            end
            SpawnedGang = CreatePed(2, model, Gang.pos, Gang.h, true, true)
            TaskCombatPed(SpawnedGang, GetPlayerPed(-1), 0, 16)
            SetModelAsNoLongerNeeded(SpawnedGang)
        end
    end
end

function ReturnAnim()
    SetEntityCoords(SpawnedHooker, GOTOHOOKER, 0, 0, 0, 0)
    TaskStartScenarioInPlace(SpawnedHooker, Hooker.anim, 0, false)
    inPlaceHooker = true
end

function ResetCustomer()
    SetPedAsNoLongerNeeded(SpawnedPed)
    SetModelAsNoLongerNeeded(SpawnedPed)
    ReturnAnim()
    incomingPed = false
    gotoHookerPed = false
end

function ResetWork()
    TriggerServerEvent('esx_procurer:workDone')
    SetPedAsNoLongerNeeded(SpawnedPed)
    SetModelAsNoLongerNeeded(SpawnedPed)
    SetPedAsNoLongerNeeded(SpawnedHooker)
    SetModelAsNoLongerNeeded(SpawnedHooker)
    incomingHooker = false
    inPlaceHooker = false
    incomingPed = false
    gotoHookerPed = false
    missionStarted = false
end

function ShowInGuard(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	if outline then SetTextOutline() end
	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end