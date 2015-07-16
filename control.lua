require "defines"
deflate = require "lmod/deflatelua"
base64 = require "lmod/base64"

defaultBook = require "defaultBook"

local onsave = false

function init()
	--why do this here and not somewhere sane?
	if glob.blueprints == nil then
		glob.blueprints = {}
	end
	if glob.guiSettings == nil then
		glob.guiSettings = {}
	end
	--if #glob.guiSettings < #game.players then
	for i,player in ipairs(game.players) do
		if glob.guiSettings[i] == nil then
			glob.guiSettings[i] = {page = 1, blueprintCount = 0, displayCount = 10}
		end
	end
	--end
	if glob.tech == nil or not glob.tech.valid then
		for i,player in ipairs(game.players) do
			if player.character ~= nil then
				glob.tech = player.character.force.technologies["automated-construction"]
			end
		end
	else
		if glob.tech.researched then
			glob.unlocked = true
		end
	end
end





onTickEvent_long = function(event)
	if event.tick % 300 == 20 then
		init()
		if glob.unlocked then
			game.onevent(defines.events.ontick, nil)
			createBlueprintButtons(game.players, glob.guiSettings)
		end
	end
end

onTickEvent_destroy = function(event)
	game.onevent(defines.events.ontick, glob.onTickEvent)
	for i, window in ipairs(glob.destroy) do
		if window then
			window.destroy()
		end
	end
	glob.destroy = nil
end

ontickEvent = function(event)
	if glob.recreateGuiAtTick == nil or (event.tick %15 == 14 and glob.recreateGuiAtTick < event.tick) then
		debugLog("OnTick")
		init()
		if glob.unlocked then
			debugLog("Unlocked")
			createBlueprintButtons(game.players, glob.guiSettings)
			game.onevent(defines.events.ontick, nil)
		else
			game.onevent(defines.events.ontick, onTickEvent_long)
		end
		glob.recreateGuiAtTick = nil
	-- else if  then
		-- if glob.recreateGuiAtTick ~= nil and glob.recreateGuiAtTick < event.tick then
			-- init()
			-- if glob.unlocked then
				-- createBlueprintButtons(game.players)
				-- game.onevent(defines.events.ontick, nil)
			-- else
				-- game.onevent(defines.events.ontick, onTickEvent_long)
			-- end
		-- end
		-- if glob.skipOne == nil then --WHY, COZ BUGS, THATS WHY!
			-- debugLog("Tick: " .. event.tick)
			-- glob.skipOne = true
		-- else
			-- init()--end
			-- debugLog("Tock: " .. event.tick)
			-- if glob.unlocked then
				-- createBlueprintButtons(game.players)
				-- game.onevent(defines.events.ontick, nil)
			-- else
				-- game.onevent(defines.events.ontick, onTickEvent_long)
			-- end
			-- glob.skipOne = nil 
		-- end
	end
end

game.onevent(defines.events.ontick, ontickEvent)

game.onsave(function()
	game.onevent(defines.events.ontick, ontickEvent)
	-- for i,player in ipairs(game.players) do
		-- if(player ~= nil) then
			-- pcall(function () destroyGuis(player, glob.guiSettings[i]) end)
		-- end
	-- end
	-- for i, player in ipairs(game.players) do
		-- if player.character ~= nil then
			-- destroyGuis(payer, glob.guiSettings[i])
		-- end
	-- end
	--onsave = true
	--glob.guiState = destroyGuis(game.players, glob.guiSettings)
	--game.onevent(defines.events.ontick, ontickEvent)
	--glob.skipNextUpdate = true
	glob.recreateGuiAtTick = game.tick + 60
end)

game.onload(function()
	-- debugLog("OnLoad")
	-- --glob.recreateGuiAtTick = nil
	-- glob.recreateGuiAtTick = game.tick + 60
	-- --init()
	-- game.onevent(defines.events.ontick, ontickEvent)
	-- if not onsave then
		 
	-- else
		-- onsave = false
	-- end
	--game.onevent(defines.events.ontick, ontickEvent)
	--
	-- for i, player in ipairs(game.players) do
		-- if player.character ~= nil then
			-- destroyGuis(payer, glob.guiSettings[i])
		-- end
	-- end
	--game.onevent(defines.events.ontick, ontickEvent)
end)

game.onevent(defines.events.onplayercreated, function(event)
	debugLog("OnPlayerCreated")
	-- glob.recreateGuiAtTick = event.tick + 60
	
	
	
	-- for i,player in ipairs(game.players) do
		-- if glob.guiSettings[i] == nil then
			-- glob.guiSettings[i] = {page = 1, blueprintCount = 0, displayCount = 10}
		-- end
	-- end
	
	-- game.onevent(defines.events.ontick, ontickEvent)
	-- for i,player in ipairs(game.players) do
		-- if(player ~= nil) then
			-- --destroyGuis(player, glob.guiSettings[i])
		-- end
	-- end
	-- init()
	-- someonejoined = true
end)

game.onevent(defines.events.onresearchfinished, function(event)
	if event.research ~= nil and event.research.name == "automated-construction" then
		init()
		createBlueprintButtons(game.players, glob.guiSettings)
	end
end)

function getPlayerIndexFromUsername(username)
	for i, player in ipairs(players) do
		if player ~= nil and player.name == username then
			return i
		end
	end
end

-- function recreateGuis(players, guiState, guiSettingsTable, blurprints)
	-- for i, player in ipairs(players) do
		-- local guiSettings = guiSettingsTable[i]
		-- local state = guiState[i]
		-- if guiState.windowVisable then
			-- createBlueprintWindow(player, guiSettings, blurprints)
		-- end
		-- if guiSettings.newWindowVisable then
			-- createNewBlueprintWindow(player, guiSettings, blurprints)
		-- end
		-- if guiSettings.renameWindowVisable then
			-- guiSettings.renameWindow.destory()
		-- end
		-- if guiSettings.disableCountWindowVisable then
			-- guiSettings.disableCountWindow.destory()
		-- end
	-- end
-- end

function destroyGuis(player, guiSettings)
	if player ~= nil and guiSettings ~= nil then
	--local guiState = {}
		--for i, player in ipairs(players) do
			-- local guiSettings = guiSettingsTable[i]
			-- if player.character ~= nil then
				--local newGuiState = {button = false, windowVisable = false, newWindowVisable = false, renameWindowVisable = false, disableCountWindowVisable = false}
		
		if guiSettings.window then
			guiSettings.windowVisable = false
			guiSettings.window.destroy()
		end
		if guiSettings.newWindow then
			guiSettings.newWindowVisable = false
			guiSettings.newWindow.destroy()
		end
		if guiSettings.renameWindow then
			guiSettings.renameWindowVisable = false
			guiSettings.renameWindow.destroy()
		end
		if guiSettings.disableCountWindow then
			guiSettings.disableCountWindowVisable = false
			guiSettings.disableCountWindow.destroy()
		end
		
		if player.gui.top.blueprintTools then
			guiSettings.foremanVisable = false
			player.gui.top.blueprintTools.destroy()
		end
	end
	
		-- end
	--end
end


function createBlueprintButton(player, guiSettings)
	if player ~= nil then
		debugLog("player not nil")
		local topGui = player.gui.top
		--if not guiSettings.foremanVisable then
			--debugLog("foremanVisable not visable")
		if not topGui.blueprintTools  then
			debugLog(player.name)
			debugLog("create button")
			topGui.add({type="button", name="blueprintTools", caption = {"btn-blueprint-main"}, style="blueprint_button_style"}) 
			guiSettings.foremanVisable = true
		end
	end
end



game.onevent(defines.events.onguiclick, function(event) 
	local refreshWindow = false
	local refreshWindows = false

	if event.element.name == "blueprintTools" or event.element.name == "blueprintClose" then
		local player = game.players[event.element.playerindex]
		if player ~= nil then
			if player.gui.left.blueprintWindow == nil then
				refreshWindow = true
			else
				player.gui.left.blueprintWindow.destroy()
			end
		end
	elseif event.element.name == "blueprintPageBack" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if guiSettings.page > 1 then
			guiSettings.page = guiSettings.page - 1
			refreshWindow = true
		end
	elseif event.element.name == "blueprintPageForward" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		local lastPage = getLastPage(guiSettings.displayCount, #glob.blueprints)
		if guiSettings.page < lastPage then
			guiSettings.page = guiSettings.page + 1
			refreshWindow = true
		end
	elseif event.element.name == "blueprintDisplayCount" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if not guiSettings.displayCountWindowVisable then
			guiSettings.displayCountWindow = createDisplayCountWindow(game.players[event.element.playerindex].gui.center, guiSettings.displayCount)
			guiSettings.displayCountWindowVisable = true
		else
			guiSettings.displayCountWindow.destroy()
			guiSettings.displayCountWindowVisable = false
		end
	elseif event.element.name == "blueprintNew" or event.element.name == "blueprintNewCancel" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if not guiSettings.newWindowVisable then
			local num = (#glob.blueprints + 1) .. ""
			if string.len(num) < 2 then
				num = "0" .. num
			end
			guiSettings.newWindow = createNewBlueprintWindow(game.players[event.element.playerindex].gui.center, "_New " .. num)
			guiSettings.newWindowVisable = true
		else
			guiSettings.newWindow.destroy()
			guiSettings.newWindowVisable = false
		end
	elseif event.element.name == "blueprintExportAll" then
	 saveToBook(game.players[event.element.playerindex])
	elseif event.element.name == "blueprintLoadAll" then
	 loadFromBook(game.players[event.element.playerindex])
	 refreshWindows = true
	elseif endsWith(event.element.name, "_blueprintInfoDelete") then
		local data = split(event.element.name,"_")
		local blueprintIndex = data[1]
		if blueprintIndex ~= nil then
			blueprintIndex = tonumber(blueprintIndex)
			debugLog(blueprintIndex)
			table.remove(glob.blueprints, blueprintIndex)
			refreshWindows = true
		end
	elseif endsWith(event.element.name, "_blueprintInfoLoad") then -- Load TOOOOOOOOOOOOOOOOO hotbar
		local data = split(event.element.name,"_")
		local blueprintIndex = data[1]
		if blueprintIndex ~= nil then
			blueprintIndex = tonumber(blueprintIndex)
			local player = game.players[event.element.playerindex]
			local blueprint = findBlueprintInHotbar(player)
			local blueprintData = glob.blueprints[blueprintIndex]
			
			if blueprint ~= nil and blueprintData ~= nil then
				local status, err = pcall(function() setBlueprintData(blueprint, blueprintData) end )
				if status then
					player.print({"msg-blueprint-loaded"})
				else
					player.print({"msg-blueprint-notloaded"})
					player.print(err)
				end
			else
				game.players[event.element.playerindex].print({"msg-no-blueprint"})
			end
		end	
	elseif endsWith(event.element.name, "_blueprintInfoExport") then -- Export to file
		local data = split(event.element.name,"_")
		local blueprintIndex = data[1]
		local player = game.players[event.element.playerindex]
		if blueprintIndex ~= nil then
			blueprintIndex = tonumber(blueprintIndex)
			local blueprintData = glob.blueprints[blueprintIndex]
			--local stringOutput = convertBlueprintDataToString(blueprintData)
			local stringOutput = serializeBlueprintData(blueprintData)
			if stringOutput then
				--lz77(stringOutput, 3)
				--local out = ipack.compress(stringOutput, 8, 0)
				--debugLog(out)
				--local base64string = base64.encode(out)
				local filename = blueprintData.name
				if filename == nil or filename == "" then
					filname = "export"
				end
				if player.name ~= "" then
					filename = "blueprints/" .. player.name .. "_" .. filename .. ".blueprint"
				else
					filename = "blueprints/" .. filename .. ".blueprint"
				end
				--debugLog("Player: " .. player.name .. " : " .. event.element.playerindex)
				--filename = "blueprints/" .. filename .. ".blueprint"
				--filename64 = "blueprints/" .. blueprintData.name .. "64.blueprint"
				game.makefile(filename , stringOutput)
				--game.makefile(filename64, out)
				player.print({"msg-export-blueprint"})
				player.print("File: script-output/" .. filename)
			else
				player.print({"msg-problem-blueprint"})
			end
		end
	elseif endsWith(event.element.name, "_blueprintInfoRename") then
		local data = split(event.element.name,"_")
		local blueprintIndex = data[1]
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if blueprintIndex ~= nil and guiSettings ~= nil then
			blueprintIndex = tonumber(blueprintIndex)
			if guiSettings.renameWindowVisable then
				guiSettings.renameWindow.destroy()
			end
			guiSettings.renameWindowVisable = true
			guiSettings.renameWindow = createRenameWindow(game.players[event.element.playerindex].gui.center, blueprintIndex, glob.blueprints[blueprintIndex].name)
		end
	elseif event.element.name == "blueprintNewImport" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		local player = game.players[event.element.playerindex]
		if guiSettings.newWindowVisable then
			local name = guiSettings.newWindow.blueprintNewNameFlow.blueprintNewNameText.text
			if name == nil or name == "" then
				name = "new_" .. (#glob.blueprints + 1)
			else
				name = cleanupName(name) 
			end
			
			local importString = guiSettings.newWindow.blueprintNewImportFlow.blueprintNewImportText.text
			local blueprintData
			if importString == nil or importString == "" then
				local blueprint = findSetupBlueprintInHotbar(player)
				if blueprint == nil then
					player.print({"msg-no-blueprint"})
				else
					local status, err = testBlueprint(blueprint)
					if not status then
						player.print({"msg-import-blueprint-fail"})
						player.print(err)
					else
						blueprintData = getBlueprintData(blueprint)
					end
				end
			else
				blueprintData = deserializeBlueprintData(trim(importString))
				if blueprintData == nil then
					player.print({"msg-problem-string"})
				end
			end
			if blueprintData ~= nil then
				if blueprintData.name == nil then
					blueprintData.name = name
				end

				table.insert(glob.blueprints, blueprintData)
				table.sort(glob.blueprints, sortBlueprint)
				player.print({"msg-blueprint-imported"})
				player.print("Name: " .. blueprintData.name)
				destroyWindowNextTick(guiSettings.newWindow)
				guiSettings.newWindowVisable = false
				refreshWindows = true
			end
		end
	elseif event.element.name == "blueprintRenameCancel" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if guiSettings.renameWindowVisable then
			guiSettings.renameWindow.destroy()
			guiSettings.renameWindowVisable = false
		end
	elseif endsWith(event.element.name,"_blueprintRenameOK") then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		local data = split(event.element.name,"_")
		local blueprintIndex = data[1]
		debugLog(blueprintIndex)
		if guiSettings.renameWindowVisable and blueprintIndex ~= nil then
			blueprintIndex = tonumber(blueprintIndex)
			local newName = guiSettings.renameWindow.blueprintRenameText.text
			if newName ~= nil then
				newName = cleanupName(newName)
				if newName ~= ""  then
					local blueprintData = glob.blueprints[blueprintIndex]
					blueprintData.name = newName
					destroyWindowNextTick(guiSettings.renameWindow)
					guiSettings.renameWindowVisable = false
					refreshWindows = true
				end
			end
		end
	elseif event.element.name == "blueprintDisplayCountOK" then
		local guiSettings = glob.guiSettings[event.element.playerindex]
		if guiSettings.displayCountWindowVisable then
			local newInt = tonumber(guiSettings.displayCountWindow.blueprintDisplayCountText.text)
			if newInt then
				if newInt < 1 then
					newInt = 1
				elseif newInt > 50 then
					newInt = 50
				end
				guiSettings.displayCount = newInt
				guiSettings.page = 1
				refreshWindow = true
			else
				game.players[event.element.playerindex].print({"msg-notanumber"})
			end
			destroyWindowNextTick(guiSettings.displayCountWindow)
			guiSettings.displayCountWindowVisable = false
		end
	end
	
	
	
	if refreshWindow then
		createBlueprintWindow(game.players[event.element.playerindex], glob.blueprints, glob.guiSettings[event.element.playerindex])
	end
	if refreshWindows then
		for i,player in ipairs(game.players) do
			if glob.guiSettings[i].windowVisable then
				createBlueprintWindow(player, glob.blueprints, glob.guiSettings[i])
			end
		end
	end

end)

function sortBlueprint(blueprintA, blueprintB)
	if blueprintA.name < blueprintB.name then
		return true
	end
end

function serializeBlueprintData(blueprintData)
	if blueprintData ~= nil and blueprintData.icons ~= nil and blueprintData.entities ~= nil then
		return serpent.dump(blueprintData, {name="blueprintData"})
	end
	return nil
end

function getLastPage(displayCount, blueprintCount)
	local num =  math.floor((blueprintCount - 1) / displayCount ) + 1
	if num == 0 then 
		return 1
	else
		return num
	end
end

function deserializeBlueprintData(dataString)
	if dataString ~= nil then
		local textData = dataString
		if not string.match(dataString, "do local") then
			if string.match(dataString, "Blueprint string") then
				local splitData = split(dataString, " ")
				dataString = splitData[#splitData]
			end
			-- Try to decode "blueprint-string" format (gzip > base64)
			local gzipData
			pcall(function () gzipData = base64.decode(dataString) end)
			if gzipData then
				--debugLog(gzipData)
				
				-- Stolen lock stock from blueprint-string\
				local output = {}
				local status, result = pcall(deflate.gunzip, { input = gzipData, output = function(byte) output[#output+1] = string.char(byte) end })
				if (status) then
					textData = table.concat(output)
				else
					debugLog(result)
				end
			end
		end
		if textData ~= nil then
			--debugLog(textData)
			local ok, copy = deserialize(textData)
			if ok then 
				return copy
			end
		end
	end
	--debugLog("Error:")
	return nil
end

function destroyWindowNextTick(window) -- THIS IS A HACK TO WORKAROUND A GUI TIMING BUG IN FACTORIO
	if glob.destroy == nil then
		glob.destroy = {}
		game.onevent(defines.events.ontick, onTickEvent_destroy)
	end
	table.insert(glob.destroy, window)
end

function cleanupName(name)
	return string.gsub(name, "[\\.?~!@#$%^&*(){}\"']", "") 
end

function isMultiplayer()
	if pcall(function () game.getplayer() end) then
		return false
	else
		return true
	end
end

function testBlueprint(blueprint)
	local entities = blueprint.getblueprintentities()
	convertToRecipeName(entities)
	return pcall(function () blueprint.setblueprintentities(entities) end)
end

function createBlueprintButtons(players, guiSettings)
	for i, player in ipairs(game.players) do
		createBlueprintButton(player, guiSettings[i])
	end
end

function findSetupBlueprintInHotbar(player)
	local blueprints = findBlueprintsInHotbar(player)
	if blueprints ~= nil then
		for i, blueprint in ipairs(blueprints) do
			if blueprint.isblueprintsetup() then
				return blueprint
			end
		end
	end
end

function findBlueprintInHotbar(player)
	local blueprints = findBlueprintsInHotbar(player)
	if blueprints ~= nil and blueprints[1] ~= nil then
		return blueprints[1]
	end
end

function findBlueprintsInHotbar(player)
	local blueprints = {}
	if player ~= nil then
		local hotbar = player.getinventory(1)
		if hotbar ~= nil then
			local i = 1
			while (i < 30) do
				local itemStack
				if pcall(function () itemStack = hotbar[i] end) then
					if itemStack ~= nil and itemStack.type == "blueprint" then
							table.insert(blueprints, itemStack)
					end
					i = i + 1
				else
					i = 100
				end
			end
		end
	end
	return blueprints
end

function createBlueprintWindow(player, blueprints, guiSettings)
	if player ~= nil and guiSettings ~= nil then
		debugLog("create window")
		
		local gui = player.gui.left
		if gui.blueprintWindow ~= nil then
			gui.blueprintWindow.destroy()
		end
		
		guiSettings.windowVisable = true
		
		
		local window = gui.add({type="flow", name="blueprintWindow", direction="vertical", style="blueprint_thin_flow"}) --style="fatcontroller_thin_frame"})  ,caption={"msg-blueprint-window"}
		guiSettings.window = window
		
		local buttons = window.add({type="frame", name="blueprintButtons", direction="horizontal", style="blueprint_thin_frame"})
		local buttonFlow = buttons.add({type="flow", name="pageButtonFlow", direction="horizontal", style="blueprint_button_flow"})
		
		if guiSettings.page <= 1 then
			buttonFlow.add({type="button", name="blueprintPageBack", caption={"btn-blueprint-pageback"}, style="blueprint_disabled_button"})
		else
			buttonFlow.add({type="button", name="blueprintPageBack", caption={"btn-blueprint-pageback"}, style="blueprint_button_style"})
		end
		
		local lastPage = getLastPage(guiSettings.displayCount, #blueprints)
		
		buttonFlow.add({type="button", name="blueprintDisplayCount", caption=guiSettings.page .. "/" .. lastPage, style="blueprint_button_style"})
		if guiSettings.page >= lastPage then
			buttonFlow.add({type="button", name="blueprintPageForward", caption={"btn-blueprint-pageforward"}, style="blueprint_disabled_button"})
		else
			buttonFlow.add({type="button", name="blueprintPageForward", caption={"btn-blueprint-pageforward"}, style="blueprint_button_style"})
		end
		buttons.add({type="button", name="blueprintNew", caption={"btn-blueprint-new"}, style="blueprint_button_style"})
		buttons.add({type="button", name="blueprintExportAll", caption={"btn-blueprint-export"}, style="blueprint_button_style"})
		buttons.add({type="button", name="blueprintLoadAll", caption={"btn-blueprint-load"}, style="blueprint_button_style"})
		buttons.add({type="button", name="blueprintClose", caption={"btn-blueprint-close"}, style="blueprint_button_style"})
		
		local displayed = 0
		local pageStart = ((guiSettings.page - 1) * guiSettings.displayCount)
		for i,blueprintData in ipairs(blueprints) do
			if (i > pageStart) then
				displayed = displayed + 1
				createBlueprintFrame(window, i, blueprintData)
				if displayed >= guiSettings.displayCount then
					break
				end
			end
		end
		
		return window
	end
end

function createBlueprintFrame(gui, index, blueprintData)
	if gui ~= nil then
		local frame = gui.add({type="frame", name=index .. "_blueprintInfoFrame", direction="horizontal", style="blueprint_thin_frame"})
		local buttonFlow = frame.add({type="flow", name=index .. "_InfoButtonFlow", direction="horizontal", style="blueprint_button_flow"})
		buttonFlow.add({type="button", name=index .. "_blueprintInfoDelete", caption={"btn-blueprint-delete"}, style="blueprint_button_style"})
		buttonFlow.add({type="button", name=index .. "_blueprintInfoLoad", caption={"btn-blueprint-load"}, style="blueprint_button_style"})
		buttonFlow.add({type="button", name=index .. "_blueprintInfoExport", caption={"btn-blueprint-export"}, style="blueprint_button_style"})
		buttonFlow.add({type="button", name=index .. "_blueprintInfoRename", caption={"btn-blueprint-rename"}, style="blueprint_button_style"})
		local label = frame.add({type="label", name=index .. "_blueprintInfoName", caption=blueprintData.name, style="blueprint_label_style"})
		--debugLog(blueprintData.name)
		--label.caption = blueprintData.name
		
		return frame
	end
end

function createRenameWindow(gui, index, oldName)
	if gui ~= nil then
		if oldName == nil then 
			oldName = "" 
		end
		
		local frame = gui.add({type="frame", name="blueprintRenameWindow", direction="vertical", caption={"window-blueprint-rename"}})
		frame.add({type="textfield", name="blueprintRenameText"})
		frame.blueprintRenameText.text = oldName
		
		local flow = frame.add({type="flow", name="blueprintRenameFlow", direction="horizontal"})
		flow.add({type="button", name="blueprintRenameCancel", caption={"btn-cancel"}})
		flow.add({type="button", name=index .. "_blueprintRenameOK" , caption={"btn-ok"}})

		return frame
	end
end

function createNewBlueprintWindow(gui, blueprintName)
	if gui ~= nil then
		local frame = gui.add({type="frame", name="blueprintNewWindow", direction="vertical", caption={"window-blueprint-new"}})
		local flow = frame.add({type="flow", name="blueprintNewNameFlow", direction="horizontal"})
		flow.add({type="label", name="blueprintNewNameLabel", caption={"lbl-blueprint-new-name"}})
		flow.add({type="textfield", name="blueprintNewNameText"})
		flow.blueprintNewNameText.text = blueprintName
		
		flow = frame.add({type="flow", name="blueprintNewImportFlow", direction="horizontal"})
		flow.add({type="label", name="blueprintNewImportLabel", caption={"lbl-blueprint-new-import"}})
		flow.add({type="textfield", name="blueprintNewImportText"})
		
		flow = frame.add({type="flow", name="blueprintNewButtonFlow", direction="horizontal"})
		flow.add({type="button", name="blueprintNewCancel", caption={"btn-cancel"}})
		flow.add({type="button", name="blueprintNewImport", caption={"btn-import"}})
		
		return frame
	end
end

function createDisplayCountWindow(gui, displayCount)
	if gui ~= nil then
		local window = gui.add({type="frame", name="blueprintDisplayCountWindow", caption={"window-blueprint-displaycount"}, direction="vertical" }) --style="fatcontroller_thin_frame"}) 
		window.add({type="textfield", name="blueprintDisplayCountText", text=displayCount .. ""})
		window.blueprintDisplayCountText.text = displayCount .. ""
		window.add({type="button", name="blueprintDisplayCountOK", caption={"btn-ok"}})
		return window
	end
end

function setBlueprintData(blueprintStack, blueprintData)
	if blueprintStack ~= nil then
		blueprintStack.setblueprintentities(blueprintData.entities)
		--debugLog(serpent.block(blueprintData.icons))
		local newTable = {}
		for i = 0, #blueprintData.icons do
		  if blueprintData.icons[i] then
			 table.insert(newTable, blueprintData.icons[i])
		  end
		end
		blueprintStack.blueprinticons = newTable
		return true
	end
	return false
end

function getBlueprintData(blueprintStack)
	if blueprintStack ~= nil and blueprintStack.isblueprintsetup() then
		local data = {}
		data.icons = blueprintStack.blueprinticons
		data.entities = blueprintStack.getblueprintentities()
		convertToRecipeName(data.entities)
		return data
	end
	return nil
end

function convertToRecipeName(entities) 
	if entities ~= nil then
		for i,entity in ipairs(entities) do
			if entity.recipe ~= nil then
				if entity.recipe.valid then 
					entity.recipe = entity.recipe.name
				else
					entity.recipe = nil
				end
			end
		end
	end
end

function split(stringA, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(stringA, pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

--function getBlueprintDataText (blueprintData)

-- game.players[1].getinventory(1).getitemstack(1)
-- [13:19:18] <Rseding91|H> Read: name, type, hasgrid, grid, health, durability, ammo, blueprinticons
-- [13:19:25] <Rseding91|H> write: health, durability, blueprinticons
-- [13:19:36] <Rseding91|H> methods: isblueprintsetup(), getblueprintentities(), setblueprintentities()

function debugLog(message)
	if false then -- set for debug
		for i,player in ipairs(game.players) do
			player.print(message)
		end
	end
end

-- Safe deserialize, copied from serpent 0.272
-- Lies! I stole it from blueprint-string, Thanks Dave!
function deserialize(data, opts)
	local f, res = (loadstring or load)('return '..data)
	if not f then f, res = (loadstring or load)(data) end
	if not f then return f, res end
	if opts and opts.safe == false then return pcall(f) end
	local count, thread = 0, coroutine.running()
	local linecount = 0
	local h, m, c = debug.gethook(thread)
	debug.sethook(function (e, l)
		if (e == "call") then
			count = count + 1
			if count >= 3 then error("cannot call functions") end
		elseif (e == "line") then
			linecount = linecount + 1
			if linecount >= 1000 then
				linecount = 0  -- set again, to give us time to remove the hook
				error("timeout")
			end
		end
	end, "cl")
	local res = {pcall(f)}
	count = 0 -- set again, otherwise it's tripped on the next sethook
	debug.sethook(thread, h, m, c)
	return (table.unpack or unpack)(res)
end

function split(stringA, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(stringA, pattern, function(c) fields[#fields+1] = c end)
	return fields
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function saveToBook(player)
  game.makefile("blueprints/defaultBookPreSave.lua", serpent.dump(defaultBook, {name="blueprints"}))
  game.makefile("blueprints/defaultBook.lua", serpent.dump(glob.blueprints, {name="blueprints"}))
  player.print(#glob.blueprints.." blueprints exported")
  --game.makefile("farl/loco"..n..".lua", serpent.block(findAllEntitiesByType("locomotive")))
end

function loadFromBook(player)
  if #defaultBook > 0 then
    game.makefile("blueprints/defaultBookpreLoad.lua", serpent.dump(glob.blueprints, {name="blueprints"}))
    glob.blueprints = defaultBook    
    table.sort(glob.blueprints, sortBlueprint)
    player.print(#glob.blueprints.." blueprints imported")
  else
    player.print("No blueprints found, skipped loading.")
  end
end