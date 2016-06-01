require "defines"
require "util"
require 'stdlib.string'
require 'stdlib.area.position'
require 'stdlib.game'

BlueprintString = require 'blueprintstring.blueprintstring'
require "config"
MOD_NAME = "Foreman"
defaultBook = require "defaultBook"

function debugLog(message, force)
  if false or force then -- set for debug
    for _,player in pairs(game.players) do
      player.print(message)
  end
  end
end

local function init_global()
  global.blueprints = global.blueprints or {}
  global.guiSettings = global.guiSettings or {}
  global.unlocked = global.unlocked or {}
  global.bpVersion = global.bpVersion or "0.1.2"
end

local function init_player(player)
  local i = player.index
  global.guiSettings[i] = global.guiSettings[i] or {page = 1, displayCount = 10}
end

function createBlueprintButton(player, guiSettings)
  if player.valid then
    local topGui = player.gui.top
    if not topGui.blueprintTools  then
      topGui.add({type="button", name="blueprintTools", caption = {"btn-blueprint-main"}, style="blueprint_button_style"})
      guiSettings.foremanVisable = true
    end
  end
end

local function init_players(recreate_gui)
  for i,player in pairs(game.players) do
    init_player(player)
    if recreate_gui then
      if global.unlocked[player.force.name] then
        createBlueprintButton(player,global.guiSettings[i])
      end
    end
  end
end

local function init_force(force)
  if not global.unlocked then
    init_global()
  end
  global.unlocked[force.name] = force.technologies["automated-construction"].researched
  global.blueprints[force.name] = global.blueprints[force.name] or {}
end

local function init_forces()
  for _, force in pairs(game.forces) do
    init_force(force)
  end
end

local function on_init()
  init_global()
  init_forces()
end

local function on_load()
-- set metatables, register conditional event handlers, local references to global
end

function serializeBlueprintData(data)
  if data ~= nil and data.icons ~= nil and (data.entities ~= nil or data.tiles ~= nil) then
    return serpent.dump(data, {name="blueprintData", comment=false, sparse=true})
  end
  return nil
end

function deserializeBlueprintData(data)
  return data
end

saveBlueprint = function(player, blueprintIndex, show, folder)
  local blueprintData = global.blueprints[player.force.name][blueprintIndex]
  --local stringOutput = convertBlueprintDataToString(blueprintData)
  local stringOutput = serializeBlueprintData(blueprintData)
  if not stringOutput then
    player.print({"msg-problem-blueprint"})
    return
  end
  local filename = blueprintData.name
  if filename == nil or filename == "" then
    filename = "export"
  end
  folder = folder or ""
  if player.name ~= "" then
    filename = "blueprints/".. folder .. player.name .. "_" .. filename .. ".blueprint"
  else
    filename = "blueprints/" .. folder .. filename .. ".blueprint"
  end
  game.write_file(filename , stringOutput)
  if show then
    Game.print_force(player.force, {"", player.name, " ", {"msg-export-blueprint"}}) --TODO localisation
    Game.print_force(player.force, "File: script-output/" .. filename) --TODO localisation
  end
end

function convertBlueprint(bp, offset)
  if bp.entities then
    for _, ent in pairs(bp.entities) do
      ent.position = Position.add(ent.position,offset)
    end
  end
  if bp.tiles then
    for _, tile in pairs(bp.tiles) do
      tile.position = Position.add(tile.position,offset)
    end
  end
  return bp
end

function contains_entities(bp, entities)
  if bp.entities then
    for _, ent in pairs(bp.entities) do
      if entities[ent.name] then
        return true
      end
    end
  end
  return false
end

function convert_to_012(bp)
  local offset = {x=-0.5,y=-0.5}
  local rail_entities = {["straight-rail"] = true, ["curved-rail"]=true, ["rail-signal"]=true, ["rail-chain-signal"]=true, ["train-stop"]=true, ["smart-train-stop"]=true}
  if contains_entities(bp,rail_entities) then
    offset = { x = -1, y = -1 }
  end
  log("Converting " .. bp.name .. " to 0.1.2 format")
  bp.version = "0.1.2"
  return convertBlueprint(bp,offset)
end

function convertBlueprints()
  log("Converting blueprints")
  for force, forceBP in pairs(global.blueprints) do
    local player = {name="", force={name=force}, print=function() return end}
    for i, bp in pairs(forceBP) do
      saveBlueprint(player,i,false,"preConversion/")
      if not bp.version then
        convert_to_012(bp)
        saveBlueprint(player,i,false,"postConversion/")
      end
    end
  end
  log("Done")
end

function saveVar(var, name,sparse)
  var = var or global
  local n = name or "foreman"
  game.write_file("blueprint/"..n..".lua", serpent.block(var, {name="global", sparse=sparse, comment=false}))
end

-- run once
local function on_configuration_changed(data)
  if not data or not data.mod_changes then
    return
  end
  if data.mod_changes[MOD_NAME] then
    local newVersion = data.mod_changes[MOD_NAME].new_version
    local oldVersion = data.mod_changes[MOD_NAME].old_version
    -- mod was added to existing save
    init_global()
    if not oldVersion then
      init_global()
      init_forces()
      init_players(true)
    else
      --mod was updated
      if oldVersion < "0.1.1" then
        local tmp = util.table.deepcopy(global.blueprints)
        saveVar(global.blueprints, "pre_0.1.1")
        global.blueprints = {}
        global.unlocked = {}
        init_global()
        init_forces()
        init_players()
        for i, _ in pairs(game.players) do
          global.guiSettings[i].blueprintCount = nil
        end
        if oldVersion < "0.1.0" then
          for _,f in pairs(game.forces) do
            if not config.ignoreForces[f.name] then
              global.blueprints[f.name] = util.table.deepcopy(tmp)
            end
          end
        elseif oldVersion == "0.1.0" then
          for i,p in pairs(game.players) do
            local f = p.force.name
            for _, bp in pairs(tmp[i]) do
              table.insert(global.blueprints[f], util.table.deepcopy(bp))
            end
          end
        end
        saveVar(global.blueprints, "post_0.1.1")
      end
      if oldVersion < "0.1.2" then
        convertBlueprints()
      end
      Game.print_all("Updated Foreman from ".. oldVersion .. " to " .. newVersion)
    end
    global.bpVersion = "0.1.2"
    global.version = newVersion
  end
  --check for other mods
end

function on_player_created(event)
  local player = game.players[event.player_index]
  init_player(player)
  if global.unlocked[player.force.name] then
    createBlueprintButton(player,global.guiSettings[player.index])
  end
end

local function on_force_created(event)
  init_force(event.force)
end

local function createBlueprintButtons(force)
  for _, player in pairs(force.players) do
    createBlueprintButton(player, global.guiSettings[player.index])
  end
end

local function on_research_finished(event)
  if event.research ~= nil and event.research.name == "automated-construction" then
    global.unlocked[event.research.force.name] = true
    createBlueprintButtons(event.research.force)
  end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_force_created, on_force_created)
--script.on_event(defines.events.on_forces_merging, on_forces_merging)
script.on_event(defines.events.on_research_finished, on_research_finished)

function split(stringA, sep)
  sep = sep or ":"
  local fields = {}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(stringA, pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function sortBlueprint(blueprintA, blueprintB)
  if blueprintA.name < blueprintB.name then
    return true
  end
end

function getLastPage(displayCount, blueprintCount)
  local num =  math.floor((blueprintCount - 1) / displayCount ) + 1
  if num == 0 then
    return 1
  else
    return num
  end
end

function cleanupName(name)
  return string.gsub(name:trim(), "[\\.?~!@#$%^&*(){}\"']", "")
end

function findBlueprintsInHotbar(player)
  local blueprints = {}
  if player ~= nil then
    local hotbar = player.get_inventory(defines.inventory.player_quickbar)
    if hotbar ~= nil then
      local i = 1
      while (i < 30) do
        local itemStack
        if pcall(function () itemStack = hotbar[i] end) then
          if itemStack.valid_for_read and itemStack.type == "blueprint" then
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

function findBlueprintInHotbar(player)
  local blueprints = findBlueprintsInHotbar(player)
  if blueprints ~= nil and blueprints[1] ~= nil then
    return blueprints[1]
  end
end

function findSetupBlueprintInHotbar(player)
  local blueprints = findBlueprintsInHotbar(player)
  if not blueprints then
    return
  end
  for _, blueprint in ipairs(blueprints) do
    if blueprint.is_blueprint_setup() then
      return blueprint
    end
  end
end

function findEmptyBlueprintInHotbar(player)
  local blueprints = findBlueprintsInHotbar(player)
  if not blueprints then
    return
  end
  for _, blueprint in ipairs(blueprints) do
    if not blueprint.is_blueprint_setup() then
      return blueprint
    end
  end
end

function createBlueprintFrame(gui, index, blueprintData)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", name=index .. "_blueprintInfoFrame", direction="horizontal", style="blueprint_thin_frame"})
  local buttonFlow = frame.add({type="flow", name=index .. "_InfoButtonFlow", direction="horizontal", style="blueprint_button_flow"})
  buttonFlow.add({type="button", name=index .. "_blueprintInfoDelete", caption={"btn-blueprint-delete"}, style="blueprint_button_style"})
  buttonFlow.add({type="button", name=index .. "_blueprintInfoLoad", caption={"btn-blueprint-load"}, style="blueprint_button_style"})
  buttonFlow.add({type="button", name=index .. "_blueprintInfoExport", caption={"btn-blueprint-export"}, style="blueprint_button_style"})
  buttonFlow.add({type="button", name=index .. "_blueprintInfoRename", caption={"btn-blueprint-rename"}, style="blueprint_button_style"})
  frame.add({type="label", name=index .. "_blueprintInfoName", caption=blueprintData.name, style="blueprint_label_style"})
  return frame
end

function createBlueprintWindow(player, blueprints, guiSettings)
  if not player or not guiSettings then
    return
  end
  debugLog("create window")

  local gui = player.gui.left
  if gui.blueprintWindow ~= nil then
    gui.blueprintWindow.destroy()
  end

  guiSettings.windowVisable = true
  if remote.interfaces.YARM then
    guiSettings.YARM_old_expando = remote.call("YARM", "hide_expando", player.index)
  end

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
  --buttons.add({type="button", name="blueprintClose", caption={"btn-blueprint-close"}, style="blueprint_button_style"})

  local displayed = 0
  local pageStart = ((guiSettings.page - 1) * guiSettings.displayCount)
  for i,blueprintData in pairs(blueprints) do
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

function createRenameWindow(gui, index, oldName)
  if not gui then
    return
  end
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

function createNewBlueprintWindow(gui, blueprintName)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", name="blueprintNewWindow", direction="vertical", caption={"window-blueprint-new"}})
  local flow = frame.add({type="flow", name="blueprintNewNameFlow", direction="horizontal"})
  flow.add({type="label", name="blueprintNewNameLabel", caption={"lbl-blueprint-new-name"}})
  flow.add({type="textfield", name="blueprintNewNameText"})
  flow.blueprintNewNameText.text = blueprintName

  flow = frame.add({type="flow", name="blueprintNewImportFlow", direction="horizontal"})
  flow.add({type="label", name="blueprintNewImportLabel", caption={"lbl-blueprint-new-import"}})
  flow.add({type="textfield", name="blueprintNewImportText"})

  flow = frame.add({type="flow", name="blueprintNewFixFlow", direction="horizontal"})
  flow.add({type="checkbox", name="fixPositions", caption="fix positions", state = true})

  flow = frame.add({type="flow", name="blueprintNewButtonFlow", direction="horizontal"})
  flow.add({type="button", name="blueprintNewCancel", caption={"btn-cancel"}})
  flow.add({type="button", name="blueprintNewImport", caption={"btn-import"}})

  return frame
end

function createDisplayCountWindow(gui, displayCount)
  if not gui then
    return
  end
  local window = gui.add({type="frame", name="blueprintDisplayCountWindow", caption={"window-blueprint-displaycount"}, direction="vertical" }) --style="fatcontroller_thin_frame"})
  window.add({type="textfield", name="blueprintDisplayCountText", text=displayCount .. ""})
  window.blueprintDisplayCountText.text = displayCount .. ""
  window.add({type="button", name="blueprintDisplayCountOK", caption={"btn-ok"}})
  return window
end

--write to blueprint
function setBlueprintData(force, blueprintStack, blueprintData)
  if not blueprintStack then
    return false
  end
  --remove unresearched/invalid recipes
  local entities = util.table.deepcopy(blueprintData.entities)
  local tiles = blueprintData.tiles
  for _, entity in pairs(entities) do
    if entity.recipe then
      if not force.recipes[entity.recipe] or not force.recipes[entity.recipe].enabled then
        entity.recipe = nil
      end
    end
  end
  saveVar(entities, "test")
  blueprintStack.set_blueprint_entities(entities)
  blueprintStack.set_blueprint_tiles(tiles)
  saveVar({e=blueprintStack.get_blueprint_entities(),t=blueprintStack.get_blueprint_tiles()}, "test2")
  --debugDump(serpent.block(blueprintData.entities),true)
  local newTable = {}
  for i = 0, #blueprintData.icons do
    if blueprintData.icons[i] then
      table.insert(newTable, blueprintData.icons[i])
    end
  end
  blueprintStack.blueprint_icons = newTable
  return true
end

function getBlueprintData(blueprintStack)
  if not blueprintStack or not blueprintStack.is_blueprint_setup() then
    return
  end
  local data = {}
  data.icons = blueprintStack.blueprint_icons
  data.entities = blueprintStack.get_blueprint_entities()
  data.tiles = blueprintStack.get_blueprint_tiles()
  data.version = global.bpVersion
  return data
end

function debugDump(var, force)
  if false or force then
    for _,player in pairs(game.players) do
      local msg
      if type(var) == "string" then
        msg = var
      else
        msg = serpent.dump(var, {name="var", comment=false, sparse=false, sortkeys=true})
      end
      player.print(msg)
    end
  end
end

function saveToBook(player)
  local name = player.name or ""
  game.write_file("blueprints/"..name.."_defaultBookPreSave.lua", serpent.dump(defaultBook, {name="blueprints"}))
  game.write_file("blueprints/"..name.."_defaultBook.lua", serpent.dump(global.blueprints[player.force.name], {name="blueprints"}))
  player.print("Exporting all blueprints to single file is going to be removed soon!")
  player.print(#global.blueprints[player.force.name].." blueprints exported")
end

function loadFromBook(player)
  player.print("Importing all blueprints from a single file is going to be removed soon!")
  if #defaultBook > 0 then
    local name = player.name or ""
    game.write_file("blueprints/"..name.."_defaultBookpreLoad.lua", serpent.dump(global.blueprints[player.force.name], {name="blueprints"}))
    for _, bp in pairs(defaultBook) do
      if not bp.version then
        player.print("Converting "..bp.name.. " to 0.1.2 format")
        convert_to_012(bp)
      end
    end
    global.blueprints[player.force.name] = defaultBook
    table.sort(global.blueprints[player.force.name], sortBlueprint)
    player.print(#global.blueprints[player.force.name].." blueprints imported")
  else
    player.print("No blueprints found, skipped loading.")
  end
end

local function on_gui_click(event)
  local _, err = pcall(function(event)
    local refreshWindow = false
    local refreshWindows = false
    local player = game.players[event.element.player_index]
    local guiSettings = global.guiSettings[event.element.player_index]
    local data = split(event.element.name,"_")
    local blueprintIndex = tonumber(data[1])

    if not player then
      Game.print_all("Something went horribly wrong")
      return
    end

    if event.element.name == "blueprintTools" or event.element.name == "blueprintClose" then
      if player.gui.left.blueprintWindow == nil then
        refreshWindow = true
      else
        player.gui.left.blueprintWindow.destroy()
        if remote.interfaces.YARM and guiSettings.YARM_old_expando then
          remote.call("YARM", "show_expando", player.index)
        end
      end
    elseif event.element.name == "blueprintPageBack" then
      if guiSettings.page > 1 then
        guiSettings.page = guiSettings.page - 1
        refreshWindow = true
      end
    elseif event.element.name == "blueprintPageForward" then
      local lastPage = getLastPage(guiSettings.displayCount, #global.blueprints[player.force.name])
      if guiSettings.page < lastPage then
        guiSettings.page = guiSettings.page + 1
        refreshWindow = true
      end
    elseif event.element.name == "blueprintDisplayCount" then
      if not guiSettings.displayCountWindowVisable then
        guiSettings.displayCountWindow = createDisplayCountWindow(game.players[event.element.player_index].gui.center, guiSettings.displayCount)
        guiSettings.displayCountWindowVisable = true
      else
        guiSettings.displayCountWindow.destroy()
        guiSettings.displayCountWindowVisable = false
      end
    elseif event.element.name == "blueprintNew" or event.element.name == "blueprintNewCancel" then
      if not guiSettings.newWindowVisable then
        local num = (#global.blueprints[player.force.name] + 1) .. ""
        if string.len(num) < 2 then
          num = "0" .. num
        end
        guiSettings.newWindow = createNewBlueprintWindow(game.players[event.element.player_index].gui.center, "_New " .. num)
        guiSettings.newWindowVisable = true
      else
        guiSettings.newWindow.destroy()
        guiSettings.newWindowVisable = false
      end
    elseif event.element.name == "blueprintExportAll" then
      saveToBook(game.players[event.element.player_index])
    elseif event.element.name == "blueprintLoadAll" then
      loadFromBook(game.players[event.element.player_index])
      refreshWindows = true
    elseif string.ends_with(event.element.name, "_blueprintInfoDelete") then
      if blueprintIndex ~= nil then
        debugLog(blueprintIndex)
        Game.print_force(player.force, player.name.." deleted "..global.blueprints[player.force.name][blueprintIndex].name) --TODO localisation
        table.remove(global.blueprints[player.force.name], blueprintIndex)
        refreshWindows = true
      end
    elseif string.ends_with(event.element.name, "_blueprintInfoLoad") then
      -- Load TOOOOOOOOOOOOOOOOO hotbar
      if not blueprintIndex then
        return
      end
      local blueprint = findEmptyBlueprintInHotbar(player)

      if not blueprint and config.overwrite then
        blueprint = findBlueprintInHotbar(player)
        if blueprint and config.useCircuit then
          if player.get_item_count("electronic-circuit") > 0 then
            player.remove_item{name="electronic-circuit", count=1}
          else
            player.print({"msg-no-circuit"})
            blueprint = nil
            return
          end
        end
      end

      local blueprintData = global.blueprints[player.force.name][blueprintIndex]

      if blueprint ~= nil and blueprintData ~= nil then
        local status, err = pcall(function() setBlueprintData(player.force, blueprint, blueprintData) end )
        if status then
          player.print({"msg-blueprint-loaded"})
        else
          player.print({"msg-blueprint-notloaded"})
          player.print(err)
        end
      else
        if not config.overwrite then
          player.print({"msg-no-empty-blueprint"})
        else
          player.print({"msg-no-blueprint"})
        end
      end
    elseif string.ends_with(event.element.name, "_blueprintInfoExport") then
      -- Export to file
      if blueprintIndex ~= nil then
        saveBlueprint(player, blueprintIndex, true)
      end
    elseif string.ends_with(event.element.name, "_blueprintInfoRename") then
      if blueprintIndex ~= nil and guiSettings ~= nil then
        if guiSettings.renameWindowVisable then
          guiSettings.renameWindow.destroy()
        end
        guiSettings.renameWindowVisable = true
        guiSettings.renameWindow = createRenameWindow(game.players[event.element.player_index].gui.center, blueprintIndex, global.blueprints[player.force.name][blueprintIndex].name)
      end
    elseif event.element.name == "blueprintNewImport" then
      if not guiSettings.newWindowVisable then
        return
      end
      local name = guiSettings.newWindow.blueprintNewNameFlow.blueprintNewNameText.text
      if name == nil or name == "" then
        name = "new_" .. (#global.blueprints[player.force.name] + 1)
      else
        name = cleanupName(name)
      end

      local importString = string.trim(guiSettings.newWindow.blueprintNewImportFlow.blueprintNewImportText.text)
      local blueprintData
      if importString == nil or importString == "" then
        -- read blueprint in hotbar
        local blueprint = findSetupBlueprintInHotbar(player)
        if blueprint == nil then
          player.print({"msg-no-blueprint"})
          return
        end
        blueprintData = getBlueprintData(blueprint)
        if not blueprintData then
          player.print({"msg-problem-string"})
          return
        end
      else
        -- read pasted string
        if string.starts_with(importString, "do local") then
          blueprintData = BlueprintString.load(importString)
          if blueprintData then
            blueprintData = deserializeBlueprintData(blueprintData)
          end
        else
          blueprintData = BlueprintString.fromString(importString)
        end
        if not blueprintData then
          player.print({"msg-problem-string"})
          return
        end
        if string.starts_with(importString, "do local") then
          log("local " .. serpent.line(blueprintData.name) .. " " .. serpent.line(blueprintData.version))
        else
          if not blueprintData.version then
            local fix = event.element.parent.parent.blueprintNewFixFlow.fixPositions.state
            if not fix then
              blueprintData.version = global.bpVersion
            end
          end
          log("bps " .. serpent.line(blueprintData.name) .. " " .. serpent.line(blueprintData.version))
        end
      end

      if blueprintData.name == nil then
        blueprintData.name = name
      end
      if not blueprintData.version then
        player.print("Converting "..blueprintData.name.." to 0.1.2 format")
        convert_to_012(blueprintData)
        blueprintData.version = global.bpVersion
      end

      table.insert(global.blueprints[player.force.name], blueprintData)
      table.sort(global.blueprints[player.force.name], sortBlueprint)
      Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}}) --TODO localisation
      Game.print_force(player.force, "Name: " .. blueprintData.name) --TODO localisation
      guiSettings.newWindow.destroy()
      guiSettings.newWindowVisable = false
      refreshWindows = true

    elseif event.element.name == "blueprintRenameCancel" then
      if guiSettings.renameWindowVisable then
        guiSettings.renameWindow.destroy()
        guiSettings.renameWindowVisable = false
      end
    elseif string.ends_with(event.element.name,"_blueprintRenameOK") then
      if guiSettings.renameWindowVisable and blueprintIndex ~= nil then
        local newName = guiSettings.renameWindow.blueprintRenameText.text
        if newName ~= nil then
          newName = cleanupName(newName)
          if newName ~= ""  then
            local blueprintData = global.blueprints[player.force.name][blueprintIndex]
            local oldName = blueprintData.name
            blueprintData.name = newName
            Game.print_force(player.force, {"msg-blueprint-renamed", player.name, oldName, newName})
            guiSettings.renameWindow.destroy()
            guiSettings.renameWindowVisable = false
            refreshWindows = true
          end
        end
      end
    elseif event.element.name == "blueprintDisplayCountOK" then
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
          player.print({"msg-notanumber"})
        end
        guiSettings.displayCountWindow.destroy()
        log("w "..serpent.line(guiSettings.displayCountWindow))
        guiSettings.displayCountWindowVisable = false
      end
    end

    if refreshWindow then
      createBlueprintWindow(player, global.blueprints[player.force.name], global.guiSettings[player.index])
    end
    if refreshWindows then
      for _,p in pairs(player.force.players) do
        if global.guiSettings[p.index].windowVisable then
          createBlueprintWindow(p, global.blueprints[p.force.name], global.guiSettings[p.index])
        end
      end
    end
  end, event)
  if err then debugDump(err,true) end
end

script.on_event(defines.events.on_gui_click, on_gui_click)

remote.add_interface("foreman",
  {
    saveVar = function(name)
      saveVar(global, name)
    end,

    init = function()
      global.guiSettings = {}
      global.shared_blueprints = {}
      init_global()
      init_forces()
      init_players(true)
    end,
    
    fixBlueprints = function()
      convertBlueprints()
    end

  })
