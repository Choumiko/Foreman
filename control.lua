require "util"
require 'stdlib.string'
require 'stdlib.area.position'
require 'stdlib.game'

BlueprintString = require 'blueprintstring.blueprintstring'
serpent = require 'blueprintstring.serpent0272'

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
end

local function init_player(player)
  local i = player.index
  global.guiSettings[i] = global.guiSettings[i] or {page = 1, displayCount = 10, overwrite = false, hotkey = false, setCursor = false}
  local guiSettings = global.guiSettings[i]
  if guiSettings.overwrite == nil then
    guiSettings.overwrite = false
  end
  if guiSettings.hotkey == nil then
    guiSettings.hotkey = false
  end
  if guiSettings.setCursor == nil then
    guiSettings.setCursor = false
  end
  if guiSettings.closeGui == nil then
    guiSettings.closeGui = false
  end
  if guiSettings.hideButton == nil then
    guiSettings.hideButton = false
  end
  if not guiSettings.buttonOrder then
    guiSettings.buttonOrder = {"D", "L", "E", "R"}
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

addNametoBlueprintString = function(blueprintString, name)
  local tmp = BlueprintString.fromString(blueprintString)
  tmp.name = name
  return BlueprintString.toString(tmp)
end


--removeNameFromBlueprintString = function(blueprintString)
--  local tmp = BlueprintString.fromString(blueprintString)
--  local name = tmp.name
--  tmp.name = nil
--  return BlueprintString.toString(tmp), name
--end

saveToFile = function(player, blueprintIndex, book)
  if not blueprintIndex then
    player.print({"msg-problem-blueprint"})
    return
  end
  local blueprintData, stringOutput, extension
  if book then
    --log("save book")
    blueprintData = util.table.deepcopy(global.books[player.force.name][blueprintIndex])
    --    for _, blueprint in pairs(blueprintData.blueprints) do
    --      blueprint.data = addNametoBlueprintString(blueprintData.data, blueprint.name)
    --    end
    --stringOutput = serpent.dump(blueprintData, {comment=false, name="s"})
    stringOutput = serpent.dump(blueprintData, {comment=false})
    extension = ".book"
  else
    --log("save blueprint")
    blueprintData = global.blueprints[player.force.name][blueprintIndex]
    stringOutput = addNametoBlueprintString(blueprintData.data, blueprintData.name)
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
  game.write_file(filename , stringOutput, player.index)
  player.print({"", player.name, " ", {"msg-export-blueprint"}})
  player.print("File: script-output/".. filename)
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
  if changes.mod_changes.Foreman then
    local newVersion = changes.mod_changes.Foreman.new_version
    local oldVersion = changes.mod_changes.Foreman.old_version
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
      if oldVersion < "0.2.3" then
        global.bpVersion = nil
        for i, player in pairs(game.players) do
          init_player(player)
          if player.gui.center.blueprintSettingsWindow then
            player.gui.center.blueprintSettingsWindow.destroy()
            global.guiSettings[i].windows = false
          end
        end
      end
      if oldVersion < "1.0.1" then
        init_players()
      end
      Game.print_all("Updated Foreman from ".. oldVersion .. " to " .. newVersion)
    end
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
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_force_created, function(event) init_force(event.force) end)

--script.on_event(defines.events.on_forces_merging, on_forces_merging)
script.on_event(defines.events.on_research_finished, on_research_finished)

isValidSlot = function(slot, state)
  if not slot or not slot.valid_for_read then return false end

  --if state then
  if state == "empty" then
    return not slot.is_blueprint_setup()
  elseif state == "setup" then
    return slot.is_blueprint_setup()
  end
  --end
  return true
end

getBlueprintOnCursor = function (player)
  local stack = player.cursor_stack
  if stack.valid_for_read then
    if (stack.type == "blueprint" and isValidSlot(stack, 'setup')) then
      return stack
    elseif (stack.type == "blueprint-book" and isValidSlot(stack.get_inventory(defines.inventory.item_active)[1], 'setup')) then
      return stack.get_inventory(defines.inventory.item_active)[1]
    end
  end
  return false
end

function clearBlueprintBook(event_)
  local _, err = pcall(function(event)
    local player = game.players[event.player_index]
    if not global.guiSettings[player.index].hotkey then
      return
    end
    local cursor_stack = (player.cursor_stack.valid_for_read and player.cursor_stack.type == "blueprint-book") and player.cursor_stack or false
    if cursor_stack then
      cursor_stack.label = ""
      local active = cursor_stack.get_inventory(defines.inventory.item_active)[1]
      local main = cursor_stack.get_inventory(defines.inventory.item_main)

      if isValidSlot(active) then
        active.label = ""
        active.set_blueprint_tiles({})
        active.set_blueprint_entities({})
      end
      for i=1, #main do
        if isValidSlot(main[i]) then
          main[i].label = ""
          main[i].set_blueprint_tiles({})
          main[i].set_blueprint_entities({})
        end
      end
    end
  end, event_)
  if err then game.players[event_.player_index].print(err) end
end

script.on_event("blueprint_delete_book", clearBlueprintBook)

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

function sortAllBlueprints(forceName)
  table.sort(global.blueprints[forceName], sortBlueprint)
  table.sort(global.books[forceName], sortBlueprint)
end

function cleanupName(name)
  return string.gsub(name:trim(), "[\\.\"']", "")
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
GUI = {}

function GUI.createSettingsWindow(player, guiSettings)
  if not player.gui.center.blueprintSettingsWindow then
    local frame = player.gui.center.add{
      type="frame",
      name="blueprintSettingsWindow",
      direction="vertical",
      caption={"window-blueprint-settings"}
    }

    local hotkey = frame.add{type="checkbox", name="blueprintSettingHotkey", caption={"lbl-blueprint-hotkey"}, state = guiSettings.hotkey}
    hotkey.tooltip = {"tooltip-blueprint-hotkey"}

    local overwrite = frame.add{type="checkbox", name="blueprintSettingOverwrite", caption={"lbl-blueprint-overwrite"}, state = guiSettings.overwrite}
    overwrite.tooltip = {"tooltip-blueprint-overwrite"}

    local setCursor = frame.add{type = "checkbox", name = "blueprintSettingSetCursor", caption={"lbl-blueprint-setCursor"}, state = guiSettings.setCursor}
    setCursor.tooltip = {"tooltip-blueprint-setCursor"}

    local closeGui = frame.add{type = "checkbox", name = "blueprintSettingsCloseGui", caption = {"lbl-blueprint-closeGui"}, state = guiSettings.closeGui}
    closeGui.tooltip = {"tooltip-blueprint-closeGui"}

    local hideButton = frame.add{type = "checkbox", name = "blueprintSettingsHideButton", caption = {"lbl-blueprint-hideButton"}, state = guiSettings.hideButton}
    hideButton.tooltip = {"tooltip-blueprint-hideButton"}

    local order = ""
    for _, button in pairs(guiSettings.buttonOrder) do
      order = order .. button
    end
    local buttonOrderFlow = frame.add{type = "flow", direction = "horizontal"}
    buttonOrderFlow.add{type = "label", caption = {"window-blueprint-buttonOrder"}, {"tooltip-blueprint-buttonOrder"}}

    local buttonOrder = frame.add{type = "textfield", name = "blueprintSettingsButtonOrder", text = order}
    buttonOrder.style.minimal_width = 50
    buttonOrder.tooltip = {"tooltip-blueprint-buttonOrder"}

    local displayCountFlow = frame.add{type="flow", direction="horizontal" }
    displayCountFlow.add{type="label", caption={"window-blueprint-displaycount"}, tooltip = {"tooltip-blueprint-displayCount"}}

    local displayCount = displayCountFlow.add{type="textfield", name="blueprintDisplayCountText", text=guiSettings.displayCount .. ""}
    displayCount.style.minimal_width = 30
    displayCount.tooltip = {"tooltip-blueprint-displayCount"}

    local buttonFlow = frame.add{type="flow", direction="horizontal"}
    buttonFlow.add{type="button", name="blueprintSettingsOk", caption={"btn-ok"}, style = "blueprint_button_style"}
    buttonFlow.add{type="button", name="blueprintSettingsCancel", caption={"btn-cancel"}, style = "blueprint_button_style"}

    return {overwrite = overwrite, displayCount = displayCount, hotkey = hotkey, setCursor = setCursor, closeGui = closeGui, hideButton = hideButton, buttonOrder = buttonOrder}
  else
    player.gui.center.blueprintSettingsWindow.destroy()
  end
end

function GUI.getBookButton(type, index)
  if type == "D" then
    return {type="sprite-button", name=index .. "_blueprintInfoBookDelete", tooltip={"tooltip-blueprint-delete"}, sprite="delete_sprite", style="blueprint_sprite_button"}
  end
  if type == "L" then
    return {type="sprite-button", name=index .. "_blueprintInfoBookLoad", tooltip={"tooltip-blueprint-load"}, sprite="load_book_sprite", style="blueprint_sprite_button"}
  end
  if type == "E" then
    return {type="sprite-button", name=index .. "_blueprintInfoBookExport", tooltip={"tooltip-blueprint-export"}, sprite="save_sprite", style="blueprint_sprite_button"}
  end
  if type == "R" then
    return {type="sprite-button", name=index .. "_blueprintInfoRenameBook", tooltip={"tooltip-blueprint-rename"}, sprite="rename_sprite", style="blueprint_sprite_button"}
  end
end

function GUI.createBlueprintFrameBook(gui, index, caption, countBP, guiSettings)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})
  local buttonFlow = frame.add({type="flow", direction="horizontal", style="blueprint_button_flow"})
  for _, type in pairs(guiSettings.buttonOrder) do
    buttonFlow.add(GUI.getBookButton(type,index))
  end
  frame.add{type="label", caption=caption, style="blueprint_label_style", tooltip = {"", countBP, " ", {"item-name.blueprint"}}}
end

function GUI.getButton(type, index)
  if type == "D" then
    return {type="sprite-button", name=index .. "_blueprintInfoDelete", tooltip={"tooltip-blueprint-delete"}, sprite="delete_sprite", style="blueprint_sprite_button"}
  end
  if type == "L" then
    return {type="sprite-button", name=index .. "_blueprintInfoLoad",   tooltip={"tooltip-blueprint-load"},   sprite="load_sprite",   style="blueprint_sprite_button"}
  end
  if type == "E" then
    return {type="sprite-button", name=index .. "_blueprintInfoExport", tooltip={"tooltip-blueprint-export"}, sprite="save_sprite",   style="blueprint_sprite_button"}
  end
  if type == "R" then
    return {type="sprite-button", name=index .. "_blueprintInfoRename", tooltip={"tooltip-blueprint-rename"}, sprite="rename_sprite", style="blueprint_sprite_button"}
  end
end

function GUI.createBlueprintFrame(gui, index, caption, guiSettings)
  if not gui then
    return
  end
  local frame = gui.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})
  local buttonFlow = frame.add({type="flow", direction="horizontal", style="blueprint_button_flow"})

  for _, type in pairs(guiSettings.buttonOrder) do
    buttonFlow.add(GUI.getButton(type,index))
  end
  frame.add({type="label", caption=caption, style="blueprint_label_style"})
end

function GUI.createBlueprintWindow(player, guiSettings)
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

  local buttons = window.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})

  buttons.add({type="sprite-button", name="blueprintNew", tooltip={"tooltip-blueprint-import"}, sprite="add_sprite", style="blueprint_sprite_button"})

  buttons.add{type="sprite-button", name="blueprintNewBook", tooltip={"tooltip-blueprint-import-book"}, style="blueprint_sprite_button", sprite="add_book_sprite"}

  buttons.add({type="sprite-button", name="blueprintFixPositions", tooltip={"tooltip-blueprint-fix"}, style="blueprint_sprite_button", sprite="item/repair-pack"})

  buttons.add({type="button", name="blueprintExportAll", tooltip={"tooltip-blueprint-export-all"}, caption="E", style="blueprint_button_style"})
  buttons.add({type="button", name="blueprintImportAll", tooltip={"tooltip-blueprint-import-all"}, caption="L", style="blueprint_button_style"})
  buttons.add({type="sprite-button", name="blueprintSettings", tooltip={"window-blueprint-settings"}, sprite="settings_sprite", style="blueprint_sprite_button"})

  local tools = window.add({type="frame", direction="horizontal", style="blueprint_thin_frame"})

  tools.add({type = "sprite-button", name="blueprintToolMirror", tooltip = {"tooltip-blueprint-mirror"}, sprite = "mirror_sprite", style = "blueprint_sprite_button"})
  tools.add({type = "label", caption = "Replace"})
  local search = tools.add({type = "sprite-button", name = "blueprintToolSearch", tooltip = {"tooltip-blueprint-search"}, style = "blueprint_sprite_button"})
  search.sprite = guiSettings.search and "entity/"..guiSettings.search or ""

  tools.add({type = "label", caption = "with"})
  local replace = tools.add({type = "sprite-button", name = "blueprintToolReplace", tooltip = {"tooltip-blueprint-replace"}, style = "blueprint_sprite_button"})
  replace.sprite = guiSettings.replace and "entity/" .. guiSettings.replace or ""
  tools.add({type = "button", name = "blueprintToolReplaceOk", caption = {"btn-ok"}, style = "blueprint_button_style"})

  --tools.add({type = "button", name = "blueprintToolMoveUp", caption = "U", tooltip = "Move up 2 tiles", style = "blueprint_button_style"})
  --tools.add({type = "button", name = "blueprintToolMoveRight", caption = "R", tooltip = "Move right 2 tiles", style = "blueprint_button_style"})

  local frame = window.add({type="frame", direction="vertical"})
  frame.style.left_padding = 0
  frame.style.right_padding = 0
  frame.style.top_padding = 0
  frame.style.bottom_padding = 0
  frame.style.resize_row_to_width=true
  local pane = frame.add{
    type = "scroll-pane",
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
    GUI.createBlueprintFrameBook(flow, i, bookData.name, #bookData.blueprints, guiSettings)
  end
  local blueprints = global.blueprints[player.force.name]
  for i,blueprintData in pairs(blueprints) do
    GUI.createBlueprintFrame(flow, i, blueprintData.name, guiSettings)
  end
  guiSettings.windowVisable = true
  return window
end

function GUI.createRenameWindow(player, index, oldName, book)
  local gui = game.players[player.index].gui.center
  if oldName == nil then
    oldName = ""
  end

  local frame = gui.add({type="frame", name="blueprintRenameWindow", direction="vertical", caption={"window-blueprint-rename"}})
  local name = frame.add({type="textfield", name="blueprintRenameText"})
  frame.blueprintRenameText.text = oldName

  local flow = frame.add({type="flow", name="blueprintRenameFlow", direction="horizontal"})
  flow.add({type="button", name="blueprintRenameCancel", caption={"btn-cancel"}})
  flow.add({type="button", name=index .. "_blueprintRenameOk" , caption={"btn-ok"}})

  return {window = frame, name = name, book = book}
end

function GUI.createImportWindow(player)
  local gui = player.gui.center
  local frame = gui.add{type="frame", direction="vertical", caption={"window-blueprint-new"}}
  local flow = frame.add{type="flow", direction="horizontal"}
  flow.add{type="label", caption={"lbl-blueprint-new-name"}}
  local name = flow.add{type="textfield", name="blueprintNewNameText"}

  flow = frame.add{type="flow", direction="horizontal"}
  flow.add{type="label", caption={"lbl-blueprint-new-import"}}
  local importString = flow.add{type="textfield", name="blueprintImportText"}

  flow = frame.add{type="flow", direction="horizontal"}
  flow.add{type="button", name="blueprintImportCancel", caption={"btn-cancel"}}
  flow.add{type="button", name="blueprintImportOk", caption={"btn-import"}}

  return {window = frame, name = name, importString = importString}
end

function GUI.destroyImportWindow(guiSettings)
  if guiSettings.import and guiSettings.import.window.valid then
    guiSettings.import.window.destroy()
  end
  guiSettings.import = false
end

function GUI.refreshOpened(force)
  sortAllBlueprints(force.name)
  for _, p in pairs(force.players) do
    local guiSettings = global.guiSettings[p.index]
    if guiSettings and guiSettings.windowVisable then
      GUI.createBlueprintWindow(p, guiSettings)
    end
  end
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
    if #entities > 0 then
      blueprintStack.blueprint_icons = newTable
    end
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

isDuplicate = function(player, data, name)
  local num = #global.blueprints[player.force.name] + 1
  local fixedName = name or "new_"
  local names = {}
  for _, bp in pairs(global.blueprints[player.force.name]) do
    names[bp.name] = true
    if bp.data == data then
      return bp.name, fixedName
    end
  end
  if names[name] then
    fixedName = name .. "_1"
  end
  if fixedName == "new_" then fixedName = fixedName .. num end
  return false, fixedName
end

isDuplicateBook = function(player, book)
  --TODO properly check duplicates, for now just compare the names
  for _, storedBook in pairs(global.books[player.force.name]) do
    if storedBook.name == book.name then
      player.print("Book with name '" .. storedBook.name .."' already exists" ) --TODO localisation
      return true
    end
  end
  return false
end

addBlueprintToTable = function(player, blueprintString, name)
  local duplicate, fixedName = isDuplicate(player, blueprintString, name)
  if not duplicate then
    table.insert(global.blueprints[player.force.name], {data = blueprintString, name = fixedName})
    Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}}) --TODO localisation
    Game.print_force(player.force, "Name: " .. fixedName) --TODO localisation
    return true
  else
    player.print({"msg-blueprint-exists", duplicate})
    return false
  end
end

addBlueprintFromCursor = function(player, stack)
  local blueprintData = getBlueprintData(stack)
  if blueprintData then
    blueprintData.name = stack.label and cleanupName(stack.label) or nil
    local blueprintString = BlueprintString.toString(blueprintData)
    return addBlueprintToTable(player, blueprintString, blueprintData.name)
  end
end

addBookFromCursor = function(player, cursor_stack)
  local blueprints = {}

  local active = cursor_stack.get_inventory(defines.inventory.item_active)[1]
  local main = cursor_stack.get_inventory(defines.inventory.item_main)
  local data
  local numBooks = #global.books[player.force.name]
  numBooks = numBooks < 10 and "0" .. numBooks or numBooks
  local bookName = cursor_stack.label and cleanupName(cursor_stack.label) or "Book_" .. numBooks
  local num = 0
  if isValidSlot(active, "setup") then
    data = getBlueprintData(active)
    data.name = active.label and active.label or bookName .. "_" .. num
    data.name = cleanupName(data.name)
    table.insert(blueprints, {name = data.name, data = BlueprintString.toString(data)})
    num = num + 1
  end
  for i=1, #main do
    if isValidSlot(main[i], "setup") then
      data = getBlueprintData(main[i])
      data.name = main[i].label or bookName .. "_" .. num
      data.name = cleanupName(data.name)
      table.insert(blueprints, {name = data.name, data = BlueprintString.toString(data)})
      num = num + 1
    end
  end
  if #blueprints > 0 then
    table.insert(global.books[player.force.name], {blueprints = blueprints, name = bookName})
    Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}})
    Game.print_force(player.force, "Name: " .. bookName) --TODO localisation
    return true
  end
end

addBookToTable = function(player, book)
  if not book or not book.blueprints then
    player.print({"msg-problem-string"})
    return
  end
  if #book.blueprints > 0 and not isDuplicateBook(player,book) then
    book.name = book.name or "newBook_" .. (#global.books[player.force.name] + 1)
    table.insert(global.books[player.force.name], {blueprints = book.blueprints, name = book.name})
    Game.print_force(player.force, {"", player.name, ": ",{"msg-blueprint-imported"}})
    Game.print_force(player.force, "Name: " .. book.name) --TODO localisation
    return true
  end
  return
end

importBlueprintString = function(player, importString, name)
  --log("importBlueprintString")
  --  log(importString)
  --  local data, name = removeNameFromBlueprintString(importString)
  --  log(data)
  local data = BlueprintString.fromString(importString)
  if data.book then
    log("Blueprintstring book")
    log(serpent.block(data,{comment=false}))
    local blueprints = {}
    for _, page in pairs(data.book) do
      table.insert(blueprints, {data = BlueprintString.toString(page), name = page.name})
    end
    local tmp = {}
    tmp.name = data.name or name
    tmp.blueprints = blueprints
    return addBookToTable(player, tmp)
  else
    return addBlueprintToTable(player, importString, name)
  end
end

importBookFromString = function(player, data, name)
  if data.blueprints and #data.blueprints > 0 then
    return addBookToTable(player, data, name)
  end
end

importAll = function(player, data)
  local inserted = false
  for _, blueprint in pairs(data.blueprints) do
    inserted = importBlueprintString(player, blueprint.data, blueprint.name) or inserted
  end
  for _, book in pairs(data.books) do
    inserted = importBookFromString(player, book, book.name) or inserted
  end
end

deleteBlueprint = function(player, blueprintIndex, book)
  if blueprintIndex then
    local table_
    if book then
      table_ = global.books[player.force.name]
    else
      table_ = global.blueprints[player.force.name]
    end
    if table_[blueprintIndex] then
      Game.print_force(player.force, player.name.." deleted ".. table_[blueprintIndex].name) --TODO localisation
      table.remove(table_, blueprintIndex)
      return true
    end
  end
end

setButtonOrder = function(player, orderString)
  local order = {}
  if not string.len(orderString) == 4 then
    player.print("Invalid order string") --TODO localisation
  else
    for c in orderString:gmatch"." do
      table.insert(order, c)
    end
    global.guiSettings[player.index].buttonOrder = order
  end
end

function mirror(blueprint)
  local curves, others, stops, signals, tanks = 9, 0, 4, 4, 2

  local smartTrains = remote.interfaces.st and remote.interfaces.st.getProxyPositions
  local smartStops = {["smart-train-stop-proxy"] = {}, ["smart-train-stop-proxy-cargo"] = {}}
  local smartSignal = {}
  local smartCargo = {}
  local proxyKeys = function(trainStop)
    local proxies = remote.call("st", "getProxyPositions", trainStop)
    local signal = proxies.signalProxy.x .. ":" .. proxies.signalProxy.y
    local cargo = proxies.cargo.x .. ":" .. proxies.cargo.y
    return {signal = signal, cargo = cargo}
  end
  local entities = blueprint.get_blueprint_entities()
  local tiles = blueprint.get_blueprint_tiles()
  if entities then
    for i, ent in pairs(entities) do
      local entType = game.entity_prototypes[ent.name] and game.entity_prototypes[ent.name].type
      ent.direction = ent.direction or 0
      if entType == "curved-rail" then
        ent.direction = (curves - ent.direction) % 8
      elseif entType == "rail-signal" or entType == "rail-chain-signal" then
        ent.direction = (signals - ent.direction) % 8
      elseif entType == "train-stop" then
        if ent.name == "smart-train-stop" and smartTrains then
          local proxies = proxyKeys(ent)
          smartStops["smart-train-stop-proxy"][proxies.signal] = {old = {direction = ent.direction, position = Position.copy(ent.position)}}
          smartStops["smart-train-stop-proxy-cargo"][proxies.cargo] = {old = {direction = ent.direction, position = Position.copy(ent.position)}}
          ent.direction = (stops - ent.direction) % 8
          smartStops["smart-train-stop-proxy"][proxies.signal].new = ent
          smartStops["smart-train-stop-proxy-cargo"][proxies.cargo].new = ent
        else
          ent.direction = (stops - ent.direction) % 8
        end
      elseif entType == "storage-tank" then
        ent.direction = (tanks + ent.direction) % 8
      elseif entType == "lamp" and ent.name == "smart-train-stop-proxy" then
        ent.direction = 0
        table.insert(smartSignal, {entity = {name=ent.name, position = Position.copy(ent.position)}, i = i})
      elseif entType == "constant-combinator" and ent.name == "smart-train-stop-proxy-cargo" then
        ent.direction = 0
        table.insert(smartCargo, {entity = {name=ent.name, position = Position.copy(ent.position)}, i = i})
      else
        ent.direction = (others - ent.direction) % 8
      end

      ent.position.x = -1 * ent.position.x

      if ent.drop_position then
        ent.drop_position.x = -1 * ent.drop_position.x
      end
      if ent.pickup_position then
        ent.pickup_position.x = -1 * ent.pickup_position.x
      end
    end
  end
  for _, data in pairs(smartSignal) do
    local proxy = data.entity
    local stop = smartStops[proxy.name][proxy.position.x .. ":" .. proxy.position.y]
    if stop then
      local newPositions = remote.call("st", "getProxyPositions", stop.new)
      entities[data.i].position = newPositions.signalProxy
    else
      log("No proxy found")
      log(proxy.position.x .. ":" .. proxy.position.y)
      log(serpent.block(smartStops,{comment=false}))
    end
  end
  for _, data in pairs(smartCargo) do
    local proxy = data.entity
    local stop = smartStops[proxy.name][proxy.position.x .. ":" .. proxy.position.y]
    if stop then
      local newPositions = remote.call("st", "getProxyPositions", stop.new)
      entities[data.i].position = newPositions.cargo
    else
      log("No proxy found")
      log(proxy.position.x .. ":" .. proxy.position.y)
      log(serpent.block(smartStops,{comment=false}))
    end
  end
  if tiles then
    for _, tile in pairs(tiles) do
      tile.position.x = -1 * tile.position.x
    end
  end
  return {entities = entities, tiles = tiles}
end

local function getEntityNameFromItem(item)
  local itemProto = game.item_prototypes[item.name]
  return itemProto.place_result and itemProto.place_result.name  or false
end

on_gui_click = {

    blueprintTools = function(player, guiSettings)
      if player.gui.left.blueprintWindow == nil then
        GUI.createBlueprintWindow(player, global.guiSettings[player.index])
      else
        player.gui.left.blueprintWindow.destroy()
        guiSettings.windowVisable = false
        if remote.interfaces.YARM and guiSettings.YARM_old_expando then
          remote.call("YARM", "show_expando", player.index)
        end
      end
    end,

    -- adds the blueprint or the active blueprint from cursors book
    -- or opens the window to import a string
    blueprintNew = function(player, guiSettings)
      local cursor_stack = player.cursor_stack
      if cursor_stack and cursor_stack.valid_for_read and
        ( ( cursor_stack.type == "blueprint" and cursor_stack.is_blueprint_setup() ) or
        ( cursor_stack.type == "blueprint-book")
        )
      then
        local blueprint = cursor_stack
        if cursor_stack.type == "blueprint-book" then
          if isValidSlot(cursor_stack.get_inventory(defines.inventory.item_active)[1], "setup") then
            blueprint = cursor_stack.get_inventory(defines.inventory.item_active)[1]
          else
            player.print("Click this button with a book and an active blueprint to add the active blueprint only")
            return
          end
        end
        return addBlueprintFromCursor(player, blueprint)
      else
        if not guiSettings.import then
          guiSettings.import = GUI.createImportWindow(player)
        else
          GUI.destroyImportWindow(guiSettings)
        end
      end
    end,

    -- adds the blueprint on the cursor or opens the import window
    blueprintNewBook = function(player, guiSettings)
      local cursor_stack = player.cursor_stack
      if cursor_stack and cursor_stack.valid_for_read then
        if cursor_stack.type ~= "blueprint-book" then
          player.print("Click this button with a blueprint book to import it")
        else
          return addBookFromCursor(player,cursor_stack)
        end
      else
        if not guiSettings.import then
          guiSettings.import = GUI.createImportWindow(player)
        else
          GUI.destroyImportWindow(guiSettings)
        end
      end
    end,

    blueprintImportAll = function(player, guiSettings)
      if not guiSettings.import then
        guiSettings.import = GUI.createImportWindow(player)
      else
        GUI.destroyImportWindow(guiSettings)
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
      local elements = GUI.createSettingsWindow(player, guiSettings)
      guiSettings.windows = elements
    end,

    blueprintSettingsOk = function(player, guiSettings)
      if player.gui.center.blueprintSettingsWindow then
        if guiSettings.windows then
          guiSettings.overwrite = guiSettings.windows.overwrite.state
          guiSettings.hotkey = guiSettings.windows.hotkey.state
          guiSettings.setCursor = guiSettings.windows.setCursor.state
          guiSettings.closeGui = guiSettings.windows.closeGui.state
          guiSettings.hideButton = guiSettings.windows.hideButton.state
          local newInt = tonumber(guiSettings.windows.displayCount.text) or 1
          newInt = newInt > 0 and newInt or 1
          global.guiSettings[player.index].displayCount = newInt

          local orderString = string.upper(string.trim(guiSettings.windows.buttonOrder.text))
          setButtonOrder(player, orderString)
        end
        player.gui.center.blueprintSettingsWindow.destroy()
        GUI.createBlueprintWindow(player, guiSettings)
        if guiSettings.hideButton then
          player.gui.top.foremanFlow.blueprintTools.style.visible = false
          player.print({"msg-blueprint-hideButton"})
        else
          player.gui.top.foremanFlow.blueprintTools.style.visible = true
        end
      end
    end,

    blueprintSettingsCancel = function(player, guiSettings)
      if player.gui.center.blueprintSettingsWindow then
        player.gui.center.blueprintSettingsWindow.destroy()
        guiSettings.windows = false
      end
    end,

    --exports blueprints and books into a single file
    blueprintExportAll = function(player)
      local data = {books={}, blueprints={}}
      data.blueprints = global.blueprints[player.force.name]
      data.books = global.books[player.force.name]

      if #data.blueprints > 0 or #data.books > 0 then
        local stringOutput = serpent.dump(data)
        if not stringOutput then
          player.print({"msg-problem-blueprint"})
          return
        end
        local folder = player.name ~= "" and player.name:gsub("[/\\:*?\"<>|]", "_") .."/"
        folder = (folder and folder ~= "/") and folder or ""
        local filename = "export" .. #data.blueprints .. "_" .. #data.books
        filename = "blueprint-string/" .. folder .. filename .. ".lua"
        game.write_file(filename , stringOutput)
        Game.print_force(player.force, {"", player.name, " ", {"msg-export-blueprint"}}) --TODO localisation
        Game.print_force(player.force, "File: script-output/".. folder .. filename) --TODO localisation
      end
    end,

    blueprintInfoLoad = function(player, guiSettings, blueprintIndex)
      if not blueprintIndex then
        return
      end

      local cursor_stack = player.cursor_stack
      local blueprint
      if cursor_stack and cursor_stack.valid_for_read then
        if cursor_stack.type == "blueprint" then
          blueprint = cursor_stack
        elseif cursor_stack.type == "blueprint-book" then
          local active = cursor_stack.get_inventory(defines.inventory.item_active)[1]
          if isValidSlot(active,'empty') then
            blueprint = active
          else
            player.print("Active slot of book is not an empty blueprint")
            player.print("Click with a blueprint-book with an empty active blueprint to load that blueprint into the book")
            return
          end
        end
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
          if guiSettings.setCursor and not cursor_stack.valid_for_read then
            if cursor_stack.set_stack(blueprint) then
              blueprint.clear()
            end
          end
          if guiSettings.closeGui and player.gui.left.blueprintWindow then
            player.gui.left.blueprintWindow.destroy()
            return
          end
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

    blueprintInfoBookLoad = function(player, _, blueprintIndex)
      local cursor_stack = player.cursor_stack
      local book = global.books[player.force.name][blueprintIndex]
      if book and cursor_stack and cursor_stack.valid_for_read then
        if cursor_stack.type == "blueprint" then
          player.print("Trying to load a blueprint book with a blueprint on the cursor.")
          return
        end
        if cursor_stack.type == "blueprint-book" then
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
              local oldEntities = getBlueprintData(blueprintOld).entities
              for n, blueprintNew in pairs(book.blueprints) do
                if util.table.compare(oldEntities, BlueprintString.fromString(blueprintNew.data).entities) then
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
                  newBP.name = newBP.name or ""
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
      end
      return true
    end,

    blueprintInfoExport = function(player, _, blueprintIndex)
      saveToFile(player, blueprintIndex, false)
    end,

    blueprintInfoBookExport = function(player, _, blueprintIndex)
      saveToFile(player, blueprintIndex, true)
    end,

    blueprintInfoRename = function(player, guiSettings, blueprintIndex)
      if blueprintIndex ~= nil and guiSettings ~= nil then
        if guiSettings.rename then
          guiSettings.rename.window.destroy()
          guiSettings.rename = nil
          return
        end
        guiSettings.rename = GUI.createRenameWindow(player, blueprintIndex, global.blueprints[player.force.name][blueprintIndex].name)
      end
    end,

    blueprintInfoRenameBook = function(player, guiSettings, blueprintIndex)
      if blueprintIndex ~= nil and guiSettings ~= nil then
        if guiSettings.rename then
          guiSettings.rename.window.destroy()
          guiSettings.rename = nil
          return
        end
        guiSettings.rename = GUI.createRenameWindow(player, blueprintIndex, global.books[player.force.name][blueprintIndex].name, true)
      end
    end,

    blueprintRenameOk = function(player, guiSettings, blueprintIndex)
      if guiSettings.rename and blueprintIndex ~= nil then
        local newName = guiSettings.rename.name.text
        if newName ~= nil then
          newName = cleanupName(newName)
          if newName ~= ""  then
            local blueprintData
            local oldName
            if guiSettings.rename.book then
              blueprintData = global.books[player.force.name][blueprintIndex]
            else
              blueprintData = global.blueprints[player.force.name][blueprintIndex]
            end
            oldName = blueprintData.name
            blueprintData.name = newName
            Game.print_force(player.force, {"msg-blueprint-renamed", player.name, oldName, newName})
            guiSettings.rename.window.destroy()
            guiSettings.rename = nil
            return true
          end
        end
      end
    end,

    blueprintImportOk = function(player, guiSettings)
      if not guiSettings.import or not guiSettings.import.window.valid then
        return
      end
      --local importString = string.trim(guiSettings.import.importString.text)
      local importString = guiSettings.import.importString.text
      if not importString or importString == "" then
        player.print({"msg-empty-string"})
        GUI.destroyImportWindow(guiSettings)
        return
      end
      -- plain blueprintstring, may contain name or not
      if not importString:starts_with("do local") then
        local inserted = importBlueprintString(player, importString, cleanupName(guiSettings.import.name.text))
        GUI.destroyImportWindow(guiSettings)
        return inserted
      end

      -- "do local" type string, can be from export all or a book
      local status, result, script
      if importString:starts_with("do local script") or importString:starts_with("do local foo") then
        result = assert(loadstring(importString))()
        status = result
        script = true
      else
        status, result = serpent.load(importString)
      end
      if not status then
        player.print({"msg-import-blueprint-fail"})
        player.print(result)
        GUI.destroyImportWindow(guiSettings)
        return
      end
      local inserted = false
      --string from Export all
      if result.books then
        inserted = importAll(player, result)
        -- exported book
      elseif result.blueprints then
        inserted = importBookFromString(player, result)
      elseif script then
        local blueprintString = BlueprintString.toString(result)
        inserted = addBlueprintToTable(player, blueprintString, result.name)
      end
      GUI.destroyImportWindow(guiSettings)
      return inserted
    end,

    blueprintImportCancel = function(_, guiSettings)
      GUI.destroyImportWindow(guiSettings)
    end,

    blueprintRenameCancel = function(_, guiSettings)
      if guiSettings.rename then
        guiSettings.rename.window.destroy()
        guiSettings.rename = nil
      end
    end,

    blueprintInfoDelete = function(player, _, blueprintIndex)
      local stack = getBlueprintOnCursor(player)
      if stack then
        local name = global.blueprints[player.force.name][blueprintIndex].name
        deleteBlueprint(player, blueprintIndex)
        local blueprintData = getBlueprintData(stack)
        if blueprintData then
          blueprintData.name = name
          local blueprintString = BlueprintString.toString(blueprintData)
          return addBlueprintToTable(player, blueprintString, name)
        end
      else
        return deleteBlueprint(player, blueprintIndex)
      end
    end,

    blueprintInfoBookDelete = function(player, _, blueprintIndex)
      return deleteBlueprint(player,blueprintIndex, true)
    end,

    blueprintToolMirror = function(player, _, _)
      local blueprint = getBlueprintOnCursor(player)
      if blueprint then
        --local bpEntities = blueprint.get_blueprint_entities()
        local mirrored = mirror(blueprint)
        blueprint.set_blueprint_entities(mirrored.entities)
        blueprint.set_blueprint_tiles(mirrored.tiles)
      else
        player.print("Click this button with a blueprint or book with an active blueprint to mirror it")
      end
    end,

    blueprintToolSearch = function(player, guiSettings, _, element)
      local stack = player.cursor_stack.valid_for_read and player.cursor_stack or false
      local search = stack and getEntityNameFromItem(stack)
      if search then
        element.sprite = "entity/" .. search--stack.name
      else
        element.sprite = ""
      end
      guiSettings.search = search
    end,

    blueprintToolReplace = function(player, guiSettings, _, element)
      local stack = player.cursor_stack.valid_for_read and player.cursor_stack or false
      local replace = stack and getEntityNameFromItem(stack)
      if replace then
        element.sprite = "entity/" .. replace --stack.name
      else
        element.sprite = ""
      end
      guiSettings.replace = replace
    end,

    blueprintToolReplaceOk = function(player, guiSettings)
      local blueprint = getBlueprintOnCursor(player)
      if not blueprint then
        player.print("Click this button with a blueprint or book with an active blueprint to replace entities")
        return
      end
      local s, r = guiSettings.search, guiSettings.replace
      if s and r then
        local bpEntities = blueprint.get_blueprint_entities()
        for _, entity in pairs(bpEntities) do
          if entity.name == s then
            entity.name = r
          end
        end
        blueprint.set_blueprint_entities(bpEntities)
      end
    end,

    on_gui_click = function(event_)
      local _, err = pcall(function(event)
        local player = game.players[event.element.player_index]
        local guiSettings = global.guiSettings[player.index]
        local data = split(event.element.name,"_") or {}
        local blueprintIndex = tonumber(data[1])
        local buttonName = data[2] or event.element.name
        if not player then
          Game.print_all("Something went horribly wrong")
          return
        end
        if buttonName and on_gui_click[buttonName] then
          if on_gui_click[buttonName](player, guiSettings, blueprintIndex, event.element) then
            GUI.refreshOpened(player.force)
          end
        end
      end, event_)
      if err then debugDump(err,true) end
    end
}
script.on_event(defines.events.on_gui_click, on_gui_click.on_gui_click)

local function toggleGui(event_)
  local _, err = pcall(function(event)
    if global.unlocked[game.players[event.player_index].force.name] then
      on_gui_click.blueprintTools(game.players[event.player_index], global.guiSettings[event.player_index])
    end
  end, event_)
  if err then game.players[event_.player_index].print(err) end
end
script.on_event("blueprint_toggle_gui", toggleGui)

local function mirrorKey(event_)
  local _, err = pcall(function(event)
    on_gui_click.blueprintToolMirror(game.players[event.player_index])
  end, event_)
  if err then game.players[event_.player_index].print(err) end
end
script.on_event("blueprint_mirror", mirrorKey)

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

    init_buttons = function()
      init_players(true)
    end,

    addBlueprint = function(player, blueprintString, name)
      if addBlueprintToTable(player, blueprintString, name) then
        GUI.refreshOpened(player.force)
      end
    end,

    addBook = function(player, book)
      if addBookToTable(player, book) then
        GUI.refreshOpened(player.force)
      end
    end,

    refreshGUI = function(p)
      local player = p or game.player
      GUI.refreshOpened(player.force)
    end,

    show = function(p)
      local player = p or game.player
      local topGui = player.gui.top
      if topGui.foremanFlow and topGui.foremanFlow.blueprintTools then
        topGui.foremanFlow.blueprintTools.style.visible = true
      end
    end,

    hide = function(p)
      local player = p or game.player
      local topGui = player.gui.top
      if topGui.foremanFlow and topGui.foremanFlow.blueprintTools then
        topGui.foremanFlow.blueprintTools.style.visible = false
      end
    end,

    setButtonOrder = function(orderString, p)
      local player = p or game.player
      setButtonOrder(player, orderString)
      GUI.refreshOpened(player.force)
    end,
  })
