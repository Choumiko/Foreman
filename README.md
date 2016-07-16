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

###Per blueprint/book buttons

 - Delete stored blueprints
 - Load blueprint to toolbar or to cursor (if clicked with a blueprint)
 - Export blueprint to file
 - Rename blueprints
 - Imports/Exports [Blueprint Strings](https://mods.factorio.com/mods/DaveMcW/blueprint-string)  (Thanks Dave!)

Todo
---
- cleanup the top buttons, only one button to read in strings, one button to add blueprints/books from cursor
- fix duplicate checking
- add 2 missing button graphics
- ???

Credits
---
graphics/save_icon.jpg made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)

***
Changelog
---
0.2.3

- added Hotkey to clear blueprint book on the cursor (default Shift + right click, must be enabled in the settings!)
- added option to move the loaded blueprint when the load blueprint button is clicked with an empty cursor
- load a single blueprint into a book when 'load blueprint' button is clicked with a blueprint book with an empty blueprint in the active slot

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