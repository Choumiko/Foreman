require "util"
require 'stdlib.string'
require 'stdlib.area.position'
require 'stdlib.game'

BlueprintString = require 'blueprintstring.blueprintstring'
serpent = require 'blueprintstring.serpent0272'
MOD_NAME = "Foreman"

function debugLog(message, force)
  if false or force then -- set for debug
    for _,player in pairs(game.players) do
      player.print(message)
  end
  end
end

local function init_global()
  global.blueprints = global.blueprints or {}
  global.books = global.books or {}
  global.guiSettings = global.guiSettings or {}
  global.unlocked = global.unlocked or {}
  global.bpVersion = global.bpVersion or "0.1.2"
end

local function init_player(player)
  local i = player.index
  global.guiSettings[i] = global.guiSettings[i] or {page = 1, displayCount = 10}
  if global.guiSettings[i].overwrite == nil then
    global.guiSettings[i].overwrite = false
  end
end

function createBlueprintButton(player)
  if player.valid then
    local topGui = player.gui.top
    if not topGui.foremanFlow then
      topGui.add{
        type = "flow",
        name = "foremanFlow",
        direction = "horizontal",
        style = "blueprint_thin_flow"
      }
      if not topGui.foremanFlow.blueprintTools then
        topGui.foremanFlow.add({type="sprite-button", name="blueprintTools", sprite="main_button_sprite", style="blueprint_main_button"})
      end
      if topGui.blueprintTools and topGui.blueprintTools.valid then
        topGui.blueprintTools.destroy()
      end
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
  local name = force.name
  global.unlocked[name] = force.technologies["automated-construction"].researched
  global.blueprints[name] = global.blueprints[name] or {}
  global.books[name] = global.books[name] or {}
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

saveToFile = function(player, blueprintIndex, book)
  if not blueprintIndex then
    player.print({"msg-problem-blueprint"})
    return
  end
  local blueprintData, stringOutput, extension
  if book then
    blueprintData = global.books[player.force.name][blueprintIndex]
    stringOutput = serpent.block(blueprintData, {comment=false})
    extension = ".book"
  else
    blueprintData = global.blueprints[player.force.name][blueprintIndex]
    stringOutput = blueprintData.data
    extension = ".blueprint"
  end

  if not stringOutput or not blueprintData then
    player.print({"msg-problem-blueprint"})
    return
  end
  local filename = blueprintData.name
  if filename == nil or filename == "" then
    filename = "export"
  end
  local folder = player.name ~= "" and player.name:gsub("[/\\:*?\"<>|]", "_") .."/"
  folder = (folder and folder ~= "/") and folder or ""
  filename = "blueprint-string/" .. folder .. filename .. extension
  game.write_file(filename , stringOutput)
  Game.print_force(player.force, {"", player.name, " ", {"msg-export-blueprint"}})
  Game.print_force(player.force, "File: script-output/".. folder .. filename)
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

function fix_positions(bp)
  local offset = {x=-0.5,y=-0.5}
  local rail_entities = {["straight-rail"] = true, ["curved-rail"]=true, ["rail-signal"]=true, ["rail-chain-signal"]=true, ["train-stop"]=true, ["smart-train-stop"]=true}
  if contains_entities(bp,rail_entities) then
    offset = { x = -1, y = -1 }
  end
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

function saveVar(var, name,sparse)
  var = var or global
  local n = name or "foreman"
  game.write_file(n..".lua", serpent.block(var, {name="global", sparse=sparse, comment=false}))
end

-- run once
local function on_configuration_changed(changes)
  if not changes.mod_changes then
    return
  end
  if changes.mod_changes[MOD_NAME] then
    local newVersion = changes.mod_changes[MOD_NAME].new_version
    local oldVersion = changes.mod_changes[MOD_NAME].old_version
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
        global.blueprints = {}
        global.unlocked = {}
        init_global()
        init_forces()
        init_players()
        for i, _ in pairs(game.players) do
          global.guiSettings[i].blueprintCount = nil
        end
        if oldVersion < "0.1.0" then
          global.blueprints.player = util.table.deepcopy(tmp)
        elseif oldVersion == "0.1.0" then
          for i,p in pairs(game.players) do
            local f = p.force.name
            for _, bp in pairs(tmp[i]) do
              table.insert(global.blueprints[f], util.table.deepcopy(bp))
            end
          end
        end
      end
      if oldVersion < "0.1.25" then
        local status, err = pcall(function()
          local tmp = {}
          for force, force_blueprints in pairs(global.blueprints) do
            tmp[force] = {}
            for i, blueprint in pairs(force_blueprints) do
              local data = serpent.dump(blueprint)
              local name = blueprint.name
              tmp[force][i] = {data = BlueprintString.toString(BlueprintString.fromString(data)), name = name}
            end
          end
          global.blueprints = tmp
        end)
        if not status then
          debugLog("Error converting blueprints")
          debugLog(err, true)
        end
      end
      if oldVersion < "0.1.26" then
        init_players()
      end
      if oldVersion < "0.2.1" then
        init_global()
        init_forces()
        init_players(true)
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

local function on_research_finished(event)
  if event.research ~= nil and event.research.name == "automated-construction" then
    global.unlocked[event.research.force.name] = true
    for _, player in pairs(event.research.force.players) do
      createBlueprintButton(player, global.guiSettings[player.index])
    end
  end
end

script.on_init(on_init)
script.on_load(on_load)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_force_created, function(event) init_force(event.force) end)

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

function cleanupName(name)
  return string.gsub(name:trim(), "[\\.?~!@#$%^&*(){}\"']", "")
end

function findBlueprint(player, state)
  local inventories = {player.get_inventory(defines.inventory.player_quickbar), player.get_inventory(defines.inventory.player_main)}
  for _, inv in pairs(inventories) do
    for i=1,#inv do
      local itemStack = inv[i]
      if itemStack.valid_for_read and itemStack.type == "blueprint" then
        local setup = itemStack.is_blueprint_setup()
        if (state == "empty" and not setup) or
          (state == "setup" and setup) or
          (state == "whatever")
        then
          return itemStack
        end
      end
    end
  end
end

function createSettingsWindow(player, guiSettings)
  if not player.gui.center.blueprintSettingsWindow then
    local frame = player.gui.center.add{
      type="frame",
      name="blueprintSettingsWindow",
      direction="vertical",
      caption={"window-blueprint-settings"}
    }

    --local flow = frame.add({type="flow", name="blueprintSettingsFlow", direction="vertical"})
    local overwrite = frame.add({type="checkbox", name="blueprintSettingOverwrite", caption={"lbl-blueprint-overwrite"}, state = guiSettings.overwrite})
    overwrite.tooltip = {"blueprint-tt-overwrite"}
    local displayCountFlow = frame.add({type="flow", name="blueprintDisplayCountFlow", direction="horizontal" }) --style="fatcontroller_thin_frame"})
    displayCountFlow.add{type="label", caption={"window-blueprint-displaycount"}}

    local displayCount = displayCountFlow.add({type="textfield", name="blueprintDisplayCountText", text=guiSettings.displayCount .. ""})
    displayCount.style.minimal_width = 30
    local buttonFlow = frame.add{type="flow", direction="horizontal"}
    buttonFlow.add{type="button", name="blueprintSettingsOk", caption={"btn-ok"}}
    buttonFlow.add{type="button", name="blueprintSettingsCancel", caption={"btn-cancel"}}

    return {overwrite = overwrite, displayCount = displayCount}
  else
    player.gui.center.blueprintSettingsWindow.destroy()
  end
end

function createBlueprintFrameBook(gui, index, caption, countBP)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})
  local buttonFlow = frame.add({type="flow", direction="horizontal", style="blueprint_button_flow"})

  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoBookDelete", tooltip={"tooltip-blueprint-delete"}, sprite="delete_sprite", style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoBookLoad", tooltip={"tooltip-blueprint-load"}, sprite="load_book_sprite", style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoBookExport", tooltip={"tooltip-blueprint-export"}, sprite="save_sprite", style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoBookRename", tooltip={"tooltip-blueprint-rename"}, sprite="rename_sprite", style="blueprint_sprite_button"})
  frame.add{type="label", caption=caption, style="blueprint_label_style", tooltip = {"", countBP, " ", {"item-name.blueprint"}}}
end

function createBlueprintFrame(gui, index, caption)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})
  local buttonFlow = frame.add({type="flow", direction="horizontal", style="blueprint_button_flow"})

  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoDelete", tooltip={"tooltip-blueprint-delete"}, sprite="delete_sprite", style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoLoad",   tooltip={"tooltip-blueprint-load"},   sprite="load_sprite",   style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoExport", tooltip={"tooltip-blueprint-export"}, sprite="save_sprite",   style="blueprint_sprite_button"})
  buttonFlow.add({type="sprite-button", name=index .. "_blueprintInfoRename", tooltip={"tooltip-blueprint-rename"}, sprite="rename_sprite", style="blueprint_sprite_button"})
  frame.add({type="label", caption=caption, style="blueprint_label_style"})
end

function createBlueprintWindow(player, guiSettings)
  if not player or not guiSettings then
    return
  end

  local gui = player.gui.left
  if gui.blueprintWindow ~= nil then
    gui.blueprintWindow.destroy()
  end

  if remote.interfaces.YARM then
    guiSettings.YARM_old_expando = remote.call("YARM", "hide_expando", player.index)
  end

  local window = gui.add({type="flow", name="blueprintWindow", direction="vertical", style="blueprint_thin_flow"}) --style="fatcontroller_thin_frame"})  ,caption={"msg-blueprint-window"}
  guiSettings.window = window

  local buttons = window.add({type="frame", name="blueprintButtons", direction="horizontal", style="blueprint_thin_frame"})

  buttons.add({type="sprite-button", name="blueprintNew", tooltip={"tooltip-blueprint-import"}, sprite="add_sprite", style="blueprint_sprite_button"})

  buttons.add{type="sprite-button", name="blueprintNewBook", tooltip={"tooltip-blueprint-import-book"}, style="blueprint_sprite_button", sprite="add_book_sprite"}

  buttons.add({type="sprite-button", name="blueprintFixPositions", tooltip={"tooltip-blueprint-fix"}, style="blueprint_sprite_button", sprite="item/repair-pack"})

  buttons.add({type="button", name="blueprintExportAll", tooltip={"tooltip-blueprint-export-all"}, caption="E", style="blueprint_button_style"})
  buttons.add({type="button", name="blueprintImportAll", tooltip={"tooltip-blueprint-import-all"}, caption="L", style="blueprint_button_style"})
  buttons.add({type="sprite-button", name="blueprintSettings", tooltip={"window-blueprint-settings"}, sprite="settings_sprite", style="blueprint_sprite_button"})

  local frame = window.add({type="frame", name="blueprintFrame", direction="vertical"})
  frame.style.left_padding = 0
  frame.style.right_padding = 0
  frame.style.top_padding = 0
  frame.style.bottom_padding = 0
  frame.style.resize_row_to_width=true
  local pane = frame.add{
    type = "scroll-pane",
    name = "scroll_me",
    style = "blueprint_scroll_style"
  }
  pane.style.maximal_height = math.ceil(41.5*guiSettings.displayCount)
  pane.horizontal_scroll_policy = "never"
  pane.vertical_scroll_policy = "auto"
  local flow = pane.add{
    type="flow",
    direction="vertical",
    style="blueprint_thin_flow"
  }

  local books = global.books[player.force.name]
  for i, bookData in pairs(books) do
    createBlueprintFrameBook(flow, i, bookData.name, #bookData.blueprints)
  end
  local blueprints = global.blueprints[player.force.name]
  for i,blueprintData in pairs(blueprints) do
    createBlueprintFrame(flow, i, blueprintData.name)
  end
  guiSettings.windowVisable = true
  return window
end

function createRenameWindow(gui, index, oldName, book)
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
  if not book then
    flow.add({type="button", name=index .. "_blueprintRenameOk" , caption={"btn-ok"}})
  else
    flow.add({type="button", name=index .. "_blueprintRenameBookOk" , caption={"btn-ok"}})
  end

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

  flow = frame.add({type="flow", name="blueprintNewUnsafeFlow", direction="horizontal"})
  local unsafe = flow.add({type="checkbox", name="unsafe", caption="allow scripts (unsafe!)", state = false})

  flow = frame.add({type="flow", name="blueprintNewButtonFlow", direction="horizontal"})
  flow.add({type="button", name="blueprintNewCancel", caption={"btn-cancel"}})
  flow.add({type="button", name="blueprintNewImport", caption={"btn-import"}})
  return frame, unsafe
end

--write to blueprint
function setBlueprintData(force, blueprintStack, blueprintData)
  return pcall(function()
    if not blueprintStack or not blueprintStack.valid_for_read or blueprintStack.type ~= "blueprint" then
      return false
    end
    local data = BlueprintString.fromString(blueprintData.data)
    --remove unresearched/invalid recipes
    local entities = util.table.deepcopy(data.entities)
    local tiles = data.tiles

    for _, entity in pairs(entities) do
      if entity.recipe then
        --entity.recipe = rename_recipes[entity.recipe] or entity.recipe
        if not force.recipes[entity.recipe] or not force.recipes[entity.recipe].enabled then
          entity.recipe = nil
        end
      end
    end
    local name = cleanupName(blueprintData.name) or "new_" .. (#global.blueprints[force.name] + 1)
    blueprintStack.label = name
    blueprintStack.set_blueprint_entities(entities)
    blueprintStack.set_blueprint_tiles(tiles)

    local newTable = {}
    for i = 0, #data.icons do
      if data.icons[i] then
        table.insert(newTable, data.icons[i])
      end
    end
    blueprintStack.blueprint_icons = newTable
    return true
  end)
end

function getBlueprintData(blueprintStack)
  if not blueprintStack or not blueprintStack.is_blueprint_setup() then
    return
  end
  local data = {}
  data.icons = blueprintStack.blueprint_icons
  data.entities = blueprintStack.get_blueprint_entities()
  data.tiles = blueprintStack.get_blueprint_tiles()
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

isValidSlot = function(slot, state)
  if not slot.valid_for_read then return false end

  if state == "empty" then
    return not slot.is_blueprint_setup()
  elseif state == "setup" then
    return slot.is_blueprint_setup()
  end
  return true
end

isDuplicate = function(player, data)
  for _, bp in pairs(global.blueprints[player.force.name]) do
    if bp.data == data then
      return bp.name
    end
  end
  return false
end

addBlueprintToTable = function(player, name, blueprintData)
  blueprintData.name = nil
  local data = BlueprintString.toString(blueprintData)
  for k,_ in pairs(blueprintData) do
    log(k)
  end
  log("")
  local duplicate = isDuplicate(player, data)
  if not duplicate then
    name = cleanupName(name) or "new_" .. #global.blueprints[player.force.name]+1
    table.insert(global.blueprints[player.force.name], {data = data, name = name})
    table.sort(global.blueprints[player.force.name], sortBlueprint)
    Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}}) --TODO localisation
    Game.print_force(player.force, "Name: " .. blueprintData.name) --TODO localisation
    return true
  else
    player.print({"msg-blueprint-exists", duplicate})
    return false
  end
end

on_gui_click = {

    blueprintTools = function(player, guiSettings)
      if player.gui.left.blueprintWindow == nil then
        createBlueprintWindow(player, global.guiSettings[player.index])
      else
        player.gui.left.blueprintWindow.destroy()
        if remote.interfaces.YARM and guiSettings.YARM_old_expando then
          remote.call("YARM", "show_expando", player.index)
        end
      end
    end,

    blueprintNewBook = function(player)
      local cursor_stack = player.cursor_stack
      if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "blueprint-book" then
        local blueprints = {}

        local active = cursor_stack.get_inventory(defines.inventory.item_active)[1]
        local main = cursor_stack.get_inventory(defines.inventory.item_main)
        local name
        local numBooks = #global.books[player.force.name]
        numBooks = numBooks < 10 and "0" .. numBooks or numBooks
        local bookName = cursor_stack.label or "Book_" .. numBooks
        local num = 0
        if isValidSlot(active, "setup") then
          name = active.label and active.label or bookName .. "_" .. 0
          table.insert(blueprints, {name=cleanupName(name), data=BlueprintString.toString(getBlueprintData(active))})
          num = num + 1
        end
        local suffix
        for i=1, #main do
          if isValidSlot(main[i], "setup") then
            suffix = num < 10 and "0"..num or num
            name = main[i].label or bookName .. "_" .. suffix
            num = num + 1
            table.insert(blueprints, {name=cleanupName(name), data=BlueprintString.toString(getBlueprintData(main[i]))})
          end
        end
        if num > 0 then
          table.insert(global.books[player.force.name], {blueprints = blueprints, name = bookName})
          table.sort(global.books[player.force.name], sortBlueprint)
          Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}})
          Game.print_force(player.force, "Name: " .. bookName) --TODO localisation
        end
        return true
      else
        player.print("Click this button with a blueprint book to import it")
      end
    end,

    blueprintInfoBookDelete = function(player, _, blueprintIndex)
      if blueprintIndex then
        Game.print_force(player.force, player.name.." deleted "..global.books[player.force.name][blueprintIndex].name) --TODO localisation
        table.remove(global.books[player.force.name], blueprintIndex)
        return true
      end
    end,

    blueprintInfoBookLoad = function(player, _, blueprintIndex)
      local cursor_stack = player.cursor_stack
      local book = global.books[player.force.name][blueprintIndex]
      if book and cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "blueprint-book" then
        local count = #book.blueprints
        local active = cursor_stack.get_inventory(defines.inventory.item_active)
        local main = cursor_stack.get_inventory(defines.inventory.item_main)
        local countBookBlueprints = main.get_item_count("blueprint") + active.get_item_count("blueprint")
        active = active[1]

        if countBookBlueprints >= count then
          local empty = {}
          local setup = {}
          local emptyCount = 0
          if isValidSlot(active,'empty') then
            table.insert(empty, active)
            emptyCount = emptyCount + 1
          end
          if isValidSlot(active, "setup") then
            table.insert(setup, active)
          end
          for i=1, #main do
            if isValidSlot(main[i],'empty') then
              table.insert(empty, main[i])
              emptyCount = emptyCount + 1
            end
            if isValidSlot(main[i], "setup") then
              table.insert(setup, main[i])
            end
          end
          local duplicateCount = 0
          local duplicates = {}
          local needed = count - emptyCount
          for _, blueprintOld in pairs(setup) do
            local blueprintString = BlueprintString.toString(getBlueprintData(blueprintOld))
            for n, blueprintNew in pairs(book.blueprints) do
              if blueprintString == blueprintNew.data then
                duplicates[n] = true
                duplicateCount = duplicateCount + 1
              end
            end
          end
          needed = needed - duplicateCount
          local writeIndex = 1
          if needed < 1 then
            for n, newBP in pairs(book.blueprints) do
              if not duplicates[n] and newBP then
                local status, err = pcall(function() setBlueprintData(player.force, empty[writeIndex], newBP) end )
                if status then
                  player.print({"msg-blueprint-loaded", "'" .. newBP.name .. "'"})
                  writeIndex = writeIndex + 1
                else
                  player.print({"msg-blueprint-notloaded"})
                  player.print(err)
                end
              end
              if duplicates[n] then
                player.print("Skipped loading duplicate " .. newBP.name)
              end
            end
            cursor_stack.label = book.name
          else
            player.print("Not enough blueprints in the book. Need " .. needed .. " more") --TODO localisation
            return
          end
        else
          player.print("Not enough blueprints in the book. Need " .. count - countBookBlueprints .. " more") --TODO localisation
          return
        end

      end
      return true
    end,

    blueprintInfoBookExport = function(player, _, blueprintIndex)
      saveToFile(player, blueprintIndex, true)
    end,

    blueprintInfoBookRename = function(player, guiSettings, blueprintIndex)
      if blueprintIndex ~= nil and guiSettings ~= nil then
        if guiSettings.renameWindowVisable then
          guiSettings.renameWindow.destroy()
        end
        guiSettings.renameWindowVisable = true
        guiSettings.renameWindow = createRenameWindow(game.players[player.index].gui.center, blueprintIndex, global.books[player.force.name][blueprintIndex].name, true)
      end
    end,

    blueprintRenameBookOk = function(player, guiSettings, blueprintIndex)
      if guiSettings.renameWindowVisable and blueprintIndex ~= nil then
        local newName = guiSettings.renameWindow.blueprintRenameText.text
        if newName ~= nil then
          newName = cleanupName(newName)
          if newName ~= ""  then
            local blueprintData = global.books[player.force.name][blueprintIndex]
            local oldName = blueprintData.name
            blueprintData.name = newName
            Game.print_force(player.force, {"msg-blueprint-renamed", player.name, oldName, newName})
            guiSettings.renameWindow.destroy()
            guiSettings.renameWindowVisable = false
            return true
          end
        end
      end
    end,

    blueprintNew = function(player, guiSettings)
      if not guiSettings.newWindowVisable then
        local num = (#global.blueprints[player.force.name] + 1) .. ""
        if string.len(num) < 2 then
          num = "0" .. num
        end
        local cursor_stack = player.cursor_stack
        if cursor_stack and cursor_stack.valid_for_read and
          ( ( cursor_stack.type == "blueprint" and cursor_stack.is_blueprint_setup() ) or
          ( cursor_stack.type == "blueprint-book" and isValidSlot(cursor_stack.get_inventory(defines.inventory.item_active)[1], "setup") )
          )
        then
          -- read blueprint from cursor
          local blueprint = cursor_stack
          if cursor_stack.type == "blueprint-book" then
            blueprint = cursor_stack.get_inventory(defines.inventory.item_active)[1]
          end

          local blueprintData = getBlueprintData(blueprint)
          if blueprintData then
            local name = blueprint.label or "new_" .. num
            return addBlueprintToTable(player, name, blueprintData)
          end
        else
          guiSettings.newWindow = createNewBlueprintWindow(game.players[player.index].gui.center, "new_" .. num)
          guiSettings.newWindowVisable = true
        end
      else
        guiSettings.newWindow.destroy()
        guiSettings.newWindowVisable = false
      end
    end,

    blueprintNewCancel = function(_, guiSettings)
      if guiSettings.newWindowVisable then
        guiSettings.newWindow.destroy()
        guiSettings.newWindowVisable = false
      end
    end,

    blueprintNewImport = function(player, guiSettings, _, event)
      if not guiSettings.newWindowVisable then
        return
      end
      local name = cleanupName(guiSettings.newWindow.blueprintNewNameFlow.blueprintNewNameText.text)
      if name == nil or name == "" then
        name = "new_" .. (#global.blueprints[player.force.name] + 1)
      end

      local importString = string.trim(guiSettings.newWindow.blueprintNewImportFlow.blueprintNewImportText.text)
      local blueprintData
      if importString == nil or importString == "" then
        player.print({"msg-empty-string"})
        return
      end
      -- read pasted string
      if string.starts_with(importString, "do local") and event.element.parent.parent.blueprintNewUnsafeFlow.unsafe.state then
        blueprintData = loadstring(importString)()
      else
        blueprintData = BlueprintString.fromString(importString)
      end
      if not blueprintData then
        player.print({"msg-problem-string"})
        return
      end

      if blueprintData.name == nil then
        blueprintData.name = name
      end

      local inserted = addBlueprintToTable(player, blueprintData.name, blueprintData)
      guiSettings.newWindow.destroy()
      guiSettings.newWindowVisable = false
      return inserted
    end,

    blueprintRenameCancel = function(_, guiSettings)
      if guiSettings.renameWindowVisable then
        guiSettings.renameWindow.destroy()
        guiSettings.renameWindowVisable = false
      end
    end,

    blueprintFixPositions = function(player)
      local cursor_stack = player.cursor_stack
      if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "blueprint" and cursor_stack.is_blueprint_setup() then
        local bp = {entities = cursor_stack.get_blueprint_entities(), tiles = cursor_stack.get_blueprint_tiles()}
        bp = fix_positions(bp)
        cursor_stack.set_blueprint_entities(bp.entities)
        cursor_stack.set_blueprint_tiles(bp.tiles)
        player.print("Fixed positions") --TODO localisation
      else
        player.print("Click this button with a blueprint to fix the positions") --TODO localisation
      end
    end,

    blueprintSettings = function(player, guiSettings)
      local elements = createSettingsWindow(player, guiSettings)
      guiSettings.windows = elements
    end,

    blueprintSettingsOk = function(player, guiSettings)
      if player.gui.center.blueprintSettingsWindow then
        if guiSettings.windows then
          global.guiSettings[player.index].overwrite = guiSettings.windows.overwrite.state
          local newInt = tonumber(guiSettings.windows.displayCount.text) or 1
          newInt = newInt > 0 and newInt or 1
          global.guiSettings[player.index].displayCount = newInt
        end
        player.gui.center.blueprintSettingsWindow.destroy()
      end
    end,

    blueprintSettingsCancel = function(player, guiSettings)
      if player.gui.center.blueprintSettingsWindow then
        player.gui.center.blueprintSettingsWindow.destroy()
        guiSettings.windows = false
      end
    end,

    blueprintInfoDelete = function(player, _, blueprintIndex)
      if blueprintIndex then
        debugLog(blueprintIndex)
        Game.print_force(player.force, player.name.." deleted "..global.blueprints[player.force.name][blueprintIndex].name) --TODO localisation
        table.remove(global.blueprints[player.force.name], blueprintIndex)
        return true
      end
    end,

    blueprintInfoLoad = function(player, guiSettings, blueprintIndex)
      -- Load TO hotbar
      if not blueprintIndex then
        return
      end

      local cursor_stack = player.cursor_stack
      local blueprint
      if cursor_stack and cursor_stack.valid_for_read and cursor_stack.type == "blueprint" then
        blueprint = cursor_stack
      else
        blueprint = findBlueprint(player, "empty")
        if not blueprint and guiSettings.overwrite then
          blueprint = findBlueprint(player, "setup")
        end
      end

      local blueprintData = global.blueprints[player.force.name][blueprintIndex]

      if blueprint ~= nil and blueprintData ~= nil then
        local status, err = setBlueprintData(player.force, blueprint, blueprintData)
        if status then
          player.print({"msg-blueprint-loaded", "'"..blueprintData.name.."'"})
        else
          player.print({"msg-blueprint-notloaded"})
          player.print(err)
        end
      else
        if not guiSettings.overwrite then
          player.print({"msg-no-empty-blueprint"})
        else
          player.print({"msg-no-blueprint"})
        end
      end
    end,

    blueprintInfoExport = function(player, _, blueprintIndex)
      saveToFile(player, blueprintIndex, false)
    end,

    blueprintInfoRename = function(player, guiSettings, blueprintIndex)
      if blueprintIndex ~= nil and guiSettings ~= nil then
        if guiSettings.renameWindowVisable then
          guiSettings.renameWindow.destroy()
        end
        guiSettings.renameWindowVisable = true
        guiSettings.renameWindow = createRenameWindow(game.players[player.index].gui.center, blueprintIndex, global.blueprints[player.force.name][blueprintIndex].name)
      end
    end,

    blueprintRenameOk = function(player, guiSettings, blueprintIndex)
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
            return true
          end
        end
      end
    end,

    blueprintExportAll = function(player)
      local blueprints = {}
      for i, blueprint in pairs(global.blueprints[player.force.name]) do
        blueprints[i] = blueprint
      end
      if #blueprints > 0 then
        local stringOutput = serpent.dump(blueprints)
        if not stringOutput then
          player.print({"msg-problem-blueprint"})
          return
        end
        local folder = player.name ~= "" and player.name:gsub("[/\\:*?\"<>|]", "_") .."/"
        local filename = "export" .. #blueprints
        filename = "blueprint-string/" .. folder .. filename .. ".lua"
        game.write_file(filename , stringOutput)
        Game.print_force(player.force, {"", player.name, " ", {"msg-export-blueprint"}}) --TODO localisation
        Game.print_force(player.force, "File: script-output/".. folder .. filename) --TODO localisation
      end
    end,

    blueprintImportAll = function(player, guiSettings)
      local frame = player.gui.center.add({type="frame", name="blueprintImportAllWindow", direction="vertical", caption={"window-blueprint-import-all"}})
      local text = frame.add({type="textfield", name="blueprintImportAllText"})

      local flow = frame.add({type="flow", name="blueprintNewButtonFlow", direction="horizontal"})
      flow.add({type="button", name="blueprintImportAllCancel", caption={"btn-cancel"}})
      flow.add({type="button", name="blueprintImportAllOk", caption={"btn-import"}})

      guiSettings.import = {window = frame, textfield = text}

      return true
    end,

    blueprintImportAllOk = function(player, guiSettings)
      if guiSettings.import and guiSettings.import.window.valid then
        local importString = string.trim(guiSettings.import.textfield.text)
        local status, result = serpent.load(importString)
        if status then
          local forceName = player.force.name
          local names = {}
          for _, bp in pairs(global.blueprints[forceName]) do
            names[bp.name] = bp
          end
          for _, blueprint in pairs(result) do
            if names[blueprint.name] and blueprint.data == names[blueprint.name].data then
              Game.print_force(forceName, {"msg-blueprint-exists", blueprint.name})
            else
              table.insert(global.blueprints[forceName], blueprint)
            end
          end
          guiSettings.import.window.destroy()
          guiSettings.import = nil
          return true
        else
          Game.print_force(player.force, {"msg-import-blueprint-fail"})
          Game.print_force(player.force, result)
        end
      end
    end,

    blueprintImportAllCancel = function(_, guiSettings)
      if guiSettings.import and guiSettings.import.window.valid then
        guiSettings.import.window.destroy()
        guiSettings.import = nil
      end
    end,

    on_gui_click = function(event_)
      local _, err = pcall(function(event)
        local player = game.players[event.element.player_index]
        local guiSettings = global.guiSettings[event.element.player_index]
        local data = split(event.element.name,"_") or {}
        local blueprintIndex = tonumber(data[1])
        local buttonName = data[2] or event.element.name
        if not player then
          Game.print_all("Something went horribly wrong")
          return
        end
        if buttonName and on_gui_click[buttonName] then
          if on_gui_click[buttonName](player, guiSettings, blueprintIndex, event) then
            for _, p in pairs(player.force.players) do
              if global.guiSettings[p.index].windowVisable then
                createBlueprintWindow(p, global.guiSettings[p.index])
              end
            end
          end
        end
      end, event_)
      if err then debugDump(err,true) end
    end
}
script.on_event(defines.events.on_gui_click, on_gui_click.on_gui_click)

remote.add_interface("foreman",
  {
    saveVar = function(name)
      saveVar(global, name, true)
    end,

    init = function()
      global.guiSettings = {}
      global.shared_blueprints = {}
      init_global()
      init_forces()
      init_players(true)
    end,
  })
