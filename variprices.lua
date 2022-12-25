--
--
-- Variation priced of fuels diesel an def
--
-- Author: SbSh / Frvetz
-- 11.7.22
-- 0.0.1.5
-- variprices.lua
--
-- ToDo:
-- 		l10n einbauen
--		def wieder mit einbinden
--		
--

RandomFuelsPrices = {}

-- RandomFuelsPrices.modDirectory = RandomFuelsPrices_register.modDirectory
-- RandomFuelsPrices.debug = true -- if you experience any issues set this to true and send me the log with description of your issue 


	-- superPreis     			1,55 € - 1,85 €
local DieselPreis = 1659; -- x1000	1,65 € - 2,20 €
local DieselPreisO = DieselPreis + 260; 
local DieselPreisU = DieselPreis - 120; 
-- local AdBluePreis = 1.77; -- 	1,50 € - 4,00 €
local AdBluePreisO = 1500; 
local AdBluePreisU = 4000; 
local Stand = "20.12.2022";
local sbshDebugOn = false;
local calcDebugOn = false;


function RandomFuelsPrices:init()
    FSBaseMission.loadMap = Utils.appendedFunction(FSBaseMission.loadMap, RandomFuelsPrices.mapLoaded)
	if g_currentMission ~= nil then
		-- for what
	end
end

function RandomFuelsPrices:mapLoaded()
    local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
    local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
	
    if funitDiesel == nil then
        print("[ERROR] RandomFuelsPrices: unknown filltype 'DIESEL'")
        return
    end
	if funitDef == nil then
        print("[ERROR] RandomFuelsPrices: unknown filltype 'DEF' (adBlue)")
        return
    end
	
	if sbshDebugOn then
		print("RandomFuelsPrices: Vanilla price before: " .. funitDiesel.pricePerLiter) -- 1,25
	end
	local alterDieselPreis = funitDiesel.pricePerLiter / 2
	local alterDefPreis = funitDef.pricePerLiter
	local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
    local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
	local currentHour = g_currentMission.environment.dayTime
	local randSamen = math.ceil(g_currentMission.environment.dayTime) * 100
	math.randomseed(randSamen)
	local newDP = (math.random(DieselPreisU,DieselPreisO) / 1000 )
	local newABP = (math.random(AdBluePreisU,AdBluePreisO) / 1000 )
	funitDiesel.pricePerLiter = (newDP - alterDieselPreis)
	funitDef.pricePerLiter = newABP
	-- debug --------------------------------------------------------------
	if sbshDebugOn then 
		if g_currentMission == nil then
			print("RandomFuelsPrices: [DEBUG] g_currentMission is nil")
		end
		if environment == nil then
			print("RandomFuelsPrices: [DEBUG] environment is nil")
		end
		if timeAdjustment == nil then
			print("RandomFuelsPrices: [DEBUG] timeAdjustment is nil")
		end
		if dayTime == nil then
			print("RandomFuelsPrices: [DEBUG] dayTime is nil")
		end
		if randSamen == nil then
			print("RandomFuelsPrices: [DEBUG] randSamen is nil")
		end
			if g_currentMission.environment.dayTime ~= nil then
			print("RandomFuelsPrices: Seed: [DEBUG] " .. randSamen .. " dayTime: " .. g_currentMission.environment.dayTime)
		end
	-------------------------------------------------------------------
		print("################################################################################################################")
		print("[INFO] RandomFuelsPrices: Set price per liter DIESEL to " .. funitDiesel.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter TT to " .. newDP .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter DEF (adBlue) to " .. funitDef.pricePerLiter .. " Stand vom " ..Stand)
		print("################################################################################################################")
		print("RandomFuelsPrices: [DEBUG] neuer Diesel Preis " .. newDP .. "  neuer DEF Preis: " .. newABP .. " €")
		print("RandomFuelsPrices: alterDieselPreis: " .. alterDieselPreis)
		print("RandomFuelsPrices: Obere Berechnung: " .. DieselPreisO .. "  Untere Berechnung: ".. DieselPreisU)
		print("RandomFuelsPrices: funitDiesel.pricePerLiter: " .. funitDiesel.pricePerLiter)
	end
end


function RandomFuelsPrices:CalculateFinishTime(AddHour, AddMinute, self)
    local FinishHour = 0
    local FinishMinute = 0
    local PlusHourForMinutes = math.floor((g_currentMission.environment.currentMinute + AddMinute) / 60)
    local FinishDay = g_currentMission.environment.currentDay + math.floor((g_currentMission.environment.currentHour + PlusHourForMinutes + AddHour) / 21)
    
    if g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes >= 23 then
        FinishHour = g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes  - 14 - (math.max(g_currentMission.environment.currentHour - 21, 0))
        if PlusHourForMinutes >= 1 then
            FinishMinute = g_currentMission.environment.currentMinute + AddMinute - 60
        else
            FinishMinute = g_currentMission.environment.currentMinute + AddMinute
        end
    elseif g_currentMission.environment.currentHour < 7 then
        FinishHour = g_currentMission.environment.currentHour + AddHour + (9 - g_currentMission.environment.currentHour)
        FinishMinute = 0 + AddMinute
    else
        FinishHour = g_currentMission.environment.currentHour + AddHour + PlusHourForMinutes
        if PlusHourForMinutes >= 1 then
            FinishMinute = g_currentMission.environment.currentMinute + AddMinute - 60
        else
            FinishMinute = g_currentMission.environment.currentMinute + AddMinute
        end
    end
	
    return FinishDay, FinishHour, FinishMinute
end


function RandomFuelsPrices:onUpdate(dt)
	if self ~= nil then
		local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
		local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
		local alterDieselPreis = funitDiesel.pricePerLiter / 2
		local alterDefPreis = funitDef.pricePerLiter
		local randSamen = math.ceil(g_currentMission.environment.dayTime) * 100 -- additional minute evtl. seed weiter willkürlicher machen, nötig oder nicht

		if i ~= 1 then
			FinishDay, FinishHour, FinishMinute = RandomFuelsPrices:CalculateFinishTime(5, 0, self)
			i = 1
		end
		if i == 1 and g_currentMission.environment.currentHour == FinishHour and g_currentMission.environment.currentMinute == FinishMinute then -- i = safty bonus
			local alterDieselPreis = funitDiesel.pricePerLiter / 2
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local newDP = string.format("%.3f", (math.random(DieselPreisU,DieselPreisO) / 1000 ))
			math.randomseed(randSamen)
			funitDiesel.pricePerLiter = (newDP - alterDieselPreis)
			if sbshDebugOn then
				g_currentMission:addExtraPrintText("newDP" .. newDP .. " € und alterDefPreis" .. alterDefPreis .. " €") -- #l10n
			end
			
			i = 0
		end
		g_currentMission:addExtraPrintText("Aktueller Dieselpreis: " .. funitDiesel.pricePerLiter .. " €") -- #l10n
	end
end

RandomFuelsPrices:init()
Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, RandomFuelsPrices.onUpdate);