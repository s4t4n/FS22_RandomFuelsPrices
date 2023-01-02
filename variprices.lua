--
--
-- Variation priced of fuels diesel an def
--
-- Author: SbSh / Frvetz
-- 11.7.22
-- 0.1.0.0 beta
-- last edit: 30.12.2022
-- variprices.lua
--
-- ToDo:
-- 		l10n einbauen				done
--		def wieder mit einbinden	done
--		save/load					done
--		
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
-- local sbshDebugOn = true;
-- local calcDebugOn = true;
local oldDieselPreis = 1659;	
								---------------------------------------------------------------------------------------------------------------------------------------
local NewFinish = 0 			-- 				I explain later in onUpdate why I added this one
								---------------------------------------------------------------------------------------------------------------------------------------

function RandomFuelsPrices.loadedMission(mission, node)
    if mission:getIsServer() then
        if mission.missionInfo.savegameDirectory ~= nil and fileExists(mission.missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml") then
            local xmlFile = XMLFile.load("RandomFuelsPrices", mission.missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml")
            if xmlFile ~= nil then
                FinishHour = xmlFile:getFloat("RandomFuelsPrices.FinishHour", FinishHour)
                FinishMinute = xmlFile:getFloat("RandomFuelsPrices.FinishMinute", FinishMinute)
                oldDieselPreis = xmlFile:getFloat("RandomFuelsPrices.oldDieselPreis", oldDieselPreis)
                newAB = xmlFile:getFloat("RandomFuelsPrices.newAB", newAB)
				NewFinish = xmlFile:getFloat("RandomFuelsPrices.NewFinish", NewFinish)


				---------------------------------------------------------------------------------------------------------------------------------------
				-- update prices here since mapLoaded is getting loaded after this and therefore the prices are not the old ones
				---------------------------------------------------------------------------------------------------------------------------------------

				local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
				local funitDef = g_fillTypeManager:getFillTypeByName("DEF")

				funitDiesel.pricePerLiter = string.format("%.3f", oldDieselPreis / 1000)
				funitDef.pricePerLiter = newAB
                xmlFile:delete()
            end

		else

			---------------------------------------------------------------------------------------------------------------------------------------
			-- update prices to new "default" when game is started for the first time with the script
			---------------------------------------------------------------------------------------------------------------------------------------
			
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local funitDef = g_fillTypeManager:getFillTypeByName("DEF")

			funitDiesel.pricePerLiter = 1.659
			funitDef.pricePerLiter = 2.500
        end
    end
    if mission.cancelLoading then
        return
    end
end

function RandomFuelsPrices.saveToXMLFile(missionInfo)
    if missionInfo.isValid then
        local xmlFile = XMLFile.create("RandomFuelsPrices", missionInfo.savegameDirectory .. "/RandomFuelsPrices.xml", "RandomFuelsPrices")
        if xmlFile ~= nil then
            xmlFile:setFloat("RandomFuelsPrices.FinishHour", FinishHour)
            xmlFile:setFloat("RandomFuelsPrices.FinishMinute", FinishMinute)
            xmlFile:setFloat("RandomFuelsPrices.oldDieselPreis", oldDieselPreis) 	                    ----------------------------------------------------------------------------------------------------------------------------------
            xmlFile:setFloat("RandomFuelsPrices.newAB", tonumber(newAB))			-- need "tonumber" to get the result of the calculation in onUpdate (otherwise newAB is a string and therfore -> lua callstack 
																										--	(it's a string because: newAB = the whole calculation in onUpdate and not just the result)) | I GUESS
			xmlFile:setFloat("RandomFuelsPrices.NewFinish", NewFinish)				                    ----------------------------------------------------------------------------------------------------------------------------------
            xmlFile:save()
            xmlFile:delete()
        end
    end
end


function RandomFuelsPrices:init()
    FSBaseMission.loadMap = Utils.appendedFunction(FSBaseMission.loadMap, RandomFuelsPrices.mapLoaded)
	if g_currentMission ~= nil then
		-- for what
	end
end
										---------------------------------------------------------------------------------------------------------------------------------------
function RandomFuelsPrices:mapLoaded()  -- 									can delete the whole function
										---------------------------------------------------------------------------------------------------------------------------------------

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
	-- local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
	-- local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
	-- funitDiesel.pricePerLiter = newDP
	-- funitDiesel.pricePerLiter = newAB

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
			print("RandomFuelsPrices: Seed: [DEBUG] " .. tostring(randSamen) .. " dayTime: " .. tostring(g_currentMission.environment.dayTime))
		end
	-------------------------------------------------------------------
		print("################################################################################################################")
		print("[INFO] RandomFuelsPrices: Set price per liter DIESEL to " .. funitDiesel.pricePerLiter .. " Stand vom " ..Stand)
		print("[INFO] RandomFuelsPrices: Set price per liter DEF (adBlue) to " .. funitDef.pricePerLiter .. " Stand vom " ..Stand)
		print("################################################################################################################")
		print("RandomFuelsPrices: [DEBUG] neuer Diesel Preis " .. tostring(newDP) .. "  neuer DEF Preis: " .. tostring(newAB) .. " €")
		print("RandomFuelsPrices: alterDieselPreis: " .. tostring(alterDieselPreis))
		print("RandomFuelsPrices: Obere Berechnung: " .. tostring(DieselPreisO) .. "  Untere Berechnung: ".. tostring(DieselPreisU))
		print("RandomFuelsPrices: funitDiesel.pricePerLiter: " .. tostring(funitDiesel.pricePerLiter))
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- 			calculate "currentHour" and "currentMinute" for when it's 5h later
---------------------------------------------------------------------------------------------------------------------------------------
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
		local alterDieselPreis = funitDiesel.pricePerLiter
		local alterDefPreis = funitDef.pricePerLiter
		local randSamen = math.ceil(g_currentMission.environment.dayTime * 100)
		
		-------------------------------------------------------------------------------------------------------------------------------------------------
		-- changed "i" to "NewFinish" and added "NewFinish" to saved xml file because when restarting, a new FinishHour and FinishMinute was beeing calculated
		-------------------------------------------------------------------------------------------------------------------------------------------------
		if NewFinish ~= 1 then
			FinishDay, FinishHour, FinishMinute = RandomFuelsPrices:CalculateFinishTime(5, 0, self)
			NewFinish = 1
		end
		if calcDebugOn then
			print("FinishHour: "..tostring(FinishHour))
			print("FinishMinute: "..tostring(FinishMinute))
			print("currentDieselPreis: "..tostring(funitDiesel.pricePerLiter))
			print("currentDefPreis: "..tostring(funitDef.pricePerLiter))
		end
		if NewFinish == 1 and g_currentMission.environment.currentHour == FinishHour and g_currentMission.environment.currentMinute >= FinishMinute then -- NewFinish = safty bonus
			local alterDieselPreis = funitDiesel.pricePerLiter
			local alterDefPreis = funitDef.pricePerLiter
			local funitDiesel = g_fillTypeManager:getFillTypeByName("DIESEL")
			local funitDef = g_fillTypeManager:getFillTypeByName("DEF")
			local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
			print("oldDieselPreis: "..tostring(oldDieselPreis))
			
			newDP = string.format("%.3f", (math.random(math.max(oldDieselPreis - 78, DieselPreisU), math.min(oldDieselPreis + 78, DieselPreisO)) / 1000 ))
			newAB = string.format("%.3f", (math.random(AdBluePreisU,AdBluePreisO) / 1000 ))
			math.randomseed(randSamen)
			funitDiesel.pricePerLiter = newDP		-- Diesel
			if sbshDebugOn then
				print("Aktueller Dieselpreis [DEBUG]: ".. funitDiesel.pricePerLiter)
			end
			if not isEntered then
				g_currentMission:showBlinkingWarning(g_i18n:getText("text_DieselpreisNew") .." "..funitDiesel.pricePerLiter.." ".. g_i18n:getCurrencySymbol(true) .." / L", 1500)
			end
			-- 0 spring, 1 summer, 2 autmn, 4 winter
			if g_currentMission.environment.currentDay ~= FinishDay and g_currentMission.environment.currentSeason == 0 or 2 then
				funitDef.pricePerLiter = newAB		-- AdBlue
				if sbshDebugOn then
					print("Aktueller AdBluepreis [DEBUG]: ".. funitDef.pricePerLiter)
				end
				if not isEntered then
					g_currentMission:showBlinkingWarning(g_i18n:getText("text_DefpreisNew") .." "..string.format("%.3f", funitDef.pricePerLiter).." ".. g_i18n:getCurrencySymbol(true) .." / L", 1000)
				end
			end

			if sbshDebugOn then
				print("FinishDay: ".. tostring(FinishDay))
				print("currDay: ".. tostring(g_currentMission.environment.currentDay))
				print("Season: ".. tostring(g_currentMission.environment.currentSeason))
			end

			oldDieselPreis = newDP * 1000

			NewFinish = 0
		end
		if g_currentMission.environment.currentMinute <= 26 and g_currentMission.environment.currentMinute >= 15 then
			g_currentMission:addExtraPrintText(g_i18n:getText("text_Dieselpreis") .." "..funitDiesel.pricePerLiter.." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
			g_currentMission:addExtraPrintText(g_i18n:getText("text_Defpreis") .." "..string.format("%.3f", funitDef.pricePerLiter).." ".. g_i18n:getCurrencySymbol(true) .." / L") -- #l10n
		end
	end
end

if RandomFuelsPrices.loaded == nil then
    RandomFuelsPrices.loaded = true
    
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, RandomFuelsPrices.loadedMission);
    FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, RandomFuelsPrices.saveToXMLFile);
    
    FSBaseMission.onConnectionFinishedLoading = Utils.appendedFunction(FSBaseMission.onConnectionFinishedLoading, RandomFuelsPrices.loadSettingsForClient)
end



RandomFuelsPrices:init()
Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, RandomFuelsPrices.onUpdate);