--
--
-- Variation priced of fuels diesel an def
--
-- Author: SbSh / Frvetz
-- 11.7.22
-- 0.1.0.1
-- last edit: 23.04.2023
-- variprices.lua
--
-- ToDo:
-- 3d Display done
-- sync that shit


-- Käse - Version

RandomFuelsPrices = {}

local DieselPreis = 1559;
local DieselPreisO = DieselPreis + 359; 
local DieselPreisU = DieselPreis - 95; 
-- fakeSuperPreisO = 1995; 
-- fakeSuperPreisU = 1499;
local AdBluePreisU = 1500; 
local AdBluePreisO = 4000; 
local GasPreisU = 0450; 
local GasPreisO = 1300;
local EPreisU = 0250; 
local EPreisO = 1050;
local Stand = "23.04.2023";
local sbshDebugOn = true; -- debug
-- local calcDebugOn = true; -- debug with time calc
local oldDieselPreis = 1559;	
local ElChangedtY = 0; -- change only once per year
local NewFinish = 0
-- local newDP = 1.111
-- local newAB = 2.222
-- local newMT = 3.333
-- local newEL = 4.444
local readXMLdone = 0;

function RandomFuelsPrices.prerequisitesPresent(specializations)
    return true;
end
function RandomFuelsPrices.registerEventListeners(placeableType)
	SpecializationUtil.registerEventListener(placeableType, "onLoad", RandomFuelsPrices);
	SpecializationUtil.registerEventListener(placeableType, "onMinuteChanged", RandomFuelsPrices);
end
function RandomFuelsPrices.registerFunctions(placeableType)
	SpecializationUtil.registerOverwrittenFunction(placeableType, "getNeedMinuteChanged", RandomFuelsPrices.getNeedMinuteChanged)
end

function RandomFuelsPrices:getNeedMinuteChanged()
	return true;
end
-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:loadedMission(mission, node)
    -- if mission:getIsServer() then  -- variprices.lua:45: attempt to index local 'mission' (a number value)
	local spec = self.spec_RFP
    if mission:getIsServer() then
        if mission.missionInfo.savegameDirectory ~= nil and fileExists(mission.missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml") then
		-- 46 attempt to index local 'mission' (a number value)
            local xmlFile = XMLFile.load("RandomFuelsPrices", missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml")
            if xmlFile ~= nil then
                FinishHour = xmlFile:getFloat("RandomFuelsPrices.FinishHour", FinishHour)
                FinishMinute = xmlFile:getFloat("RandomFuelsPrices.FinishMinute", FinishMinute)
                oldDieselPreis = xmlFile:getFloat("RandomFuelsPrices.oldDieselPreis", oldDieselPreis)
                newAB = xmlFile:getFloat("RandomFuelsPrices.newAB", newAB)
                newMT = xmlFile:getFloat("RandomFuelsPrices.newMT", newMT)
                newEL = xmlFile:getFloat("RandomFuelsPrices.newEL", newEL)
				NewFinish = xmlFile:getFloat("RandomFuelsPrices.NewFinish", NewFinish)
				print("RFP: RandomFuelsPrices.xml loaded")
				print("RFP: RandomFuelsPrices.xml oldDieselPreis: ".. tostring(oldDieselPreis/1000))
				print("RFP: RandomFuelsPrices.xml newAB: ".. tostring(newAB))
				print("RFP: RandomFuelsPrices.xml newMT: ".. tostring(newMT))
				print("RFP: RandomFuelsPrices.xml newEL: ".. tostring(newEL))
				
                xmlFile:delete()
				readXMLdone = 1
            end
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
			local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
			local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
			newDP = (oldDieselPreis/1000)
			funitDiesel.pricePerLiter = (oldDieselPreis/1000)
			funitDef.pricePerLiter = (newAB)
			funitGas.pricePerLiter = (newMT)
			funitElek.pricePerLiter = (newEL)
		else
			---------------------------------------------------------------------------------------------------------------------------------------
			-- update prices to new "default" when game is started for the first time with the script
			---------------------------------------------------------------------------------------------------------------------------------------
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
			local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
			local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
			funitDiesel.pricePerLiter = 1.559
			funitDef.pricePerLiter = 2.500
			funitGas.pricePerLiter = 0.810
			funitElek.pricePerLiter = 0.570
			print("RFP: RandomFuelsPrices.xml NOT loaded")
        end
    end
    if missionInfo.cancelLoading then
        return
    end
	-- dirtyFlag = self:getNextDirtyFlag() -- error
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices.saveToXMLFile(missionInfo)
    if missionInfo.isValid then
		local spec = self.spec_RFP
        local xmlFile = XMLFile.create("RandomFuelsPrices", missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml", "RandomFuelsPrices")
        if xmlFile ~= nil then
            xmlFile:setFloat("RandomFuelsPrices.FinishHour", FinishHour)
            xmlFile:setFloat("RandomFuelsPrices.FinishMinute", FinishMinute)
            xmlFile:setFloat("RandomFuelsPrices.oldDieselPreis", oldDieselPreis) -- ????  newDP ?!?!
            xmlFile:setFloat("RandomFuelsPrices.newAB", tonumber(newAB))
            xmlFile:setFloat("RandomFuelsPrices.newMT", tonumber(newMT))
            xmlFile:setFloat("RandomFuelsPrices.newEL", tonumber(newEL))

			xmlFile:setFloat("RandomFuelsPrices.NewFinish", NewFinish)
            xmlFile:save()
            xmlFile:delete()
			print("RFP: RandomFuelsPrices.xml saved")
        end
    end
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- function RandomFuelsPrices:init()
    -- FSBaseMission.loadMap = Utils.appendedFunction(FSBaseMission.loadMap, RandomFuelsPrices.mapLoaded)
	-- if g_currentMission ~= nil then
		-- -- for what
	-- end
-- end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:onLoad(savegame) -- savegame or name ?
	self.spec_RFP = {}
	local spec = self.spec_RFP
	local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
	local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
	local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
	local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
	if readXMLdone == 1 then
		newDP = (oldDieselPreis/1000)
		funitDiesel.pricePerLiter = newDP -- ???? newDP, oldDieselPreis is loaded from xml and... calculate max min change on random
		funitDef.pricePerLiter = (newAB)
		funitGas.pricePerLiter = (newMT)
		funitElek.pricePerLiter = (newEL)
		readXMLdone = 2
		print("RFP: XML Werte gesetzt mL")
	end
	if sbshDebugOn then
		print("RFP: currentDieselPreis MapLoaded: "..tostring(funitDiesel.pricePerLiter))
		print("RFP: currentDEFPreis MapLoaded: "..tostring(funitDef.pricePerLiter))
		print("RFP: currentGasPreis MapLoaded: "..tostring(funitGas.pricePerLiter))
		print("RFP: currentElekPreis MapLoaded: "..tostring(funitElek.pricePerLiter))
	end
    if funitDiesel == nil then print("[ERROR] RandomFuelsPrices variprice.lua: unknown filltype 'DIESEL'") return end
	if funitDef == nil then print("[ERROR] RandomFuelsPrices variprice.lua: unknown filltype 'DEF' (adBlue)") return end
	if funitGas == nil then print("[ERROR] RandomFuelsPrices variprice.lua: unknown filltype 'METHANE'") return end
	if funitElek == nil then print("[ERROR] RandomFuelsPrices variprice.lua: unknown filltype 'ELECTRICCHARGE'") return end
	if sbshDebugOn then print("RandomFuelsPrices: Vanilla price before: " .. funitDiesel.pricePerLiter) end
	-- debug --------------------------------------------------------------
	if sbshDebugOn then 
		if g_currentMission == nil then print("RandomFuelsPrices: [DEBUG] g_currentMission is nil ")end
		if environment == nil then print("RandomFuelsPrices: [DEBUG] environment is nil") end
		if timeAdjustment == nil then print("RandomFuelsPrices: [DEBUG] timeAdjustment is nil") end
		if dayTime == nil then print("RandomFuelsPrices: [DEBUG] dayTime is nil") end
		if randSamen == nil then print("RandomFuelsPrices: [DEBUG] randSamen is nil") end
		if g_currentMission.environment.dayTime ~= nil then	print("RandomFuelsPrices: Seed: [DEBUG] " .. tostring(randSamen) .. " dayTime: " .. tostring(g_currentMission.environment.dayTime)) end
		print("################################################################################################################")
		print("[INFO] RandomFuelsPrices: Set price per liter DIESEL to " .. funitDiesel.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter DEF (adBlue) to " .. funitDef.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter METHANE to " .. funitGas.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter ELECTRICCHARGE to " .. funitElek.pricePerLiter .. " Stand vom " ..Stand)
		print("################################################################################################################")
		print("RandomFuelsPrices: [DEBUG] neuer Diesel Preis " .. tostring(newDP) .. "  neuer DEF Preis: " .. tostring(newAB) .. " €")
		print("RandomFuelsPrices: [DEBUG] neuer Gas Preis " .. tostring(newMT) .. "  neuer Strom Preis: " .. tostring(newEL) .. " €")
		-- print("RandomFuelsPrices: alterDieselPreis: " .. tostring(alterDieselPreis))
		print("RandomFuelsPrices: oldDieselPreis: " .. tostring(oldDieselPreis))
		print("RandomFuelsPrices: Obere Berechnung: " .. tostring(DieselPreisO) .. "  Untere Berechnung: ".. tostring(DieselPreisU))
		-- print("RandomFuelsPrices: funitDiesel.pricePerLiter: " .. tostring(funitDiesel.pricePerLiter))
	end
end
-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:CalculateFinishTimeD(AddHour, AddMinute)
	local spec = self.spec_RFP
	if sbshDebugOn then	print("Tank-Preise haben sich verändert") end
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

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- function RandomFuelsPrices:update(dt)
function RandomFuelsPrices:onMinuteChanged()
	-- if g_server ~= nil then
		local spec = self.spec_RFP
		local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
		local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
		local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
		local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
		local alterDieselPreis = funitDiesel.pricePerLiter
		local alterDefPreis = funitDef.pricePerLiter
		local alterGasPreis = funitGas.pricePerLiter
		local alterElekPreis = funitElek.pricePerLiter
		local randSamen = math.ceil(g_currentMission.environment.dayTime * 100) -- g_currentDt
		if readXMLdone == 1 then
			funitDiesel.pricePerLiter = (oldDieselPreis/1000)
			funitDef.pricePerLiter = (newAB)
			funitGas.pricePerLiter = (newMT)
			funitElek.pricePerLiter = (newEL)
			readXMLdone = 2
		elseif readXMLdone == 0 then
			funitDiesel.pricePerLiter = 1.555
			funitDef.pricePerLiter = 2.555
			funitGas.pricePerLiter = 3.555
			funitElek.pricePerLiter = 4.555
			readXMLdone = 3
		end
		if sbshDebugOn then
			print("RFP: readXMLdone upd:" .. readXMLdone)
			print("RFP: XML Werte gesetzt upd")
			print("RFP: currentDieselPreis update: "..tostring(funitDiesel.pricePerLiter))
			print("RFP: currentDEFPreis update: "..tostring(funitDef.pricePerLiter))
			print("RFP: currentGasPreis update: "..tostring(funitGas.pricePerLiter))
			print("RFP: currentElekPreis update: "..tostring(funitElek.pricePerLiter))
		end
		-------------------------------------------------------------------------------------------------------------------------------------------------
		-- changed "i" to "NewFinish" and added "NewFinish" to saved xml file because when restarting, a new FinishHour and FinishMinute was beeing calculated
		-------------------------------------------------------------------------------------------------------------------------------------------------
		if NewFinish ~= 1 then
			FinishDay, FinishHour, FinishMinute = RandomFuelsPrices:CalculateFinishTimeD(5, 0)
			NewFinish = 1
			print("currentGasPreis: "..tostring(funitGas.pricePerLiter))
			print("currentElekPreis: "..tostring(funitElek.pricePerLiter))
		end
		if calcDebugOn then
			print("FinishHour: "..tostring(FinishHour))
			print("FinishMinute: "..tostring(FinishMinute))
			print("currentDieselPreis: "..tostring(funitDiesel.pricePerLiter))
			print("currentDefPreis: "..tostring(funitDef.pricePerLiter))
			print("currentGasPreis: "..tostring(funitGas.pricePerLiter))
			print("currentElekPreis: "..tostring(funitElek.pricePerLiter))
			print("NewFinish: "..tostring(NewFinish))
			print("##########currentHour: "..tostring(g_currentMission.environment.currentHour))
			-- print("CalculateFinishTime: "..tostring(CalculateFinishTime))
		end
		if NewFinish == 1 and g_currentMission.environment.currentHour == FinishHour and g_currentMission.environment.currentMinute >= FinishMinute then -- NewFinish = safty bonus
			newDP = string.format("%.3f", (math.random(math.max(oldDieselPreis - 77, DieselPreisU), math.min(oldDieselPreis + 83, DieselPreisO)) / 1000 ))
			newAB = string.format("%.3f", (math.random(AdBluePreisU,AdBluePreisO) / 1000 ))
			newMT = string.format("%.3f", (math.random(GasPreisU,GasPreisO) / 1000 ))
			newEL = string.format("%.3f", (math.random(EPreisU,EPreisO) / 1000 ))
			math.randomseed(randSamen)
				funitDiesel.pricePerLiter = newDP		-- Diesel
				funitGas.pricePerLiter = newMT		-- Methane
			-- end
			if sbshDebugOn then	print("Aktueller Dieselpreis [DEBUG]: ".. funitDiesel.pricePerLiter) end

			-- 0 spring, 1 summer, 2 autmn, 3 winter
			if g_currentMission.environment.currentDay ~= FinishDay and g_currentMission.environment.currentSeason == 0 or 2 then
				-- if g_currentMission.environment.currentMinute >= 20 and g_currentMission.environment.currentMinute <= 55 then
					funitDef.pricePerLiter = newAB		-- AdBlue
				-- end
				if sbshDebugOn then
					print("Aktueller AdBluepreis [DEBUG]: ".. funitDef.pricePerLiter)
				end
			end
			
			if g_currentMission.environment.currentSeason == 3 and ElChangedtY == 0 then
				funitElek.pricePerLiter = newEL		-- Strom
				g_currentMission:showBlinkingWarning(g_i18n:getText("text_ElectricalYear") .." "..funitElek.pricePerLiter.." ".. g_i18n:getCurrencySymbol(true) .." / Kw/h", 5024)
				ElChangedtY = 1
			end
			if g_currentMission.environment.currentSeason == 1 then
				ElChangedtY = 0
			end

			if sbshDebugOn then
				print("FinishDay: ".. tostring(FinishDay))
				print("currDay: ".. tostring(g_currentMission.environment.currentDay))
				print("Season: ".. tostring(g_currentMission.environment.currentSeason))
			end

			oldDieselPreis = newDP * 1000

			NewFinish = 0
			-- self:raiseDirtyFlags(dirtyFlag)
		end
		
		-- if g_currentMission.environment.currentMinute <= 5 and g_currentMission.environment.currentMinute >= 1 then
		-- g_currentMission:addExtraPrintText(g_i18n:getText("text_Dieselpreis") .." "..funitDiesel.pricePerLiter.." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
		-- g_currentMission:addExtraPrintText(tostring(g_currentMission.environment.currentSeason))
		-- g_currentMission:addExtraPrintText(g_i18n:getText("text_Defpreis") .." "..string.format("%.3f", funitDef.pricePerLiter).." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
		-- end
	-- end -- g_server
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
if RandomFuelsPrices.loaded == nil then
    RandomFuelsPrices.loaded = true
    
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, RandomFuelsPrices.loadedMission);
    FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, RandomFuelsPrices.saveToXMLFile);
    
    FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, RandomFuelsPrices.loadSettingsForClient)
end



-- RandomFuelsPrices:init()
addModEventListener(RandomFuelsPrices)