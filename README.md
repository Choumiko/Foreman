# Foreman

Foreman is a mod for managing blueprints in game. You can manage a list of blueprints in your save game, export them to text and import blueprints others have shared.

![Main GUI](http://i.imgur.com/6SL6FNE.png)

Features
---
###Top buttons:

 - Save blueprints from toolbar/cursor
 - Save blueprint books from cursor
 - Import blueprint/books from text
 - Fix positions in blueprints
 - Export all stored blueprints/books (E button)
 - Load multiple blueprints/books (L button)
 
###Toolbar:

 - Mirror blueprint / active blueprint in book on the cursor (mirroring along the other axis: mirror and rotate by 180°)  
 Works with [Side Inserters](https://mods.factorio.com/mods/GotLag/Side Inserters), [Bob's Adjustable Inserters](https://mods.factorio.com/mods/Bobingabout/bobinserters), Trainstops from [SmartTrains](https://mods.factorio.com/mods/Choumiko/SmartTrains)
 - Replace entities in the blueprint with another one: Click the empty buttons with an item on the cursor. Click "Ok" with a blueprint/book to replace.

###Per blueprint/book buttons

 - Delete stored blueprints (clicking with a blueprint on the cursor will overwrite instead of deleting)
 - Load blueprint to toolbar or to cursor (if clicked with a blueprint)
 - Export blueprint to file
 - Rename blueprints
 - Imports/Exports [Blueprint Strings](https://mods.factorio.com/mods/DaveMcW/blueprint-string)  (Thanks Dave!)

###Virtual blueprints

 - If activated in the settings, Foreman will convert empty blueprints in your inventory into virutal blueprints and remove all but one empty blueprint from the inventory.
 - When trying to load a book Foreman will create empty blueprints if necessary, reducing the number of virtual blueprints accordingly.
 - When loading a blueprint that has fewer blueprints than the book it's loaded into, Foreman will remove the ones that are not needed and convert them into virtual blueprints
 - To convert the virtual blueprints back into normal ones, make sure you have enough space in your inventory and deactivate the setting.

###Hotkeys

 - Toggle the gui: Ctrl + T
 - Mirror blueprint: Alt + R
 
###Console commands:
 
 - Show the main button: /c remote.call("foreman", "show")  
 - Hide the main button: /c remote.call("foreman", "hide")
 - Change button order for stored blueprints (L,E,R,D stand for Load, Export, Rename, Delete): /c remote.call("foreman", "setButtonOrder", "LERD")

###Sharing blueprints across saves:

 - click the Export/Export all button for the blueprint/book you want to share
 - the files are written to:  C:\Users\"Yor user name"\AppData\Roaming\Factorio\script-output on Windows,  to ~/.factorio/script-output on Linux or to wherever you installed the zip version  
 If you can't find it search your PC for the path/filename Foreman prints ingame when exporting
 - to import a blueprint: copy the contents of the file, open the Foreman gui, click the + button and paste it in the textfield, click import.


Todo
---
- wait for 0.15

Credits
---
graphics/save_icon.jpg made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)

***
Changelog
---

1.1.6

 - importing from script doesn't require admin anymore (seemed to cause desyncs)

1.1.5

 - fixed name not being set after importing
 - fixed error with virtual blueprints and set to cursor option
 - importing from script requires the player to be an admin

1.1.4

 - fixed Gui opening for other players

1.1.3

 - added virtual blueprints option (WIP)
 - when loading a book, Foreman will insert empty blueprints into the book if necessary
 - fixed "overwrite books" option not clearing blueprints
 - fixed error when using Export all
 - fixed that exporting blueprints/books would append to the file, instead of overwriting

1.1.2

 - clicking the load button on a stored book with an empty cursor now loads the book into a book with enough empty blueprints in the inventory/toolbar
 - added option to overwrite blueprint books when clicking load with an empty cursor, defaults to false
 - The "load to cursor" and "close gui after loading to cursor" settings now also apply for blueprint books
 - mirroring blueprints now also mirrors tiles
 - fixed error when replacing rails in a blueprint
 - fixed wrong filename being printed when exporting blueprints

1.1.1
 
 - Hotkey to toggle the GUI only works after Blueprints are researched
 - Allowed more characters in blueprints (Only . \ " and ' are removed)

1.1.0

 - added button/hotkey to mirror blueprint/ active blueprint in a book (mirroring along the other axis is just mirroring and rotating by 180°)
 - added buttons to replace an entity with another one (to upgrade belts, assemblers, etc)
 - clicking Delete blueprint with a blueprint on the cursor overwrites the stored blueprint
 - changed remote interface to accept an optional [LuaPlayer](http://lua-api.factorio.com/latest/LuaPlayer.html) argument

1.0.2

 - added support for importing books from blueprintstring format
 - added textfield to change the button order
 - changed expected argument of setButtonOrder to a single string: remote.call("foreman", "setButtonOrder", "LERD")
 - fixed GUI opening for all players when someone saves/renames/deletes a blueprint
 - discontinued updates for the 0.13 version

1.0.1/0.2.6
 
 - added option to close the gui after loading a blueprint to the cursor
 - added Hotkey to toggle the GUI. Ctrl + t by default
 - added option and console command to hide the main button.
 - added console command to change the button order
 - added russian translation

1.0.0

 - version for Factorio 0.14.x

0.2.5

 - readded script input. Strings starting with "do local foo" or "do local script" are treated as script input.
 - added remote functions to add blueprints:  
  remote.call("foreman", "addBlueprint", player, blueprintString, name)  
  remote.call("foreman", "addBook", player, book)  
  remote.call("foreman", "refreshGUI", player)  
  player: LuaPlayer, blueprintString: compressed Blueprint, name: optional name for the blueprint  
  book: a lua table (export a book via Foreman to see the expected format)

0.2.4

- fixed error when no player name is set
- fixed name being ignored when importing single blueprint string

0.2.3

- added Hotkey to clear blueprint book on the cursor (default Shift + right click, must be enabled in the settings!)
- added option to move the loaded blueprint when the load blueprint button is clicked with an empty cursor
- load a single blueprint into a book when 'load blueprint' button is clicked with a blueprint book with an empty blueprint in the active slot
- added missing tooltips to buttons

0.2.2

- fixed importing books from string not working. Books from 0.2.1 have to be exported again for the string to work
- Changed L button to load blueprint string, exported books or the string created by the E button
- added german translation by luma88
- removed debug log

0.2.1

- added support for blueprint books
- clicking the + button with a blueprint book adds the active blueprint only

0.1.26

- New feature: export/import all blueprints to/from a single file
- added tooltips for buttons
- added settings button:
 - added setting to overwrite blueprints if no empty blueprint is found when loading a string
 - display count setting: How many blueprints to show befor scrolling
- added some sprite buttons