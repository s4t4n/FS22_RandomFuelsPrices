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
-- local newDP = 0
-- local newAB = 0
-- local newMT = 0
-- local newEL = 0
local readXMLdone = 0;

RandomFuelsPrices.modDirectory = g_currentModDirectory;
source(RandomFuelsPrices.modDirectory.."variEvent.lua") -- ????

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices.loadedMission(mission, node)
    if mission:getIsServer() then
		local spec = self.spec_RFP
        if mission.missionInfo.savegameDirectory ~= nil and fileExists(mission.missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml") then
            local xmlFile = XMLFile.load("RandomFuelsPrices", mission.missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml")
            if xmlFile ~= nil then
                FinishHour = xmlFile:getFloat("RandomFuelsPrices.FinishHour", FinishHour)
                FinishMinute = xmlFile:getFloat("RandomFuelsPrices.FinishMinute", FinishMinute)
                oldDieselPreis = xmlFile:getFloat("RandomFuelsPrices.oldDieselPreis", oldDieselPreis)
                newAB = xmlFile:getFloat("RandomFuelsPrices.newAB", spec.newAB)
                newMT = xmlFile:getFloat("RandomFuelsPrices.newMT", spec.newMT)
                newEL = xmlFile:getFloat("RandomFuelsPrices.newEL", spec.newEL)
				NewFinish = xmlFile:getFloat("RandomFuelsPrices.NewFinish", NewFinish)
				print("RFP: RandomFuelsPrices.xml loaded")
				print("RFP: RandomFuelsPrices.xml oldDieselPreis: ".. tostring(oldDieselPreis/1000))
				print("RFP: RandomFuelsPrices.xml newAB: ".. tostring(spec.newAB))
				print("RFP: RandomFuelsPrices.xml newMT: ".. tostring(spec.newMT))
				print("RFP: RandomFuelsPrices.xml newEL: ".. tostring(spec.newEL))
				readXMLdone = 1
                xmlFile:delete()
            end
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
			local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
			local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
			spec.newDP = (oldDieselPreis/1000)
			funitDiesel.pricePerLiter = (oldDieselPreis/1000)
			funitDef.pricePerLiter = (spec.newAB)
			funitGas.pricePerLiter = (spec.newMT)
			funitElek.pricePerLiter = (spec.newEL)
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
    if mission.cancelLoading then
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
            xmlFile:setFloat("RandomFuelsPrices.newAB", tonumber(spec.newAB))
            xmlFile:setFloat("RandomFuelsPrices.newMT", tonumber(spec.newMT))
            xmlFile:setFloat("RandomFuelsPrices.newEL", tonumber(spec.newEL))

			xmlFile:setFloat("RandomFuelsPrices.NewFinish", NewFinish)
            xmlFile:save()
            xmlFile:delete()
			print("RFP: RandomFuelsPrices.xml saved")
        end
    end
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- ----------------   Server Sync   --------------------------------

-- function RandomFuelsPrices.SyncClientServer(newDP, newAB, newMT, newEL)
	-- spec.newDP = newDP
	-- spec.newAB = newAB
	-- spec.newMT = newMT
	-- spec.newEL = newEL
	-- spec.vFive = vFive
-- end		
						   
function RandomFuelsPrices:onReadStream(streamId, connection) -- client join the server
	spec.newDP = streamReadFloat32(streamId)
	spec.newAB = streamReadFloat32(streamId)
	spec.newMT = streamReadFloat32(streamId)
	spec.newEL = streamReadFloat32(streamId)
end

function RandomFuelsPrices:onWriteStream(streamId, connection) -- server reg. that a client has joint
	local spec = self.spec_RFP
	streamWriteFloat32(streamId, spec.newDP)
	streamWriteFloat32(streamId, spec.newAB)
	streamWriteFloat32(streamId, spec.newMT)
	streamWriteFloat32(streamId, spec.newEL)
end

function RandomFuelsPrices:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_RFP
		if streamReadBool(streamId) then			
			spec.newDP = streamReadFloat32(streamId)
			spec.newAB = streamReadFloat32(streamId)
			spec.newMT = streamReadFloat32(streamId)
			spec.newEL = streamReadFloat32(streamId)
		end
	end
end

function RandomFuelsPrices:onWriteUpdateStream(streamId, connection, dirtyMask)
	if connection:getIsServer() then
		local spec = self.spec_RFP
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
			streamWriteFloat32(streamId, spec.newDP)
			streamWriteFloat32(streamId, spec.newAB)
			streamWriteFloat32(streamId, spec.newMT)
			streamWriteFloat32(streamId, spec.newEL)
		end
	end
end
-----------------  sync end --------------------------

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:init()
    FSBaseMission.loadMap = Utils.appendedFunction(FSBaseMission.loadMap, RandomFuelsPrices.mapLoaded)
	if g_currentMission ~= nil then
		-- for what
	end
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices.prerequisitesPresent(specializations)
	return true;
end

function RandomFuelsPrices.registerEventListeners(vehicleType)  -- ???? need other nameType
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "CalculateFinishTimeD", RandomFuelsPrices)
    -- SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", RandomFuelsPrices)
    -- SpecializationUtil.registerEventListener(vehicleType, "loadedMission", RandomFuelsPrices)
    -- SpecializationUtil.registerEventListener(vehicleType, "mapLoaded", RandomFuelsPrices)
    -- SpecializationUtil.registerEventListener(vehicleType, "loaded", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "onReadStream", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", RandomFuelsPrices)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", RandomFuelsPrices)
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:mapLoaded() -- ???? zu onLoad machen ?
	local spec = self.spec_RFP -- ???? spec geht hier trotzdem nicht
	local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
	local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
	local funitGas = g_fillTypeManager:getFillTypeByName("METHANE")
	local funitElek = g_fillTypeManager:getFillTypeByName("ELECTRICCHARGE")
	if readXMLdone == 1 then
		funitDiesel.pricePerLiter = (oldDieselPreis/1000) -- ???? newDP, oldDieselPreis is loaded from xml and... calculate max min change on random
		funitDef.pricePerLiter = (spec.newAB)
		funitGas.pricePerLiter = (spec.newMT)
		funitElek.pricePerLiter = (spec.newEL)
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
	-------------------------------------------------------------------
		print("################################################################################################################")
		print("[INFO] RandomFuelsPrices: Set price per liter DIESEL to " .. funitDiesel.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter DEF (adBlue) to " .. funitDef.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter METHANE to " .. funitGas.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter ELECTRICCHARGE to " .. funitElek.pricePerLiter .. " Stand vom " ..Stand)
		print("################################################################################################################")
		print("RandomFuelsPrices: [DEBUG] neuer Diesel Preis " .. tostring(spec.newDP) .. "  neuer DEF Preis: " .. tostring(spec.newAB) .. " €")
		print("RandomFuelsPrices: [DEBUG] neuer Gas Preis " .. tostring(spec.newMT) .. "  neuer Strom Preis: " .. tostring(spec.newEL) .. " €")
		-- print("RandomFuelsPrices: alterDieselPreis: " .. tostring(alterDieselPreis))
		print("RandomFuelsPrices: oldDieselPreis: " .. tostring(oldDieselPreis))
		print("RandomFuelsPrices: Obere Berechnung: " .. tostring(DieselPreisO) .. "  Untere Berechnung: ".. tostring(DieselPreisU))
		-- print("RandomFuelsPrices: funitDiesel.pricePerLiter: " .. tostring(funitDiesel.pricePerLiter))
	end
	-- dirtyFlag = self:getNextDirtyFlag() -- fatal errors
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
function RandomFuelsPrices:onLoad(name)
	self.spec_RFP = {}
	local spec = self.spec_RFP
    -- self.spec_RandomFuelPrices.dirtyFlag = self:getNextDirtyFlag()
	spec.dirtyFlag = self:getNextDirtyFlag()
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
	-- dirtyFlag = self:getNextDirtyFlag() -- error
	-- self:raiseDirtyFlags(dirtyFlag) 
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
-- function RandomFuelsPrices:update(dt)
function RandomFuelsPrices:onUpdate(dt)
	local spec = self.spec_RFP
	-- if self ~= nil then
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
			funitDef.pricePerLiter = (spec.newAB)
			funitGas.pricePerLiter = (spec.newMT)
			funitElek.pricePerLiter = (spec.newEL)
			readXMLdone = 2
			
			if sbshDebugOn then
				print("RFP: XML Werte gesetzt upd")
				print("RFP: currentDieselPreis update: "..tostring(funitDiesel.pricePerLiter))
				print("RFP: currentDEFPreis update: "..tostring(funitDef.pricePerLiter))
				print("RFP: currentGasPreis update: "..tostring(funitGas.pricePerLiter))
				print("RFP: currentElekPreis update: "..tostring(funitElek.pricePerLiter))
			end
		end
		-------------------------------------------------------------------------------------------------------------------------------------------------
		-- changed "i" to "NewFinish" and added "NewFinish" to saved xml file because when restarting, a new FinishHour and FinishMinute was beeing calculated
		-------------------------------------------------------------------------------------------------------------------------------------------------
		if NewFinish ~= 1 then
			FinishDay, FinishHour, FinishMinute = RandomFuelsPrices:CalculateFinishTimeD(5, 0)
			NewFinish = 1
			print("currentGasPreis: "..tostring(funitGas.pricePerLiter))
			print("currentElekPreis: "..tostring(funitElek.pricePerLiter))
			-- dirtyFlag = self:getNextDirtyFlag() -- variprices.lua:345: attempt to call method 'getNextDirtyFlag' (a nil value)
			
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
			spec.newDP = string.format("%.3f", (math.random(math.max(oldDieselPreis - 77, DieselPreisU), math.min(oldDieselPreis + 83, DieselPreisO)) / 1000 ))
			spec.newAB = string.format("%.3f", (math.random(AdBluePreisU,AdBluePreisO) / 1000 ))
			spec.newMT = string.format("%.3f", (math.random(GasPreisU,GasPreisO) / 1000 ))
			spec.newEL = string.format("%.3f", (math.random(EPreisU,EPreisO) / 1000 ))
			math.randomseed(randSamen)
			-- if g_currentMission.environment.currentSeason == 4 and g_currentMission.environment.currentHour < 15 then
				-- newDP = newDP * 1.1
			-- elseif g_currentMission.environment.currentSeason == 0 and g_currentMission.environment.currentDay > 1 then
				-- newDP = newDP * 1.2
			-- end
			-- if g_currentMission.environment.currentMinute >= math.random(1, 59) then
				funitDiesel.pricePerLiter = spec.newDP		-- Diesel
			-- end
			-- math.randomseed(randSamen)
			-- if g_currentMission.environment.currentMinute >= math.random(15, 41) then
				funitGas.pricePerLiter = spec.newMT		-- Methane
			-- end
			if sbshDebugOn then	print("Aktueller Dieselpreis [DEBUG]: ".. funitDiesel.pricePerLiter) end

			-- 0 spring, 1 summer, 2 autmn, 3 winter
			if g_currentMission.environment.currentDay ~= FinishDay and g_currentMission.environment.currentSeason == 0 or 2 then
				-- if g_currentMission.environment.currentMinute >= 20 and g_currentMission.environment.currentMinute <= 55 then
					funitDef.pricePerLiter = spec.newAB		-- AdBlue
				-- end
				if sbshDebugOn then
					print("Aktueller AdBluepreis [DEBUG]: ".. funitDef.pricePerLiter)
				end
			end
			
			if g_currentMission.environment.currentSeason == 3 and ElChangedtY == 0 then
				funitElek.pricePerLiter = spec.newEL		-- Strom
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

			oldDieselPreis = spec.newDP * 1000

			NewFinish = 0
			-- RandomFuelsPrices:dirtyFlag = self:getNextDirtyFlag() -- Error: Running LUA method 'update'.
												-- ...variprices.lua:425: attempt to call method 'getNextDirtyFlag' (a nil value)
			self:raiseDirtyFlags(spec.dirtyFlag)
		end
		
		-- if g_currentMission.environment.currentMinute <= 5 and g_currentMission.environment.currentMinute >= 1 then
		-- g_currentMission:addExtraPrintText(g_i18n:getText("text_Dieselpreis") .." "..funitDiesel.pricePerLiter.." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
		-- g_currentMission:addExtraPrintText(tostring(g_currentMission.environment.currentSeason))
		-- g_currentMission:addExtraPrintText(g_i18n:getText("text_Defpreis") .." "..string.format("%.3f", funitDef.pricePerLiter).." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
		-- end
	-- end -- was self_nil
end

-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
if RandomFuelsPrices.loaded == nil then
    RandomFuelsPrices.loaded = true
    
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, RandomFuelsPrices.loadedMission);
    FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, RandomFuelsPrices.saveToXMLFile);
    
    FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, RandomFuelsPrices.loadSettingsForClient)
end



RandomFuelsPrices:init()
addModEventListener(RandomFuelsPrices)